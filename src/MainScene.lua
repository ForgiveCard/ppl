
local MainScene = class("MainScene", function()

	local scene = cc.Scene:createWithPhysics()
    --scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    --0,0不受到重力的影响
    scene:getPhysicsWorld():setGravity(cc.p(0,0))
    return scene

end)
ball=import("app.BALL")

local size=cc.Director:getInstance():getVisibleSize()
local Tpos={x=0,y=0,d=0}
local Dmove=nil
local ChangeDir=false
local r=90
local active=false
local sqtr=1.4
local fighterAble=false
local T={j={},o={}}
local Remove={}
local Down={}
local downAble=true
local preview={}
local previewFight={}
local previewIndex={}
local top="j"
local round=0

function MainScene:ctor()
math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	

  local bg= display.newSprite("background4.jpg")
  bg:pos(display.cx,display.cy)
  self:addChild(bg)

  self.bgLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
  self.bgLayer:pos(32,32*2)
  self.bgLayer:setContentSize(size.width-32*2,size.height-32*4)
  local BLsize=self.bgLayer:getContentSize()
  self:addChild(self.bgLayer)

  local edgenode=display.newNode()--物理边框
  local body=cc.PhysicsBody:createEdgeBox(cc.size(BLsize.width+64,BLsize.height+64),cc.PHYSICSBODY_MATERIAL_DEFAULT,3,cc.p(0,-64))
  body:setContactTestBitmask(0xFFFFFFFF)
  edgenode:pos(display.cx,display.cy+32)
  edgenode:setPhysicsBody(body)
  edgenode:setTag(2)
  self:addChild(edgenode)
 
 
 self:addKeyListener()
 self:addPhysicListener()
 self:addBall()

end

