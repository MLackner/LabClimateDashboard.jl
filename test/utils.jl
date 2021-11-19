function generate_logdata()
    logdata_path = mktempdir()

    # generate fake data
    s = now() - Day(30)
    e = now()
    dt = Minute(1)

    dates = s:dt:e
    # sin/cos require numeric values. Pass the millisecond
    # value to the function
    temp = [sin(x.instant.periods.value) / 100 for x in dates]
    hum = [cos(x.instant.periods.value) / 110 for x in dates]

    writedlm(joinpath(logdata_path, "test.log"), [dates temp hum])

    return logdata_path
end
