require "/scripts/util.lua"

function init()
  object.setInteractive(true)

end

function update(dt)

end

function onInteraction(interactSource)
  return {
    "ShowPopup", 
    {
      title = "Activation Failed!", 
      message = string.format("^red;Epic failure: %s.", "a"), 
      sound = "/sfx/cinematics/ship_upgrade/captain_gripe.ogg"
    } 
  }
end