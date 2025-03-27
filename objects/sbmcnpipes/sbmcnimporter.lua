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
  storage.outputContainerID = storage.outputContainerID or "nil"
  object.setConfigParameter("outputContainerID", storage.outputContainerID)

  animator.setAnimationState("switchState", dirs[storage.fromIndex] )
  

  message.setHandler("sbmcnPipeWrench", function(messageName, isLocalEntity, input, shift)
    local _fromDir = nil
    local _toDir = nil
    if input == "primary" and not shift then
      --

    elseif input == "alt" and not shift then
      --cycle thru from offsets
      storage.fromIndex = storage.fromIndex % #offset + 1
      storage.toIndex = ((storage.fromIndex+1) % 4)+1
      fromPositionOffset = offset[storage.fromIndex]
      toPositionOffset = offset[storage.toIndex]
      animator.burstParticleEmitter("bluePoof")

    elseif input == "primary" and shift then
      --

    elseif input == "alt" and shift then
      --
    end
    _fromDir = dirs[storage.fromIndex]
    _toDir = dirs[storage.toIndex]
    animator.setAnimationState("switchState", _fromDir )
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
    else
      obj = "nil"
    end
  end
  storage.outputContainerID = obj
  object.setConfigParameter("outputContainerID", storage.outputContainerID)
end

