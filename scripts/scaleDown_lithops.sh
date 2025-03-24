#!/bin/bash

current_dir=$(pwd)

if [ -z "$PLGRID_ACCOUNT" ]; then
    echo "export PLGRID_ACCOUNT environment variable with appropriate user-account"
    cd $current_dir
    exit 1
fi

if [ -z "$PLGRID_PARTITION" ]; then
    echo "export PLGRID_PARTITION environment variable with appropriate partition"
    cd $current_dir
    exit 1
fi

# Check if LITHOPS_HPC_HOME environment variable exists
if [ -z "$LITHOPS_HPC_HOME" ]; then
    echo "LITHOPS_HPC_HOME environment variable does not exist"
    cd $current_dir
    exit 1
fi

# Check if LITHOPS_CONFIG_FILE environment variable exists
if [ -z "$LITHOPS_CONFIG_FILE" ]; then
    echo "LITHOPS_CONFIG_FILE environment variable does not exist"
    cd $current_dir
    exit 1
fi

# Check if input arguments are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <workers_pid>"
    cd $current_dir
    exit 1
fi

#1. Removing workers 
job_id=$1

# Check if the job exists
if squeue -j $job_id | grep -q $job_id; then
    echo "Job $job_id exists. Attempting to cancel..."
else
    echo "Job $job_id does not exist."
    cd $current_dir
    exit 1
fi

total_workers_remove=$(squeue -A $PLGRID_ACCOUNT -o "%A %D %c" | grep "^$job_id" |  awk '{print $2*$3}')
scancel $job_id
scancel_exit_code=$?

# Check if scancel command was successful
if [ $scancel_exit_code -ne 0 ]; then
   echo "Failed to execute scancel for job $job_id."
   cd $current_dir
   exit 1
fi

#Wait a few seconds to allow for status update
#sleep 20

# Check job status using sacct
#job_status=$(sacct -j $job_id --format=JobID,State | grep $job_id | awk '{print $2}')
#if [ "$job_status" == "CANCELLED" ]; then
#     echo "Job $job_id was canceled successfully."
#else
#     echo "Job $job_id is still in progress or failed to cancel."
#     cd $current_dir
#     exit 1
#fi

#2 Updating config file
current_workers=$(grep -v "#" $LITHOPS_CONFIG_FILE | grep "worker_processes" | cut -f2 -d":" | xargs)
new_workers=$(echo "$current_workers-$total_workers_remove" | bc)
sed -i "s/worker_processes: $current_workers/worker_processes: $new_workers/" "$LITHOPS_CONFIG_FILE"
echo "Removing $total_workers_remove, updating total workers:$new_workers"
echo "DONE"
cd $current_dir
