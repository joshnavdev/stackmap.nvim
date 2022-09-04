local M = {}

local find_mapping = function(maps, lhs)
  for _, value in ipairs(maps) do
    if value.lhs == lhs then
      return value
    end
  end
end

M._stack = {}

M.push = function(name, mode, mappings)
  local maps = vim.api.nvim_get_keymap(mode)
  local existing_maps = {}

  for lhs, _ in pairs(mappings) do
    -- print("Searching for:", lhs)
    local existing = find_mapping(maps, lhs)

    if existing then
      existing_maps[lhs] = existing
    end
  end


  for lhs, rhs in pairs(mappings) do
    vim.keymap.set(mode, lhs, rhs)
  end

  M._stack[name] = M._stack[name] or {}

  M._stack[name][mode] = {
    existing = existing_maps,
    mappings = mappings,
  }
end

M.pop = function(name, mode)
  local state = M._stack[name][mode]
  M._stack[name][mode] = nil

  for lhs, _ in pairs(state.mappings) do
    if state.existing[lhs] then
      -- handle mappings that existed
      vim.keymap.set(mode, lhs, state.existing[lhs].rhs)
    else
      -- handle mapping that not existed
      vim.keymap.del(mode, lhs)
    end
  end
end

M._clear = function()
  M._stack = {}
end

-- M.push("debug_mode", "n", {
--   [" zz"] = ":echo 'Hello'",
--   [" zx"] = ":echo 'Goodbye'",
-- })
--
-- M.pop("debug_mode")

return M
