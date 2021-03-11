include("../components/ClimateCO2CycleComponent.jl")
include("../components/ClimateCH4CycleComponent.jl")
include("../components/ClimateN2OCycleComponent.jl")
include("../components/ClimateSF6CycleComponent.jl")
include("../components/ClimateForcingComponent.jl")
include("../components/ClimateDynamicsComponent.jl")
include("../components/BioDiversityComponent.jl")
include("../components/ClimateRegionalComponent.jl")
include("../components/OceanComponent.jl")

@defcomposite climatecomposite begin 

    # add components

    Component(climateco2cycle)
    Component(climatech4cycle)
    Component(climaten2ocycle)
    Component(climatesf6cycle)
    Component(climateforcing)
    Component(climatedynamics)
    Component(biodiversity)
    Component(climateregional)
    Component(ocean)
   
    # resolve conflicts - these parameters are common to more than one component

    n2opre = Parameter(climateforcing.n2opre, climaten2ocycle.n2opre)
    ch4pre = Parameter(climatech4cycle.ch4pre, climateforcing.ch4pre)
    sf6pre = Parameter(climateforcing.sf6pre, climatesf6cycle.sf6pre)
    
    # explicit calls to Variable and Parameters for later access

    # these are required to make links between this composite component and 
    # other composite components
    acco2 = Variable(climateco2cycle.acco2)
    nospecies = Variable(biodiversity.nospecies)
    regtmp = Variable(climateregional.regtmp)
    regstmp = Variable(climateregional.regstmp)
    sea = Variable(ocean.sea)
    # both of these use temp but they are different variables, so assign them
    # explicitly different names
    climatedynamics_temp_var = Variable(climatedynamics.temp) 
    climateregional_temp_var = Variable(climateregional.temp)

    # HOOKS for connection with FAIR - TODO we cannot expose these without then
    # setting them ... because normally these are already connected so doing this
    # creates a new exogenous parameter that is then never set
    temp = Parameter(climateco2cycle.temp, biodiversity.temp, ocean.temp) 
    inputtemp = Parameter(climateregional.inputtemp)

    # make connections

    connect(climateco2cycle.temp, climatedynamics.temp)

    connect(climateforcing.acco2, climateco2cycle.acco2)
    connect(climateforcing.acch4, climatech4cycle.acch4)
    connect(climateforcing.acn2o, climaten2ocycle.acn2o)
    connect(climateforcing.acsf6, climatesf6cycle.acsf6)

    connect(climatedynamics.radforc, climateforcing.radforc)

    connect(climateregional.inputtemp, climatedynamics.temp)

    connect(biodiversity.temp, climatedynamics.temp)

    connect(ocean.temp, climatedynamics.temp)

end