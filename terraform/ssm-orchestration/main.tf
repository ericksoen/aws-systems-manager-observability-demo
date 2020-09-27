resource "aws_ssm_document" "orchestrator" {
  name = "demo-orchestrator"

  document_type = "Command"

  content = file("${path.module}/orchestrator.yml")

  document_format = "YAML"
}

resource "aws_ssm_document" "open_trace" {
  name = "demo-open-trace"
  document_type = "Command"

  content = file("${path.module}/open-trace.yml")

  document_format = "YAML"
}

resource "aws_ssm_document" "first" {
  name = "demo-first"

  document_type   = "Command"
  content         = file("${path.module}/first-run-command.yaml")
  document_format = "YAML"
}

resource "aws_ssm_document" "second" {
  name = "demo-second"

  document_type   = "Command"
  content         = file("${path.module}/second-run-command.yaml")
  document_format = "YAML"
}

resource "aws_ssm_document" "close" {
  name = "demo-close"

  document_type   = "Command"
  content         = file("${path.module}/close-trace.yml")
  document_format = "YAML"
}