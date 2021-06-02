## function to get baseline FUND-FAIR model (i.e. input temperature vector from FAIR-NCEE into baseline FUND)
function get_fundfair(;usg_scenario::String)
    
    ## load baseline FUND model
    m = MimiFUND.get_model()
    run(m)

    ## load baseline FAIR-NCEE
    FAIR = MimiFAIR.get_model(usg_scenario = usg_scenario)
    run(FAIR)

    fair_years = collect(1765:1:2300)
    fund_years = collect(1950:1:3000)

    temperature = DataFrame(year = fair_years, T = FAIR[:temperature, :T])

    input_temp = temperature[[year in fund_years for year in fair_years], :T] # 58 element array, needs to be 100. make temperature constant after 2300
    append!(input_temp, repeat([input_temp[end]], length(fund_years) - length(input_temp)))

    ## set parameter in DICE model
    MimiFUND.set_param!(m, :temp, input_temp)
    run(m)

    return(m)

end

## function to get marginal FUND-FAIR model (i.e. input perturbed FAIR temperature vector into FUND)
## note: FAIR-NCEE must be loaded in environment first!!
function get_fundfair_marginal_model(;usg_scenario::String, pulse_year::Int)
    
    ## create FUND marginal model
    m = MimiFUND.get_fundfair()
    mm = Mimi.create_marginal_model(m, 1.0) # check: might need to change this pulse size
    run(mm)

    ## get perturbed FAIR temperature vector
    new_temperature = MimiFAIR.get_perturbed_fair_temperature(usg_scenario = usg_scenario, pulse_year = pulse_year)
    new_temperature_df = DataFrame(year = fair_years, T = new_temperature)

    fund_years = collect(1950:1:3000)
    new_input_temp = new_temperature_df[[year in fund_years for year in fair_years], :T]
    append!(new_input_temp, repeat([new_input_temp[end]], length(fund_years) - length(new_input_temp)))

    ## set temperature in marginal DICE model to equal perturbed FAIR temperature
    MimiFUND.update_param!(mm.modified, :temp, new_input_temp)
    run(mm)

    return(mm)

end

## compute SCC from FUNDFAIR
function compute_scc_fundfair(;usg_scenario::String, pulse_year::Int, prtp::Float64, eta::Float64, last_year::Int=2300)
    
    mm = MimiFUND.get_fundfair_marginal_model(usg_scenario::String, pulse_year::Int)

    marginaldamage = mm[:impactaggregation, :loss]

    # calculate discount factors
    df = zeros(ntimesteps, 16)

    # assume equity_weights = false and equity_weights_normalization_region = 0 -- NEED TO CHECK THIS
    normalization_ypc = equity_weights_normalization_region==0 ? mm.base[:socioeconomic, :globalypc][getindexfromyear(year)] : ypc[getindexfromyear(year), equity_weights_normalization_region]
    df = Float64[t >= getindexfromyear(year) ? (normalization_ypc / ypc[t, r]) ^ eta / (1.0 + prtp) ^ (t - getindexfromyear(year)) : 0.0 for t = 1:ntimesteps, r = 1:16]

    # Compute global social cost
    sc = sum(marginaldamage[2:ntimesteps, :] .* df[2:ntimesteps, :])   # need to start from second value because first value is missing
    ## NEED TO CHECK THE ABOVE

    return(scc)
end

