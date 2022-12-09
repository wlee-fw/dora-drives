#!/bin/bash

if [ -z $DORA_DEP_HOME ] ; then
    DORA_DEP_HOME=$(pwd)
    echo "WARNING: \$DORA_DEP_HOME is not set; Setting it to ${DORA_DEP_HOME}"
else
    echo "INFO: \$DORA_DEP_HOME is set to ${DORA_DEP_HOME}"
fi

# Install opencv separately because pip3 install doesn't install all libraries
# opencv requires.

#### . activate base
#### conda create -n dora3.7 python=3.8
#### conda activate dora3.7
#### pip install -r install_requirements.txt



###############################################################################
# Get models & code bases we depend on
###############################################################################
mkdir $DORA_DEP_HOME/dependencies
cd $DORA_DEP_HOME/dependencies/

#################### Download the code bases ####################
echo "[x] Compiling the planners..."
###### Build the FrenetOptimalTrajectory Planner ######
echo "[x] Compiling the Frenet Optimal Trajectory planner..."
cd $DORA_DEP_HOME/dependencies/
git clone https://github.com/erdos-project/frenet_optimal_trajectory_planner.git
cd frenet_optimal_trajectory_planner/
bash build.sh

###### Build the RRT* Planner ######
echo "[x] Compiling the RRT* planner..."
cd $DORA_DEP_HOME/dependencies/
git clone https://github.com/erdos-project/rrt_star_planner.git
cd rrt_star_planner/
bash build.sh

###### Build the Hybrid A* Planner ######
echo "[x] Compiling the Hybrid A* planner..."
cd $DORA_DEP_HOME/dependencies/
git clone https://github.com/erdos-project/hybrid_astar_planner.git
cd hybrid_astar_planner/
bash build.sh

###### Clone the Prediction Repository #####
echo "[x] Cloning the prediction code..."
cd $DORA_DEP_HOME/pylot/prediction/
git clone https://github.com/erdos-project/prediction.git

. activate base
conda activate dora3.7 

###### Download the Carla simulator ######
echo "[x] Downloading the CARLA_Leaderboard_20 simulator..."
cd $DORA_DEP_HOME/dependencies/
if [ "$1" != 'challenge' ] && [ ! -d "CARLA_Leaderboard_20" ]; then
    mkdir CARLA_0.9.13
    cd CARLA_0.9.13
    wget https://carla-releases.s3.eu-west-3.amazonaws.com/Linux/Leaderboard/CARLA_Leaderboard_20.tar.gz
    tar -xvf CARLA_Leaderboard_20.tar.gz
    rm CARLA_Leaderboard_20.tar.gz
    pip install CARLA_0.9.13/PythonAPI/carla/dist/carla-0.9.13-cp37-cp37m-manylinux_2_27_x86_64.whl
fi


###### Install Carla Leaderboard ######
echo "[x] Installing Carla leaderboard..."
cd $DORA_DEP_HOME/dependencies/
git clone -b leaderboard-2.0 --single-branch https://github.com/carla-simulator/leaderboard.git
python3 -m pip install -r leaderboard/requirements.txt

git clone -b leaderboard-2.0 --single-branch https://github.com/carla-simulator/scenario_runner.git
python3 -m pip install -r scenario_runner/requirements.txt