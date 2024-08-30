#!/bin/bash

# Cargar variables de entorno
if [ -f /tmp/envs ]; then
  source /tmp/envs
fi

echo "Descargando consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Actualizando e instalando consul"
sudo apt-get update && sudo apt-get install -y consul haproxy

echo "Arrancar un agente de consul del server"
consul agent -server -bootstrap-expect=1 -node=${CONSUL_SERVER_NAME} -bind=192.168.100.4 \
    -data-dir=/var/consul -ui -client=0.0.0.0 -enable-script-checks=true \
    -retry-join=192.168.100.5 \
    -retry-join=192.168.100.6 \
    -config-dir=/etc/consul.d > /var/log/consul.log 2>&1 &

# Creando página personalizada de error
cat <<EOL > "/etc/haproxy/errors/errorcito.html"
HTTP/1.0 503 Service Unavaible Gateway
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>Servicio caido</h1>
NO estoy listo :( ...
</body></html>
EOL

echo "Configurando haproxy para ver estatidísticas en el puerto 1396"
sudo systemctl enable haproxy
sudo cat <<EOL >> /etc/haproxy/haproxy.cfg
backend mymicroservice-backend
        balance roundrobin
        server-template mywebapp 1-8 _mymicroservice._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check
        errorfile 503 /etc/haproxy/errors/errorcito.html

frontend mymicroservice-frontend
        bind *:80
        default_backend mymicroservice-backend
        errorfile 503 /etc/haproxy/errors/errorcito.html

backend haproxy-backend
        balance roundrobin
        stats enable
        stats auth admin:admin
        stats uri /haproxy?stats

frontend haproxy-frontend
        bind *:1396
        default_backend haproxy-backend

resolvers consul
        nameserver consul 127.0.0.1:8600
        accepted_payload_size 8192
        hold valid 5s
EOL

sudo systemctl restart haproxy

echo <<EOF "
*****************************************************************************
***
*** Configuración del Servidor finalizada
***
*****************************************************************************"
EOF
