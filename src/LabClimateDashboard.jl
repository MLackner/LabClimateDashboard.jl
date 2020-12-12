# using Pkg
# Pkg.activate(joinpath(@__DIR__, ".."))
# Pkg.instantiate()

module LabClimateDashboard 

using Dash, DashHtmlComponents, DashCoreComponents
using DataFrames, CSV
using Dates
using Statistics
import Sockets: getipaddr

include("utils.jl")

# default lower limit of the time axis of the plot
const START_DATE = now() - Dates.Day(3)
# refresh interval in s -> the Plot will update in this interval
const INTERVAL = 5
# when did the last update of the plot happen -> we need this to evaluate what
# is new data and should be appended to the data already in the plot
const last_update = Ref{DateTime}(now()) # use Ref to make a global of fixed type
# the path where the data resides
# TODO: this should be implemented via a config file
const LOGDATA_PATH = "/Users/lackner/.julia/dev/HYT939Logger/log" 
# Have the dataframe that holds all the values global
const df = Ref{DataFrame}()
# initialize the app
const app = dash(external_stylesheets=["https://codepen.io/chriddyp/pen/bWLwgP.css"])

include("layout.jl")
include("callbacks.jl")

"""
    run(;port=8050, debug=false)

Start the server.
"""
function run(;port=8050, debug=false)
    println("Loading the log data...")
    load_logdata!(df, LOGDATA_PATH) 

    println("Starting the server...")
    run_server(app, "0.0.0.0"; debug)

    ip4 = getipaddr()
    println("""
    Starting the server...
    In your browser visit http://127.0.0.1:$port/ from this machine to get to
    the dashboard. 
    
    From other machines in the same network as this machine visit
    http://$ip4:$port/ to view the dashboard.

    Terminate the process by pressing 'Ctrl+c'
    """)

    nothing
end

end