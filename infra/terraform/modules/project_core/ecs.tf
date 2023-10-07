resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.project
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/ecs/${var.project}"
  retention_in_days = 5
}

resource "aws_iam_role" "ecs_task_iam_role" {
  name        = "${var.project}-ecs-task-role"
  description = "Allow ECS tasks to access AWS resources"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid      = ""
        Effect   = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "${var.project}-ecs-policy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_ecs_task_role" {
  role       = aws_iam_role.ecs_task_iam_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

locals {
  container_definitions = templatefile("${path.module}/templates/ecs_dbt.tpl", {
    container_name     = "dbt"
    image              = aws_ecr_repository.docker_repository.repository_url
    image_version      = "latest"
    essential          = true
    db_host = aws_redshiftserverless_workgroup.serverless.endpoint[0].address
    db_port            = aws_redshiftserverless_workgroup.serverless.endpoint[0].port
    db_role            = var.db_role
    db_type            = var.db_type
    db_user            = var.master_username
    db_name            = var.database_name
    db_schema          = var.dbt_default_schema
    log_group          = "/aws/ecs/${var.project}"
    log_region         = var.aws_region
    log_stream_prefix  = "dbt"
  })
}

resource "aws_ecs_task_definition" "dbt_task_definition" {
    depends_on = [aws_redshiftserverless_namespace.serverless]
  family                   = "${var.project}-task-definition"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_iam_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = local.container_definitions
}
