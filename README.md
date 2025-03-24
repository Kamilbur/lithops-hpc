# Lithops-HPC

## Installation
#### 1. Obtain the Lithops-HPC code: clone the sources and set the ENV variables
```bash
git clone https://github.com/neardata-eu/lithops-hpc.git
cd lithops-hpc
export LITHOPS_HPC_HOME=$(pwd)
```
#### 2. Install dependencies in a mamba environment
```bash
conda install -n base -c conda-forge mamba
mamba env update -n lhops --file $LITHOPS_HPC_HOME/lhops.yml
conda activate lhops

# to deactivate or remove if necessary
conda deactivate
conda remove --name lhops --all
```

#### 3. Build Singularity Images
```bash
cd $LITHOPS_HPC_HOME/sif/
sudo singularity build rabbitmq.sif rabbitmq.def
lithops runtime build -b singularity singularity-plantilla342
```
#### 3.1 Optional: Build a custom runtime from a definition file
```bash
lithops runtime build -b singularity singularity-plantilla342 -f singularity-template.def --fakeroot --force
```


## Usage 
```bash
cd lithops-hpc
export LITHOPS_HPC_HOME=$(pwd)
export PLGRID_PARTITION=<PARTITION>
export PLGRID_ACCOUNT=<ACCOUNT>
export LITHOPS_WORKER_SIF=$LITHOPS_HPC_HOME/sif/<worker.sif>

export PATH=$LITHOPS_HPC_HOME/scripts:$PATH
export LITHOPS_HPC_STORAGE=$LITHOPS_HPC_HOME/lithops_wk/storage
export LITHOPS_CONFIG_FILE=$LITHOPS_HPC_STORAGE/lithops_config
export LITHOPS_HPC_JOB_TIME_LIMIT=1:00:00
export LITHOPS_HPC_MEM_PER_CPU=5G

export SINGULARITY_PATH=/usr/bin/apptainer

conda activate lhops
lithops_hpc.sh <num_cpus> <num_nodes>
```
num_lithops_workers=num_cpus x num_nodes

## Run Examples
```bash
cd $LITHOPS_HPC_HOME/examples/sleep 
mkdir plots

export LITHOPS_HPC_STORAGE=$LITHOPS_HPC_HOME/lithops_wk/storage
export LITHOPS_CONFIG_FILE=$LITHOPS_HPC_STORAGE/lithops_config
conda activate lhops

python sleep.py
```

## Setup Lithops storage directory
By default, $LITHOPS_HPC_HOME/lithops_wk directory is used for storage. 
To specify a different storage location, set the LITHOPS_HPC_STORAGE environment variable:
```bash
export LITHOPS_HPC_STORAGE=<custom_dir>

# to set storage access control lists
setfacl --recursive  -m g::rwx $LITHOPS_HPC_STORAGE
```


## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[Apache V2.0]( http://www.apache.org/licenses/LICENSE-2.0)
