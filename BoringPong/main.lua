
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

	window = {}
	window.width, window.height = love.graphics.getWidth(), love.graphics.getHeight()
	
	paused = true
	
	paddleWidth = 10
	paddleHeight = 150
	paddleSpeed = 600
	
	
	player1 = {}
	player1.x = 25
	player1.y = 100
	player1.yspeed = 0
	player1.score = 0
	player1.scoretext = ""
	
	player2 = {}
	player2.x = window.width - 25 - paddleWidth
	player2.y = window.height - 100 - paddleHeight
	player2.yspeed = 0
	player2.score = 0
	player1.scoretext = ""
	
	
	ball = {}
	
	ball.xspeed = -500
	ball.yspeed = math.random(-10,10) * 25
	ball.x, ball.y = window.width/2, window.height/2
	ball.radius = 8
	
	resetStuff(math.random(1,2))
	
	scoretext = {}
	scoretext.font = love.graphics.newFont("pixel font.ttf",84)
	scoretext.width = scoretext.font:getWidth("0")
	scoretext.y = 20
	scoretext.xspace = 20
	
	mediumfont = love.graphics.newFont("pixel font.ttf",24)
	love.window.setTitle("Pong")
	win = false
	scored = false
end

function love.update(dt)
	if not paused then
		--------Update Ball---------------
		ball.x = ball.x + ball.xspeed*dt
		ball.y = ball.y + ball.yspeed*dt
	
		if ball.y - ball.radius < 0 then
			ball.y = ball.radius
			ball.yspeed = -ball.yspeed
		elseif ball.y + ball.radius > window.height then
			ball.y = window.height - ball.radius
			ball.yspeed = -ball.yspeed
		end
	
		-----Hit Left Player??---
		if ball.x - ball.radius < player1.x + paddleWidth then
			if ball.y+ball.radius > player1.y and ball.y-ball.radius < player1.y+paddleHeight and not win then
				ball.xspeed = math.abs(ball.xspeed)+15
				ball.x = player1.x + paddleWidth + ball.radius
			else
				win = 2
			end
		end
	
		-----Hit Right Player??---
		if ball.x + ball.radius > player2.x then
			if ball.y+ball.radius > player2.y and ball.y-ball.radius < player2.y+paddleHeight and not win then
				ball.xspeed = -math.abs(ball.xspeed)-15
				ball.x = player2.x - ball.radius
			else
				win = 1
			end
		end
	
	
		----------Move Player 1------------
		if love.keyboard.isDown('w') then
			player1.yspeed = -paddleSpeed
		end	
		if love.keyboard.isDown('s') then
			player1.yspeed = paddleSpeed
		elseif not (love.keyboard.isDown('s') or love.keyboard.isDown('w')) then
			player1.yspeed = 0
		end	
	
		----------Move Player 2---------------
		if love.keyboard.isDown('up') then
			player2.yspeed = -paddleSpeed
		end	
		if love.keyboard.isDown('down') then
			player2.yspeed = paddleSpeed
		elseif not (love.keyboard.isDown('down') or love.keyboard.isDown('up')) then
			player2.yspeed = 0
		end	
		player1.y = player1.y + player1.yspeed*dt
		player2.y = player2.y + player2.yspeed*dt
		
		if ball.yspeed > paddleSpeed - 150 then	
			paddleSpeed = paddleSpeed + 20*dt
		end
		if ball.yspeed < 0 then
			ball.yspeed = ball.yspeed + 4*dt
		else
			ball.yspeed = ball.yspeed - 4*dt
		end
	
		-----------Player Boundaries------------
		if player1.y < 0 then
			player1.y = 0
		elseif player1.y > window.height - paddleHeight then
			player1.y = window.height - paddleHeight
		end
	
		if player2.y < 0 then
			player2.y = 0
		elseif player2.y > window.height - paddleHeight then
			player2.y = window.height - paddleHeight
		end
	
	
		if win then
			if ball.x + ball.radius < 0 then
				player2.score = player2.score + 1
				scored = 2
				resetStuff(win)
				paused = true
			elseif ball.x - ball.radius > window.width then
				player1.score = player1.score + 1
				scored = 1
				resetStuff(win)
				paused = true
			end
		
		end
		----------Modify scoretext----------------
		--[[player1.scoretext,player2.scoretext = "",""
		if player1.score < 10 then
			player1.scoretext = "0"
		end
		player1.scoretext = player1.scoretext .. player1.score
		
		if player2.score < 10 then
			player2.scoretext = "0"
		end
		player2.scoretext = player2.scoretext .. player2.score
		--]]
	end
	
	if ball.xspeed * (window.width/2-ball.x) > 0 and math.random() < 0.1 and not paused and not randomizedspeed then
		ball.yspeed = ball.yspeed + math.random(-50,50)
		randomizedspeed = true
	elseif ball.xspeed * (window.width/2-ball.x) < 0 and not paused then
		randomizedspeed = false
	end
	
