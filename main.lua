local snake = {}
local player = {}
local playing = false
local gameover = false
local g = love.graphics
local t = love.timer
local rand = math.random

-- Points and pixel functions

local function newPoint(xpos, ypos)
  return {x = xpos, y = ypos}
end

local function tilePosToPx(tile)
	return tile.x * 5, tile.y * 5 + 100
end

-- Game functions

local function snakeOccupiesPosition(xpos, ypos)
	for i = 1, #snake.body do
		if snake.body[i].x == xpos and snake.body[i].y == ypos then
			return true
		end
	end
	return false
end

local function generateNewStar()
	local xpos, ypos = rand(0, 99), rand(0, 99)
	while snakeOccupiesPosition(xpos, ypos) do
		xpos, ypos = rand(0, 99), rand(0, 99)
	end
	star.x, star.y = xpos, ypos
end

local function eatPoint()
	player.points = player.points + 5
	star.x, star.y = -1, -1
	snake.size = snake.size + 1
	if snake.body[#snake.body].x == snake.body[#snake.body - 1].x then
		if snake.body[#snake.body].y > snake.body[#snake.body - 1].y then
			snake.body[#snake.body + 1] = newPoint(snake.body[#snake.body].x, snake.body[#snake.body].y + 1)
		else
			snake.body[#snake.body + 1] = newPoint(snake.body[#snake.body].x, snake.body[#snake.body].y - 1)
		end
	else
		if snake.body[#snake.body].x > snake.body[#snake.body - 1].x then
			snake.body[#snake.body + 1] = newPoint(snake.body[#snake.body].x + 1, snake.body[#snake.body].y)
		else
			snake.body[#snake.body + 1] = newPoint(snake.body[#snake.body].x - 1, snake.body[#snake.body].y)
		end
	end
end

-- Printing functions

local function printSnake()
	-- Set color to flashy green
	g.setColor(159, 238, 0)
	for i = 1, #snake.body do
		local x, y = tilePosToPx(snake.body[i])
		g.rectangle('fill', x, y, 5, 5)
	end
end

local function printStar()
	g.setColor(255, 0, 0)
	local x, y = tilePosToPx(star)
	g.rectangle('fill', x, y, 5, 5)
end

local function printPoints(points)
	points = points or 0
	g.setColor(103, 155, 0)
	g.rectangle('fill', 0, 0, 500, 100)
	g.setColor(201, 247, 111)
	g.setFont(love.graphics.newFont(30))
	g.print("You have " .. points .. " points!", 50, 35)
end

-- Keyboard functions 

local function isMotionKey(key)
	return key == 'up' or key == 'down' or key == 'left' or key == 'right'
end

function love.keypressed(key, unicode)
	if isMotionKey(key) then
		if player.direction == 'down' and (key == 'left' or key == 'right') then player.direction = key end
		if player.direction == 'up' and (key == 'left' or key == 'right') then player.direction = key end
		if player.direction == 'left' and (key == 'up' or key == 'down') then player.direction = key end
		if player.direction == 'right' and (key == 'up' or key == 'down') then player.direction = key end
	end
end

-- LÖVE callbacks

function love.load()
	snake = {
		body = {},
		size = 3,
		corners = {}
	}
	player = {
		direction = 'up',
		speed = 0.5,
		points = 0
	}
	star = {
		x = -1,
		y = -1
	}
	for i = 1, snake.size do
		snake.body[i] = newPoint(49, 47 + i)
	end
end

function love.update(timedelta)
	if gameover then return nil end
	if playing then
		-- Move the snake
		snake.body[#snake.body] = nil -- erase last tile
		-- Move the tiles
		for i = #snake.body, 1, -1 do
			snake.body[i+1] = snake.body[i]
		end
		local newTile = false
		if player.direction == 'up' then
			newTile = newPoint(snake.body[2].x, snake.body[2].y - 1)
		elseif player.direction == 'down' then
			newTile = newPoint(snake.body[2].x, snake.body[2].y + 1)
		elseif player.direction == 'left' then
			newTile = newPoint(snake.body[2].x - 1, snake.body[2].y)
		elseif player.direction == 'right' then
			newTile = newPoint(snake.body[2].x + 1, snake.body[2].y)
		end
		if newTile.x > 99 then newTile.x = 0 end
		if newTile.y > 99 then newTile.y = 0 end
		if newTile.x < 0 then newTile.x = 99 end
		if newTile.y < 0 then newTile.y = 99 end
		
		if snakeOccupiesPosition(newTile.x, newTile.y) then gameover, playing = true, false end
		
		snake.body[1] = newTile
		
		if snake.body[1].x == star.x and snake.body[1].y == star.y then eatPoint() end 
	end
	
	if star.x == -1 and star.y == -1 then
		generateNewStar()
	end
	
	-- If we're playing, delay the update
	-- If we're not playing and it's not game over it means that we're actually playing
	if playing then
		if player.speed > timedelta then t.sleep(player.speed - timedelta) end
	elseif not playing and not gameover then
		playing = true
	end
end

function love.draw()
	if gameover then
		g.setColor(201, 247, 111)
		g.setFont(love.graphics.newFont(50))
		g.print("GAME OVER", 100, 275)
		g.setBackgroundColor(0, 0, 0)
	else
		printPoints(player.points)
		printSnake()
		printStar()
		g.setBackgroundColor(0, 99, 99)
	end
end
