import "sceneManager"
import "signalManager"

import "scenes/TitleScene"

local pd <const> = playdate

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

function prettyPrintTime(seconds)
    local mins = tostring(math.floor(seconds / 60))
    local secs = tostring(math.floor(seconds % 60))
    if #secs < 2 then secs = '0' .. secs end
    return mins .. ':' .. secs
end

signalManager = Signal()

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
function pd.update()
    sceneManager:emit('update')
end
