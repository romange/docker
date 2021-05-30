#!/bin/bash
set -e

export AWS_DEFAULT_REGION=eu-west-1

echo "********* Install Basics Server Environment ********"

export DEBIAN_FRONTEND=noninteractive

PATH=$PATH:/usr/local/bin
pip3 install git-remote-codecommit boto3 

npm install -g aws-cdk

# Dispatch files that were put by packer.yaml into /tmp/files
tf=/tmp/files
mv $tf/huge_pages.service /etc/systemd/system/
mv $tf/changedns.sh /var/lib/cloud/scripts/per-boot/
mv $tf/huge_multiuser.service /etc/systemd/system/
mv $tf/local.conf /etc/sysctl.d/

systemctl enable huge_multiuser.service

echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* soft core unlimited" >> /etc/security/limits.conf

# Disable mitigations
sed -i 's/\(^GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 mitigations=off"/' /etc/default/grub
update-grub

ARTPATH=$(aws ssm get-parameters --names artifactdir  --query "Parameters[*].{Value:Value}" --output text)

if [[ $(uname -i) == "aarch64" ]]; then
  arch='aarch64'
else
  arch='x86'
fi

aws s3 cp $ARTPATH/bin/$arch/s5cmd /usr/local/bin/ && chmod a+x /usr/local/bin/*
s5cmd cp -n $ARTPATH/bin/$arch/* /usr/local/bin/
chmod a+x /usr/local/bin/*

echo "********* User Setup ********"
root_gist=https://gist.githubusercontent.com/romange/43114d544e2981cfe4a6/raw

cd /home/dev

for i in .gitconfig .bash_aliases .bashrc .tmux.conf supress.txt
 do
  wget -qN $root_gist/$i
done

mkdir -p .aws projects bin /root/.aws .tmux
cp $tf/aws_config .aws/config
cp $tf/aws_config /root/.aws/config
cp $tf/reset .tmux/
mv $tf/disableht.sh bin/
mv $tf/update_kernel.py bin/
mv $tf/mount_disks.py bin/
mv $tf/.bash_profile .

install_cmake() {
  CMAKE_VER=$1
  wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}.tar.gz
  tar xfz cmake-*gz && cd cmake-*
  ./bootstrap && gmake -j4 cmake cpack ctest
  gmake install
  cd - && rm -rf cmake-*
}

. /etc/os-release

if [[ $VERSION_ID == "2" ]]; then  # AL2 Linux
  install_cmake 3.18.2
  echo "alias ninja=ninja-build" >> .bash_aliases
fi

# Copy useful binaries (s3cmd is broken in 21.04 so for now we use s3-cli)
# s3cmd get $ARTPATH/bin/$arch/* bin/

# Finally, fix permissions.
chown -R dev:dev /home/dev


echo "********* Install BOOST ********"
BVER=1.76.0
BOOST=boost_${BVER//./_}   # replace all . with _

url="https://boostorg.jfrog.io/artifactory/main/release/${BVER}/source/$BOOST.tar.bz2"
echo "Downloading from $url"

mkdir -p /tmp/boost && pushd /tmp/boost
wget -nv ${url} -O $BOOST.tar.bz2
tar -xjf $BOOST.tar.bz2

booststap_arg="--prefix=/opt/${BOOST} --without-libraries=graph_parallel,graph,wave,test,mpi,python"
cd $BOOST
boostrap_cmd=`readlink -f bootstrap.sh`

echo "Running ${boostrap_cmd} ${booststap_arg}"
${boostrap_cmd} ${booststap_arg} || { cat bootstrap.log; return 1; }
b2_args=(define=BOOST_COROUTINES_NO_DEPRECATION_WARNING=1 link=shared variant=release debug-symbols=on
          threading=multi --without-test --without-math --without-log --without-locale --without-wave
          --without-regex --without-python -j4)

echo "Building targets with ${b2_args[@]}"
./b2 "${b2_args[@]}" cxxflags='-std=c++14 -Wno-deprecated-declarations'
./b2 install "${b2_args[@]}" -d0
ln -s /opt/${BOOST} /opt/boost

