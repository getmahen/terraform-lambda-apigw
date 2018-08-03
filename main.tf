resource "aws_lambda_function" "playground" {
  function_name = "ServerlessPlayground"

  # Make sure the following S3 bucket exists and the lambda package is uploaded
  s3_bucket = "${data.aws_s3_bucket_object.playground_pkg.bucket}"
  s3_key    = "${data.aws_s3_bucket_object.playground_pkg.key}"
  s3_object_version = "${data.aws_s3_bucket_object.playground_pkg.version_id}"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs6.10"

  # This is a very basic IAM role for this lambda. 
  role = "${aws_iam_role.playground_lambda_exec.arn}"

  # Environmental vars used by Lambda can be defined here
  environment {
    variables = {
      LOG_LEVEL   = "DEBUG"
    }
  }
}

# IAM role which dictates what other AWS services the Lambda function
# may access. This is a very basic Policy. To define a policy with more specific permissions
# create a new policy using "aws_iam_policy" resource and attach it to this IAM role using "aws_iam_role_policy_attachment"
resource "aws_iam_role" "playground_lambda_exec" {
  name = "playground_lambda_exec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# SNIPPET below illustrates how a custom POLICY can be created and attached to IAM role that is used by Lambda
# resource "aws_iam_role_policy_attachment" "vpc_policy_attachment" {
#   policy_arn = "${aws_iam_policy.playground_vpc_policy.arn}"
#   role       = "${aws_iam_role.playground_lambda_exec.name}"
# }

# resource "aws_iam_policy" "playground_vpc_policy" {
#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:CreateNetworkInterface",
#                 "ec2:DescribeNetworkInterfaces",
#                 "ec2:DeleteNetworkInterface"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.playground.id}"
  parent_id   = "${aws_api_gateway_rest_api.playground.root_resource_id}"
  path_part   = "playgroundhello"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.playground.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.playground.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.playground.invoke_arn}"
}

# resource "aws_api_gateway_method" "proxy_root" {
#   rest_api_id   = "${aws_api_gateway_rest_api.playground.id}"
#   resource_id   = "${aws_api_gateway_rest_api.playground.root_resource_id}"
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_root" {
#   rest_api_id = "${aws_api_gateway_rest_api.playground.id}"
#   resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
#   http_method = "${aws_api_gateway_method.proxy_root.http_method}"

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = "${aws_lambda_function.playground.invoke_arn}"
# }

resource "aws_api_gateway_deployment" "playground" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    //"aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.playground.id}"
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.playground.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.playground.execution_arn}/*/*"
}