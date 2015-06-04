String = {}


--str = "{r0:message,message}"
function String.action_format(str)
    local actions = {
        r0 = {str= "aaaa",event = function() log("invork r0") end},
        r1 = {str= "bbbb",event = function() log("invork r0") end},
        r2 = {str= "cccc",event = function() log("invork r0") end},
        r3 = {str= "dddd",event = function() log("invork r0") end},
        r4 = {str= "eeee",event = function() log("invork r0") end},
        r5 = {str= "ffff",event = function() log("invork r0") end},
    }

    local color2 = xse.color.ORANGE ;
    local color1 = xse.color.YELLOW;

    local token ={
        r_key = 1,
        r_message =2,
        r_end =3,
        r_normal =4,
    }

    local m_token = token.r_normal;
    local fontTabs = {}
    local fontSize =20
    local fontTab = {color=color1,fontSize = fontSize ,str =""} table.insert(fontTabs,#fontTabs+1,fontTab)
    local r_key,defaultKey = "",""
    --    layer:addChar(char,var.color,var.event,nil,var.fontSize)
    xse.base.string.foreach(str,function(char,charIndex,byteIndex)
        switch(char,{
            ["{"] = function()m_token = token.r_key char = nil r_key="" end ,
            ["}"] = function()m_token = token.r_normal char = nil  r_key="" fontTab = {color=color1,fontSize = fontSize ,str =""} table.insert(fontTabs,#fontTabs+1,fontTab) end ,
            [":"] = function()m_token = token.r_message char = nil fontTab = {color=color2,fontSize = fontSize ,str =""} table.insert(fontTabs,#fontTabs+1,fontTab) end ,
        })
        switch(m_token,{
            [token.r_key] = function() if char then r_key = r_key .. char end end,
            [token.r_normal] = function() if char then fontTab.str = fontTab.str .. char end end,
            [token.r_message] = function() if char then fontTab.str = fontTab.str .. char end  end,
        })
        ---绑定事件
        if m_token == token.r_message and r_key ~= nil then
            for key, var in pairs(actions) do
                if key == r_key then log(key)
                    fontTab.event = var.event ; fontTab.str =  var.str or fontTab.str; defaultKey = var.str r_key = nil; break;
                end
            end
        end

        if #fontTab.str > #defaultKey and string.find(fontTab.str,defaultKey) == 1 then
            fontTab.str = string.sub(fontTab.str,#defaultKey, #fontTab.str - #defaultKey );
            defaultKey= ""
        end
    end)
    return fontTabs
end

return String