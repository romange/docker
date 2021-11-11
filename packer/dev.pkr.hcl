variable project {}
variable zone { default = "us-east1-b" }
variable region { default = "us-east1" }
variable aws_region { default = "eu-central-1" }

locals {
   service_account_id = "packer@${var.project}.iam.gserviceaccount.com"	
   wait_script = 	<<EOT
      while [ ! -f /var/lib/cloud/instance/boot-finished ]
				  do echo 'Waiting for cloud-init...'
				sleep 10
				done	
    EOT
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  userdata = templatefile("${path.root}/provision/userdata.pkrtpl.yml", {os = "ubuntu"})
}

source "amazon-ebs" "dev" {
  source_ami_filter {
    filters = {
       virtualization-type = "hvm"
       name = "ubuntu/images/hvm-ssd/ubuntu-impish-21.10-amd64-server-*"
       root-device-type = "ebs"
    }
    owners = ["679593333241"]
    most_recent = true
  }
  
  launch_block_device_mappings {
		delete_on_termination = true
		device_name =           "/dev/sda1"
		encrypted   =           false
		volume_size =           16
		volume_type =          "gp2"
	}

  ami_name = "udev-2110-${local.timestamp}"

  ami_virtualization_type = "hvm"
	ena_support =             true
	encrypt_boot =            false
	force_deregister =        true
	force_delete_snapshot=    true
  iam_instance_profile =    "PackerBuilderRole"
	instance_type =           "c5.xlarge"
	ami_description  =        "udev-2110-${local.timestamp}"
	region =                  var.aws_region
	ssh_username =            "ubuntu"
}

source "googlecompute" "dev" {
  project_id = var.project
  source_image_family = "ubuntu-2110"
  ssh_username = "ubuntu"
  preemptible  = true
  zone = var.zone
  
  image_storage_locations = [var.region]

  image_family = "ubuntu-dev"
  metadata = {
    user-data = local.userdata
  }  
  wrap_startup_script  = false
  image_name = "udev-2110-${local.timestamp}"
  service_account_email = local.service_account_id
}

build {
  sources = ["sources.googlecompute.dev", "sources.amazon-ebs.dev"]
  
  provisioner "shell" {
		inline = [
		  local.wait_script,
			"echo finished, rebooting",
			"sudo reboot",
		]
		expect_disconnect = true
  }

  provisioner "file" {
    source = "provision/files"
    destination = "/tmp/"
  }
}
