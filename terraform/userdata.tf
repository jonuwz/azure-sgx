data "template_file" "script" {
  template = file("../cloudinit/script.sh")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = "${data.template_file.script.rendered}"
  }
}

