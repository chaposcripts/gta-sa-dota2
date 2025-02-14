local ffi = require('ffi');
local Utils = {};

function Utils.msg(...)
   return IS_SAMP and sampAddChatMessage(('Dota // %s'):format(table.concat({ ... }, ' ')), -1) or print('Dota //', ...);
end

function Utils.debugMsg(...)
   Utils.msg('DEBUG //', ...);
end

function Utils.isVector3D(v)
   return type(v) == 'table' and v.x ~= nil;
end

local CPed_SetModelIndex = ffi.cast('void(__thiscall *)(void*, unsigned int)', 0x5E4880);

function Utils.setCharModel(ped, model)
   if not (doesCharExist(ped)) then return Utils.debugMsg('ped not found') end
   if (not hasModelLoaded(model)) then
      requestModel(model);
      loadAllModelsNow();
   end
   CPed_SetModelIndex(ffi.cast('void*', getCharPointer(ped)), ffi.cast('unsigned int', model));
end

local effil = require 'effil' -- В начало скрипта
function Utils.asyncHttpRequest(method, url, args, resolve, reject)
   pcall(asyncHttpRequest, method, url, args, resolve, reject);
end

function asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function(method, url, args)
      local requests = require 'requests'
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   -- Если запрос без функций обработки ответа и ошибок.
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   -- Проверка выполнения потока
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end

function Utils.bringFloatTo(from, to, start_time, duration)
   local timer = os.clock() - start_time
   if timer >= 0.00 and timer <= duration then
      local count = timer / (duration / 100)
      return from + (count * (to - from) / 100), true
   end
   return (timer > duration) and to or from, false
end

function Utils.join_argb(a, r, g, b)
   local argb = b                          -- b
   argb = bit.bor(argb, bit.lshift(g, 8))  -- g
   argb = bit.bor(argb, bit.lshift(r, 16)) -- r
   argb = bit.bor(argb, bit.lshift(a, 24)) -- a
   return argb
end

function Utils.explode_argb(argb)
   local a = bit.band(bit.rshift(argb, 24), 0xFF)
   local r = bit.band(bit.rshift(argb, 16), 0xFF)
   local g = bit.band(bit.rshift(argb, 8), 0xFF)
   local b = bit.band(argb, 0xFF)
   return a, r, g, b
end

function Utils.argb_to_rgba(argb)
   local a, r, g, b = explode_argb(argb)
   return join_argb(r, g, b, a)
end

return Utils;
