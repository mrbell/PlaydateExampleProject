import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
gfx.clear()

class("Player").extends(gfx.sprite)
class("Pie").extends(gfx.sprite)
class("Rock").extends(gfx.sprite)

local playerSprite = nil
local pieSprite = nil
local rockSprites = {}
local kPlayerType = 1
local kPieType = 3
local kRockType = 2
local numberOfRocks = 4
local playerSpeed = 4
local playTimer = nil
local playTime = 30 * 1000

local playerImage = gfx.image.new("images/player")
local pieImage = gfx.image.new("images/pie")
local rockImage = gfx.image.new("images/rock")
local backgroundImage = gfx.image.new("images/background")

local score = 0

function Pie:move()
	while (true) do
		local randX = math.random(40, 360)
		local randY = math.random(24, 216)
		self:moveTo(randX, randY)
		local collisions = self:overlappingSprites()
		if #collisions == 0 then
			break
		end
	end
end

function Rock:place()
	while (true) do 
		local randX = math.random(40, 360)
		local randY = math.random(24, 216)

		self:moveTo(randX, randY)
		local collisions = self:overlappingSprites()
		if #collisions == 0 then
			break
		end
	end
end	

function Pie:collisionResponse(other)
	if other.type == kPlayerType then 
		return "overlap"
	else
		return "freeze"
	end
end

function Player:collisionResponse(other)
	if other.type == kPieType then 
		return "overlap"
	else
		return "freeze"
	end
end

local function resetTimer()
	playTimer = playdate.timer.new(playTime, playTime, 0, playdate.easingFunctions.linear)
end

local function createPlayerSprite()

	local player = Player()
	player.type = kPlayerType

	player:setImage(playerImage)
	player:moveTo(200, 120)
	player:setCollideRect(4, 2, 19, 27)
	player:addSprite()

	playerSprite = player

end

local function createPieSprite()

	local pie = Pie()
	pie.type = kPieType
	pie:setImage(pieImage)
	pie:setCollideRect(7, 7, 18, 17)
	pie:addSprite()
	pie:move()

	pieSprite = pie

end

local function createRockSprite()

	local rock = Rock()
	rock.type = kRockType
	rock:setImage(rockImage)
	rock:setCollideRect(0, 0, rock:getSize())
	rock:addSprite()
	rock:place()

	rockSprites[#rockSprites+1] = rock

end

local function initialize()
	math.randomseed(playdate.getSecondsSinceEpoch())

	createPlayerSprite()
	for i = 1,numberOfRocks,1 do 
		createRockSprite()
	end
	createPieSprite()

	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)
	resetTimer()
end

initialize()

function playdate.update() 
	if playTimer.value <= 0 then
		if playdate.buttonJustPressed(playdate.kButtonA) then
			resetTimer()
			pieSprite:move()
			for index, rockSprite in ipairs(rockSprites) do
				rockSprite:place()
			end
			score = 0
		end
	else

		if playdate.buttonIsPressed(playdate.kButtonUp) then
			playerSprite:moveWithCollisions(playerSprite.x, playerSprite.y - playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			playerSprite:moveWithCollisions(playerSprite.x, playerSprite.y + playerSpeed)
		end
		if playdate.buttonIsPressed(playdate.kButtonLeft) then
			playerSprite:moveWithCollisions(playerSprite.x - playerSpeed, playerSprite.y)
		end	
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			playerSprite:moveWithCollisions(playerSprite.x + playerSpeed, playerSprite.y)
		end	
	end

	local collisions = pieSprite:overlappingSprites()
	if #collisions > 0 then
		pieSprite:move()
		score += 1
	end

	playdate.timer.updateTimers()
	gfx.sprite.update()

	gfx.drawText("Time: " .. math.ceil(playTimer.value / 1000), 5, 5)
	gfx.drawText("Score: " .. score, 320, 5)
end