function MainScene:addKeyListener()

   local listener =cc.EventListenerKeyboard:create()

  listener:registerScriptHandler(function(keyCode,event)


      
      if keyCode == 146 then
        if fighterAble==false then
          
          return
        end
        active=true
        fighterAble=false
        Tpos.x=self.sp:getPositionX()
        Tpos.y=self.sp:getPositionY()
        Tpos.d=0
      if r>0 and r>90 then
        Dmove="right"
        self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
          Tpos.d=Tpos.d+16
          self.sp:setPosition(Tpos.x+math.cos(math.rad(math.abs(180-r)))*Tpos.d,math.sin(math.rad(math.abs(180-r)))*Tpos.d+Tpos.y)
        end,0.01,false)
      elseif r==90 then
        self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
          self.sp:setPosition(self.sp:getPositionX(),self.sp:getPositionY()+16)
        end,0.01,false)        
      else
        Dmove="left"
        self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
          Tpos.d=Tpos.d+16
          self.sp:setPosition(Tpos.x-math.cos(math.rad(math.abs(r)))*Tpos.d,math.sin(math.rad(math.abs(r)))*Tpos.d+Tpos.y)
      end,0.01,false)
     end
     round=round+1
      elseif  keyCode ==124 then
        
        if active==true or (90-r+5)>75 then
          return
        end
        self.Dir:setRotation(self.Dir:getRotation()-5)
        r=r-5
        self:PreviewFight()
      elseif keyCode ==127 then
        
        if active==true or (r+5-90)>75 then
          return
        end
        self.Dir:setRotation(self.Dir:getRotation()+5)
        r=r+5
        self:PreviewFight()

        elseif keyCode==142 then
          for i=1,6,1 do
            for o=1,8 do
              if T.o[i][o]==nil then
                print(nil)
              else
                print(T.o[i][o].index)
              end
            end
            print("---------------------------------------------")
          end
          print("ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo")
          for j=1,6,1 do
            for a=1,9 do
              if T.j[j][a]==nil then
                print(nil)
              else
                print(T.j[j][a].index)
              end
            end
            print("---------------------------------------------")
          end
          print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj")
      end
      

  end,cc.Handler.EVENT_KEYBOARD_PRESSED)


  local eventDispatcher =self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function MainScene:Check(w,x,y)
  ---------------------------------左上--------------------------------
  if w=="j" and x>1 then
    if top=="j" and y>1 then

     if T.o[y-1][x-1] ~=nil then
      if T.j[y][x].index==T.o[y-1][x-1].index and T.o[y-1][x-1].selected==false then
        T.o[y-1][x-1].selected=true
        table.insert(Remove, T.o[y-1][x-1]) 
        self:Check("o",x-1,y-1)
      end
     end

   elseif top=="o" then
     if T.o[y][x-1] ~=nil then
      if T.j[y][x].index==T.o[y][x-1].index and T.o[y][x-1].selected==false then
        T.o[y][x-1].selected=true
        table.insert(Remove, T.o[y][x-1]) 
        self:Check("o",x-1,y)
      end
     end
   end
  elseif w=="o" then
    if top=="j" then

     if T.j[y][x] ~=nil then
      if T.o[y][x].index==T.j[y][x].index and T.j[y][x].selected==false then
        T.j[y][x].selected=true
        table.insert(Remove, T.j[y][x]) 
        self:Check("j",x,y)
      end
     end

   elseif top=="o"and y>1 then
    if T.j[y-1][x] ~=nil then
      if T.o[y][x].index==T.j[y-1][x].index and T.j[y-1][x].selected==false then
        T.j[y-1][x].selected=true
        table.insert(Remove, T.j[y-1][x]) 
        self:Check("j",x,y-1)
      end
     end
   end
  end
  ---------------------------------右上--------------------------------
  if w=="j" and x<9 then
    if top =="j" and y>1 then

      if T.o[y-1][x] ~=nil then
        if T.j[y][x].index==T.o[y-1][x].index and T.o[y-1][x].selected==false then 
          T.o[y-1][x].selected=true
          table.insert(Remove,T.o[y-1][x]) 
          self:Check("o",x,y-1)
        end      
      end

    elseif top=="o" then
      if T.o[y][x] ~=nil then
        if T.j[y][x].index==T.o[y][x].index and T.o[y][x].selected==false then 
          T.o[y][x].selected=true
          table.insert(Remove,T.o[y][x]) 
          self:Check("o",x,y)
        end      
      end
    end
  elseif w=="o" then
    if top =="j" then

     if T.j[y][x+1] ~=nil then
      if T.o[y][x].index==T.j[y][x+1].index and T.j[y][x+1].selected==false then
        T.j[y][x+1].selected=true
        table.insert(Remove, T.j[y][x+1]) 
        self:Check("j",x+1,y)
      end
     end

    elseif top=="o" and y>1 then
      if T.j[y-1][x+1] ~=nil then
      if T.o[y][x].index==T.j[y-1][x+1].index and T.j[y-1][x+1].selected==false then
        T.j[y-1][x+1].selected=true
        table.insert(Remove, T.j[y-1][x+1]) 
        self:Check("j",x+1,y-1)
      end
     end
    end
  end
  ----------------------------------左---------------------------------
  if w=="j" and x>1 then
    if T.j[y][x-1] ~=nil then
      if T.j[y][x].index==T.j[y][x-1].index and T.j[y][x-1].selected==false  then
        T.j[y][x-1].selected=true
        table.insert(Remove,T.j[y][x-1]) 
        self:Check("j",x-1,y)
      end   
    end   
  elseif w=="o" and x>1 then
     if T.o[y][x-1] ~=nil then
      if T.o[y][x].index==T.o[y][x-1].index and T.o[y][x-1].selected==false then
        T.o[y][x-1].selected=true
        table.insert(Remove, T.o[y][x-1]) 
        self:Check("o",x-1,y)
      end
     end
  end
  ----------------------------------右---------------------------------
  if w=="j" and x<9 then
    if T.j[y][x+1] ~=nil then
      if T.j[y][x].index==T.j[y][x+1].index and T.j[y][x+1].selected==false then
        T.j[y][x+1].selected=true
        table.insert(Remove, T.j[y][x+1]) 
        self:Check("j",x+1,y)
      end   
    end  
  elseif w=="o" and x<8 then
     if T.o[y][x+1] ~=nil then
      if T.o[y][x].index==T.o[y][x+1].index and T.o[y][x+1].selected==false then
        T.o[y][x+1].selected=true
        table.insert(Remove, T.o[y][x+1]) 
        self:Check("o",x+1,y)
      end
     end 
  end
  ---------------------------------左下--------------------------------
  if w=="j" and y<6 and x>1 then
    if top=="j" then

     if T.o[y][x-1] ~=nil then
       if T.j[y][x].index==T.o[y][x-1].index and T.o[y][x-1].selected==false then
         T.o[y][x-1].selected=true
         table.insert(Remove, T.o[y][x-1]) 
         self:Check("o",x-1,y)
       end 
    end  

   elseif top=="o" then
    if T.o[y+1][x-1] ~=nil then
       if T.j[y][x].index==T.o[y+1][x-1].index and T.o[y+1][x-1].selected==false then
         T.o[y+1][x-1].selected=true
         table.insert(Remove, T.o[y+1][x-1]) 
         self:Check("o",x-1,y+1)
       end 
    end  
   end
  elseif w=="o" and y<6 then
    if top =="j" then

     if T.j[y+1][x] ~=nil then
      if T.o[y][x].index==T.j[y+1][x].index and T.j[y+1][x].selected==false then
        T.j[y+1][x].selected=true
        table.insert(Remove, T.j[y+1][x]) 
        self:Check("j",x,y+1)
      end
     end

    elseif top=="o" then
     if T.j[y][x] ~=nil then
      if T.o[y][x].index==T.j[y][x].index and T.j[y][x].selected==false then
        T.j[y][x].selected=true
        table.insert(Remove, T.j[y][x]) 
        self:Check("j",x,y)
      end
     end
    end
  end
  ---------------------------------右下--------------------------------
  if w=="j" and y<6 and x<9 then
    if top=="j" then

      if T.o[y][x] ~=nil then
        if T.j[y][x].index==T.o[y][x].index and T.o[y][x].selected==false then
          T.o[y][x].selected=true
          table.insert(Remove, T.o[y][x]) 
          self:Check("o",x,y)
        end      
      end

    elseif top=="o" then
      if T.o[y+1][x] ~=nil then
        if T.j[y][x].index==T.o[y+1][x].index and T.o[y+1][x].selected==false then
          T.o[y+1][x].selected=true
          table.insert(Remove, T.o[y+1][x]) 
          self:Check("o",x,y+1)
        end      
      end
    end
  elseif w=="o" and y<6 then
    if top=="j" then

     if T.j[y+1][x+1] ~=nil then
      if T.o[y][x].index==T.j[y+1][x+1].index and T.j[y+1][x+1].selected==false then
        T.j[y+1][x+1].selected=true
        table.insert(Remove, T.j[y+1][x+1]) 
        self:Check("j",x+1,y+1)
      end
     end

    elseif top=="o" then
     if T.j[y][x+1] ~=nil then
      if T.o[y][x].index==T.j[y][x+1].index and T.j[y][x+1].selected==false then
        T.j[y][x+1].selected=true
        table.insert(Remove, T.j[y][x+1]) 
        self:Check("j",x+1,y)
      end
     end
    end
  end

