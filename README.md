# ModFrame
> A very easy way to create modfiles in Average4K (heavily inspired by NotITG's [Mirin Template](https://xerool.github.io/notitg-mirin/))

Mod frame is a seperate *.lua* file that is put in the same folder as your *mod.lua* file. 
This file has lots of ways to create visually stunning mods, that sync well.

## How to use

Copy and paste [modFrame.lua](modFrame.lua) into your folder, and make sure your main starting code looks like this:

```lua
function create()
    -- This dofile runs modFrame
    dofile(formCompletePath("modFrame.lua"))

    ModFrame.create() -- this creates all the mods we can use
end

function editor_scroll() -- for previewing in the mod editor
    ModFrame.editor_scroll()
end

function update(beat) -- actually run our mods
    ModFrame.update(beat)
end
```

Now that you have the main functions set up, you can now create some cool mods!

## ModEase

**me**, short for modease;

Is used for the easing of mods. Think of it like *"activateMod"* and *"activateModMap"* all in one function.

After the *ModFrame.create()* function, you can use *me* to start easing mods.

Example:

```lua
--[[
    it might be weird seeing {}'s instead of ()'s but all that its really doing is letting us create
    a table, so we can pass it into the function as the argument. It's basically equivalent to, func({tableValue, tableValue, etc})

    The properties for this table are as follows:
    Mod Name,
    Start Value (can be nil. If so, it will take the current value of the mod at runtime),
    End Value,
    Tween Start,
    Tween End,
    Easing,
    Column (can be nil/-1, if so. It will not use the column)
]]--

-- To move the entire playfield to the right, it'd follow like this:

me{'amovex', nil, 250, 1, 4, 'outcubic'}
```

## Set

The instant version of modease.

It's extremely simple, and I dont really have to explain much.

Example:

```lua
--[[
    Properties are:
    Mod Name,
    End Value,
    Beat,
    Column (can be nil/-1, if so. It will not use the column)
]]--

-- Instantly set the playfield 250 pixels to the right

set{'amovex',250,2.9}
```

## DefineMod

defineMod is a very special function that lets you define your own mods!

In which you can then use in *me*/*set*

Here is a semi-tutorial from the code because I am lazy.

```lua
--[[
    defineMod defines a mod that you can then set the value to using setModValue/setModValueColumn

    defineMod{'modName', 0, function(beat, perc, me, plr)
            -- Your code
            -- "me" is simply a reference to your custom mod, which contains a .value property you can set
        end, false, false}

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

-- Example:

defineMod{'myMod',0, function(beat, perc, me, plr)
    -- Set column one's confusion to 180
    setModValueColumn('confusion', 1, plr, 180)
end, false, false}
```

## DrawSize

Draw size is basically how many beats away from the playfield to draw notes. Notes **also fade in and out as they cross the borders of drawing.**

Example usage:
```lua
-- in create()
-- [1] for the playfield.
drawsize[1] = {-0.1,2} -- stop drawing notes when they're -0.1 beats away from the receptors, and 2 beats away from the receptors.
-- on playfield 2 (after an addPlayer() call)
drawsize[2] = {-0.1,2} -- do the same thing
```

## ModFrame Custom Mods

| Mod | Description |
| --- |----------- |
| cmod | Allows you to set the scroll speed |
| hidden | Describes when to start fading out notes (in beats away from the receptor) |
| hiddenin | Describes when to start fading in notes (in beats away from the receptor |

## Other functions

There are some other functions that I will now list here:

| Function | Description |
| --- |----------- |
| getModValue | Get a mods value |
| setModValue | Set a mods value |
| setModValueColumn | Set a mods value on a column |
| getModValueColumn | Get a mods value on a column |
| addPlayer | Add a player in Average4K, and also append it's id to the **playfields** global |
| shader | Creates a shader (example: `shader{'shaderName','shaderVert', 'shaderFrag', {{'uniform1', 0}}}`) |
| se | Shader Ease (like me, but for shaders. Example: `se{'aberration',0,1,4,1,'aberration','outCubic'}`) |
| dump | A helper function that dumps everything in a table to a string. Usage: `dump(table)` |
