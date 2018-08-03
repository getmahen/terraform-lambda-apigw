## This Terraform repo is used to create a NodeJs Lambda function with API Gateway integration. Following resources are created:
 - TF state in this repo is saved in S3
 - Lambda function (NodeJs runtime)
 - Simple/basic IAM role for the lambda with basic policy
 - API gateway and its integration with Lambda

## Lambda code
- Simple NodeJs code for the lambda is in ./lambdaCode folder.
- Zip the code by executing the following command
  `cd lambdaCode/`
  `zip ../playground.zip main.js`
- Upload the zipped package to S3 bucket. Make sure to create S3 bucket first
  `aws s3 cp playground.zip s3://<bucketname>/playground.zip --profile <profile name>`

## Steps to execute
 - First exec `terraform init -backend-config=./backendConfigs/dev`
    This command with initialize TF and sets up the S3 backed to save the TF state. **MAKE SURE** to supply access keys in ./backendConfigs/dev file
 - Then execute `terraform plan`
 - Then execute `terraform apply` if plan output is satisfactory


