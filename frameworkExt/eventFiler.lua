eventFiler = {}

---点击响应的次数
eventFiler.clickEvent = {}

function eventFiler:enable(enbale)
	self.enableState = enbale
end

function eventFiler:addUnFiler(key)
    self.unfilerKeys =  self.unfilerKeys or {}
    self.unfilerKeys[key] = key
end

function eventFiler:removeUnfiler(key)
    self.unfilerKeys =  self.unfilerKeys or {}
    self.unfilerKeys[key] = nil
end

---
function eventFiler:canExecute(key)
    self.unfilerKeys = self.unfilerKeys or {}
    return self.enableState == nil or self.enableState == false or  (self.enableState == true and self.unfilerKeys[key] ~= nil)
end

function eventFiler:addExecuteEventKey(key)
    eventFiler.clickEvent = eventFiler.clickEvent or {}
    if key == nil then return end
    eventFiler.clickEvent[key] = key;
end

return eventFiler