local uv = vim.loop
local M = {}

local function list_directory_entries(directory_path)
  local entries = {}
  local handle = uv.fs_scandir(directory_path)
  if not handle then
    return entries
  end

  while true do
    local entry_name, _ = uv.fs_scandir_next(handle)
    if not entry_name then break end
    table.insert(entries, entry_name)
  end

  table.sort(entries)
  return entries
end

local function build_tree_lines(base_path, indent, lines)
  local entries = list_directory_entries(base_path)

  for index, entry_name in ipairs(entries) do
    local entry_path = base_path .. "/" .. entry_name
    local is_last_entry = (index == #entries)
    local stat = uv.fs_stat(entry_path)
    local type_suffix = stat and stat.type == "file" and " [file]" or " [dir]"

    if is_last_entry then
      table.insert(lines, indent .. "└── " .. entry_name .. type_suffix)
      build_tree_lines(entry_path, indent .. "    ", lines)
    else
      table.insert(lines, indent .. "├── " .. entry_name .. type_suffix)
      build_tree_lines(entry_path, indent .. "│   ", lines)
    end
  end
end

function M.tree()
  local cwd = vim.fn.getcwd()
  local lines = { cwd }
  build_tree_lines(cwd, "", lines)
  return table.concat(lines, "\n")
end

return M

