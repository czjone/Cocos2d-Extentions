---@type xse.base.menuHelper
xse.base.menuHelper = {}

local tabView = require "TabView"

---设置目录选中状态
--@param instance #instance instance 对象,callbackFun的第一参数的穿透参数
--@param menu #cc.Menu cc.Menu 对象
--@param item #cc.Menuitem cc.Menuitem 对象
--@param callbackFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setMenuFun(instance,menu,item,callbackFun)
    local children = menu:getChildren()
    for key, var in pairs(children) do
        if var:getTag() == item:getTag() then
            var:selected()
            if callbackFun ~= nil then
                callbackFun(instance,var:getTag(),var)
            end
        else
            var:unselected()
        end
    end
end

---设置目录选中状态
--@param uinode #uinod uinode 对象
--@param menutag #int cc.Menu tag 标示
--@param itemidx #cc.Menuitem cc.Menuitem 索引
--@param itemCalleventFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setselectIndexAndCallEvent(uinode,menutag,itemidx,itemCalleventFun)
    local menu = uinode.node:getChildByTag(menutag)
    local children = menu:getChildren()
    xse.base.menuHelper.setMenuFun(uinode,menu,children[itemidx],itemCalleventFun)
end

---设置目录选中状态
--@param uinode #uinod uinode 对象
--@param menutag #int cc.Menu tag 标示
--@param itemidx #cc.Menuitem cc.Menuitem 索引
--@param itemCalleventFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setselectIndexAndCallEventA(instance,node,menutag,itemidx,itemCalleventFun)
    local menu = node:getChildByTag(menutag)
    local children = menu:getChildren()
    xse.base.menuHelper.setMenuFun(instance,menu,children[itemidx],itemCalleventFun)
end

---设置目录选中状态
--@param uinode #uinod uinode 对象
--@param menutag #int cc.Menu tag 标示
--@param itemtag #cc.Menuitem cc.Menu tag 标示
--@param itemCalleventFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setselectTagAndCallEventFun(uinode,menutag,itemtag,itemCalleventFun)
    local menu = uinode.node:getChildByTag(menutag)
    local menuitem = menu:getChildByTag(itemtag)
    xse.base.menuHelper.setMenuFun(uinode,menu,menuitem,itemCalleventFun)
end