end

function MainScene:removeSame()
  if #Remove>2 then 

    self:performWithDelay(function()
               Remove={}
                self:down()
        end,0.1*(#Remove+1))

    for i=1,#Remove,1 do
      self:performWithDelay(function()
               
               --爆炸圈
      local circleSprite=display.newSprite("circle.png")
            :pos(Remove[i]:getPosition())
            :addTo(self.bgLayer)
      circleSprite:setScale(0)
      circleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.0),
        cc.CallFunc:create(function ( ) circleSprite:removeFromParent() end)))

      --爆炸碎片
      local emitter=cc.ParticleSystemQuad:create("stars.plist")
      emitter:setPosition(Remove[i]:getPosition())
      local batch=cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
      batch:addChild(emitter)
      if Remove[i].w =="j" then
        T.j[Remove[i].y][Remove[i].x]=nil
      elseif Remove[i].w =="o" then
        T.o[Remove[i].y][Remove[i].x]=nil
      end
      Remove[i]:removeFromParent()  
      self.bgLayer:addChild(batch) 
                end, 0.1*i)

      
      
    end
    
  else 
    for i=1,#Remove,1 do
      Remove[i].selected=false
    end
    Remove={}
  end
end

function MainScene:downCheck(w,x,y)
  if y==1 and w=="j" and top=="j" then
    downAble=false
  elseif y==1  and w=="o" and top=="o" then
    downAble=false
  end
  ---------------------------------左上--------------------------------
  if w=="j" and x>1 then
    if top =="j" and y>1 then

     if T.o[y-1][x-1] ~=nil then
      if  T.o[y-1][x-1].selected==false then
        T.o[y-1][x-1].selected=true
        table.insert(Down, T.o[y-1][x-1]) 
        self:downCheck("o",x-1,y-1)
      end
     end

   elseif top=="o" then
     if T.o[y][x-1] ~=nil then
      if y==1 and T.o[y][x-1].index~=nil then
        downAble=false
      end
      if  T.o[y][x-1].selected==false then
        T.o[y][x-1].selected=true
        table.insert(Down, T.o[y][x-1]) 
        self:downCheck("o",x-1,y)
      end
     end
   end
  elseif w=="o" then
    if top =="j" then

     if T.j[y][x] ~=nil then
      if y==1 and T.j[y][x].index~=nil then
        downAble=false
      end
      if T.j[y][x].selected==false then
        T.j[y][x].selected=true
        table.insert(Down, T.j[y][x]) 
        self:downCheck("j",x,y)
      end
     end

    elseif top=="o" and y>1 then
      if T.j[y-1][x] ~=nil then
        if T.j[y-1][x].selected==false then
          T.j[y-1][x].selected=true
          table.insert(Down, T.j[y-1][x]) 
          self:downCheck("j",x,y-1)
        end
      end
    end
  end
  ---------------------------------右上--------------------------------
  if w=="j"  and x<9 then
    if top=="j" and y>1 then

      if T.o[y-1][x] ~=nil then
        if T.o[y-1][x].selected==false then 
          T.o[y-1][x].selected=true
          table.insert(Down,T.o[y-1][x]) 
          self:downCheck("o",x,y-1)
        end      
      end

    elseif top=="o" then
      if T.o[y][x] ~=nil then
        if y==1 and T.j[y][x].index~=nil then
          downAble=false
        end
        if T.o[y][x].selected==false then 
          T.o[y][x].selected=true
          table.insert(Down,T.o[y][x]) 
          self:downCheck("o",x,y)
        end      
      end
    end
  elseif w=="o" then
    if top=="j" then

     if T.j[y][x+1] ~=nil then
      if y==1 and T.j[y][x+1].index~=nil then
        downAble=false
      end
      if T.j[y][x+1].selected==false then
        T.j[y][x+1].selected=true
        table.insert(Down, T.j[y][x+1]) 
        self:downCheck("j",x+1,y)
      end
     end

   elseif top=="o" and y>1 then
     if T.j[y-1][x+1] ~=nil then
      if T.j[y-1][x+1].selected==false then
        T.j[y-1][x+1].selected=true
        table.insert(Down, T.j[y-1][x+1]) 
        self:downCheck("j",x+1,y-1)
      end
     end
   end
  end
  ----------------------------------左---------------------------------
  if w=="j" and x>1 then
    if T.j[y][x-1] ~=nil then
      if T.j[y][x-1].selected==false  then
        T.j[y][x-1].selected=true
        table.insert(Down,T.j[y][x-1]) 
        self:downCheck("j",x-1,y)
      end   
    end   
  elseif w=="o" and x>1 then
     if T.o[y][x-1] ~=nil then
      if T.o[y][x-1].selected==false then
        T.o[y][x-1].selected=true
        table.insert(Down, T.o[y][x-1]) 
        self:downCheck("o",x-1,y)
      end
     end
  end
  ----------------------------------右---------------------------------
  if w=="j" and x<9 then
    if T.j[y][x+1] ~=nil then
      if T.j[y][x+1].selected==false then
        T.j[y][x+1].selected=true
        table.insert(Down, T.j[y][x+1]) 
        self:downCheck("j",x+1,y)
      end   
    end  
  elseif w=="o" and x<8 then
     if T.o[y][x+1] ~=nil then
      if T.o[y][x+1].selected==false then
        T.o[y][x+1].selected=true
        table.insert(Down, T.o[y][x+1]) 
        self:downCheck("o",x+1,y)
      end
     end 
  end
  ---------------------------------左下--------------------------------
  if w=="j" and y<6 and x>1 then
    if top =="j" then

      if T.o[y][x-1] ~=nil then
        if T.o[y][x-1].selected==false then
          T.o[y][x-1].selected=true
          table.insert(Down, T.o[y][x-1]) 
          self:downCheck("o",x-1,y)
        end 
      end  

    elseif top=="o" then
      if T.o[y+1][x-1] ~=nil then
        if T.o[y+1][x-1].selected==false then
          T.o[y+1][x-1].selected=true
          table.insert(Down, T.o[y+1][x-1]) 
          self:downCheck("o",x-1,y+1)
        end 
      end  
    end
  elseif w=="o" and y<6 then
    if top=="j" then

     if T.j[y+1][x] ~=nil then
      if T.j[y+1][x].selected==false then
        T.j[y+1][x].selected=true
        table.insert(Down, T.j[y+1][x]) 
        self:downCheck("j",x,y+1)
      end
     end

    elseif top=="o" then
     if T.j[y][x] ~=nil then
      if T.j[y][x].selected==false then
        T.j[y][x].selected=true
        table.insert(Down, T.j[y][x]) 
        self:downCheck("j",x,y)
      end
     end
    end
  end
  ---------------------------------右下--------------------------------
  if w=="j" and y<6 and x<9 then
    if top=="j" then

      if T.o[y][x] ~=nil then
        if T.o[y][x].selected==false then
          T.o[y][x].selected=true
          table.insert(Down, T.o[y][x]) 
          self:downCheck("o",x,y)
        end      
      end

    elseif top=="o" then
      if T.o[y+1][x] ~=nil then
        if T.o[y+1][x].selected==false then
          T.o[y+1][x].selected=true
          table.insert(Down, T.o[y+1][x]) 
          self:downCheck("o",x,y+1)
        end      
      end
    end
  elseif w=="o" and y<6 then
    if top=="j" then

     if T.j[y+1][x+1] ~=nil then
      if T.j[y+1][x+1].selected==false then
        T.j[y+1][x+1].selected=true
        table.insert(Down, T.j[y+1][x+1]) 
        self:downCheck("j",x+1,y+1)
      end
     end

    elseif top=="o" then
      if T.j[y][x+1] ~=nil then
        if T.j[y][x+1].selected==false then
          T.j[y][x+1].selected=true
          table.insert(Down, T.j[y][x+1]) 
          self:downCheck("j",x+1,y)
        end
     end
    end
  end
  return false
