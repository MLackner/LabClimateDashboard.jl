# LabClimateDashboard
This is a dashboard to view temperature / humidity log data.

## Installation
To install the dashboard, from the REPL type
```julia
julia> ]
pkg> add https://github.com/MLackner/LabClimateDashboard.jl
```

## Usage
The dashboard is hosted on a server running on the local machine. To start the
server open a Julia REPL and do
```julia
julia> using LabClimateDashboard
julia> LabClimateDashboard.run("<path/to/log/folder/>")
```

By default the server listens on port `8050` on `localhost` or `0.0.0.0`. To
open the dashboard visit `0.0.0.0:8050` in your browser. The port and printing
of debug information can be configured via the `port` and `debug` keyword
arguments respectively like for example
```julia
LabClimateDashboard.run("<path/to/log/folder/>"; port=8080, debug=true)
```

> The package is supposed to be used together with the
> [HTLogger.jl](https://github.com/MLackner/HTLogger.jl) package.
