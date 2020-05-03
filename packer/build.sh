#!/bin/bash
set -e

python_cmd='import sys, yaml, json; json.dump(yaml.load(sys.stdin, Loader=yaml.FullLoader), \
sys.stdout, indent=4);print("\n")'

pfile=/tmp/packer.json
python3 -c "$python_cmd" < packer.yaml > $pfile
packer validate $pfile
packer build $pfile
