
e1 ={speed = 45, radius = 10}

function e1.getSpeed(x,y)
	local fx, fy = towardHero(x,y)
	return e1.speed*fx, e1.speed*fy
end

function e1.hitHero(x,y)
	local hits, axis, overlap = satCircleCircle(x,y,e1.radius, hero.x, hero.y, hero.HeroRadius)
	return hits, axis, overlap
end

function e1.move(x,y,vx, vy, dt)
	local x2 = x + vx*dt
	local y2 = y + vy*dt

	--check for wall collisions should probably be a function 

	for i = 1, numActiveWalls, 1 do
		wall = activeWalls[i]
		intersects, dir, mag = satCircleLine(x2, y2, e1.radius, wall.x1, wall.y1, wall.x2, wall.y2)
	  if intersects then
      --hasIntersection = true
        x2 = x2 + dir[1]*mag
        y2 = y2 + dir[2]*mag
      else
     -- hasIntersection = false
      end
    end
    return x2, y2	
end

function e1.hitSword
	
end

function e1.draw(x,y)
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", x, y, e1.radius, 500)
end