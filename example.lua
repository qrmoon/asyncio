local asyncio = require "asyncio"
local fiber = require "fiber"

local client = fiber:new(function()
  local sock = asyncio.TCP:new()
  print "Connecting..."
  local ok, err = fiber.wait_for(5, function()
    return sock:connect("127.0.0.1", 4040)
  end)
  if not ok then
    print(err)
    return
  end
  fiber.defer(function()
    sock:close()
  end)

  local msg = ""
  local byte, err
  repeat
    byte, err = sock:receive(1)
    if byte then msg = msg .. byte end
  until not byte
  print("Message from server: " .. msg)
end)

local server = fiber:new(function()
  local sock = asyncio.TCP:new()
  fiber.defer(function()
    sock:close()
  end)
  local ok, err = sock:bind("127.0.0.1", 4040)
  if not ok then
    print(err)
    return
  end
  ok, err = sock:listen(16)
  if not ok then
    print(err)
    return
  end

  while true do
    print "Waiting for connection..."
    local client = sock:accept()
    fiber.spawn(function()
      print "Client connected"
      client:send "Hello, Client!"
      client:close()
    end)
  end
end)

fiber.loop { client, server }
