local tree = require("context-gen.tree")
local file_manager = require("context-gen.file_manager")
local uv = vim.loop

local M = {}

local opts = {
  output_file = vim.fn.getcwd(),
  add_timestamp = false,
  output_file_name = "context"
}

function M.setup(user_opts)
  for key, _ in pairs(user_opts) do
    if user_opts[key] ~= nil then
      opts[key] = user_opts[key]
    end
  end
end

function M.add(file_path)
  file_manager.add(file_path)
end

function M.show_popup()
  file_manager.show_popup()
end

local function collect_files_with_headers(file_paths)
  local output_lines = {}

  for _, file_path in ipairs(file_paths) do
    local fd = uv.fs_open(file_path, "r", 438)
    if fd then
      local stat = uv.fs_fstat(fd)
      local file_data = ""
      if stat then
        file_data = uv.fs_read(fd, stat.size, 0)
      end
      uv.fs_close(fd)

      table.insert(output_lines, "\n ----- " .. file_path .. "\n")
      table.insert(output_lines, file_data)
    else
      table.insert(output_lines, "----- " .. file_path)
      table.insert(output_lines, "[Error: could not read file]")
    end
  end

  return output_lines, "\n"
end

local function generate_output_filename()
  local name = opts.output_file_name

  if opts.add_timestamp then
    local timestamp = os.date("%Y-%m-%d-%H-%M-%S")
    name = timestamp .. "-" .. opts.output_file_name
  end

  return vim.fs.joinpath(vim.fn.getcwd(), name)
end


function _generate(file_paths)
  local tree_str = tree.tree()

  local fd = uv.fs_open(generate_output_filename(), "w", 438)
  local output_lines = collect_files_with_headers(file_paths)

  table.insert(output_lines, 1, tree_str)

  if fd then
    uv.fs_write(fd, table.concat(output_lines, "\n"), 0)
    uv.fs_close(fd)
  else
    vim.notify("Could not create output file: " .. opts.output_file, vim.log.levels.ERROR)
  end

  file_manager.clear_files()
end

function M.generate()
  local file_paths = file_manager.get_selected_files()
  _generate(file_paths)
end

local function get_all_files_in_cwd()
  local all_files = {}
  local cwd = vim.fn.getcwd()

  local function traverse(path)
    local dir_iterator = vim.fs.dir(path, {
      on_error = function(name, err)
        vim.notify("Could not scan " .. name .. ": " .. err.message, vim.log.levels.WARN)
      end,
    })

    if not dir_iterator then
      return
    end

    for name, type in dir_iterator do
      if not name:match("^%.") then
        local full_path = vim.fs.joinpath(path, name)
        if type == "directory" then
          traverse(full_path)
        elseif type == "file" then
          table.insert(all_files, full_path)
        end
      end
    end
  end

  traverse(cwd)
  return all_files
end

function M.generate_from_repo()
  local file_paths = get_all_files_in_cwd()
  if file_paths then
    _generate(file_paths)
  end
end

return M
