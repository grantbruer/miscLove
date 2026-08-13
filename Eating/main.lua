require('1st Party Lib/camera')
require("1st Party Lib/Grant's Tables")
require("Game/Enemy/enemy")
require("Game/drawBackground")
require("1st Party Lib/math")
require("1st Party Lib/collision")

require('Game/game')
require('Game/intro')
require('Game/title')


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

function love.run()
	blurryfont = love.graphics.newImageFont("Assets/Fonts/blurryredsmallspacing.png",
    "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()-=[]" .. [[\;',./_+{}|:"<>? `~]])
	
	quit = false
	state = 'game'
	if state == 'intro' then
		intro.run()
	end
	if state == 'game' then
		game.run()
	end
end