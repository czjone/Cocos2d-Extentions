-----------------------------------------------
-- try catch finally
function trycall(fun,catchfun,finallyfun,...)
    local res,err =pcall(fun(...))
    if err then catchfun(err) end
    finallyfun()
end