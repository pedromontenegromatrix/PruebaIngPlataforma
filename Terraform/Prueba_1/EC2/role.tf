# IAM Role for New Relic Integration
resource "aws_iam_role" "this" {
  count = local.borrado || var.new_relic_account == "" ? 0 : 1
  name  = "role-${local.env}-${var.project}-RoleNewRelicIntegrationRole-01"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          AWS = "arn:aws:iam::${var.new_relic_account}:root" # Replace with New Relic account ID
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
  tags = {
    Name = "role-${local.env}-${var.project}-RoleNewRelicIntegrationRole-01"
  }
}

# IAM Policy for ReadOnlyAccess
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "ec2:Get*",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:Get*",
      "s3:Get*",
      "s3:List*",
      "iam:GetRole",
      "iam:List*",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::*:role/*NewRelic*"]
  }
}

resource "aws_iam_policy" "this" {
  count       = local.borrado || var.new_relic_account == "" ? 0 : 1
  name        = "policy-${local.env}-${var.project}-RoleNewRelicIntegrationRole-01"
  description = "Policy for New Relic to access AWS resources"
  policy      = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = local.borrado || var.new_relic_account == "" ? 0 : 1
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}
