resource "aws_ecr_repository" "docker_repository" {
  name = "${var.project}"
}

resource "aws_ecr_lifecycle_policy" "docker_repository_lifecycly" {
  repository = "${aws_ecr_repository.docker_repository.name}"

  policy = jsonencode({
    rules = [
        {
            rulePriority = 1,
            description = "Keep only the latest 5 images",
            selection = {
                tagStatus = "tagged",
                tagPrefixList = ["v"],
                countType = "imageCountMoreThan",
                countNumber = 5
            },
            action = {
                type = "expire"
            }
        }
    ]
})
}