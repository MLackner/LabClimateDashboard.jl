using Pkg

Pkg.activate(joinpath(@__DIR__, ".."))

using LabClimateDashboard
using Dates
using DelimitedFiles

include(joinpath(@__DIR__, "utils.jl"))

logpath = generate_logdata()
LabClimateDashboard.run(logpath)