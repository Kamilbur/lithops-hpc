#!/bin/bash

singularity=apptainer

fail_code=0
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
        fail_code=1
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Use: rabbitmq_master_service.sh <start/stop> <rabbitmq.sif>"
    exit 1
fi

if [ "$1" = "start" ]; then
  # Start Singularity instance
  execute_command $singularity run \
            -B etc/rabbitmq:/opt/rabbitmq_server-3.13.1/etc/rabbitmq \
            -B var/lib/rabbitmq:/opt/rabbitmq_server-3.13.1/var/lib/rabbitmq \
            -B var/log/rabbitmq:/opt/rabbitmq_server-3.13.1/var/log \
            $2

  #Check final status 
  if [ $? -eq 0 ]; then
    echo "*******************************"
    echo "RabbitMQ ready to run Lithops."
    echo "*******************************"

    while :; do
      #echo "RabbitMQ ready to running ..."
      sleep 600
    done

  else
    echo "**********************************************"
    echo "ERROR: RabbitMQ failed with above error code. "
    echo "**********************************************" 
    exit 1 
  fi
elif [ "$1" = "stop" ]; then
  execute_command $singularity exec instance://rabbitmq  $rabbimq_path/rabbitmqctl shutdown
  execute_command $singularity instance stop rabbitmq
  echo "*******************************"
  echo "RabbitMQ close."
  echo "*******************************"
else
    echo "Invalid argument. Use 'start' to start the instance or 'stop' to finish the user and virtual host."
    exit 1
fi

