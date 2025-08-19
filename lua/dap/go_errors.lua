local M = {}

local function parse_go_error(line)
  -- Example format: "%f:%l:%c: %m"
  -- /path/to/file.go:10:5: error message
  local pattern = "^(.-):(%d+):(%d+):%s*(.*)$"
  local file, lnum, col, message = line:match(pattern)
  if file and lnum and col and message then
    return {
      filename = file,
      lnum = tonumber(lnum),
      col = tonumber(col),
      text = message,
      type = "E", -- Error
    }
  end
  return nil
end

function M.add_to_quickfix(session, output_lines)
  local qflist = {}
  for _, line in ipairs(output_lines) do
    local entry = parse_go_error(line)
    if entry then
      table.insert(qflist, entry)
    end
  end

  if #qflist > 0 then
    vim.fn.setqflist({}, "r", { title = "Go Compilation Errors", items = qflist })
    vim.api.nvim_command("copen")
  end
end

return M
