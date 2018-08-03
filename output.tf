output "base_url" {
  value = "${aws_api_gateway_deployment.playground.invoke_url}"
}