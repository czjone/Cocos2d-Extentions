effect = {}
inheritanceA(effect,object ,"object")

effect.suffix = {
    png = "png"
}

-----特效动画
----@usage effect:create(node,100,"effectFolder",5,1,2,effect.suffix.png,48)
--function effect:create(ccbnode,effsprtag,folder,prefix,count,startindex,loops,suffix,fps)
--    function self:init()
--        self.__sprites = {}
--        self.__fps = fps or cc.Director:getInstance():getFrameRate()
--        local folder_=nil
--        if folder~= nil then folder_ = folder .."/" end
--
--        for var=startindex,startindex + count do
--            local name = folder_ .. "prefix"..var .."."..suffix
--            self.__sprites[var] = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
--        end
--        self:setloops(loops or -1)
--        self.__Sprite = xse.base.getNodebyTag(ccbnode,effsprtag,"cc.Sprite")
--        return self
--    end
--
--    function  self:getSpriteNode()
--        return self.__Sprite
--    end
--
--    function self:parse()
--        if self.__tickid ~= nil then
--            xse.base.timer.tick.removeFrameTick(self.__tickid)
--        end
--    end
--
--    function self:start()
--        self.__tickid = xse.base.timer.tick.addFrameTick(self.update)
--    end
--
--    function self:stop()
--        if self.__tickid ~= nil then
--            xse.base.timer.tick.removeFrameTick(self.__tickid)
--        end
--        local parent = self.__Sprite:getParent()
--        if parent ~= nil then
--            xse.base.hide(parent,self.__Sprite)
--        end
--    end
--
--    function self:setloops(times)
--        self.__looptimesSetting = times or 1
--    end
--
--    function self:update()
--        self.__framespaner =  self.__framespaner or 0
--        self.__framespaner  = self.__framespaner  + 1
--        local framespan = self.__fps / cc.Director:getInstance():getFrameRate()
--        while self.__framespaner > framespan  do
--            self.__loops =  self.__loops or 1
--            self.__frameindex = self.__frameindex or 0
--            self.__frameindex = self.__frameindex + 1
--            if self.__frameindex > #(self.__sprites) then
--                self.__frameindex = self.__frameindex %  #(self.__sprites)
--            end
--            self.__Sprite:setSpriteFrame(self.__sprites[self.__frameindex])
--            self.__framespaner = self.__framespaner  - framespan
--        end
--    end
--
--    self:init()
--end

