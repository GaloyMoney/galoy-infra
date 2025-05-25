data "terraform_remote_state" "inception" {
  backend = "s3"
  config = {
    bucket         = "test-flow-xxx-tf-state"
    key            = "test-flow-xxx/inception.tfstate"
    region         = "us-east-1"
    dynamodb_table = "test-flow-xxx-tf-lock"
  }
}

module "platform" {
  source = "../../../modules/platform/aws"

  name_prefix          = var.name_prefix
  aws_region          = var.aws_region
  eks_cluster_role_arn = var.eks_cluster_role_arn
  eks_nodes_role_arn   = var.eks_nodes_role_arn
  inception_state_backend = var.inception_state_backend

  vpc_id          = data.terraform_remote_state.inception.outputs.vpc_id
  nat_gateway_ids = data.terraform_remote_state.inception.outputs.nat_gateway_ids
  dmz_subnet_ids  = data.terraform_remote_state.inception.outputs.dmz_subnet_ids
} 