---设置目录选中状态
--@param uinode #uinod uinode 对象
--@param menutag #int cc.Menu tag 标示
--@param sender #cc.Menuitem cc.Menuitem
--@param itemCalleventFun function callbackFun(uinode,senderTag,sender
function xse.base.menuHelper.setselectTagAndCallEventFun(uinode,menutag,sender,itemCalleventFun)
    local menu = uinode.node:getChildByTag(menutag)
    xse.base.menuHelper.setMenuFun(uinode,menu,sender,itemCalleventFun)
end
-----------------------------------------------------------------------------------------------
--scrollview menu,带滑动的目录

---设置目录选中状态 [有两个重载函数]
--@param uinode #uinod uinode 对象
--@param scrollviewTag #number menutag
--@param item #cc.Menuitem cc.Menuitem 对象
--@param callbackFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setselectTagAndCallEventFunByScrollViewMenu(uinode,scrollviewTag,item,callbackFun)
    local layer = uinode.node:getChildByTag(scrollviewTag)
    local menu = nil
    assert(#(layer:getChildren())==1,"一个scrollview 有且只有一个menu，tagId必须设置成500")
    local tempItems = layer:getChildren()[1]:getChildren()
    for key, var in pairs(tempItems) do
        if var:getTag()== 500 then
            menu =var
            break;
        end
    end
    assert(menu,"一个scrollview 有且只有一个menu，tagId必须设置成500")
    xse.base.menuHelper.setMenuFun(uinode,menu,item,callbackFun)
end

---设置目录选中状态  [有两个重载函数]
--@param uinode #uinod uinode 对象
--@param scrollviewTag #number menutag
--@param item #cc.Menuitem cc.Menuitem 对象
--@param callbackFun function callbackFun(uinode,senderTag,sender)
function xse.base.menuHelper.setselectTagAndCallEventFunByScrollViewMenuByIndex(uinode,scrollviewTag,index,callbackFun)
    local layer = uinode.node:getChildByTag(scrollviewTag)
    local menu = nil
    assert(#(layer:getChildren())==1,"一个scrollview 有且只有一个menu，tagId必须设置成"..scrollviewTag)
    local tempItems = layer:getChildren()[1]:getChildren()
    for key, var in pairs(tempItems) do
        if var:getTag()== 500 then
            menu =var
            break;
        end
    end
    assert(menu,"scrollview 中的 menu 必须把tag设置成" .. scrollviewTag)
    local children = menu:getChildren()
    xse.base.menuHelper.setMenuFun(uinode,menu,children[index],callbackFun)
end

----------------------------------------------------------
-----由多个层组合成的按钮
-----个人中心就是例子
--function xse.base.menuHelper.menu(menulayer,onselectedChaned,sender)
--    local children = menulayer:getChildren()
--    local senderTag = sender:getTag()
--    for key, var in pairs(children) do
--        local tag = var:getTag()
--        if tag == senderTag then
--            onselectedChaned(var)
--            var:selected()
----            xse.base.setCCBottonSelecteStateByBotton(var,true);
--        else
--            var:unselected()
----            xse.base.setCCBottonSelecteStateByBotton(var,false);
--        end
--    end
--end

---------------------------------------------------------
----只有一个bottom的按钮,服务器的列表菜单就是列子
function xse.base.menuHelper.menu1(menulayer,tb,instance)
    menulayer.tb,menulayer.__menu_instance =  tb,instance
    local children = menulayer:getChildren()
    local setDefaultFlags = false
    local selectIndex = nil;
    assert(#children~=table.getLength(instance),"配置的行与界面上的按钮个数不一致!")
    for key, var in pairs(children) do
        xse.base.setCCBottonStringA (var,tb[key].title)
        xse.base.setCCBottonOnClick(var,function(self,sender)
            for key1, var1 in pairs(children) do xse.base.setCCBottonSelecteStateByBotton(var1,false); end
            xse.base.setCCBottonSelecteStateByBotton(var,sender:getTag() == var:getTag());
            if menulayer.selectIndex ~= sender:getTag() then
                tb[key].action(instance,sender);
                menulayer.selectIndex = sender:getTag()
                --                menulayer.selectIndex = sender:getTag()
            end
        end,instance)

        ---set default
        if tb[key].default == true then
            xse.base.setCCBottonSelecteStateByBotton(var,true);
            tb[key].action(instance,var);
            setDefaultFlags =true;
            menulayer.selectIndex = var:getTag()
        end
    end

    if setDefaultFlags == false then
        local sender = children[1]
        xse.base.setCCBottonSelecteStateByBotton(sender,true);
        tb[1].action(instance,sender);
        menulayer.selectIndex = sender:getTag()
    end
end

---要与前面的 xse.base.menuHelper.menu1 一起使用才有用
function xse.base.menuHelper.menu1SetIndex(menulayer,index)
    local tb,instance =  menulayer.tb,menulayer.__menu_instance
    assert(tb and instance,"menu layer 不是有效的目录.");
    local bt = menulayer:getChildren()[index]
    tb[index].action(instance,bt);
end

---------------------------------------------------------------
---由多个层组合成的按钮
---个人中心就是例子
--@
--最大只支持20个目录,menuitem 为sprite 与 lable合成
--
function xse.base.menuHelper.menu(node,tag,tasks,instance)
    local menuLayer = node:getChildByTag(tag)
    for key, var in ipairs(tasks) do
        local layer = menuLayer:getChildByTag(key)
        if layer == nil then break; end;
        local bt =  layer:getChildByTag(1)
        local font = layer:getChildByTag(2)
        font:setString(var.title)

        local function callback(instance,sender)
            for key1, var1 in pairs(menuLayer:getChildren()) do
                xse.base.setCCBottonSelecteStateByBotton(var1:getChildByTag(1),false)
            end
            var.action(instance,sender)
            xse.base.setCCBottonSelecteStateByBotton(sender,true)

        end

        xse.base.setCCBottonOnClick(bt,callback,instance)
        xse.base.setCCBottonOnClick(bt,callback,instance,true,"menuHelper.meluItemClickEvent")
        if key == 1 then callback(instance,bt) end
    end
end

---由多个层组合成的按钮
---个人中心就是例子
--@
--最大只支持20个目录,menuitem 为bottom合成
--

function xse.base.menuHelper.menuA(node,tag,tasks,instance)
    local menuLayer = node:getChildByTag(tag)
    for key, var in pairs(menuLayer:getChildren()) do
        var:setVisible(false)
    end

    for key, var in ipairs(tasks) do
        local bt = menuLayer:getChildByTag(key)
        if bt == nil then break; end;
        xse.base.setCCBottonStringA(bt,var.title);

        local function callback(instance,sender)
            for key1, var1 in pairs(menuLayer:getChildren()) do
                xse.base.setCCBottonSelecteStateByBotton(var1,false)
            end
            var.action(instance,sender)
            xse.base.setCCBottonSelecteStateByBotton(sender,true)

        end

        xse.base.setCCBottonOnClick(bt,callback,instance)
        if key == 1 then callback(instance,bt) end
        bt:setVisible(true)
    end
end

function xse.base.menuHelper.setScrollBtByScrollView(scrollView,leftbt,rightBt)
    local function move(step)
        local offset =  scrollView:getContentOffset()
        offset.x =  offset.x + step;
        scrollView:setContentOffset(offset)
    end

    xse.base.Sprite.setOnClickEvent(leftbt,function()
        move(scrollView:getViewSize().width / 10)
    end)

    xse.base.Sprite.setOnClickEvent(rightBt,function()
        move(scrollView:getViewSize().width / -10)
    end)
end

------------------------------------------------------------------------------------------
--
-- function  xse.base.menuHelper.toleft(menulayer,step,isBounce)
--
-- end


------------------------------------------------------------------------------------------

--local function isMenuItem(node)
--    return false
--end
--
--
-----tableControl
----[PS:第一个选项卡的层级必须相同]
----@param self object  当前绑定的脚本对象
----@param node cc.Node   当前绑定的node 对象
----{
----                      【CCBI中的节点布局情况】
----                      layer -> layer[tag=index(要手动设置)]  -> bt [tag=1]
----                                                            -> ttf[tag=2] 正常情况的字体颜色
----                            -> layer[tag=index(要手动设置)]  -> bt [tag=1]
----                                                            -> ttf[tag=2] 选中时的字体的颜色
----                            -> layer[tag=index(要手动设置)]  -> bt [tag=1]
----                                                            -> ttf[tag=2] 任何颜色都无用
----}
----@param tag number cc.Layer
----@param callback function 当事件发生变化时触发的事件
--function xse.base.menuHelper.tabControl(self,node,tag,contentLayer,callback,depindex,defaultSelectIndex)
--    local temp_var_key  = self:getHashCode().."_"..tag.."_"..(depindex or 1)
--    local temp_var = getTempVariable(self,temp_var_key)
--    defaultSelectIndex = defaultSelectIndex or 1
--
--    if temp_var == nil then
--        temp_var = {}
--        temp_var.normal_font_color = nil
--        temp_var.select_font_color = nil
--    end
--
--    local function setSelected(item,bool)
--        local ttf = item:getChildByTag(2)
--        local color = temp_var.normal_font_color
--        if bool== true and temp_var.select_font_color ~= nil then
--            color = temp_var.select_font_color
--        end
--        ttf:setColor(color)
--        xse.base.setCCBottonSelecteState(item,1,bool)
--    end
--    ---注册回掉事件
--    local function registerCallBack(instance,bt,callback,index)
--        bt:registerControlEventHandler(function(sender)
--            contentLayer:removeAllChildren()
--            local layer = sender:getParent():getParent()
--            table.foreach(layer:getChildren(),function(key,var)
--                local state = sender:getParent():getTag() == var:getTag()
--                xse.base.setCCBottonSelecteState(var,1,state)
--                if state == true then
--                    local res ,err = pcall( callback(instance,contentLayer,index,depindex))
--                    warning(err~=nil,err)
--                end
--            end)
--        end,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
--    end
--
--    local function setDefault(instance,menuLayer,defaultSelectIndex)
--        contentLayer:removeAllChildren()
--        table.foreach(menuLayer:getChildren(),function(key,var)
--            local state = defaultSelectIndex == var:getTag()
--            xse.base.setCCBottonSelecteState(var,1,state)
--            if state == true then
--                local res ,err = pcall( callback(instance,contentLayer,1,depindex))
--                warning(err==nil,err)
--            end
--        end)
--    end
--
--    local function init_layer(layer)
--        local items = layer:getChildren()
--        assert(#items > 0,"not contains items")
--        for i, var in pairs(items) do
--            local ttf = var:getChildByTag(2)
--            if temp_var.normal_font_color == nil and ttf then
--                local color = ttf:getColor()
--                temp_var.normal_font_color = color
--            elseif temp_var.select_font_color == nil and ttf then
--                local color = ttf:getColor()
--                temp_var.select_font_color = color
--            end
--            registerCallBack(self,var:getChildByTag(1),callback,i)
--        end
--        warning( temp_var.normal_font_color,"没有设置了正常的节点的字体颜色")
--        warning( temp_var.select_font_color,"没有设置了选中的节点的字体颜色")
--        setDefault(self,layer,defaultSelectIndex)
--    end
--
--    local menuLayer = node:getChildByTag(tag)
--    assert(menuLayer,"not found tag in node")
--    init_layer(menuLayer)
--    ---设置环境变量
--    setTempVariable(self,temp_var_key,temp_var)
--end
--
-----就是很多层级的 tabControl
----[PS:第一个选项卡的层级必须相同]
--function xse.base.menuHelper.tabControlA(self,node,tag,contentLayer,callBack,depindex)
--    depindex = depindex or 1
--    local layer = node:getChildByTag(tag)
--    local items = layer:getChildren()
--    for key, var in pairs(items) do
--        if isMenuItem(var) then
--            tabControl(self,node,tag,callback,depindex)
--        else
--            xse.base.menuHelper.tabControlA(self,node,tag,contentLayer,callBack,depindex + 1)
--        end
--    end
--end
--
-----
----configtb = {{title= "",load = "", reload = "",btname = "",layer = "", animal = "" ,child = {title= "",load = "", reload = "", btname = ""},
----            {title= "",load = "", reload = "",btname = "",layer = "", animal = "" ,child = {title= "",load = "", reload = "", btname = ""},}
--function xse.base.menuHelper.tabControlB(self,configtb,contentLayer)
--    local tb = {}
--    for key, var in pairs(configtb) do
--        tb[key] = {
--            title = var.title,
--            getNode=function()  var.load(self) return self.node:getChildByTag(500) end,
--            btname = var.btname,
--            layer = var.menulayer,
--            reload=function(self,node) if  var.load then return var.load(self,node) end end,
--        }
--    end
--    tabView.createTabView(self,tb[1].layer or node:getChildByTag(10009), contentLayer, tb, 0, tb[1].btname or "tabBtn1.ccbi",nil,nil,false);
--end
--

-------------------------------------------------------------
--上面的函数由于结构比较混乱，不在支持更新。有业务上的bug也不在处理。当出现业务
--上的bug时候，请选用当前函数
--【PS】测试的时候要测试办公室换皮肤和期货是否完全正确
function xse.base.menuHelper.createFromLayer(instance,layer,datas,itemNode,onItemClick,leftBtNode,rigthBtNode,isHorizontal,DefaultIndex)

    local selectIndex = DefaultIndex or 1;
    local scrollviewTag =1
    local moveStep = 10
    local Direction =  cc.SCROLLVIEW_DIRECTION_VERTICAL
    if isHorizontal ~= false then Direction = cc.SCROLLVIEW_DIRECTION_HORIZONTAL; end
    local contentSize = layer:getContentSize()
    --    assert(leftBtNode:getContentSize().width == rigthBtNode:getContentSize().width,"left bt and right bt must same content width.")

    local hasBt = leftBtNode and rigthBtNode and isHorizontal ~= false
    ---设置左边和右边的空白
    if hasBt == true then
        contentSize.width = contentSize.width - leftBtNode:getContentSize().width*leftBtNode:getScaleX() * 2
    end

    local scrollview = cc.ScrollView:create(contentSize,cc.Layer:create());
    scrollview:setTag(scrollviewTag);
    scrollview:setTouchEnabled(true)
    scrollview:setDirection(Direction)

    layer:addChild(scrollview);

    if isHorizontal == nil then isHorizontal = false ;end
    if hasBt == true then
        layer:addChild(leftBtNode)
        layer:addChild(rigthBtNode)
        scrollview:setPosition(cc.p(leftBtNode:getContentSize().width,0))
        rigthBtNode:setPosition(cc.p(contentSize.width + leftBtNode:getContentSize().width,contentSize.height/2 - leftBtNode:getContentSize().width/2))
        leftBtNode:setPosition(cc.p(0,contentSize.height/2- leftBtNode:getContentSize().width/2))

        ---TODO::有BUG 下次再处理
        local function isLeft()
            return scrollview:getContentOffset().x < -contentSize.width
        end

        local function isRight()
            return scrollview:getContentOffset().x >= contentSize.width
        end
        local function setBtEnable()
            xse.base.setCCBottonEnabledState(leftBtNode,1,isLeft());
            xse.base.setCCBottonEnabledState(rigthBtNode,1,isRight());
        end

        xse.base.Sprite.setOnClickEvent(leftBtNode,function()
            setBtEnable()
            local leftStep =  cc.p(-contentSize.width + math.floor( contentSize.width /moveStep) * - moveStep,0)
            if -contentSize.width > leftStep.x then
                --leftStep.x  = -contentSize.width + moveStep --有bug，先用下面的代码处理
                leftStep.x  = -contentSize.width + moveStep / 8
            end
            scrollview:setContentOffset(leftStep,true)
        end,nil,true)

        xse.base.Sprite.setOnClickEvent(rigthBtNode,function()
            setBtEnable()
            local leftStep = cc.p(math.floor( contentSize.width /moveStep) * moveStep,0)
            if leftStep.x > 0 then leftStep.x =0 end
            scrollview:setContentOffset(leftStep,true)
        end,nil,true)

        ---处理滑动变化的影响
        local callFun = cc.CallFunc:create(function() setBtEnable() end);
        local seq = cc.Sequence:create(callFun);
        local forever = cc.RepeatForever:create(seq);
        scrollview:runAction(forever)
    end

    local loadIndex = nil;

    local function loadNode(args)
        local node  =nil;
        if type(args) == "function" then
            local value = args();
            switch(value,{
                ["defualt"] =  function() assert("function is defualt!"); end
            })
            loadIndex =  loadIndex + 1;
            node.loadIndex = loadIndex;
        else
            loadIndex =  loadIndex + 1;
            if type(itemNode) =="string" then
                local nodestr =  xse.base.string.format(itemNode,tostring(args));
                node = xse.base.loadCCBI(nodestr)
            elseif type(itemNode) == "function" then
                node = itemNode(args,loadIndex);
            end
            moveStep = node:getContentSize().width
            node.loadIndex = loadIndex;
        end

        local tag = 10015 ---每一行数据的按钮必须为10015

        local function setSelected(node,selecteIndex)
            local childrens = node:getParent():getChildren()
            for key, var in pairs(childrens) do
                xse.base.setCCBottonEnabledState(var,tag,key == selectIndex)
            end
        end

        xse.base.Sprite.setOnClickEvent(node,function()
            if onItemClick then
                onItemClick(args,  node.loadIndex,node);
                setSelected(node,node.loadIndex)
            end
        end,nil,nil,false)

        ---触发默认的选中事件
        if loadIndex == selectIndex and onItemClick then
            local timerid;
            timerid = xse.base.timer.tick.add(function()
                onItemClick(args,selectIndex,node)
                xse.base.timer.tick.remove(timerid);

            end);
            xse.base.setCCBottonEnabledState(node,tag,loadIndex == selectIndex)
        end

        return node;
    end

    loadIndex = 0;
    local itemDatas = datas
    require("tableViewExt")
    layer.tbv = nil;
    listView.sortForNode(layer, itemDatas, loadNode, scrollviewTag, isHorizontal,0);
end
return xse.base.menuHelper