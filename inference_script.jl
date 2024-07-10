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
        "--prior"
        help = "Prior distribution for inference"
        arg_type = String
        default = "Uniform"
    end

    @add_arg_table s begin
        "--n"
        help = "Number of successes"
        arg_type = Int
        default = 100
    end

    @add_arg_table s begin
        "--cases"
        help = "Number of detections within days"
        arg_type = Int
        default = 1
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
    hs = parsed_args["hs"]
    n = parsed_args["n"]
    cases = parsed_args["cases"]

    prior = parsed_args["prior"]
    if prior == "Uniform"
        distribution = Uniform(0.1,2)
    elseif prior == "H1N2"
        distribution = Gamma(3.14, 1/17.4)
    elseif prior == "Seasonal_influenza"
        distribution = Gamma(90.25, 1/70.51)
    end

    results = pmap(x -> distribution_simulation(x, N, distribution, p, Gamma(8,1/2), Gamma(144/16,16/12), T_max, cases, hs)
, 1:n)

    df = DataFrame(map(idx -> getindex.(results, idx), eachindex(results[1])), [:R, :infected_cases])

    if isnothing(hs)
        CSV.write("inference_days_"*string(T_max)*"_p_"*string(p)*"_N_"*string(N)*"_"*prior*"_number_"*string(n)*".csv", df, header = true)
    else
        CSV.write("inference_days_"*string(T_max)*"_p_"*string(p)*"_hs_"*string(hs)*"_N_"*string(N)*"_"*prior*"_number_"*string(n)*".csv", df, header = true)
    end
end

main()