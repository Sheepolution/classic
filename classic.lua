--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--


local Object = {}
Object.__index = Object


function Object:new()
end

function Object:extend(name)
  if not name then
    local info = debug.getinfo(2, "Sl")
    if info and info.source and info.currentline then
      local lines = love.filesystem.lines(info.source:sub(2))
      local i = 0
      for line in lines do
        i = i + 1
        if i == info.currentline then
          local _, _, var = line:find("([%w_]+) =")
          if var then
            name = var
          end
          break
        end
      end
    end
  end

  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  cls.__name = name
  setmetatable(cls, self)
  return cls
end

local function implement(self, cls)
  for k, v in pairs(cls) do
    if self[k] == nil then
      if type(v) ~= 'table' then
        self[k] = v
      else
        self[k] = {}
        implement(self[k], v)
      end
    end
  end
end

function Object:implement(...)
  for _, cls in pairs({ ... }) do
    implement(self, cls)
  end
  return self
end

function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

function Object:__tostring()
  return self.__name or "Object"
end

function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

return Object
