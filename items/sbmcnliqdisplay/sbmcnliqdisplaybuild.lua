function build(directory, config, parameters, level, seed)

  local configParameter = function(key, default)
    if parameters[key] ~= nil then
      return parameters[key]
    elseif config[key] ~= nil then
      return config[key]
    else 
      return default
    end
  end
  
  local liqData = configParameter("sbmcnLiqData",{})

  --the config for the current liquid
  local liqConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnLiquidConfig.liquidTypes[liqData.liqType]
  
  local shortdesc = liqConfig.fname
  parameters.shortdescription = shortdesc

  local desc = liqData.count .. "mL\n" .. (liqData.temperature or liqConfig.defaultTemp) .. "K\n" .. liqConfig.desc
  parameters.description = desc

  parameters.inventoryIcon = liqConfig.texture .. ":" .. liqData.frame
  parameters.category = ( ((liqConfig.state == "gas") and "sbmcngas") or "liquid" )
  

  return config, parameters
end