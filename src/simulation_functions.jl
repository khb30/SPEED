function initialise_population(N::Int, p::Float64, T_R::Distributions.Gamma, T_D::Distributions.Gamma, tau::Float64, T_max::Float64)
    
    population = DataFrame(
        recovery_time = fill(NaN, N),
        diagnosis_time = fill(NaN, N),
        infection_time = fill(NaN, N),
        infected_by = fill(0, N)
    )

    population.recovery_time[N] = rand(T_R)
    population.infection_time[N] = 0
    population.infected_by[N] = N + 1

    individual_test_probability = 1 - exp(-tau * population.recovery_time[N])
    initial_test = rand(Bernoulli(individual_test_probability))

    if initial_test == 1
        population.diagnosis_time[N] = rand(T_D)
        max_time = minimum(filter(!isnan, population.diagnosis_time)) + T_max
    else
        population.diagnosis_time[N] = Inf
        max_time = Inf
    end

    return population, max_time

end

function simulation(N::Int, Rt::Float64, p::Float64, T_R::Distributions.Gamma, T_D::Distributions.Gamma, T_max:: Float64, P:: Union{Float64, Nothing}, d_max::Int, sigma:: Union{Float64, Nothing})
    tau = diagnosis_rate(T_R, p)
    population, max_time = initialise_population(N, p, T_R, T_D, tau, T_max)

    S = collect(1:(N-1))
    E = Int[]
    I = Int[N]
    R = Int[]
    D = Int[]

    states = DataFrame(
        time = 0.0,
        s = length(S),
        e = length(E),
        i = length(I),
        r = length(R),
        d = length(D)
    )

    state = last(states)

    while state.time < max_time && ( (state.e + state.i) > 0 || (state.r > 0 && minimum(population.diagnosis_time[R]) != Inf) ) && state.d <= d_max

        if sigma === nothing
            rate_total = state.s * (Rt / mean(T_R)) * (state.i / N)
        else
            rateStoE = state.s * (Rt / mean(T_R)) * (state.i / N)
            rateEtoI = state.e * sigma
            rate_total = rateStoE + rateEtoI
        end

        if rate_total == 0
            delta = Inf
        else 
            delta = rand(Exponential(1/rate_total))
        end
        
        E_I = state.time + delta

        if state.i > 0
            E_D = minimum(population[I, :].diagnosis_time)
            E_R = minimum(population[I, :].recovery_time)
        else
            E_D = Inf
            E_R = Inf
        end

        if state.r > 0
            E_RD = minimum(population[R, :].diagnosis_time)
        else
            E_RD = Inf
        end

        # E_D = state.i > 0 ? minimum(population[I, :].diagnosis_time) : Inf
        # E_R = state.i > 0 ? minimum(population[I, :].recovery_time) : Inf
        # E_RD = state.r > 0 ? minimum(population[R, :].diagnosis_time) : Inf

        if E_I == minimum([E_I, E_D, E_R, E_RD])

            if sigma === nothing
                
                newly_infected = rand(S)
                population.infected_by[newly_infected] = rand(I)
                deleteat!(S, findfirst(==(newly_infected), S))
                push!(I, newly_infected)

                population.recovery_time[newly_infected] = E_I + rand(T_R)
                population.infection_time[newly_infected] = E_I
                
                individual_test_probability = 1 - exp(-tau * (population.recovery_time[newly_infected] - E_I))
                test = rand(Bernoulli(individual_test_probability))
            
                if test == 1
                    population.diagnosis_time[newly_infected] = E_I + rand(T_D)
                    max_time = minimum(filter(!isnan, population.diagnosis_time)) + T_max
                else
                    population.diagnosis_time[newly_infected] = Inf
                end
      
                push!(states, [E_I, length(S), length(E), length(I), length(R), length(D)])
            
            else

                if rand(Bernoulli(rateStoE / rate_total))
                    newly_exposed = rand(S)
                    deleteat!(S, findfirst(==(newly_exposed), S))
                    push!(E, newly_exposed)

                    push!(states, [E_I, length(S), length(E), length(I), length(R), length(D)])
                else
                    newly_infected = rand(E)
                    population.infected_by[newly_infected] = rand(I)
                    deleteat!(E, findfirst(==(newly_infected), E))
                    push!(I, newly_infected)
    
                    population.recovery_time[newly_infected] = E_I + rand(T_R)
                    population.infection_time[newly_infected] = E_I
                    
                    individual_test_probability = 1 - exp(-tau * (population.recovery_time[newly_infected] - E_I))
                
                    if rand(Bernoulli(individual_test_probability))
                        population.diagnosis_time[newly_infected] = E_I + rand(T_D)
                        max_time = minimum(filter(!isnan, population.diagnosis_time)) + T_max
                    else
                        population.diagnosis_time[newly_infected] = Inf
                    end
          
                    push!(states, [E_I, length(S), length(E), length(I), length(R), length(D)])
                end

            end

        elseif E_D == minimum([E_I, E_D, E_R, E_RD])
            
            newly_diagnosed = findfirst(x -> x == E_D, population.diagnosis_time)
            deleteat!(I, findfirst(==(newly_diagnosed), I))

            push!(D, newly_diagnosed)

            push!(states, [E_D, length(S), length(E), length(I), length(R), length(D)])

        elseif E_R == minimum([E_I, E_D, E_R, E_RD])

            newly_recovered = findfirst(x -> x == E_R, population.recovery_time)
            deleteat!(I, findfirst(==(newly_recovered), I))

            push!(R, newly_recovered)

            push!(states, [E_R, length(S), length(E), length(I), length(R), length(D)])

        else

            now_diagnosed = findfirst(x -> x == E_RD, population.diagnosis_time)
            deleteat!(R, findfirst(==(now_diagnosed), R))

            push!(D, now_diagnosed)

            push!(states, [E_RD, length(S), length(E), length(I), length(R), length(D)])

        end

        state = last(states)

        if P != nothing && state.d == 1

            tau_hs = diagnosis_rate(T_R, P)

            non_tested_individual = intersect(findall(x -> x == Inf, population.diagnosis_time), I)

            if !isempty(non_tested_individual)

                infection_times = population[non_tested_individual, :].infection_time
                recovery_times = population[non_tested_individual, :].recovery_time
    
                adjusted_test_probabilities = 1 .- exp.(-(recovery_times .- state.time) .* (tau_hs - tau))

                new_tests_population = rand.(Bernoulli.(adjusted_test_probabilities))

                for i in 1:length(non_tested_individual)
                    if new_tests_population[i]
                        population.diagnosis_time[non_tested_individual[i]] = rand(T_D) + state.time
                    end
                end

                max_time = minimum(filter(!isnan, population.diagnosis_time)) + T_max

            end

            tau = tau_hs

        end
    
    end

    return states, population, max_time, population[D, :].diagnosis_time
end
