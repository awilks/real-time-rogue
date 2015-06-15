function circleRayIntersection(e, dx, dy, x, y)
	return quadEq(dx^2 + dy^2, 2*(dx*(x-e.x) + dy*(y - e.y)), (x-e.x)^2 + (y- e.y)^2 - e.r^2)
end

function makeEnemiesActive(x,y, dx, dy, t)
	for i = 1, #enemies do
		e = enemies[i]
		local nsol, t1, t2 = e:rayHits(dx,dy)
		if nsol == 0 then
		else
			if t1< t and t1 >= 0 then  
				makeActive(e)
			elseif nsol == 2 and t2< t and t2>=0 then
				makeActive(e)
			end
		end
	end
end

function makeActive(e)
	for i = 1, #activeEnemies do 
		if activeEnemies[i] == e then return end
	end
	activeEnemies[#activeEnemies + 1] = e
end