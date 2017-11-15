local BALL=class("BALL", function (w,x,y,index,p)
	sprite=display.newSprite("bubble_"..index..".png")
	sprite.w=w
	sprite.x=x
	sprite.y=y
	sprite.selected=false
	if p==nil then
	 local Bbody=cc.PhysicsBody:createCircle(32,cc.PHYSICSBODY_MATERIAL_DEFAULT,cc.p(0,0))
         Bbody:setContactTestBitmask(0xFFFFFFFF)
         sprite:setPhysicsBody(Bbody)
         sprite:setTag(100)
    end
	sprite.index=index
	
	return sprite
end)

function BALL:ctor()
	
	
end

function BALL:setNum(w,x,y)
	self.w=w
	self.x=x
	self.y=y
end

function BALL:setFr(num)
	self.index=num
	local texture=cc.Director:getInstance():getTextureCache():getTextureForKey("bubble_"..num..".png")
	self:setTexture(texture)
end

function BALL:getNum()
	return self.w,self.x,self.y
end

return BALL