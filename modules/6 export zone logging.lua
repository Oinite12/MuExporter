MuExporter.latest_empty_log_line = 1
MuExporter.latest_log_file = ""

-- Changes the text of the i-th log line.
---@param i integer
---@param text string
---@return nil
Mu_f.update_log_line = function(i, text)
	G.export_zone.log_lines[i] = text
	G.export_zone.log_line_objects[i]:update()

    if not MuExporter.log_file_created then
        love.filesystem.write(MuExporter.latest_log_file, "LOGGING BEGAN ON " .. os.date("%Y/%m/%d %X"))
        MuExporter.log_file_created = true
    end
    love.filesystem.append(MuExporter.latest_log_file, ("\n[%s] "):format(os.date("%X")) .. text)
end

-- Adds a new log message.
---@param text string
---@return nil
Mu_f.log = function(text)
    text = text or ""
    if MuExporter.latest_empty_log_line == MuExporter.log_size + 1 then
        for i = 1, MuExporter.log_size - 1 do
            Mu_f.update_log_line(i, G.export_zone.log_lines[i+1])
        end
        Mu_f.update_log_line(MuExporter.log_size, text)
    else
        Mu_f.update_log_line(MuExporter.latest_empty_log_line, text)
        MuExporter.latest_empty_log_line = MuExporter.latest_empty_log_line + 1
    end
end

-- ============
-- RUNTIME
-- ============

love.filesystem.createDirectory(MuExporter.filedirs.logs)
MuExporter.latest_log_file = MuExporter.filedirs.logs .. "muexp_log_" .. os.date("%Y/%m/%d-%X") .. ".log"
MuExporter.log_file_created = false