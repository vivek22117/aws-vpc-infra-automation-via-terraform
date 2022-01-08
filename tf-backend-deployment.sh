#!/usr/bin/env bash


echo ====================================== Info =======================================================
echo "The below script will first create terraform backend resources that is S3 bucket and DynamoDB table.
They will be used in other modules to store the TF state file"
echo -e "===============================================================================================\n\n"


echo ============================== Reading AWS Default Profile ====================================
aws configure list --profile default >/dev/null 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -eq 256 ]; then
    echo "'default' aws profile does not exit, please create!"
    exit 1
else
  echo "'default' aws profile exists! Let's provision some AWS resources."
fi


echo -e "\n\n =========================== Fetch AWS Account Id ======================================"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text --profile default)
if [ -z $AWS_ACCOUNT_ID  ]; then
    echo "Credentials are not valid!"
    exit 1
else
  echo $AWS_ACCOUNT_ID
fi


echo -e "\n\n =========================== Choose Terraform Execution Type ==========================="

PS3="Select the terraform execution type: "

select EXEC_TYPE in apply destroy
do
    echo "You have decided to $EXEC_TYPE the AWS resources!"
    break
done


echo -e "\n\n ============================= Choose AWS Region ======================================="

PS3="Select aws region to deploy the resources: "

select AWS_REGION in us-east-1 us-east-2 eu-central-1 eu-west-1 eu-west-2 ap-south-1
do
    echo "You have selected $AWS_REGION to deploy the resources!"
    break
done


echo -e "\n\n ======================= Choose Environment To Deploy =================================="

PS3="Select environment to deploy: "

select ENV in qa test prod
do
    echo "You have selected $ENV environment for deployment"
    break
done


function terraform_backend_deployment() {
    echo -e "\n\n==================== Starting Terraform Backend Deployment ========================="

    cd aws-terraform-backend

    sed -i '/profile/s/^#//g' providers.tf

    terraform init -backend-config="config/$ENV-backend-config.config" \
    -backend-config="bucket=$ENV-tfstate-$AWS_ACCOUNT_ID-$AWS_REGION" -reconfigure

    terraform plan -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION"
    terraform apply -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve

    cd ..

    echo -e "========================= Completed ================================================ \n\n"
}


if [ $EXEC_TYPE == 'apply' ]; then

  terraform_backend_deployment

fi



if [ $EXEC_TYPE == 'destroy' ]; then
    echo -e "\n\n ========================= Destroying Backend TF Resources =============================="
    cd aws-jenkins-tf-backend

    terraform init

    terraform destroy -var-file="$ENV.tfvars" -var="default_region=$AWS_REGION" -var="environment=$ENV" -auto-approve
    cd ..

fi