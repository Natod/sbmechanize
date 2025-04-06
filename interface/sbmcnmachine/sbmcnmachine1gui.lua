require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

local liqData = {
    liqType = "testLiquid",
    count = 0, 
    temperature = 398
}
local counter
--the config for the current liquid
local liqConfig
local liqMax

function init()
    liqConfig = root.assetJson("/utility/sbmcnutil.config").sbmcnLiquidConfig.liquidTypes[liqData.liqType]
    counter = 0
    liqMax = world.getObjectParameter(pane.containerEntityId(), "sbmcnConfig").outLiqMaxCap
end

function update(dt)
    --
    --liqData.count = liqData.count + dt * 8
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

    local descCount = ((liqData.count < 1000) 
    and (math.floor(math.min(liqData.count, liqMax)) .. "mL" ) 
    or (math.floor(math.min(liqData.count, liqMax))/1000 .. "L"))

    local descMax = "^#5f5f5f;" .. ((liqMax < 1000) and (liqMax .. "mL" ) or (liqMax/1000 .. "L")) .. "^reset;"
    widget.setText("lblOutLiq1", descCount)
    widget.setText("lblOutLiqMax1", descMax)
    local liqCapBar = math.min(math.floor(liqData.count/liqMax * 200), 200)
    widget.setImage("outLiqCapBar1", "/interface/sbmcn-common/progbar10x200.png?crop=0;0;4;" .. liqCapBar)
    widget.setImageScale("outLiqCapBar1", 0.25)
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