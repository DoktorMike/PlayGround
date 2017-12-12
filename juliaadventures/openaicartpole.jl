using OpenAIGym
using Reinforce

env = GymEnv("CartPole-v0")
#env = GymEnv("BipedalWalker-v2")
ep = Episode(env, RandomPolicy())

for i=1:20
    for (s, a, r, s′) in ep
        # do something special?
        OpenAIGym.render(env)
    end
    R = ep.total_reward
    N = ep.niter
    info("Episode $i finished after $N steps. Total reward: $R")
end
