local o = vim.o
local api = vim.api

local M = {}

local selected_files = {}

M.buffer = nil
M.window = nil

function M.get_selected_files()
  return selected_files
end

local function selected_files_contain(file_path)
  for _, v in ipairs(selected_files) do
    if v == file_path then
      return true
    end
  end
  return false
end


function M.add(file_path)
  if selected_files_contain(file_path) then
    return
  end

  table.insert(selected_files, file_path)
  M.render()
end

function M.clear_files()
  selected_files = {}
  M.render()
end

function M.render()
  if not (M.window and M.buffer and api.nvim_buf_is_valid(M.buffer)) then
    return
  end

  api.nvim_buf_set_lines(M.buffer, 0, -1, false, selected_files)
end

function M.show_popup()
  if M.window and M.buffer and api.nvim_buf_is_valid(M.buffer) then
    api.nvim_set_current_win(M.window)
    return
  end

  M.buffer = api.nvim_create_buf(false, true) -- scratch buffer
  local width = math.floor(o.columns * 0.8)
  local height = math.floor(o.lines * 0.8)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = (o.lines - height) / 2,
    col = (o.columns - width) / 2,
    style = "minimal",
    border = "single",
  }

  M.window = api.nvim_open_win(M.buffer, true, opts)
  M.render()

  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = M.buffer,
    callback = function()
      local lines = api.nvim_buf_get_lines(M.buffer, 0, -1, false)
      selected_files = {}
      for _, line in ipairs(lines) do
        local contain = selected_files_contain(line)

        if #line > 0 and not contain then
          table.insert(selected_files, line)
        end
      end
    end,
  })

  api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local closed_win_id = tonumber(args.match)
      if closed_win_id == M.window then
        M.buffer = nil
        M.window = nil
      end
    end,
  })

  vim.keymap.set("n", "q", function()
    if M.window and api.nvim_win_is_valid(M.window) then
      api.nvim_win_close(M.window, true)
    end
  end, { buffer = M.buffer, nowait = true, silent = true })
end

return M
