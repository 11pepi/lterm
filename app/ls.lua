if args[2] == nil then args[2] = wd end
local files = love.filesystem.getDirectoryItems(args[2])
if #files == 0 then
    printt("no files found")
else
    for _, file in pairs(files) do
        local finfo = love.filesystem.getInfo(file)
        if finfo == nil then
            printt(file .. " ?")
            goto continue
        end
        if finfo["type"] == "directory" then
            printt(file .. " /")
        else
            printt(file)
        end
        ::continue::
    end
end