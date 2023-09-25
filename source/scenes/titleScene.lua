import "sceneManager"
import "sprites/levelSelectionMenuItem"
import "sprites/text"
import "scenes/gameScene"
import "scenes/creditsScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("TitleScene").extends(Room)

function TitleScene:enter()
    local menuCol = 200
    local menuRow = 130
    local rowHeight = gfx.font.new('fonts/Big Run'):getHeight() * 1.5
    self.levelForbiddenText = nil

    ---Plays music
    self.bgMusic = playBgMusicWithIntro(nil, 'xDeviruchi - Title Theme (Loop)')

    ---Gets the progression level
    self.progressionLevel = pd.datastore.read().progressionLevel

    Text("couples", 200, 70, true, 'Carded Bigger Run')

    self.gameMenu = {
        LevelSelectionMenuItem("Easy", menuCol, menuRow, true),
        LevelSelectionMenuItem("Hard", menuCol, menuRow + rowHeight),
        LevelSelectionMenuItem("A little bit harder", menuCol, menuRow + rowHeight * 2),
    }
    self.selectedGameMenuItem = 1

    ---Modify system menu
    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    menu:addMenuItem('Credits', function ()
        self.bgMusic:stop()
        sceneManager:enter(CreditsScene())
    end)

    ---Game pause
    function pd.gameWillPause()
        pd.setMenuImage(nil)
    end
end

function TitleScene:update()
    gfx.sprite.update()
end

--- Menu navigation
function TitleScene:downButtonDown()
    self:changeGameMenu(1)
end

function TitleScene:upButtonDown()
    self:changeGameMenu(-1)
end

function TitleScene:AButtonDown()
    if self.selectedGameMenuItem <= self.progressionLevel then
        self.bgMusic:stop()
        sceneManager:enter(GameScene(), self.selectedGameMenuItem)
    else
        playdate.sound.sampleplayer.new('sounds/sfx/lose3'):play()
    end
end

function TitleScene:changeGameMenu(howMuch)
    self.selectedGameMenuItem = (self.selectedGameMenuItem + howMuch - 1) % #self.gameMenu + 1
    for i = 1, #self.gameMenu, 1 do
        self.gameMenu[i]:setSelection(i == self.selectedGameMenuItem)
    end
    
    if self.levelForbiddenText then
        self.levelForbiddenText:remove()
    end

    if self.selectedGameMenuItem == 2 and self.progressionLevel < 2 then
        self.levelForbiddenText = Text('You must complete the easy level\n     with 4 errors or less', 200, 200)
    elseif self.selectedGameMenuItem == 3 and self.progressionLevel < 3 then
        self.levelForbiddenText = Text('You must complete the hard level\n     with 10 errors or less', 200, 200)
    end
end