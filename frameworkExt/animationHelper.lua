-----------------------------------------------------------
--动画帮助类
xse.base.animal = {}

---显示动画,打开一居中显示的ui
--@param node cc.Node 当前要显示的节点
--@param p cc.Node 当前node要添加到的父节点，如果当前的节点为空，就不添加到任何对象中
function xse.base.animal.showOnCenter(node,p,removecallback,binder,showCompalateCallback,orderIndex)
    node:ignoreAnchorPointForPosition(false)
    node:setPosition(xse.base.center())
    xse.base.animal.alert(node,p or xse.base.Scene,showCompalateCallback,orderIndex)
    xse.base.block.setblock(node,true,function()
        xse.base.animal.hideAlert(node)
        local r,e = pcall(removecallback)
    end,binder)
end

---显示动画像alert一样打开ui
--@param node cc.Node 当前要显示的节点
--@param p cc.Node 当前node要添加到的父节点，如果当前的节点为空，就不添加到任何对象中
function xse.base.animal.alert(node,p,showCompalateCallback,orderIndex)
    if p then p:addChild(node,orderIndex or 99999) end
    node:setVisible(true)
    local scale = node:getScale()
    node:setScale(0.9)
    local action = cc.EaseElasticOut:create(cc.ScaleTo:create(scale,scale),0.3)
    local seq = cc.Sequence:create(action,cc.CallFunc:create(function()
        if showCompalateCallback then showCompalateCallback() end
    end))
    node:runAction(seq)
end

---显示动画 比下向上展示一个ui
--@param node cc.Node 当前要显示的节点
--@param p cc.Node 当前node要添加到的父节点，如果当前的节点为空，就不添加到任何对象中
--@param hasAnimal 是否有过程动画，默认的为有过程动画
function xse.base.animal.show(node,p,showComplateCallBack,hasAnimal)
    --    local function createSimpleDelayTime()
    --        return cc.DelayTime:create(0.25)
    --    end

    if p then p:addChild(node) end
    node:setVisible(true)
    if hasAnimal == true or hasAnimal == nil then
        local x,y = node:getPositionX(), node:getPositionY()
        node:setPosition(x,-(cc.Director:getInstance():getVisibleSize().height))
        --    local action = cc.EaseElasticOut:create(cc.MoveTo:create(1.0,ccp(x,y)),0.5)
        local action = cc.MoveTo:create(0.3,ccp(x,y))
        local callback = cc.CallFunc:create(function()
            if showComplateCallBack then
                showComplateCallBack()
            end
        end)
        local seq = cc.Sequence:create(action,callback)
        node:runAction(seq)
    elseif showComplateCallBack then
        showComplateCallBack()
    end
end

---隐藏动画
--@param node cc.Node 要隐藏的对象
--@param remove boolean 是否从父对象中，移除之后这个对象就不能再使用
function xse.base.animal.hide(node,remove)
    remove = remove or true
    local function createSimpleDelayTime()
        return cc.DelayTime:create(0.25)
    end

    if p then p:addChilde(node) end
    node:setVisible(true)
    local x,y = node:getPositionX(), node:getPositionY()
    local action = cc.MoveTo:create(0.2,ccp(x,-(cc.Director:getInstance():getVisibleSize().height)))
    --    action = action:reverse()
    local seq1 = nil
    if remove == true then
        seq1 = cc.Sequence:create(action,cc.CallFunc:create(function(node)  node:removeFromParent() end))
    else
        seq1 = cc.Sequence:create(action)
    end
    node:runAction(seq1)
end

---是否为新的标示
--@param spr cc.Sprite 是为新的标示
--@param isnew boolean 是否为新的
function xse.base.animal.isNew(spr,isnew)
    assert(spr,"argment spr is nil value")
    if not isnew and spr.action~=nil then
        spr:stopAction(spr.action)
    else
        local pos = spr:getPosition()
        local offset = 30
        local moveto = cc.MoveTo:create(0.5,cc.p(pos.x,pos.y+offset))
        local easeOut = cc.EaseOut:create(moveto,1)
        local moverevet = easeOut:reverse()
        local action = cc.Sequence:create(easeOut,moverevet)
        local foreverAction = cc.RepeatForever:create(action);
        spr:runAction(foreverAction)
        spr.action = foreverAction
    end
end

---隐藏动画
--@param node cc.Node 要隐藏的对象
--@param remove boolean 是否从父对象中，移除之后这个对象就不能再使用
function xse.base.animal.hideAlert(node,remove)
    remove = remove or true
    node:setVisible(true)
    local posX,posY =node:getPositionX() ,node:getPositionY()
    local action = cc.EaseElasticIn:create(cc.ScaleTo:create(0.9,0.9),0.3)
    --    local move = cc.MoveTo:create(0.3,cc.p(posX,posY+130))
    local seq1 = nil
    --    node:runAction(action)
    if remove == true then
        seq1 = cc.Sequence:create(action,cc.CallFunc:create(function(node)
            node:removeFromParent() end))
    else
        seq1 = cc.Sequence:create(action)
    end
    node:runAction(seq1)
end


