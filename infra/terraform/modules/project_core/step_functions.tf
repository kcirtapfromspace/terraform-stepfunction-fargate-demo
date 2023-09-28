resource "aws_iam_role" "step_function_role" {
  name        = "${var.project}-step-function-role"
  description = "Allow Step Functions to access AWS resources"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = ""
        Effect    = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name   = "${var.project}-step-function-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "ecs:DescribeTasks",
          "ecs:RunTask",
          "ecs:StopTask"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["iam:PassRole"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = [
          "events:DescribeRule",
          "events:PutTargets",
          "events:PutRule"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy_step_function_role" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

locals {
  state_machine_with_deps = templatefile("${path.module}/templates/state_machine_with_deps.tpl", {
    ecs_cluster       = aws_ecs_cluster.ecs_cluster.arn
    ecs_task_name     = "${var.project}-task"
    subnet_1          = aws_subnet.public[0].id
    subnet_2          = aws_subnet.public[1].id
    subnet_3          = aws_subnet.public[2].id
    security_group_1  = aws_security_group.dbt_security_group.id
    retry_seconds     = 5
    retry_backoff     = 1.5
    retry_attempts    = 3
  })

  state_machine_with_no_deps = templatefile("${path.module}/templates/state_machine_with_no_deps.tpl", {
    ecs_cluster       = aws_ecs_cluster.ecs_cluster.arn
    ecs_task_name     = "${var.project}-task"
    subnet_1          = aws_subnet.public[0].id
    subnet_2          = aws_subnet.public[1].id
    subnet_3          = aws_subnet.public[2].id
    security_group_1  = aws_security_group.dbt_security_group.id
    retry_seconds     = 5
    retry_backoff     = 1.5
    retry_attempts    = 3
  })
}

resource "aws_sfn_state_machine" "sfn_state_machine_with_deps" {
  name     = "${var.project}-with-deps"
  role_arn = aws_iam_role.step_function_role.arn
  definition = local.state_machine_with_deps
}

resource "aws_sfn_state_machine" "sfn_state_machine_with_no_deps" {
  name     = "${var.project}-with-no-deps"
  role_arn = aws_iam_role.step_function_role.arn
  definition = local.state_machine_with_no_deps
}
