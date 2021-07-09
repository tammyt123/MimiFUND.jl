using Pkg
Pkg.activate("development")
using MimiFUND, Mimi, CSVFiles, DataFrames, Plots

# folder where data is saved
directory = "C:/Users/TTAN/Environmental Protection Agency (EPA)/NCEE Social Cost of Carbon - General/models/Notes/Code/output/SSP Implementation"

# set constants
fund_years = collect(1950:1:3000)
param_dict = Dict("ypc_grw" => :ypcgrowth,
                "pop_grw" => :pgrowth)
gases = ["co2", "ch4", "n2o", "sf6"]
gas_param_dict = Dict("co2" => :mco2,
                    "ch4" => :globch4,
                    "n2o" => :globn2o,
                    "sf6" => :globsf6)
        
# loop
for model in ["IIASA GDP", "OECD Env-Growth"]
    for cmip6_scenario in ["SSP1-19", "SSP1-26", "SSP2-45", "SSP3-70 (Baseline)", "SSP3-LowNTCF", "SSP4-34", "SSP4-60", "SSP5-34-OS", "SSP5-85 (Baseline)"]

        ## load model
        # model to be modified with SSP inputs
        m = MimiFUND.get_model()
        run(m)

        # default FUND for comparison
        default_FUND = MimiFUND.get_model()
        run(default_FUND)

        ## choose SSP scenario based on CMIP6 scenario
        ssp_scenario = SubString(cmip6_scenario, 1, 4)

        # ---------------------------------------------------------------------------------------------
        # replace ypc and pop growth
        # ---------------------------------------------------------------------------------------------

        for param in ["ypc_grw", "pop_grw"]
            # read in SSP parameter and convert to array format
            ssp_data = DataFrame(load(directory * "/" * param * "_combined_fund_" * model * "_" * ssp_scenario * ".csv"))
            ssp_param = Matrix(ssp_data[:,2:17]) # drop first column (years), each column corresponds to a FUND region

            # set parameter
            set_param!(m, param_dict[param], ssp_param)
        end

        # run(m)

        # ---------------------------------------------------------------------------------------------
        # replace emissions
        # ---------------------------------------------------------------------------------------------

        # set ssp emissions for each gas
        for gas in gases
            
            # read in data
            ssp_em_data = DataFrame(load(directory * "/" * gas * "_global_emissions_" * cmip6_scenario * ".csv"))
            
            # assign to vector and convert units as necessary
            if gas == "co2"
                ssp_em = ssp_em_data[:,3] .* 12/44 # convert to MtC
            elseif gas == "n2o"
                ssp_em = ssp_em_data[:,3] ./ 1e3 .* 14/44 # convert to MtN
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

        # ---------------------------------------------------------------------------------------------
        # plot and compare
        # ---------------------------------------------------------------------------------------------

        ## global ypc

        # just 2015-2100
        plot(fund_years[66:151], m[:socioeconomic, :globalypc][66:151], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalypc][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_global_ypc_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:socioeconomic, :globalypc], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years, default_FUND[:socioeconomic, :globalypc], label = "Default FUND")
        savefig((directory * "/" * "fund_global_ypc_" * cmip6_scenario))

        ## global income

        # just 2015-2100
        plot(fund_years[66:151], m[:socioeconomic, :globalincome][66:151], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalincome][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_global_income_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:socioeconomic, :globalincome], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years, default_FUND[:socioeconomic, :globalincome], label = "Default FUND")
        savefig((directory * "/" * "fund_global_ypc_" * cmip6_scenario))

        ## global population

        # just 2015-2100
        plot(fund_years[66:151], m[:socioeconomic, :globalpopulation][66:151], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalpopulation][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_global_pop_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:socioeconomic, :globalpopulation], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
        plot!(fund_years, default_FUND[:socioeconomic, :globalpopulation], label = "Default FUND")
        savefig((directory * "/" * "fund_global_pop_" * cmip6_scenario))

        ## co2 emissions

        # just 2015-2100
        plot(fund_years[66:151], m[:climateco2cycle, :mco2][66:151], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:climateco2cycle, :mco2][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_co2_emissions_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:climateco2cycle, :mco2], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = cmip6_scenario, legend = :topright)
        plot!(fund_years, default_FUND[:climateco2cycle, :mco2], label = "Default FUND")
        savefig((directory * "/" * "fund_co2_emissions_" * cmip6_scenario))

        ## ch4 emissions

        # just 2015-2100
        plot(fund_years[66:151], m[:climatech4cycle, :globch4][66:151], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:climatech4cycle, :globch4][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_ch4_emissions_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:climatech4cycle, :globch4], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
        plot!(fund_years, default_FUND[:climatech4cycle, :globch4], label = "Default FUND")
        savefig((directory * "/" * "fund_ch4_emissions_" * cmip6_scenario))

        ## n2o emissions

        # just 2015-2100
        plot(fund_years[66:151], m[:climaten2ocycle, :globn2o][66:151], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN2O)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:climaten2ocycle, :globn2o][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_n2o_emissions_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:climaten2ocycle, :globn2o], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN2O)", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
        plot!(fund_years, default_FUND[:climaten2ocycle, :globn2o], label = "Default FUND")
        savefig((directory * "/" * "fund_n2o_emissions_" * cmip6_scenario))

        ## sf6 emissions

        # just 2015-2100
        plot(fund_years[66:151], m[:climatesf6cycle, :globsf6][66:151], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
        plot!(fund_years[66:151], default_FUND[:climatesf6cycle, :globsf6][66:151], label = "Default FUND")
        savefig((directory * "/" * "fund_sf6_emissions_to_2100_" * cmip6_scenario))

        # 1950-3000
        plot(fund_years, m[:climatesf6cycle, :globsf6], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = cmip6_scenario, legend = :topright)
        plot!(fund_years, default_FUND[:climatesf6cycle, :globsf6], label = "Default FUND")
        savefig((directory * "/" * "fund_sf6_emissions_" * cmip6_scenario))

        ## temperature

        # 1950-3000
        plot(fund_years, m[:climatedynamics, :temp], title = "FUND Global Average Temperature", ylabel = "Degrees", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
        plot!(fund_years, default_FUND[:climatedynamics, :temp], label = "Default FUND")
        savefig((directory * "/" * "fund_global_avg_temp_" * cmip6_scenario))

    end
end


## WITHOUT LOOP


# ## load model
# # model to be modified with SSP inputs
# m = MimiFUND.get_model()
# run(m)

# # default FUND for comparison
# default_FUND = MimiFUND.get_model()
# run(default_FUND)

# ## choose SSP scenario and model
# cmip6_scenario = "SSP2-45"
# ssp_scenario = SubString(cmip6_scenario, 1, 4)
# model = "IIASA GDP" # for pop growth and ypc growth. either IIASA GDP or OECD-Env Growth

# # ---------------------------------------------------------------------------------------------
# # replace ypc and pop growth
# # ---------------------------------------------------------------------------------------------

# # folder where data is saved
# directory = "C:/Users/TTAN/Environmental Protection Agency (EPA)/NCEE Social Cost of Carbon - General/models/Notes/Code/output"

# # param dictionary
# param_dict = Dict("ypc_grw" => :ypcgrowth,
#                 "pop_grw" => :pgrowth)

# for param in ["ypc_grw", "pop_grw"]
#     # read in SSP parameter and convert to array format
#     ssp_data = DataFrame(load(directory * "/" * param * "_combined_fund_" * model * "_" * ssp_scenario * ".csv"))
#     ssp_param = Matrix(ssp_data[:,2:17]) # drop first column (years), each column corresponds to a FUND region

#     # set parameter
#     set_param!(m, param_dict[param], ssp_param)
# end

# # run(m)

# # ---------------------------------------------------------------------------------------------
# # replace emissions
# # ---------------------------------------------------------------------------------------------

# gases = ["co2", "ch4", "n2o", "sf6"]

# gas_param_dict = Dict("co2" => :mco2,
#                     "ch4" => :globch4,
#                     "n2o" => :globn2o,
#                     "sf6" => :globsf6)

# # set ssp emissions for each gas
# for gas in gases
    
#     # read in data
#     ssp_em_data = DataFrame(load(directory * "/" * gas * "_global_emissions_" * cmip6_scenario * ".csv"))
    
#     # assign to vector and convert units as necessary
#     if gas == "co2"
#         ssp_em = ssp_em_data[:,3] .* 12/44 # convert to MtC
#     elseif gas == "n2o"
#         ssp_em = ssp_em_data[:,3] ./ 1e3 .* 14/44 # convert to MtN
#     else
#         ssp_em = ssp_em_data[:,3]
#     end

#     # combine with fund default emissions for years pre 2015 and post 2100
#     ssp_emissions_input = copy(default_FUND[:emissions, gas_param_dict[gas]])
#     ssp_emissions_input[66:151] = ssp_em # replace default fund emissions with ssp emissions for 2015-2100

#     # set parameter
#     set_param!(m, gas_param_dict[gas], ssp_emissions_input)
# end 

# run(m)

# # ---------------------------------------------------------------------------------------------
# # plot and compare
# # ---------------------------------------------------------------------------------------------

# ## global ypc

# # just 2015-2100
# plot(fund_years[66:151], m[:socioeconomic, :globalypc][66:151], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalypc][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_global_ypc_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:socioeconomic, :globalypc], title = "FUND Global Income Per Capita", ylabel = "YPC (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years, default_FUND[:socioeconomic, :globalypc], label = "Default FUND")
# savefig((directory * "/" * "fund_global_ypc_" * cmip6_scenario))

# ## global income

# # just 2015-2100
# plot(fund_years[66:151], m[:socioeconomic, :globalincome][66:151], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalincome][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_global_income_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:socioeconomic, :globalincome], title = "FUND Global Income", ylabel = "Income (1950 US Dollars)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years, default_FUND[:socioeconomic, :globalincome], label = "Default FUND")
# savefig((directory * "/" * "fund_global_ypc_" * cmip6_scenario))

# ## global population

# # just 2015-2100
# plot(fund_years[66:151], m[:socioeconomic, :globalpopulation][66:151], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:socioeconomic, :globalpopulation][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_global_pop_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:socioeconomic, :globalpopulation], title = "FUND Global Population", ylabel = "Population", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
# plot!(fund_years, default_FUND[:socioeconomic, :globalpopulation], label = "Default FUND")
# savefig((directory * "/" * "fund_global_pop_" * cmip6_scenario))

# ## co2 emissions

# # just 2015-2100
# plot(fund_years[66:151], m[:climateco2cycle, :mco2][66:151], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:climateco2cycle, :mco2][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_co2_emissions_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:climateco2cycle, :mco2], title = "FUND Global CO2 Emissions", ylabel = "Emissions (MtC)", xlabel = "Year", label = cmip6_scenario, legend = :topright)
# plot!(fund_years, default_FUND[:climateco2cycle, :mco2], label = "Default FUND")
# savefig((directory * "/" * "fund_co2_emissions_" * cmip6_scenario))

# ## ch4 emissions

# # just 2015-2100
# plot(fund_years[66:151], m[:climatech4cycle, :globch4][66:151], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:climatech4cycle, :globch4][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_ch4_emissions_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:climatech4cycle, :globch4], title = "FUND Global CH4 Emissions", ylabel = "Emissions (MtCH4)", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
# plot!(fund_years, default_FUND[:climatech4cycle, :globch4], label = "Default FUND")
# savefig((directory * "/" * "fund_ch4_emissions_" * cmip6_scenario))

# ## n2o emissions

# # just 2015-2100
# plot(fund_years[66:151], m[:climaten2ocycle, :globn2o][66:151], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN2O)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:climaten2ocycle, :globn2o][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_n2o_emissions_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:climaten2ocycle, :globn2o], title = "FUND Global N2O Emissions", ylabel = "Emissions (MtN2O)", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
# plot!(fund_years, default_FUND[:climaten2ocycle, :globn2o], label = "Default FUND")
# savefig((directory * "/" * "fund_n2o_emissions_" * cmip6_scenario))

# ## sf6 emissions

# # just 2015-2100
# plot(fund_years[66:151], m[:climatesf6cycle, :globsf6][66:151], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = cmip6_scenario, legend = :topleft)
# plot!(fund_years[66:151], default_FUND[:climatesf6cycle, :globsf6][66:151], label = "Default FUND")
# savefig((directory * "/" * "fund_sf6_emissions_to_2100_" * cmip6_scenario))

# # 1950-3000
# plot(fund_years, m[:climatesf6cycle, :globsf6], title = "FUND Global SF6 Emissions", ylabel = "Emissions (kt SF6)", xlabel = "Year", label = cmip6_scenario, legend = :topright)
# plot!(fund_years, default_FUND[:climatesf6cycle, :globsf6], label = "Default FUND")
# savefig((directory * "/" * "fund_sf6_emissions_" * cmip6_scenario))

# ## temperature

# # 1950-3000
# plot(fund_years, m[:climatedynamics, :temp], title = "FUND Global Average Temperature", ylabel = "Degrees", xlabel = "Year", label = cmip6_scenario, legend = :bottomright)
# plot!(fund_years, default_FUND[:climatedynamics, :temp], label = "Default FUND")
# savefig((directory * "/" * "fund_global_avg_temp_" * cmip6_scenario))