end

function MainScene:down()
  local T1=self.bgLayer:getChildren()
  local j=0
  for i=1,#T1,1 do
    if T1[i]:getTag()==100 and T1[i].selected==false then
      T1[i].selected=true
      table.insert(Down, T1[i])
      self:downCheck(T1[i]:getNum())
      if downAble==true then
       for o=1,#Down,1 do
        Down[o]:setTag(10)
        local x=Down[o]:getPositionX()
        local w,x1,y=Down[o].w,Down[o].x,Down[o].y
        local act2
        if w=="j" then
         act2= cc.CallFunc:create(function()
          --爆炸圈
      local circleSprite=display.newSprite("circle.png")
            :pos(T.j[y][x1]:getPosition())
            :addTo(self.bgLayer)
      circleSprite:setScale(0)
      circleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.0),
        cc.CallFunc:create(function ( ) circleSprite:removeFromParent() end)))

      --爆炸碎片
      local emitter=cc.ParticleSystemQuad:create("stars.plist")
      emitter:setPosition(T.j[y][x1]:getPosition())
      local batch=cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
      batch:addChild(emitter)
      self.bgLayer:addChild(batch) 
          T.j[y][x1]:removeFromParent()   
          T.j[y][x1]=nil
        end)

        else
         act2= cc.CallFunc:create(function()
          --爆炸圈
      local circleSprite=display.newSprite("circle.png")
            :pos(T.o[y][x1]:getPosition())
            :addTo(self.bgLayer)
      circleSprite:setScale(0)
      circleSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.0),
        cc.CallFunc:create(function ( ) circleSprite:removeFromParent() end)))

      --爆炸碎片
      local emitter=cc.ParticleSystemQuad:create("stars.plist")
      emitter:setPosition(T.o[y][x1]:getPosition())
      local batch=cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
      batch:addChild(emitter)  
      self.bgLayer:addChild(batch) 
          T.o[y][x1]:removeFromParent() 
          T.o[y][x1]=nil
        end)
        end
        local speed=((Down[o]:getPositionY()-112)/480)
        local act1=cc.MoveTo:create(speed,cc.p(x,112))
        local act=cc.Sequence:create(act1,act2)
        Down[o]:setPhysicsBody(nil)
        Down[o]:runAction(act)
       end
       Down={}
      else
        downAble=true
        Down={}
      end
    end
  end

  for i=1,#T1,1 do
    if T1[i]:getTag()==100 and T1[i].selected==true then
       T1[i].selected=false
    end
  end

