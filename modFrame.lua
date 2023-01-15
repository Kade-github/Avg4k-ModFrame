--[[
    This is obviously inspired by mirin template from NotITG, so go check them out :) 
    https://xerool.github.io/notitg-mirin/

    oh and side note, probably don't touch this file unless you know what you are doing.

    consider this the "don't touch kiddo" warning lmao
]]--


-- Helper
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

ModFrame = {}

plr = 0

playfields = {
    0
}

drawsize = {
    {-8, 8} -- plr 1
}

-- setup arrays

--[[
    Structure

    name
    value
    playfieldValues
    func
    setBack
    useColumns
    columns
    default
    
]]--


ModFrame.mods = {

}

--[[
    Structure

    modName
    startValue - if nil, assign the current value as that start value
    endValue
    tweenStart
    tweenLen
    easing
    complete
    column
    playfield

]]

ModFrame.activeMods = {

}


--[[
    Structure

    shaderName
    startValue - if nil, assign the current value as that start value
    endValue
    tweenStart
    tweenLen
    uniform
    easing
    complete

]]

ModFrame.shaderMods = {

}

--[[
    Structure

    shaderName
    uniforms (array)
]]--

ModFrame.shaders = {

}

--[[
    defineMod defines a mod that you can then set the value to using setModValue/setModValueColumn

    defineMod{'modName', function(beat, perc, me, plr)
            -- Your code
            -- "me" is simply a reference to your custom mod, which contains a .value property you can set
        end, false, false, 0}

    The 0 is the default value.

    Setting the function to "nil" will make it automaticly set the "value" property

    The 2nd to last argument is for Average4K and if the mod you defined is a Built-In mod, as setting that argument to true
    will try to set its mod property in game. It will do nothing if it was not found though.

    You also have a columns array, which is what the last arugmnet is specifying. Its if this mod affects only one column.
    If you set this to true, the ModFramework will try to read the columns array and set each columns property.

    This is probably only good for Built-In mods so you should probably ignore it.

    By the way, the defaults for the last 2 arguments will default to false if set to nil. 
    So you can completely ignore them if you want. Just wanted to explain it :)
]]--
function defineMod(n)
    local m = {}
    m.name = n[1]
    m.func = n[2]
    m.setBack = n[3]
    m.useColumns = n[4]
    m.value = n[5]
    m.playfieldValues = {}
    m.columns = {}
    m.default = m.value
    table.insert(ModFrame.mods,m)
end

--[[
    Both shaderVert and shaderFrag could be "NULL", which means they go to the default.
    shader{'shaderName','shaderVert', 'shaderFrag', {{'uniform1', 0}}}
]]--

function shader(s)
    createShader(s[1], s[2], s[3])
    for index, u in ipairs(s[4]) do
        setShaderUniform(s[1], u[1], u[2])
    end
    table.insert(ModFrame.shaders, s)
end

function shaderTarget(spriteName, shader)
    applyShader(shader, spriteName)
end

function addPlayer()
    table.insert(playfields, createPlayfield() + 1)
    table.insert(drawsize, {-8,8})
end

--[[
    Smootly interperlates to an end value from a start value.

    me{
        modName = 'amovex',
        startValue = nil, -- Get current value
        endValue = 250,
        tweenStart = 1,
        tweenLen = 4,
        easing = 'outcubic',
        column = -1, -- no column
        add = false
    }

    Note: Do not add the "modName =" etc.

    A real example looks smth like this:
    me{'amovex',0,250,3,1,'outcubic',-1}
]]--
function me(n)
    local m = {}
    m.modName = n[1]
    m.startValue = n[2]
    m.endValue = n[3]
    m.tweenStart = n[4]
    m.tweenLen = n[5]
    m.easing = n[6]
    m.column = n[7]
    if m.column == nil then
        m.column = -1
    end
    if n[8] == nil then
        m.additive = false
    else
        m.additive = n[8]
    end
    m.playfield = plr

    table.insert(ModFrame.activeMods,m)
