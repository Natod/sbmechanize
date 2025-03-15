require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
  local sbmcnUtil = root.assetJson("/utility/sbmcnutil.config")

  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end

  local sbmcnMatTable = sbmcnUtil.sbmcnMaterialConfig.itemExporter[configParameter("sbmcnMaterial", "default")]

  local cooldown = configParameter("itemTransferTickCooldown", 0) + 1
  local desc = config.description
  local shortdesc = config.shortdescription

  parameters.description = "Transfer Speed: " .. 
  configParameter("itemTransferCount", 1) .. " item/" .. 
  ((cooldown == 1) and "" or cooldown) .. "t\n" .. 
  "Max Pipe Length: " .. configParameter("maxPipeLength", 12) .. "\n" ..
  desc

  parameters.shortdescription = sbmcnMatTable.fname .. " " .. shortdesc

  return config, parameters
end
