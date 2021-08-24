# using Pkg
# Pkg.activate("development")
# using MimiFUND, Mimi, CSVFiles, DataFrames, Plots

#######################################################################################################################
# LOAD SSP PARAMETERS
########################################################################################################################
# Description: Return FUND model loaded with SSP parameters.
#
# Function Arguments:
#
#       ssp:              SSP scenario for GDP and population. Choose from "SSP1", "SSP2", "SSP3", "SSP4", "SSP5".
#       cmip6_scen:       CMIP6 (RCP/SSP) scenario for emissions. Choose from ssp119, ssp126, ssp245, ssp370, ssp370-lowNTCF-aerchmmip, ssp370-lowNTCF-gidden, ssp434, ssp460, ssp534-over, ssp585.
#       ssp_model:        SSP model that GDP and population assumptions are taken from.
#
#----------------------------------------------------------------------------------------------------------------------

function get_ssp_fund_model(;ssp::String, cmip6_scen::String, ssp_model::String="OECD Env-Growth")
    
    # define param dicts
    param_dict = Dict("ypc_grw" => :ypcgrowth,
                        "pop_grw" => :pgrowth,
                        "urb_pop" => :urbpop)
    gases = ["CO2", "CH4", "N2O", "SF6"]
    gas_param_dict = Dict("CO2" => :mco2,
                        "CH4" => :globch4,
                        "N2O" => :globn2o,
                        "SF6" => :globsf6)

    # load model to be modified with SSP inputs
    m = MimiFUND.get_model()
    run(m)

    # replace ypc and pop growth, urb pop share
    for param in ["ypc_grw", "pop_grw", "urb_pop"]

        # read in SSP parameter and convert to array format
        if param != "urb_pop"
            ssp_data = DataFrame(load(dirname(@__FILE__) * "/ssp_params/" * param * "_combined_fund_" * ssp_model * "_" * ssp * ".csv"))
        else
            ssp_data = DataFrame(load(dirname(@__FILE__) * "/ssp_params/" * param * "_combined_fund_" * ssp * ".csv"))
        end
        ssp_param = Matrix(ssp_data[:,2:17]) # drop first column (years), each column corresponds to a FUND region

        # set parameter
        set_param!(m, param_dict[param], ssp_param)
    end

    # set rcp/ssp emissions for each gas
    for gas in gases
                
        # read in data
        ssp_em_data = DataFrame(load(dirname(@__FILE__) * "/ssp_params/" * cmip6_scen * "_" * gas * "_emissions_fund.csv"))
                
        # assign to vector and convert units as necessary
        if gas == "CO2"
            ssp_em = ssp_em_data[:,3] * 12/44 # convert to MtC from MtCO2
        elseif gas == "N2O"
            ssp_em = ssp_em_data[:,3] ./ 1e3 .* 14/44 # convert to MtN from ktN2O
        else
            ssp_em = ssp_em_data[:,3] # ssp SF6 emissions are in ktSF6/yr; ssp CH4 emissions are in MtCH4/yr
        end

        # set parameter
        set_param!(m, gas_param_dict[gas], ssp_em)
    end 

    run(m)
    return(m)

end


#######################################################################################################################
# ADD PULSE OF EMISSIONS TO GIVEN YEAR
########################################################################################################################
# Description: Add a pulse of emissions to a given year, to FUND model loaded with SSP params.
#
# Function Arguments:
#
#       pulse_year:       Pulse year for SC-GHG calculation.
#       pulse_size:       Pulse size in Mt. For gas = :CO2, will be converted to MtCO2 in function body (hence if you want a 1MtCO2 pulse, enter pulse_size = 1.0).
#       gas:              Gas to perturb (:CO2, :CH4, or :N2O)
#       ssp:              SSP scenario for GDP and population. Choose from "SSP1", "SSP2", "SSP3", "SSP4", "SSP5".
#       cmip6_scen:       CMIP6 (RCP/SSP) scenario for emissions. Choose from ssp119, ssp126, ssp245, ssp370, ssp370-lowNTCF-aerchmmip, ssp370-lowNTCF-gidden, ssp434, ssp460, ssp534-over, ssp585.
#       ssp_model:        SSP model that GDP and population assumptions are taken from.
#
#----------------------------------------------------------------------------------------------------------------------

