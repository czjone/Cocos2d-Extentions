dragBar =  {}
dragBar = inheritanceA(dragBar,class,"dragBar")

dragBar.data = {
    bgspr = nil,
    frontspr = nil,
    onChanged = nil,
    leftspr = nil,
    leftspr = nil,
    rightspr = nil,
    clickstep = 1;
    value = 0,
    maxnum = maxnum,
    nil
}

function dragBar:onChanged(value)

end

---只支持水平模式
--bgspr,背景
--frontspr,拖动按钮，
--onChanged 当value 发生变化时要执行的函数
--maxnum 0～maxnum 取值范围
--leftspr 减少精灵
--rightspr增加精灵
--clickstep 减少和增加，点击一次的步长，默认步长为1
function dragBar:create(bgspr,frontspr,onChanged,maxnum,leftspr,rightspr,clickstep)
    self.data.bgspr = bgspr
    self.data.frontspr = frontspr
    self.data.onChanged = onChanged
    self.data.leftspr = leftspr
    self.data.leftspr = leftspr
    self.data.rightspr = rightspr
    self.data.maxnum = maxnum
    self.data.clickstep =1
    self:setValue(0)

    xse.base.Sprite.setDragEvent(frontspr,function(self,node,x,y)
        local value = self:getValue()
        value = value + self.data.clickstep
        value = math.max(value,0)
        value = math.min(value,maxnum)
        self:setValue(value)
    end)
    
    if leftspr then
        xse.base.Sprite.setOnClickEvent(leftspr,function()
            local value = self:getValue()
            value = value + self.data.clickstep
            value = math.max(value,0)
            self:setValue(value)
        end,key)
    end

    if righter then
        xse.base.Sprite.setOnClickEvent(righter,function()
            local value = self:getValue()
            value = value + self.data.clickstep
            value = math.min(value,self.data.maxnum)
            self:setValue(value)
        end,key)
    end
end

--0～maxnum
function dragBar:setValue(value)
    self.data.value = value
    self:onChanged(value)

    local bgspr,frontspr = self.data.bgspr,self.data.bgsp.frontspr
    local contentsize = bgspr:getContentSize()
    assert(value > self.data.maxnum ,"value 不能大于".. self.data.maxnum)
    frontspr:setPosition(value * contentsize.width/self.data.maxnum,frontspr:getPositionY())
end

--0~maxnum
function dragBar:getValue()
    return self.data.value
end

return dragBar