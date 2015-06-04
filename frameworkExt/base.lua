-- --[[
--                   _oo0oo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  0\  =  /0
--                ___/`---'\___
--              .' \\|     |-- '.
--             / \\|||  :  |||-- \
--            / _||||| -:- |||||- \
--           |   | \\\  -  --/ |   |
--           | \_|  ''\---/''  |_/ |
--           \  .-\__  '-'  ___/-. /
--         ___'. .'  /--.--\  `. .'___
--      ."" '<  `.___\_<|>_/___.' >' "".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `_.   \_ __\ /__ _/   .-` /  /
-- =====`-.____`.___ \_____/___.-`___.-'=====
--                   `=---='
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--          佛祖保佑   永无BUG   永不修改
-- ]]

----------------------------------------------------
-- game helper extention by cocos2d
--当前对象
xse = {}
xse.base = {}
local private = {}

require "Cocos2d"
require "Cocos2dConstants"
require "CCBReaderLoad"

require "eventFiler"

------------------------------------------------------
---使用共享代理
--local  proxy = cc.CCBProxy:create()
xse.base.Scene = nil
xse.base.config = require "config" --defualt config set

function isDebug()
    return  xse and xse.base and xse.base.config and xse.base.config.debug == true
end

-----------------------------------------------------
--debug helers
---set user define print services
if xse.base.config ~= nil and xse.base.config.logEnable == true then
    print =  LOG_PRINT or print
end

---
--@param #string msg 日志信息
function cclog(msg)
    if xse.base.config.logEnable and xse.base.config.logEnable== true then
        print(msg)
    end
end

----
--@param #boolean exp 与断言相同的使用
--@param #string msg 出警告要显示的信息
function warning(exp,msg)
    if isDebug() and ( exp == nil or exp == false) then
        cclog(tostring(msg))
    end
end

---断言
function assert(exp,msg)
    if (isDebug() or config.logEnable) and (exp == nil or exp == false) then
        cclog(tostring(msg))
        cclog(debug.traceback())
    end
    return exp
end

---函数已过期
function expired(old,new)
    assert(false,old.." function has expired, the use of alternative function "..new)
end

---日志函数
log = cclog or function(...) print(string.format(...)) end

