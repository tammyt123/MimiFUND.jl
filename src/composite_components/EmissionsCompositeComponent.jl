include("../components/SocioEconomicComponent.jl")
include("../components/PopulationComponent.jl")
include("../components/EmissionsComponent.jl")
include("../components/GeographyComponent.jl")
include("../components/ScenarioUncertaintyComponent.jl")

@defcomposite emissionscomposite begin

    # add components

    Component(scenariouncertainty)
    Component(population)          
    Component(geography)
    Component(socioeconomic)
    Component(emissions)
    
    # resolve conflicts - these parameters are common to more than one component

    gdp90 = Parameter(emissions.gdp90, socioeconomic.gdp90)
    pop90 = Parameter(emissions.pop90, socioeconomic.pop90)
    
    # explicit calls to Variable and Parameters for later access

    # these are required to make links between this composite component and 
    # other composite components
    mco2 = Variable(emissions.mco2) # also a HOOK for connection with fair
    population_var = Variable(population.population) # can't have a component and var with same name 
    globch4 = Variable(emissions.globch4)
    globn2o = Variable(emissions.globn2o)
    globsf6 = Variable(emissions.globsf6)
    income = Variable(socioeconomic.income)
    plus = Variable(socioeconomic.plus)
    urbpop = Variable(socioeconomic.urbpop)
    cumaeei = Variable(emissions.cumaeei)
    area = Variable(geography.area)

    # make connections

    connect(population.pgrowth, scenariouncertainty.pgrowth)

    connect(socioeconomic.area, geography.area)
    connect(socioeconomic.globalpopulation, population.globalpopulation)
    connect(socioeconomic.populationin1, population.populationin1)
    connect(socioeconomic.population, population.population)
    connect(socioeconomic.pgrowth, scenariouncertainty.pgrowth)
    connect(socioeconomic.ypcgrowth, scenariouncertainty.ypcgrowth)
    connect(socioeconomic.mitigationcost, emissions.mitigationcost)

    connect(emissions.income, socioeconomic.income)
    connect(emissions.population, population.population)
    connect(emissions.forestemm, scenariouncertainty.forestemm)
    connect(emissions.aeei, scenariouncertainty.aeei)
    connect(emissions.acei, scenariouncertainty.acei)
    connect(emissions.ypcgrowth, scenariouncertainty.ypcgrowth)

end