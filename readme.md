## Rede
```bash
aws cloudformation deploy --template-file Network.yaml --stack-name eco-fire-watch-network
```

## Iot
```bash
aws cloudformation deploy --template-file IotEntrypointApi.yaml --stack-name eco-fire-watch-iot-entrypoint
```

## Banco de Dados
```bash
aws cloudformation deploy --template-file DataLake.yaml --stack-name eco-fire-watch-datalake
```


## Grafana Installation
```bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo mkdir -p /etc/apt/keyrings/
wget -q -O- https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update -y
sudo apt-get install grafana -y
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl status grafana-server
```