
## function to compute partial sc-ghgs (deterministic only)

function compute_sc_partial(m::Model=get_model(); 
    sector::Symbol,
    gas::Symbol = :CO2, 
    year::Union{Int, Nothing} = nothing, 
    eta::Float64 = 1.45, 
    prtp::Float64 = 0.015, 
    equity_weights::Bool = false, 
    equity_weights_normalization_region::Int = 0,
    last_year::Int = 3000, 
    pulse_size::Float64 = 1e7
    )

    year === nothing ? error("Must specify an emission year. Try `compute_sc(year=2020)`.") : nothing
    !(last_year in 1950:3000) ? error("Invlaid value for `last_year`: $last_year. `last_year` must be within the model's time index 1950:3000.") : nothing
    !(year in 1950:last_year) ? error("Invalid value for `year`: $year. `year` must be within the model's time index 1950:$last_year.") : nothing

    mm = get_marginal_model(m; year = year, gas = gas, pulse_size = pulse_size)

    ntimesteps = getindexfromyear(last_year)

    # Run the "best guess" social cost calculation
    run(mm; ntimesteps = ntimesteps)

    sc = _compute_sc_from_mm_partial(mm, sector = sector, year = year, gas = gas, ntimesteps = ntimesteps, equity_weights = equity_weights, eta = eta, prtp = prtp, equity_weights_normalization_region=equity_weights_normalization_region)

    return sc

end


## sector can be one of the below
# water = Parameter(index=[time,regions])
# forests = Parameter(index=[time,regions])
# heating = Parameter(index=[time,regions])
# cooling = Parameter(index=[time,regions])
# agcost = Parameter(index=[time,regions])
# drycost = Parameter(index=[time,regions])
# protcost = Parameter(index=[time,regions])
# entercost = Parameter(index=[time,regions])
# hurrdam = Parameter(index=[time,regions])
# extratropicalstormsdam = Parameter(index=[time,regions])
# species = Parameter(index=[time,regions])
# deadcost = Parameter(index=[time,regions])
# morbcost = Parameter(index=[time,regions])
# wetcost = Parameter(index=[time,regions])
# leavecost = Parameter(index=[time,regions])


# helper function for computing SC from a MarginalModel that's already been run, not to be exported
function _compute_sc_from_mm_partial(mm::MarginalModel; sector::Symbol, year::Int, gas::Symbol, ntimesteps::Int, equity_weights::Bool, equity_weights_normalization_region::Int, eta::Float64, prtp::Float64)

    # Calculate the marginal damage between run 1 and 2 for each year/region
    # marginaldamage = mm[:impactaggregation, :loss]

    if sector in [:water, :forests, :heating, :cooling, :agcost]
        marginaldamage = mm[:impactaggregation, sector] .* -1e9
    else
        marginaldamage = mm[:impactaggregation, sector] .* 1e9
    end

    ypc = mm.base[:socioeconomic, :ypc]

    # Compute discount factor with or without equityweights
    df = zeros(ntimesteps, 16)
    if !equity_weights
        for r = 1:16
            x = 1.
            for t = getindexfromyear(year):ntimesteps
                df[t, r] = x
                gr = (ypc[t, r] - ypc[t - 1, r]) / ypc[t - 1,r]
                x = x / (1. + prtp + eta * gr)
            end
        end
    else
        normalization_ypc = equity_weights_normalization_region==0 ? mm.base[:socioeconomic, :globalypc][getindexfromyear(year)] : ypc[getindexfromyear(year), equity_weights_normalization_region]
        df = Float64[t >= getindexfromyear(year) ? (normalization_ypc / ypc[t, r]) ^ eta / (1.0 + prtp) ^ (t - getindexfromyear(year)) : 0.0 for t = 1:ntimesteps, r = 1:16]
    end 

    # Compute global social cost
    sc = sum(marginaldamage[2:ntimesteps, :] .* df[2:ntimesteps, :])   # need to start from second value because first value is missing
    return sc
end
