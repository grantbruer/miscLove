

require "display functions"
require "collision"

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
	
	metersize = 440
	ball = {}
	
	ball.x = 10
	ball.y = 100
	ball.xspeed = -3*metersize
	ball.yspeed = -5*metersize
	ball.gravity = 9.8*metersize
	
	ball.radius = 15
	ball.points = {}
	ball.pointcounter = love.timer.getTime()
	ball.pointdt = 0.1
	groundy = 400
	
	window = {}
	window.width,window.height = love.graphics.getWidth(), love.graphics.getHeight()
	
	love.graphics.setBackgroundColor(0,127,255)
	
	sidebar = {}
	sidebar.width = 200
	
	camera = {}
	camera.x = 0
	camera.y = 0
	camera.xscale = 1
	camera.yscale = 1
	
	camera.speed = 10
	camera.locked = true
	
	if not sliders then
		sliders = {}
		sliders.gravity = slider.make{x=window.width-sidebar.width+2,y=100,width=sidebar.width-4,height=15, arrowheight = 20, value=0.5, text="Gravity: ",multiplyer=9.8*2,round=0.01}
	end
end

function love.update(dt)

	if love.timer.getTime()-ball.pointcounter > ball.pointdt then
		ball.pointcounter = love.timer.getTime()
		table.insert(ball.points,ball.x)
		table.insert(ball.points,ball.y)
	end
	
	ball.x = ball.x + ball.xspeed*dt
	ball.yspeed = ball.yspeed + ball.gravity*dt
	ball.y = ball.y + ball.yspeed*dt
	
	if camera.locked then
		if ball.x > camera.x + window.width-sidebar.width then
			camera.x = camera.x + window.width - sidebar.width	
		elseif ball.x < camera.x then
			camera.x = camera.x - window.width + sidebar.width
		end
	
		if ball.y > camera.y + window.height then
			camera.y = camera.y + window.height
		elseif ball.y < camera.y then
			camera.y = camera.y - window.height
		end
	else 
		if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
			camera.y = camera.y - camera.speed
		end
		if love.keyboard.isDown('s') or love.keyboard.isDown('down') then
			camera.y = camera.y + camera.speed
		end
		if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
			camera.x = camera.x - camera.speed
		end
		if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
			camera.x = camera.x + camera.speed
		end
	end
	
	if ball.y + ball.radius > groundy then
		ball.y = groundy - ball.radius
		ball.yspeed = 0
		ball.xspeed = ball.xspeed*(1-dt)
	end
	
	
	for i,s in pairs(sliders) do
		s:update()
	end
	
	love.window.setTitle(love.timer.getFPS())
	
	ball.gravity = sliders.gravity.value*sliders.gravity.multiplyer*metersize
end

function love.draw()
	love.graphics.push()
	love.graphics.translate((window.width-sidebar.width)/2,window.height/2)
	love.graphics.scale(camera.xscale,camera.yscale)
	love.graphics.translate(-(window.width-sidebar.width)/2,-window.height/2)
	
	love.graphics.translate(-camera.x,-camera.y)
	
		if #ball.points > 3 then
			love.graphics.setColor(230,0,0)
			love.graphics.line(unpack(ball.points))
		end
		
		love.graphics.setColor(127,0,255)
		love.graphics.circle("fill", ball.x,ball.y, ball.radius)
	
		love.graphics.setColor(0,225,0)
		love.graphics.rectangle("fill",camera.x,groundy,window.width/camera.xscale,window.height-groundy)
	
	love.graphics.pop()
	
	
	
	love.graphics.setColor(255,127,27)
	love.graphics.rectangle("fill", window.width-sidebar.width, 0,sidebar.width,window.height)
	
	for i,s in pairs(sliders) do
		s:draw()
	end
	
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'r' then
		ball.x = 10
		ball.y = 100
		ball.xspeed = -3*metersize
		ball.yspeed = -5*metersize
		camera.x,camera.y =0,0
	elseif key == 'l' then
		camera.locked = not camera.locked
	elseif key == '=' then
		camera.xscale = camera.xscale*2
		camera.yscale = camera.yscale*2
	elseif key == '-' then
		camera.xscale = camera.xscale/2
		camera.yscale = camera.yscale/2
	end	
end

function love.mousepressed(x,y,button)
	for i,s in pairs(sliders) do
		if s.hover then
			if s.selected then
				s.value = (x - s.x)/s.width
			else
				s.selected = true
			end
		elseif collision.pointRectangle(x,y,s.x + s.width * s.value - s.arrowwidth/2, s.y - s.arrowheight*0.6,s.arrowwidth, s.arrowheight) then
			s.mouseoffx = s.x + s.width*s.value - x
			s.selected = true
		else
			s.selected = false
			s.mouseoffx = 0
		end
	end
end


function math.round(n, round)
	local d = n/round
	if d - math.floor(d) >=  0.5 then
		n = round * (math.floor(d) + 1)
	else
		n = round * math.floor(d)
	end
	return n
end

