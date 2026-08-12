
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

require 'lib/camera'
require 'lib/New Tables'
require 'lib/collision'
require 'level'

function love.load()
	
	window = {}
	window.width,window.height = love.graphics.getWidth(), love.graphics.getHeight()
	
	player = {}
	player.x,player.y,player.width,player.height = 0,0,20,20--3200,180,10
	player.speed = 200
	player.xspeed,player.yspeed = 0,0

	level = {}
	level.blocks = t
	--level.blockss = tabletostring(stringtotable(grant.table.load('level.txt')))
	camera.load()
	
	
	
	--------Make Widths and Heights Positive----------
	for i,v in ipairs(level.blocks) do
		
		if v.width < 0 then
			v.width = -v.width
			v.x = v.x - v.width
		end
		if v.height < 0 then
			v.height = -v.height
			v.y = v.y - v.height
		end
	end
	
	pixelfont = {}
	pixelfont[148] = love.graphics.newFont('pixel font.ttf',148)
	pixelfont[16] = love.graphics.newFont('pixel font.ttf',16)
	
	camera.xscale,camera.yscale = 1.953125,1.953125
end


function love.update(dt)
	camera.update(dt)
	camera.x,camera.y = player.x+player.width/2,player.y+player.height/2
	
	mousex,mousey = love.mouse.getPosition()
	wmousex,wmousey = camera.getWorldPoint(mousex,mousey)
	
	updatePlayer(dt)
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
		
		love.graphics.setColor(220,0,0)
		love.graphics.rectangle("fill",player.x,player.y,player.width,player.height)
		
		love.graphics.setFont(pixelfont[148])
		love.graphics.print("Winner!!", 3180,240)
	camera.unset()
	
	
	love.graphics.setColor(255,255,255)
	
	love.graphics.setFont(pixelfont[16])
	love.graphics.print("World X: " .. player.x, 4, 45)
	love.graphics.print("World Y: " .. player.y,4,60)
	
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == '-' then
		--camera.xscale = camera.xscale*0.8
		--camera.yscale = camera.yscale*0.8
	elseif key == '=' then
		--camera.xscale = camera.xscale/0.8
		--rcamera.yscale = camera.yscale/0.8
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


function math.round(x,n)
	local a =  math.floor(x/n)
	if x/n - a < 0.5 then
		return a * n
	end
	return n*a + n
end


function updatePlayer(dt)

	if love.keyboard.isDown('a') then
		player.xspeed = -player.speed
	end
	if love.keyboard.isDown('d') then
		player.xspeed = player.speed
	elseif not (love.keyboard.isDown('a') or love.keyboard.isDown('d')) then
		player.xspeed = 0
	end
	
	if love.keyboard.isDown('w') then
		player.yspeed = -player.speed
	end
	if love.keyboard.isDown('s') then
		player.yspeed = player.speed
	elseif not (love.keyboard.isDown('w') or love.keyboard.isDown('s')) then
		player.yspeed = 0
	end
	
	player.x = player.x + player.xspeed * dt
	player.y = player.y + player.yspeed * dt
	
	for i,v in ipairs(level.blocks) do
		if collision.rectangles(player.x,player.y,player.width,player.height,v.x,v.y,v.width,v.height) then
			local direction = collision.direction.rectangles(player.x-player.xspeed*dt,player.y-player.yspeed*dt, player.width,player.height, v.x,v.y,v.width,v.height)
			if direction == 'left' or direction == 'right' then
				player.x = player.x - player.xspeed*dt
			else
				player.y = player.y - player.yspeed*dt
			end
		end
	end
	
	
end

