--多面板实现类
--暂时只支持两级按钮，如需扩展，重写createBtn方法
--@author wangbing
--local xse =require "depend"
require "base"

local tabView = {};

local CONSTANTS = {
    TAB_BTN1_CCBI = "tabBtn1.ccbi";
    TAB_BTN2_CCBI = "tabBtn2.ccbi";
    LV1_BTN_VERTICAL_GAP = 22;
    
    BTN_ID = 1;
    BTN_LABEL_ID = 2;
    GAP = 0;
    
    LV2_BTN_WIDTH = 280;
    LV2_BTN_HEIGHT = 40;
    --二级按钮和1级按钮的高度差
    LV2_BTN_VERTICAL_GAP = 2;
    --二级按钮之间的间距
    LV2_BTN_HORIZONTAL_GAP = 5;
    LV2_BTN_MARGIN = 16;
    
    
    BTN_LAYER_NAME = "tabview_btn";
    BTN_ACTION_NAME = "tabSelected";
    
    BTN1_WIDTH_SCALE = {1.5,1.08,0.80};
    BTN1_HEIGHT_SCALE = {1.0,1.0,1.0};
    --按钮变小时和变大时的差距
    BTN1_WIDTH_DIFF = {26, 19, 15};
    --按钮间的缝隙
    BTN1_WIDTH_GAP = {5, 5, 5};
    --按钮变大后字体变大号数
    LABEL_FONT_SIZE_ADD = 2;
    --按钮变大后字体Y轴移动距离
    LABEL_POSITION_Y_ADD = 6;
}

