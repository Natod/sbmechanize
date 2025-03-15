require "/scripts/util.lua"
require "/scripts/vec2.lua"

local itemMaxTransferCount
local transferCooldown
local _counter
local offset = {
  {-1,0}, --left  / w
  {0,1},  --up    / n
  {1,0},  --right / e
  {0,-1}  --down  / s
}
local dirs = { "w", "n", "e", "s" }
local fromPositionOffset
local toPositionOffset

function init()
  object.setInteractive(false)
  animator.setParticleEmitterBurstCount("bluePoof", 10)
  animator.setParticleEmitterBurstCount("redPoof", 10)
  itemMaxTransferCount = config.getParameter("itemMaxTransferCount", 1)
  transferCooldown = config.getParameter("itemTransferTickCooldown", 1)
  _counter = 0
  pipeCheckTime = root.assetJson("/utility/sbmcnutil.config").sbmcnSettings.exporterPipeCheckTime
  _updateCounter = 0
  -- pipe direction storage
  storage.fromIndex = storage.fromIndex or 1
  storage.toIndex = storage.toIndex or 3
  fromPositionOffset = offset[storage.fromIndex]
  toPositionOffset = offset[storage.toIndex]
  --pipe output storage
  storage.outputContainerID = storage.outputContainerID or nil
  storage.outputToBG = storage.outputToBG or true

  animator.setAnimationState("switchState", dirs[storage.fromIndex] .. "." .. dirs[storage.toIndex])
  --itemMaxTransferCount = 5
  --transferCooldown = 50
  

  message.setHandler("sbmcnPipeWrench", function(messageName, isLocalEntity, input, shift)
    -- TODO - make it spawn particles that have random position and starting velocity but move up and get slower
    local _fromDir = nil
    local _toDir = nil
    if input == "primary" and not shift then
      --cycle thru from offsets
      storage.fromIndex = storage.fromIndex % #offset + 1
      if storage.fromIndex == storage.toIndex then
        storage.fromIndex = storage.fromIndex % #offset + 1
      end
      fromPositionOffset = offset[storage.fromIndex]
      animator.burstParticleEmitter("redPoof")

    elseif input == "alt" and not shift then
      --cycle thru to offsets
      storage.toIndex = storage.toIndex % #offset + 1
      if storage.fromIndex == storage.toIndex then
        storage.toIndex = storage.toIndex % #offset + 1
      end
      toPositionOffset = offset[storage.toIndex]
      animator.burstParticleEmitter("bluePoof")

    elseif input == "primary" and shift then
      storage.outputContainerID = pipeRoute(true) or storage.outputContainerID

    elseif input == "alt" and shift then
      --
    end
    _fromDir = dirs[storage.fromIndex]
    _toDir = dirs[storage.toIndex]
    animator.setAnimationState("switchState", _fromDir .. "." .. _toDir )

  end)

end

function update(dt)
  if _updateCounter <= 0 then 
    storage.outputContainerID = pipeRoute(false) or storage.outputContainerID
    _updateCounter = pipeCheckTime
  else
    _updateCounter = math.max(_updateCounter-1, 0)
  end

  --[[
  if _counter >= transferCooldown then
    local fromSlotOffset = 0
    local fromObject = world.objectAt(vec2.add(entity.position(),fromPositionOffset))
    local toObject = world.objectAt(vec2.add(entity.position(),toPositionOffset))
    
    --null check for fromObj and toObj
    if fromObject and toObject then
      local fromItems = world.containerItems(fromObject)
      -- #fromItems doesn't work here due to disconnected indices :(
      local lenFromItems = 0
      if fromItems then
        for i,_ in pairs(fromItems) do 
          lenFromItems = lenFromItems + 1 
          fromSlotOffset = tonumber(i) - 1
        end
      end
      --make sure there are items in fromObj and that toObj is a container
      if lenFromItems > 0 and world.containerAvailable(toObject, {name = "copperbar"}) then
        --fromSlotOffset = fromItems[1]
        --sb.logWarn(sb.print(fromItems))
        local itemToTransfer = world.containerItemAt(fromObject, fromSlotOffset)
        local itemTransferCount = 1
        if itemToTransfer then 
          itemTransferCount = math.min(itemToTransfer.count, itemMaxTransferCount) 
          itemToTransfer.count = itemTransferCount
        end
        local leftovers = world.containerAddItems(toObject, itemToTransfer)
        if leftovers == nil then
          world.containerConsumeAt(fromObject, fromSlotOffset, itemTransferCount)
        end
        _counter = 0
      end
    end
  else
    _counter = math.min(_counter + 1, transferCooldown)
  end
  --]]
  --sb.logWarn("itemToTransfer: " .. sb.print(itemToTransfer))
end

-- return entityID of destination container
function pipeRoute(doParticles) 
  sb.logWarn("pipeRoute run")
  local testPos = object.position()
  -- one more iteration than maxPipeLength
  for i=0, config.getParameter("maxPipeLength", 12) do
    
    -- if it's unloaded don't change status
    if world.material(testPos, (storage.outputToBG and "backround" or "foreground")) == nil then
      break
    end
    -- if it's loaded but empty clear output destination ID
    if world.material(testPos, (storage.outputToBG and "backround" or "foreground")) == false then
      storage.outputContainerID = nil
    end
  end
  world.spawnProjectile("sbmcnparticlespawner", vec2.add(object.position(), vec2.add(toPositionOffset, {0.5,0.5})))
end