if args[2] == nil or args[3] == nil then return 0 end
if string.sub(args[2], 1, 1) ~= "/" then args[2] = wd .. args[2] end
local finfo = love.filesystem.getInfo(args[2])
local lines = {}
if finfo ~= nil and finfo["type"] == "file" then
    local fcont = love.filesystem.read(args[2])
    for _, line in pairs(split(fcont, "\n")) do
        for i = 3, #args do
            if string.match(line, args[i]) then
                table.insert(lines, line)
                goto continue
            end
        end
        ::continue::
    end
    for _, line in pairs(lines) do
        printt(line)
    end
else
    printt("error")
end