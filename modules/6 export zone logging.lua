MuExporter.latest_empty_log_line = 1

-- Changes the text of the i-th log line.
---@param i integer
---@param text string
---@return nil
Mu_f.update_log_line = function(i, text)
	G.export_zone.log_lines[i] = text
	G.export_zone.log_line_objects[i]:update()
end

-- Adds a new log message.
---@param text string
---@return nil
Mu_f.log = function(text)
	text = text or ""
	Mu_f.simple_ev(function()
		if MuExporter.latest_empty_log_line == MuExporter.log_size + 1 then
			for i = 1, MuExporter.log_size - 1 do
				Mu_f.update_log_line(i, G.export_zone.log_lines[i+1])
			end
			Mu_f.update_log_line(MuExporter.log_size, text)
		else
			Mu_f.update_log_line(MuExporter.latest_empty_log_line, text)
			MuExporter.latest_empty_log_line = MuExporter.latest_empty_log_line + 1
		end
	end)
end