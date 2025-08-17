local helptext = [[
The Help Thing
Built in commands:
exit clear var cd rm mkdir lua ver
Built in apps:
edit cat echo find help
Documents:
custom-apps custom-commands can-i-make-a-package-manager
tuyu love2d
For more info, use help [document]
]]
local helpdocs = {
    ["help"] = "This program. Shows help text, or help for a program.",
    ["cat"] = "Cat program. Use it to read out files.\
Usage: cat [file]",
    ["echo"] = "Echo program. Says what you say at it.",
    ["edit"] = "funny text editor haha\
Usage: edit [name]",
    ["find"] = "Cat but with grep lol\
Usage: find [file] [text to find]",
    ["ls"] = "List the contents of a directory.\
Usage: ls [*dir]",
    ["exit"] = "Makes you become bye",
    ["clear"] = "Clears the screen.",
    ["var"] = "Change env variables, use $[key] to refer to them.\
Usage: var [key] = [value]",
    ["cd"] = "Change Directory\
Usage: cd [dir]",
    ["rm"] = "remove the file at the file location specified by the file name in the argument\
Usage: rm [file/dir]",
    ["ver"] = "Shows current version of lterm.",
    ["mkdir"] = "MaKe DIRectory\
Usage: mkdir [dir]",
    ["lua"] = "lua",
    ["custom-apps"] = "place lua files in the /app/ directory with the command name as the filename\
(you can use the var args for the cli arguments or wd for the working directory)",
    ["custom-commands"] = "use apps please!",
    ["can-i-make-a-package-manager"] = "sure",
    ["tuyu"] = "yes",
    ["love2d"] = "cool",
    ["lterm"] = "this thing youre in now"
}
if args[2] ~= nil then
    printt(helpdocs[args[2]] or "not found")
else
    printt(helptext)
end