##TODO: CHECK UNITS

const MolarEnergyUnits = Unitful.Units{U,(Unitful.𝐍^-1)*Unitful.𝐌*Unitful.𝐋^2/Unitful.𝐓^2,A} where A where U
const MassEnergyUnits = Unitful.Units{U,Unitful.𝐋^2/Unitful.𝐓^2,A} where A where U
const MolUnits = Unitful.Units{U,Unitful.𝐍,A} where A where U
const INTENSIVE_ENERGY_UNITS = (Helmholtz,Gibbs,InternalEnergy,Enthalpy) 

#Entropy
const EntropyUnits = Unitful.Units{U,(Unitful.𝚯^-1)*Unitful.𝐌*Unitful.𝐋^2/Unitful.𝐓^2,A} where A where U
const MassEntropyUnits = Unitful.Units{U,(Unitful.𝚯^-1)*Unitful.𝐋^2/Unitful.𝐓^2,A} where A where U
const MolEntropyUnits = Unitful.Units{U,(Unitful.𝐍^-1)*(Unitful.𝚯^-1)*Unitful.𝐌*Unitful.𝐋^2/Unitful.𝐓^2,A} where A where U

#volume and density units
const MolDensityUnits = Unitful.Units{U,((Unitful.𝐋)^-3)*(Unitful.𝐍),A} where A where U
const MassDensityUnits = Unitful.Units{U,((Unitful.𝐋)^-3)*(Unitful.𝐌),A} where A where U
const MassVolumeUnits = Unitful.Units{U,((Unitful.𝐋)^3)/(Unitful.𝐌),A} where A where U
const MolVolumeUnits = Unitful.Units{U,((Unitful.𝐋)^3)/(Unitful.𝐍),A} where A where U

function convert_unit(from::T,to::T,val::N) where {T,N<:Number}
    return val
end

function convert_unit(from::T1,to::T2,val::N) where {T1,T2,N<:Number}
    return Unitful.ustrip(Unitful.uconvert(to,val*from))
end

function convert_unit(from::T1,to::T2,val::N) where {T1,T2,N<:Unitful.Quantity}
    return Unitful.ustrip(Unitful.uconvert(to,val))
end

function pressure(model::FromState,props::ThermodynamicState,unit::T=u"Pa",mw=nothing) where T <: Unitful.PressureUnits
    sval = throw_get_spec(Pressure(),props)
    val = to_spec(props,sval,nothing,Pressure())
    return convert_unit(u"Pa",unit,val)
end

function temperature(model::FromState,props::ThermodynamicState,unit::T=u"K",mw=nothing) where T <: Unitful.TemperatureUnits
    sval = throw_get_spec(Temperature(),props)
    val = to_spec(props,sval,nothing,Temperature())
    return convert_unit(u"K",unit,val)
end

function mass(model::FromState,props::ThermodynamicState,unit::T=u"kg",mw=nothing) where T <: Unitful.MassUnits
    val = mass2(props,mw)
    return convert_unit(u"kg",unit,val)
end

function moles(model::FromState,props::ThermodynamicState,unit::T=u"mol",mw=nothing) where T <: MolUnits
    val = moles2(props,mw)
    return convert_unit(u"mol",unit,val)
end

function molar_mass(model::FromState,props::ThermodynamicState,unit=u"kg/mol",mw=nothing)
    val = kg_per_mol2(props,mw)
    return convert_unit(u"kg/mol",unit,val)
end

for (op,sp) in zip((:mol_helmholtz, :mol_gibbs, :mol_internal_energy, :mol_enthalpy),INTENSIVE_ENERGY_UNITS)
    @eval begin 
        function $op(model::FromState,props::ThermodynamicState,unit::T=u"J/mol",mw=nothing) where T <: MolarEnergyUnits
            sval = throw_get_spec($sp,props)
            val = to_spec(props,sval,mw,MOLAR())
            return convert_unit(u"J/mol",unit,val)
        end
    end
end

for (op,sp) in zip((:mass_helmholtz, :mass_gibbs, :mass_internal_energy, :mass_enthalpy),INTENSIVE_ENERGY_UNITS)
    @eval begin 
        function $op(model::FromState,props::ThermodynamicState,unit::T=u"J/kg",mw=nothing) where T <: MassEnergyUnits
            sval = throw_get_spec($sp,props)
            val = to_spec(props,sval,mw,MASS())
            return convert_unit(u"J/kg",unit,val)
        end    
    end
end

