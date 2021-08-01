package packer

_nick: {
	"21.04": "Hippo"
	"20.10": "Groovy"
	"al2":   "Amazon Linux 2"
}

_ins_type: {
	aarch64: "m6g.medium"
	x86:     "m5.xlarge"
}


_ami: x86: {
	// eu-west-1 ebs 21.04 amd
	"21.04": "ami-0d7626a9c2ceab1ac"
	"20.10": "ami-0b66abce162eb2baf"

	"al2":   "ami-0bb3fad3c0286ebd5"
}

_ami: aarch64: {
	//  eu-west-1 ebs 21.04 arm
	"21.04": "ami-0622951acf3501c7a"
}

_config: {
	arch:       "aarch64" | "x86" @tag(arch)
	os_flavour: "al2" | "ubuntu"  @tag(osf)
	os_ver:     string            @tag(osv)

	instance_type: _ins_type[arch]
	ubuntu: {
		pref:     "u"
		ssh_user: "ubuntu"
	}

	al2: {
		pref:     ""
		ssh_user: "ec2-user"
	}

	ami:  _ami[arch][os_ver]
	name: _config[os_flavour].pref + os_ver + "-" + arch
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

provisioners: [{
	type:        "file"
	source:      "provision/files"
	destination: "/tmp/"
}, {
	type: "shell"
	inline: [
		"""
			while [ ! -f /var/lib/cloud/instance/boot-finished ]
			  do echo 'Waiting for cloud-init...'
			sleep 10
			done

			""",
		"echo finished",
	]
}, {
	type: "shell"

	// {{.Vars}} expands to environment variable list. {{.Path}} expands to the path of the script
	// containing inline commands. Since sudo in ec2 is without a password we do not have
	// to pipe the password into it.
	execute_command: "{{ .Vars }} sudo -E /bin/bash '{{ .Path }}'"
	script:          "provision/base.sh"
}]