----打印堆栈信息
function xse.base.trace (msg)
    cclog("------------------------------------")
    cclog(tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("------------------------------------")
end

----打印堆栈信息
function xse.base.traceStack(msg)
    if msg then log(msg) end
    cclog(debug.traceback())
end

---switch 语句的实现
--@param #firsttype var_ 可用于比较的任何值
function switch(var_,tb)
    for key, var in pairs(tb) do
        assert(type(var)=="function","var must a function")
        --assert(type(key)==type(var_),"types must === ..") ---不能做类型检查。default会出现问题
        if key == var_ then
            xpcall(var,xse.base.trace);
            return ;
        end
    end
--    local fun = tb["default"]
--    assert(fun~=nil ,"switch case not set default case.")
--    pcall(fun)
end

---三元去算符号的实现
function ternary(condition,expTrue,expFalse,args)
    if condition == true then return expTrue
    else return expFalse end
end

---互斥调用
function mutexCall(exp,calltrue,callfalse,args)
    local r,e =nil,nil
    if exp == true then
        r,e= pcall(calltrue,args)
    else
        r,e = pcall(callfalse,args)
    end
    assert(e== nil, e)
end

---debug模式下才会执行的函数
function debugCallFun(fun,args)
    mutexCall(isDebug() == true,fun,function() end,args)
end

---发布版本才执行的函数
function releaseCallFun(fun,args)
    mutexCall(isDebug()  == false,fun,function() end,args)
end

---------------------------------------------------------------
--屏幕适配逻辑
--
function xse.base.getResouceConfig(cfg)
    local type_;
    local size  = xse.base.winSize()
    for k,v in pairs(cfg.DES_RES_TYPE) do
        if (v.default and v.default == true) or (v.width == size.width and  v.height == size.height) then
            type_ =  v
        end
    end
    return type_
end

function xse.base.setSearchPathByPath(path)
    cc.FileUtils:getInstance():addSearchResolutionsOrder(path);
--cc.FileUtils:getInstance():addSearchPath(path)
end

function xse.base.setSearchPathByPathes(pathes)
    for key, var in pairs(pathes) do
        xse.base.setSearchPathByPath(var)
    end
end

function xse.base.setSearchPath(type_)
    for k,v in pairs(type_.res) do
        xse.base.setSearchPathByPath(v)
    end
end

function xse.base.setSearchPathA(cfg)
    local type_ = xse.base.getResouceConfig(cfg)
    xse.base.setSearchPath(type_)
end

function xse.base.adapter(cfg)
    local glview = cc.Director:getInstance():getOpenGLView()
    local size  = xse.base.winSize()
    local type_ = xse.base.getResouceConfig(cfg)
    xse.base.setSearchPath(type_)
    --    log("game windows size width:" ..size.width .." height:"..size.height.. " using "..type_.name)
    --cc.RESOLUTION_POLICY:EXACT_FIT ＝0
    glview:setDesignResolutionSize(type_.rheight, type_.rwidth, 0);
--    glview:setDesignResolutionSize(type_.rheight, type_.rwidth, 1);
end

---无用的函数
--function xse.base.getScale  ()
--    local size  = xse.base.winSize()
--    if (size.height==2048 and size.width ==1536) or (size.height==1024 and size.width == 768) then
--        return 1.0; --hd 模式
--    elseif size.height / size.width <= 960.0/640.0 then
--        return 0.5; --4s模式
--    else
--        return 0.5; --iphone 5 模式，通用模式
--    end
--    return 1
--end

-----------------------------------------------------
--加载静态资源
function xse.base.loadRes()
    if xse.base.config~= nil  and xse.base.config.loadRes ~= nil then
        for key, var in ipairs(xse.base.config.loadRes) do
            --            log("load splist cache:"..var)
            --            cc.SpriteFrameCache:getInstance():addSpriteFramesWithFile(var);
            cc.SpriteFrameCache:getInstance():addSpriteFrames(var..".plist",var..".png")
        end
    end
end

-----------------------------------------------------
--init the game
--@param _cfg config 游戏配置信息
function xse.base.init  (_cfg)

    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    ---缓存配置
    xse.base.config = _cfg
    ---屏幕适配
    xse.base.adapter(xse.base.config or require("config"))
    ---性能显示
    local director = cc.Director:getInstance()
    --    director:setDisplayStats(xse.base.config.showFps or false)
    --    ---路径搜索
    --    if _cfg ~=nil and _cfg.searchPath ~=nil then
    --        for i,v in ipairs(_cfg.searchPath) do
    --            local path = v
    --            cc.FileUtils:getInstance():addSearchResolutionsOrder(path);
    --        end
    --    end
    ---静态资源加载
    debugCallFun(xse.base.loadRes,args)

    ---创建主场景
    xse.base.Scene = cc.Scene:create()
    ---加载主节点
    if xse.base.config ~= nil and xse.base.config.mainNode ~= nil then
        local args = xse.base.config.mainNodeArgs
        local n =xse.base.loadBllNode(xse.base.config.mainNode)
        --        if n~=nil then  xse.base.Scene:addChild(n)  end
    end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(xse.base.Scene)
    else
        cc.Director:getInstance():runWithScene(xse.base.Scene)
    end

    return 1
end

---@return #table {width=?,height=?,nil} 屏幕大小
function xse.base.winSize  ()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    return visibleSize
end
---得到屏幕的中心点
--@return table {width=?,height=?,nil} 屏幕中心位置坐标
function xse.base.center()
    local winSize =  xse.base.winSize()
    return cc.p(winSize.width/2.0,winSize.height/2.0)
end

-------------------------------------------------------------
-- 运行游戏
function xse.base.run ()
    if xse.base.Scene ==nil then xse.base.Scene = cc.Scene:create() end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(xse.base.Scene)
    else
        cc.Director:getInstance():runWithScene(xse.base.Scene)
    end
end

------------------------------------------------------------

function xse.base.playBackgroundSound(backgroundMusicName)
--    if xse.base.config.debug == nil or xse.base.config.debug ~= true then
--        cc.SimpleAudioEngine:getInstance():stopMusic()
--        cc.SimpleAudioEngine:getInstance():playMusic(backgroundMusicName,true)
--    end
end

------------------------------------------------------------
--load bll node
function xse.base.loadBllNode(m,args)
    --    log("load mode :"..m)
    local cls = require (m)
    local res = nil
    if xse.base ~= nil then
        assert(cls.new,"not found ctor")
        assert(cls.open,"init 函数已改成open 函数")
        local obj = cls.getInstance()
        obj:open(args)
    end
    --    xse.base["this"] =  res
    assert(xse.base,"load bll molde error. model:"..m)
    return res
end

---加载业务模块
function xse.base.showBllNode(p,n)
    expired("xse.base.showBllNode","nil")
    local node = xse.base.loadBllNode(n)
    if node ~= nil then
        -- p:addChild(node)
        -- local scene = cc.Scene:create()
        -- scene:addChild(node)
        -- cc.Director:getInstance():pushScene(scene)
        node:ignoreAnchorPointForPosition(false)
        xse.base.show(p or xse.base.Scene,node)
    end
    return node
end

---直接显示open 业务模块
function xse.base.openBLLModel(cls)
    assert(cls,"cls is a nil value")
    assert(cls.new,"cls:new is a nil value")
    assert(cls.open,"cls:open is a nil value")
    local obj = cls:new()
    obj:open()
end

---在屏幕中心打开一个模块
--已过时
function xse.base.showBllNodeOnCenter(p,n)
    expired(" xse.base.showBllNodeOnCenter","")
    assert(false,"")
    local node = xse.base.loadBllNode(n)
    if node ~= nil then
        node:ignoreAnchorPointForPosition(false)
        xse.base.showNodeOnSceneCenter(node)
    end
    return node
end

function  xse.base.openModel(parameters)

end

---移除业务模块
function xse.base.removeBLLNode ( p,n )
    assert(n,"p and is not allow nil")
    if n then
        n:removeFromParent()
    end
end


-----------------------------------------------------------
--xse.base.EventFiler = {}--xse.base.EventFiler or {}
--xse.base.EventFiler.enable =  false --xse.base.EventFiler.enable or false
--xse.base.EventFiler.notFilerEvents = {}-- xse.base.EventFiler.notFilerEvents or {}
--
--function xse.base.EventFiler.setEnable(state)
--    xse.base.EventFiler.enable = state
--end
-----检查当前事件是否为被过滤掉的事件
--function xse.base.EventFiler.Check(key)
--    ---如果是过滤掉的就返回true
--    return xse.base.EventFiler.enable and xse.base.EventFiler.notFilerEvents[key] == nil
--end
--
--function xse.base.EventFiler.addAllowEvent(key)
--    if not key then return end
--    xse.base.EventFiler.notFilerEvents[key] = 1
--end
--
--function xse.base.EventFiler.removeAllowEvent(key)
--    if not key then return end
--    xse.base.EventFiler.notFilerEvents[key] = nil
--end

-----------------------------------------------------------
--ccbil加载
function xse.base.showCCBI(p, n ,o)
    local _n = xse.base.loadCCBI(n,o)
    if _n~=nil then
        xse.base.show(p or  xse.base.Scene,_n)
    end
    return _n
end

function xse.base.showCCBIA (p, n)
    local o = n.."owner"
    ccb[o] = {}
    return xse.base.showCCBI(p,n,o)
end

--repalce the ccbi node by exits node
function xse.base.replaceCCBI(p,r, n,o)
    local n = xse.base.loadBllNode(n)
    xse.base.hideA(p,r)
    xse.base.showCCBI(p,n,o)
    return n
end

--load a new ccbi node and create a new instance,
--sw 是否可以 穿透
function xse.base.loadScene  (n ,o,sw)

    if n == nil then return end
    --    xse.base.unloadUnUsedTexture()
    --    log("load ccbi file:",n)
    if sw == nil then sw = false end
    local  node = nil
    local  proxy = cc.CCBProxy:create()
    if o ~= nil then
        ccb["owner_for_G"] = ccb["owner_for_G"] or {}
        node  = CCBReaderLoad(n,proxy, true,ccb["owner_for_G"])
    else node  = CCBReaderLoad(n,proxy)
    end
    assert(node,"load ui resource by script error.")
    --对node进行命名tag命名
    node:setTag(1111111)
    if sw == false then
        xse.base.block.setlayerblock(node)
    end
    xse.base.effect.Check(node)
    return node
end

---加载一个CCBI对象为cc.node对象
--@param swallow boolean 默认为true
function xse.base.loadCCBI(n ,o,swallow)
    if n == nil then return end
    --    xse.base.unloadUnUsedTexture()
    --    log("load ccbi file:",n)
    if swallow == nil then  swallow = false end
    local  node = nil
    local  proxy = cc.CCBProxy:create()
    if o ~= nil then
        ccb["owner_for_G"] = ccb["owner_for_G"] or {}
        node  = CCBReaderLoad(n,proxy, true,ccb["owner_for_G"])
    else node  = CCBReaderLoad(n,proxy)
    end
    assert(node,"load ui resource by script error.")
    --对node进行命名tag命名
    node:setTag(1111111)
    if swallow == true then
        xse.base.block.setlayerblock(node)
    end
    xse.base.effect.Check(node)
    return node
end

---加载一个CCBI对象为cc.node对象
--@param swallow boolean 默认为true
function xse.base.loadSceneCCBI(n ,o,swallow)
    if n == nil then return end
    --    xse.base.unloadUnUsedTexture()
    --    log("load ccbi file:",n)
    swallow = swallow or true
    local  node = nil
    local  proxy = cc.CCBProxy:create()
    if o ~= nil then
        ccb["owner_for_G"] = ccb["owner_for_G"] or {}
        node  = CCBReaderLoad(n,proxy, true,ccb["owner_for_G"])
    else node  = CCBReaderLoad(n,proxy)
    end
    assert(node,"load ui resource by script error.")
    --对node进行命名tag命名
    node:setTag(1111111)
    if swallow == true then
        xse.base.block.setlayerblock(node)
    end
    xse.base.effect.Check(node)
    return node
end

---设置指定的节点是否为可见
function xse.base.setVisibleByTag ( ccb, tag ,b)
    assert(ccb,"ccb is a nil argment")
    local _cb = ccb:getChildByTag(tag)
    --    local tagttf = tolua.cast(_cb,"cc.Node")
    _cb:setVisible(b)
end

----------------------------------------------------------------------------------------
--node 相关的帮助函数

--get node by taget frome then ccbi root
function xse.base.getNodebyTag ( node,tag, _type )
    _type = _type or "cc.Node"
    if node then
        local n =  node:getChildByTag(tag)
        if n== nil then
            --        log("not found target,target num:"..tag)
            return nil
        end
        if _type then
            n =  tolua.cast(n,_type)
        end

        assert(n,"get node con't cast to target.")
        return n
    end
    return nil
end

function xse.base.getNodeVisible(node)
    local  isVisible = node:isVisible()
    if isVisible == true then
        local parent =  node:getParent()
        if parent == nil then return true
        else return xse.base.getNodeVisible(node:getParent()) end
    else
        return false
    end
end

--add a node to the ccbi node
function xse.base.addToTag ( ccblayer,tag, node )
    local n =  xse.base.getNodebyTag(ccblayer,tag,"cc.Node")
    n:addChild(node)
    return n
end

--clear a not by target form ccbi node root
function xse.base.clearTag( ccb,tag)
    local n =  xse.base.getNodebyTag(ccb,tag,"cc.Node")
    n:removeAllChildren()
    return n
end


------------------------------------------------------------------------------------------
--按钮相关的帮助函数

--set the label display string for the target node found in ccbi root
function xse.base.setCCLableTTFString  ( ccb, tag ,str)
    --must used  label not lable ttf.
    --    log("set ttf string.tag:"..tag);
    assert(ccb ,"ccb is a nil arg.")
    assert(tag ,"tag is a nil arg.")
    assert(str ,"str is a nil arg.")
    local _cb = ccb:getChildByTag(tag)
    assert(_cb,"cb is a nil value")
    local tagttf = tolua.cast(_cb,"cc.Label")
    tagttf:setString(str or "-")
end

function xse.base.setCCBottonStringA ( bt,str)
    bt:setTitleForState(str or "-",cc.CONTROL_STATE_NORMAL)
end

--set the botton display string for the target node found in ccbi root
function xse.base.setCCBottonString ( ccb, tag ,str)
    local bt = ccb:getChildByTag(tag)
    xse.base.setCCBottonStringA ( bt,str)
end

--set the botton select state
function xse.base.setCCBottonSelecteStateByBotton ( bt ,b)
    local tagttf = tolua.cast(bt,"cc.ControlButton")
    tagttf:setHighlighted(b)
end

--set the botton select state
function xse.base.setCCBottonSelecteState ( ccb, tag ,b)
    local _cb = ccb:getChildByTag(tag)
    local tagttf = tolua.cast(_cb,"cc.ControlButton")
    -- tagttf:setSelected(b)
    tagttf:setHighlighted(b)
    --    xse.base.setCCBottonDisableState(ccb,tag,true)
end


function xse.base.setCCBottonEnabledStateA ( bt ,b)
    xse.base.setCCBottonSelecteStateByBotton ( bt ,b)
end

--set the botton enabled state
function xse.base.setCCBottonEnabledState ( ccb, tag ,b)
    local _cb = ccb:getChildByTag(tag)
    xse.base.setCCBottonEnabledStateA ( _cb ,b)
end


function xse.base.setCCBottonOnClick(bt,func,instance,sw,key)

    bt:registerControlEventHandler(
        function(sender)
            if eventFiler:canExecute(key) == true then
                eventFiler:addExecuteEventKey(key)
                func(instance,sender)
            end

        end,
        --cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
        cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)

    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("@995.png")
    local btsprite = cc.Sprite:createWithSpriteFrame(spriteFrame)
    btsprite:setScaleX(bt:getContentSize().width)

    btsprite:setScaleY(bt:getContentSize().height)
    btsprite:setAnchorPoint(bt:getAnchorPoint())
    btsprite:setPosition(cc.p(bt:getContentSize().width/2,bt:getContentSize().height/2))
    bt:addChild(btsprite,-999999)
    if sw == nil then  sw = true end
    if sw ~= false then return nil end
    xse.base.Sprite.setOnClickEvent(btsprite,function(sender)  end,"",bt,sw)
end
---在按下按钮时事件

function xse.base.setCCBottonOnClickA(getbtfun,func,instance)
    local bt = getbtfun()
    xse.base.setCCBottonOnClick(bt,func,instance)
end
---在按下按钮时事件
function xse.base.setCCBottonOnClickB(node,tag,func,instance)
    local bt = node:getChildByTag(tag)
    xse.base.setCCBottonOnClick(bt,func,instance)
end
---在按下按钮时事件
function xse.base.setCCBottonOnClickC(bt,title,callback,instance)
    xse.base.setCCBottonStringA(bt,title)
    xse.base.setCCBottonOnClick(bt,callback,instance)
end

---在按下按钮时事件
function xse.base.setCCBottonOnClickD(bt,func,instance,sw,key)
    bt:registerControlEventHandler(
        function(sender)
            if eventFiler:canExecute(key) == true then
                eventFiler:addExecuteEventKey(key)
                func(instance,sender)
            end
        end,
        --        cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
        cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)--处理有的按钮穿透
    --cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)

    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame("@995.png")
    local btsprite = cc.Sprite:createWithSpriteFrame(spriteFrame)
    btsprite:setScaleX(bt:getContentSize().width)


    btsprite:setScaleY(bt:getContentSize().height)
    btsprite:setAnchorPoint(bt:getAnchorPoint())
    btsprite:setPosition(cc.p(bt:getContentSize().width/2,bt:getContentSize().height/2))
    bt:addChild(btsprite,-999999)
    if sw ~= true then  sw = false end
    xse.base.Sprite.setOnClickEvent(btsprite,function(sender)  end,"",bt,sw)
