## AWS Transfer Family SFTP

AWS Transfer Family SFTP allows you to securely transfer files over SFTP, FTPS, and FTP directly in and out of Amazon S3 or Amazon EFS.

### Design Decisions

1. **User Authentication**: The design utilizes AWS Managed Authentication for user identities, simplifying the management of access credentials.
2. **Key Management**: A secure TLS private key is generated and managed for server authentication, ensuring secure communication channels.
3. **Logging**: The setup includes a logging role pre-configured to deliver logs to AWS CloudWatch, aiding in monitoring and troubleshooting.
4. **High Availability**: The `endpoint_type` is set to "PUBLIC", providing a highly available endpoint accessible over the internet.
5. **Security Policies**: Depending on AWS regions, different security policies are applied to maintain high encryption standards (FIPS compliance where applicable).
6. **Storage Integration**: Integration with Amazon EFS is set up, providing scalable storage for files transferred via SFTP.

### Runbook

#### Issue: Unable to Connect to SFTP Server

If you are experiencing issues connecting to the SFTP server, follow these steps:

To verify the server's endpoint and status:

```sh
aws transfer describe-server --server-id <server-id>
```

Check the output for `ServerState` and `Endpoint` details.

#### Issue: Permission Denied When Uploading Files

If you encounter a "Permission Denied" error when trying to upload files:

1. Confirm the user and permissions:

```sh
aws transfer describe-user --server-id <server-id> --user-name <user-name>
```

Confirm the `HomeDirectoryMappings` and `PosixProfile` values.

2. Check EFS directory permissions:

SSH into an instance with access to the EFS file system and navigate to the directory:

```sh
sudo su
cd /path/to/efs/mounted
ls -lah
```

Make sure the directory permissions allow writing by the SFTP user.

#### Issue: SFTP Service Not Starting

If the SFTP service is not starting:

Check the AWS Transfer Family service logs:

```sh
aws logs describe-log-streams --log-group-name /aws/transfer/<server-id>
aws logs get-log-events --log-group-name /aws/transfer/<server-id> --log-stream-name <log-stream-name>
```

Look for error messages that can indicate misconfigurations or other issues.

#### Issue: Key Mismatch or Authentication Failure

If users cannot authenticate and you suspect a key mismatch:

Ensure the correct public key is associated with the user in AWS Transfer Family:

```sh
aws transfer list-users --server-id <server-id>
aws transfer describe-ssh-keys --server-id <server-id> --user-name <user-name>
```

Compare the public key listed with the one on the client side.

#### Issue: Debugging EFS Issues

If there are issues related to EFS, such as mounting or access problems:

Check the EFS file system state:

```sh
aws efs describe-file-systems --file-system-id <file-system-id>
```

Ensure the EFS file system is in a "available" state. If mounting issues persist, verify the mount targets:

```sh
aws efs describe-mount-targets --file-system-id <file-system-id>
```

These troubleshooting steps should help identify and resolve common issues encountered when using AWS Transfer Family SFTP with your EFS integration.