end

function MainScene:addPhysicListener()
  local function onContactBegin(contact)
        if active~=true then
          return
        end
        if self.move ~=nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.move)
        self.move=nil
        end
        local tag=contact:getShapeB():getBody():getNode():getTag()
        local NodeA=contact:getShapeA():getBody():getNode()
        local NodeB=contact:getShapeB():getBody():getNode()
        local Td=0
        Tpos.d=0
        if tag==2 then
        local height=self.sp:getPositionY()
        if Dmove=="right" and height< size.height-32*6 and height>32 then
          if r>90 then
            if ChangeDir then
              self.sp:setPosition(self.bgLayer:getContentSize().width,math.tan(math.rad(math.abs(180-r)))*self.bgLayer:getContentSize().width+Tpos.y)
            else
              self.sp:setPosition(self.bgLayer:getContentSize().width,math.tan(math.rad(math.abs(180-r)))*self.bgLayer:getContentSize().width/2+Tpos.y)
              ChangeDir=true
            end
            Tpos.y=self.sp:getPositionY()
            Tpos.x=self.sp:getPositionX()
           self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
                 Tpos.d=Tpos.d+16
                 Td=Td+16
                 self.sp:setPosition(Tpos.x-math.cos(math.rad(math.abs(180-r)))*Td,math.sin(math.rad(math.abs(180-r)))*Tpos.d+Tpos.y)
              end
              ,0.01,false)
          elseif r<90 then 
            self.sp:setPosition(self.bgLayer:getContentSize().width,math.tan(math.rad(math.abs(r)))*self.bgLayer:getContentSize().width+Tpos.y)
                 Tpos.y=self.sp:getPositionY()
                 Tpos.x=self.sp:getPositionX()

            self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()   
                 Tpos.d=Tpos.d+16
                 Td=Td+16
                 self.sp:setPosition(Tpos.x-math.cos(math.rad(math.abs(r)))*Td,math.sin(math.rad(math.abs(r)))*Tpos.d+Tpos.y)
              end
              ,0.01,false)
          end
           Dmove="left"
        elseif Dmove=="left" and height< size.height-32*6 and height>32 then

          if r>90 then
            self.sp:setPosition(0,math.tan(math.rad(math.abs(180-r)))*self.bgLayer:getContentSize().width+Tpos.y)
                 Tpos.y=self.sp:getPositionY()
                 Tpos.x=self.sp:getPositionX()

           self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
                 Tpos.d=Tpos.d+16
                 Td=Td+16
                 self.sp:setPosition(Tpos.x+math.cos(math.rad(math.abs(180-r)))*Td,math.sin(math.rad(math.abs(180-r)))*Tpos.d+Tpos.y)
              end
              ,0.01,false)
          elseif r<90 then 
            if ChangeDir then
              self.sp:setPosition(0,math.tan(math.rad(math.abs(r)))*self.bgLayer:getContentSize().width+Tpos.y)
            else
               self.sp:setPosition(0,math.tan(math.rad(math.abs(r)))*self.bgLayer:getContentSize().width/2+Tpos.y)
               ChangeDir=true
            end
                 Tpos.y=self.sp:getPositionY()
                 Tpos.x=self.sp:getPositionX()

            self.move=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
                
                 Tpos.d=Tpos.d+16
                 Td=Td+16
                 self.sp:setPosition(Tpos.x+math.cos(math.rad(math.abs(r)))*Td,math.sin(math.rad(math.abs(r)))*Tpos.d+Tpos.y)
              end
              ,0.01,false)
          end
          Dmove="right"
        elseif  height>32  then

          Dmove=nil
          self.sp:setTag(100)
         local posx=math.ceil(self.sp:getPositionX()/64)
         local posy=math.ceil(self.sp:getPositionY()/64)
         if (posy-1)*64+32>self.bgLayer:getContentSize().height or (posy-1)*64+32==self.bgLayer:getContentSize().height then
          if top=="j" then
            if (posx-1)>0 then
             self.sp:setPosition((posx-1)*64+32,self.bgLayer:getContentSize().height-32)
            else
              self.sp:setPosition(32,self.bgLayer:getContentSize().height-32)
            end
          elseif top=="o" then
            if (posx-1)>0 then
             self.sp:setPosition((posx-1)*64,self.bgLayer:getContentSize().height-32)
            else
              self.sp:setPosition(64,self.bgLayer:getContentSize().height-32)
            end
          end
         else
          if top =="j" then
            self.sp:setPosition((posx-1)*64+32,(posy-1)*64+32)
          elseif top=="o" then
            if (posx-1)*64+64<self.bgLayer:getContentSize().width then
              self.sp:setPosition((posx-1)*64+64,(posy-1)*64+32)
            else
              self.sp:setPosition((posx-1)*64,(posy-1)*64+32)
            end
          end
        end