end
---
function xse.base.setCCBottonDisableState ( ccb, tag ,b)
    local _cb = ccb:getChildByTag(tag)
    local tagttf = tolua.cast(_cb,"cc.ControlButton")
    tagttf:setEnabled(b)
end

function xse.base.setCCBottonDisableStateA (bt ,b)
    bt:setEnabled(b)
end

function xse.base.setCCBottonDisableStateA ( tb ,b)
    tb:setEnabled(b)
end

---迭代指定的id
function xse.base.setRadioSelected(node,startid,endid,selectid)
    for var=startid, endid do
        if node:getChildByTag(var) ~=nil then
            xse.base.setCCBottonSelecteState(node,selectid,selectid == var)
        end
    end
end

---
function xse.base.setRadioSelectedLayer(sender)
    local id = sender:getTag()
    local layer = sender:getParent()
    local count = layer:getChildrenCount()
    xse.base.setRadioSelected(layer,id - count,id + count,id)
end

-------------------------------------------------------------------------------------------------
---layer helper

---convert then layer to text editor.
function xse.base.layerToEditor(p,tag,s1,s2,multiline)
    local defaultPng = cc.SpriteFrameCache:getInstance():getSpriteFrame("@995.png")
    assert(defaultPng,"default sprite frame is a nil")
    local n=p:getChildByTag(tag)
    local scale9Sprite1 =  cc.Scale9Sprite:createWithSpriteFrame(s1 or defaultPng)
    local scale9Sprite2 =  cc.Scale9Sprite:createWithSpriteFrame(s2 or defaultPng)
    local editor =  cc.EditBox:create(n:getContentSize(),scale9Sprite1,scale9Sprite2)
    editor:setAnchorPoint(ccp(0,0))
    n:addChild(editor)

    --    则Multiline 选成True ,Auto HScroll
    if multiline == true then
    --        editor:setm
    ---TODO::多行文字输入的支持
    end

    ---设置编辑框是否为编辑状态
    function editor.enalbleEditState(self,enable)
        editor.__editor_Enalble = editor.__editor_Enalble or false
        editor.__editor_Enalble = not editor.__editor_Enalble
    end

    function editor.getEnalbleEditState(self)
        return editor.__editor_Enalble == true
    end

    return editor
end

function xse.base.toCheckBox(instance,layer,onselectChanged)
    local checkBox = xse.base.getNodebyTag(layer,101,"cc.Node"):getChildByTag(10)
    xse.base.setCCBottonOnClick(checkBox,
        function(instance)
            if checkBox:isSelected() == true then
                checkBox:setHighlighted(false)
                checkBox:setSelected(false)
            else
                checkBox:setHighlighted(true)
                checkBox:setSelected(true)
            end
            if onselectChanged~=nil and type(onselectChanged) == "functon" then
                onselectChanged()
            end
        end,instance)
    return checkBox
end

function xse.base.isChecked(checkBox)
    return checkBox:isSelected()
end

-----------------------------------------------------
--effect supports
xse.base.effect = {}

local EffectTags = {
    MAX = 150999999,
    MIN = 150000000
}

local pathAnimationTags = {
    MAX = 100,
    MIN = 50
}

local MAXFrames = 99