end


function love.draw()
	love.graphics.push()
	love.graphics.translate(window.width/2, window.height/2)
	love.graphics.scale(0.98,0.98)
	love.graphics.translate(-window.width/2,-window.height/2)
	
	love.graphics.setColor(255,255,255)
	
	love.graphics.rectangle("fill", player1.x,player1.y, paddleWidth,paddleHeight)
	
	love.graphics.rectangle("fill", player2.x,player2.y, paddleWidth,paddleHeight)
	
	love.graphics.setLineWidth(10)
	love.graphics.rectangle("line", -5,-5,window.width+10,window.height+10)
	
	
	local radius = 6
	local ncircles = 20
	local space = window.width/ncircles - radius*2
	y = 0
	for i=1, ncircles do
		y = y + radius + space
		love.graphics.circle("fill", window.width/2, y,radius)
	end
	
	love.graphics.setColor(255,255,255)
	love.graphics.circle("fill", ball.x,ball.y, ball.radius)
	love.graphics.setFont(scoretext.font)
	
	love.graphics.print(player1.score,window.width/2-scoretext.width - scoretext.xspace, scoretext.y)
	love.graphics.print(player2.score,window.width/2 + scoretext.xspace, scoretext.y)
	
	
	if player1.score > 7 then
		love.graphics.print("Winner!", 50,window.height/2-100)
		love.graphics.present()
		love.timer.sleep(3)
		player1.score = 0
		player2.score = 0
	elseif player2.score > 7 then
		love.graphics.print("Winner!!", window.width/2+40,window.height/2-100)
		love.graphics.present()
		love.timer.sleep(3)
		player1.score = 0
		player2.score = 0
	end
	
	if paused then
		love.graphics.setColor(255,255,255,100)
		love.graphics.rectangle("fill",0,0,window.width,window.height)
		local x
		if ball.xspeed < 0 then 
			x = 100
		else
			x = window.width/2 + 100
		end
		love.graphics.setFont(mediumfont)
		love.graphics.setColor(255,255,255)
		love.graphics.print("Press Space when ready.",x,window.height/2-100)
		
		
		if scored then
			love.graphics.setFont(scoretext.font)
			love.graphics.setColor(0,220,0)
			love.graphics.print("Scored!!",x,100)
		end
	end
	
	love.graphics.pop()
end


function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	elseif key == 'space' then
		paused = not paused
		scored = false
	end
end


function resetStuff(winner)
	
	local playerx
	if winner == 1 then
		playerx = player1.x + paddleWidth
	else
		playerx = player2.x
	end
	ball.x = window.width/2
	if winner == 1 then
		ball.xspeed = -500
	else
		ball.xspeed = 500
	end
	
	player1.y,player2.y = window.width/2-paddleHeight,window.width/2-paddleHeight
	ball.y = window.height/2 + math.randsign()*math.random(window.width/10, window.width/2-3*ball.radius)
	
	local ang = math.atan2(ball.y-player1.y-paddleHeight/2,ball.x-playerx)
	local totalspeed = ball.xspeed/math.cos(ang)
	ball.yspeed = totalspeed * math.sin(ang)
	win = false
end

function math.randsign()
	if math.random() < 0.5 then
		return 1
	else
		return -1
	end
end

function math.getSign(n)
	if n > 0 then
		return 1
	elseif n == 0 then
		return 0
	else
		return -1
	end
end
