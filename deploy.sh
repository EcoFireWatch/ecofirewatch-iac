
echo "================== Deploying Network Stack ==============================="
aws cloudformation deploy --template-file Network.yaml --stack-name eco-fire-watch-network

echo "================== Starting Data Lake Stack =============================="
lakeSecurityGroupId=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=EcoFireWatch" "Name=tag:Name,Values=EcoFireWatchRDSSecGroup" --query 'SecurityGroups[0].GroupId' --output text)
echo "Data Lake Security Group ID: $lakeSecurityGroupId"

lakeSubnetIds=$(aws ec2 describe-subnets --filters "Name=tag:Project,Values=EcoFireWatch" "Name=tag:Access,Values=Private" --query Subnets[*].SubnetId --output text | tr '\t' ',')
echo "Data Lake Subnet IDs: $lakeSubnetIds"

echo "================== Deploying Data Lake Stack ============================="
aws cloudformation deploy \
    --template-file DataLake.yaml \
    --stack-name eco-fire-watch-datalake \
    --parameter-overrides \
        ClientSubnetList="$lakeSubnetIds" \
        ClientSecurityGroupId=$lakeSecurityGroupId

echo "================== Starting Lambdas Stack ================================"
aws s3 cp ./resources/lambdas s3://eco-fire-watch-raw-v2/resources/ --recursive

echo "================== Deploy Lambdas Stack =================================="

aws cloudformation deploy --template-file Lambda.yaml --stack-name eco-fire-watch-serverless

echo "================== Deploy Iot Processing Stack ==========================="

aws cloudformation deploy --template-file IotEntrypointApi.yaml --stack-name eco-fire-watch-iot-entrypoint

echo "================== Starting Grafana Stack ================================"
grafanaSecurityGroupId=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=EcoFireWatch" "Name=tag:Name,Values=EcoFireWatchGrafanaSecGroup" --query 'SecurityGroups[0].GroupId' --output text)
echo "Grafana Security Group ID: $grafanaSecurityGroupId"

grafanaSubnetId=$(aws ec2 describe-subnets --filters "Name=tag:Project,Values=EcoFireWatch" "Name=tag:Access,Values=Public" --query 'Subnets[0].SubnetId' --output text)
echo "Grafana Subnet ID: $grafanaSubnetId"

keyHasCreated=$(aws ec2 describe-key-pairs --key-names grafana-key-pair --query 'KeyPairs[0].KeyName' --output text 2>/dev/null)
echo "Grafana Key Pair: $keyHasCreated"
if [ "$keyHasCreated" != "grafana-key-pair" ]; then
    ssh-keygen -t rsa -b 4096 -f grafana-key.pem -N ""
fi

echo "================== Deploy Grafana Stack =================================="
aws cloudformation deploy \
    --template-file Grafana.yaml \
    --stack-name eco-fire-watch-grafana \
    --parameter-overrides \
        SubnetId="$grafanaSubnetId" \
        GrafanaSecurityGroup="$grafanaSecurityGroupId" \
        GrafanaKey="$(cat grafana-key.pub)"
