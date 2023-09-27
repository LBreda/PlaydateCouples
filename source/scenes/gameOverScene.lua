import "sceneManager"
import "scenes/gameScene"
import "scenes/titleScene"
import "scenes/creditsScene"
import "sprites/text"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("GameOverScene").extends(Room)

function GameOverScene:enter(previous)
	self.previous = previous
    local progressionLevel = playdate.datastore.read().progressionLevel

    ---Plays music
    self.bgMusic = playBgMusicWithIntro(nil, 'xDeviruchi - Title Theme (Loop)')

    ---Background
    Image(200, 120, gfx.image.new('images/gameOverSceneBackground'), true)

    ---Progression
    local progressionHappened = false
    if previous.level == 1 and previous.wrongAttempts <= 4 and progressionLevel == 1 then
        local store = pd.datastore.read()
        store.progressionLevel = 2
        progressionHappened = true
        pd.datastore.write(store)
        Text('You unlocked the next level!', 200, 150, 'center', 'Roobert 11 Medium')
    elseif previous.level == 2 and previous.wrongAttempts <= 10 and progressionLevel == 2 then
        local store = pd.datastore.read()
        store.progressionLevel = 3
        progressionHappened = true
        pd.datastore.write(store)
        Text('You unlocked the next level!', 200, 150, 'center', 'Roobert 11 Medium')
    end

    ---Main text
    local yOffset = 0;
    if not progressionHappened then
        yOffset = 30
    end
	Text('Yay!', 200, 50 + yOffset, 'center', 'Roobert 11 Medium')
	Text('You finished the ' .. previous.howManyCards .. '-card game', 200, 75 + yOffset, 'center', 'Roobert 11 Medium')
	Text('in ' .. prettyPrintTime(previous.timerValue) .. ' minutes with ' .. previous.wrongAttempts .. ' errors!', 200, 100 + yOffset, 'center', 'Roobert 11 Medium')

	Text('Ⓐ to play again, Ⓑ for the main menu', 200, 200, 'center', 'Roobert 11 Medium')

    ---Modify system menu
    local menu = pd.getSystemMenu()
    menu:removeAllMenuItems()
    menu:removeAllMenuItems()
    menu:addMenuItem('Restart level', function ()
        self.bgMusic:stop()
        sceneManager:enter(GameScene(), self.previous.level)
    end)
    menu:addMenuItem('Main menu', function ()
        self.bgMusic:stop()
        sceneManager:enter(TitleScene())
    end)
    menu:addMenuItem('Credits', function ()
        self.bgMusic:stop()
        sceneManager:enter(CreditsScene())
    end)

    ---Game pause
    function pd.gameWillPause()
        pd.setMenuImage(nil)
    end
end

function GameOverScene:update(dt)
	gfx.sprite.update()
end

function GameOverScene:AButtonDown()
    self.bgMusic:stop()
	sceneManager:enter(GameScene(), self.previous.level)
end

function GameOverScene:BButtonDown()
    self.bgMusic:stop()
	sceneManager:enter(TitleScene())
end