import "sceneManager"
import "sprites/text"
import "scenes/titleScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("CreditsScene").extends(Room)

function CreditsScene:enter()
    ---Plays music
    self.bgMusic = playBgMusicWithIntro(nil, 'xDeviruchi - Title Theme (Loop)')

    Text("Credits", 5, 5, 'left', 'Carded Bigger Run')

    local creditsText = "Couples is a game by\n"
    .. "Lorenzo Breda - lbreda.com\n"
    .. "\n"
    .. "A lot of help was provided by the friends\n"
    .. "at HIGH - high.pumo.mp - Check them out!!\n"
    .. "\n"
    .. "This game uses the pretty good Roomy Playdate\n"
    .. "scene manager by Robert Curry.\n"
    .. "\n"
    .. "The game fonts are based on the Big Run font\n"
    .. "in the Playdate Arcade Fonts collection.\n"
    .. "\n"
    .. "The background music is made by Marllon Silva\n"
    .. "(xDeviruchi) and the sound effects are by Kenney."

    Text(creditsText, 5, 40, 'left', 'Roobert 9 Mono Condensed')

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
    self.bgMusic:stop()
    sceneManager:enter(TitleScene())
end
function CreditsScene:BButtonDown()
    self:AButtonDown()
end
function CreditsScene:downButtonDown()
    self:AButtonDown()
end
function CreditsScene:upButtonDown()
    self:AButtonDown()
end
function CreditsScene:leftButtonDown()
    self:AButtonDown()
end
function CreditsScene:rightButtonDown()
    self:AButtonDown()
end

