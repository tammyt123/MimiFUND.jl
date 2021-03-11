connect_param!(m, :emissionscomponent, :landloss, :impactscomposite, :landloss)

connect_param!(m, :emissionscomposite, :pgrowth, :emissionscomposite, :pgrowth)
connect_param!(m, :emissionscomposite, :enter, :impactscomposite, :enter)
connect_param!(m, :emissionscomposite, :leave, :impactscomposite, :leave)
connect_param!(m, :emissionscomposite, :dead, :impactscomposite, :dead)

connect_param!(m, :emissionscomposite, :area, :emissionscomponent, :area)
connect_param!(m, :emissionscomposite, :globalpopulation, :emissionscomposite, :globalpopulation)
connect_param!(m, :emissionscomposite, :populationin1, :emissionscomposite, :populationin1)
connect_param!(m, :emissionscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :emissionscomposite, :pgrowth, :emissionscomposite, :pgrowth)
connect_param!(m, :emissionscomposite, :ypcgrowth, :emissionscomposite, :ypcgrowth)
connect_param!(m, :emissionscomposite, :eloss, :impactscomposite, :eloss)
connect_param!(m, :emissionscomposite, :sloss, :impactscomposite, :sloss)
connect_param!(m, :emissionscomposite, :mitigationcost, :emissionscomposite, :mitigationcost)

connect_param!(m, :emissionscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :emissionscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :emissionscomposite, :forestemm, :emissionscomposite, :forestemm)
connect_param!(m, :emissionscomposite, :aeei, :emissionscomposite, :aeei)
connect_param!(m, :emissionscomposite, :acei, :emissionscomposite, :acei)
connect_param!(m, :emissionscomposite, :ypcgrowth, :emissionscomposite, :ypcgrowth)

connect_param!(m, :climatecomposite, :mco2, :emissionscomposite, :mco2)

connect_param!(m, :climatecomposite, :globch4, :emissionscomposite, :globch4)

connect_param!(m, :climatecomposite, :globn2o, :emissionscomposite, :globn2o)

connect_param!(m, :climatecomposite, :temp, :climatecomposite, :temp)

connect_param!(m, :climatecomponent, :globsf6, :emissionscomposite, :globsf6)

connect_param!(m, :climatecomposite, :acco2, :climatecomposite, :acco2)
connect_param!(m, :climatecomposite, :acch4, :climatecomposite, :acch4)
connect_param!(m, :climatecomposite, :acn2o, :climatecomposite, :acn2o)
connect_param!(m, :climatecomposite, :acsf6, :climatecomponent, :acsf6)

connect_param!(m, :climatecomposite, :radforc, :climatecomposite, :radforc)

connect_param!(m, :climatecomposite, :inputtemp, :climatecomposite, :temp)

connect_param!(m, :climatecomposite, :temp, :climatecomposite, :temp)

connect_param!(m, :climatecomposite, :temp, :climatecomposite, :temp)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :acco2, :climatecomposite, :acco2)

connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :nospecies, :climatecomposite, :nospecies)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :plus, :emissionscomposite, :plus)
connect_param!(m, :impactscomposite, :urbpop, :emissionscomposite, :urbpop)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :cumaeei, :emissionscomposite, :cumaeei)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :regtmp, :climatecomposite, :regtmp)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :acco2, :climatecomposite, :acco2)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :acco2, :climatecomposite, :acco2)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)
connect_param!(m, :impactscomposite, :cumaeei, :emissionscomposite, :cumaeei)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :regstmp, :climatecomposite, :regstmp)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)

connect_param!(m, :impactscomposite, :vsl, :impactscomposite, :vsl)
connect_param!(m, :impactscomposite, :vmorb, :impactscomposite, :vmorb)
connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :dengue, :impactscomposite, :dengue)
connect_param!(m, :impactscomposite, :schisto, :impactscomposite, :schisto)
connect_param!(m, :impactscomposite, :malaria, :impactscomposite, :malaria)
connect_param!(m, :impactscomposite, :cardheat, :impactscomposite, :cardheat)
connect_param!(m, :impactscomposite, :cardcold, :impactscomposite, :cardcold)
connect_param!(m, :impactscomposite, :resp, :impactscomposite, :resp)
connect_param!(m, :impactscomposite, :diadead, :impactscomposite, :diadead)
connect_param!(m, :impactscomposite, :hurrdead, :impactscomposite, :hurrdead)
connect_param!(m, :impactscomposite, :extratropicalstormsdead, :impactscomposite, :extratropicalstormsdead)
connect_param!(m, :impactscomposite, :diasick, :impactscomposite, :diasick)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :temp, :climatecomposite, :temp)

connect_param!(m, :impactscomposite, :population, :emissionscomposite, :population)
connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :sea, :climatecomposite, :sea)
connect_param!(m, :impactscomposite, :area, :emissionscomponent, :area)

connect_param!(m, :impactscomposite, :income, :emissionscomposite, :income)
connect_param!(m, :impactscomposite, :heating, :impactscomposite, :heating)
connect_param!(m, :impactscomposite, :cooling, :impactscomposite, :cooling)
connect_param!(m, :impactscomposite, :agcost, :impactscomposite, :agcost)
connect_param!(m, :impactscomposite, :species, :impactscomposite, :species)
connect_param!(m, :impactscomposite, :water, :impactscomposite, :water)
connect_param!(m, :impactscomposite, :hurrdam, :impactscomposite, :hurrdam)
connect_param!(m, :impactscomposite, :extratropicalstormsdam, :impactscomposite, :extratropicalstormsdam)
connect_param!(m, :impactscomposite, :forests, :impactscomposite, :forests)
connect_param!(m, :impactscomposite, :drycost, :impactscomposite, :drycost)
connect_param!(m, :impactscomposite, :protcost, :impactscomposite, :protcost)
connect_param!(m, :impactscomposite, :entercost, :impactscomposite, :entercost)
connect_param!(m, :impactscomposite, :deadcost, :impactscomposite, :deadcost)
connect_param!(m, :impactscomposite, :morbcost, :impactscomposite, :morbcost)
connect_param!(m, :impactscomposite, :wetcost, :impactscomposite, :wetcost)
connect_param!(m, :impactscomposite, :leavecost, :impactscomposite, :leavecost)