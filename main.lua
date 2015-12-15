--"d:\program files\love\love.exe" "$(CURRENT_DIRECTORY)"
--"d:\program files\love\love.exe" --console "D:\Hans\Dropbox\Programmering\Lua Löve\Filler"
--"c:\program files\love\love.exe" --console "C:\Users\hans\Dropbox\Programmering\Lua Löve\Filler"

--========= Classes ====================

point = {
	x = 0,
	y = 0,
	color = 0
}
function point:new(x_, y_)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x_ 
	o.y = y_
	return o

end


--========= Variables & data structs ====================
gridSize = 20
score = 0
state = "MAKEMOVE" -- 	States: GAMEOVER, MAKEMOVE, UPDATEGFX

color = {
	{255,0,0,255},
	{0,255,0,255},
	{0,0,255,255},
	{255,255,0,255},
}

board = {
	{1, 1, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

gfxBoard = {}	-- copy of the (logic) board to be drawn
changes = {}	-- changed positions, use class point
--===================================



--========= Initialization ==========
function love.load()
	restart()
end

function newBoard()
	for y = 1, #board do
		for x = 1, #board[y] do
			board[y][x] = love.math.random(1, 4)
		end
	end
end

function restart()
	score = 0
	newBoard()
	gfxBoard = deepcopy(board)
	state = "MAKEMOVE"
end

--========= General functions =============
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--========= Game Functions =============
function love.update(dt)

	if isGameOver() then
		state = "GAMEOVER"
	elseif state == "ANIMATEBOARD" then
		if changeMade() == false then
			state = "MAKEMOVE"
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if state == "MAKEMOVE" then
		state = "ANIMATEBOARD"
		if key == "1" then
			makeMove(1)
		elseif key == "2" then
			makeMove(2)
		elseif key == "3" then
			makeMove(3)
		elseif key == "4" then
			makeMove(4)
		end	
	elseif key == " " then
			restart()
	end
end

function makeMove(selectedColor)
	changes = {}	-- reset previous changes
	position = point:new(1, 1)
	if board[1][1] ~= selectedColor then 
		score = score + 1
		fill(board[1][1], selectedColor, position)
	end
end

-- If more graphical changes (stored in changes) are to be made, make change and return true. If not return false
function changeMade()
	local _point
	if #changes == 0 then
		return false
	else
		_point = changes[#changes]						-- get next change position
		gfxBoard[_point.y][_point.x] = _point.color		-- update gfx board
		changes[#changes] = nil							-- remove change position
	end
	return true
end


-- Check the board in reverse order to see if the game is complete.
function isGameOver()
	_color = board[1][1]	
	for y = #board, 1, -1 do
		for x = #board[y], 1, -1 do
			if _color ~= board[y][x] then
				return false
			end
		end
	end
	return true
end

--[[ Recursive function. Fills the board
targetCol - color integer
selectedColor - color integer
position - point (class)
]]--
function fill(targetCol, selectedColor, position)
	if (position.x < 1 or position.x > #board[1]+1 or position.y < 1 or position.y > #board+1 or targetCol == selectedColor) then
		print("return")
		return
	end

	board[position.y][position.x] = selectedColor
	position.color = selectedColor
	changes[#changes+1] = position
	
	if position.x+1 < #board[1]+1 and board[position.y][position.x + 1] == targetCol then			-- Right
		fill(targetCol, selectedColor, point:new(position.x+1, position.y) )
	end
	if position.x-1 > 0 and board[position.y][position.x - 1] == targetCol then						-- Left
		fill(targetCol, selectedColor, point:new(position.x-1, position.y) )
	end
	if position.y < #board and board[position.y + 1][position.x] == targetCol then					-- Down
		fill(targetCol, selectedColor, point:new(position.x, position.y + 1) )
	end
	if position.y > 1 and board[position.y - 1][position.x] == targetCol then						-- Up
		fill(targetCol, selectedColor, point:new(position.x, position.y - 1) )
	end
end
			
--========= Draw ====================

function love.draw()
	drawBoard()
	drawHud()
end

function drawBoard()
	love.graphics.setColor(0,0,0,255)
	for y = 1, #gfxBoard do
		for x = 1, #gfxBoard[y] do
			love.graphics.setColor(color[gfxBoard[y][x]])
			love.graphics.rectangle("fill", x*gridSize, y*gridSize, gridSize, gridSize)
		end
	end
	love.graphics.setColor(255,255,255,255)
end

function drawHud()
	love.graphics.setColor(255,0,255,255)
	love.graphics.print("Score: " .. score, 350, 50)
	love.graphics.setColor(255,255,255,255)
	if state == "GAMEOVER" then
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("GAME OVER", 350, 150, 0, 2, 2)
		love.graphics.print("SPACE to restart", 350, 180, 0, 1, 1)
		
	end
	for i = 1, #color do
		love.graphics.setColor(color[i])
		love.graphics.rectangle("fill", 350+(i*gridSize), 100, gridSize, gridSize)
		love.graphics.setColor(0,0,0,255)		
		love.graphics.print(i, 350+(i*gridSize), 100, 0, 1.5, 1.5)
	end
end

