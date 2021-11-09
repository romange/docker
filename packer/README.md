## Initial configuration

1. Update your region in packer.cue
2. Update AMI id according to the region
3. Make sure that .aws/config region is consistent with the region you chose.
4. Set `artifactdir` variable to the bucket that hosts `/bin` directory.
   ```
     aws ssm put-parameter --name "artifactdir" --value "bucketname" --type String
   ```
5. Create IAM role `PackerBuilderRole`  with the following policy:
   ```
   {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CopyImage",
                "ec2:CreateImage",
                "ec2:CreateKeypair",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSnapshot",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:DeleteKeyPair",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSnapshot",
                "ec2:DeleteVolume",
                "ec2:DeregisterImage",
                "ec2:DescribeImageAttribute",
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeRegions",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSnapshots",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "ec2:GetPasswordData",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifySnapshotAttribute",
                "ec2:RegisterImage",
                "ec2:RunInstances",
                "ec2:StopInstances",
                "ec2:TerminateInstances",
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*",
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
   }
   ```

### Using terraform

```
cd tf
cue export builder.tf.cue --out json -o builder.tf.json -t bucket=...
terrraform init
terrraform apply
```