local str = ""
---检查节点中是否特效
--同一节点最多可以使用90特效,一个特效最多90fps
--150[count][id][frameDelayTime]
--id = 1~99
--51~99 为路径动画
--1~50为没有路径的位置动画,目前只支持一个action路径的动画。
--todo::多个action 叠加
function xse.base.effect.Check(node,frameloop,DelayLoopTime)
    frameloop = frameloop or true
    if node ~= nil then
        for key, var in pairs(node:getChildren()) do
            local tag = var:getTag()
            local id = math.floor(tag % 10000 / 100)
            -- log("tag :"..tag .." id :".. id)
            ---解析路径动画,只能来
            if  tag < EffectTags.MAX and tag > EffectTags.MIN and id > pathAnimationTags.MIN and id < pathAnimationTags.MAX then
                local function getAllActions(node)
                    --local var = cc.Sprite:create()
                    local var = node
                    local action =  var:getActionByTag(0)
                    local posx,posy = var:getPositionX(), var:getPositionY()
                    local scalx,scaly = var:getScaleX(), var:getScaleY()
                    local i = 0
                    local actions =  {}
                    while action ~= nil do
                        if i == 0 then
                            actions[i] =cc.RepeatForever:create( cc.Sequence:create(action,cc.MoveTo:create(0.00001,cc.p(posx,posy)),cc.DelayTime:create(0.001)))
                        else
                            actions[i] =cc.RepeatForever:create( cc.Sequence:create(action))
                        end
                        i= i+1
                        action =  var:getActionByTag(i)
                    end
                    return actions
                end

                local function checkAllActionIsDone(node)
                    local counter = 0
                    local action =  node:getActionByTag(counter)
                    local allDone = true
                    while action ~= nil do
                        if action:isDone() == false then allDone = fasle break; end
                        action =  node:getActionByTag(counter)
                        counter =  counter + 1
                    end
                    return allDone
                end

                local function ReRunAllAction(node,actions)
                    node:stopAllActions()
                    for k, v in pairs(actions) do
                        local action =v:clone()
                        actions[k]  = action:clone()
                        action:setTag(k)
                        node:runAction(action)
                    end
                end

                local actions =  getAllActions(var)
                ReRunAllAction(var,actions)
            end

            if #(var:getChildren()) > 0 then
                xse.base.effect.Check(var)
            else
                --                -- var.getOffsetPosition ~= nil and
                --                -- log(var:getName() .. tag)
                if  tag >= EffectTags.MIN and tag < EffectTags.MAX and id >= 0 and id <= pathAnimationTags.MIN then

                    local name = var:getName()
                    local suffix =  name:match(".+%.(%w+)$")
                    local num = #name:match("%d+%.")
                    local prefix =  string.sub(name,1,-(#suffix + num + 1)) --- "s000.png" -> "s000"
                    local count = MAXFrames
                    local frames = {}
                    for i = 1,count do
                        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(prefix.. tostring(i - 1) .."." ..suffix)
                        if spriteFrame == nil then break; end
                        frames[i] = spriteFrame
                    end

                    local random = xse.base.random()
                    ---增加随机功能
                    local reorderFrame =  {}
                    for i = 1, #frames do
                        reorderFrame[i] =  frames[(i + random)% (#frames)]
                    end
                    frames = reorderFrame

                    local frameDelayTime = tag % 100

                    if DelayLoopTime ~= nil then
                        local animation = cc.Animation:createWithSpriteFrames(frames,frameDelayTime /100 )
                        animation:setRestoreOriginalFrame(false)
                        local animate = cc.Animate:create(animation);
                        local seq = cc.Sequence:create(animate,cc.DelayTime:create(3))
                        local action = cc.RepeatForever:create(seq)
                        var:runAction(seq)
                    else
                        local animation = cc.Animation:createWithSpriteFrames(frames,frameDelayTime /100 )
                        animation:setRestoreOriginalFrame(frameloop)
                        local animate = cc.Animate:create(animation);
                        local action = cc.RepeatForever:create(animate)
                        var:runAction(action)
                    end
                end
            end
        end
    end
end

function xse.base.effect.setVisible(node,bool)
    for key, var in pairs(node:getChildren()) do
        local tag =  var:getTag()
        if tag < EffectTags.MAX and tag > EffectTags.MIN then
            var:setVisible(bool)
        else
            xse.base.effect.setVisible(var,bool)
        end
    end
end

----------------------------------------------------
--
xse.base.scrollView = {}
function xse.base.scrollView.isScrollView(scrollNode)
    return scrollNode.isClippingToBounds ~= nil and scrollNode.scrollToRight==nil
end

function xse.base.scrollView.fixeScrollBug(scrollNode)
    assert(false,"还没完善的逻辑")
    local function onTouchBegan(touch, event)   return true  end
    local function onTouchMoved(touch, event)  end
    local function onTouchEnded(touch, event)  end

    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )

    scrollNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,scrollNode)
end

---如果tag 为空就处理tag 不为空就处理node
--对属性的不完全支持，有bug再加
function xse.base.scrollView.ToUIScrollview(node,tag)
    assert(false,"还没完善的逻辑")
    assert(node,"argument node is a nil value.")
    local scrollNode =  node;
    if tag ~=nil then
        scrollNode = node:getChildByTag(tag)
    end
    assert(scrollNode,"not found srollview node")
    if scrollNode.isClippingToBounds ~= nil and scrollNode.scrollToRight==nil then
        local contentLayer =   scrollNode:getContainer()
        local zorder = scrollNode:getLocalZOrder()
        local size = scrollNode:getViewSize()
        local children = contentLayer:getChildren()
        local isBounceEnabled = scrollNode:isBounceable()
        local posx,posy = scrollNode:getPositionX(),scrollNode:getPositionY()
        local ignoreAnchorPointForPosition = scrollNode:isIgnoreAnchorPointForPosition()
        local anchorPoint = scrollNode:getAnchorPoint()
        local getDirection = scrollNode:getDirection()
        local isClippingEnabled = scrollNode:isClippingToBounds()

        local scrollNodeNew = cc.ScrollView:create()
        scrollNodeNew:setViewSize(size)
        --scrollNodeNew:setTag(scrollNode:getTag())
        --再次bug
        scrollNodeNew:setPositionX(posx)
        scrollNodeNew:setPositionY(posy)
        scrollNodeNew:setAnchorPoint(anchorPoint)
        scrollNodeNew:ignoreAnchorPointForPosition(ignoreAnchorPointForPosition)
        scrollNodeNew:setBounceable(isBounceEnabled)
        scrollNodeNew:setDirection(getDirection)
        scrollNodeNew:setClippingToBounds(isClippingEnabled)

        --[bug]scrollNode:removeAllChildrenWithCleanup(false)
        local newLayer = scrollNodeNew:getContainer()
        for key, var in pairs(children) do
            contentLayer:removeChild(var,false)
            scrollNodeNew:addChild(var)
        end

        --        scrollNode:getParent():addChild(scrollNodeNew,zorder,scrollNode:getTag())
        scrollNode:getParent():removeChild(scrollNode)
    end
end

--function xse.base.scrollView.focusBottom(scrollView)
--
--end
--
--function xse.base.scrollView.focusTop(scrollView)
--
--end



--function xse.base.menuHelper.getScrollMenu(scrollview)
--    assert(false,"没有测试过的函数")
--    local layer = uinode.node:getChildByTag(scrollviewTag)
--    local menu = nil
--    assert(#(layer:getChildren())==1,"一个scrollview 有且只有一个menu，tagId必须设置成500")
--    local tempItems = layer:getChildren()[1]:getChildren()
--    for key, var in pairs(tempItems) do
--        if var:getTag()== 500 then menu =var break; end
--    end
--    assert(menu,"一个scrollview 有且只有一个menu，tagId必须设置成500")
--end

function xse.base.scrollView.layerCreateScrollView(contentLayer,scrollTag)
    local scrollview = cc.ScrollView:create()
    scrollview:setContentSize(contentLayer:getContentSize())
    scrollview:setViewSize(contentLayer:getContentSize())
    scrollview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    scrollview:setTag(scrollTag or 500)
    contentLayer:addChild(scrollview)
    return scrollview
end

------------------------------------------------------------------------------

---设置星星
--@param #cc.node node 当前对象
--@param #number ccbtag ccbifile 设置的tag
--@param #number num 当前会有几个星：1~5
function xse.base.setStar(node,ccbtag,num)
    local len = 5
    assert(num >0 and num <=len  ,"num must be between 1-5")
    local layer = node:getChildByTag(ccbtag)

    local tempdatakey = "star"
    local tempdata = getTempVariable(node,tempdatakey)
    if tempdata == nil then
        tempdata =  {
            sp1 = layer:getChildByTag(1):getSpriteFrame(),
            sp2 = layer:getChildByTag(len):getSpriteFrame()
        }
        setTempVariable(node,ccbtag,tempdata)
    end

    local spr1 = tempdata.sp1
    local spr2 = tempdata.sp2
    for var=1, len do
        if var <= num then
            layer:getChildByTag(var):setSpriteFrame(spr1)
        else
            layer:getChildByTag(var):setSpriteFrame(spr2)
        end
    end
    return layer
end

---添加ui事件的支持
--@param #string layerstr 当前ui对面名
--@param #string eventstr 当前事件的名字
--@param #function fun 事件绑定到函数的函数名
--@param #bool disablefun 禁用时调用的函数.如果为空，在禁用时候就不做任何响应
--@param #boll supportClickSound 是否支持点击时候有声音，默认为支持（true）,false
function xse.base.addEventSupportA(layerstr,eventstr,fun,disablefun,supportClickSound)
    assert(layerstr ,"layerstr is nil")
    assert(eventstr,"eventstr is nil")
    warning(fun,"unregister event:"..layerstr.. "."..eventstr)
    ccb[layerstr] =  ccb[layerstr] or {}
    if fun == nil then
        --todo::不成熟，需要处理
        ccb[layerstr][eventstr] = nil
        if #ccb[layerstr] == 0 then  ccb[layerstr] = nil end
    else
        ---默认是要支持声音
        if supportClickSound == nil then
            supportClickSound = true
        end
        ccb[layerstr][eventstr] = function(arg1,args2)

            --            if xse.base.EventFiler.Check(layerstr.."."..eventstr) == true then return nil end
            if eventFiler:canExecute(layerstr.."."..eventstr) == false then return nil end
            eventFiler:addExecuteEventKey(layerstr.."."..eventstr)
            if supportClickSound == true then
                ---play sound
                cc.SimpleAudioEngine:getInstance():playEffect("mouseClick.mp3",false)
            end

            local sender = arg1
            --目前只兼容controlbottom 和 menuitem
            if type(sender)== "number" then sender = args2 end
            local __f = fun
            assert(__f ~= nil,"fun is a nil value")
            assert(type(__f) == "function","fun is not a function.")
            log("invork function:"..layerstr.. "."..eventstr)
            if sender:isEnabled() == false then
                log("target is disable")
                if disablefun~= nil then
                    disablefun(sender)
                end
            else
                fun(sender)
                log("bind event:"..layerstr.. "."..eventstr)
            end
        end
    end
end

------------------------------------------------------------------------

---添加全屏的拦截下层拦截事件
function xse.base.addFullEvent(node,fun)
    warning(false,"已废弃的函数")
    assert(false,"add full evnet error.")
end

--add a swllow touches layer
function xse.base.setSwallowTouches  ( n,b,isfull )
    warning(false,"已废弃的函数")
end

function xse.base.setSwallowTouchesByTag ( node,tag,b )
    warning(false,"已废弃的函数")
    local n = node:getChildByTag(tag)
    xse.base.setSwallowTouches(n,b)
end

------------------------------------------------------------
--
xse.base.Sprite = {}

function xse.base.Sprite.setSpriteFrame(layer,tag,name)
    assert(layer,"layer is nil")
    local node = layer:getChildByTag(tag)
    local spriteFrame =   cc.SpriteFrameCache:getInstance():getSpriteFrame(name);
    assert(spriteFrame,"spriteFrame is nil :"..name)
    node:setSpriteFrame(spriteFrame)
    return node
end

---会从文件系统中加载纹理，用完后必须调用unloadTexture
function xse.base.Sprite.setTexture(layer,tag,name)
    assert(layer,"layer is nil")
    local node = layer:getChildByTag(tag)
    --    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    local textrue =  cc.Director:getInstance():getTextureCache():addImage(name);
    assert(textrue,"get textrue is nil:"..name)
    node:setTexture(textrue)
    return node
end

---换一个节点，在xse.base.Sprite.setSpriteFrame, xse.base.Sprite.setTexture
--不能满足需求的时候使用
function xse.base.Sprite.switchNodeByTextureNameA(node,name)
    --    local node = layer:getChildByTag(tag)
    local posx,posy = node:getPositionX(),node:getPositionY()
    local scale= node:getScale()
    local zorder = node:getLocalZOrder();
    local anchor =node:getAnchorPoint();
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    local newnode =nil
    if spriteFrame then newnode = cc.Sprite:createWithSpriteFrame(spriteFrame)
    else newnode = cc.Sprite:create(name)  end
    newnode:setScale(scale,scale)
    newnode:setPosition(cc.p( posx,posy))
    newnode:setAnchorPoint(anchor)
    node:getParent():addChild(newnode,zorder,node:getTag())
    node:getParent():removeChild(node)
    return newnode
end

---换一个节点，在xse.base.Sprite.setSpriteFrame, xse.base.Sprite.setTexture
--不能满足需求的时候使用
function xse.base.Sprite.switchNodeByTextureName(layer,tag,name)
    local node = layer:getChildByTag(tag)
    --    local posx,posy = node:getPositionX(),node:getPositionY()
    --    local scale= node:getScale()
    --    local zorder = node:getLocalZOrder();
    --    local anchor =node:getAnchorPoint();
    --    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(name)
    --    local newnode =nil
    --    if spriteFrame then newnode = cc.Sprite:createWithSpriteFrame(spriteFrame)
    --    else newnode = cc.Sprite:create(name)  end
    --    newnode:setScale(scale,scale)
    --    newnode:setPosition(cc.p( posx,posy))
    --    newnode:setAnchorPoint(anchor)
    --    layer:addChild(newnode,zorder,tag)
    --    layer:removeChild(node)
    return xse.base.Sprite.switchNodeByTextureNameA(node,name)
end

function xse.base.isMoved(de)
    local dif = 3; --移动的边界
    return de.x > dif or de.x < -dif or de.y > dif or de.x < -dif
end

---设置点击事件
function xse.base.Sprite.setOnClickEvent(node,fun,key,eventargs,swallowTouches)
    assert(node,"node is a nil value")
    local eventKey = key or xse.base.random().."listnerkey"

    if eventKey ~= nil and type(fun) == "function" then
        local listener = cc.EventListenerTouchOneByOne:create()
        local function onTouchBegan(touch, event)
            local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            if xse.base.getNodeVisible(target) == false then return false end
            local rect = cc.rect(0, 0, s.width, s.height)
            local res =  cc.rectContainsPoint(rect, locationInNode)
            if res == true then event:getCurrentTarget().__ismoved  = false end
            return res
        end
        local function onTouchMoved(touch, event)
            local de = touch:getDelta();
            if event:getCurrentTarget().__ismoved == false then
                event:getCurrentTarget().__ismoved  = xse.base.isMoved(de)
            end
        end
        local function onTouchEnded(touch, event)
            local node =  event:getCurrentTarget()
            local ismoved = node.__ismoved
            if ismoved ~= true then
                --                if eventFiler:canExecute(self,eventargs) == false then return nil end
                if eventFiler:canExecute(eventKey) == false then return nil end
                eventFiler:addExecuteEventKey(eventKey)
                cc.SimpleAudioEngine:getInstance():playEffect("mouseClick.mp3",false)
                xpcall(fun(eventargs or node.__bindToInstance,node),log)
            end
        end

        local _swallowTouches = true
        if swallowTouches ~= nil then _swallowTouches = swallowTouches end

        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        listener:setSwallowTouches(_swallowTouches)
        node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,node)
    end

    if eventKey~= nil and fun == nil then
        local listener = getTempVariable(node,eventKey)
        local eventdispather = node:getEventDispatcher()
        eventdispather:removeEventListener(listener)
    end

    return eventKey
end


function xse.base.Sprite.setDragEvent(node,fun,key)
    assert(node,"node is a nil value")
    local key = key or xse.base.random().."listnerkey"
    if key ~= nil and type(fun) == "function" then
        local listener = cc.EventListenerTouchOneByOne:create()
        local function onTouchBegan(touch, event) local target = event:getCurrentTarget()
            local locationInNode = target:convertToNodeSpace(touch:getLocation())
            local s = target:getContentSize()
            local rect = cc.rect(0, 0, s.width, s.height)
            return cc.rectContainsPoint(rect, locationInNode)end
        local function onTouchMoved(touch, event)
            --            event:getCurrentTarget().__ismoved = true
            local target = event:getCurrentTarget()
            local posX,posY = target:getPosition()
            local delta = touch:getDelta()
            target:setPosition(cc.p(posX + delta.x, posY + delta.y))
            xpcall(fun(node.__bindToInstance,deltax,deltay),log)
        end

        local function onTouchEnded(touch, event)
        --[[
        local node =  event:getCurrentTarget()
        local ismoved = node.__ismoved
        if ismoved ~= true then
        xpcall(fun(node.__bindToInstance,node),log)
        end
        ]]
        end
        listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,node)
    end

    if key~= nil and fun == nil then
        local listener = getTempVariable(node,key)
        local eventdispather = node:getEventDispatcher()
        eventdispather:removeEventListener(listener)
    end

    return key
end

---设置点击事件
function xse.base.setLayerOnClickEvent(node,fun,key,eventargs,swallowTouches)
    return xse.base.Sprite.setOnClickEvent(node,fun,key,eventargs,swallowTouches)
end

---删除资源
function xse.base.Sprite.unloadTexture(name)
    xse.base.unloadTexture(name)
end

---删除资源
function xse.base.unloadUnUsedTexture()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function xse.base.unloadTexture(name)
    while  cc.Director:getInstance():getTextureCache():getTextureForKey(name) do
        cc.Director:getInstance():getTextureCache():removeTextureForKey(name)
    end
end

function xse.base.unloadTextures(names)
    if names == nil then return end
    for key, var in pairs(names) do
        xse.base.unloadTexture(var)
    end
end

-----卸载资源
--function xse.base.Sprite.unloadTextureBySpriteFrame(spriteFrame)
--    assert(spriteFrame,"spriteFrame is a nil value")
--    cc.Director:getInstance():getTextureCache():removeTexture(spriteFrame:getTexture())
--end

---节点水平，垂直镜像
function xse.base.Sprite.revert(sender)
    local scalex,scaley = sender:getScaleX(),sender:getScaleY()
    sender:setScale(scalex*-1,scaley*-1)
end

---
--node -> bar(-1)，注意textNode上的错误，这个bug不是很好找
function xse.base.Sprite.ToProcessBar(node,textNode)
    if node then
        local layer = node:getParent()
        local spriteFrame = node:getSpriteFrame()
        local sprite = cc.Sprite:createWithSpriteFrame(spriteFrame)
        local zorder = node:getLocalZOrder()
        require("protocal")
        local barlib = require ("progress")
        local bar = barlib.create(sprite)
        bar:setLocalZOrder(zorder)
        bar:setAnchorPoint(node:getAnchorPoint())
        bar:setScale(node:getScaleX(),node:getScaleY())
        bar:setRotation(node:getRotation())
        bar:setPosition(node:getPosition())
        bar:setTag(node:getTag())
        layer:addChild(bar)
        layer:removeChild(node)
        if textNode then  textNode:setLocalZOrder(1) end
        -- bar:setPercentage(30)
        return bar;
    end
    return nil
end

---把layer转行成带拖动的滚动条
function xse.base.Sprite.toSlider(node,layerTag,bgStr,progressStr,thumbStr,minvalue,maxvalue,strIncrease,strDencrease,step)
    local function valueChanged(pSender)
        local pControl = pSender
        pControl:getValue()
    end
    local layer = node:getChildByTag(tag)
    --Add the slider
    local pSlider = cc.ControlSlider:create(bgStr,progressStr ,thumbStr)
    pSlider:setMinimumValue(minvalue)
    pSlider:setMaximumValue(maxvalue)
    pSlider:setTag(1)

    local size = pSlider:getContentSize()
    local sprleft = cc.Scale9Sprite:create(strIncrease)
    local sprright = cc.Scale9Sprite:create(strDencrease)
    local btleft = cc.ControlButton:create(sprleft)
    local btright = cc.ControlButton:create(sprright)
    step = step or 1
    local layerPos = layer:getPosition()

    local function setEvent(touch,event)
        local target = event:getCurrentTarget()
        local tag = target:getTag()
        local parent = target:getParent()
        local slider = parent:getChildByTag(1)
        local add = target.stepNum or 1
        if tag == 2 then add = add end
        if tag == 3 then add =-add end
        slider:setValue(add)
    end

    local btleftPos = cc.p(layerPos.x - size.width/2,layerPos.y)
    btleft:setPosition(layer)
    btleft:setPosition(btleftPos)
    btleft:setZoomOnTouchDown(false)
    btleft:registerControlEventHandler(setEvent, cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    btleft.stepNum = step
    layer:addChild(btleft)
    btleft:setTag(2)

    local rightftPos = cc.p(layerPos.x + size.width/2,layerPos.y)
    btright:setPosition(layer)
    btright:setPosition(rightftPos)
    btright:setZoomOnTouchDown(false)
    btright:registerControlEventHandler(setEvent, cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
    layer:addChild(rightftPos)
    btright.stepNum = step
    btright:setTag(3)

    return pSlider
end

---把layer 转换成带拖搜索框
function xse.base.Sprite.toSearch(node,textLayerTag,bttag,callBack)
    local texteditor = xse.base.layerToEditor(node,textLayerTag)
    local btTag = node:getChildByTag(bttag)
    btTag.texteditor = texteditor
    btTag.callback = callBack
    local function setEvent(touch,event)
        local target = event:getCurrentTaget()
        local editor = target:getText()
        local fun = target.callback
        fun(editor:getText())
    end
    btTag:registerControlEventHandler(setEvent, cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
end

function xse.base.Sprite.ToProcessBarByTag(layer,tag)
    local node = layer:getChildByTag(tag)
    assert(node,"not found node by tag,tag:"..tag)
    return xse.base.Sprite.ToProcessBar(node)
end

------------------------------------------------------------
--menu
xse.base.menu = {}

------------------------------------------------------------
--add to node helpers

---显示一个节点在场景上
function xse.base.show ( p,n ,index)
    assert(n,"node is nil value")
    p = p or xse.base.Scene
    if index and index > 0 then
        p:addChild(n,index); n:getParent()
    else
        p:addChild(n);
    end

end

----
--替换当前节点 用n2 替换n1
--目前只支持最顶层间的node替换
function xse.base.reaplace(n1,n2)
    local parent = n1:getParent()
    parent:remove(n1)
    parent:addChild(n2)
end

function xse.base.hide ( p,n,callback)
    p = p or n:getParent()
    --todo str1et hide animal
    n:removeAllChildren()
    p:removeChild(n,true)
    if callback and type(callback)=="function" then callback() end
end

function xse.base.showItem ( p,n ,on_complate_fun)
    assert(n,"node is nil value")
    p=p or xse.base.Scene
    p:addChild(n);
end

function xse.base.hideItem ( p,n ,on_complate_fun)
    if n==nil then return end
    --todo str1et hide animal
    n:removeFromParent()
end

function xse.base.repalce(p,rawn,newn)
    xse.base.hide(p,rawn)
    xse.base.show(p,newn)
end

--------------------------
--关闭界面的高级应用
function xse.base.hideA(n,callback)
    if n then
        n = tolua.cast(n,"cc.Node")
    end
    --    xse.base.removeBLLNode(nil,n)
    n:getParent():removeChild(n)
    if callback and type(callback)=="function" then callback() end
end

function xse.base.addToNode (_p,_n)
    --    log("add addChild")
    _p:addChild(_n)
end

function xse.base.removeNode(n)
    if n then
        local parent = n:getParent()
        parent:removeChild(n);
    end
end
--在屏幕的下中间显示一个对象
function xse.base.showNodeOnSceneCenter(node)
    local _center = xse.base.center()
    --    log("center.x =  %f ,center.y = %f", _center.x,_center.y)
    node:ignoreAnchorPointForPosition(false)
    node:setPosition(ccp(_center.x,_center.y))
    xse.base.Scene:addChild(node)
end

function xse.base.removeFromNode (_p,_n)
    --    log("remove addChild")
    _p:removeChild(_n,true)
end

--------------------------------------------------------------
--user datas manager
xse.base.cache = {}
function xse.base.cache.write ( k,v )
    if string.len(v)==0 then
        xse.base.trace ("----------------------------write debug error -------------")
    end
    cc.UserDefault:getInstance():setStringForKey(k,v)
end

function xse.base.cache.read  ( k )
    local str = cc.UserDefault:getInstance():getStringForKey(k)
    return str
end

function xse.base.cache.remove ( k )
    cc.UserDefault:getInstance():setStringForKey(k,"")
end

--------------------------------------------------------------
--language servicesss

--get then local language code
local language = language or {}
function language.getCode()
    local  str = cc.Application:getInstance():getCurrentLanguageCode()
    assert(str,"get language code error")
    return str
end
xse.base.language = language

---------------------------------------------------------------
--string extention
xse.base.string =   {}

function xse.base.string.replace(str,originalStr, newStr,isAll)
    isAll = isAll or false
    if isAll == true then
        local s,n = str
        while n > 0 do
            s,n= string.gsub(str,originalStr,newStr)
            return s,n
        end
    else
        local s,n = string.gsub(str,originalStr,newStr)
        return s,n
    end
end

function xse.base.string.format(str1,str2,str3,str4,str5,str6,str7,str8,str9,str10)
    local s,n = str1,0
    --迭代器有问题,暂时先这样用起。
    if str2~=nil then s,n = string.gsub(s,"{"..(0).."}",str2) end
    if str3~=nil then s,n = string.gsub(s,"{"..(1).."}",str3) end
    if str4~=nil then s,n = string.gsub(s,"{"..(2).."}",str4) end
    if str5~=nil then s,n = string.gsub(s,"{"..(3).."}",str5) end
    if str6~=nil then s,n = string.gsub(s,"{"..(4).."}",str6) end
    if str7~=nil then s,n = string.gsub(s,"{"..(5).."}",str7) end
    if str8~=nil then s,n = string.gsub(s,"{"..(6).."}",str8) end
    if str9~=nil then s,n = string.gsub(s,"{"..(7).."}",str9) end
    if str10~=nil then s,n = string.gsub(s,"{"..(8).."}",str10) end
    return s
end

--将字符串数组按照gap进行拼接
--@param gap 默认为逗号
function xse.base.string.append(strs, gap)
    gap = gap or ",";
    if strs then
        local array = "";
        for i,v in pairs(strs) do
            if i == 1 then
                array = array .. v;
            else
                array = gap .. array .. v;
            end
        end;
        return array;
    else
        return "";
    end;
end;

--数字保留小数位数格式化函数
function xse.base.string.numToString(num,f)
    if type(f)=="string" then f = #f end
    return xse.base.string.round(num,f)
end


--对一个数据进行四舍五入，保留precision小数
--@param num 数据
--@param precision 保留的小数位数 默认两位
function xse.base.string.round(num, precision)
    precision = precision or 2;
    local value = 1;
    for i = 1, precision do
        value = value * 10;
    end;

    num = math.floor(num * value + 0.5);
    return num / value;
end

---使用计算机的计算方法 默认保留两位小数
function xse.base.string.ToStringA(str1,len)
    local str = tonumber(str1)
    local c =  ""
    assert(str,"str is nil")
    if str >10000 and str < 1000000 then
        str =  str /1000.0
        c = "K"
    end

    if str > 1000000 and str < 1000000000 then
        str = str / 1000000.0
        c = "M"
    end

    if str > 1000000000 then
        str = str / 1000000000.0
        c = "G"
    end

    if str > 1000000000000 then
        str = str / 1000000000000.0
        c = "T"
    end

    return xse.base.string.numToString(str,len or "#") .. c
end

---科学计数法改为正常的计数法
function xse.base.string.ktonumber(str)
    local c = string.sub(str,#str, -1)
    local numStr = string.sub(str,1,#str-1)
    if c == "K" then
        numStr = tonumber(numStr)*1000
    elseif c == "M" then
        numStr = tonumber(numStr)*1000000
    elseif c == "G" then
        numStr = tonumber(numStr)*1000000000
    elseif c == "T" then
        numStr = tonumber(numStr)*1000000000000
    end
    return tonumber(numStr)
end

---用固定的位数。不够就用0占位
function xse.base.string.ToStringForBlen(num,len)
    local str = tostring(num)
    local count = len - #str
    for var=1, count do
        str = "0"..str
    end

    return str;
end

function xse.base.string.split(szFullString,szSeparator)
    if szSeparator  == nil then return szFullString end
    if szFullString == nil or string.len(szFullString) == 0 then return {} end
    local nFindStartIndex ,nSplitIndex,nSplitArray= 1 ,1 ,{}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex,string.len(szFullString))
            break
        end
        ---处理连续两个 szSeparator
        if nFindLastIndex ==  nFindStartIndex then
            nSplitArray[nSplitIndex] = ""
            nSplitIndex = nSplitIndex + 1
        end

        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        if #(nSplitArray[nSplitIndex]) > 0 then
            nSplitIndex = nSplitIndex + 1
        end
    end

    return nSplitArray
end

-------------------------------------
--来自己网络，目前没有确定是否无bug
--function xse.base.string.utfSub(s, n)
--    local dropping = string.byte(s, n+1)
--    if not dropping then return s end
--    if dropping >= 128 and dropping < 192 then
--        return xse.base.string.utfSub(s, n-1)
--    end
--    return string.sub(s, 1, n)
--end
--
--function xse.base.string.utflen(str)
--    return #(str.gsub('[\128-\255][\128-\255]',' '))
--end
--
--function xse.base.string.nextChar(utfStrBytes,currentIndex)
--    local blen = currentIndex
--    while counter < #str do
--        if b<0x80 then  counter = counter + 1; blen = blen + 1;
--        elseif b<0x800 then counter = counter + 2; blen = blen + 1;                  -- 2 byte
--        elseif b<0x10000 then  counter = counter + 3; blen = blen + 1;               -- 3 byte
--        elseif b<0x200000 then counter = counter + 4; blen = blen + 1;               -- 4 byte
--        elseif b<0x4000000 then counter = counter + 5; blen = blen + 1;              -- 5 byte
--        else counter = counter + 6; blen = blen + 1;                                 -- 6 byte
--        end
--    end
--    return
--end
--
--function xse.base.string.getUtfChar(utfstr,index)
--
--end

--[[uftstring 迭代器
utf 字符串
@param #function fun 处理单个字符的函数 function(uchar) end 返回为true就不再迭代
]]
function xse.base.string.foreach(utfstr,fun)
    local counter,len = 1,0
    local charIndex = 0
    while  counter <= #utfstr do
        local b = string.byte(utfstr, counter)
        if b<0xC0 then   len = 1;
        elseif b<0xE0 then  len= 2
        elseif b<0xF0 then len = 3
        elseif b<0xF8 then len = 4
        elseif b<0xFC then len = 5
        else len=6;
        end
        charIndex = charIndex+ len;
        local char = string.sub(utfstr,counter,counter + len -1)
        counter = counter + len
        if fun(char,charIndex,len) then
            break;
        end
    end
end

--test
--xse.base.string.foreach("口香糖除あなたのお母さんの卵了提升艺术气Tôi hẹn hò với em gái của bạn质外口香糖除了提升艺术气质外",nil)
function xse.base.string.getUtfChar(utfstr,index)
    counter = counter or 1
    local res = nil
    xse.base.string.foreach(utfstr,function(char)
        if counter == index then
            res = char
            --不再迭代
            return true
        end
        counter =  counter + 1
    end)
    return res
end

function xse.base.string.charIndexToUtfIndex(utfstr,charIndex)
    local byteIndex,utfindex = 0,0
    xse.base.string.foreach(utfstr,function(char)
        if byteIndex <charIndex then
            byteIndex =  byteIndex + #char
            utfindex = utfindex +1
        end

    end)
    return utfindex
end
---检查字符是还为英文
function xse.base.string.charIsEn(char)
    local b = string.byte(char, 1)
    return b < 0x80
end

---TODO::有性能问题，暂时不优化
function xse.base.string.sub(str,startIndex,endIndex)
    if not str then return "" end;
    local index = 1;
    local newStr ="";
    xse.base.string.foreach(str,function(char)
        if index >=  startIndex and index <= endIndex then
            newStr = newStr .. char;
        end
        index = index +1
    end)
    return newStr;
end

---TODO::有性能问题，暂时不优化
---startIndex ASNIII索引，byteLen utf-8 长度
function xse.base.string.subA(str,starWordIndex,wordLen)
    if not str then return "" end;
    local index = 1;
    local newStr ="";
    xse.base.string.foreach(str,function(char)
        index = index + 1;
        if wordLen > 0 and index >= starWordIndex then
            wordLen = wordLen -  1
            newStr = newStr .. char;
        end
        index = index + 1;
    end,
    ---提高处理的性能
    function(char) return  index >= starWordIndex end )
    return newStr;
end

function xse.base.string.sub4holdeLen(str,startHolderIndex,holderlen)
    local counter = 0;
    local retstr = "";
    local byteIndex = 1
    local lenCounter = 0
    local len = 0;

    while  byteIndex <= #str do
        do
            local b = string.byte(str, byteIndex)

            if b<0xC0 then     len = 1 lenCounter = lenCounter + 2 * 0.7083333 lastIsEn = true --英文占中文的 17/24 =0.7083333.... ,用的24号字体 做为标准，英文占用就是17号的中文字，不同的字体会有差别
            elseif b<0xE0 then len = 2 lenCounter = lenCounter + 2
            elseif b<0xF0 then len = 3 lenCounter = lenCounter + 2
            elseif b<0xF8 then len = 4 lenCounter = lenCounter + 2
            elseif b<0xFC then len = 5 lenCounter = lenCounter + 2
            else               len = 6 lenCounter = lenCounter + 2
            end

            if lenCounter >= startHolderIndex  then
                retstr = retstr .. string.sub(str,byteIndex,byteIndex + len -1)

                if lenCounter > startHolderIndex + holderlen  then
                    break;
                end
            end
            byteIndex =  byteIndex  + len
        end
    end
    return retstr ,len
end

---文字占位长度,中文占用2个位，英文占用17/24个位
function xse.base.string.utfHolder(utfstr)
    local counter,len = 1,0
    local lenCounter = 0
    local utfstrLen = #utfstr
    while  counter <= utfstrLen do
        do
            local b = string.byte(utfstr, counter)
            if b<0xC0 then     len = 1 lenCounter = lenCounter + 2 * 0.7083333 --英文占中文的 17/24 =0.7083333.... ,用的24号字体 做为标准，英文占用就是17号的中文字，不同的字体会有差别
            elseif b<0xE0 then len = 2 lenCounter = lenCounter + 2
            elseif b<0xF0 then len = 3 lenCounter = lenCounter + 2
            elseif b<0xF8 then len = 4 lenCounter = lenCounter + 2
            elseif b<0xFC then len = 5 lenCounter = lenCounter + 2
            else               len = 6 lenCounter = lenCounter + 2
            end
        end
        counter = counter + len
    end
    return lenCounter
end

---文字个数长度
function xse.base.string.utfBlen(utfstr)
    local counter,len = 1,0
    local lenCounter = 0
    while  counter <= #utfstr do
        local b = string.byte(utfstr, counter)
        if b<0xC0 then   len = 1;
        elseif b<0xE0 then  len= 2
        elseif b<0xF0 then len = 3
        elseif b<0xF8 then len = 4
        elseif b<0xFC then len = 5
        else len=6;
        end
        --        local char = string.sub(utfstr,counter,counter + len -1)
        counter = counter + len
        lenCounter = lenCounter +1
    end
    return lenCounter
end


function xse.base.string.compare(str1,str2)
    assert(str1,"str1 is a nil value")
    assert(str2,"str2 is a nil value")
    if #str1 ~= #str2 then
        return false
    end
    for var=1, #str1 do
        if str1[i]~= str2[i] then return false end
    end
    return true
end

function xse.base.string.toTable(str)
    local res = {}
    xse.base.string.foreach(str,function(char)
        table.insert(res,#char+1,char)
    end)
    return res
end

--copy table
function copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = copyTab(v)
        end
    end
    return tab
end

----------------------------------------------------------------
--格式化p在min和max 之间
--@return #number 格式化后的数据
function xse.base.Range (p,min,max)
    if p > max then return max end
    if p < min then return min end
    return p
end

---检查是否为数字
--@param num string 要检查的字符
--@param min number 最小值
--@param max  number 最大值
--@return #number 数据[min,max]
function xse.base.numberBetween(num,min,max)
    local n = tonumber(num);
    if min and n < min then return min end
    if max and n >= max then return max end
    return n;
end

function xse.base.toServerIndex(index)
    return index -1
end

function xse.base.serverIndextoClientIndex(index)
    return index + 1
end

---检查是否为数字
--@param num string 要检查的字符
--@param min number 最小值
--@param max  number 最大值
--@return #number 如果 num 是数字并且 min,max不为nil 返回num 是否为[min,max)
--                 如果num是数字并且min 和max为空，直接返回num to number.
function xse.base.isNumber(num,min,max)
    local n = tonumber(num);
    if not n then return nil end;
    if min and n < min then return nil end
    if max and n >= max then return nil end
    return n;
end

---生成一个随机数，用时间作为种子
--@return #number 返回生成的随机数
function xse.base.random()
    ---[PS] 返回为nil
    --  local random_code = math.randomseed(os.time())
    local random_code = math.random(os.time(),os.time()* os.time())
--    local num = math.floor(random_code) + math.ceil(random_code)
    return random_code
end
-----------------------------------------------------------------
xse.base.timer =  {}

---转换成时间对象，
--@param #number num 格林时间参数
--@param #boolean lb 是否进行格林时间转换
--@return #table  {year=2005, month=11, day=6, hour=22,min=18,sec=30}
function xse.base.timer.totime( num ,lb)
    --    log("data num:"..num)
    --调用c的timer扩展
    if lb then num =  timer:to_local_time(num) log("convet time num"..num)end
    local times =  os.date("*t", num)
    -- (times.year..","..times.month,","..times.day..","..times.hour..","..times.hour..","..times.min..","..times.sec)
    times.year = times.year - 2010 ---由于c的问题，加上一个时间 基数
    return times
end

function xse.base.timer.totimesString(num)
    local times =  xse.base.timer.totime( num ,true)
    return (times.year.."-"..times.month .. "-"..times.day.." "..times.hour..":"..times.min..":"..times.sec)
end

--function xse.base.timer.toRemainTimeString(num,formatStr)
--    local ms = num / 1000;
--    local m_days = 24 * 60 * 60
--    local m_hours = 60 * 60
--    local m_min = 60
--
--    local day,hour,min,second = math.floor(ms/m_days),math.floor(ms % m_days /m_hours),
--        math.floor(ms % m_days % m_hours / m_min),math.floor(ms % m_days % m_hours % m_min)
--    return day,hour,min,second
--end

---时间格式化，把给定的时间转换成时间格式
--@return #string x:x:x
function xse.base.timer.format( num)
    num = math.floor( num / 1000)
    local h = tostring(math.floor( num / 3600))
    local m = tostring(math.floor( num / 60 % 60 ))
    local s = tostring(num % 60)
    if #h ==1 then h = "0"..h end
    if #m==1 then m = "0"..m end
    if #s ==1 then s = "0"..s end
    return h ..":"..m ..":"..s
end

---
--@return #timer {h=h_,m=m_,s=s_}
function xse.base.timer.totimes( num)
    num = math.floor( num / 1000)
    local h_ = tostring(math.floor( num / 3600))
    local m_ = tostring(math.floor( num / 60 % 60 ))
    local s_ = tostring(num % 60)
    return {h=h_,m=m_,s=s_}
end

---将标准的时间tabel转换成number
--@param #table tb 时间table 对象
--@usage xse.base.num({year=2005, month=11, day=6, hour=22,min=18,sec=30})
--@return #number 返回时间
function xse.base.timer.tonum(tb)
    return os.time(time)
end

---
function xse.base.timer.time()
    return  os.clock()
end

---返回当前当地时间与格林时间的时差
function xse.base.timer.getlocaldiff()
    return timer.get_local_timediff()
end

-----------------------------------------------------------------
--time ticks
xse.base.timer.tick = {}
xse.base.timer.record = xse.base.timer.time()
xse.base.timer.functions = {}
xse.base.timer.drivers = nil
xse.base.timer.driversId = nil

---注册一个tick函数，同步界面调用
--@param fun function 添加一个tick 函数
--@return #number 返回一个唯一的ID
function xse.base.timer.tick.add(fun)
    warning(fun and type(fun)=="function","fun is nil or fun not a function")
    local processID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        fun()
    end, 0, false)

    return processID
end

---注册一个函数，1秒调用一次
--@param fun fucntion format:function() end
function xse.base.timer.tick.addB(fun)
    warning(fun and type(fun)=="function","fun is nil or fun not a function")
    if xse.base.timer.drivers ==  nil then
        xse.base.timer.record = os.time()
        local remaining = 0
        xse.base.timer.drivers = function()
            local currentTime   = os.time()
            local timediff =  currentTime - xse.base.timer.record
            local timeDiffFloor = math.floor(timediff);
            if timeDiffFloor >= 1 then
                for key, var in pairs(xse.base.timer.functions) do
                    xpcall(function() var.function_(timeDiffFloor * 1000.0) end,function()
                        xse.base.timer.tick.removeA(var.key)
                    end)
                end
                timediff = timediff - timeDiffFloor
            end
            xse.base.timer.record =  currentTime - timediff
        end

        xse.base.timer.driversId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(xse.base.timer.drivers, 0, false)
    end

    local key = xse.base.random()
    table.insert(xse.base.timer.functions,#(xse.base.timer.functions)+1,{id = key,function_ = fun})
    return key
end

---注册一个函数1秒调用一次,并开始倒时，当倒计时完成后回调一个函数，并设置总的执行时间
function  xse.base.timer.tick.addC(time,fun,callback,errCallBack)
    local statTime = os.time();
    local preCallTime = os.time()
    local id = nil;
    id =  xse.base.timer.tick.addB(function()
        local currentTime = os.time()
        local timeCounter = currentTime - statTime
        if timeCounter > time then
            callback()
            xse.base.timer.tick.removeA(id)
        else
            fun(math.ceil(time - timeCounter * 1000));
        end
    end)

    return id;
end

function xse.base.timer.tick.removeA(key)
    table.removeA(xse.base.timer.functions,function(v)
        return v.id == key
    end)
    local id = xse.base.timer.functions
end


function xse.base.timer.tick.addFrameTick(fun,...)
    local id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        trycall(fun)
    end, 0, false)
    return id
end

function  xse.base.timer.tick.removeFrameTick(key)
    xse.base.timer.tick.remove(key)
end

---移除一个tick 函数
--@param id number 移除tick的id
function xse.base.timer.tick.remove(id)
    assert(id,"remove id is a nil value")
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
end

-----------------------------
--
function xse.base.getClientType()
    ---TODO::返回当前客户端口的类型，用于统计
    return  1;
end

-----------------------------
--其它文件中的api
require("animationHelper")

return xse.base
