#!/bin/bash
set -e

if ! hash packer &> /dev/null
then
    echo "packer could not be found, install from https://www.packer.io/downloads"
    exit 1
fi

if ! hash ytt &> /dev/null
then
    echo "ytt could not be found, install from https://github.com/k14s/ytt/releases"
    exit 1
fi

IS_ARM=0
AL2=0
while (( "$#" )); do
  case "$1" in
    --arm)
    IS_ARM=1
    shift
  ;;
  --al?)
    AL2=1
    shift
  ;;
  -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
  esac
done

# For Ubuntu - check in http://cloud-images.ubuntu.com/locator/ec2/
# for eu-west-1 focal
# or go to http://cloud-images.ubuntu.com/query/focal/server/released.current.txt
if [[ $IS_ARM == 1 && $AL2 == 1 ]]; then
  config=al2-arm.yaml
elif [[ $IS_ARM == 1 && $AL2 == 0 ]]; then
  config=u20.04-arm.yaml
elif [[ $IS_ARM == 0 && $AL2 == 1 ]]; then
  config=al2-x86.yaml
elif [[ $IS_ARM == 0 && $AL2 == 0 ]]; then
  config=u20.04-x86.yaml
fi


pfile=$(mktemp -u /tmp/packer.json.XXXX)
ytt -f ${config} -f packer.yaml -o json > $pfile
echo "Validating ${pfile}"
packer validate $pfile
packer build $pfile $@
