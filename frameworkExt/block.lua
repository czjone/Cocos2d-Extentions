-------------------------------------------------------
--blocks
xse.base.block = {}
xse.base.block.blockLayerIndex = -9999998
xse.base.block.maskLayerIndex = -9999999

function xse.base.block.setlayerblock(node)
    local function button_callback(ref,sender) return true end
    local bt = cc.LayerColor:create(cc.c4b (0,0,0,0))
    bt:ignoreAnchorPointForPosition(true)
    --    bt:setZoomOnTouchDown(false)
    --    bt:setScale(1)
    bt:setAnchorPoint(0.5,0.5)
    bt:setContentSize(node:getContentSize())

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        return cc.rectContainsPoint(rect, locationInNode)  end
    local function onTouchMoved(touch, event) end
    local function onTouchEnded(touch, event) end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    node:addChild(bt,xse.base.block.blockLayerIndex,node:getTag())
    node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,bt)
    --    log("set layer block")
end

function xse.base.block.setmask(node,removeCallBck,binder,maskalpha,isFull)
    log("setmask")
    local winsize = nil
    local winlayer =  nil
    if isFull == nil or isFull == true then
        winsize = cc.Director:getInstance():getVisibleSize()
        winlayer = cc.LayerColor:create(cc.c4b (0,0,0,maskalpha or 180),winsize.width*4,winsize.height*4)
        winlayer:ignoreAnchorPointForPosition(false)
    else
        winsize = node:getContentSize()
        winlayer = cc.LayerColor:create(cc.c4b (0,0,0,0),winsize.width,winsize.height)
        winlayer:ignoreAnchorPointForPosition(true)
        --winlayer:setAnchorPoint(0,0)
    end


    local listener =cc.EventListenerTouchOneByOne:create()

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        return cc.rectContainsPoint(rect, locationInNode)  end
    local function onTouchMoved(touch, event)  end
    local function onTouchEnded(touch, event)
        --        local node = event:getCurrentTarget()
        if removeCallBck == nil then
            xse.base.animal.hideAlert(node)
            winlayer:getEventDispatcher():removeEventListener(listener)
        else
            assert(type(removeCallBck)== "function" , "removeCallBck not a function")
            removeCallBck(binder,function()
                xse.base.animal.hideAlert(node)
                winlayer:getEventDispatcher():removeEventListener(listener)
            end)
        end

    end

    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    node:addChild(winlayer,xse.base.block.maskLayerIndex,node:getTag())
    node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,winlayer)
end

---@param node cc.Node 当前的节点
--@param isfull boolean 是否全屏
function xse.base.block.setblock(node,isfull,removeCallBck,binder,alphamask)
    if isfull == nil then isfull = false end
    xse.base.block.setlayerblock(node)
    if isfull == true then xse.base.block.setmask(node,removeCallBck,binder,alphamask) end
end