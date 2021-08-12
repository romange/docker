package userdata

package_update:  true
package_upgrade: true
groups: [
	"docker",
]

users: [
	"default",
	{
		name:   "dev"
		sudo:   "ALL=(ALL) NOPASSWD:ALL"
		groups: "adm, docker"
		shell:  "/bin/bash"
		ssh_authorized_keys: [
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCano8DfBycFQ/2OxszQ5ZcnHpodZBI4XGsiTK+bw/RxGgwdL6V3/de53DtjZNCltCgfU04fw8wntm2SJ/PyguN8O/Kj3qSD9QHI04CBe2P/Z+GOfJUo528ocIj2PnWHTV8zs5XZVyRaZCLyNfiKTnkfY7EoTHDVJcuUE669v9Q5FDPVBp0eUMGW49Gw1i1z6dXJiv7pfEGyKCcMuGiPnCB357XsuxKzEThazlpuRFWXPqilBOI8hSapMd8G0TXU9xhGNNzpBdrZg6DFvoXX2JChD9sOBNumS0FMv0BEBbZeonMzMHoVU6mMfFMnYAEMJesCXK12vcr440HM8sXC20H",
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBbvZmZwPKrvMmckFCSxvV+qt3Z3DXAwP64N8oGPiop1KBKnPj+ORLL2/k9zmPiVfceP4o9iomys/l4oVCq+pgtTXmPPBwgeFi/BpGeBR7D2cPWJaEuwe/4mG58YYlwSp12RjddE7a4TxgRsxlQ3z51GOvGyBJc5ig+7HroTN4Sw9ncBhNmmi59YJRA1KDEwTe5sJsfzfkrqjeGN4xhIZSRkpSHCPW2n9MC1eB4sNJUJl2xvn8JaR8oCLHsHd81f+ybbMURC0g3mRWakpuRnzdHGwzZWCfUwJGhW1BAp2I6zc7Sb+u0GyR+AnARIkTuUMirHsIeFW1a1hd54aSyn7nWHlQ6rKwX7withcDsQ/nhCkpTqcsbeEzHWe2XzH1UEnN351yIAyrI0sbgYI/tq1/dVEvP6796fdNTcd1RhvXc0OXlqdRU0iRxVKlVPdG/8YV6wfHiEOhW7kGtbh3OldS5Pox7sxN8mn+XmNRCW+5uuR62mbgPEO/YfZBl9/FPB8=",
		]
	}]

_common_pkgs: ["acl", "automake", "autoconf", "binutils", "bison",
	"bzip2", "ca-certificates", "ccache", "cmake-curses-gui", "chrony", "cloc", "curl",
	"dkms", "doxygen", "htop", "iftop",
	"iotop", "flex", "gdb", "graphviz", "git", "golang", "libelf-dev",
	"libtool", "make", "mlocate", "ninja-build", "npm", "parallel", "podman", "runc", "sysstat",
	"tcptrace",
	"python3-pip", "python3-setuptools", "vim", "unzip", "wget", "zip"]

_ubuntu_pkgs: [ "ack-grep", "cmake", "g++", "libunwind-dev", "linux-tools-generic", "libbz2-dev",
	"docker.io", "libhugetlbfs-bin", "libncurses5-dev", "libssl-dev", "libxml2-dev",
	"vim-gui-common", "net-tools"]

// Remove systems that add overhead to syscalls.
runcmd: [ "systemctl disable apparmor", "modprobe -rv ip_tables" ]

// _os_version is limited to either al2 or ubuntu. 
// the value is injected via '-t osf=...' argument
_os_flavour: "al2" | "ubuntu" @tag(osf)

if _os_flavour == "ubuntu" {
	packages: _common_pkgs + _ubuntu_pkgs
}
