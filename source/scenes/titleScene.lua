import "sceneManager"
import "sprites/levelSelectionMenuItem"
import "scenes/gameScene"

local pd <const> = playdate
local gfx <const> = pd.graphics
local display <const> = playdate.display

class("TitleScene").extends(Room)

function TitleScene:enter()
    local menuCol = 200
    local menuRow = 130
    local rowHeight = gfx.font.new('fonts/Big Run'):getHeight() * 1.5

    Text("couples", 200, 70, true, 'fonts/Carded Big Run')

    self.gameMenu = {
        LevelSelectionMenuItem("Easy", menuCol, menuRow, true),
        LevelSelectionMenuItem("Hard", menuCol, menuRow + rowHeight),
        LevelSelectionMenuItem("A little bit harder", menuCol, menuRow + rowHeight * 2),
    }
    self.selectedGameMenuItem = 1
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
    if self.selectedGameMenuItem == 1 then
        sceneManager:enter(GameScene())
    elseif self.selectedGameMenuItem == 2 then
        sceneManager:enter(GameScene(), 9, 130)
    else
        sceneManager:enter(GameScene(), 12, 160)
    end
end

function TitleScene:changeGameMenu(howMuch)
    self.selectedGameMenuItem = (self.selectedGameMenuItem + howMuch - 1) % #self.gameMenu + 1
    for i = 1, #self.gameMenu, 1 do
        self.gameMenu[i]:setSelection(i == self.selectedGameMenuItem)
    end
end