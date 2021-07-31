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
  os_vars=al2.yaml
  cue_vars=al2
  pref_conf="al2"
else
  os_vars=ubuntu.yaml
  cue_vars=ubuntu
  if [[ $UB10 == 1 ]]; then
    pref_conf="u20.10"
  else
    pref_conf="u21.04"
  fi
fi

if [[ $IS_ARM == 1 ]]; then
  config="${pref_conf}-arm.yaml"
else
  config="${pref_conf}-x86.yaml"
fi

echo '#cloud-config' > /tmp/userdata.yml
cue export provision/userdata.cue -t osv=${cue_vars} --out yaml >> /tmp/userdata.yml

pfile=$(mktemp -u /tmp/packer.json.XXXX)
echo "Generating packer file $pfile"
ytt -f packer.yaml -f ${config} -f ${os_vars} -o json > $pfile

echo "Validating ${pfile}"
packer validate $pfile
packer build $@ $pfile
