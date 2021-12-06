# Configure the AWS Provider
provider "aws" {
  region                  = var.region
  shared_credentials_file = "./credentials"
  profile                 = "default"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_id}-keypair"
  public_key = file("../generated/controller.pub_key")
}

resource "random_uuid" "deployment_uuid" {}

data "template_file" "cli_logging_config_template" {
  template = file("../etc/hpecp_cli_logging.conf")
  vars = {
    hpecp_cli_log_file = "../generated/hpecp_cli.log"
  }
}

resource "local_file" "cli_logging_config_file" {
  filename = "../generated/hpecp_cli_logging.conf"
  content  = data.template_file.cli_logging_config_template.rendered
}

data "template_file" "cloud_data" {
  template = file("../generated/cloud-init.yaml")
}

data "template_file" "user_data" {
  template = file("../generated/cloud-init-ad-server.yaml")
}

data "template_cloudinit_config" "ad_cloud_config" {
  gzip          = true
  base64_encode = true
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_data.rendered
  }
  part {
    filename     = "user.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}


### OUTPUTS
# output "project_dir" {
#   value = abspath(path.module)
# }
# output "additional_client_ip_list" {
#   value = var.additional_client_ip_list
# }
# output "user" {
#   value = var.user
# }
# output "project_id" {
#   value = var.project_id
# }
# output "epic_dl_url" {
#   value = var.epic_dl_url
# }