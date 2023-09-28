import "CoreLibs/timer"
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
    local menuRow = 120
    local rowHeight = gfx.font.new('fonts/Roobert 11 Medium'):getHeight()
    self.levelForbiddenText = nil

    ---Plays music
    self.bgMusic = playBgMusicWithIntro(nil, 'xDeviruchi - Title Theme (Loop)')

    ---Gets the progression level
    self.progressionLevel = pd.datastore.read().progressionLevel

    ---Cards circle
    self.cards = {}
    for i = 0, 359, 15 do
        table.insert(self.cards, Card(200, 120, 140, i, ((i/15)%12)+1, true))
    end
    local rotateTimer = pd.timer.new(500, function (timer)
        ---Rotates the cards
        for i = 1, #self.cards, 1 do
            self.cards[i]:moveByAngle(1)
        end
    end)
    rotateTimer.repeats = true

    ---Title and menu
    Text("couples", 200, 70, true, 'Carded Bigger Run')

    self.gameMenu = {
        LevelSelectionMenuItem("Easy", menuCol, menuRow, true),
        LevelSelectionMenuItem("Hard", menuCol, menuRow + rowHeight, false, self.progressionLevel < 2),
        LevelSelectionMenuItem("A little bit harder", menuCol, menuRow + rowHeight * 2, false, self.progressionLevel < 3),
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
    ---Selects with the crank
    self:changeGameMenu(pd.getCrankTicks(8))

    pd.timer.updateTimers()
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
    if howMuch ~= 0 then
        self.selectedGameMenuItem = (self.selectedGameMenuItem + howMuch - 1) % #self.gameMenu + 1
        for i = 1, #self.gameMenu, 1 do
            self.gameMenu[i]:setSelection(i == self.selectedGameMenuItem)
        end
    
        if self.levelForbiddenText then
            self.levelForbiddenText:remove()
        end

        if self.selectedGameMenuItem == 2 and self.progressionLevel < 2 then
            self.levelForbiddenText = Text('You must complete the easy\n level with 4 errors or\n    less to access this\n           level', 200, 205, "center", "Roobert 9 Mono Condensed")
        elseif self.selectedGameMenuItem == 3 and self.progressionLevel < 3 then
            self.levelForbiddenText = Text('You must complete the hard\n level with 10 errors or\n    less to access this\n          level', 200, 205, "center", "Roobert 9 Mono Condensed")
        end
    end
end