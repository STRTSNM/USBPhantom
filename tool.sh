#!/bin/bash

echo "USB backup tool v1.0"

backup(){

    local dev=$1
    local img=$2
    echo "Partition data"
    lsblk -ln -b -o NAME,SIZE,FSTYPE $dev | tail -n +2 | tee /tmp/partition_data
    local line=$(wc -l </tmp/partition_data)
    echo "Partitions:$line">ptable
    while read -r name size fstype; do
        fstype=${fstype:-unknown}
        echo "NAME=$name FSTYPE=$fstype SIZE=$size" >> ptable
        echo "→ $name | $size bytes | $fstype"
    done < /tmp/partition_data
    echo "==> $line Partitions found"
    for i in $(seq 2 $(($line+1)))
    do
        local linestr=$(head -n $i ptable | tail -n 1)
        echo "==>Processsing $linestr"
        local tmp=${linestr#* }
        local size=${tmp% *}
        local fstype=${tmp#* }
        echo FSTYPE $fstype SIZE $size
        echo "Executing sudo dd if="$dev$(($i-2))" bs=4M status=progress conv=sparse,fsync  > backup_p$(($i-2)).img"
    done

    
}

backup /dev/sda backup.img
