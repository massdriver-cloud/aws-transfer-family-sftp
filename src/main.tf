locals {
  file_system_id = split("/", var.aws_efs_file_system.data.infrastructure.arn)[1]
  region         = var.aws_efs_file_system.specs.aws.region

  // https://docs.aws.amazon.com/general/latest/gr/transfer-service.html
  regions_supporting_fips = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "ca-central-1",
    "us-gov-east-1",
    "us-gov-west-1"
  ]
  // FIPS only supported in certain regions
  transfer_security_policy = contains(local.regions_supporting_fips, local.region) ? "TransferSecurityPolicy-FIPS-2020-06" : "TransferSecurityPolicy-2022-03"
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_transfer_ssh_key" "main" {
  server_id = aws_transfer_server.main.id
  user_name = aws_transfer_user.main.user_name
  body      = tls_private_key.main.public_key_openssh
}

resource "aws_transfer_server" "main" {
  domain                 = "EFS"
  protocols              = ["SFTP"]
  endpoint_type          = "PUBLIC"
  host_key               = tls_private_key.main.private_key_pem
  identity_provider_type = "SERVICE_MANAGED"

  force_destroy = false

  logging_role         = data.aws_iam_role.logging.arn
  security_policy_name = local.transfer_security_policy
}

resource "aws_transfer_user" "main" {
  server_id = aws_transfer_server.main.id
  user_name = var.md_metadata.name_prefix
  role      = aws_iam_role.main.arn

  home_directory_type = "LOGICAL"

  home_directory_mappings {
    entry  = "/"
    target = "/${local.file_system_id}"
  }

  posix_profile {
    // Hardcoding to root for now. EFS and Transfer Family uses POSIX users, so unless
    // the customer has created directories w/ proper permissions only root will work
    uid = 0
    gid = 0
  }
}
