#!/bin/bash

echo "Descargando consul"
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Actualizando e instalando consul"
sudo apt-get update && sudo apt-get install -y consul

echo "Arrancar un agente de consul del server"
consul agent -server -bootstrap-expect=1 -node=consulServer -bind=192.168.100.4 \
    -data-dir=/var/consul -ui -client=0.0.0.0 -enable-script-checks=true \
    -retry-join=192.168.100.5 \
    -retry-join=192.168.100.6 \
    -config-dir=/etc/consul.d > /var/log/consul.log 2>&1 &

echo "Iniciando Consul servidor en segundo plano y redirigiendo logs"