end

--[[
    Smootly interperlates to an end value from a start value on a shader.

    Example (on beat 4, over 1 beats in length. set the value of aberration on the aberration shader to 1 from 0):
    se{'aberration',0,1,4,1,'aberration','outCubic'}
]]--

function se(n)
    local m = {}
    m.shader = n[1]
    m.startValue = n[2]
    m.endValue = n[3]
    m.tweenStart = n[4]
    m.tweenLen = n[5]
    m.uniform = n[6]
    m.easing = n[7]
    m.complete = false
    

    table.insert(ModFrame.shaderMods,m)
end

--[[
    Immediately sets a mods value

    ModFrame.set{
        modName = 'amovex',
        endValue = 250,
        tweenStart = 1,
        column = -1 -- no column
    }

    Note: Do not add the "modName =" etc.

    A real example looks smth like this:
    set{'aconfusion',0,1,-1}
]]--

function set(n)
    local m = {}
    m.modName = n[1]
    m.endValue = n[2]
    m.tweenStart = n[3]
    m.column = n[4]
    if m.column == nil then
        m.column = -1
    end
    m.tweenLen = 0
    m.startValue = nil
    m.playfield = plr
    m.easing = 'linear'
    table.insert(ModFrame.activeMods,m)
end

function ModFrame.create()
    defineMod{'drunk', nil, true, false, 0}
    defineMod{'drunkCol', nil, true, true, 0}
    defineMod{'tipsy', nil, true, false, 0}
    defineMod{'tipsyCol', nil, true, true, 0}
    defineMod{'wave', nil, true, false, 0}
    defineMod{'waveCol', nil, true, true, 0}
    defineMod{'aconfusion', nil, true, false, 0}
    defineMod{'confusion', nil, true, true, 0}
    defineMod{'amovex', nil, true, false, 0}
    defineMod{'movex', nil, true, true, 0}
    defineMod{'amovey', nil, true, false, 0}
    defineMod{'movey', nil, true, true, 0}
    defineMod{'reverse', nil, true, true, 0}
    defineMod{'dizzy', nil, true, false, 0}
    defineMod{'dizzyCol', nil, true, true, 0}
    defineMod{'mini', nil, true, false, 0.5}
    defineMod{'miniCol', nil, true, true, 0.5}
    defineMod{'stealthWhite', nil, true, true, 0}
    defineMod{'stealthOpacity', nil, true, true, 1}
    defineMod{'stealthReceptorOpacity', nil, true, true, 1}
    defineMod{'pathAlpha', nil, true, false, 0}
    defineMod{'pathDensity', nil, true, false, 1}
    defineMod{'cmod', function(beat, perc, me, plr)
        setScrollSpeed(perc, plr)
    end, false, false, config.scrollSpeed}
    defineMod{'hidden',function(beat, perc, me, plr)
        drawsize[plr + 1] = {1 * perc,drawsize[plr + 1][2]}
    end, false, false, 0}
    defineMod{'hiddenin',function(beat, perc, me, plr)
        drawsize[plr + 1] = {drawsize[plr + 1][1],1 / perc}
    end, false, false, 0}

    consolePrint("ModFrame Loaded! Created by Kade :)")
end

function getModValue(name)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            return value.value
        end
    end
    return 0
end


function setModValue(name, v)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            value.value = v
        end
    end
end

function setModValueColumn(name, column, pid, v)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            if value.columns[pid + 1] == nil then
                value.columns[pid + 1] = {}
            end
            value.columns[pid + 1][column] = {value = v}
        end
    end
end

function getModValue(name, v)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            return value.value 
        end
    end
    return nil
end

function getModValueColumn(name, column, pid, v)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            if value.columns[pid + 1] == nil then
                value.columns[pid + 1] = {}
            end
            return value.columns[pid + 1][column]
        end
    end
    return nil
