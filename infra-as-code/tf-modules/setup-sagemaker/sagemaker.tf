# Fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch subnets that are public (have a route to an Internet Gateway)
data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  # Iterate over subnets and match only those with a route to an Internet Gateway
  filter {
    name   = "mapPublicIpOnLaunch"
    values = ["true"]
  }
}

resource "aws_sagemaker_domain" "sagemaker_domain" {
  domain_name = "learn-mlops-sagemaker-domain"
  auth_mode   = "IAM"
  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
  default_space_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default_public_subnets.ids
}

resource "aws_sagemaker_user_profile" "sagemaker_user" {
  domain_id         = aws_sagemaker_domain.sagemaker_domain.id
  user_profile_name = "mlops-learner"
  user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn
  }
}

# Create a SageMaker JupyterLabSpace
resource "aws_sagemaker_space" "jupyterlab_space" {
  domain_id  = aws_sagemaker_domain.sagemaker_domain.id
  space_name = "mlops-learner-space"
}