
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
	
	
	clear = true
	paused = false
	start = false
	cheatline = false
	
	pixelfont = love.graphics.newFont("pixel font.ttf", 48)
	windowWidth, windowHeight = love.graphics.getDimensions()
	
	player={}
	player.x=0
	player.y= 570
	playerWidth=177
	playerHeight= 10
	player.speed= 850
	
	circle = {x=windowWidth/4,y=windowHeight/2,radius = 4, yspeed = -600, xspeed = 500, color={255,0,0},dead=true}
	circle.speed = 800
	circle.angle = 7*math.pi/4
	
	brick = {}
	brick.width = 50
	brick.height = 23
	
	bricks = {}
	bricks.x = 30
	bricks.y = 60
	
	local numberacross =14
	local numberdown = 7
	local widthspace = 3
	local heightspace = 4
	
	for i=0, numberacross-1 do
		local x = bricks.x + i * (brick.width + widthspace)
		for j = 0, numberdown-1 do
			local y = bricks.y + j *(brick.height + heightspace)
			table.insert(bricks,{x=x,y=y})
		end
		
	end
	centerarea = 0.4
end


function love.update(dt)
	dt = dt * 0.6
	
	if not paused then
		
		
		if love.keyboard.isDown("right") or love.keyboard.isDown('d') then
			player.x=player.x + player.speed*dt
		end	

		if love.keyboard.isDown("left") or love.keyboard.isDown('a') then
			player.x=player.x - player.speed*dt
		end

		if player.x<0 then
			player.x=0
		end	

		if player.x>windowWidth-playerWidth then
			player.x=windowWidth-playerWidth
		end	

		--[[   
		--playerWidth slowly decreases
		if playerWidth > 50 then
			playerWidth = playerWidth - 2*dt
		end
		--]]
		if start then
			circle.x = circle.x + circle.xspeed*dt
			circle.y = circle.y + circle.yspeed*dt
			if circle.x + circle.radius > windowWidth then
				circle.x =  windowWidth - (circle.x+circle.radius-windowWidth) - circle.radius
				circle.xspeed =  -math.abs(circle.xspeed)
				changeColors()
			elseif circle.x - circle.radius < 0 then
				circle.x = -circle.x + circle.radius * 2
				circle.xspeed = math.abs(circle.xspeed)
				changeColors()
			end
			
			if circle.y > windowHeight then
				-- circle.yspeed,circle.xspeed = 0,0
				start = false
			elseif circle.y - circle.radius < 0 then
				circle.y = -circle.y + circle.radius*2
				circle.yspeed = math.abs(circle.yspeed)
				changeColors()
				if playerWidth > 50 then
					playerWidth = playerWidth-5
				end
			end

			
			if circle.y + circle.radius > player.y then
				if not circle.dead  then
					if (circle.x + circle.radius > player.x and circle.x - circle.radius < player.x + playerWidth) or (circle.x - circle.radius < player.x+playerWidth and circle.x+circle.radius > player.x) then
							circle.yspeed = -math.abs(circle.yspeed)
							if math.abs(circle.x - (player.x+playerWidth/2)) > centerarea/2*playerWidth then
								if circle.xspeed * (player.x+playerWidth/2 - circle.x) > 0 then
									circle.xspeed = -circle.xspeed
								elseif math.abs(circle.x - (player.x+playerWidth/2)) > (centerarea*1.8)/2*playerWidth then
									local ang = math.atan2(circle.yspeed,circle.xspeed)

									if ang > -math.pi/2 then
										ang = ang -ang/2
									else
										ang = ang - (ang + math.pi)/2
										
									end
									local speed = (circle.xspeed^2 + circle.yspeed^2)^0.5
									circle.yspeed = math.sin(ang) * speed
									circle.xspeed = math.cos(ang) * speed
								end
							end
							circle.y = player.y - (circle.y+circle.radius-player.y) - circle.radius
							changeColors()
					else
						circle.dead = true
					end
				else
					if collision.rectangles(circle.x-circle.radius,circle.y-circle.radius, circle.radius*2, circle.radius*2, player.x, player.y, playerWidth, playerHeight) then
						circle.xspeed = - circle.xspeed
					end
				end
			end
		
			updateBricks(dt)
		end -- end of start
	end
	
	love.timer.sleep(0.02)
	
end


