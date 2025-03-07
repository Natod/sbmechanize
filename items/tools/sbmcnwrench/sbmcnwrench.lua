require "/scripts/vec2.lua"

local _update = update or function() end
local _init = init or function() end
local _uninit = uninit or function() end

local fireOffset
local inUse

function init()
  _init()

  inUse = false
  fireOffset = config.getParameter("fireOffset")
  updateAim()
  activeItem.setTwoHandedGrip(false)

  animator.setAnimationState("gun", "idle")
end

function update(dt, fireMode, shiftHeld)
  _update()
  
  updateAim()
  if fireMode == "primary" and fireMode ~= "alt" and not shiftHeld and not inUse then
    inUse = true
    fire(dt)
  end

  if fireMode ~= "primary" and fireMode ~= "alt" then
    inUse = false
  end
  
end

function uninit()
  _uninit()
end

function fire(dt)
  world.spawnProjectile(
    "deep_monsterdig",
    activeItem.ownerAimPosition(),
    activeItem.ownerEntityId(),
    nil,
    false
  )
end

function updateAim()
  local aimAngle
  local aimDirection
  aimAngle, aimDirection = activeItem.aimAngleAndDirection(fireOffset[2], activeItem.ownerAimPosition())
  activeItem.setArmAngle(aimAngle)
  activeItem.setFacingDirection(aimDirection)
end