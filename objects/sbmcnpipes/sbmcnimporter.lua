require "/scripts/vec2.lua"

local _updateCounter
local offset = {
  {-1,0}, --left  / w
  {0,1},  --up    / n
  {1,0},  --right / e
  {0,-1}  --down  / s
}
local dirs = { "w", "n", "e", "s" }
local fromPositionOffset
local toPositionOffset
local pipeCheckTime

function init()
  object.setInteractive(false)
  animator.setParticleEmitterBurstCount("bluePoof", 10)
  animator.setParticleEmitterBurstCount("redPoof", 10)
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
      -- updateDest()

    elseif input == "alt" and shift then
      --
    end
    _fromDir = dirs[storage.fromIndex]
    _toDir = dirs[storage.toIndex]
    animator.setAnimationState("switchState", _fromDir .. "." .. _toDir )
    updateDest()

  end)

end


function update(dt)
  if _updateCounter <= 0 then 
    updateDest()
    _updateCounter = pipeCheckTime
  else
    _updateCounter = math.max(_updateCounter-1, 0)
  end

  --if storage.outputContainerID then sb.logWarn("Importer: " .. storage.outputContainerID) end
end

function updateDest()
  local obj = world.objectAt(vec2.add(object.position(), toPositionOffset))
  --check if there's an object
  if obj then 
    -- check if it's storage
    if world.containerAvailable(obj, {name = "copperbar"}) then
      storage.outputContainerID = obj
      object.setConfigParameter("outputContainerID", obj)
    else
      storage.outputContainerID = nil
    end
  else
    storage.outputContainerID = nil
  end
end

