---检查玩家的输入
inputCheckServices = {}

----检查输入的数据是否为指定的数据类型
inputCheckServices.checkValue = function(value,types,callback,errcallback,...)
    local res,newvalue = xpcall(types(value,...),function(msg) log(msg) end)
    if res == true and not err then callback(value) end
    return res,newvalue
end

--inputCheckServices.setEditorInputTypesA = function(editor,types,tcallback,fcallback,...)
--    inputCheckServices.setEditorInputTypes (editor,types,tcallback,function(msg)
--
--    end,...)
--end

---检查editor是否为有效果的输入
inputCheckServices.setEditorInputTypes = function(editor,types,tcallback,fcallback,...)

    local function errCallBack(msg,tastkId)
        xse.base.timer.tick.remove(tastkId)
        fcallback(msg)
    end

    local args = ...
    local id = 0
    id = xse.base.timer.tick.add(function()
        if editor ~= nil and editor.getText ~= nil and editor.setText
            and types and type(types) == "function" then
            local getValue = editor:getText()
            local res,newvalue = inputCheckServices.checkValue(getValue,types,tcallback,function(msg) errCallBack(msg) end)
            if res == true and newvalue~=nil then editor:setValue(newvalue) end
        end
        xpcall(function() if editor:getParent() == nil then xse.base.timer.tick.remove(id) end end,
            function(msg) errCallBack(msg) end)
    end)
end

inputCheckServices.types = {}

local match,max,min = string.match,string.max,string.min

inputCheckServices.types.EMAIL = function(str,defaultvalue)
    local res,newvalue = match(str,"%w+([-+.]%w+)*@%w+([-.]%w+)*%.%w+([-.]%w+)*"),nil
    return res ~= nil ,newvalue
end

inputCheckServices.types.NUMBER = function(str,defaultvalue)
    local res,newvalue = match(str,"^-?[1-9]%d*$"),nil
    if res then newvalue =  tonumber(str) end
    return res,newvalue
end

inputCheckServices.types.INT = function(str,defaultvalue)
    local res,newvalue = match(str,"%."),str
    return res,newvalue
end

inputCheckServices.types.UINT = function(str,defaultvalue)
    local res,newvalue = inputCheckServices.types.INT(str,defaultvalue)
    if newvalue < 0 then newvalue=0 end
    return res,newvalue
end

inputCheckServices.types.NUMBER_RECT = function(str,min_,max_,defaultvalue)
    local res,newvalue = inputCheckServices.types.INT(str,defaultvalue)
    newvalue = max(newvalue,max_)
    newvalue = min(newvalue,min_)
    return res,newvalue
end

inputCheckServices.types.USER_NAME = function(str,defaultvalue)
    local res,newvalue = match(str,"(%w|_)*"),nil
    return res,newvalue
end

--inputCheckServices.types.PASSWORD = function(str,defaultvalue)
--    local res,newvalue = match(str,"(%w|_)*"),nil
--    return res,newvalue
--end

return inputCheckServices