local class = require "class"
local socket = require "socket"
local fiber = require "fiber"

local Socket = class:abstract "asyncio.Socket"

function Socket:__index(k)
  local v = rawget(self, k)
  if v == nil then v = rawget(rawget(self, "class"), k) end
  if v == nil and rawget(self, "sock") then
    v = rawget(self, "sock")[k]
  end
  return v
end

function Socket._wrap_blocking(f)
  return function(self, ...)
    local args = { ... }
    local func = function()
      local res = { self.sock[f](self.sock, table.unpack(args)) }
      local ok, err = res[1], res[2]
      if not ok and err == "timeout" then
        return false
      end
      return true, table.unpack(res)
    end
    local res
    if self.timeout == 0 then
      res = { fiber.wait(func) }
    else
      res = { fiber.wait_for(self.timeout, func) }
    end
    return select(2, table.unpack(res))
  end
end

function Socket._wrap(f)
  return function(self, ...)
    return self.sock[f](self.sock, ...)
  end
end

return Socket