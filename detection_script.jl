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
        "--n"
        help = "Number of successes"
        arg_type = Int
        default = 100
    end

    @add_arg_table s begin
        "--hs"
        help = "Heightened surveillance average population diagnosis probability"
        arg_type = Any
        default = nothing
    end

    parsed_args = parse_args(s)

    T_max = parsed_args["days"]
    p = parsed_args["p"]
    N = parsed_args["N"]
    Rt = parsed_args["Rt"]
    n = parsed_args["n"]
    hs = parsed_args["hs"]

    results = pmap(x -> detection_simulation(x, N, Rt, p, Gamma(8,1/2), Gamma(144/16,16/12), T_max, hs)
, 1:n)

    if isnothing(hs)
        CSV.write("detection_days_"*string(T_max)*"_p_"*string(p)*"_N_"*string(N)*"_Rt_"*string(Rt)*"_number_"*string(n)*".csv", DataFrame(R = results), header = true)
    else
        CSV.write("detection_days_"*string(T_max)*"_p_"*string(p)*"_hs_"*string(hs)*"_N_"*string(N)*"_Rt_"*string(Rt)*"_number_"*string(n)*".csv", DataFrame(R = results), header = true)
    end
    
end

main()