module SPEED

using Distributions
using DataFrames

export diagnosis_rate
include("tau_function.jl")

export initialise_population
export simulation
include("simulation_functions.jl")

export detection_simulation
export distribution_simulation
include("application_functions.jl")

end
