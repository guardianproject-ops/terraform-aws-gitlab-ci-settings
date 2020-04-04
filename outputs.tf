output "gitlab_ci_username" {
  value = aws_iam_user.gitlab_ci.name
}

output "gitlab_ci_arn" {
  value = aws_iam_user.gitlab_ci.arn
}

output "gitlab_ci_access_key" {
  value = aws_iam_access_key.gitlab_ci.id
}

output "gitlab_ci_secret_access_key" {
  value = aws_iam_access_key.gitlab_ci.secret
}

output "ci_subnet_id" {
  value = aws_subnet.ci_subnet.id
}

output "ci_vpc_id" {
  value = aws_vpc.ci_vpc.id
}
output "policy_json" {
  value = data.aws_iam_policy_document.gitlab_ci.json
}
