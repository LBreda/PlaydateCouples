import "sceneManager"
import "scenes/gameScene"
import "scenes/titleScene"
import "sprites/text"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("GameOverScene").extends(Room)

function GameOverScene:enter(previous)
	self.previous = previous

	Text('Yay!', 200, 50, true)
	Text('You finished the ' .. previous.howManyCards .. '-card game in ' .. prettyPrintTime(previous.timerValue) .. ' minutes', 200, 75, true)
	Text('with ' .. previous.wrongAttempts .. ' errors!', 200, 100, true)

	Text('Press A to retry, B to change difficulty', 200, 200, true)
end

function GameOverScene:update(dt)
	gfx.sprite.update()
end

function GameOverScene:AButtonDown()
	sceneManager:enter(GameScene(), self.previous.howManyCards, self.previous.radius)
end

function GameOverScene:BButtonDown()
	sceneManager:enter(TitleScene())
end