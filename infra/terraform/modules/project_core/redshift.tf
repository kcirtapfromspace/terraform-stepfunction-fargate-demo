resource "aws_security_group" "redshift_serverless" {
  # checkov:skip=CKV2_AWS_5: False positive, security group is used below in redshift serverless module
  name = "allow_incoming"
  # name = "${local.prefix}-redshift-serverless"
  description = "Allow incoming traffic to redshift"
  # description = "${local.prefix}-redshift-serverless"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "redshift_cluster_port" {
  security_group_id = aws_security_group.redshift_serverless.id

  description = "Connections to redshift cluster port"
  from_port   = 5439
  to_port     = 5439
  ip_protocol = "tcp"
  cidr_ipv4   = "10.0.0.0/8"
}

resource "aws_vpc_security_group_ingress_rule" "glue_to_redshift" {
  # checkov:skip=CKV_AWS_25: Does not apply to self-referencing group
  # checkov:skip=CKV_AWS_24: Does not apply to self-referencing group
  # checkov:skip=CKV_AWS_260: Does not apply to self-referencing group
  security_group_id = aws_security_group.redshift_serverless.id

  description                  = "For glue to be able to connect"
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.redshift_serverless.id
}

resource "aws_vpc_security_group_egress_rule" "redshift_to_data_sources_ipv4" {
  security_group_id = aws_security_group.redshift_serverless.id

  description = "Connections to redshift cluster port"
  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "redshift_to_data_sources_ipv6" {
  security_group_id = aws_security_group.redshift_serverless.id

  description = "Connections to redshift cluster port"
  from_port   = "-1"
  to_port     = "-1"
  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

resource "aws_iam_role" "redshift_serverless" {
  name = "${local.prefix}-redshift-serverless"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "redshift_serverless" {
  name        = "${local.prefix}-redshift-serverless"
  path        = "/"
  description = "IAM policy for ${local.prefix}-redshift-serverless"

  policy = templatefile(
    "${path.module}/policy/s3_policy.json.tpl",
    {
      data_bucket    = module.data_bucket.bucket_id
      raw_bucket     = module.raw_bucket.bucket_id
      staging_bucket = module.staging_bucket.bucket_id
      curated_bucket = module.curated_bucket.bucket_id
      #   partition                 = data.aws_partition.current.partition
      #   region                    = data.aws_region.current.name
      #   account_id                = data.aws_caller_identity.current.account_id,
      #   secretsmanager_secret_arn = aws_secretsmanager_secret.sfmc.arn,
      #   log_group_id              = resource.aws_cloudwatch_log_group.sfmc.id,
      #   dead_letter_queue         = aws_sqs_queue.lambda_deadletter.arn
      #   kms_key_arn               = aws_kms_key.project.arn
    }
  )
}

resource "aws_iam_role_policy_attachment" "redshift_serverless" {
  role       = aws_iam_role.redshift_serverless.name
  policy_arn = aws_iam_policy.redshift_serverless.arn
}

resource "aws_secretsmanager_secret" "redshift_jdbc_creds" {
  # checkov:skip=CKV2_AWS_57: Rotating credentials causes issues for integrations
  name       = "${local.prefix}-redshift-jdbc-credentials"
  kms_key_id = aws_kms_key.project_key.id
}

resource "aws_secretsmanager_secret_version" "redshift_jdbc_creds" {
  secret_id     = aws_secretsmanager_secret.redshift_jdbc_creds.id
  secret_string = jsonencode(var.redshift_jdbc_creds_seed)

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}

################################
## Redshift Serverless - Main ##
################################

# Create the Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "serverless" {
  namespace_name      = var.redshift_serverless_namespace_name
  db_name             = var.redshift_serverless_database_name
  admin_username      = var.redshift_serverless_admin_username
  admin_user_password = var.redshift_serverless_admin_password
  iam_roles           = [aws_iam_role.redshift-serverless-role.arn]

  tags = {
    Name        = var.redshift_serverless_namespace_name
    Environment = var.app_environment
  }
}

################################################

# Create the Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "serverless" {
  depends_on = [aws_redshiftserverless_namespace.serverless]

  namespace_name = aws_redshiftserverless_namespace.serverless.id
  workgroup_name = var.redshift_serverless_workgroup_name
  base_capacity  = var.redshift_serverless_base_capacity
  
  security_group_ids = [ aws_security_group.redshift-serverless-security-group.id ]
  subnet_ids         = [ 
    aws_subnet.redshift-serverless-subnet-az1.id,
    aws_subnet.redshift-serverless-subnet-az2.id,
    aws_subnet.redshift-serverless-subnet-az3.id,
  ]
  publicly_accessible = var.redshift_serverless_publicly_accessible
  
  tags = {
    Name        = var.redshift_serverless_workgroup_name
    Environment = var.app_environment
  }
}