

require 'lib/camera'
require 'lib/New Tables'
require 'lib/collision'
require 'lib/ai'
require 'level'
require 'level2'
require 'level2nodes'

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

	paused = true
	window = {}
	window.width,window.height = love.graphics.getDimensions()
	
	
	plotnouns = {"apples",'mice','letters','tables','groceries', 'paper','zombies','people','pancakes','shirts', 'elephants','pens','gorillas','maze-makers', 'gravity', 'fortran', 'Mason', 'flour', 'flowers', 'keys', 'lions','Minotaurs', 'laptops', 'supernovas', 'black holes', 'light', 'planets', 'gangs', 'horders', 'trash', 'money',"Magikarp","leprechauns", "mazes", "hordes", 'Jeromes'}
	noun = plotnouns[math.random(1,#plotnouns)]
	
	player = {}
	player.x,player.y,player.width,player.height = 0,0,40,40--3200,180,10
	player.speed = 200
	player.xspeed,player.yspeed = 0,0

	grid = {}
	grid.size = 50
	
	level = {}
	level.blocks = blocks
	level.nodes = nodes
	--level.blockss = tabletostring(stringtotable(grant.table.load('level.txt')))
	camera.load()
	
	ai.load()
	
	
	--------Make Widths and Heights Positive----------
	level.left = level.blocks[1].x
	level.top = level.blocks[1].y
	level.bottom = level.top + level.blocks[1].height
	for i,v in ipairs(level.blocks) do
		
		if v.width < 0 then
			v.width = -v.width
			v.x = v.x - v.width
		end
		if v.height < 0 then
			v.height = -v.height
			v.y = v.y - v.height
		end
		
		if v.x < level.left then
			level.left = v.x
		end
		if v.y < level.top then
			level.top = v.y
		end
		if v.y + v.height > level.bottom then
			level.bottom = v.y + v.height
		end
	end
	
	pixelfont = {}
	pixelfont[148] = love.graphics.newFont('pixel font.ttf',148)
	pixelfont[72] = love.graphics.newFont('pixel font.ttf',72)
	pixelfont[40] = love.graphics.newFont('pixel font.ttf',40)
	pixelfont[16] = love.graphics.newFont('pixel font.ttf',16)
	
	camera.xscale,camera.yscale = 1.953125,1.953125
end


function love.update(dt)
	dt = dt
	if not paused then
		camera.update(dt)
		camera.x,camera.y = ai.x,ai.y
	
		mousex,mousey = love.mouse.getPosition()
		wmousex,wmousey = camera.getWorldPoint(mousex,mousey)
	
	
		ai.update(dt)
		updatePlayer(dt)
	end
end


function love.draw()
	mousex,mousey = love.mouse.getPosition()
	wmousex,wmousey = camera.getWorldPoint(mousex,mousey)
	
	camera.set()
		
		
		love.graphics.setColor(100,100,255)
		
		for i,v in pairs(level.blocks) do
			
			love.graphics.setColor(100,100,255)
			love.graphics.rectangle("fill", v.x,v.y,v.width,v.height)
		end
		
		for i,v in ipairs(level.nodes) do
			love.graphics.setColor(255,100,255)
			--love.graphics.circle("fill", v.x,v.y,10)
		end
		
		ai.draw()
		
		love.graphics.setFont(pixelfont[148])
		love.graphics.print("Winner!!", 3180,240)
	camera.unset()
	
	
	love.graphics.setColor(255,255,255)
	
	if ai.info then
		love.graphics.setFont(pixelfont[16])
		love.graphics.print("World X: " .. ai.x, 4, 45)
		love.graphics.print("World Y: " .. ai.y,4,60)
		
		love.graphics.print("X Speed: " .. ai.xspeed, 4, 80)
		love.graphics.print("Y Speed: " .. ai.yspeed,4,95)
		
		love.graphics.print("X Acc: " .. ai.xacc, 4, 110)
		love.graphics.print("Y Acc: " .. ai.yacc,4,125)
		
		love.graphics.print("R Speed: " .. ai.rspeed, 4, 140)
		
		love.graphics.print("R Acc: " .. ai.racc, 4, 155)
		
		love.graphics.print("State: " .. ai.state, 4, 170)
		if target.x then
			love.graphics.print("Target X: " .. target.x, 4, 125)
			love.graphics.print("Target Y: " .. target.y, 4,140)
		end
		love.graphics.print("Arrived: " .. tostring(ai.arrived), 4, 185)
		
		love.graphics.print("Left Hit: " .. tostring(ai.lefthit),4, 200)
		love.graphics.print("Right Hit: " .. tostring(ai.righthit),4, 215)
		
		love.graphics.print("Angle Arrived: " .. tostring(ai.anglearrived),4, 230)
		
		
		love.graphics.print("Chosen: " .. tostring(ai.chosen),4, 245)
		
		love.graphics.print("Clear: " .. tabletostring(ai.clear,true),4, 260)
	end	
	
	if paused then
		love.graphics.setColor(255,255,255,160)
		love.graphics.rectangle("fill",0,0,window.width,window.height)
		
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(pixelfont[148])
		love.graphics.print("Oh no!!", 105,5)
		love.graphics.setColor(205,0,0)
		love.graphics.print("Oh no!!", 100,0)
		
		love.graphics.setFont(pixelfont[40])
		love.graphics.print("You're being chased by a horde of ", 80,200)
		
		
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(pixelfont[72])
		love.graphics.print(noun .. "!",305,235)
		
		love.graphics.setColor(255,255,0)
		love.graphics.setFont(pixelfont[72])
		love.graphics.print(noun .. "!",300,230)
		
		
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(pixelfont[148])
		love.graphics.print("Quick!",205,355)
		love.graphics.setColor(205,0,0)
		love.graphics.print("Quick!",200,350)
		
		love.graphics.setFont(pixelfont[72])
		love.graphics.print("Run through this maze!",40,480)
	end
	
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == '-' then
		camera.xscale = camera.xscale*0.8
		camera.yscale = camera.yscale*0.8
	elseif key == '=' then
		camera.xscale = camera.xscale/0.8
		camera.yscale = camera.yscale/0.8
	elseif key == 'i' then	
		ai.info = not ai.info
	elseif key == 'space' then
		paused = not paused
	end

end

function love.mousepressed(x,y,button)
	wx,wy = camera.getWorldPoint(x,y)

end

function love.mousereleased(x,y,button)

end


function love.quit()
	--grant.table.save(level.blocks,'level.lua')
end

-------Good Functions to Have---------------


function math.round(x,n)------
	local a =  math.floor(x/n)
	if x/n - a < 0.5 then
		return a * n
	end
	return n*a + n
end



function updatePlayer(dt)
	
	--[[
	for i,v in ipairs(level.blocks) do
		if collision.rectangles(ai.x-ai.radius, ai.y-ai.radius, ai.radius*2,ai.radius*2,v.x,v.y,v.width,v.height) then
			local direction = collision.direction.rectangles(ai.x-ai.radius-ai.xspeed*dt,ai.y-ai.radius-ai.yspeed*dt, ai.radius*2,ai.radius*2, v.x,v.y,v.width,v.height)
			if direction == 'left' or direction == 'right' then
				--ai.x = ai.x - ai.xspeed*dt
				--ai.angle = ai.angle + math.pi/6
				--ai.targetangle = ai.angle + math.pi/2
			else
				--ai.y = ai.y - ai.yspeed*dt
				--ai.angle = ai.angle + math.pi/6
				--ai.targetangle = ai.angle + math.pi/2
			end
			--ai.align(ai.targetangle)
		end
	end
	--]]
	
	
	if ai.x-ai.radius < level.left then
		ai.x = level.left + ai.radius
		ai.angle = ai.angle + math.pi/4
	end
	
	if ai.y - ai.radius < level.top then	
		ai.y = level.top + ai.radius
		ai.angle = ai.angle + math.pi/2
	elseif ai.y + ai.radius > level.bottom then
		ai.y = level.bottom - ai.radius
		ai.angle = ai.angle + math.pi/2
	end
	
	
	local changed = false
	if ai.targetx < level.left then
		ai.targetx = level.left +  (level.left-ai.targetx)
		changed = true
	end
	
	if ai.targety < level.top then	
		ai.targety = level.top + (level.top-ai.targety)
		changed = true
	elseif ai.targety > level.bottom then
		ai.targety = level.bottom - (ai.targety-level.bottom)
		changed = true
	end
	
	if changed then
		ai.targetangle = math.atan2(ai.targety - ai.y, ai.targetx-ai.x)
		ai.align()
	end
	
	
	
end

function math.randomSign()
	return math.random(1,2)*2-3
end

