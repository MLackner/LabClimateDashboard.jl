# THIS IS THE APP'S LAYOUT

function layout!(app)
    app.layout = html_div(id="main") do
        html_div(id="header") do
            html_h1(
                "Lab Climate Dashboard",
            )#h1
        end,
        html_hr(),
        html_div(id="body") do
            html_div(className="graph", id="graph-div") do
                dcc_graph(
                    id = "log-graph",
                    figure = (
                        data = [
                            (
                                x    = DateTime[],
                                y    = Float64[], 
                                name = "Temperature", 
                                line = (color=:OrangeRed,)
                            ),
                            (
                                x     = DateTime[], 
                                y     = Float64[], 
                                name  = "Humidity", 
                                yaxis = "y2", 
                                line  = (color=:SteelBlue,)
                            ),
                        ],
                        layout = (
                            yaxis = (
                                title = "Temperature (°C)",
                                titlefont = (
                                    color = :OrangeRed,
                                ),
                                tickfont = (
                                    color = :OrangeRed,
                                ),
                            ),
                            yaxis2 = (
                                title = "relative Humidity (%)",
                                titlefont = (
                                    color = :SteelBlue,
                                ),
                                tickfont = (
                                    color = :SteelBlue,
                                ),
                                overlaying = "y",
                                side = "right",
                            ),
                            uirevision="no",
                        )
                    )
                )
            end, #log-graph
            html_hr(),
            html_div(id="range-select") do
                html_p("Pick a date range:"),
                dcc_datepickerrange(
                    id = "date-picker-range",
                    min_date_allowed = DateTime("2020-01-01"), #minimum(df.date),
                    max_date_allowed = DateTime("2040-01-01"), #maximum(df.date),
                    initial_visible_month = now(),
                    start_date = START_DATE,
                    end_date = Date( now() ) + Day(1),
                )
            end, #range-select
            html_hr(),
            html_div(className="stats", id="stats") do
                html_h2("Statistics"),
                html_div() do
                    html_h3("Temperature"),
                    html_div(id = "temperature-stats")
                end,
                html_div() do
                    html_h3("Humidity"),
                    html_div(id = "humidity-stats")
                end
            end #stats
        end, #body

        # INVISIBLE COMPONENTS
        html_div() do 
            # This will trigger a callback to update the graph regularly
            dcc_interval(
                id = "refresh-interval",
                interval = INTERVAL*1000, # interval in ms
                n_intervals = 0,
            )
        end
    end 

    nothing
end #layout