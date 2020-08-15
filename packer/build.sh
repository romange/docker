#!/bin/bash
set -e

IS_ARM=0
while (( "$#" )); do
  case "$1" in
    --arm)
    IS_ARM=1
    shift
  ;;
  -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

# Check in http://cloud-images.ubuntu.com/locator/ec2/
# for eu-west-1 focal
#
if [ $IS_ARM -eq 1 ]; then
  export SRC_AMI_ID=ami-0fa1efaadcbd8f3de
  export INSTANCE_TYPE=m6g.medium
  export NAME=u20.04-aarch64
else
  export SRC_AMI_ID=ami-0f1d11c92a9467c07
  export INSTANCE_TYPE=t3.large
  export NAME=u20.04-x86
fi

python_cmd='import sys, yaml, json; json.dump(yaml.load(sys.stdin, Loader=yaml.FullLoader), \
sys.stdout, indent=4);print("\n")'

pfile=$(mktemp -u /tmp/packer.json.XXXX)
python3 -c "$python_cmd" < packer.yaml > $pfile

echo "Validating ${pfile}"
packer validate $pfile

packer build $pfile $@
