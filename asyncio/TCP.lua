local class = require "class"
local fiber = require "fiber"
local socket = require "socket"

local Socket = require "asyncio.Socket"

local TCP = Socket "asyncio.TCP"

function TCP:init(sock)
  self.sock = sock or socket.tcp()
  self.sock:settimeout(0)
  self.timeout = nil
end

function TCP:settimeout(t)
  self.timeout = t
end

function TCP:gettimeout(t)
  return self.timeout
end

function TCP:accept()
  local sock, err
  if not self.timeout then
    fiber.wait(function()
      sock, err = self.sock:accept()
      return err ~= "timeout"
    end)
  else
    fiber.wait_for(self.timeout, function()
      sock, err = self.sock:accept()
      return err ~= "timeout"
    end)
  end
  if sock then
    sock = TCP:new(sock)
  end
  return sock, err
end

-- function TCP:connect(...)
--   local args = { ... }
--   if self.timeout == 0 then
--     return fiber.wait(function()
--       local ok, err = self.sock:connect(table.unpack(args))
--       print(ok, err, self.sock)
--       return ok, err
--     end)
--   else
--   end
-- end

TCP.connect = Socket._wrap_blocking "connect"
TCP.receive = Socket._wrap_blocking "receive"

function TCP:send(s, i, j)
  local i = i or 1
  if not self.timeout then
    return fiber.wait(function()
      local ok, err, index = self.sock:send(s, i, j)
      if err == "timeout" then
        i = index + 1
      end
      return err ~= "timeout"
    end)
  else
    return fiber.wait_for(self.timeout, function()
      local ok, err, index = self.sock:send(s, i, j)
      if err == "timeout" then
        i = index + 1
      end
      return err ~= "timeout"
    end)
  end
end

for _, f in ipairs {
  "bind",
  "close",
  "dirty",
  "getfd",
  "getoption",
  "getpeername",
  "getsockname",
  "getstats",
  "listen",
  "setfd",
  "setoption",
  "setstats",
  "shutdown"
} do
  TCP[f] = Socket._wrap(f)
end

return TCP
