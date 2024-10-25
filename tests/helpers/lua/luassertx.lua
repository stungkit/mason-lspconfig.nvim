local a = require "mason-core.async"
local assert = require "luassert"
local match = require "luassert.match"
local uv = vim.uv or vim.loop

local function wait_for(_, arguments)
    ---@type (fun()): Function to execute until it does not error.
    local assertions_fn = arguments[1]
    ---@type number: Timeout in milliseconds. Defaults to 5000.
    local timeout = arguments[2]
    timeout = timeout or 15000

    local start = uv.hrtime()
    local is_ok, err
    repeat
        is_ok, err = pcall(assertions_fn)
        if not is_ok then
            a.sleep(math.min(timeout, 100))
        end
    until is_ok or ((uv.hrtime() - start) / 1e6) > timeout

    if not is_ok then
        error(err)
    end

    return is_ok
end

local function tbl_containing(_, arguments, _)
    return function(value)
        local expected = arguments[1]
        for key, val in pairs(expected) do
            if match.is_matcher(val) then
                if not val(value[key]) then
                    return false
                end
            elseif value[key] ~= val then
                return false
            end
        end
        return true
    end
end

local function list_containing(_, arguments, _)
    return function(value)
        local expected = arguments[1]
        for _, val in pairs(value) do
            if match.is_matcher(expected) then
                if expected(val) then
                    return true
                end
            elseif expected == val then
                return true
            end
        end
        return false
    end
end

local function instanceof(_, arguments, _)
    return function(value)
        local expected_mt = arguments[1]
        return getmetatable(value) == expected_mt
    end
end

assert:register("matcher", "tbl_containing", tbl_containing)
assert:register("matcher", "list_containing", list_containing)
assert:register("matcher", "instanceof", instanceof)
assert:register("assertion", "wait_for", wait_for)
