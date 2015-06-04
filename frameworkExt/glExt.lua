glExt={}
require("Opengl")
require("table")
inheritance(glExt,object);

function glExt.create(width,height)
    local cls = glExt:new()
    cls.size = {width = width,height = height}
    local size = cls.size
    cls.glNode  = gl.glNodeCreate()
    cls.glNode:setContentSize(cc.size(size.width, size.height))
    return cls
end

function glExt:getNode()
    return self.glNode
end
--
function glExt:devicesClear()
--    local layer = self.node:getChildByTag(2)
--    layer:removeAllChildren();
    self.drawQueue = {}
end

--function glExt:getNode()
--    return self.glNode
--end

function glExt:devicesBegin()
    local size = self.size;
    
    self.glNode:setContentSize(cc.size(size.width, size.height))
    self.glNode:setAnchorPoint(cc.p(0.5, 0.5))
end

function glExt:devicesEnd()
    local function DrawPrimitivesEffect(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        for key, var in pairs(self.drawQueue or {}) do
            var();
        end
        kmGLPopMatrix()
    end

    self.glNode:registerScriptDrawHandler(DrawPrimitivesEffect)
--    self.node:getChildByTag(2):addChild(self.glNode)
    local size = self.size
    self.glNode:setPosition( size.width / 2, size.height / 2)
end

function glExt:linkPoint(p1,p2,c4bR,c4bG,c4bB,c4bA,linwight)
    local function drawLine()
        gl.lineWidth( linwight or 2 )
        cc.DrawPrimitives.drawColor4B(c4bR or 255,c4bG or 255,c4bB or 255,c4bA or 255)
        cc.DrawPrimitives.drawLine(p1,p2)
    end
    self.drawQueue = self.drawQueue or {}
    table.insert(self.drawQueue,#self.drawQueue + 1,drawLine)
end
return glExt