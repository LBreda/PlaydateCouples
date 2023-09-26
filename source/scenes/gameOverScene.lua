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

	Text('Yay!', 200, 50)
	Text('You finished the ' .. previous.howManyCards .. '-card game in ' .. prettyPrintTime(previous.timerValue) .. ' minutes', 200, 75)
	Text('with ' .. previous.wrongAttempts .. ' errors!', 200, 100)

	Text('Press A to play again, B to go back to the main menu', 200, 200)


    ---Progression
    if previous.level == 1 and previous.wrongAttempts <= 4 and progressionLevel == 1 then
        local store = pd.datastore.read()
        store.progressionLevel = 2
        pd.datastore.write(store)
        Text('You unlocked the next level!', 200, 150)
    elseif previous.level == 2 and previous.wrongAttempts <= 10 and progressionLevel == 2 then
        local store = pd.datastore.read()
        store.progressionLevel = 3
        pd.datastore.write(store)
        Text('You unlocked the next level!', 200, 150)
    end

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