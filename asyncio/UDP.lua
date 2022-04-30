local class = require "class"
local socket = require "socket"

local Socket = require "asyncio.Socket"

local UDP = Socket "asyncio.UDP"

function UDP:init(sock)
  self.sock = sock or socket.udp()
  self.sock:settimeout(0)
  self.timeout = 0
end

function UDP:settimeout(t)
  self.timeout = t
end

function UDP:gettimeout(t)
  return self.timeout
end

function UDP:send(...)
  return self.sock:send(...)
end

function UDP:sendto(...)
  return self.sock:sendto(...)
end

for _, f in ipairs {
  "receive",
  "receivefrom"
} do
  UDP[f] = Socket._wrap_blocking(f)
end

for _, f in ipairs {
  "close",
  "getoption",
  "getpeername",
  "getsockname",
  "setpeername",
  "setsockname",
  "setoption",
  "setstats"
} do
  UDP[f] = Socket._wrap(f)
end

return UDP
