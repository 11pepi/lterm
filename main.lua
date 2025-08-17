#!/bin/env love
local love = require "love"
local jbmono, term, command, interm, vars, wd, tinc, history
local editor = require "app/editor"

function love.load()
    love.window.setTitle("lterm")
    love.window.setMode(640, 480)
    love.keyboard.setKeyRepeat(true)
    jbmono = love.graphics.newFont("jbmono.ttf", 14)
    love.graphics.setFont(jbmono)
    term = {"welcome to lterm", "help for help"}
    command = ""
    interm = true
    vars = {["version"] = "2.02"}
    wd = "/"
    tinc = "█"
    history = {""}
    history.index = 0
end

function split(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function printt(text)
    for _, line in pairs(split(text, "\n")) do
        table.insert(term, line)
    end
end

function clst()
    term = {}
end

function processcommand(args)
    for i, arg in pairs(args) do
        if string.sub(arg, 1, 1) == "$" and string.len(arg) > 1 then
            args[i] = vars[string.sub(arg, 2, -1)]
        end
    end
    if args[1] == "exit" then
        love.event.quit()
    elseif args[1] == "clear" then
        term = {}
    elseif args[1] == "var" then
        if args[2] == nil then return 0 end
        if args[3] ~= "=" then
            if vars[args[2]] == nil then printt("invalid")return 0 end
            printt(vars[args[2]])
        else
            vars[args[2]] = args[4]
        end
    elseif args[1] == "cd" then
        if args[2] == ".." then
            local x = {}
            for i, j in pairs(split(wd, "/")) do
                table.insert(x, j)
            end
            local sliced = {}
            for i = 1, #x - 1 do
                table.insert(sliced, x[i])
            end
            wd = "/" .. table.concat(sliced, "/")
        elseif args[2] == "/" then
            wd = "/"
        else
            local finfo = love.filesystem.getInfo(args[2])
            if finfo ~= nil and finfo["type"] == "directory" then
                wd = wd .. args[2] .. "/"
            end
        end
    elseif args[1] == "rm" then
        local finfo = love.filesystem.getInfo(args[2])
        if finfo ~= nil then
            love.filesystem.remove(args[2])
        else
            printt("error")
        end
    elseif args[1] == "mkdir" then
        local finfo = love.filesystem.getInfo(args[2])
        if finfo == nil then
            love.filesystem.createDirectory(args[2])
        end
    elseif args[1] == "edit" then
        if args[2] then
            interm = false
            editor.open(wd .. args[2])
        else
            printt("usage: edit <filename>")
        end
    elseif args[1] == "lua" then
        if args[2] == nil then return 0 end
        local file = love.filesystem.load(args[2])
        file()
    elseif args[1] == "ver" then
        printt("Version " .. vars["version"] .. " of lterm")
    else
        _G.args = args
        _G.wd = wd
        _G.vars = vars
        app = love.filesystem.load("/app/" .. args[1] .. ".lua")
        if app == nil then
            if args[1] ~= nil then
                printt("invalid command: " .. args[1])
            end
        else
            app(args)
        end
    end
end

function love.keypressed(key, _, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
    if interm then
        if key == "return" then
            table.insert(term, wd .. "$" .. command)
            table.insert(history, 1, command)
            processcommand(split(command, " "))
            history.index = 0
            command = ""
        elseif key == "backspace" then
            command = string.sub(command, 1, -2)
        elseif key == "up" then
            history.index = history.index + 1
            history.index = history.index % #history
            command = history[history.index]
            if command == nil then command = "" end
        elseif key == "down" then
            history.index = history.index - 1
            history.index = history.index % #history
            command = history[history.index]
            if command == nil then command = "" end
        end
    else
        editor.keypressed(key)
    end
end

function love.textinput(text)
    if not interm then
        editor.textinput(text)
    else
        if #text == 1 then
            command = command .. text
        end
    end
end

function love.update(dt)
    if #term > 33 then
        while #term > 33 do
            table.remove(term, 1)
        end
    end
    if not interm and not editor.active then
        interm = true
        local w, h = love.window.getMode()
        if w ~= 640 and h ~= 480 then
            love.window.setMode(640, 480)
        end
        love.keyboard.setKeyRepeat(true)
        jbmono = love.graphics.newFont("jbmono.ttf", 14)
        love.graphics.setFont(jbmono)
    end
    if (love.timer.getTime() * 1.5) % 2 > 1 then
        tinc = "█"
    else
        tinc = ""
    end
end

function love.draw()
    if interm then
        for i, line in pairs(term) do
            love.graphics.print(line, 0, (i - 1) * 14)
        end
        love.graphics.print(wd .. "$" .. command .. tinc, 0, #term * 14)
    else
        editor.draw()
    end
end