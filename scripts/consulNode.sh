#!/bin/bash

# Cargar variables de entorno
if [ -f /tmp/envs ]; then
  source /tmp/envs
fi

echo "Descargando consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Actualizando e instalando consul, NodeJS, NPM y Git"
sudo apt-get update && sudo apt-get install -y consul nodejs npm git

LOCAL_IP=$(hostname -I | awk '{print $2}')


echo "Arrancar un agente de consul"
consul agent -node=${NODE_NAME} -bind=${LOCAL_IP} -enable-script-checks=true \
    -data-dir=/var/consul -config-dir=/etc/consul.d \
    -retry-join=192.168.100.4 > /var/log/consul_client.log 2>&1 &

echo "**** Información versión NodeJS"
node -v
echo "**** Información versión NPM"
npm -v

echo "Clonando repositorio"
rm -rf *.* consulService
git clone https://github.com/omondragon/consulService
cd consulService/app
sed -i "s/const HOST='192.168.100.3'/const HOST='$LOCAL_IP'/g" index.js

npm install consul express
node index.js $(shuf -i 3000-3999 -n 1) &
# node index.js 3000 &
# node index.js 3001 &

echo "Consul servidor iniciado en segundo plano "
