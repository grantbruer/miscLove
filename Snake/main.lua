
local major, minor, revision, codename = love.getVersion()
print(string.format("Using compatibility profile for version %d.%d.%d", major, minor, revision))
local version10 = (major == 0 and minor == 10)
if not version10 then
    -- Convert colors from [0,255] to [0,1]
    local oldSetColor = love.graphics.setColor
    function love.graphics.setColor(r, g, b, a)
        if type(r) == 'table' then
            g = r[2]
            b = r[3]
            a = r[4]
            r = r[1]
        end
        g = g/255
        b = b/255
        a = a and a/255
        r = r/255
        oldSetColor(r,g,b,a)
    end
end

function love.load()
	
	
	gridScale = 20
	window = {}
	window.width,window.height = love.graphics.getWidth(),love.graphics.getHeight()
	
	window.tilewidth = math.floor(window.width/gridScale)
	window.tileheight = math.floor(window.height/gridScale)
	
	
	------------Fonts------------------
	pixelfont = {}
	pixelfont[84] = love.graphics.newFont("pixel font.ttf", 84)
	pixelfont[18] = love.graphics.newFont("pixel font.ttf", 18)	
	
	
	snake = {}
	snake.x = 5
	snake.y = 5
	snake.points = {{snake.x,snake.y}}
	snake.soon = {}
	
	snake.direction = 'right'
	
	snake.drops = {}
	
	snake.drop = {}
	snake.drop.pic = love.graphics.newImage("tile drop.png")
	snake.drop.width = snake.drop.pic:getWidth()
	snake.drop.height = snake.drop.pic:getHeight()
	
	snake.speed = 14--8
	
	snake.tile = {}
	snake.tile.pic = love.graphics.newImage("snake tile.png")
	snake.tile.width = snake.tile.pic:getWidth()
	snake.tile.height = snake.tile.pic:getHeight()
	
	paused = false
	
	love.graphics.setBackgroundColor(31,63,127)
end


function love.update(dt)
	
	if not paused then
		if snake.direction == 'up' then		
			snake.y = snake.y - snake.speed*dt
		elseif snake.direction == 'down' then		
			snake.y = snake.y + snake.speed*dt
		elseif snake.direction == 'left' then		
			snake.x = snake.x - snake.speed*dt
		else		
			snake.x = snake.x + snake.speed*dt
		end
	
		if math.floor(snake.x) ~= snake.points[#snake.points][1] then
			table.insert(snake.points,{math.floor(snake.x),math.floor(snake.y)})
			for i,v in pairs(snake.soon) do
				if v[1] == snake.points[1][1] and v[2] == snake.points[1][2] then
					table.insert(snake.points,2,{v[1],v[2]})
					table.remove(snake.soon,i)
				end
			end
			table.remove(snake.points,1)
		end
		if math.floor(snake.y) ~= snake.points[#snake.points][2] then
			table.insert(snake.points,{math.floor(snake.x),math.floor(snake.y)})
			for i,v in pairs(snake.soon) do
				if v[1] == snake.points[1][1] and v[2] == snake.points[1][2] then
					table.insert(snake.points,2,{v[1],v[2]})
					table.remove(snake.soon,i)
				end
			end
			table.remove(snake.points,1)
		end
	
		if snake.x < 0 then
			snake.x = window.tilewidth
			snake.y = snake.y
		elseif snake.x > window.tilewidth then
			snake.x = 0
			snake.y = snake.y
		end
	
		if snake.y < 0 then
			snake.y = window.tileheight
		elseif snake.y >= window.tileheight then
			snake.y = 0
		end
	
	
		if #snake.drops < 152 and math.random() < 0.8 then
			local x = math.random(0,39)
			local y = math.random(0,29)
			for i,v in pairs(snake.points) do
				if x == v[1] and y == v[2] then
					x = math.random(0,39)
					y = math.random(0,29)
				end
			end
			table.insert(snake.drops, {x,y})
		end 
	
		love.window.setTitle(love.timer.getFPS())
	
		for i,v in pairs(snake.drops) do
			if math.floor(snake.x) == v[1] and math.floor(snake.y) == v[2] then
				table.insert(snake.soon,{v[1],v[2]})
				table.remove(snake.drops,i)
			end
		end
	
	end
end


function love.draw()
	
	love.graphics.setColor(255,255,255)
	for i,v in pairs(snake.points) do
		love.graphics.draw(snake.tile.pic,math.floor(v[1])*gridScale,math.floor(v[2])*gridScale,0, gridScale/snake.tile.width,gridScale/ snake.tile.height)
	end
	
	for i,v in pairs(snake.drops) do
		love.graphics.draw(snake.drop.pic,math.floor(v[1])*gridScale,math.floor(v[2])*gridScale,0, gridScale/snake.drop.width,gridScale/ snake.drop.height)
	end
	
	love.graphics.setColor(0,100,0)
	for i,v in pairs(snake.soon) do
		love.graphics.draw(snake.drop.pic,math.floor(v[1])*gridScale,math.floor(v[2])*gridScale,0, gridScale/snake.drop.width,gridScale/ snake.drop.height)
	end
	
	if paused then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill", 0,0,window.width,window.height)
	
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(pixelfont[84])
	
		love.graphics.print("Paused", window.width/2-100,150)
	end
	
	
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(pixelfont[18])
	
	love.graphics.print(snake.direction,10,10)
	love.graphics.print("Snake X: " .. snake.x,10,30)
	love.graphics.print("Snake Y: " .. snake.y,10,45)
end


function love.keypressed(key) 
	if key == 'escape' then
		love.event.quit()
	elseif key == ' ' then
		paused = not paused
	elseif paused then
	
	elseif key == 'w' or key == 'up' then
		snake.direction = 'up'
		
		snake.y = math.floor(snake.y)
		snake.x = math.floor(snake.x)
	elseif key == 's' or key == 'down' then
		snake.direction = 'down'
		
		snake.y = math.ceil(snake.y)
		snake.x = math.floor(snake.x)
	elseif key == 'a' or key == 'left' then	
		snake.direction = 'left'
		
		snake.y = math.floor(snake.y)
		snake.x = math.floor(snake.x)
	elseif key == 'd' or key == 'right' then
		snake.direction = 'right'
		
		snake.y = math.floor(snake.y)
		snake.x = math.ceil(snake.x)
	end
end


function math.round(x,n) --
	return x
end
