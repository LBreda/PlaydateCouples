import "CoreLibs/timer"
import "CoreLibs/ui"
import "sceneManager"
import "scenes/gameOverScene"
import "sprites/card"
import "sprites/image"
import "sprites/text"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("GameScene").extends(Room)

---Generates the game scene
---@param previous table Previous scene
---@param howManyCards integer how many cards to show (defaults to 6)
---@param radius integer (defaults to 80)
function GameScene:enter(previous, howManyCards, radius)
    ---Scene configurations
    self.howManyCards = howManyCards or 6
    self.radius = radius or 80

    ---Game data
    self.centerX = 200 + (self.radius - 80)
    self.centerY = 120
    self.step = 360/(self.howManyCards * 2)
    self.isRunning = true
    self.timerValue = 0
    self.wrongAttempts = 0
    self.discoveredCards = 0
    self.selectedCard = nil

    ---Generates cards list
    local cardList = {}
    for i = 1, self.howManyCards, 1 do
        table.insert(cardList, i)
        table.insert(cardList, i)
    end

    ---Prints cards
    local cardNos = shuffleTable(cardList)
    self.cards = {}
    for i = 0, 359, self.step do
        table.insert(self.cards, Card(self.centerX, self.centerY, self.radius, i, cardNos[#self.cards+1]))
    end

    ---Masking image
    Image(200, 120, gfx.image.new('images/gameSceneMask'), true)

    ---Game info screen
    local InfoX = 351
    Text("c\no\nu\np\nl\ne\ns", 50, 120, 'center', 'Carded Big Run')
    self.elapsedTimeKey = Text('Time', InfoX, 58, 'center')
    self.elapsedTimeValue = Text('0:00', InfoX, 78, 'center', 'Kerned Bigger Run')
    self.wrongAttemptsKey = Text('Errors', InfoX, 108, 'center')
    self.wrongAttemptsValue = Text('0', InfoX, 128, 'center', 'Kerned Bigger Run')
    self.discoveredCardsKey = Text('Found', InfoX, 158, 'center')
    self.discoveredCardsValue = Text('0/' .. self.howManyCards, InfoX, 178, 'center', 'Kerned Bigger Run')

    ---Crank indicator
    pd.ui.crankIndicator:start()

    pd.resetElapsedTime()
end

function GameScene:update()
    gfx.sprite.update()
    pd.timer.updateTimers()

    if(pd.isCrankDocked()) then
        pd.ui.crankIndicator:update()
    end

    ---If the game is running, updates the elapsed time
    if self.isRunning then
        self:updateTimer()
    end
end

function GameScene:cranked(change)
    for i = 1, #self.cards, 1 do
        self.cards[i]:moveByAngle(change)
    end
end
function GameScene:AButtonDown()
    self:selectCard()
end
function GameScene:BButtonDown()
    self:AButtonDown()
end
function GameScene:upButtonDown()
    self:AButtonDown()
end
function GameScene:downButtonDown()
    self:AButtonDown()
end
function GameScene:leftButtonDown()
    self:AButtonDown()
end
function GameScene:rightButtonDown()
    self:AButtonDown()
end

---Game logic
function GameScene:selectCard()
    ---Selects the card on the 270° position if it is not selected
    for i = 1, #self.cards, 1 do
        if (not self.cards[i].isFrontFacing) and self.cards[i].angle > (270 - self.step/2) and self.cards[i].angle < (270 + self.step/2) then
            ---Flips the card
            self.cards[i]:flip()
            ---Waits for it to be fipped before checking its value
            pd.timer.new(self.cards[i].animationDuration * 2, function ()
                ---If a card is already selected
                if self.selectedCard then
                    ---and it contains the same figure
                    if self.selectedCard.cardNo == self.cards[i].cardNo then
                        ---Increments the discoveredCards
                        self:incrementDiscoveredCards()
                    ---and it does not contain the same figure
                    else
                        ---Flips the cards back again
                        self.selectedCard:flip()
                        self.cards[i]:flip()
                        ---Increments the wrongAttempts
                        self:incrementWrongAttempts()
                    end
                    ---Unselects the selected card
                    self.selectedCard = nil
                ---If there is no selected card
                else
                    ---selects the current one
                    self.selectedCard = self.cards[i]
                end
            end)
        end
    end
end

---Updates the on-screen timer
function GameScene:updateTimer()
    self.timerValue = pd.getElapsedTime()
    self.elapsedTimeValue:changeText(prettyPrintTime(self.timerValue))
end

---Increments the wrongAttempts counter
function GameScene:incrementWrongAttempts()
    self.wrongAttempts += 1
    self.wrongAttemptsValue:changeText(self.wrongAttempts)
end

---Increments the discoveredCards counter
function GameScene:incrementDiscoveredCards()
    self.discoveredCards += 1
    self.discoveredCardsValue:changeText(self.discoveredCards .. '/' .. self.howManyCards)
    if self.discoveredCards == self.howManyCards then
        self.isRunning = false
        sceneManager:enter(GameOverScene())
    end
end