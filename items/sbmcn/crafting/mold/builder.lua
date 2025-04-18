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

  local moldType = configParameter("sbmcnData", {materialType = "default"}).moldType
  if moldType == "default" then return config, parameters end
  if moldType == nil then return end
  matConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnMaterialConfig.generic[moldType] --or {fname = "ERROR"}
  if matConfig == nil then return end
  
  parameters.inventoryIcon = moldType .. ".png"
  parameters.shortdescription = matConfig.fname .. " Mold"

  return config, parameters
end