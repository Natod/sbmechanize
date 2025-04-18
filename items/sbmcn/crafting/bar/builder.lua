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

  local matType = configParameter("sbmcnData", {materialType = "default"}).materialType
  if matType == "default" then return config, parameters end
  matConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnMaterialConfig.generic[matType] --or {fname = "ERROR"}
  if matType == nil then return end
  
  parameters.inventoryIcon = matType .. ".png"
  parameters.shortdescription = matConfig.fname .. " Bar"
  local basePrice = 8
  local priceMult = matConfig.priceMult or 1
  parameters.price = math.floor(basePrice * priceMult)
  local rarity = matConfig.rarity or "Common"
  parameters.rarity = rarity

  return config, parameters
end