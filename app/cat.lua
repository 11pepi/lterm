if args[2] == nil then return 0 end
if string.sub(args[2], 1, 1) ~= "/" then args[2] = wd .. args[2] end
local finfo = love.filesystem.getInfo(args[2])
if finfo ~= nil and finfo["type"] == "file" then
    local fcont = love.filesystem.read(args[2])
    for _, line in pairs(split(fcont, "\n")) do
        printt(line)
    end
else
    printt("error")
end