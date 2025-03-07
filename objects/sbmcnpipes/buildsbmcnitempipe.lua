require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)

  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then
      return parameters[keyName]
    elseif config[keyName] ~= nil then
      return config[keyName]
    else
      return defaultValue
    end
  end
  local cooldown = configParameter("itemTransferTickCooldown", 0) + 1
  parameters.description = "Transfer speed: " .. 
  configParameter("itemTransferCount", 1) .. " item/" .. 
  ((cooldown == 1) and "" or cooldown) .. "t\n"

  return config, parameters
end
