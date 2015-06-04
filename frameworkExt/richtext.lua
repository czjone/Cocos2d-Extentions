richtext ={}
require("glExt")

---可以任意组织的文字控件
--@param instance event的第一个回传参数
--@param layer cc.Node
--@param tb table {{str="",color = "",fontSize = 24,event =fun}，{str="",color = "",event =fun}}

function richtext.create(instance,layer,tb)
    assert(layer~=nil,"layer is a nil value")

    local enterChar = '\n'
    local viewSize = layer:getContentSize()
    local size = {width = 0,height = 0}

    layer.nodes = layer.nodes or {}

    function layer:reset()
        for key, var in pairs(layer.nodes) do
            if type(var) ~= "string" and char ~= enterChar then
                local node = cc.Node:create()
                var:removeFromParentAndCleanup()
            end
        end
        layer.nodes ={}
    end

    ---支持char or cc.Node
    function layer:addChar(char,color,event,args,fontSize)
        local node =nil
        ---用\n作为换行
        if type(char) == "string" and char ~= enterChar then
            fontSize = fontSize or 24
            node = cc.Label:create()
            node:setString(char)
            node:setSystemFontSize(fontSize)
            node:setColor(color)

            local size = node:getContentSize()
            if xse.base.string.charIsEn(char) or char == "“"
                or char == "·"
            then
                ---TODO::针对en做的特殊处理，会导致en版本的时候文字版本不和谐
                node:setContentSize(math.ceil(17/24 * fontSize) ,size.height)
            else
                node:setContentSize(fontSize ,size.height)
            end

            --            self:addChild(node)
            --        else
            --            node = char ---char 为cc.node
        end

        if event ~= nil and type(node) ~= "string" then
            local layer = cc.Layer:create()
            layer:setContentSize(node:getContentSize())
            local line = glExt.create(node:getContentSize().width,node:getContentSize().height)
            line:devicesBegin()
            line:linkPoint(cc.p(-10,-13),cc.p(10,-13),color.r,color.g,color.b,color.a,1)
            line:devicesEnd()
            layer:addChild(node)
            layer:addChild(line:getNode());
            xse.base.Sprite.setOnClickEvent(node,event,"",args)
            node = layer
        end
        self:addChild(node)
        table.insert(self.nodes,#(self.nodes) + 1,node)
        self:sort()
    end

    function layer:sort(startindex)
        if startindex == nil then
            local xpos,ypos,curentline_height,prewidth = 0,0,0
            local preLineHight = 0
            for i, var in ipairs(layer.nodes) do
                if (type(var) == "string" and var == enterChar) then
                    --            var:setAnchorPoint(0,0)
                    xpos = 0
                    curentline_height = curentline_height + preLineHight
                else
                    local contentSize = var:getContentSize()
                    if xpos + contentSize.width > viewSize.width + 10  then
                        xpos = 0
                        prewidth = nil
                        curentline_height = curentline_height + contentSize.height
                        var:setPosition(0,ypos - curentline_height + contentSize.height+ viewSize.height/2)
                    else
                        xpos = xpos + (prewidth or 0)
                        --                    xpos = xpos + contentSize.width
                        var:setPosition(xpos,ypos - curentline_height + contentSize.height+ viewSize.height/2)
                    end
                    preLineHight = contentSize.height
                    prewidth = contentSize.width
                end
            end
        else
            assert(startindex > 1 ,"startindex 重排的起始位置必须大于1")
            local var = layer.nodes[startindex - 1]
            local xpos,ypos,curentline_height,prewidth =
                var:getPositionX(),var:getPositionY(),var:getContentSize().width,var:getContentSize().height
            for i=startindex, # (layer.nodes)do
                var =  layer.nodes[i]

                local contentSize = var:getContentSize()

                if xpos + contentSize.width > viewSize.width + 10 then
                    xpos = 0
                    prewidth = nil
                    curentline_height = curentline_height + contentSize.height
                    var:setPosition(0,ypos - curentline_height + contentSize.height+ viewSize.height/2)
                else
                    xpos = xpos + (prewidth or 0)
                    var:setPosition(xpos,ypos - curentline_height + contentSize.height + viewSize.height/2)
                end

                prewidth = contentSize.width
            end
        end
    end

    for key, var in pairs(tb or {}) do
        xse.base.string.foreach(var.str,function(char)
            layer:addChar(char,var.color,var.event,nil,var.fontSize)
        end)
    end

    layer:sort()

    return layer
end

---有打印效果的文件效果
--@param instance event的第一个回传参数
--@param layer cc.Node
--@param tb table
--@usage richtext.playMessage(self,node:getChildByTag(500),{
--        {str="【丽轩中餐厅】" or cc.node,color = cc.c4b(255,0,0,255), fontSize = 24,   event = function() log("aaaaaaaaaaa") end},
--        {str="丽思卡尔顿酒店26楼！昨天真的是享受到前所未有的美食盛宴啊，把主厨的拿手好菜给点来吃了！有钱就是这么任性！快来吃一哈哦@成都美食 @成都探店",color = cc.c4b(255,0,255,255),  event = function() log("[bbbbbbbbbbbbbb]   ") end},
--        {str="cccccccccccccccccccccccccccccccccccccccccccc",color = cc.c4b(255,255,0,255),  event = function() log("ccccc") end}
--      })
function richtext.playMessage(instance,layer,tb,onshowComplate)
    --    local layer = xse.base.loadCCBI("MS.ccbi")
    --    xse.base.animal.showOnCenter(layer)
    instance = instance or {}
    require("richtext")
    local layer = richtext.create(instance,layer:getChildByTag(500))
    local curentCharIndex = 1
    layer.frameswitcher = 1
    layer.speedconter = 1
    local taskId = nil
    taskId =  xse.base.timer.tick.add(function()
        xpcall(function()
            if not layer.speedconter then
                xse.base.timer.tick.remove(taskId)
                return;
            end
            layer.speedconter = layer. speedconter + 1
            while layer. speedconter > layer.frameswitcher do
                layer. speedconter =layer. speedconter -layer.frameswitcher
                local foreachCharIndex = 0
                local isprocess = false
                for key, var in pairs(tb or {}) do

                    if type(var.str) == "string" then log(var.str)
                        xse.base.string.foreach(var.str,function(char)
                            foreachCharIndex = foreachCharIndex + 1
                            if foreachCharIndex == curentCharIndex and char ~= nil then
                                layer:addChar(char,var.color,var.event,var.eventargs,var.fontSize)
                                layer:sort()
                                isprocess = true
                            end
                        end)
                    elseif type(var.str) == "function" then
                        foreachCharIndex = foreachCharIndex + 1
                        if foreachCharIndex == curentCharIndex and var.str ~= nil then
                            layer:addChar(var.str(),var.color,var.event,var.fontSize)
                            layer:sort()
                            isprocess = true
                        end
                    end
                end
                if isprocess == false or layer:getParent() == nil then
                    xse.base.timer.tick.remove(taskId)
                    onshowComplate()
                end
                curentCharIndex = curentCharIndex + 1
            end
        end,function(e ) log(tostring(e)) xse.base.timer.tick.remove(taskId)end)
    end)

    function layer:resetA()
        self:reset()
        xse.base.timer.tick.remove(taskId)
    end

    return layer
end

return richtext