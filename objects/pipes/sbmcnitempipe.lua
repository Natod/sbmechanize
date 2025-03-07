require "/scripts/util.lua"
require "/scripts/vec2.lua"

local itemMaxTransferCount
local transferCooldown
local _counter
local offset = {
  left = {-1,0},
  right = {1,0},
  up = {0,1},
  down = {0,-1}
}

function init()
  object.setInteractive(false)
  itemMaxTransferCount = config.getParameter("itemMaxTransferCount", 1)
  transferCooldown = config.getParameter("itemTransferTickCooldown", 1)
  _counter = 0
  --itemMaxTransferCount = 5
  --transferCooldown = 50 
end

function update(dt)
  if _counter >= transferCooldown then
    local fromSlotOffset = 0
    local fromPositionOffset = offset.left
    local toPositionOffset = offset.right
    local fromObject = world.objectAt(vec2.add(entity.position(),fromPositionOffset))
    local toObject = world.objectAt(vec2.add(entity.position(),toPositionOffset))
    
    --null check for fromObj and toObj
    if fromObject and toObject then
      local fromItems = world.containerItems(fromObject)
      -- #fromItems doesn't work here due to disconnected indices :(
      local lenFromItems = 0
      for i,_ in pairs(fromItems) do 
        lenFromItems = lenFromItems + 1 
        fromSlotOffset = tonumber(i) - 1
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
  --sb.logWarn("itemToTransfer: " .. sb.print(itemToTransfer))
end