--创建tabview
--@param node 需要创建多面板视图的节点
--@param #number layerTag 创建多面板的layer
--@param #string数组 tabBtnNames 多面板按钮的名字，传入数组
--@param #获取节点的函数 getNodeFunctions 生成多面板内容的方法，数组
--@param #是否需要移动特效 needMoveEffect 
function tabView.createTabView(self, menuLayer, contentLayer, menuInfo, verticalGap, bigBtnName, index1, index2, needMoveEffect)
    local contentSize = menuLayer:getContentSize();
    
    local viewInfo = {};
    viewInfo.mainLayer = contentLayer;
    viewInfo.nodes = {};
    local lv1Btns = tabView.createLv1Btns(menuInfo, bigBtnName);
    --给按钮布局
    local btnHeight = lv1Btns[1]:getContentSize().height * CONSTANTS.BTN1_HEIGHT_SCALE[#menuInfo - 1];
    local btnWidth = lv1Btns[1]:getContentSize().width * CONSTANTS.BTN1_WIDTH_SCALE[#menuInfo - 1] - CONSTANTS.BTN1_WIDTH_DIFF[#menuInfo - 1];
    local horizontalGap = (contentSize.width - btnWidth * #lv1Btns - CONSTANTS.BTN1_WIDTH_GAP[#menuInfo - 1] * (#lv1Btns - 1) - CONSTANTS.BTN1_WIDTH_DIFF[#menuInfo - 1]) / 2;
    verticalGap = verticalGap or CONSTANTS.LV1_BTN_VERTICAL_GAP;
    local lv1BtnLocationY = contentSize.height - verticalGap - btnHeight
    
    local lv2BtnLocationY = lv1BtnLocationY - CONSTANTS.LV2_BTN_VERTICAL_GAP - CONSTANTS.LV2_BTN_HEIGHT;
    
    for i, v in pairs(lv1Btns) do
        --设置按钮位置
        menuLayer:addChild(v)
        v:setPosition(horizontalGap + (i - 1) * (btnWidth + CONSTANTS.BTN1_WIDTH_GAP[#menuInfo - 1]) - CONSTANTS.BTN1_WIDTH_DIFF[#menuInfo - 1] / 2, lv1BtnLocationY);
        --注册引用，需要通过btn找到父节点
        v.parent = viewInfo;
        if menuInfo[i].child then
            local length = #menuInfo[i].child;
            --二级面板可以为空
            local lv2BtnWidth = (contentSize.width - CONSTANTS.LV2_BTN_HORIZONTAL_GAP * (length - 1) - CONSTANTS.LV2_BTN_MARGIN * 2) / length;
            v.btns = tabView.createLv2Btns(menuInfo[i].child, lv2BtnWidth);
            for j, w in pairs(v.btns) do
                --设置按钮位置
                menuLayer:addChild(w)
                w:setPosition(CONSTANTS.LV2_BTN_MARGIN + (j - 1) * (lv2BtnWidth + CONSTANTS.LV2_BTN_HORIZONTAL_GAP), lv2BtnLocationY);
                --注册引用，需要通过btn找到父节点
                w.parent = v;
            end;
            v.select = function(parent, index, childIndex) tabView.select(self, parent, viewInfo, index, childIndex, false, needMoveEffect);end
            v.menu = menuInfo[i].child;
        end
    end;
    
    viewInfo.btns = lv1Btns;
    viewInfo.menu = menuInfo;
    --定义选中方法
    viewInfo.select = function(parent, index, childIndex) tabView.select(self, parent, viewInfo, index, childIndex, true, needMoveEffect);end
    viewInfo:select(index1, index2);
end;

--选中按钮事件
function tabView.select(self, parent, viewInfo, index, childIndex, isBigBtn, needMoveEffect)
    if index == parent.selectedIndex and parent.selectedIndex then 
        --不管连续两次是否选择的是否是同一个Tab，这里都要刷新，因为底层一个按钮连续点击两次会取消其选中效果
        for i,v in pairs(parent.btns) do
            if i == index then 
                tabView.setSelectedState(v, true);
            else
                tabView.setSelectedState(v, false);
            end;
        end
        
        return;
    end;
    
    index = index or parent.selectedIndex or 1;
    --是否需要移动特效
    needMoveEffect = needMoveEffect == nil or needMoveEffect;
    --这里有特效，每次重新选择之后，将大按钮位置复原
    if index ~= parent.selectedIndex and isBigBtn and needMoveEffect then
        local num = #parent.btns;
        if parent.selectedIndex then
            for i=1, num do
            	if i == parent.selectedIndex then
                    tabView.move(parent.btns[i], -CONSTANTS.BTN1_WIDTH_DIFF[num - 1] / 2);
                    local label = parent.btns[i]:getChildByTag(2);
                    local fontSize = label:getSystemFontSize();
                    label:setSystemFontSize(fontSize - CONSTANTS.LABEL_FONT_SIZE_ADD);
                    tabView.move(label, 0, -CONSTANTS.LABEL_POSITION_Y_ADD);
                elseif i > parent.selectedIndex then
                    tabView.move(parent.btns[i], -CONSTANTS.BTN1_WIDTH_DIFF[num - 1]);
            	end;
            end
        end
        
        for i=1, num do
            if i == index then
                tabView.move(parent.btns[i], CONSTANTS.BTN1_WIDTH_DIFF[num - 1] / 2);
                --字体大两号，位置上移
                local label = parent.btns[i]:getChildByTag(CONSTANTS.BTN_LABEL_ID);
                local fontSize = label:getSystemFontSize();
                label:setSystemFontSize(fontSize + CONSTANTS.LABEL_FONT_SIZE_ADD);
                tabView.move(label, 0, CONSTANTS.LABEL_POSITION_Y_ADD);
            elseif i > index then
                tabView.move(parent.btns[i], CONSTANTS.BTN1_WIDTH_DIFF[num - 1]);
            end;
        end
    end;
    
    --不管连续两次是否选择的是否是同一个Tab，这里都要刷新，因为底层一个按钮连续点击两次会取消其选中效果
    for i,v in pairs(parent.btns) do
        if i == index then 
            tabView.setSelectedState(v, true);
        else
            tabView.setSelectedState(v, false);
        end;
    end
    
    --如果此按钮还有子按钮
    if parent.btns[index].btns then
        --二级按钮地板显示
        if isBigBtn and self.setLv2BtnBGVisable then self:setLv2BtnBGVisable(true); end;
        parent.btns[index]:select(childIndex);
    else
        --二级按钮地板隐藏 
        if isBigBtn and self.setLv2BtnBGVisable then self:setLv2BtnBGVisable(false); end;
        --如果选中的面板node为空，则加载node
        parent.nodes = parent.nodes or {};
        local node = parent.nodes[index]
        if not node then 
            node = parent.menu[index].getNode(self);
            parent.nodes[index]= node;
            --node不为空且没有父节点的情况下加入
            if node and not node:getParent() and viewInfo.mainLayer then
                viewInfo.mainLayer:addChild(node);
                node:setPosition(CONSTANTS.GAP, CONSTANTS.GAP);
            end;
        elseif parent.menu[index].reload then
            parent.menu[index].reload(self, node);
        end;
        
        if viewInfo.currentNode == node then 
            parent.selectedIndex = index;
            return;
        else
            if viewInfo.currentNode then viewInfo.currentNode:setVisible(false); end
            viewInfo.currentNode = node;
            viewInfo.currentNode:setVisible(true);
        end;
    end;
    parent.selectedIndex = index;
    
end;

function tabView.move(node, gapX, gapY)
    local x,y = node:getPosition();
    gapX = gapX or 0;
    gapY = gapY or 0;
    node:setPosition(x + gapX, y + gapY);
end;

function tabView.setSelectedState(btn, selected)
    --其下面的子按钮变为可见
    if btn.btns then
        for j,w in pairs(btn.btns) do
            w:setVisible(selected);
        end;
    end;
    xse.base.setCCBottonSelecteState(btn, CONSTANTS.BTN_ID, selected);
end;

function tabView.tabSelected(sender)
    local node = sender:getParent()
    for i,v in pairs(node.parent.btns) do
        if v == node then 
            node.parent:select(i);
            return;
        end;
    end;
end

--只要没有指定是第二级按钮，则返回大按钮
function tabView.createLv1Btns(menuInfo,bigBtnName)
    local btns = {};
    for i, v in pairs(menuInfo) do
        table.insert(btns, tabView.createLv1Btn(v.title, #menuInfo, bigBtnName));
    end
    return btns;
end

--只要没有指定是第二级按钮，则返回大按钮
function tabView.createLv2Btns(menuInfo, width)
    local btns = {};
    for i, v in pairs(menuInfo) do
        table.insert(btns, tabView.createLv2Btn(v.title, width));
    end
    return btns;
end

--只要没有指定是第二级按钮，则返回大按钮
function tabView.createLv1Btn(name,num, bigBtnName)
    bigBtnName = bigBtnName or CONSTANTS.TAB_BTN1_CCBI
    local node = xse.base.loadCCBI(bigBtnName);
    local btnWidth = node:getContentSize().width;
    node:getChildByTag(CONSTANTS.BTN_ID):setScale(CONSTANTS.BTN1_WIDTH_SCALE[num - 1], CONSTANTS.BTN1_HEIGHT_SCALE[num - 1]);
    xse.base.setCCLableTTFString(node, CONSTANTS.BTN_LABEL_ID, name);
    local x, y = node:getChildByTag(CONSTANTS.BTN_LABEL_ID):getPosition();
    node:getChildByTag(CONSTANTS.BTN_LABEL_ID):setPosition(btnWidth * CONSTANTS.BTN1_WIDTH_SCALE[num - 1] / 2, y);
    return node;
end

--只要没有指定是第二级按钮，则返回大按钮
function tabView.createLv2Btn(name, width)
    local node = xse.base.loadCCBI(CONSTANTS.TAB_BTN2_CCBI);
    node:getChildByTag(CONSTANTS.BTN_ID):setScale(width / CONSTANTS.LV2_BTN_WIDTH, 1);
    xse.base.setCCLableTTFString(node, CONSTANTS.BTN_LABEL_ID, name);
    node:getChildByTag(CONSTANTS.BTN_LABEL_ID):setPosition(width / 2, CONSTANTS.LV2_BTN_HEIGHT / 2);
    return node;
end

xse.base.addEventSupportA(CONSTANTS.BTN_LAYER_NAME, CONSTANTS.BTN_ACTION_NAME, tabView.tabSelected);

return tabView;