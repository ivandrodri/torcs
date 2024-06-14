import numpy as np

from gymnasium_torcs.gym_torcs import TorcsEnv
import gymnasium as gym


class TorcsLidarEnv(TorcsEnv):
    def __init__(self, vision=False, throttle=False, gear_change=False, render_mode = None):

        super(TorcsLidarEnv, self).__init__(
            vision=vision,
            throttle=throttle,
            gear_change=gear_change,
            render_mode=render_mode
        )
        self.observation_space = gym.spaces.Box(low=-1.0, high=1.0, shape=(19,), dtype=np.float32)

    @staticmethod
    def _preprocess_observation(observation):
        preprocessed_observation = np.array([lidar for lidar in observation["track"]])
        return preprocessed_observation

    def reset(self, **kwargs):
        # Reset the environment and preprocess the initial observation
        observation, info = super().reset(**kwargs)
        self._raw_observation = observation
        preprocessed_observation = self._preprocess_observation(observation)
        return preprocessed_observation, info

    def step(self, action):
        # Take a step in the environment and preprocess the observation
        action = np.clip(action, -0.1, 0.1)
        observation, reward, done, truncations, info = super().step(action)
        self._raw_observation = observation
        preprocessed_observation = self._preprocess_observation(observation)
        return preprocessed_observation, reward, done, truncations, info

    @property
    def raw_observation(self):
        return self._raw_observation

    def number_steps(self):
        return self.time_step
