---与界面相关的tableView ,带有一个展开的子节点
listView = {}
require "base"
local tableView =require "tableView"

local GAP = 2;

local TURN_PAGE_BTN_HEIGHT = 42;
local TURN_PAGE_BTN_WIDTH = 224;

local function checkdatas(tb)
    if table.isEmpty(tb) == true then
        local tips = require("tips")
        tips.show(xse.language.format("empty_message_tips"))
    end
end

----------------------------------------------------------------
--本函数已废弃

---带有更多信息行的table view 排序，在展开的后，会向self中添加一个moreNode, self.moreNode,如果 为空就没有展开的节点
--moreid,moreNodeName 同时为空就不展开更多子节点
--moreid,moreNodeName 同时不为空 ：moreid 与展开id相同就关闭节点，moreid 与展开id不相同就展开节点
--如果在moreid 与展开id相同的情况下传了不同的与展开node不同的ccbi moreNodeName，就会替换原来的moreNode
--
--[PS:]在你没有时间重写这个项目50%的代码的情况下不要修改这个函数
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #table tb 当前要操作的数据
--@param #number moreid 当前展开的节点的tag，会向这个item中添加一个
--@param #string moreNodeName 展开节点的CCBI名字
--@param #boolean rebuild 是否重新构建列表
--@param #function process 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number layerTag 在self.node中的目标名称
--@param #node  node
--@return #scrollView 返回当前所在的滚动框u
function listView.sortA(self, tb,moreid,moreNodeName,rebuild,process,layerTag,node,oncloseMoreNodeCallBack,onBeginDropCallback)
    assert("本函数已废弃")
    checkdatas(tb)

    -------------删除更多子节点------------------------
    local function removeMoreNode(cachecurrentMoreNodenames)
        ---是否缓存当前用过的moreNodeName
        cachecurrentMoreNodenames = cachecurrentMoreNodenames or false
        ---删除morenode
        if self.moreNode ~= nil then
            if self.moreNode.getParent and self.moreNode:getParent() ~= nil then
                self.moreNode:getParent():removeChild(self.moreNode)
            end
            self.moreNode = nil
        end

        local exist = table.exist(self.moreNodes,function(v) return v == moreNodeName end) == true

        ---收起时回调
        if self.moreid == moreid and oncloseMoreNodeCallBack and exist  then
            oncloseMoreNodeCallBack(self.moreNode)
        end

        ---是否同一个下拉节点中进行过多次的切换
        if self.moreid ~= moreid or exist then
            if cachecurrentMoreNodenames == false then self.moreNodes ={} end
            if self.moreNode and self.moreNode:getParent() ~=nil then self.moreNode:getParent():removeChild(self.moreNode) end
            self.moreNode = nil
        end
    end

    ----------重新构建tableview-----------------------------
    local tb = tb or {}
    local scrollview = node or self.node:getChildByTag(layerTag)
    local layer =  scrollview:getContainer()
    if rebuild == true or scrollview.tbv == nil then
        ---如果已构建过就处理下morenode
        removeMoreNode(rebuild)
        local function getMoreNode()
            self.moreNodeName = moreNodeName or self.moreNodeName
            self.moreNode = self.moreNode or xse.base.loadCCBI(self.moreNodeName)
            self.templateMoreNode = self.moreNode
            return self.moreNode
        end

        scrollview.tbv = tableView.initTableView(tb, process, scrollview, 0, getMoreNode, function() end, 0)
    end

    --------------子节点管理逻辑----------------------------
    do
        local types = {
            NEW_MORE_NODE =1,
            SWITCH_NODE = 2,
            CLOSE_MORE_NODE = 3,
        }

        self.moreNodes = self.moreNodes or {}

        ---在同一个更多的节点下换一个CCBI node
        local function isSwitchMoreNode()
            return moreid ~= nil and (#(self.moreNodes) > 0 and self.moreid == moreid and
                table.exist(self.moreNodes,function(v) return v == moreNodeName end) == false)
        end
        ---创建一个新的更多节点
        local function isNewMoreNode() return  moreid ~= nil and (#(self.moreNodes) == 0 or self.moreid ~= moreid) end
        local function isCloseMoreNode() return moreid ~= nil and (#(self.moreNodes) > 0 and self.moreid == moreid) end
        ---创建更多节点的逻辑
        local function createMoreNode(moreNodeName)
            if moreNodeName ~= nil then
                self.moreNodeName = moreNodeName or self.moreNodeName

                if table.exist(self.moreNodes,function(v) return v == moreNodeName end) == false then
                    table.insert(self.moreNodes,self.moreNodeName or "")
                end

                self.moreNode = xse.base.loadCCBI(self.moreNodeName)
                scrollview:addChild(self.moreNode);
                scrollview.moreNode = self.moreNode
                --scrollView.moreNode:setVisible(true);
                scrollview.moreNodeParent = layer:getChildByTag(moreid)
                scrollview:sort()
                self.moreid = moreid
                self.templateMoreNode:setVisible(false)

                ---是否为第一次打开更多节点
                if onBeginDropCallback and table.getLength(self.moreNodes) == 1 then
                    onBeginDropCallback()
                end
            end
        end

        ---修改更多节点为其它CCBI
        local function switchMoreNode(moreNodeName) removeMoreNode()  createMoreNode(moreNodeName)  end
        local function processMoreNode()
            if isNewMoreNode() then removeMoreNode() createMoreNode(moreNodeName)
            elseif isSwitchMoreNode() then  switchMoreNode(moreNodeName)
            elseif isCloseMoreNode() then removeMoreNode()
            else removeMoreNode()
            end
        end

        if moreid ~= nil then processMoreNode() end

        ---设置跟多节点的大小
        if layer:getChildren()[1] and self.moreNode then
            self.moreNode:setScale(layer:getChildren()[1]:getScaleX(),layer:getChildren()[1]:getScaleY())
        end
    end

    layer.nodes = scrollview.tbv.nodes
    return layer
end

---没有更多信息的table view 排序
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #table tb 当前要操作的数据
--@param #boolean rebuild 是否重新构建列表
--@param #function process 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number layerTag 在self.node中的目标名称
--@param singleLine number 是否为单行，默认为单行，非0 为多行
--@return #scrollView 返回当前所在的滚动框
function listView.sort(self, tb,rebuild,process,layerTag,singleLine, isHorizontal,align)
    checkdatas(tb)
    local tb = tb or {}
    local scrollview = self.node:getChildByTag(layerTag)
    --初始化一个新的table view
    if rebuild or self.node.tbv == nil then
        self.node.tbv  =  tableView.init(tb,process,scrollview,singleLine == 0, isHorizontal, align);
    end
    return scrollview
end

--此方法不需要传self
function listView.sortForNode(parentNode, datas, getNodeFunc, layerTag, isHorizontal,align)
    checkdatas(datas)
    local datas = datas or {}
    local scrollview = parentNode:getChildByTag(layerTag)
    --初始化一个新的table view
    if parentNode.tbv == nil then
        parentNode.tbv  =  tableView.init(datas, getNodeFunc, scrollview, true, isHorizontal, align);
    end
    return scrollview
end

--与sort方法不同的是，本方法需要支持点击下拉结点,且只支持单列
function listView.sort4DropDownView(self, tb, process, layerTag, downNodeFunc, refreshNodeFunc)
    checkdatas(tb)
    local tb = tb or {}
    local scrollview = self.node:getChildByTag(layerTag)
    self.node.tbv  =  tableView.initTableView(tb, process, scrollview, true, downNodeFunc, refreshNodeFunc);
    return scrollview
end

---没有更多信息的table view 排序,会检查tb数据是否为合法的数据，就是是否为空
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #table tb 当前要操作的数据
--@param #boolean rebuild 是否重新构建列表
--@param #function process 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number layerTag 在self.node中的目标名称
--@param singleLine number 是否为单行，默认为单
function listView.sortB(self, tb,rebuild,process,layerTag,singleLine)
    checkdatas(tb)
    if tb == nil or #tb == 0 then
        local tips = require("tips")
        local language = require("languageServices")
        tips.show(language.format("RECIVE_DATASUCCESS"))
    else
        return listView.sort(self, tb,rebuild,process,layerTag,singleLine)
    end
end

---没有更多信息的table view 排序
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #cc.Node node 自己定义的scrollview节点
--@param #table tb 当前要操作的数据
--@param #boolean rebuild 是否重新构建列表
--@param #function process 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number layerTag 在self.node中的目标名称
--@param singleLine number 是否为单行，默认为单行，非0 为多行
--@return #scrollView 返回当前所在的滚动框
function listView.sortD(self,node, tb,rebuild,process,layerTag,singleLine,needCheckData)
    if needCheckData ~=false then
        checkdatas(tb)
    end
    local tb = tb or {}
    local _node = node or self.node
    local scrollview = _node:getChildByTag(layerTag)
    local layer =  scrollview:getContainer()
    local contentSize = scrollview:getViewSize()
    assert(layer,"ccbi file not fond tag,tag:"..layerTag)
    log("widht:"..contentSize.width.."height:"..contentSize.height)
    --初始化一个新的table view
    if rebuild or _node.tbv == nil then
        if not singleLine and singleLine~=0 then width = contentSize.width end
        _node.tbv  =  tableView.init(tb,process,scrollview,false, singleLine == 0);
    end
    return scrollview
end

---没有更多信息的table view 排序
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #cc.Node node 自己定义的scrollview节点
--@param #table tb 当前要操作的数据
--@param #boolean rebuild 是否重新构建列表
--@param #function process 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number layerTag 在self.node中的目标名称
--@param singleLine number 是否为单行，默认为单行，非0 为多行
--@return #scrollView 返回当前所在的滚动框
function listView.sortE(self,node, tb,rebuild,process,layerTag,singleLine,needCheckData)
    if needCheckData ~=false then
        checkdatas(tb)
    end
    local tb = tb or {}
    local _node = node or self.node
    local scrollview = _node:getChildByTag(layerTag)
    local layer =  scrollview:getContainer()
    local contentSize = scrollview:getViewSize()
    assert(layer,"ccbi file not fond tag,tag:"..layerTag)
    log("widht:"..contentSize.width.."height:"..contentSize.height)
    --初始化一个新的table view
    if rebuild or _node.tbv == nil then
        if not singleLine and singleLine~=0 then width = contentSize.width end
        _node.tbv  =  tableView.init(tb,process,scrollview,rebuild, singleLine == 0);
    end
    return scrollview
end



--与sortForNormalLayer不同的是，直接传入layer，而不是传入parentNode和tag
function listView.sortForNormalLayer(rootNode, list, getNodeFunction, layerTag, verticalGap, horizontalGap, align)
    if rootNode then
        local layer =  rootNode:getChildByTag(layerTag);
        return listView.sortForNormalLayer2(layer, list, getNodeFunction, verticalGap, horizontalGap,align);
    end
end

---构造一个普通的table 不可拖动
--不支持大小不一致的node的自动排列
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #table list 当前要操作的数据
--@param #function getNodeFunction 处理某一行的逻辑，其中会包含处理一行中包含更多的模块
--@param #number verticalGap,  horizontalGap指定元素之间的纵向和横向间隔，不指定为2
--@return #scrollView 返回当前所在的滚动框
--align 对齐方式 0，左对齐，1 居中， 2 靠右 默认为1
function listView.sortForNormalLayer2(layer, list, getNodeFunction, verticalGap, horizontalGap, align)
    local contentSize = layer:getContentSize();
    verticalGap = verticalGap or GAP;
    horizontalGap = horizontalGap or GAP;
    align = align or 1;
    layer:removeAllChildren();

    if not list or #list == 0 then
        return layer;
    end;

    local nodes = {};
    for i,v in pairs(list) do
        local node = getNodeFunction(v);
        table.insert(nodes, node);
    end;

    layer.nodes = nodes;

    if #nodes > 0 then
        local nodeHeight = nodes[1]:getContentSize().height;
        local nodeWidth = nodes[1]:getContentSize().width;
        local col = math.floor((contentSize.width + horizontalGap) / (nodeWidth + horizontalGap));
        col = (col < 1 and 1) or col;

        --靠左
        if align == 0 then
            for i,v in pairs(nodes) do
                layer:addChild(v)
                local rowNum = math.ceil(i / col);
                local colNum = (i - 1) % col + 1;
                v:setPosition((colNum - 1) * (nodeWidth + horizontalGap), contentSize.height - GAP - (nodeHeight * rowNum) - verticalGap * (rowNum - 1));
            end;
        elseif align == 2 then
            local row = math.ceil(#nodes / col);
            local remainColLastRow = col - #nodes % col;
            for i,v in pairs(nodes) do
                layer:addChild(v)
                local rowNum = math.ceil(i / col);
                local colNum = (i - 1) % col + 1;
                if rowNum == row then
                    v:setPosition(contentSize.width - (col - colNum - remainColLastRow) * (nodeWidth + horizontalGap) - nodeWidth, contentSize.height - GAP - (nodeHeight * rowNum) - verticalGap * (rowNum - 1));
                else
                    v:setPosition(contentSize.width - (col - colNum) * (nodeWidth + horizontalGap) - nodeWidth, contentSize.height - GAP - (nodeHeight * rowNum) - verticalGap * (rowNum - 1));
                end
            end;
        else
            --离两端的距离
            local margin = (contentSize.width  - horizontalGap * (col - 1) - nodeWidth * col) / 2;
            for i,v in pairs(nodes) do
                layer:addChild(v)
                local rowNum = math.ceil(i / col);
                local colNum = (i - 1) % col + 1;
                v:setPosition(margin + (colNum - 1) * (nodeWidth + horizontalGap), contentSize.height - GAP - (nodeHeight * rowNum) - verticalGap * (rowNum - 1));
            end;
        end
    end;

    return layer
end



---构造一个普通的table 不可拖动,但是可以翻页
--只有当容器无法放完所有控件时才可分页，否则与sortForNormalLayer无区别
--不支持大小不一致的node的自动排列
--@param #table self 当前的模板对象，包含self.node 与self.getMaster
--@param #table list 当前要操作的数据
--@param #function getNodeFunc 每个节点的node，一般只需简单的return CCBI即可，数据填充在refreshNodeFunc中
--@param #function refreshNodeFunc 初始化node的界面属性
--@param #number verticalGap,  horizontalGap指定元素之间的纵向和横向间隔，不指定为2
--@param align 对齐方式 0，左对齐，1 居中， 2 靠右 默认为1  暂时不支持对齐方式设定，后续有需要可加入
--@return #scrollView 返回当前所在的layer
function listView.sortForNormalLayerByPage(layer, list, getNodeFunc, refreshNodeFunc, verticalGap, horizontalGap)

    if not layer.page or table.getLength(list) ~= table.getLength(layer.data) then
        local contentSize = layer:getContentSize();
        verticalGap = verticalGap or GAP;
        horizontalGap = horizontalGap or GAP;
        layer:removeAllChildren();

        if not list or #list == 0 then
            layer.data = list;
            return layer;
        end;

        local nodes = {};
        nodes[1] = getNodeFunc();

        --取第一个节点作为基准大小
        local nodeHeight = nodes[1]:getContentSize().height;
        local nodeWidth = nodes[1]:getContentSize().width;
        local col = math.floor((contentSize.width + horizontalGap) / (nodeWidth + horizontalGap));
        local row = math.floor((contentSize.height + verticalGap) / (nodeHeight + verticalGap));
        --col, row最小为1
        col = (col < 1 and 1) or col;
        row = (row < 1 and 1) or row;

        local pageNum;
        --如果最多摆放的节点数量大于或等于实际数量，则不需要翻页功能, 否则，还要显示翻页按钮，而且翻页按钮会占据一定高度，需要重新计算row
        if (col * row < table.getLength(list)) then
            --TURN_PAGE_BTN_HEIGHT为翻页控件的高度，暂时写死
            row = math.floor((contentSize.height - TURN_PAGE_BTN_HEIGHT + verticalGap) / (nodeHeight + verticalGap));
            pageNum = col * row;

            local turnPageBtn = xse.base.loadCCBI("public_leftrightbtn_group");
            layer:addChild(turnPageBtn)
            turnPageBtn:setPosition((contentSize.width -  TURN_PAGE_BTN_WIDTH)/ 2, GAP);
            --翻页按钮事件注册
            xse.base.setCCBottonOnClick(turnPageBtn:getChildByTag(82),function(instance)
                instance:nextPage()
            end, layer)
            xse.base.setCCBottonOnClick(turnPageBtn:getChildByTag(83),function(instance)
                instance:prePage()
            end, layer)
            layer.maxPage = math.ceil(table.getLength(list) / pageNum);
            layer.turnPageBtn = turnPageBtn;
        else
            pageNum = table.getLength(list);
            layer.maxPage = 1;
        end;

        for i = 2, pageNum do
            table.insert(nodes, getNodeFunc());
        end;
        layer.nodes = nodes;

        --离两端的距离
        local margin = (contentSize.width  - horizontalGap * (col - 1) - nodeWidth * col) / 2;
        for i,v in pairs(nodes) do
            layer:addChild(v)
            local rowNum = math.ceil(i / col);
            local colNum = (i - 1) % col + 1;
            v:setPosition(margin + (colNum - 1) * (nodeWidth + horizontalGap), contentSize.height - GAP - (nodeHeight * rowNum) - verticalGap * (rowNum - 1));
        end;

        layer.col = col;
        layer.row = row;

        --下一页
        layer.nextPage = function(layer)
            if not layer.page or layer.page == layer.maxPage then
                layer.page = 1
            else
                layer.page = layer.page + 1;
            end;
            layer:refreshData(startIndex, endIndex);
        end;

        --上一页
        layer.prePage = function(layer)
            if not layer.page or layer.page == 1 then
                layer.page = layer.maxPage
            else
                layer.page = layer.page - 1;
            end;
            layer:refreshData(startIndex, endIndex);
        end;

        layer.refreshData = function(layer)
            if not layer.page then layer.page = 1 end;
            if layer.page > layer.maxPage then layer.page = layer.maxPage end;
            local startIndex = (layer.page - 1) * layer.col * layer.row;
            local endIndex = layer.page * layer.col * layer.row;
            if endIndex > table.getLength(layer.data) then endIndex = table.getLength(layer.data) end;
            for i, v in pairs(layer.nodes) do
                if i + startIndex > endIndex then
                    if layer.nodes[i] then
                        layer.nodes[i]:setVisible(false);
                    end
                else
                    refreshNodeFunc(layer.nodes[i], layer.data[i + startIndex]);
                    layer.nodes[i]:setVisible(true);
                end;
            end;
            if layer.turnPageBtn then
                layer.turnPageBtn:getChildByTag(10):setString(layer.page .. "/" .. layer.maxPage);
            end
        end;

        --用来清空整个layer
        layer.clear = function(layer)
            layer.page = nil;
        end
    end
    layer.data = list;
    layer:refreshData();
    return layer
end

return listView