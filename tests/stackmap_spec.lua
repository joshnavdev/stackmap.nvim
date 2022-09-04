local find_map = function(lhs)
  local maps = vim.api.nvim_get_keymap("n")
  for _, map in ipairs(maps) do
    if map.lhs == lhs then
      return map
    end
  end
end

describe("stackmap", function()
  local lhs = "asdf"

  before_each(function()
    require("stackmap")._clear()
    pcall(vim.keymap.del, "n", lhs)
  end)

  it("can be require", function()
    require("stackmap")
  end)

  it("can push a single mapping", function()
    local rhs = ":echo 'Testing'"

    require("stackmap").push("test1", "n", {
      [lhs] = rhs
    })

    local found = find_map(lhs)
    assert.are.same(rhs, found.rhs)
  end)

  it("can push multiple mappings", function()
    local rhs = ":echo 'Testing'"

    require("stackmap").push("test1", "n", {
      [lhs .. "_1"] = rhs .. "1",
      [lhs .. "_2"] = rhs .. "2"
    })

    local found1 = find_map(lhs .. "_1")
    local found2 = find_map(lhs .. "_2")

    assert.are.same(rhs .. "1", found1.rhs)
    assert.are.same(rhs .. "2", found2.rhs)
  end)

  it("can delete mappings after pop", function()
    local rhs = ":echo 'Testing'"

    require("stackmap").push("test1", "n", {
      [lhs] = rhs
    })

    local found = find_map(lhs)
    assert.are.same(rhs, found.rhs)

    require("stackmap").pop("test1", "n")
    local after_pop = find_map(lhs)
    assert.are.same(nil, after_pop)
  end)

  it("can restore existing mappings after pop", function()
    local rhs = ":echo 'Testing'"
    local existing_rhs = ":echo 'existing map'"

    vim.keymap.set("n", lhs, existing_rhs)

    require("stackmap").push("test1", "n", {
      [lhs] = rhs
    })

    local found = find_map(lhs)
    assert.are.same(rhs, found.rhs)

    require("stackmap").pop("test1", "n")
    local after_pop = find_map(lhs)
    assert.are.same(existing_rhs, after_pop.rhs)
  end)
end)
