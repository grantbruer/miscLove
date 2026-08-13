
function drawTileBackground(tile)
	if map.width/tile.width > 100 then
		tile.width = tile.width*3
		tile.height = tile.height*3
	end
	local left = math.floor( ( (camera.x - camera.width/2) - (map.x - map.width/2) )/tile.width )  * tile.width + (map.x - map.width/2)
	if left < map.x - map.width/2 then
		left = map.x - map.width/2
	end
	local right = left + camera.width + tile.width	
	if right > map.x +map.width/2 then
		right = map.x + map.width/2
	end
	local x = left
	
	
	local top = math.floor( ( (camera.y - camera.height/2) - (map.y - map.height/2) )/tile.height )  * tile.height + (map.y - map.height/2)
	if top < map.y - map.height/2 then
		top = map.y - map.height/2 
	end	
	local bottom = top + camera.height + tile.height
	if bottom > map.y + map.height/2 then
		bottom = map.y + map.height/2 
	end
	local y = top
	
	love.graphics.setColor(255,255,255)
	
	while y < bottom  do
	
		while x < right do
			
			love.graphics.draw(tile.image, x,y, 0, tile.width/tile.imagewidth, tile.height/tile.imageheight)
			
			x = x + tile.width
		end
		
		y = y + tile.height
		x = left
	end
	
	
end


function drawFlowers()
	love.graphics.setColor(255,255,255)
	
	
	local left = camera.x - camera.width/2 - flowersize*1.5
	local right = camera.x + camera.width/2 + flowersize*1.5
	local top = camera.y - camera.height/2 - flowersize*1.5
	local bottom = camera.y + camera.height/2 + flowersize*1.5
	
	
	for i,v in pairs(flowers) do
		if v[1] > left and v[1] < right and v[2] > top and v[2] < bottom then
			love.graphics.draw(flowerpics[v[3]], v[1], v[2], v[4], flowersize/originalflowersize, flowersize/originalflowersize)	
		end
	end

end
