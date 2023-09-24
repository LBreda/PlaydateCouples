import "sceneManager"

import "scenes/TitleScene"

local pd <const> = playdate
local sound <const> = pd.sound

---Seeds the math.random function
math.randomseed(playdate.getSecondsSinceEpoch())

---Shuffles a given table
---@param t table The table to shuffle
---@return table Shuffled table
function shuffleTable(t)
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

---Prints a given time (in seconds) in the form "mm:ss"
---@param seconds integer Time in seconds
---@return string Pretty printed time
function prettyPrintTime(seconds)
    local mins = tostring(math.floor(seconds / 60))
    local secs = tostring(math.floor(seconds % 60))
    if #secs < 2 then secs = '0' .. secs end
    return mins .. ':' .. secs
end

---Plays a background music with optional intro
---@param intro ?string Intro file name (may be nil)
---@param theme string Theme file name
---@param volume ?number Volume, defaults to .3
---@return unknown
function playBgMusicWithIntro(intro, theme, volume)
    volume = volume or .3

    local bgMusic = sound.fileplayer.new('sounds/bgm/' .. theme)
    bgMusic:setVolume(volume)
    if intro then
        local introMusic = sound.fileplayer.new('sounds/bgm/' .. intro)
        introMusic:setVolume(volume)
        introMusic:setFinishCallback(function ()
            bgMusic:play(0)
        end)
        introMusic:play()
    else
        bgMusic:play(0)
    end
    return bgMusic
end

---Creates the datastore if it doesn't exist
if not playdate.datastore.read() then
    playdate.datastore.write({progressionLevel = 1})
end

---Scene manager initialization and configuration
sceneManager = Manager()
sceneManager:hook({
    include = {
        'AButtonDown',
        'BButtonDown',
        'downButtonDown',
        'upButtonDown',
        'leftButtonDown',
        'rightButtonDown',
        'cranked',
    },
})
sceneManager:enter(TitleScene())

---Update cycle
function pd.update()
    sceneManager:emit('update')
end
