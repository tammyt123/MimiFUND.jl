import Mimi.compinstance

"""
Creates a MarginalModel of FUND with additional emissions in the specified year for the specified gas. 
"""
function create_marginal_FUND_model(; gas = :C, emissionyear = 2010, parameters = nothing, yearstorun = 1050)

    # Get default FUND model
    FUND = getmodel(nsteps = yearstorun, params = parameters)

    # Build marginal model
    mm = create_marginal_model(FUND)
    m1, m2 = mm.base, mm.marginal

    add_marginal_emissions!(m2, emissionyear; gas = gas, yearstorun = yearstorun)

    Mimi.build(m1)
    Mimi.build(m2)
    return mm 
end 

"""
Adds a marginalemission component to m, and sets the additional emissions if a year is specified.
"""
function add_marginal_emissions!(m, emissionyear = nothing; gas = :C, yearstorun = 1050)

    # Add additional emissions to m
    add_comp!(m, Mimi.adder, :marginalemission, before = :climateco2cycle, first = 1951)
    addem = zeros(yearstorun)
    if emissionyear != nothing 
        addem[getindexfromyear(emissionyear)-1:getindexfromyear(emissionyear) + 8] .= 1.0
    end
    set_param!(m, :marginalemission, :add, addem)

    # Reconnect the appropriate emissions in m
    if gas == :C
        connect_param!(m, :marginalemission, :input, :emissions, :mco2)
        connect_param!(m, :climateco2cycle, :mco2, :marginalemission, :output, repeat([missing], yearstorun + 1))
    elseif gas == :CH4
        connect_param!(m, :marginalemission, :input, :emissions, :globch4)
        connect_param!(m, :climatech4cycle, :globch4, :marginalemission, :output, repeat([missing], yearstorun + 1))
    elseif gas == :N2O
        connect_param!(m, :marginalemission, :input, :emissions, :globn2o)
        connect_param!(m, :climaten2ocycle, :globn2o, :marginalemission, :output, repeat([missing], yearstorun + 1))
    elseif gas == :SF6
        connect_param!(m, :marginalemission, :input, :emissions,:globsf6)
        connect_param!(m, :climatesf6cycle, :globsf6, :marginalemission, :output, repeat([missing], yearstorun + 1))
    else
        error("Unknown gas: $gas")
    end

end 

"""
Helper function to set the marginal emissions in the specified year.
"""
function perturb_marginal_emissions!(m::Model, emissionyear; comp_name = :marginalemission)

    ci = compinstance(m, comp_name)
    emissions = Mimi.get_param_value(ci, :add)

    nyears = length(Mimi.dimension(m, :time))
    new_em = zeros(nyears - 1)
    new_em[getindexfromyear(emissionyear)-1:getindexfromyear(emissionyear) + 8] .= 1.0
    emissions[:] = new_em

end

"""
Returns the social cost per one ton of additional emissions of the specified gas in the specified year. 
Uses the specified eta and prtp for discounting, with the option to use equity weights.
"""
function get_social_cost(; emissionyear = 2010, parameters = nothing, yearstoaggregate = 1000, gas = :C, useequityweights = false, eta = 1.0, prtp = 0.001)

    # Get marginal model
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)
    mm = create_marginal_FUND_model(emissionyear = emissionyear, parameters = parameters, yearstorun = yearstorun, gas = :C)
    run(mm)
    m1, m2 = mm.base, mm.marginal

    damage1 = m1[:impactaggregation, :loss]
    # Take out growth effect effect of run 2 by transforming the damage from run 2 into % of GDP of run 2, and then multiplying that with GDP of run 1
    damage2 = m2[:impactaggregation, :loss] ./ m2[:socioeconomic, :income] .* m1[:socioeconomic, :income]

    # Calculate the marginal damage between run 1 and 2 for each
    # year/region
    marginaldamage = (damage2 .- damage1) / 10000000.0

    ypc = m1[:socioeconomic, :ypc]

    df = zeros(yearstorun + 1, 16)
    if !useequityweights
        for r = 1:16
            x = 1.
            for t = getindexfromyear(emissionyear):yearstorun
                df[t, r] = x
                gr = (ypc[t, r] - ypc[t - 1, r]) / ypc[t - 1,r]
                x = x / (1. + prtp + eta * gr)
            end
        end
    else
        globalypc = m1[:socioeconomic, :globalypc]
        df = Float64[t >= getindexfromyear(emissionyear) ? (globalypc[getindexfromyear(emissionyear)] / ypc[t, r]) ^ eta / (1.0 + prtp) ^ (t - getindexfromyear(emissionyear)) : 0.0 for t = 1:yearstorun + 1, r = 1:16]
    end 

    scc = sum(marginaldamage[2:end, :] .* df[2:end, :])
    return scc

end

"""
Returns a matrix of marginal damages per one ton of additional emissions of the specified gas in the specified year.
"""
function getmarginaldamages(; emissionyear=2010, parameters = nothing, yearstoaggregate = 1000, gas = :C) 

    # Get marginal model
    yearstorun = min(1050, getindexfromyear(emissionyear) + yearstoaggregate)
    mm = create_marginal_FUND_model(emissionyear = emissionyear, parameters = parameters, yearstorun = yearstorun, gas = :C)
    run(mm)

    # Get damages
    marginaldamages = mm[:impactaggregation, :loss] / 10000000.0
    return marginaldamages
end