function love.draw(dt)
	
	
	-- love.window.setTitle("FPS: " .. love.timer.getFPS())
	
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", player.x, player.y, playerWidth, playerHeight)

	--[[
	love.graphics.setColor(255,200,0)
	love.graphics.rectangle("fill",player.x+playerWidth/2-playerWidth*(centerarea*1.8)/2,player.y,playerWidth*(centerarea*1.8),playerHeight)
	
	love.graphics.setColor(255,0,0)
	love.graphics.rectangle("fill",player.x+playerWidth/2-playerWidth*centerarea/2,player.y,playerWidth*centerarea,playerHeight)
	--]]
	
	drawBricks()
	
	if start then
	
		if cheatline then
			love.graphics.setColor(255,255,255)
			love.graphics.line(circle.x,circle.y, circle.x + circle.xspeed * 4, circle.y + circle.yspeed * 4)
		end
		
		love.graphics.setColor(unpack(circle.color))
		love.graphics.circle("fill", circle.x, circle.y, circle.radius)
		
	end
	
	if paused then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill", 0,0,windowWidth,windowHeight)
		
		love.graphics.setColor(255,255,255)
		love.graphics.print("Paused",15,20)
	end
	
	love.graphics.setColor(255,255,255)
	if #bricks == 0 then
		love.graphics.setFont(pixelfont)
		love.graphics.printf("You Lose...", 0,windowHeight/3, windowWidth,'center')
	end
	
end


function love.keypressed(key)
	if key== 'escape' then
		love.event.quit()
	elseif key == 'c' then
		clear = not clear
	elseif key == 'p' then
		paused = not paused
	elseif key == 'space' then
		if circle.dead then
			if player.x + playerWidth/2 > windowWidth/2 then
				circle.x = player.x + playerWidth/2 - 250
			else
				circle.x = player.x + playerWidth/2 + 250
			end
			circle.y = windowHeight/2
			local ang = math.atan2(player.y-circle.y, player.x + playerWidth/2 - circle.x)
			circle.xspeed = math.cos(ang)*800
			circle.yspeed = math.sin(ang)*800
			circle.dead = false
			
			start = true
		else
			paused = not paused
		end
	elseif key == 'r' then
		love.load()
	elseif key == 'b' then
		cheatline = not cheatline
	end
end



collision = {}
function collision.rectangles(left1,top1,width1,height1,left2,top2,width2,height2 )
	return (left1 + width1 > left2 and left2 + width2 > left1 and top1 + height1 > top2 and top2 + height2 > top1)
end




function updateBricks(dt)

	for i,v in ipairs(bricks) do
		if collision.rectangles(v.x,v.y,brick.width,brick.height, circle.x - circle.radius, circle.y-circle.radius, circle.radius*2, circle.radius*2) then
			
			-- [calculate the how many xspeed units the circle is from whichever x side it hit]
			-- [calculate the how many yspeed units the circle is from whichever y side it hit]
			
			local xdis = math.min(v.x + brick.width - (circle.x-circle.radius), circle.x+circle.radius-v.x)
			local xsteps = xdis/circle.xspeed
			
			local ydis = math.min(v.y + brick.height - (circle.y-circle.radius), circle.y+circle.radius-v.y)
			local ysteps = ydis/circle.yspeed
			
			if math.abs(xsteps) < math.abs(ysteps) then
				circle.xspeed = - circle.xspeed
			else --(it hit from ydirection)
				circle.yspeed = -circle.yspeed
			end
			
			-- paused = true
			-- love.timer.sleep(2)
			table.remove(bricks, i)
			break
		end
	end
	
end

function drawBricks()
	love.graphics.setColor(127,200,30)
	for i,v in ipairs(bricks) do
		love.graphics.rectangle("fill",v.x,v.y,brick.width,brick.height)
	end
	
	love.graphics.setColor(127,0,30)
	local width = 3
	love.graphics.setLineWidth(width)
	for i,v in ipairs(bricks) do
		love.graphics.rectangle("line",v.x + width/2,v.y + width/2,brick.width-width,brick.height-width/2)
	end
end



function changeColors()
	-- love.graphics.setBackgroundColor(math.random(0,8)*16-1,math.random(0,8)*16-1,math.random(0,8)*16-1)
	-- circle.color = {math.random(8,16)*16-1,math.random(8,16)*16-1,math.random(8,16)*16-1}
end














-- function love.run()

--     math.randomseed(os.time())
--     math.random() math.random()

--     if love.load then love.load(arg) end

--     local dt = 0

--     -- Main loop time.
--     while true do
--         -- Process events.
--         if love.event then
--             love.event.pump()
--             for e,a,b,c,d in love.event.poll() do
--                 if e == "quit" then
--                     if not love.quit or not love.quit() then
--                         if love.audio then
--                             love.audio.stop()
--                         end
--                         return
--                     end
--                 end
--                 love.handlers[e](a,b,c,d)
--             end
--         end

--         -- Update dt, as we'll be passing it to update
--         if love.timer then
--             love.timer.step()
--             dt = love.timer.getDelta()
-- 			if dt > 1/30 then
-- 				dt = 1/30
-- 			end
--         end
-- 		timing = love.timer.getTime()
--         -- Call update and draw
		
--         if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		
		
		
-- 		if clear then
-- 			love.graphics.clear()
-- 		else
-- 		end
-- 		if love.draw then love.draw(dt) end
        

-- 		love.graphics.present()
		
--     end

-- end



