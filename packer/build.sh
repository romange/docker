#!/bin/bash
set -e

if ! hash packer &> /dev/null
then
    echo "packer could not be found, install from https://www.packer.io/downloads"
    exit 1
fi

if ! hash cue &> /dev/null
then
    echo "cue could not be found, install from https://github.com/cuelang/cue/releases"
    exit 1
fi


IS_ARM=0
AL2=0
UB10=0

for ((i=1;i <= $#;));do
  arg=${!i}
  case "$arg" in
    --arm)
    IS_ARM=1
    shift
  ;;
  --al?)
    AL2=1
    shift
  ;;
  --10)
    UB10=1
    shift
  ;;
  -*|--*=) # bypass flags
      i=$((i + 1))
  ;;
  esac
done

# For Ubuntu - check in http://cloud-images.ubuntu.com/locator/ec2/
# for eu-west-1 focal
# or go to http://cloud-images.ubuntu.com/query/focal/server/released.current.txt

if [[ $AL2 == 1 ]]; then
  osv=al2
  cue_vars=al2
else
  os_vars=ubuntu.yaml
  cue_vars=ubuntu
  if [[ $UB10 == 1 ]]; then
    osv="20.10"
  else
    osv="21.04"
  fi
fi

if [[ $IS_ARM == 1 ]]; then
  arch="aarch64"
else
  arch="x86"
fi

echo '#cloud-config' > /tmp/userdata.yml
cue export provision/userdata.cue -t osf=${cue_vars} --out yaml >> /tmp/userdata.yml

pfile=$(mktemp -u /tmp/packer.json.XXXX)
echo "Generating packer file $pfile"
cue export packer.cue -t osf=${cue_vars} -t arch=${arch} -t osv=${osv} --out=json > $pfile

echo "Validating ${pfile}"
packer validate $pfile
packer build $@ $pfile