end

function getMod(name)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            return value
        end
    end
    return nil
end

function getModIndex(name)
    for index, value in ipairs(ModFrame.mods) do
        if value.name == name then
            return index
        end
    end
    return 0
end

function ModFrame.update(beat)
    for index, m in ipairs(ModFrame.shaderMods) do
        if beat > m.tweenStart and not m.complete then
            local dur = (beat - m.tweenStart)

            local t = 0

            if m.tweenLen == 0 then
                t = 1
            else
                t = (dur / m.tweenLen)
            end

            if beat > m.tweenStart + m.tweenLen then
                ModFrame.shaderMods[index].complete = true
                t = 1
            end
            local value = tween(m.startValue, m.endValue, t, m.easing)

            consolePrint(tostring(value))

            setShaderUniform(m.shader, m.uniform, value)

        end
    end
    for index, m in ipairs(ModFrame.activeMods) do
        if beat > m.tweenStart and not m.complete then
            
            local md = getMod(m.modName)

            if md == nil then
                consolePrint('[ModFrame] The mod ' .. m.modName .. ' could not be found!')
            else

                local dur = (beat - m.tweenStart)

                local t = 0

                if m.tweenLen == 0 then
                    t = 1
                else
                    t = (dur / m.tweenLen)
                end

                if beat > m.tweenStart + m.tweenLen then
                    ModFrame.activeMods[index].complete = true
                    t = 1
                end

                if m.startValue == nil then
                    m.startValue = md.value
                    if md.playfieldValues[m.playfield + 1] ~= nil then
                        m.startValue = md.playfieldValues[m.playfield + 1]
                    end
                    if m.additive then
                        m.endValue = m.startValue + m.endValue
                    end
    
                end
                
                local value = tween(m.startValue, m.endValue, t, m.easing)



                if md.useColumns then
                    if md.columns[m.playfield + 1] == nil then
                        md.columns[m.playfield + 1] = {}
                    end
                    if m.column ~= -1 and m.column ~= nil then
                        md.columns[m.playfield + 1][m.column] = {value = value}
                    end
                else
                    md.value = value
                    md.playfieldValues[m.playfield + 1] = value
                end

                if md.func ~= nil then
                    md.func(beat, value, md, m.playfield)
                end
            end
        end
    end

    for index1, mod in ipairs(ModFrame.mods) do
        if mod.setBack then
            for pn = 1,#playfields do
                local value = mod.value

                if mod.playfieldValues[pn] ~= nil then
                    value = mod.playfieldValues[pn]
                end
                
                if mod.useColumns then
                    local c = mod.columns[pn]
                    if c ~= nil then
                        for i = 1, 4 do
                            local col = c[i]
                            if col ~= nil then
                                setModProperty(mod.name, pn - 1, i - 1, col.value)
                            else
                                setModProperty(mod.name, pn - 1, i - 1, value)
                            end
                        end
                    else
                        setModProperty(mod.name, pn - 1, -1, value)
                    end
                else
                    setModProperty(mod.name, pn - 1, -1, value)
                end
            end
        end
    end

    for i = 1, #drawsize do
        local draw = drawsize[i]
        setModProperty('drawSize', i - 1, 0, draw[1])
        setModProperty('drawSize', i - 1, 1, draw[2])
    end
end

function ModFrame.editor_scroll()
    for index, m in ipairs(ModFrame.mods) do
        m.value = m.default
        m.columns = {}
        m.playfieldValues = {}
    end
    for index, m in ipairs(ModFrame.shaderMods) do
        m.complete = false
    end
    for index, m in ipairs(ModFrame.shaders) do
        for index, u in ipairs(m[4]) do
            setShaderUniform(m[1], u[1], u[2])
        end
    end
    for index, m in ipairs(ModFrame.activeMods) do
        m.complete = false
    end

    ModFrame.update(getBeat())
end