for (op,sp) in zip((:total_helmholtz, :total_gibbs, :total_internal_energy, :total_enthalpy),INTENSIVE_ENERGY_UNITS)
    @eval begin 
            function $op(model::FromState,props::ThermodynamicState,unit::T=u"J",mw=nothing) where T <: Unitful.EnergyUnits
                sval = throw_get_spec($sp,props)
                val = to_spec(props,sval,mw,TOTAL())
                return convert_unit(u"J",unit,val)
            end
    end
end

function mol_entropy(model::FromState,props::ThermodynamicState,unit::T=u"J/(K*mol)",mw=nothing) where T <: MolEntropyUnits
    sval = throw_get_spec(Entropy,props)
    val = to_spec(props,sval,mw,MOLAR())
    return convert_unit(u"J/(mol*K)",unit,val)
end

function mass_entropy(model::FromState,props::ThermodynamicState,unit::T=u"J/(K*kg)",mw=nothing) where T <: MassEntropyUnits
    sval = throw_get_spec(Entropy,props)
    val = to_spec(props,sval,mw,MASS())
    return convert_unit(u"J/(kg*K)",unit,val)
end

function total_entropy(model::FromState,props::ThermodynamicState,unit::T=u"J/(K)",mw=nothing) where T <: EntropyUnits
    sval = throw_get_spec(Entropy,props)
    val = to_spec(props,sval,mw,TOTAL())
    return convert_unit(u"J/(K)",unit,val)
end

function total_volume(model::FromState,props::ThermodynamicState,unit::T=u"m^3",mw=nothing) where T <: Unitful.VolumeUnits
    sval = throw_get_spec(VolumeAmount,props)
    val = to_spec(props,sval,mw,VolumeAmount{TOTAL,VOLUME}())
    return convert_unit(u"m^3",unit,val)

end

function mass_volume(model::FromState,props::ThermodynamicState,unit::T=u"(m^3)/kg",mw=nothing) where T <: MassVolumeUnits
    sval = throw_get_spec(VolumeAmount,props)
    val = to_spec(props,sval,mw,VolumeAmount{MASS,VOLUME}())
    return convert_unit(u"m^3/kg",unit,val)
end

function mol_volume(model::FromState,props::ThermodynamicState,unit::T=u"(m^3)/mol",mw=nothing) where T <: MolVolumeUnits
    sval = throw_get_spec(VolumeAmount,props)
    val = to_spec(props,sval,mw,VolumeAmount{MOLAR,VOLUME}())
    return convert_unit(u"m^3/mol",unit,val)

end

function mass_density(model::FromState,props::ThermodynamicState,unit::T=u"kg/m^3",mw=nothing) where T <: MassDensityUnits
    sval = throw_get_spec(VolumeAmount,props)
    val = to_spec(props,sval,mw,VolumeAmount{MASS,DENSITY}())
    return convert_unit(u"kg/m^3",unit,val)
end

function mol_density(model::FromState,props::ThermodynamicState,unit::T=u"mol/m^3",mw=nothing) where T <: MolDensityUnits
    sval = throw_get_spec(VolumeAmount,props)
    val = to_spec(props,sval,mw,VolumeAmount{MOLAR,DENSITY}())
    return convert_unit(u"mol/m^3",unit,val)

end

function mol_fraction(model::FromState,props::ThermodynamicState,unit,mw=nothing)
    val = to_spec_compounds(props,mw,MaterialCompounds{MOLAR,FRACTION}())
    return val
end

function mass_fraction(model::FromState,props::ThermodynamicState,unit,mw=nothing)
    val = to_spec_compounds(props,mw,MaterialCompounds{MASS,FRACTION}())
    return val   
end

function mol_number(model::FromState,props::ThermodynamicState,unit::T,mw=nothing) where T <: MolUnits
    val = to_spec_compounds(props,mw,MaterialCompounds{MOLAR,TOTAL_AMOUNT}())
    return convert_unit.(u"mol",unit,val)

end

function mass_number(model::FromState,props::ThermodynamicState,unit::T,mw=nothing) where T <: Unitful.MassUnits
    val = to_spec_compounds(props,mw,MaterialCompounds{MASS,TOTAL_AMOUNT}())
    return convert_unit.(u"kg",unit,val)
end

function options(model::FromState,props::ThermodynamicState)
    hasval = has_spec(Options(),props)
    if !hasval
        return (;)
    else
        return value(get_spec(Options(),props))
    end
end

function phase(model::FromState,props::ThermodynamicState)::Symbol
    hasval = has_spec(PhaseTag(),props)
    if !hasval
        return :unspecified
    else
        return value(get_spec(PhaseTag(),props))
    end
end

function quality(model::FromState,props::ThermodynamicState)
    hasval = has_spec(VaporFraction(),props)
    if !hasval
        return NaN
    else
        return value(get_spec(VaporFraction(),props))
    end
end




