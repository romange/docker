#!/bin/bash
set -e

function print_usage_exit() {
	echo "Usage: $0 -i <dev> [-n]"
	echo "-n  Dry run"
    echo "Note: It is advised to run 'sudo systemctl disable irqbalance.service' before running this script"
	exit 1
}


if [ $# -lt 2 ] ; then
	print_usage_exit
fi

while [[ ($# -ge 1) ]]; do
	case $1 in
	"-i")
		shift
		[[ $# -ge 1 ]] || print_usage_exit
		DEVICE="$1"		
		;;
    "-n")
	    DRY=1		
		;;
	*)
		print_usage_exit
		;;
	esac    
    shift
done

if [[ "$EUID" -ne 0 && $DRY != "1" ]]; then 
  echo "Please run as root"
  exit 1
fi

IRQS=($(grep "${DEVICE}-Tx-Rx" /proc/interrupts | cut -d: -f1 | tr -d "[:blank:]"))
ONLINE=($(cat /sys/devices/system/cpu/online | awk '/-/{for (i=$1; i<=$2; i++) printf "%s%s",i,ORS;next} 1' RS=, FS=-))
NUM_ONLINE=${#ONLINE[@]}
NUM_IRQS=${#IRQS[@]}

if [ $NUM_ONLINE -lt $NUM_IRQS ] ; then
	echo "There are less online cpus than network IRQs: $NUM_ONLINE vs $NUM_IRQS"
	exit 1
fi

echo "Assigning ${NUM_ONLINE} cpus to $NUM_IRQS network irqs"

# This should prioritize handling IRQs on CPUs from different cores.
# For example, when we have 36 vCPUs, I expect that 0-17 will belong to different cores
# and 18-35 will be their hyper-threaded siblings.
#
# If we have enough dedicated cores to cover all the network IRQs we won't need to use the same
# core for multiple IRQs. And if number of IRQs is higher than we will assign some vCPUs from 
# the upper half range.

i=0;
for i in "${!IRQS[@]}"; do 
  irq=${IRQS[$i]}
  new_cpu=${ONLINE[$i]}
  irq_list_path="/proc/irq/$irq/smp_affinity_list"
  curr=$(cat $irq_list_path)
  echo "Setting CPU $new_cpu to handle irq $irq, currently set ${curr}"
  if [ "$DRY" != "1" ]; then
    echo "$new_cpu" > "$irq_list_path"
  fi
done
