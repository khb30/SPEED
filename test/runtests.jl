using SPEED
using Test
using Distributions

@testset "SPEED.jl" begin
    # Write your tests here.
    T_R = Gamma(8,1/2)
    p = 0.0

    @test SPEED.diagnosis_rate(T_R, p) == 0.0
end
