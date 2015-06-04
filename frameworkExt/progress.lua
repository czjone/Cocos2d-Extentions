Progressbar = {}

---@return #cc.ProgressTimer
function Progressbar.create(spr)
    local n = cc.ProgressTimer:create(spr)
    n:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    n:setMidpoint(cc.p(0, 0)) --left->right
    n:setBarChangeRate(cc.p(1, 0))
    n:setPosition(cc.p(100, 100))
    -- n:runAction(cc.RepeatForever:create(to1))
    --set percent api
--    n.setPercentage = function(self,p)
--        if p< 1 then p =1 end
--        if p >100 then p =100 end
--        local to2 = cc.ProgressTo:create(n:getPercentage(), p)
--        n:runAction(to2)
--    end
    return n
end

return Progressbar
