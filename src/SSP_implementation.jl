# ---------------------------------------------------------------------------------------------
# description: manual SSP implementation and plotting of outputs
# ---------------------------------------------------------------------------------------------

using Pkg
Pkg.activate("development")
using MimiFUND, Mimi, CSVFiles, DataFrames, Plots

# set root dir
directory = "C:/Users/TTAN/Environmental Protection Agency (EPA)/NCEE Social Cost of Carbon - General/models/Notes/Code"

# set constants
fund_years = collect(1950:1:3000)
param_dict = Dict("ypc_grw" => :ypcgrowth,
                "pop_grw" => :pgrowth,
                "urb_pop" => :urbpop)
gases = ["CO2", "CH4", "N2O", "SF6"]
gas_param_dict = Dict("CO2" => :mco2,
                    "CH4" => :globch4,
                    "N2O" => :globn2o,
                    "SF6" => :globsf6)

# ---------------------------------------------------------------------------------------------
# first pass implementation
# ---------------------------------------------------------------------------------------------

## implement with OECD Env-Growth model

model = "OECD Env-Growth"
ssp = "SSP4" # choose from SSP1-5
cmip6_scen = "ssp460" # choose from ssp119, ssp126, ssp245, ssp370, ssp370-lowNTCF-aerchmmip, ssp370-lowNTCF-gidden, ssp434, ssp460, ssp534-over, ssp585
# currently using ssp126, ssp245, ssp370, ssp460, ssp585 to pair with ssp1-5 respectively

## load model
# model to be modified with SSP inputs
m = MimiFUND.get_model()
run(m)

# default FUND for comparison
default_FUND = MimiFUND.get_model()
run(default_FUND)

# ---------------------------------------------------------------------------------------------
# replace ypc and pop growth, urb pop share
# ---------------------------------------------------------------------------------------------

for param in ["ypc_grw", "pop_grw", "urb_pop"]

    # read in SSP parameter and convert to array format
    if param != "urb_pop"
        ssp_data = DataFrame(load(directory * "/output/ssp/final_params/" * param * "_combined_fund_" * model * "_" * ssp * ".csv"))
    else
        ssp_data = DataFrame(load(directory * "/output/ssp/final_params/" * param * "_combined_fund_" * ssp * ".csv"))
    end
    ssp_param = Matrix(ssp_data[:,2:17]) # drop first column (years), each column corresponds to a FUND region

    # set parameter
    set_param!(m, param_dict[param], ssp_param)
end

# run(m)

# ---------------------------------------------------------------------------------------------
# replace emissions
# ---------------------------------------------------------------------------------------------

# set emissions for each gas
for gas in gases
            
    # read in data
    ssp_em_data = DataFrame(load(directory * "/output/ssp/final_params/" * cmip6_scen * "_" * gas * "_emissions_fund.csv"))
            
    # assign to vector and convert units as necessary
    if gas == "CO2"
        ssp_em = ssp_em_data[:,3] * 12/44 # convert to MtC from MtCO2
    elseif gas == "N2O"
        ssp_em = ssp_em_data[:,3] ./ 1e3 .* 14/44 # convert to MtN from ktN2O
    else
        ssp_em = ssp_em_data[:,3]
    end

    # set parameter
    set_param!(m, gas_param_dict[gas], ssp_em)
end 

# ---------------------------------------------------------------------------------------------
# run and explore results
# ---------------------------------------------------------------------------------------------

# run model with updated params
run(m)

# compare to default FUND

## global ypc

# just 2015-2300
plot(fund_years[66:351], m[:socioeconomic, :globalypc][66:351], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years[66:351], default_FUND[:socioeconomic, :globalypc][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_ypc_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:socioeconomic, :globalypc], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = "FUND x " * ssp, legend = :topleft)
plot!(fund_years, default_FUND[:socioeconomic, :globalypc], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_ypc_" * ssp))

## global income

# just 2015-2300
plot(fund_years[66:351], m[:socioeconomic, :globalincome][66:351], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = "FUND x " * ssp, legend = :topleft)
plot!(fund_years[66:351], default_FUND[:socioeconomic, :globalincome][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_income_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:socioeconomic, :globalincome], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = "FUND x " * ssp, legend = :topleft)
plot!(fund_years, default_FUND[:socioeconomic, :globalincome], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_ypc_" * ssp))

## global population

# just 2015-2300
plot(fund_years[66:351], m[:socioeconomic, :globalpopulation][66:351], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years[66:351], default_FUND[:socioeconomic, :globalpopulation][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_pop_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:socioeconomic, :globalpopulation], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = "FUND x " * ssp, legend = :bottomright)
plot!(fund_years, default_FUND[:socioeconomic, :globalpopulation], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_pop_" * ssp))

## co2 emissions

# just 2015-2300
plot(fund_years[66:351], m[:climateco2cycle, :mco2][66:351], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years[66:351], default_FUND[:climateco2cycle, :mco2][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_co2_emissions_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:climateco2cycle, :mco2], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years, default_FUND[:climateco2cycle, :mco2], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_co2_emissions_" * ssp))

## ch4 emissions

# just 2015-2300
plot(fund_years[66:351], m[:climatech4cycle, :globch4][66:351], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = "FUND x " * ssp, legend = :topleft)
plot!(fund_years[66:351], default_FUND[:climatech4cycle, :globch4][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_ch4_emissions_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:climatech4cycle, :globch4], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = "FUND x " * ssp, legend = :bottomright)
plot!(fund_years, default_FUND[:climatech4cycle, :globch4], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_ch4_emissions_" * ssp))

## n2o emissions

# just 2015-2300
plot(fund_years[66:351], m[:climaten2ocycle, :globn2o][66:351], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN)", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years[66:351], default_FUND[:climaten2ocycle, :globn2o][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_n2o_emissions_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:climaten2ocycle, :globn2o], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN)", xlabel = "Year", label = "FUND x " * ssp, legend = :bottomright)
plot!(fund_years, default_FUND[:climaten2ocycle, :globn2o], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_n2o_emissions_" * ssp))

## sf6 emissions

# just 2015-2300
plot(fund_years[66:351], m[:climatesf6cycle, :globsf6][66:351], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = "FUND x " * ssp, legend = :bottomright)
plot!(fund_years[66:351], default_FUND[:climatesf6cycle, :globsf6][66:351], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_sf6_emissions_to_2300_" * ssp))

# 1950-3000
plot(fund_years, m[:climatesf6cycle, :globsf6], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years, default_FUND[:climatesf6cycle, :globsf6], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_sf6_emissions_" * ssp))

## temperature

# 1950-3000
plot(fund_years, m[:climatedynamics, :temp], title = "FUND Global Average Temperature", ylabel = "Degrees", xlabel = "Year", label = "FUND x " * ssp, legend = :topright)
plot!(fund_years, default_FUND[:climatedynamics, :temp], label = "Default FUND")
savefig((directory * "/output/ssp/plots/" * "fund_global_avg_temp_" * ssp))