function get_ssp_fund_marginal_model(;gas::Symbol=:CO2, pulse_year::Int, pulse_size::Float64=1.0, ssp::String, cmip6_scen::String, ssp_model::String="OECD Env-Growth")
    
    ## load base model with ssp params
    m = MimiFUND.get_ssp_fund_model(;ssp = ssp, cmip6_scen = cmip6_scen, ssp_model = ssp_model)
    
    ## create and run marginal model
    mm = Mimi.create_marginal_model(m, pulse_size)
    run(mm)

    ## perturb emissions of selected gas in marginal model

    # get pulse year index
    pulse_year_index = findall((in)([pulse_year]), collect(1950:3000))
    
    # set marginal model emissions equal to perturbed emissions
    if gas == :CO2
        # perturb CO2 emissions
        new_emissions = copy(mm.base[:climateco2cycle, :mco2])
        new_emissions[pulse_year_index] = new_emissions[pulse_year_index] .+ (pulse_size * 12/44) # FUND CO2 emissions are in MtC, convert 1MtCO2 emissions pulse to MtCO2

        # update emissions parameter
        MimiFUND.update_param!(mm.modified, :mco2, new_emissions)

    elseif gas == :N2O
        # perturb N2O emissions
        new_emissions = copy(mm.base[:climaten2ocycle, :globn2o])
        new_emissions[pulse_year_index] = new_emissions[pulse_year_index] .+ (pulse_size * 14/44) # N2O emissions are in MtN, convert 1MtN2O pulse to MtN

        # update emissions parameter
        MimiFAIR.update_param!(mm.modified, :globn2o, new_emissions)

    elseif gas == :CH4
        # perturb CH4 emissions
        new_emissions = copy(mm.base[:climatech4cycle, :globch4])
        new_emissions[pulse_year_index] = new_emissions[pulse_year_index] .+ pulse_size # CH4 emissions are in MtCH4

        # update emissions parameter
        MimiFAIR.update_param!(mm.modified, :globch4, new_emissions)
    else
        error("Gas not recognized. Available gases are :CO2, :N2O, and :CH4")
    end
    
    ## run marginal model
    run(mm)
    
    return(mm)

end



#######################################################################################################################
# COMPUTE SC-GHG
########################################################################################################################
# Description: Compute SC-GHG from SSP-modified FUND (constant discounting only, for now).
#
# Function Arguments:
#
#       pulse_year:       Pulse year for SC-GHG calculation.
#       pulse_size:       Pulse size in Mt. For gas = :CO2, will be converted to MtCO2 in function body (hence if you want a 1MtCO2 pulse, enter pulse_size = 1.0).
#       gas:              Gas to perturb (:CO2, :CH4, or :N2O)
#       ssp:              SSP scenario for GDP and population. Choose from "SSP1", "SSP2", "SSP3", "SSP4", "SSP5".
#       cmip6_scen:       CMIP6 (RCP/SSP) scenario for emissions. Choose from ssp119, ssp126, ssp245, ssp370, ssp370-lowNTCF-aerchmmip, ssp370-lowNTCF-gidden, ssp434, ssp460, ssp534-over, ssp585.
#       ssp_model:        SSP model that GDP and population assumptions are taken from.
#       discount_rate:    Constant discount rate, as a decimal.
#       last_year:        Last year for SC-GHG calculation, marginal damages dropped after this year. Defaults to 2300.
#
#----------------------------------------------------------------------------------------------------------------------

function compute_scghg_ssp_fund(;discount_rate::Float64, gas::Symbol=:CO2, last_year::Int = 2300, pulse_year::Int, pulse_size::Float64=1.0, ssp::String, cmip6_scen::String, ssp_model::String="OECD Env-Growth")
    
    ## create marginal model with ssp params
    mm = MimiFUND.get_ssp_fund_marginal_model(;gas = gas, pulse_year = pulse_year, pulse_size = pulse_size, ssp = ssp, cmip6_scen = cmip6_scen, ssp_model = ssp_model)

    # last year defaults to 2300, but make sure it's not > 3000
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
    scghg = sum(skipmissing(marginaldamage .* df)) / (pulse_size * 1e6) # Mt to t

    return(scghg)

end