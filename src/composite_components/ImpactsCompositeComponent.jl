include("../components/ImpactAgricultureComponent.jl")
include("../components/ImpactBioDiversityComponent.jl")
include("../components/ImpactCardiovascularRespiratoryComponent.jl")
include("../components/ImpactCoolingComponent.jl")
include("../components/ImpactDiarrhoeaComponent.jl")
include("../components/ImpactExtratropicalStormsComponent.jl")
include("../components/ImpactDeathMorbidityComponent.jl")
include("../components/ImpactForestsComponent.jl")
include("../components/ImpactHeatingComponent.jl")
include("../components/ImpactVectorBorneDiseasesComponent.jl")
include("../components/ImpactTropicalStormsComponent.jl")
include("../components/ImpactWaterResourcesComponent.jl")
include("../components/ImpactSeaLevelRiseComponent.jl")
include("../components/ImpactAggregationComponent.jl")
include("../components/VslVmorbComponent.jl")

@defcomposite impactscomposite begin

    # add components

    Component(impactagriculture)
    Component(impactbiodiversity)
    Component(impactcardiovascularrespiratory)
    Component(impactcooling)
    Component(impactdiarrhoea)
    Component(impactextratropicalstorms)
    Component(impactforests)
    Component(impactheating)
    Component(impactvectorbornediseases)
    Component(impacttropicalstorms)
    Component(vslvmorb)
    Component(impactdeathmorbidity)
    Component(impactwaterresources)
    Component(impactsealevelrise)
    Component(impactaggregation)

    # resolve conflicts - these parameters are common to more than one component

    pop90 = Parameter(impactagriculture.pop90, impactcooling.pop90, impactdiarrhoea.pop90, impactextratropicalstorms.pop90, impactforests.pop90, impactheating.pop90, impacttropicalstorms.pop90, impactvectorbornediseases.pop90, impactwaterresources.pop90)
    co2pre = Parameter(impactagriculture.co2pre, impactextratropicalstorms.co2pre, impactforests.co2pre)
    gdp90 = Parameter(impactagriculture.gdp90, impactcooling.gdp90, impactdiarrhoea.gdp90, impactextratropicalstorms.gdp90, impactforests.gdp90, impactheating.gdp90, impacttropicalstorms.gdp90, impactvectorbornediseases.gdp90, impactwaterresources.gdp90)
    cumaeei = Parameter(impactcooling.cumaeei, impactheating.cumaeei)
    income = Parameter(impactaggregation.income, impactagriculture.income, impactbiodiversity.income, impactcooling.income, impactdiarrhoea.income, impactextratropicalstorms.income, impactforests.income, impactheating.income, impactsealevelrise.income, impacttropicalstorms.income, impactvectorbornediseases.income, impactwaterresources.income, vslvmorb.income)
    population = Parameter(impactagriculture.population, impactbiodiversity.population, impactcardiovascularrespiratory.population, impactcooling.population, impactdeathmorbidity.population, impactdiarrhoea.population, impactforests.population, impactheating.population, impactsealevelrise.population, impacttropicalstorms.population, impactvectorbornediseases.population, impactwaterresources.population, vslvmorb.population, impactextratropicalstorms.population)
    acco2 = Parameter(impactagriculture.acco2, impactforests.acco2, impactextratropicalstorms.acco2)
    temp = Parameter(impactagriculture.temp, impactbiodiversity.temp, impactcardiovascularrespiratory.temp, impactcooling.temp, impactforests.temp, impactheating.temp, impactvectorbornediseases.temp, impactwaterresources.temp)
    
    # explicit calls to Variable and Parameter for later access

    # these are required to make links between this composite component and 
    # other composite components
    landloss = Variable(impactsealevelrise.landloss)
    enter = Variable(impactsealevelrise.enter)
    leave = Variable(impactsealevelrise.leave)
    dead = Variable(impactdeathmorbidity.dead)
    eloss = Variable(impactaggregation.eloss)
    sloss = Variable(impactaggregation.sloss)

    connect(impactdeathmorbidity.vsl, vslvmorb.vsl)
    connect(impactdeathmorbidity.vmorb, vslvmorb.vmorb)
    connect(impactdeathmorbidity.dengue, impactvectorbornediseases.dengue)
    connect(impactdeathmorbidity.schisto, impactvectorbornediseases.schisto)
    connect(impactdeathmorbidity.malaria, impactvectorbornediseases.malaria)
    connect(impactdeathmorbidity.cardheat, impactcardiovascularrespiratory.cardheat)
    connect(impactdeathmorbidity.cardcold, impactcardiovascularrespiratory.cardcold)
    connect(impactdeathmorbidity.resp, impactcardiovascularrespiratory.resp)
    connect(impactdeathmorbidity.diadead, impactdiarrhoea.diadead)
    connect(impactdeathmorbidity.hurrdead, impacttropicalstorms.hurrdead)
    connect(impactdeathmorbidity.extratropicalstormsdead, impactextratropicalstorms.extratropicalstormsdead)
    connect(impactdeathmorbidity.diasick, impactdiarrhoea.diasick)

    connect(impactaggregation.heating, impactheating.heating)
    connect(impactaggregation.cooling, impactcooling.cooling)
    connect(impactaggregation.agcost, impactagriculture.agcost)
    connect(impactaggregation.species, impactbiodiversity.species)
    connect(impactaggregation.water, impactwaterresources.water)
    connect(impactaggregation.hurrdam, impacttropicalstorms.hurrdam)
    connect(impactaggregation.extratropicalstormsdam, impactextratropicalstorms.extratropicalstormsdam)
    connect(impactaggregation.forests, impactforests.forests)
    connect(impactaggregation.drycost, impactsealevelrise.drycost)
    connect(impactaggregation.protcost, impactsealevelrise.protcost)
    connect(impactaggregation.entercost, impactsealevelrise.entercost)
    connect(impactaggregation.deadcost, impactdeathmorbidity.deadcost)
    connect(impactaggregation.morbcost, impactdeathmorbidity.morbcost)
    connect(impactaggregation.wetcost, impactsealevelrise.wetcost)
    connect(impactaggregation.leavecost, impactsealevelrise.leavecost)

end