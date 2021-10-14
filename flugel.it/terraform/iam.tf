resource "aws_iam_role" "tags_reader" {
  name = "tags_reader_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "tags_reader" {
  name = "tags_reader_profile"
  role = aws_iam_role.tags_reader.name
}

resource "aws_iam_role_policy" "tags_reader" {
  name = "tags_reader_policy"
  role = aws_iam_role.tags_reader.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ec2:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}