import "sceneManager"
import "sprites/text"
import "scenes/titleScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CreditsScene").extends(Room)

function CreditsScene:enter()
    Text("Credits", 5, 5, 'left', 'Carded Bigger Run')

    local creditsText = "Couples is a game by\n"
    .. "Lorenzo Breda - lbreda.com\n"
    .. "\n"
    .. "A lot of help was provided by the friends\n"
    .. "at HIGH - high.pumo.mp\n"
    .. "Check them out!!\n"
    .. "\n"
    .. "This game uses the pretty good Roomy Playdate\n"
    .. "scene manager by Robert Curry.\n"
    .. "\n"
    .. "The game fonts are based on the Big Run font\n"
    .. "in the Playdate Arcade Fonts collection.\n"

    Text(creditsText, 5, 45, 'left', 'Roobert 9 Mono Condensed')

    ---Game pause
    function pd.gameWillPause()
        pd.setMenuImage(nil)
    end
end

function CreditsScene:update()
    gfx.sprite.update()
end

--- Menu navigation
function CreditsScene:AButtonDown()
    sceneManager:enter(TitleScene())
end
function CreditsScene:BButtonDown()
    CreditsScene:AButtonDown()
end
function CreditsScene:downButtonDown()
    CreditsScene:AButtonDown()
end
function CreditsScene:upButtonDown()
    CreditsScene:AButtonDown()
end
function CreditsScene:leftButtonDown()
    CreditsScene:AButtonDown()
end
function CreditsScene:rightButtonDown()
    CreditsScene:AButtonDown()
end

