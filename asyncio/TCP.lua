local class = require "class"
local fiber = require "fiber"
local socket = require "socket"

local Socket = require "asyncio.Socket"

local TCP = Socket "asyncio.TCP"

function TCP:init(sock)
  self.sock = sock or socket.tcp()
  self.sock:settimeout(0)
  self.timeout = 0
end

function TCP:settimeout(t)
  self.timeout = t
end

function TCP:gettimeout(t)
  return self.timeout
end

function TCP:accept()
  local sock, err
  if self.timeout == 0 then
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

for _, f in ipairs {
  "connect",
  "receive",
  "send"
} do
  TCP[f] = Socket._wrap_blocking(f)
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
