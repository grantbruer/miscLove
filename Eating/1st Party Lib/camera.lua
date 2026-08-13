camera = {}

function camera.initialize(x,y,width, height)
	camera.x = x
	camera.y = y
	
	camera.targetx = x
	camera.targety = y
	
	camera.movestep = {}
	camera.movestep.x = 0
	camera.movestep.y = 0
	
	camera.originalwidth = width
	camera.originalheight = height
	
	
	camera.width = width
	camera.height = height

	camera.onedge = false
	
	camera.xscale = 1
	camera.yscale = 1
	
	camera.targetzoom = 1
	camera.zoomstep = 0
	
	camera.zooming = false
end

function camera.zoom(zoom, tween)

	if tween then
		
		camera.targetzoom = camera.xscale * zoom
		camera.zoomstep = -(camera.xscale-camera.targetzoom)/60
		
		if camera.targetzoom * map.width < camera.width then
			camera.targetzoom = camera.xscale * camera.width/map.width
			camera.targetx = map.x
			camera.targety = map.y
			camera.movestep.x = -(camera.x - camera.targetx)/60
			camera.movestep.y = -(camera.y - camera.targety)/60
			
			camera.zoomstep =  -(camera.xscale-camera.targetzoom)/60
			--[[camera.yscale = camera.height/map.height
			camera.zoomstep = 0
			camera.zooming = false]]
		else
			camera.targetx = camera.x
			camera.targety = camera.y		
		end
		
		
		camera.zooming = true
		
	else
		
		camera.xscale = camera.xscale*zoom
		camera.yscale = camera.yscale*zoom
		
		camera.width = camera.originalwidth/camera.xscale
		camera.height = camera.originalheight/camera.yscale
		
		
	end
end


function camera.updatezoom()
	if camera.zoomstep * (camera.targetzoom - camera.xscale+camera.zoomstep) > 0  then
	
		camera.xscale = camera.xscale + camera.zoomstep
		camera.yscale = camera.yscale + camera.zoomstep
			
		camera.width = camera.originalwidth/camera.xscale
		camera.height = camera.originalheight/camera.yscale
		
		if camera.x > map.x + map.width/2 - camera.width/2 then
			camera.x = map.x + map.width/2 - camera.width/2
			camera.targetx = camera.x
		elseif camera.x < map.x - map.width/2 + camera.width/2 then
			camera.x = map.x - map.width/2 + camera.width/2
			camera.targetx = camera.x
		end
		
		if camera.y > map.y + map.height/2 - camera.height/2 then
			camera.y = map.y + map.height/2 - camera.height/2
			camera.targety = camera.y
		elseif camera.y < map.y - map.height/2 + camera.height/2 then
			camera.y = map.y - map.height/2 + camera.height/2
			camera.targety = camera.y
		end
		if camera.width >= map.width then
			camera.x = map.x
		end
		if camera.height >= map.height then
			camera.y = map.y
		end
			--[[if camera.movestep.x * (camera.x-camera.targetx) < 0 then
				camera.x = camera.x + camera.movestep.x
			end
			if camera.movestep.y * (camera.y-camera.targety) < 0 then
				camera.y = camera.y + camera.movestep.y
			end
		else
			camera.movestep.x = -(camera.x - camera.targetx)/math.abs((camera.xscale-camera.targetzoom)/camera.zoomstep)
			camera.movestep.y = -(camera.y - camera.targety)/math.abs((camera.yscale-camera.targetzoom)/camera.zoomstep)]]
		
		love.timer.sleep(0.01)
				
	else
		camera.zoomstep = 0
		camera.xscale = camera.targetzoom
		camera.yscale = camera.targetzoom
		
		if camera.x > map.x + map.width/2 - camera.width/2 then
			camera.x = map.x + map.width/2 - camera.width/2
			camera.targetx = camera.x
		elseif camera.x < map.x - map.width/2 + camera.width/2 then
			camera.x = map.x - map.width/2 + camera.width/2
			camera.targetx = camera.x
		end
		
		if camera.y > map.y + map.height/2 - camera.height/2 then
			camera.y = map.y + map.height/2 - camera.height/2
			camera.targety = camera.y
		elseif camera.y < map.y - map.height/2 + camera.height/2 then
			camera.y = map.y - map.height/2 + camera.height/2
			camera.targety = camera.y
		end
		
		if camera.width >= map.width then
			camera.x = map.x
		end
		if camera.height >= map.height then
			camera.y = map.y
		end
		
		camera.width = camera.originalwidth/camera.xscale
		camera.height = camera.originalheight/camera.yscale
		
		camera.zooming = false
		
	end
end