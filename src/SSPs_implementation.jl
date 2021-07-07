using MimiFUND, CSVFiles, DataFrames, Plots

## load model

# model to be modified with SSP inputs
m = MimiFUND.get_model()
run(m)

# default FUND for comparison
default_FUND = MimiFUND.get_model()
run(default_FUND)

## choose SSP scenario and model
scenario = "SSP2"
model = "IIASA GDP"

# ---------------------------------------------------------------------------------------------
# replace ypc and pop growth
# ---------------------------------------------------------------------------------------------

# folder where data is saved
directory = "C:/Users/TTAN/Environmental Protection Agency (EPA)/NCEE Social Cost of Carbon - General/models/Notes/Code/output"

## YPC GROWTH

# old_ypcgrowth = m[:socioeconomic, :ypcgrowth] # 1051 x 16 array

# read in SSP parameter and convert to array format
ssp_ypc_grw_data = DataFrame(load(directory * "/ypc_grw_combined_fund_" * model * "_" * scenario * ".csv"))
ssp_ypc_grw = Matrix(ssp_ypc_grw_data[:,2:17])

# set parameter
set_param!(m, :ypcgrowth, ssp_ypc_grw)

## POP GROWTH

# old_pgrowth = m[:population, :pgrowth]

# read in SSP parameter and convert to array format
ssp_pop_grw_data = DataFrame(load(directory * "/pop_grw_combined_fund_" * model * "_" * scenario * ".csv"))
ssp_pop_grw = Matrix(ssp_pop_grw_data[:,2:17])

# set parameter
set_param!(m, :pgrowth, ssp_pop_grw)

## rerun model

# run(m)

new_ypcgrowth = m[:socioeconomic, :ypcgrowth]
new_pgrowth = m[:population, :pgrowth]

# # plot to compare
# old_ypcgrowth .- new_ypcgrowth
# fund_years = collect(1950:1:3000)
# plot(fund_years, old_ypcgrowth .- new_ypcgrowth, title = "FUND ypcgrowth")

# compare population
new_pop = m[:population, :globalpopulation]
old_pop = default_FUND[:population, :globalpopulation]

plot(fund_years, old_pop)
plot!(fund_years, new_pop) # new pop is higher

# compare global income
new_gdp = m[:socioeconomic, :globalincome]
old_gdp = default_FUND[:socioeconomic, :globalincome]

plot(fund_years, old_gdp)
plot!(fund_years, new_gdp) # new gdp is lower

# compare ypc
new_ypc = m[:socioeconomic, :globalypc]
old_ypc = default_FUND[:socioeconomic, :globalypc]

plot(fund_years, old_ypc)
plot!(fund_years, new_ypc) # new ypc is lower

# compare temperature
old_temp = default_FUND[:climatedynamics, :temp]
new_temp = m[:climatedynamics, :temp]

plot(fund_years, new_temp .- old_temp) # new temperature is initially higher, then lower

# ---------------------------------------------------------------------------------------------
# replace emissions
# ---------------------------------------------------------------------------------------------

scenario = "SSP2-45"
gases = ["co2", "ch4", "n2o", "sf6"]

gas_param_dict = Dict("co2" => :mco2,
                    "ch4" => :globch4,
                    "n2o" => :globn2o,
                    "sf6" => :globsf6)

# set ssp emissions for each gas
for gas in gases
    
    # read in data
    ssp_em_data = DataFrame(load(directory * "/" * gas * "_global_emissions_" * scenario * ".csv"))
    
    # assign to vector and convert units as necessary
    if gas == "co2"
        ssp_em = ssp_em_data[:,3] .* 12/44 # convert to MtC
    elseif gas == "n2o"
        ssp_em = ssp_em_data[:,3] ./ 1e3 .* 14/46 # convert to MtN
    else
        ssp_em = ssp_em_data[:,3]
    end

    # combine with fund default emissions for years pre 2015 and post 2100
    ssp_emissions_input = copy(default_FUND[:emissions, gas_param_dict[gas]])
    ssp_emissions_input[66:151] = ssp_em # replace default fund emissions with ssp emissions for 2015-2100

    # set parameter
    set_param!(m, gas_param_dict[gas], ssp_emissions_input)
end 

run(m)

## plot and compare

# CO2 emissions 
ssp_fund_emissions[150:250]
m[:climateco2cycle, :mco2][149:250]
default_FUND[:climateco2cycle, :mco2][150:250]

plot(fund_years[66:151], m[:climateco2cycle, :mco2][66:151])
plot!(fund_years[66:151], default_FUND[:climateco2cycle, :mco2][66:151])

plot(fund_years, m[:climateco2cycle, :mco2])
plot!(fund_years, default_FUND[:emissions, :mco2])

# CH4 emissions
plot(fund_years[66:151], m[:climatech4cycle, :globch4][66:151])
plot!(fund_years[66:151], default_FUND[:climatech4cycle, :globch4][66:151])

plot(fund_years, m[:climatech4cycle, :globch4])
plot!(fund_years, default_FUND[:climatech4cycle, :globch4])

# N2O emissions
plot(fund_years[66:151], m[:climaten2ocycle, :globn2o][66:151])
plot!(fund_years[66:151], default_FUND[:climaten2ocycle, :globn2o][66:151])

plot(fund_years, m[:climaten2ocycle, :globn2o])
plot!(fund_years, default_FUND[:climaten2ocycle, :globn2o])

# SF6 emissions
plot(fund_years[66:151], m[:climatesf6cycle, :globsf6][66:151])
plot!(fund_years[66:151], default_FUND[:climatesf6cycle, :globsf6][66:151])

plot(fund_years, m[:climatesf6cycle, :globsf6])
plot!(fund_years, default_FUND[:climatesf6cycle, :globsf6])
