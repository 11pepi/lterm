local editor = {}

editor.active = false
editor.filename = ""
editor.lines = {}
editor.cursor = {line = 1, col = 1}
editor.message = ""
editor.scroll = 0
editor.visible_lines = 28 -- Adjust for your window/font size

function editor.open(filename)
    editor.active = true
    editor.filename = filename
    editor.lines = {}
    editor.cursor = {line = 1, col = 1}
    editor.message = ""
    local finfo = love.filesystem.getInfo(filename)
    if finfo and finfo.type == "file" then
        local content = love.filesystem.read(filename)
        for line in string.gmatch(content, "([^\n]*)\n?") do
            table.insert(editor.lines, line)
        end
    else
        table.insert(editor.lines, "")
    end
end

function editor.save()
    local content = table.concat(editor.lines, "\n")
    love.filesystem.write(editor.filename, content)
    editor.message = "Saved!"
end

function editor.exit()
    editor.active = false
end

function editor.keypressed(key)
    if key == "q" and love.keyboard.isDown("lctrl", "rctrl") then
        editor.exit()
    elseif key == "return" then
        local line = editor.lines[editor.cursor.line]
        local before = line:sub(1, editor.cursor.col - 1)
        local after = line:sub(editor.cursor.col)
        editor.lines[editor.cursor.line] = before
        table.insert(editor.lines, editor.cursor.line + 1, after)
        editor.cursor.line = editor.cursor.line + 1
        editor.cursor.col = 1
    elseif key == "backspace" then
        local line = editor.lines[editor.cursor.line]
        if editor.cursor.col > 1 then
            editor.lines[editor.cursor.line] =
                line:sub(1, editor.cursor.col - 2) .. line:sub(editor.cursor.col)
            editor.cursor.col = editor.cursor.col - 1
        elseif editor.cursor.line > 1 then
            local prev = editor.lines[editor.cursor.line - 1]
            editor.cursor.col = #prev + 1
            editor.lines[editor.cursor.line - 1] = prev .. line
            table.remove(editor.lines, editor.cursor.line)
            editor.cursor.line = editor.cursor.line - 1
        end
    elseif key == "up" then
        if editor.cursor.line > 1 then
            editor.cursor.line = editor.cursor.line - 1
            editor.cursor.col = math.min(editor.cursor.col, #editor.lines[editor.cursor.line] + 1)
            if editor.cursor.line - editor.scroll < 1 then
                editor.scroll = editor.scroll - 1
            end
        end
    elseif key == "down" then
        if editor.cursor.line < #editor.lines then
            editor.cursor.line = editor.cursor.line + 1
            editor.cursor.col = math.min(editor.cursor.col, #editor.lines[editor.cursor.line] + 1)
            if editor.cursor.line - editor.scroll > editor.visible_lines then
                editor.scroll = editor.scroll + 1
            end
        end
    elseif key == "left" then
        if editor.cursor.col > 1 then
            editor.cursor.col = editor.cursor.col - 1
        elseif editor.cursor.line > 1 then
            editor.cursor.line = editor.cursor.line - 1
            editor.cursor.col = #editor.lines[editor.cursor.line] + 1
        end
    elseif key == "right" then
        if editor.cursor.col <= #editor.lines[editor.cursor.line] then
            editor.cursor.col = editor.cursor.col + 1
        elseif editor.cursor.line < #editor.lines then
            editor.cursor.line = editor.cursor.line + 1
            editor.cursor.col = 1
        end
    elseif key == "s" and love.keyboard.isDown("lctrl", "rctrl") then
        editor.save()
    end
end

function editor.textinput(text)
    local line = editor.lines[editor.cursor.line]
    editor.lines[editor.cursor.line] =
        line:sub(1, editor.cursor.col - 1) .. text .. line:sub(editor.cursor.col)
    editor.cursor.col = editor.cursor.col + #text
end

function editor.draw()
    love.graphics.clear(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    local first = math.max(1, editor.scroll + 1)
    local last = math.min(#editor.lines, editor.scroll + editor.visible_lines)
    for i = first, last do
        love.graphics.print(editor.lines[i], 10, (i - first) * 16 + 10)
    end
    if editor.cursor.line >= first and editor.cursor.line <= last then
        local cx = 10 + love.graphics.getFont():getWidth(editor.lines[editor.cursor.line]:sub(1, editor.cursor.col - 1))
        local cy = (editor.cursor.line - first) * 16 + 10
        love.graphics.rectangle("fill", cx, cy, 8, 16)
    end
    love.graphics.setColor(0.7, 1, 0.7)
    love.graphics.print("Editing: " .. editor.filename .. " | Ctrl+Q to exit | Ctrl+S to save", 10, 480 - 24)
    if editor.message ~= "" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(editor.message, 320, 456 - 24)
    end
    love.graphics.setColor(1, 1, 1)
end

return editor