-----------------------------------------将打出的珠子加入数组----------------------------------
          local sizeL=self.bgLayer:getContentSize()
          local dalte=(sizeL.height-self.sp:getPositionY()-32)/64+1
          local x=self.sp:getPositionX()
          local sp=self.sp
          if (dalte%2)>0 and top=="j" then
            sp:setNum("j",(x-32)/64+1, math.ceil(dalte/2))
            T.j[math.ceil(dalte/2)][(x-32)/64+1]=sp
          elseif (dalte%2)==0 and top=="o" then
            sp:setNum("j",(x-32)/64+1,dalte/2)
            T.j[dalte/2][(x-32)/64+1]=sp
          elseif (dalte%2)==0 and top=="j" then
            sp:setNum("o",(x-64)/64+1, dalte/2)
            T.o[dalte/2][(x-64)/64+1]=sp
          elseif (dalte%2)>0 and top=="o" then
            sp:setNum("o",(x-64)/64+1, math.ceil(dalte/2))
            T.o[math.ceil(dalte/2)][(x-64)/64+1]=sp
          end


-------------------------------------------检测和消除相同颜色的珠子---------------------------
          sp.selected=true
          table.insert(Remove,sp) 
          self:Check(sp:getNum())
          self:removeSame()    
-----------------------------------------------------end---------------------------------------
          active=false
          self:addNewBall()
          ChangeDir=false
        end
      else
          
          
          Dmove=nil
          local pos
          local posA
          if NodeA:getTag()==100 and NodeB:getTag()==101 then 
            pos=cc.p(NodeA:getPositionX(),NodeA:getPositionY())
            posA=cc.p(self.sp:getPositionX(),self.sp:getPositionY())
          elseif NodeA:getTag()==101 and NodeB:getTag()==100 then       
            pos=cc.p(NodeB:getPositionX(),NodeB:getPositionY())
            posA=cc.p(self.sp:getPositionX(),self.sp:getPositionY())

          end
---------------------------------------珠子位置修正------------------------------------
          if posA.x>pos.x and posA.y< pos.y-16*sqtr then
            if pos.x+32==self.bgLayer:getContentSize().width or pos.x+32>self.bgLayer:getContentSize().width then
              self.sp:setPosition(pos.x-32,pos.y-64)
            else
              self.sp:setPosition(pos.x+32,pos.y-64)
            end
            --self.sp:setPosition(pos.x+32,pos.y-64)
          elseif posA.x<pos.x and posA.y< pos.y-16*sqtr then
            if pos.x-32==0 or pos.x-32<0 then
              self.sp:setPosition(pos.x+32,pos.y-64)
            else
              self.sp:setPosition(pos.x-32,pos.y-64)
            end
            --self.sp:setPosition(pos.x-32,pos.y-64)
          elseif posA.x<pos.x and posA.y> pos.y-16*sqtr then
            if pos.x-64==0 or pos.x-64<0 then
              self.sp:setPosition(pos.x-32,pos.y-64)
            else
              self.sp:setPosition(pos.x-64,pos.y)
            end
          elseif posA.x>pos.x and posA.y> pos.y-16*sqtr then
            if pos.x+64==self.bgLayer:getContentSize().width or pos.x+64>self.bgLayer:getContentSize().width then

              self.sp:setPosition(pos.x+32,pos.y-64)
            else
              self.sp:setPosition(pos.x+64,pos.y)
            end
            --self.sp:setPosition(pos.x+64,pos.y)
          elseif posA.x ==pos.x then 
            if pos.x+32==self.bgLayer:getContentSize().width or pos.x+32>self.bgLayer:getContentSize().width then
              self.sp:setPosition(pos.x-32,pos.y-64)
            else
              self.sp:setPosition(pos.x+32,pos.y-64)
            end
          end
-----------------------------------------------end-----------------------------------------
--------------------------------------将打出的珠子加入数组---------------------------------
          self.sp:setTag(100)
          local sizeL=self.bgLayer:getContentSize()
          local dalte=(sizeL.height-self.sp:getPositionY()-32)/64+1
          local x=self.sp:getPositionX()
          local sp=self.sp
          if (dalte%2)>0 and top=="j" then
            sp:setNum("j",(x-32)/64+1, math.ceil(dalte/2))
            T.j[math.ceil(dalte/2)][(x-32)/64+1]=sp
          elseif (dalte%2)==0 and top=="o" then
            sp:setNum("j",(x-32)/64+1,dalte/2)
            T.j[dalte/2][(x-32)/64+1]=sp
          elseif (dalte%2)==0 and top=="j" then
            sp:setNum("o",(x-64)/64+1, dalte/2)
            T.o[dalte/2][(x-64)/64+1]=sp
          elseif (dalte%2)>0 and top=="o" then
            sp:setNum("o",(x-64)/64+1, math.ceil(dalte/2))
            T.o[math.ceil(dalte/2)][(x-64)/64+1]=sp
          end
          if round%6==0 then 
            self:LevelUp()
          end
