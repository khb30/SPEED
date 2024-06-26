function diagnosis_rate(T_R::Distributions.Gamma, p::Float64)

    tau = rate(T_R) * ((1 - p)^
    (
      - scale(T_R)
    ) - 1)

    return tau

end