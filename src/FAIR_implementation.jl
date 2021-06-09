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

    ## set parameter in FUND model
    MimiFUND.set_param!(m, :climateco2cycle, :temp, :climate_temp, input_temp)
    MimiFUND.set_param!(m, :biodiversity, :temp, :biodiversity_temp, input_temp)
    MimiFUND.set_param!(m, :ocean, :temp, :ocean_temp, input_temp)
    MimiFUND.set_param!(m, :inputtemp, input_temp)

    run(m)

    return(m)

end

## function to get marginal FUND-FAIR model (i.e. input perturbed FAIR temperature vector into FUND)
## note: FAIR-NCEE must be loaded in environment first!!
function get_fundfair_marginal_model(;usg_scenario::String, pulse_year::Int)
    
    ## create FUND marginal model
    m = MimiFUND.get_fundfair(usg_scenario = usg_scenario)
    mm = Mimi.create_marginal_model(m, 1.0) # check: might need to change this pulse size
    run(mm)

    ## get perturbed FAIR temperature vector
    fair_years = collect(1765:1:2300)
    new_temperature = MimiFAIR.get_perturbed_fair_temperature(usg_scenario = usg_scenario, pulse_year = pulse_year)
    new_temperature_df = DataFrame(year = fair_years, T = new_temperature)

    fund_years = collect(1950:1:3000)
    new_input_temp = new_temperature_df[[year in fund_years for year in fair_years], :T]
    append!(new_input_temp, repeat([new_input_temp[end]], length(fund_years) - length(new_input_temp)))

    ## set temperature in marginal DICE model to equal perturbed FAIR temperature
    MimiFUND.update_param!(mm.modified, :climate_temp, new_input_temp)
    MimiFUND.update_param!(mm.modified, :biodiversity_temp, new_input_temp)
    MimiFUND.update_param!(mm.modified, :ocean_temp, new_input_temp)
    MimiFUND.update_param!(mm.modified, :inputtemp, new_input_temp)

    run(mm)

    return(mm)

end

## compute SCC from FUNDFAIR -- CONSTANT DISCOUNTING ONLY FOR NOW
function compute_scc_fundfair(;usg_scenario::String, pulse_year::Int, discount_rate::Float64, last_year::Int = 2300)
    
    mm = MimiFUND.get_fundfair_marginal_model(usg_scenario = usg_scenario, pulse_year = pulse_year)

    if last_year > 3000
        error("`last_year` cannot be greater than 3000.")
    end

    ## calculate discount factors
    prtp = discount_rate # change this when implementing ramsey
    fund_years = collect(1950:1:3000)

    last_year_index = findfirst(isequal(last_year), fund_years)
    marginaldamage = mm[:impactaggregation, :loss][1:last_year_index,:] # drop MD after last_year

    pulse_year_index = findfirst(isequal(pulse_year), fund_years)

    # constant discounting
    df = zeros(size(marginaldamage,1), 16)
    for i in 1:size(marginaldamage,1)
        if i >= pulse_year_index
            df[i,:] .= 1/(1+prtp)^(i-pulse_year_index)
        end
    end

    ## calculate SCC
    scc = sum(skipmissing(marginaldamage .* df)) / 1e9 # Gt to t

    return(scc)
end

