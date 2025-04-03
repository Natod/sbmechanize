require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

local liqData = {
    liqType = "testLiquid",
    count = 200, 
    temperature = 398
}
local counter
--the config for the current liquid
local liqConfig

function init()
    liqConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnLiquidConfig.liquidTypes[liqData.liqType]
    counter = 0
end

function update(dt)
    --
    counter = counter + dt* liqConfig.frameSpeed
    liqData.frame = math.floor(counter % liqConfig.frameCount)

    local liqItem1 = root.createItem({ 
        name = "sbmcnliqdisplay",
        parameters = {
            sbmcnLiqData = liqData
        },
        count = 1
    })
    widget.setItemSlotItem("outLiq1", liqItem1)
    --]]
    --widget.setImage("outLiq1", liqConfig.texture)
end

--[[
function createTooltip(screenPosition)
    sb.logWarn("--- ran createTooltip")
    --local child = widget.getChildAt(screenPosition)
    --if not child then return end
    --check if mouse over the member
    if not widget.inMember("outLiq1", screenPosition) then return end
    --check if it has data 
    sb.logWarn("--- it's a child")
    local data = widget.getData(child)
    if not data then return end
    sb.logWarn("--- it's got data")
    --check if it has a tooltip
    if not data.hasTooltip then return end
    sb.logWarn("--- it's got a tooltip")

    local tooltip = config.getParameter("tooltipLayout")
    tooltip.title.value = liqConfig.fname
    tooltip.description.value = liqData.count .. "mL\n" .. (liqData.temperature or liqConfig.defaultTemp) .. "K\n" .. liqConfig.desc
    sb.logWarn("--- tried to return tooltip")
    return tooltip
end

function cursorOverride(screenPosition)
    sb.logWarn("----- ran cursorOverride")
end
--]]