---------------------------------------------检测玩家是否已经失败-----------------------------
          if (sizeL.height-self.sp:getPositionY()-32)/64+1>11 then
            self:GameOver()
            return
          else

            if top=="j" then
              for i=1,9 do
                if T.o[6][i]~=nil then
                  self:GameOver()
                  return
                end
              end
            else
              if top=="o" then
                for i=1,8 do
                  if T.j[6][i]~=nil then
                    self:GameOver()
                    return
                  end
                end
              end
            end

          end
-------------------------------------------检测和消除相同颜色的珠子---------------------------
          
          sp.selected=true
          table.insert(Remove, sp) 
          self:Check(sp:getNum())
          self:removeSame()
          
-----------------------------------------------------end---------------------------------------

          active=false
          self:addNewBall()
          ChangeDir=false
       end
    
  end

  local contactListener=cc.EventListenerPhysicsContact:create()
  contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
  local eventDispatcher=cc.Director:getInstance():getEventDispatcher()
  eventDispatcher:addEventListenerWithFixedPriority(contactListener, 1)
end

function MainScene:addNewBall()
  for i=1,3,1 do
            if i==3 then
             local act=cc.MoveTo:create(0.21,cc.p(i*64+64,48))
             local act1=cc.RotateBy:create(0.2, 360)           
             local action=cc.Sequence:create(cc.Spawn:create(act,act1),cc.CallFunc:create(function ()
                local num=preview[i].index
                local newnum=math.round(math.random()*999)%7
                preview[i]:setPosition(i*64,48)

                for i=3,1,-1 do

                  if i==1 then
                    preview[1]:setFr(newnum)
                  else
                    preview[i]:setFr(previewIndex[i-1])
                  end
                  
                end
                for i=3,1,-1 do

                  if i==1 then

                    previewIndex[1]=newnum

                  else

                    previewIndex[i]=previewIndex[i-1]

                  end
                  
                end

                self.sp=ball.new(nil,0,0,num)
                self.sp:pos(self.bgLayer:getContentSize().width/2,48)
                self.sp:setTag(101)
                self.bgLayer:addChild(self.sp,1)
                self:performWithDelay(function()
                  fighterAble=true
                end, 0.1)
             end))
             preview[i]:runAction(action) 
            else
               local act=cc.MoveTo:create(0.2,cc.p(i*64+64,48))
               local act1=cc.RotateBy:create(0.2, 360)
               local action=cc.Sequence:create(cc.Spawn:create(act,act1),cc.CallFunc:create(function ()
                 preview[i]:setPosition(i*64,48)
               end))
               preview[i]:runAction(action)
            end

          end
          
          
end


function MainScene:addBall()
-------------------------------数组下落时禁止射出小球-------------------
    self:performWithDelay(function ()
      fighterAble=true
    end, 1.2)
-------------------------------初始化数组-------------------------------
local arr=self.bgLayer:removeAllChildren()
T={j={},o={}}
preview={}
previewFight={}
previewIndex={}
round=0
top="j"
-----------------------------------end----------------------------------
    local sp
    local sizeL=self.bgLayer:getContentSize()
    local temp
----------------------------------------加入珠子-----------------------
    for j=1,13,1 do
      if j%2>0 then
        table.insert(T.j, {})
      else
        table.insert(T.o, {})
      end
    end
    for j=1,5,1 do
	  for i=1,9,1 do
        
        temp=j%2
        local num=math.round(math.random()*999)%7
        
        if temp>0 then		 

          sp= ball.new("j",i,math.ceil(j/2),num)
         sp:pos(32+(i-1)*64,(sizeL.height-(j-1)*64-32)*2)
         self.bgLayer:addChild(sp,2)
         local act =cc.MoveTo:create(0.1*i,cc.p(32+(i-1)*64,sizeL.height-(j-1)*64-32))
         sp:runAction(act)
         table.insert(T.j[math.ceil(j/2)], sp)
       elseif i<9 and temp==0 then

          sp= ball.new("o",i,j/2,num)
         sp:pos(64+(i-1)*64,(sizeL.height-(j-1)*64-32)*2)
         local act =cc.MoveTo:create(0.1*i,cc.p(64+(i-1)*64,sizeL.height-(j-1)*64-32))
         self.bgLayer:addChild(sp,2)
         sp:runAction(act)
         table.insert(T.o[j/2], sp)
        
         

        end

	  end
    end
-------------------------------------加入准备射出的珠子------------------------
  local num=math.round(math.random()*999)%7
  self.sp=ball.new(nil,0,0,num)
  self.sp:pos(sizeL.width/2,48)
  local Bbody=cc.PhysicsBody:createCircle(32,cc.PHYSICSBODY_MATERIAL_DEFAULT,cc.p(0,0))
  self.sp:setTag(101)
  self.bgLayer:addChild(self.sp,2)
------------------------------------加入方向标并初始化方向------------------------
self.Dir=display.newSprite("f1.png")
  self.Dir:setAnchorPoint(0.5,0)
  self.Dir:setPosition(sizeL.width/2,48)
  self.bgLayer:addChild(self.Dir,1)
  r=90
------------------------------------------加入待机珠子-----------------------------
     for i=1,3,1 do
     local num=math.round(math.random()*999)%7
    local sp=ball.new(nil,0,0,num,false)
    sp:setTag(20)
    sp:pos(i*64,48)
    sp:addTo(self.bgLayer)
    table.insert(previewIndex,num)
    table.insert(preview,sp)
  end
