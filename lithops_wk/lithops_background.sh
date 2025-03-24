#!/bin/bash

singularity=apptainer

# Function to execute a command in the background and wait for it to finish
execute_command() {
    echo "Executing command: $@"
    "$@" &
    local pid=$!
    wait "$pid"
    if [ $? -eq 0 ]; then
        echo "Command '$@' completed successfully."
    else
        echo "Command '$@' failed with exit code $?."
        exit 1
    fi
}

if [ "$#" -ne 3 ]; then
    echo "Use: $0 <start/stop> <RMQ_ip> <singularity-plantilla342.sif>"
    exit 1
fi

# Check if LITHOPS_CONFIG_FILE environment variable exists
if [ -z "$LITHOPS_CONFIG_FILE" ]; then
    echo "LITHOPS_CONFIG_FILE environment variable does not exist"
    exit 1
fi


storage_bucket=$(grep -v "^#" $LITHOPS_CONFIG_FILE | grep "storage_bucket" | cut -f2 -d":" | cut -f1 -d"#")
storage_bucket=$(echo "$storage_bucket" | xargs)

if [ -d "$storage_bucket" ]; then
    echo "Using storage: $storage_bucket"
else
    echo "Storage $storage_bucket directory does not exist."
    exit 1
fi

if [ "$1" = "start" ]; then
  # Start singularity-plantilla instance
  mkdir -p $SCRATCH/lithops_tmp
  sleep 45
  execute_command $singularity run -B $storage_bucket:$storage_bucket \
  -B $LITHOPS_HPC_HOME:$LITHOPS_HPC_HOME -B $SCRATCH/lithops_tmp:/scratch --env AMQP_URL=amqp://admin1234:1234@$2:5672/testadmin $3
  sleep 30

elif [ "$1" = "stop" ]; then
#  execute_command $singularity instance stop lithops-worker
  echo "*******************************"
  echo "lithops-worker close."
  echo "*******************************"
else
    echo "Invalid argument. Use 'start' to start the workers or 'stop' to finish the workers."
    exit 1
fi
