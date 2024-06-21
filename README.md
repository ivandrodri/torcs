# TORCS Simulator and Custom Environments

## Overview

This repository includes the TORCS race simulator (version 1.3.7) with minimal modifications, as well as customized gym environments compatible with Gymnasium.

## Contents

- **TORCS Simulator**: Located in src/torcs, this is version 1.3.7 of the TORCS race simulator with a few minimal changes.

- **Gym Torcs Environment**: Located in src/gymnasium_torcs, this version includes changes to make it compatible with Gymnasium.

- **Custom TORCS Environment**: Located in src/torcs_lidar_environment, this environment uses 19 lidar rays for observations and the steer angle as the action.

## Installation

To set up the project, follow these steps:

**1. Clone the repository:**
```bash
git clone https://github.com/yourusername/torcs_simulator.git
cd torcs_simulator
```

**2. Create conda environment:**
```conda
conda create -n torcs_gym python==3.11
```

**3. Install poetry:**
```pip
pip install poetry
```

**4. Install dependencies:**
```bash
python poetry_install.py
```

**5.Build and install TORCS:**
```bash
bash install_torcs.sh
```

## Running with Docker

To run this project using Docker, make sure you have Docker installed on your system. If not, you can download and install Docker from [Docker's official website](https://www.docker.com/get-started).

1. **Build the Docker image**:
   
   **Note**: If you already build torcs outside docker please clean the torcs project as it is a bit dirty, and it will interfere with torcs building in docker: 
   ```
   cd src/torcs
   rm -rf BUILD
   make clean
   ``` 

   Navigate to the root directory of the project where `Dockerfile` is located, then run:

   ```bash
   docker build -t torcs-simulator .
   ```

   and run docker using: 

   ```shell
   docker run -it --rm --privileged --net=host \
      --env DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix \
      torcs-simulator bash
   ```

   In case you experience some issues with the rendering when using docker
   make sure to add the docker user to xhost. So run on your local machine: 

   ```shell
   xhost +SI:localuser:docker_user
   ```


## Usage

```python
from gymnasium_torcs.gym_torcs import TorcsEnv

env = TorcsEnv()
observation = env.reset()
done = False

while not done:
    action = env.action_space.sample()  # Replace with your action
    observation, reward, done, truncations, info = env.step(action)

env.end()
```

## Contributing

Feel free to submit issues or pull requests if you have suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

