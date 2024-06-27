using Pkg, Revise

Pkg.activate(".")

using SPEED
using Distributions, Distributed, DataFrames, ArgParse, CSV

function main()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--days"
        help = "The maximum number of days for the simulation"
        arg_type = Float64
        default = 14.0
    end

    @add_arg_table s begin
        "--N"
        help = "Population size"
        arg_type = Int
        default = 500000
    end

    @add_arg_table s begin
        "--p"
        help = "Average population diagnosis probability"
        arg_type = Float64
        default = 0.0007
    end

    @add_arg_table s begin
        "--Rt"
        help = "R value"
        arg_type = Float64
        default = 1.2
    end

    @add_arg_table s begin
        "--P"
        help = "Heightened surveillance probability"
        arg_type = Union{Float64, Nothing}
        default = nothing
    end

    @add_arg_table s begin
        "--sigma"
        help = "Exposed compartment rate"
        arg_type = Union{Float64, Nothing}
        default = nothing
    end

    @add_arg_table s begin
        "--d_max"
        help = "Number of diagnosed cases"
        arg_type = Int
        default = 100
    end

    parsed_args = parse_args(s)

    T_max = parsed_args["days"]
    p = parsed_args["p"]
    N = parsed_args["N"]
    Rt = parsed_args["Rt"]
    P = parsed_args["P"]
    d_max = parsed_args["d_max"]
    sigma = parsed_args["sigma"]

    results = simulation(N, Rt, p, Gamma(8,1/2), Gamma(144/16,16/12), T_max, P, d_max, sigma)

    CSV.write("simulation_states_"*string(T_max)*"_Rt_"*string(Rt)*"_p_"*string(p)*"_N_"*string(N)*".csv", results[1], header = true)

    CSV.write("simulation_population_"*string(T_max)*"_Rt_"*string(Rt)*"_p_"*string(p)*"_N_"*string(N)*".csv", results[2], header = true)
end

main()