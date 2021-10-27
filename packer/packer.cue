package packer

_nick: {
	"21.10": "Impish"
	"21.04": "Hippo"
	"al2":   "Amazon Linux 2"
}

_ins_type: {
	aarch64: "m6g.medium"
	x86:     "c5.xlarge"
}

// https://cloud-images.ubuntu.com/locator/ec2/
// https://cloud-images.ubuntu.com/locator/daily/
_ami: x86: {
   // eu-west-1 ebs 21.04 amd
   "21.04": "ami-0d7626a9c2ceab1ac"
   "21.10": "ami-0b12a0e706f8120b0"
   "al2": "ami-0bb3fad3c0286ebd5"
}

_ami: aarch64: {
	//  eu-west-1 ebs 21.10 arm
	"21.10": "ami-02c2b9510e386bd70"
}

_config: {
	arch:       "aarch64" | "x86" @tag(arch)
	os_flavour: "al2" | "ubuntu"  @tag(osf)
	os_ver:     string            @tag(osv)

	instance_type: _ins_type[arch]
	ubuntu: {
		prefix:     "u"
		ssh_user: "ubuntu"
	}

	al2: {
		prefix:     ""
		ssh_user: "ec2-user"
	}

	ami:  _ami[arch][os_ver]
	name: _config[os_flavour].prefix + os_ver + "-" + arch
}

variables: {
	aws_region:    "eu-west-1"
	name:          _config.name
	src_ami_id:    _config.ami
	instance_type: _config.instance_type
}

builders: [{
	type: "amazon-ebs"
	ami_block_device_mappings: [{
		delete_on_termination: true
		device_name:           "/dev/sda1"
		encrypted:             false
		volume_size:           16
		volume_type:           "gp2"
	}]
	ami_description:         "AMI of {{ user `name` }}"
	ami_name:                "{{ user `name` }}"
	ami_virtualization_type: "hvm"
	ena_support:             true
	encrypt_boot:            "false"
	force_deregister:        true
	force_delete_snapshot:   true
	iam_instance_profile:    "PackerBuilderRole"
	instance_type:           "{{ user `instance_type` }}"
	name:                    "{{ user `name` }}-{{isotime}}"
	region:                  "{{ user `aws_region` }}"
	source_ami:              "{{ user `src_ami_id` }}"
	ssh_username:            _config[_config.os_flavour].ssh_user
	tags: {
		Name:       _nick[_config.os_ver] + "-" + _config.arch
		OS_Version: _config.os_ver
	}
	user_data_file: "/tmp/userdata.yml"
}]

provisioners: [
{
	type: "shell"
	inline: [
		"""
			while [ ! -f /var/lib/cloud/instance/boot-finished ]
			  do echo 'Waiting for cloud-init...'
			sleep 10
			done			
			""",
		"echo finished, rebooting",
		"sudo reboot",
	]
	expect_disconnect: true
}, 	
{
	type:        "file"
	source:      "provision/files"
	destination: "/tmp/"
}, {
	type: "shell"
	environment_vars: ["DEBIAN_FRONTEND=noninteractive", "AWS_DEFAULT_REGION=\(variables.aws_region)" ],
	// {{.Vars}} expands to environment variable list. {{.Path}} expands to the path of the script
	// containing inline commands. Since sudo in ec2 is without a password we do not have
	// to pipe the password into it.
	execute_command:   "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
	script:            "provision/base.sh"
},

]