---scrollView 滚动控制
--@param node cc.ScrollView 滚动对象
--@param dir number  0 内容向上滚动，1，内容向右滚动，2内容向下滚动，3内容向上滚动
--@param step type 步长10
function xse.base.animal.ScrollViewMove(node,dir,step)
    step = step or 10
    local currentOffset = node:getContentOffset()
    local maxoffset = node:maxContainerOffset()
    local minoffset = node:mimContainerOffset()
    local offset = cc.p(0,0)
    --内容向上
    if dir == 0 then offset.y= offset.y + step end
    --内容向右
    if dir ==1 then offset.x = offset.x - step  end
    if dir ==2 then offset.y = offset.y - step end
    if dir ==3 then offset.x = offset.x + step end

    offset.x = xse.base.numberBetween(offset.x,mixoffset.x,maxoffset.y)
    offset.y = xse.base.numberBetween(offset.y,mixoffset.y,maxoffset.y)

    node:setContentOffset(offset,true)
end

function xse.base.animal.ScrollViewMove(node,dir,step)
    step = step or 10
    local currentOffset = node:getContentOffset()
    local maxoffset = node:maxContainerOffset()
    local minoffset = node:mimContainerOffset()
    local offset = cc.p(0,0)
    --内容向上
    if dir == 0 then offset.y= offset.y + step end
    --内容向右
    if dir ==1 then offset.x = offset.x - step  end
    if dir ==2 then offset.y = offset.y - step end
    if dir ==3 then offset.x = offset.x + step end

    offset.x = xse.base.numberBetween(offset.x,mixoffset.x,maxoffset.y)
    offset.y = xse.base.numberBetween(offset.y,mixoffset.y,maxoffset.y)

    node:setContentOffset(offset,true)
end


function xse.base.animal.FadOut(node,callfun)
    local action_ = cc.FadeOut:create(0.2)
    local action =nil
    if callfun~= nil and type(callfun) =="function" then
        action = cc.Sequence:create(action_,cc.CallFunc:create(callfun))
    else action= action_
    end
    node:runAction(action)
end

---血条动画，在战斗中会使用
function  xse.base.animal.showBloodEffect(node,pos)
    pos = pos or {x = node:getPositionX(),y = node:getPositionY()}
    --set tips
    node:ignoreAnchorPointForPosition(false)
    node:setPosition(pos)
    local x,y = pos.x,pos.y + 40
    local stay_delay = cc.DelayTime:create(0.2)
    local moveto = cc.MoveTo:create(0.5,cc.p(x,y))
    local action = cc.Sequence:create(stay_delay,moveto,cc.CallFunc:create(function(n)
        n:getParent():removeChild(n)
    end))
    node:runAction(action)
end

---选中道具的动画效果
function xse.base.animal.parcelSelected(node,bool)
    bool = bool or true
    local tag = 9999
    local action = node:getActionByTag(tag)
    if action and bool == false  then
        action:stop()
    else
        local scalex,scaley = node:getScaleX(),node:getScaleY()
        local zoomOut = 0.9
        node:setScaleX(zoomOut * scalex)
        node:setScaleY(zoomOut * scaley)
        local action = cc.ScaleTo:create(0.2,scalex,scaley)
        local actionrev = cc.ScaleTo:create(0.2,zoomOut * scalex,zoomOut * scaley)
        local seq = cc.Sequence:create(action,actionrev)
        local repeater = cc.RepeatForever:create(seq)
        repeater:setTag(9999);
        node:runAction(repeater)
    end
end


-----切换spriteFrame 效果
--function xse.base.animal.switchFrame(sprite,spriteFrameName)
--    bool = bool or true
--    local tag = 9999
--    local action = node:getActionByTag(tag)
--    if action and bool == false  then
--        action:stop()
--    else
--        local scalex,scaley = node:getScaleX(),node:getScaleY()
--        local zoomOut = 0.9
--        node:setScaleX(zoomOut * scalex)
--        node:setScaleY(zoomOut * scaley)
--        local action = cc.ScaleTo:create(0.2,scalex,scaley)
--        local actionrev = cc.ScaleTo:create(0.2,zoomOut * scalex,zoomOut * scaley)
--        local seq = cc.Sequence:create(action,actionrev)
--        local repeater = cc.RepeatForever:create(seq)
--        repeater:setTag(9999);
--        node:runAction(repeater)
--    end
--end

---切换spriteFrame 效果
function xse.base.animal.switchTextrue(sprite,spriteFrameName)
    ---todo::添加奇幻角色的动画
    local action = cc.FadeIn:create(0.3)
    local action1 = cc.FadeOut:create(0.1)
    local swithcAction = cc.Sequence:create(action1,cc.CallFunc:create(function()
        --        xse.base.Sprite.switchNodeByTextureName(self.node,Tags.ROLE_TAG,"JSBS"..rolesIndex..".png")
        xse.base.Sprite.switchNodeByTextureNameA(sprite,spriteFrameName)
    end),action)
    sprite:runAction(swithcAction)
end


--xse.base.animal.switchType = {
--    alphaSwitch = 1,
--}
-----切换两个层动画
--function xse.base.animal.switchLayer(sourceLayer,tagLayer,animalType)
--    switch(animalType,{
--        [xse.base.animal.switchType.alphaSwitch] = function()
--
--        end,
--        ["default"] = function()
--
--        end
--    })
--end

xse.base.animation = xse.base.animal
return xse.base.animal
