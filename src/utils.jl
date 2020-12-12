## Here are some utility functions

"""
    load_logdata!(df::Ref{DataFrame}, path) -> nothing

Loads the logfiles from the specified path into the `DataFrame` reference `df`.
All files with the `".log"` extension will be loaded. The resulting data frame
will have three columns: `:date`, `:temperature` and `:humidity`. If there are no
data to be read we put in some default values because other functionality relies
on data in the data frame.
"""
function load_logdata!(df::Ref{DataFrame}, path)
    df[] = DataFrame(date=DateTime[], temperature=Float64[], humidity=Float64[])
    for file in readdir(path)
        # skip file if it is not a .log file
        splitext(file)[2] ≠ ".log" && continue
        _df = CSV.read(joinpath(path, file), DataFrame; header=[:date, :temperature, :humidity])
        append!(df[], _df)
    end
    
    # There has to be data in the data frame in order to do statistics on it. If
    # we get an empty data frame, we put defaults in there so we don't get
    # errors.
    if isempty(df[])
        @warn "There is no data to plot"
        _df = DataFrame(date=now(), temperature=-300.0, humidity=-42.0)
        append!(df[], _df)
    end

    nothing
end

"""
    filter_dates(df::Ref{DataFrame}, start_date, end_date) -> DataFrame

Filters the `DataFrame` at `df::Ref{DataFrame}` so it returns only the part that
is in the range between `start_date` and `end_date`.
"""
filter_dates(df::Ref{DataFrame}, start_date, end_date) = filter(x -> start_date < x.date < end_date, df[])

"""
    update_figure!(fig, df, end_date) -> nothing

Appends data from `df` to the figure `fig` that were not already included in the
figure. Only data between the last date entry in the figure and `end_date` will
be appended.
"""
function update_figure!(fig, df, end_date)
    # if we get an empty figure we'll return right away
    isempty(fig.data[1].x) && return

    # we have to append the data that was generated after the last update up
    # until the end_date
    last_date = fig.data[1].x[end] |> DateTime
    dff = filter_dates(df, last_date, end_date)

    append!(fig.data[1].x, dff.date)
    append!(fig.data[1].y, dff.temperature)
    append!(fig.data[2].x, dff.date)
    append!(fig.data[2].y, dff.humidity)

    nothing
end

"""
    replace_figure_data!(fig, df, (date_range)) -> nothing

This will replace the data in the figure `fig` with the data in `DataFrame`
reference `df` in the desired `date_range`. The date range should be given as
`(start_date, end_date)`.
"""
function replace_figure_data!(fig, df, (date_range))
    start_date, end_date = date_range
    dff = filter_dates(df, start_date, end_date)

    # since the data is stored in a named tuple we can only modify the data
    # inside the data arrays but not replace them. In order to achieve this, we
    # first delete all elements of the arrays and then append the new values.
    for (array, new_values) in zip(
        [fig.data[1].x, fig.data[1].y, fig.data[2].x, fig.data[2].y],
        [dff.date, dff.temperature, dff.date, dff.humidity]
    )
        deleteat!(array, eachindex(array)) # removes all elements
        append!(array, new_values)
    end

    nothing
end

"""
    statistics(df::Ref{DataFrame}, column, date_range=(START_DATE, now())) ->
    Tuple{Float64,Float64,Float64}
    
Performs analysis on the data frame reference `df` for the specified `column` in
the specified `date_range`. It returns a `Tuple` where the entries are the `(mean,
min, max)` of the `column`. If the data frame at `df` is empty we return `0.0`s
as default values.
"""
function statistics(df::Ref{DataFrame}, column, date_range=(START_DATE, now()))
    # if there is no data in the dataframe return immeadiatly
    isempty(df[]) && return (mean=0.0, min=0.0, max=0.0)

    dff = filter_dates(df, date_range...)

    # if the dataframe is empty return some default values
    isempty(dff) && return (mean=0.0, min=0.0, max=0.0)

    min_val, max_val = extrema(dff[!, column])
    mean_val = mean(dff[!, column])
    (mean=mean_val, min=min_val, max=max_val)
end

"""
    generate_stats(stats, unit) --> DashHtmlComponents.Component

Returns a `html_div` component with the statistics text.
"""
function generate_stats(stats, unit)
    html_div() do
        html_p("Mean: $(round(stats.mean, digits=2)) $unit"),
        html_p("Max: $(round(stats.max, digits=2)) $unit"),
        html_p("Min: $(round(stats.min, digits=2)) $unit")
    end
end
