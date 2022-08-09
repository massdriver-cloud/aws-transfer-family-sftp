resource "massdriver_artifact" "sftp" {
  field                = "sftp"
  provider_resource_id = aws_transfer_server.main.arn
  name                 = "AWS Transfer Family SFTP Server: ${aws_transfer_server.main.arn}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn = aws_transfer_server.main.arn
        }
        authentication = {
          hostname    = aws_transfer_server.main.endpoint
          user        = aws_transfer_user.main.user_name
          public_key  = tls_private_key.main.public_key_pem
          private_key = tls_private_key.main.private_key_pem
        }
      }
      specs = {
        aws = {
          region = local.region
        }
        cryptography = {
          algorithm = tls_private_key.main.algorithm
          key_size  = tls_private_key.main.rsa_bits
        }
      }
    }
  )
}
