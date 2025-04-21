require "/scripts/util.lua"

function init()
  object.setInteractive(true)

  -- item container interface shenanigans must be done server-side
  message.setHandler("sbmcnCraftItem", function(messageName, isLocalEntity, itemsToConsume, outputs)
    for i,val in pairs(itemsToConsume) do 
      world.containerConsumeAt(entity.id(), val.index, val.count)
    end
    for i,val in pairs(outputs) do   
      local leftovers = world.containerPutItemsAt(entity.id(), val.item, val.index)
      if leftovers then 
        --drop em on the floor
      end
    end
  end)

end

function update(dt)
end

function onInteraction(interactSource)
  return {
    "ShowPopup", 
    {
      title = "Activation Failed!", 
      message = "^red;EPIC FAILURE^reset;", 
      sound = "/sfx/cinematics/ship_upgrade/captain_gripe.ogg"
    } 
  }
end