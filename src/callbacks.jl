##---------------------CALLBACKS-------------------##

# Update the figure according to the date range that was picked
# Refresh the figure in the interval defined by INTERVAL. We will only do this
# if we are looking at live data, i.e. if the date range contains the last
# update. 
callback!(app,
    Output("log-graph", "figure"), 
    [
        Input("date-picker-range", "start_date"), 
        Input("date-picker-range", "end_date"), 
        Input("refresh-interval", "n_intervals"),
    ],
    State("log-graph", "figure") # we'll pull the data out of it
) do start_date_str, end_date_str, n_intervals, fig
    # parse dates as DateTime
    start_date = DateTime(start_date_str)
    end_date   = DateTime(end_date_str)

    # the `fig` variable comes is a`JSON3.Object{...}`:
    #     fig = {
    #      "data": [
    #                {
    #                      "x": [],
    #                      "y": [],
    #                   "name": "Temperature",
    #                   "line": {
    #                              "color": "OrangeRed"
    #                           }
    #                },
    #                {
    #                       "x": [],
    #                       "y": [],
    #                    "name": "Humidity",
    #                   "yaxis": "y2",
    #                    "line": {
    #                               "color": "SteelBlue"
    #                            }
    #                }
    #              ],
    #    "layout": {
    #                      "yaxis": {
    #                                      "title": {
    #                                                  "text": "Temperature (°C)",
    #                                                  "font": {
    #                                                             "color": "OrangeRed"
    #                                                          }
    #                                               },
    #                                   "tickfont": {
    #                                                  "color": "OrangeRed"
    #                                               },
    #                                      "range": [
    #                                                 -1,
    #                                                 4
    #                                               ],
    #                                  "autorange": true
    #                               },
    #                     "yaxis2": {
    #                                       "title": {
    #                                                   "text": "relative Humidity (%)",
    #                                                   "font": {
    #                                                              "color": "SteelBlue"
    #                                                           }
    #                                                },
    #                                    "tickfont": {
    #                                                   "color": "SteelBlue"
    #                                                },
    #                                  "overlaying": "y",
    #                                        "side": "right",
    #                                       "range": [
    #                                                  -1,
    #                                                  4
    #                                                ],
    #                                   "autorange": true
    #                               },
    #                 "uirevision": "no",
    #                      "xaxis": {
    #                                      "range": [
    #                                                 -1,
    #                                                 6
    #                                               ],
    #                                  "autorange": true
    #                               }
    #              }
    # }
    # This is immutable. We convert it to a mutable Dict with `copy`
    dfig = copy(fig) # this of type `Dict`

    # in the first go, load the data into the dataframe and put that data into
    # the figure
    if n_intervals == 0
        load_logdata!(df, LOGDATA_PATH)
        replace_figure_data!(dfig, df, (start_date, end_date))
    end
 
    ctx = Dash.callback_context()
    isempty(ctx.triggered) && return dfig
    if ctx.triggered[1].prop_id == "refresh-interval.n_intervals"
        # We have an auto update. So we'll refresh the figure. We'll only do
        # this if the selected end date is after in the future
        end_date < now() && return dfig
        
        load_logdata!(df, LOGDATA_PATH) 
        update_figure!(dfig, df, end_date)
        return dfig
    elseif ctx.triggered[1].prop_id in ["date-picker-range.start_date", "date-picker-range.end_date"]
        replace_figure_data!(dfig, df, (start_date, end_date))
        return dfig
    else
        @warn "Callback was not handled"
        return dfig
    end
end

# Update the temperature stats
callback!(app,
    Output("temperature-stats", "children"), 
    [
        Input("date-picker-range", "start_date"), 
        Input("date-picker-range", "end_date"),
        Input("refresh-interval", "n_intervals"),
    ]
) do start_date_str, end_date_str, n_intervals
    # Don't do anything for the initial run (n_intervals == 0)
    n_intervals == 0 && return html_div()

    start_date = Dates.DateTime(start_date_str)
    end_date = Dates.DateTime(end_date_str)
    stats = statistics(df, :temperature, (start_date, end_date))
    generate_stats(stats, "°C")
end

# Update the temperature stats
callback!(app,
    Output("humidity-stats", "children"), 
    [
        Input("date-picker-range", "start_date"), 
        Input("date-picker-range", "end_date"),
        Input("refresh-interval", "n_intervals"),
    ]
) do start_date_str, end_date_str , n_intervals
    # Don't do anything for the initial run (n_intervals == 0)
    n_intervals == 0 || isempty(df[]) && return html_div()

    
    start_date = Dates.DateTime(start_date_str)
    end_date = Dates.DateTime(end_date_str)
    stats = statistics(df, :humidity, (start_date, end_date))
    generate_stats(stats, "%")
end
