from gymnasium_torcs.gym_torcs import TorcsEnv

env = TorcsEnv()
observation = env.reset()
done = False

while not done:
    action = env.action_space.sample()  # Replace with your action
    observation, reward, done, truncations, info = env.step(action)

env.end()