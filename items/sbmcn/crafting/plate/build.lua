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
  matConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnMaterialConfig.generic[matType] or {fname = "ERROR"}

  parameters.inventoryIcon = matType .. ".png"
  local getSuffix = function(m)
    if m == "rubber" then return "Sheet" end
    if m == "glass" then return "Pane" end
    if m == "wood" then return "Plank" end
    return "Plate"
  end
  local fnameSuffix = getSuffix(matType)
  parameters.shortdescription = matConfig.fname .. " " .. fnameSuffix
  local basePrice = 10
  local priceMult = matConfig.priceMult or 1
  parameters.price = basePrice * priceMult
  local rarity = matConfig.rarity or "Common"
  parameters.rarity = rarity

  return config, parameters
end