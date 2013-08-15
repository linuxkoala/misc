#!/bin/bash
DBGFS=/sys/kernel/debug/color_page_alloc

init_system()
{
    if !(mount | grep cgroup); then
	mount -t cgroup xxx /sys/fs/cgroup
    fi
    echo 13 > $DBGFS/dram_bank_shift
    echo 3 > $DBGFS/dram_bank_bits

    echo 16 > $DBGFS/dram_rank_shift
    echo 2 > $DBGFS/dram_rank_bits
}


set_system_cgroup()
{
    mkdir /sys/fs/cgroup/system
    pushd /sys/fs/cgroup/system
    echo 0 > cpuset.cpus
    echo 0 > cpuset.mems
    for t in `cat /sys/fs/cgroup/tasks`; do
        echo $t > tasks
    done 2> /dev/null
    popd
}

set_corun_samebank_cgroup()
{
    mkdir /sys/fs/cgroup/corun_samebank
    pushd /sys/fs/cgroup/corun_samebank

    echo 0-3    > cpuset.cpus
    echo 0      > cpuset.mems
    echo 0-7    > phdusa.colors
    echo 1      > phdusa.dram_rank
    echo 0      > phdusa.dram_bank
    popd
}

set_corun_diffbank_cgroup()
{
    mkdir /sys/fs/cgroup/corun_diffbank
    pushd /sys/fs/cgroup/corun_diffbank

    echo 0-3    > cpuset.cpus
    echo 0      > cpuset.mems
    echo 0-7    > phdusa.colors
    echo 1      > phdusa.dram_rank
    echo 1-7    > phdusa.dram_bank
    popd
}

set_core_cgroup()
{
    core=$1
    banks=$2
    for t in `cat /sys/fs/cgroup/core${core}/tasks`; do
        echo $t > /sys/fs/cgroup/tasks
    done
    direc="/sys/fs/cgroup/core${core}"
    [ -d "$direc" ] && rmdir $direc
    mkdir /sys/fs/cgroup/core${core}
    pushd /sys/fs/cgroup/core${core}
    echo $core > cpuset.cpus
    echo 0 > cpuset.mems

    echo 0-7    > phdusa.colors
    echo 1      > phdusa.dram_rank
    echo $banks > phdusa.dram_bank
    popd
}

init_system

set_core_cgroup 0 "0"
set_core_cgroup 1 "2"
set_core_cgroup 2 "4"
set_core_cgroup 3 "6"

set_corun_samebank_cgroup
set_corun_diffbank_cgroup

echo "128" > /sys/kernel/debug/tracing/buffer_size_kb

echo 3 > $DBGFS/debug_level
for f in $DBGFS/dram_*; do 
    echo $f `cat $f`
done