---检查节点中是否特效
--同一节点最多可以使用90特效,一个特效最多90fps
--150[count][id][frameDelayTime]
--id = 1~99
--51~99 为路径动画
--1~50为没有路径的位置动画,目前只支持一个action路径的动画。
--todo::多个action 叠加
--function effect.Check(node)
--    if node ~= nil then
--        for key, var in pairs(node:getChildren()) do
--            local tag = var:getTag()
--            local id = math.floor(tag % 10000 /100)
----            log("tag :"..tag .." id :".. id)
--            ---解析路径动画,只能来
--            if  tag > 150000000 and tag < 150999999 and id > 50 and id < 100 then
--
--                local function getAllActions(node)
--                    --                    local var = cc.Sprite:create()
--                    local var = node
--                    local action =  var:getActionByTag(0)
--                    local posx,posy = var:getPositionX(), var:getPositionY()
--                    local scalx,scaly = var:getScaleX(), var:getScaleY()
--                    local i = 0
--                    local actions =  {}
--                    while action ~= nil do
--                        if i == 0 then
--                            actions[i] =cc.RepeatForever:create( cc.Sequence:create(action,cc.MoveTo:create(0.00001,cc.p(posx,posy)),cc.DelayTime:create(0.001)))
--                        else
--                            actions[i] =cc.RepeatForever:create( cc.Sequence:create(action))
--                        end
--                        i= i+1
--                        action =  var:getActionByTag(i)
--                    end
--                    return actions
--                end
--
--                local function checkAllActionIsDone(node)
--                    local counter = 0
--                    local action =  node:getActionByTag(counter)
--                    local allDone = true
--                    while action ~= nil do
--                        if action:isDone() == false then allDone = fasle break; end
--                        action =  node:getActionByTag(counter)
--                        counter =  counter + 1
--                    end
--                    return allDone
--                end
--
--                local function ReRunAllAction(node,actions)
--                    node:stopAllActions()
--                    for k, v in pairs(actions) do
--                        local action =v:clone()
--                        actions[k]  = action:clone()
--                        action:setTag(k)
--                        node:runAction(action)
--                    end
--                    ---轮询
--                    --                    local forever = cc.RepeatForever:create(
--                    --                        cc.Sequence:create(
--                    --                            cc.CallFunc:create(function ()
--                    --                                if checkAllActionIsDone(node) then
--                    --                                    ReRunAllAction(node,actions)
--                    --                                end
--                    --
--                    --                            end)))
--                    --                    forever:setTag(-2)
--                    --                    node:runAction(forever)
--                end
--
--                local actions =  getAllActions(var)
--                ReRunAllAction(var,actions)
--            end
--
--            if #(var:getChildren()) > 0 then
--                effect.Check(var)
--            else
--                -- var.getOffsetPosition ~= nil and
----                log(var:getName() .. tag)
--                if  tag > 150000000 and tag < 150999999 and id > 0 and id <51 then
--                    local name = var:getName()
--                    local suffix =  name:match(".+%.(%w+)$")
--                    local prefix =  string.sub(name,1,-(#suffix + 4)) --- "s000.png" -> "s000"
--                    local count = math.floor((tag - 150000000) / 10000)
--                    local frames = {}
--                    for i = 1,count do
--                        frames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame(prefix.. math.floor((i - 1)/10) .. (i-1) % 10 .."." ..suffix)
--                    end
--                    local frameDelayTime = tag % 100
--                    local animation = cc.Animation:createWithSpriteFrames(frames,frameDelayTime /100 )
--                    animation:setRestoreOriginalFrame(true)
--                    local animate = cc.Animate:create(animation);
--                    var:runAction(cc.RepeatForever:create(animate))
--                end
--            end
--        end
--    end
--end

function effect.spriteToEffect(node,effectNamePrefix,looptimes,onreplayCallBack,oncomplateCallBack,frameDelayTime,switchDaytimes)

    frameDelayTime = frameDelayTime or 13
    switchDaytimes = switchDaytimes or 0

    local function loadframes(effectNamePrefix)
        local frames = {}
        local index = 1
        while true do
            --local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(effectNamePrefix.. math.floor((index - 1)/10) .. (index-1) % 10 .."." ..effect.suffix.png);
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(effectNamePrefix.. index .."." ..effect.suffix.png);
            if not frame then break; end;
            frames[index] =  frame;
            index = index  + 1;
        end
        return frames
    end

    local function playEffect(node,frames,oncomplate)
        local animation = cc.Animation:createWithSpriteFrames(frames,frameDelayTime /100 )
        animation:setRestoreOriginalFrame(false)
        local animate = cc.Animate:create(animation);
        local action = nil;
        action = cc.Sequence:create(
            cc.CallFunc:create(function()
                node:setVisible(false)
            end),
            cc.DelayTime:create(switchDaytimes),
            cc.CallFunc:create(function()
                node:setVisible(true)
            end),
            animate,cc.CallFunc:create(function()
                action:stop()
                node:setVisible(false)
                if oncomplate then oncomplate()  end
            end)
        )
        node:runAction(action)
    end

    local function playEffectTimes(node,frames,looptimes,onreplayerCallBack,oncomplateCallBack)
        if looptimes == 0 then return; end;
        playEffect(node,frames,function()
            looptimes = looptimes -1;
            if looptimes ==  0 then
                oncomplateCallBack()
            else
                if onreplayerCallBack then
                    onreplayerCallBack(looptimes)  end
                playEffectTimes(node,frames,looptimes,onreplayerCallBack,oncomplateCallBack  )
            end
        end)
    end

    local frames = loadframes(effectNamePrefix)
    playEffectTimes(node,frames,looptimes,onreplayCallBack,oncomplateCallBack)
    return node
end
---dt
--{
--      {node,effectNamePrefix,looptimes,onreplayCallBack,oncomplateCallBack,frameDelayTime},
--      {node,effectNamePrefix,looptimes,onreplayCallBack,oncomplateCallBack,frameDelayTime},
--      {node,effectNamePrefix,looptimes,onreplayCallBack,oncomplateCallBack,frameDelayTime},
--      {node,effectNamePrefix,looptimes,onreplayCallBack,oncomplateCallBack,frameDelayTime},
--}
local function spriteToEffectByConfig(effectConfig , index)
    index = index or 1
    if (effectConfig == nil or  #effectConfig == 0) and index <= #effectConfig then return ; end;
    effect.spriteToEffect(
        effectConfig[index].node,
        effectConfig[index].effectNamePrefix,
        effectConfig[index].looptimes,
        effectConfig[index].onreplayCallBack,
        function()
            local action =  effectConfig[index].oncomplateCallBack
            if action ~= nil then action() end
            if index < #effectConfig then
                spriteToEffectByConfig(effectConfig , index + 1)
            end
        end,
        effectConfig[index].frameDelayTime)
end

function effect.layerEffectReset(layer)
    for key, var in pairs(layer:getChildren()) do
        var:setVisible(false)
    end
end

function effect.layerToEffect(layer,effectConfig , index)
    effect.layerEffectReset(layer)
    spriteToEffectByConfig(effectConfig , index)
end

function effect.stop(node)
    node:removeFromParent()
end

