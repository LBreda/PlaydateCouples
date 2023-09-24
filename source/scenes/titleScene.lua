import "sceneManager"
import "sprites/levelSelectionMenuItem"
import "scenes/gameScene"
import "scenes/creditsScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("TitleScene").extends(Room)

function TitleScene:enter()
    local menuCol = 200
    local menuRow = 130
    local rowHeight = gfx.font.new('fonts/Big Run'):getHeight() * 1.5

    ---Plays music
    self.bgMusic = playBgMusicWithIntro(nil, 'xDeviruchi - Title Theme (Loop)')

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
    self.bgMusic:stop()
    if self.selectedGameMenuItem == 1 then
        sceneManager:enter(GameScene(), 6, 80, 1)
    elseif self.selectedGameMenuItem == 2 then
        sceneManager:enter(GameScene(), 9, 130, 2)
    else
        sceneManager:enter(GameScene(), 12, 160, 3)
    end
end

function TitleScene:changeGameMenu(howMuch)
    self.selectedGameMenuItem = (self.selectedGameMenuItem + howMuch - 1) % #self.gameMenu + 1
    for i = 1, #self.gameMenu, 1 do
        self.gameMenu[i]:setSelection(i == self.selectedGameMenuItem)
    end
end