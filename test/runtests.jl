using LabClimateDashboard
using Test
using Dates
using DelimitedFiles
using HTTP
using Revise

include(joinpath(@__DIR__, "utils.jl"))

@testset "LabClimateDashboard.jl" begin
    logdata_path = generate_logdata()

    @async LabClimateDashboard.run(logdata_path; port=8050)

    r = HTTP.request("GET", "http://127.0.0.1:8050"; verbose=2, connect_timeout=60)
    # test if we receive http status code 200 (Ok)
    @test r.status == 200

    println("Press ENTER to terminate!")
    readline()
end
