
local MainScene = class("MainScene", function()

	local scene = cc.Scene:createWithPhysics()
    scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    --0,0不受到重力的影响
    scene:getPhysicsWorld():setGravity(cc.p(0,0))
    return scene

end)
ball=import("app.BALL")
bLayer=import("app.BALLsLayer")

local size=cc.Director:getInstance():getVisibleSize()
local Dmove=nil
local ChangeDir=false
local r=90
local Tpos={x=0,y=0,d=0}
local active=false
local round=0
local sqtr=1.4

function MainScene:ctor()

	

  local bg= display.newSprite("background4.jpg")
  bg:pos(display.cx,display.cy)
  self:addChild(bg)

  self.bgLayer=bLayer.new()
  self:addChild(self.bgLayer)

  self.sp=self.bgLayer:getActingBall()
 
  local BLsize=self.bgLayer:getContentSize()
 local edgenode=display.newNode()
  local body=cc.PhysicsBody:createEdgeBox(cc.size(BLsize.width+64,BLsize.height+64),cc.PHYSICSBODY_MATERIAL_DEFAULT,3,cc.p(0,-64))
  body:setContactTestBitmask(0xFFFFFFFF)
  edgenode:pos(display.cx,display.cy+32)
  edgenode:setPhysicsBody(body)
  edgenode:setTag(2)
  self:addChild(edgenode)

self.bgLayer:addBall()
 self:addKeyListener()
 self:addPhysicListener()

end

function MainScene:addKeyListener()

   local listener =cc.EventListenerKeyboard:create()

  listener:registerScriptHandler(function(keyCode,event)


      
      if keyCode == 146 then
        if self.bgLayer:getfighterAble()==false then
          return
        end
        self.sp=self.bgLayer:getActingBall()
        active=true
        self.bgLayer:setfighterAble()
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
        r=r-5
        self.bgLayer:PreviewFight(-1,r)
      elseif keyCode ==127 then
        
        if active==true or (r+5-90)>75 then
          return
        end
        r=r+5
        self.bgLayer:PreviewFight(1,r)

        elseif keyCode==142 then
         --[[ for i=1,6,1 do
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
          print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj")]]
      end
      

  end,cc.Handler.EVENT_KEYBOARD_PRESSED)


  local eventDispatcher =self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

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
          self.bgLayer:BallintoTable()
          if round%6==0 then 
            self.bgLayer:LevelUp()
          end
---------------------------------------------检测玩家是否已经失败-----------------------------
          if self.bgLayer:OverCheck() then
            self:GameOver()
            r=90
            return
          end
-------------------------------------------检测和消除相同颜色的珠子---------------------------
          self.bgLayer:StopDisposure() 
-----------------------------------------------------end---------------------------------------
          active=false
          self.bgLayer:addNewBall()
          
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
          self.bgLayer:BallintoTable()
          if round%6==0 then 
            self.bgLayer:LevelUp()
          end
---------------------------------------------检测玩家是否已经失败-----------------------------
          if self.bgLayer:OverCheck() then
            self:GameOver()
            r=90
            return
          end
-------------------------------------------检测和消除相同颜色的珠子---------------------------     
          self.bgLayer:StopDisposure()
-----------------------------------------------------end---------------------------------------

          active=false
          self.bgLayer:addNewBall()

          ChangeDir=false
       end
    
  end

  local contactListener=cc.EventListenerPhysicsContact:create()
  contactListener:registerScriptHandler(onContactBegin,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
  local eventDispatcher=cc.Director:getInstance():getEventDispatcher()
  eventDispatcher:addEventListenerWithFixedPriority(contactListener, 1)
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
      self.bgLayer:addBall()
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