-------------------------------------------轨迹预览-------------------------------
      self:PreviewFight()

end

function MainScene:PreviewFight()
  if #previewFight>0 then
    for i=1,#previewFight,1 do
      previewFight[i]:removeFromParent()
    end
    previewFight={}
  end
  local sizeL=self.bgLayer:getContentSize()
  local dalte=self.bgLayer:getContentSize().width/2
  local p=false
     for i=1,34,1 do
       local sp1=display.newSprite("bubble_9.png")
       sp1:setScale(0.1)
       sp1:setAnchorPoint(0.5,0.5)
       if (r<90) and (not p) then
        dalte=dalte-math.abs(math.cos(math.rad(math.abs(180-r)))*16)
        if (dalte)<0 then
          sp1:setPosition(0,math.sin(math.rad(math.abs(180-r)))*i*16+48)
          p=true
          dalte=0-math.cos(math.rad(math.abs(180-r)))*16
        else
          sp1:setPosition(dalte,math.sin(math.rad(math.abs(180-r)))*i*16+48)
        end
        elseif r==90 then
          sp1:setPosition(self.bgLayer:getContentSize().width/2,math.sin(math.rad(math.abs(180-r)))*i*16+48)
       elseif r<90 and p then
        dalte=dalte+math.abs(math.cos(math.rad(math.abs(180-r)))*16)
        sp1:setPosition(dalte,math.sin(math.rad(math.abs(180-r)))*i*16+48)
       elseif r>90 and p then
        dalte=dalte-math.cos(math.rad(math.abs(180-r)))*16
        sp1:setPosition(dalte,math.sin(math.rad(math.abs(180-r)))*i*16+48)
       elseif (r>90) and (not p) then
        dalte=dalte+math.cos(math.rad(math.abs(180-r)))*16
        if (dalte)>sizeL.width then
          sp1:setPosition(sizeL.width,math.sin(math.rad(math.abs(180-r)))*i*16+48)
          p=true
          dalte=sizeL.width- math.cos(math.rad(math.abs(180-r)))*16
        else
          sp1:setPosition(dalte,math.sin(math.rad(math.abs(180-r)))*i*16+48)
        end
        
       end
       self.bgLayer:addChild(sp1,0)
       table.insert(previewFight, sp1)
     end
end
function MainScene:LevelUp()
  local arr=self.bgLayer:getChildren()
  for i=1,#arr,1 do
    if arr[i]:getTag()==100 then
      arr[i]:setPosition(arr[i]:getPositionX(),arr[i]:getPositionY()-64)
    end
  end
  if top=="j" then

    for j=6,1,-1 do

      for i=1,8,1 do 
        if j==1 then
          local num=math.round(math.random()*999)%7
          local sp2=ball.new("o",i,1,num)
          sp2:setPosition(64+(i-1)*64,self.bgLayer:getContentSize().height-32)
          T.o[j][i]=sp2
          self.bgLayer:addChild(sp2,2)
        else

         if T.o[j-1][i]~=nil then
          if T.o[j-1][i].index~=nil then
            T.o[j-1][i]:setNum("o",i,j)
            T.o[j][i]=T.o[j-1][i]
          else
            T.o[j][i]=nil
          end
        else
          T.o[j][i]=nil
         end

       end

      end
    end
    top="o"
 
  elseif top=="o" then
    for j=6,1,-1 do

      for i=1,9,1 do 
        if j==1 then
          local num=math.round(math.random()*999)%7
          local sp2=ball.new("j",i,1,num)
          sp2:setPosition(32+(i-1)*64,self.bgLayer:getContentSize().height-32)
          T.j[j][i]=sp2
          self.bgLayer:addChild(sp2,2)
        else

          if T.j[j-1][i]~=nil then
            if T.j[j-1][i].index~=nil then
              T.j[j-1][i]:setNum("j",i,j)
              T.j[j][i]=T.j[j-1][i]
            else
              T.j[j][i]=nil
            end
          else
             T.j[j][i]=nil
          end

        end

      end

    end
    top="j"
  end

end
function MainScene:GameOver()
  active=false
  fighterAble=false
  local label=cc.ui.UILabel.new({type=2,text="GAME OVER",font="arial",size=90,align=cc.TEXT_ALIGNMENT_CENTER})
  label:setAnchorPoint(0.5,0.5)
  label:setPosition(display.cx,size.height+60)
  local layer=cc.LayerColor:create(cc.c4b(0,0,0,0))
  layer:setPosition(0,0)
  local layerAction=cc.FadeTo:create(0.5, 180)
  layer:runAction(layerAction)
  local labelAction=cc.Sequence:create(cc.EaseSineIn:create(cc.MoveTo:create(0.4,cc.p(display.cx,display.cy)))
    ,cc.RotateBy:create(0.2,30),cc.RotateBy:create(0.4,-60),cc.RotateBy:create(0.2,30),cc.DelayTime:create(0.2)
    ,cc.CallFunc:create(function ()
      layer:removeFromParent()
      label:removeFromParent()
      self:addBall()
    end))
  label:runAction(labelAction)
  self:addChild(layer)
  self:addChild(label)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
