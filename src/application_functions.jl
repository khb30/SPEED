function distribution_simulation(x, N::Int, distribution::Union{Distributions.Gamma, Distributions.Uniform}, p::Float64, T_R::Distributions.Gamma, T_D::Distributions.Gamma, T_max:: Float64, cases:: Int64, P:: Union{Float64, Nothing} = nothing, d_max::Int = 1, sigma:: Union{Float64, Nothing} = nothing)
    fll = Bool(1)
    Rt = nothing

    total_infections = nothing

    while fll

        Rt = rand(distribution)
        simulation_results = simulation(N, Rt, p, T_R, T_D, T_max, P, d_max, sigma)
        
        if last(simulation_results[1]).d == cases
            fll = Bool(0)
        end

        total_infections = length(filter(!isnan, simulation_results[2].infection_time))

    end

    return Rt, total_infections

end

function detection_simulation(x, N::Int, Rt::Float64, p::Float64, T_R::Distributions.Gamma, T_D::Distributions.Gamma, T_max:: Float64, P:: Union{Float64, Nothing} = nothing, d_max::Int = 2, sigma:: Union{Float64, Nothing} = nothing)
    fll = Bool(1)
    second_detection = nothing
    simulation_results = nothing

    while fll

        simulation_results = simulation(N, Rt, p, T_R, T_D, T_max, P, d_max, sigma)
        
        if last(simulation_results[1]).d == 1
            fll = Bool(0)
            second_detection = Inf
        elseif last(simulation_results[1]).d > 1
            fll = Bool(0)
            
            diagnosis_times = filter(!isnan, simulation_results[2].diagnosis_time)
            sorted_diagnosis_times = sort(diagnosis_times)

            second_detection = sorted_diagnosis_times[2]-sorted_diagnosis_times[1]
        end

    end

    return second_detection

end