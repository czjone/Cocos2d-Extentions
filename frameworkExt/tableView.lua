---table view 对象，实现游戏中常用的表格
tableView = {}
local base =  require "base"

local CONSTANTS = {
    ITEM_OUT_BOX_UNSELECTED = "trade_project_item_type.png";
    ITEM_OUT_BOX_SELECTED = "public_item_selected_box.png";
}

---for table view
---@param singline 垂直排列时此参数才有效 是否为单列 当排列为单行时，可支持不同样式大小的节点，
---如果是非单列，由于同一行可能会出现高宽不一样的情况，很难计算，这里暂不支持多列且节点大小不一致的情况
---默认为单列
---本方法暂时只支持纵向排列
---align 对齐方式 0，左对齐，1 居中， 2 靠右 默认为0
function tableView.init(tb,process,scrollView,singline, isHorizontal, align)
    if isHorizontal == false then
        return tableView.initTableViewH(tb,process,scrollView,align)
    else
        return tableView.initTableView(tb,process,scrollView,singline, nil, nil, align)
    end;
end;

----@param downNodeFunc 获取下拉子节点
----@param refreshNodeFunc 刷新子节点
function tableView.initTableView(tb, process, scrollView, singline, downNodeFunc, refreshNodeFunc, align,createComplateCallBack)
    scrollView.nodes = {}
    assert(scrollView.getContainer,"scrollView argument isn't a  scrollview")
    --必须先移除所有的节点
    scrollView:getContainer():removeAllChildren()
    scrollView.moreNodeParent = nil;
    scrollView.moreNode = nil;
    local processPos = 0 ---已处理的数据索引
    --    local __id = nil

    if downNodeFunc then
        scrollView.moreNode = downNodeFunc();
        scrollView:addChild(scrollView.moreNode);
        scrollView.moreNode:setVisible(false);
    end

    ---强制重置定时器
    if scrollView.__id ~= nil then
        xse.base.timer.tick.remove(scrollView.__id )
    end
   
    scrollView:retain()
    scrollView.clickDropDownBtn = function(self,sender)
        if self.moreNodeParent == sender:getParent() then
            --将之前的节点选中效果去除
            xse.base.Sprite.setSpriteFrame(self.moreNodeParent, Tags.MAIN_ITEM_BOX_ID, CONSTANTS.ITEM_OUT_BOX_UNSELECTED);
            self.moreNodeParent = nil;
            self.moreNode:setVisible(false);
            self:sort()
            sender:setScaleY(sender:getScaleY() * -1.0)
        else
            --将之前的节点选中效果去除
            if self.moreNodeParent then
                xse.base.Sprite.setSpriteFrame(self.moreNodeParent, Tags.MAIN_ITEM_BOX_ID, CONSTANTS.ITEM_OUT_BOX_UNSELECTED);
                local oldSender = self.moreNodeParent:getChildByTag(10002);
                oldSender:setScaleY(oldSender:getScaleY() * -1.0)
            end
            self.moreNodeParent = sender:getParent();
            self.moreNode:setVisible(true);
            if refreshNodeFunc then
                --增加选中效果
                xse.base.Sprite.setSpriteFrame(self.moreNodeParent, Tags.MAIN_ITEM_BOX_ID, CONSTANTS.ITEM_OUT_BOX_SELECTED);
                refreshNodeFunc(self.moreNode, self.moreNodeParent);
            end;
            self:sort()
            sender:setScaleY(sender:getScaleY() * -1.0)
        end;
    end
    
    --收起某个节点，如果这个节点未展开，则不管
    scrollView.retract = function(self,node)
        if self.moreNodeParent == node then
            --将之前的节点选中效果去除
            xse.base.Sprite.setSpriteFrame(self.moreNodeParent, Tags.MAIN_ITEM_BOX_ID, CONSTANTS.ITEM_OUT_BOX_UNSELECTED);
            self.moreNodeParent = nil;
            self.moreNode:setVisible(false);
            self:sort()
            local sender = node:getChildByTag(Tags.DROP_DOWN_BTN);
            sender:setScaleY(sender:getScaleY() * -1.0);
        end;
    end
    
    scrollView.__id = xse.base.timer.tick.add(function()
        ---异步处理步长
        local CONST_PROCESS_ONCES = 0.3
        local PROCESS_SORT_START = 30

        ---移除异步处理事件
        if table.getLength(tb) ==  0 or scrollView:getReferenceCount() == 1 then
            xse.base.timer.tick.remove(scrollView.__id)
            scrollView:release()
            return
        end

        ---处理当前的数据。分步处理，一次处理 CONST_PROCESS_ONCES 条
        local processCounter = CONST_PROCESS_ONCES
        local eachIndex = 0 ---迭代到索引
        local tbLength = table.getLength(tb)
        table.foreach(tb,function(k,v)
            if scrollView:getParent() == nil then
                xse.base.timer.tick.remove(scrollView.__id )
                scrollView:release()
            end

            eachIndex =  eachIndex + 1
            if processCounter >= 0 and eachIndex > processPos   then
                processPos = processPos + 1
                processCounter = processCounter - 1

                local node =process(v)

                if downNodeFunc then
                    xse.base.setCCBottonOnClickD(node:getChildByTag(Tags.DROP_DOWN_BTN), scrollView.clickDropDownBtn,scrollView,nil,"dropdown.click")
                end


                scrollView:addChild(node)
                table.insert(scrollView.nodes,node)

                if eachIndex >= tbLength then
                    xse.base.timer.tick.remove(scrollView.__id )
                    scrollView:release()
                    if createComplateCallBack then createComplateCallBack() end
                end
            end
        end)

        if eachIndex >=  PROCESS_SORT_START or eachIndex >= tbLength then
            scrollView:sort()
        end

    end)

    function scrollView:sort()

        local viewSize = self:getViewSize()
        local size = {width = 0,height = 0}

        --从下往上排列，需要倒序遍历
        local length = #self.nodes;
        local childNodeSize;
        local x = 0;
        local y = 0;
        local coloumNum;
        for i =1, length do
            local var = self.nodes[i];
            var:setAnchorPoint(0,0)
            if singline then
                local contentSize = var:getContentSize();
                childNodeSize = {width = contentSize.width * var:getScaleX(), height = contentSize.height * var:getScaleY()};
                --左对齐
                if align == 1 then x = (viewSize.width - childNodeSize.width) / 2 elseif align == 2 then x = viewSize.width - childNodeSize.width else x = 0 end;
                size.width  = math.max(size.width, x + childNodeSize.width)
                size.height  = math.max(size.height, y + childNodeSize.height)
                y = y + childNodeSize.height;
                var:setPosition(x, viewSize.height - y);

                --摆放子节点
                if self.moreNodeParent and var == self.moreNodeParent then
                    self.moreNode:setAnchorPoint(0,0);
                    local contentSize = self.moreNode:getContentSize();
                    childNodeSize = {width = contentSize.width * var:getScaleX(), height = contentSize.height * var:getScaleY()};
                    if align == 1 then x = (viewSize.width - childNodeSize.width) / 2 elseif align == 2 then x = viewSize.width - childNodeSize.width else x = 0 end;
                    size.width  = math.max(size.width, x + childNodeSize.width)
                    size.height  = math.max(size.height, y + childNodeSize.height)
                    y = y + childNodeSize.height;
                    self.moreNode:setPosition(x, viewSize.height - y);
                end;
            else
                --多列只支持同一种样式大小的节点，所以子节点大小只取一次就好
                if not childNodeSize then
                    local contentSize = var:getContentSize();
                    childNodeSize = {width = contentSize.width * var:getScaleX(), height = contentSize.height * var:getScaleY()};
                    coloumNum = math.floor(viewSize.width / childNodeSize.width);
                    if coloumNum <= 0 then coloumNum = 1; end;
                    size.width  = coloumNum * childNodeSize.width
                    size.height = math.ceil(length / coloumNum) * childNodeSize.height;
                    if align == 1 then x = (viewSize.width - childNodeSize.width * coloumNum) / 2 elseif align == 2 then x = viewSize.width - childNodeSize.width * coloumNum else x = 0 end;
                end
                --由于框架摆放的bug，节点从下往上摆，在计算行和列时需要特殊处理。比如一共8个节点，每行三个，则i=1时，即第8个节点，应该为第三行的第二列。从下往上即第一行第二列
                local rowNum = math.ceil(i / coloumNum);
                local colNum = (i - 1) % coloumNum + 1;
                y = childNodeSize.height * rowNum
                var:setPosition(x + (colNum - 1) * childNodeSize.width, viewSize.height - y);
            end
        end

        self:setContentSize(math.max(viewSize.width,size.width), math.max(viewSize.height, size.height))

        --展示下拉结点的时候，需要自动帮助用户调整界面，尽量使整个下拉node1可见
        if self.moreNodeParent then
            local minOffsetY = -self.moreNode:getPositionY()
            local offset = self:getContentOffset();
            if offset.y <  minOffsetY then
                self:setContentOffset(cc.p(offset.x, minOffsetY), true);
            end;
        end;
    end

    scrollView.add = function(self, data)
        local node =  process(data)
        table.insert(scrollView.nodes,node)
        self:addChild(node)

        self:sort();
    end;

    --按下标进行删除
    scrollView.remove = function(self, i)
        --先收起节点
        self:retract(self.nodes[i]);
        self.nodes[i]:setVisible(false);
        table.remove(self.nodes, i)
        self:sort();
    end;

    --按node进行删除
    scrollView.removeNode = function(self, node)
        for i,v in pairs(self.nodes) do
            if v == node then
                self:remove(i);
                return;
            end;
        end
    end;

    --    scrollView:sort()

    return scrollView
