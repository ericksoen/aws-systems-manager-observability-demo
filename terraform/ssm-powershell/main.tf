resource "aws_ssm_document" "lazy_module_import" {
  name = "demo-lazy-import"
  document_type = "Command"
  content = file("${path.module}/lazy-module-import.yml")
  document_format = "YAML"
}

resource "aws_ssm_document" "explicit_module_import" {
  name = "demo-explicit-import"
  document_type = "Command"
  content = file("${path.module}/explicit-module-import.yml")
  document_format = "YAML"
}

resource "aws_ssm_document" "require_module_import" {
  name = "demo-require-import"
  document_type = "Command"
  content = file("${path.module}/require-module-import.yml")
  document_format = "YAML"
}