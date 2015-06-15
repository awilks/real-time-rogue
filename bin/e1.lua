
E1 = {x = 100, y = 100, speed = 45, radius = 10, knockbackspeed = 300, knockbacktime = 0.2, invinctime = 0.2, health =40, r = 10}



function E1:new(e)
	local e = e or {}
	setmetatable(e, self)
	self.__index = self
	return e
end

function E1:getSpeed()
	if self.knockBack then
		self.vx, self.vy =  self.knockbackspeed*self.knockBackFX, self.knockbackspeed*self.knockBackFY
	else
	    local fx, fy = towardHero(self.x,self.y)
	    self.vx , self.vy = self.speed*fx , self.speed*fy
	end
end

function E1:hitHero()
	local hits, axis, overlap = satCircleCircle(self.x,self.y,self.radius, hero.x, hero.y, HeroRadius)
	return hits, axis, overlap
end

function E1:move(dt)
	local x2 = self.x + self.vx*dt
	local y2 = self.y + self.vy*dt

	--check for wall collisions should probably be a function 

	for i = 1, numActiveWalls, 1 do
		wall = activeWalls[i]
		intersects, dir, mag = satCircleLine(x2, y2, self.radius, wall.x1, wall.y1, wall.x2, wall.y2)
	  if intersects then
      --hasIntersection = true
        x2 = x2 + dir[1]*mag
        y2 = y2 + dir[2]*mag
      else
     -- hasIntersection = false
      end
    end
    self.x, self.y = x2, y2	
end

function E1:updateStatuses(dt)
	if self.invinc then
		self.invincTimer = self.invincTimer - dt
		if self.invincTimer < 0 then self.invinc = false end
	end
	if self.knockBack then 
		self.knockBackTimer = self.knockBackTimer - dt 
		if self.knockBackTimer <= 0 then 
			self.knockBack = false
		end
	end
end

function E1:hitSword()
	if self.invinc then 
		return
	else
	    local hits, axis, overlap = satCirclePoly({r = self.radius, x= self.x, y= self.y},{vertices = sword.vs})
	    if hits then 
	    	self.knockBackFX,self.knockBackFY  = normalize(overlap*axis[1], overlap*axis[2])
	    	self.knockBack = true
	    	self.invinc = true 
	    	self.knockBackTimer = self.knockbacktime
	    	self.invincTimer = self.invinctime
	    	self.health = self.health - hero.attack
	     end
	     if self.health <=0 then self.dead = true end
	     return 
    end
end

function E1:draw(x,y)
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", x, y, self.radius, 500)
end

function E1:rayHits(dx, dy)
	return circleRayIntersection(self,dx, dy, hero.x, hero.y)
end

function E1:rayHitsFirst(dx,dy)
	local nsol, t1, t2 = self:rayHits(dx,dy)
	if nsol == 0 then return nil
	elseif nsol == 1 then 
		if t1 > 0 then return t1  
		else return false
		end
	else 
		if t1 > 0 then 
			if t2 > 0 and t2 < t1 then
				return t2
			else 
				return t1
			end
		elseif t2 >0 then
			return t2
		else return nil
		end
	end
end

function E1:rayTo()
	return normalize(self.x - hero.x, self.y - hero.y)
end