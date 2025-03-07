require "/scripts/util.lua"
require "/scripts/vec2.lua"

local itemMaxTransferCount
local transferCooldown
local _counter
local offset = {
  {-1,0}, --left
  {0,1},  --up
  {1,0},  --right
  {0,-1}  --down
}
local fromPositionOffset
local toPositionOffset

function init()
  object.setInteractive(false)
  itemMaxTransferCount = config.getParameter("itemMaxTransferCount", 1)
  transferCooldown = config.getParameter("itemTransferTickCooldown", 1)
  _counter = 0
  storage.fromIndex = storage.fromIndex or 1
  storage.toIndex = storage.toIndex or 3
  fromPositionOffset = offset[storage.fromIndex]
  toPositionOffset = offset[storage.toIndex]
  --itemMaxTransferCount = 5
  --transferCooldown = 50
  object.setConfigParameter("orientations", {
    {
      image = "singleIO/w.n.png",
      imagePosition = {0,0},
      spaceScan = 0.1,
      anchors = {}
    }
  })

  message.setHandler("sbmcnPipeWrench", function(messageName, isLocalEntity, input, shift)

    if input == "primary" and not shift then
      --cycle thru from offsets
      storage.fromIndex = storage.fromIndex % #offset + 1
      if storage.fromIndex == storage.toIndex then
        storage.fromIndex = storage.fromIndex % #offset + 1
      end
      fromPositionOffset = offset[storage.fromIndex]

    elseif input == "alt" and not shift then
      --cycle thru to offsets
      storage.toIndex = storage.toIndex % #offset + 1
      if storage.fromIndex == storage.toIndex then
        storage.toIndex = storage.toIndex % #offset + 1
      end
      toPositionOffset = offset[storage.toIndex]

    elseif input == "primary" and shift then
      --
    elseif input == "alt" and shift then
      --
    end
  end)

end

function update(dt)
  if _counter >= transferCooldown then
    local fromSlotOffset = 0
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