end



---与initTableView不同的是，此方法用于横向布局
--align 对齐方式 0，上对齐，1 居中， 2 靠下 默认为1
function tableView.initTableViewH(tb, process, scrollView, align)
    scrollView.nodes = {}
    --必须先移除所有的节点
    scrollView:getContainer():removeAllChildren()
    scrollView.moreNodeParent = nil;
    scrollView.moreNode = nil;
    for key, var in pairs(tb) do
        local node =  process(var)
        scrollView:addChild(node)
        table.insert(scrollView.nodes,node)
    end

    function scrollView:sort()

        local viewSize = self:getViewSize()
        local size = {width = 0,height = 0}

        --从下往上排列，需要倒序遍历
        local length = #self.nodes;
        local childNodeSize;
        local x = 0;
        local y = 0;
        local coloumNum;
        for i =1, length do
            local var = self.nodes[i];
            var:setAnchorPoint(0,0)

            local contentSize = var:getContentSize();
            childNodeSize = {width = contentSize.width * var:getScaleX(), height = contentSize.height * var:getScaleY()};
            --左对齐
            if align == 0 then y = viewSize.height - childNodeSize.height elseif align == 2 then y = 0 else y = (viewSize.height - childNodeSize.height) / 2 end;
            var:setPosition(x, y);
            size.width  = math.max(size.width, x + childNodeSize.width)
            size.height  = math.max(size.height, y + childNodeSize.height)
            x = x + childNodeSize.width;
        end

        --        self:getContainer():setContentSize(math.max(viewSize.width,size.width), math.max(viewSize.height, size.height))
        self:setContentSize(math.max(viewSize.width,size.width), math.max(viewSize.height, size.height))
    end

    scrollView.add = function(self, data)
        local node =  process(data)
        table.insert(scrollView.nodes,node)
        self:addChild(node)
        self:sort();
    end;

    --按下标进行删除
    scrollView.remove = function(self, i)
        self.nodes[i]:setVisible(false);
        table.remove(self.nodes, i)
        self:sort();
    end;

    --按node进行删除
    scrollView.removeNode = function(self, node)
        for i,v in pairs(self.nodes) do
            if v == node then
                self:remove(i);
                return;
            end;
        end
    end;

    scrollView:sort()

    return scrollView
end

return tableView
