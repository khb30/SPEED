using Pkg, Revise

Pkg.activate(".")

using SPEED
using Distributions
using Distributed
using DataFrames

## Inference simulation

results_inference = pmap(x -> distribution_simulation(x, 10000, Uniform(0.1, 2), 0.0007, Gamma(8,1/2), Gamma(144/16,16/12), 14.0, 1)
, 1:100)

results_inference = DataFrame(map(idx -> getindex.(results_inference, idx), eachindex(results[1])), [:R, :infected_cases])

## Detection simulation

results_detection = pmap(x -> detection_simulation(x, 10000, 1.2, 0.0007, Gamma(8,1/2), Gamma(144/16,16/12), 30.0, 1)
, 1:100)

## Single simulation

simulation(500000, 1.8, 0.0007, Gamma(8,1/2), Gamma(144/16,16/12), 14.0)