wrap.argtypes = {}

wrap.argtypes.Tensor = {

   helpname = function(arg)
               return "Tensor"
            end,

   declare = function(arg)
                local txt = {}
                table.insert(txt, string.format("THTensor *arg%d = NULL;", arg.i))
                if arg.returned then
                   table.insert(txt, string.format("int arg%d_idx = 0;", arg.i));
                end
                return table.concat(txt, '\n')
           end,
   
   check = function(arg, idx)
            return string.format("(arg%d = luaT_toudata(L, %d, torch_(Tensor_id)))", arg.i, idx)
         end,

   read = function(arg, idx)
             if arg.returned then
                return string.format("arg%d_idx = %d;", arg.i, idx)
             end
          end,

   init = function(arg)
             return string.format('arg%d = TH%s_new();', arg.i, typename)
          end,
   
   carg = function(arg, idx)
             return string.format('arg%d', arg.i)
          end,

   creturn = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,
   
   precall = function(arg)
                local txt = {}
                if arg.default and arg.returned then
                   table.insert(txt, string.format('if(arg%d_idx)', arg.i)) -- means it was passed as arg
                   table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                   table.insert(txt, string.format('else')) -- means we did a new()
                   table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_(Tensor_id));', arg.i))
                elseif arg.default then
                   error('a tensor cannot be optional if not returned')
                elseif arg.returned then
                   table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                end
                return table.concat(txt, '\n')
             end,

   postcall = function(arg)
                 local txt = {}
                 if arg.creturned then
                    -- this next line is actually debatable
                    table.insert(txt, string.format('THTensor_(retain)(arg%d);', arg.i))
                    table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_(Tensor_id));', arg.i))
                 end
                 return table.concat(txt, '\n')
              end
}

wrap.argtypes.IndexTensor = {

   helpname = function(arg)
               return "LongTensor"
            end,

   declare = function(arg)
                local txt = {}
                table.insert(txt, string.format("THLongTensor *arg%d = NULL;", arg.i))
                if arg.returned then
                   table.insert(txt, string.format("int arg%d_idx = 0;", arg.i));
                end
                return table.concat(txt, '\n')
           end,
   
   check = function(arg, idx)
              return string.format("(arg%d = luaT_toudata(L, %d, torch_LongTensor_id))", arg.i, idx)
           end,

   read = function(arg, idx)
             local txt = {}
             table.insert(txt, string.format("THLongTensor_add(arg%d, arg%d, -1);", arg.i, arg.i));
             if arg.returned then
                return table.insert(txt, string.format("arg%d_idx = %d;", arg.i, idx))
             end
             return table.concat(txt, '\n')
          end,

   init = function(arg)
             return string.format('arg%d = THLongTensor_new();', arg.i)
          end,
   
   carg = function(arg, idx)
             return string.format('arg%d', arg.i)
          end,

   creturn = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,
   
   precall = function(arg)
                local txt = {}
                if arg.default and arg.returned then
                   table.insert(txt, string.format('if(arg%d_idx)', arg.i)) -- means it was passed as arg
                   table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                   table.insert(txt, string.format('else')) -- means we did a new()
                   table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_LongTensor_id);', arg.i))
                elseif arg.default then
                   error('a tensor cannot be optional if not returned')
                elseif arg.returned then
                   table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                end
                return table.concat(txt, '\n')
             end,

   postcall = function(arg)
                 local txt = {}
                 if arg.creturned or arg.returned then
                    table.insert(txt, string.format("THLongTensor_add(arg%d, arg%d, 1);", arg.i, arg.i));
                 end
                 if arg.creturned then
                    -- this next line is actually debatable
                    table.insert(txt, string.format('THLongTensor_retain(arg%d);', arg.i))
                    table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_LongTensor_id);', arg.i))
                 end
                 return table.concat(txt, '\n')
              end
}

for _,typename in ipairs({"ByteTensor", "CharTensor", "ShortTensor", "IntTensor", "LongTensor",
                          "FloatTensor", "DoubleTensor"}) do

   wrap.argtypes[typename] = {

      helpname = function(arg)
                    return typename
                 end,
      
      declare = function(arg)
                   local txt = {}
                   table.insert(txt, string.format("TH%s *arg%d = NULL;", typename, arg.i))
                   if arg.returned then
                      table.insert(txt, string.format("int arg%d_idx = 0;", arg.i));
                   end
                   return table.concat(txt, '\n')
                end,
      
      check = function(arg, idx)
                 return string.format("(arg%d = luaT_toudata(L, %d, torch_%s_id))", arg.i, idx, typename)
              end,

      read = function(arg, idx)
                if arg.returned then
                   return string.format("arg%d_idx = %d;", arg.i, idx)
                end
             end,
      
      init = function(arg)
                return string.format('arg%d = TH%s_new();', arg.i, typename)
             end,

      carg = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,

      creturn = function(arg, idx)
                   return string.format('arg%d', arg.i)
             end,
      
      precall = function(arg)
                   local txt = {}
                   if arg.default and arg.returned then
                      table.insert(txt, string.format('if(arg%d_idx)', arg.i)) -- means it was passed as arg
                      table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                      table.insert(txt, string.format('else')) -- means we did a new()
                      table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_%s_id);', arg.i, typename))
                   elseif arg.default then
                      error('a tensor cannot be optional if not returned')
                   elseif arg.returned then
                      table.insert(txt, string.format('lua_pushvalue(L, arg%d_idx);', arg.i))
                   end
                   return table.concat(txt, '\n')
                end,

      postcall = function(arg)
                    local txt = {}
                    if arg.creturned then
                       -- this next line is actually debatable
                       table.insert(txt, string.format('TH%s_retain(arg%d);', typename, arg.i))
                       table.insert(txt, string.format('luaT_pushudata(L, arg%d, torch_%s_id);', arg.i, typename))
                    end
                    return table.concat(txt, '\n')
                 end
   }
end

local function interpretdefaultvalue(arg)
   local default = arg.default
   if type(default) == 'boolean' then
      if default then
         return '1'
      else
         return '0'
      end
   elseif type(default) == 'number' then
      return tostring(default)
   elseif type(default) == 'string' then
      return default
   elseif type(default) == 'function' then
      default = default(arg)
      assert(type(default) == 'string', 'a default function must return a string')
      return default
   elseif type(default) == 'nil' then
      return nil
   else
      error('unknown default type value')
   end   
end

wrap.argtypes.index = {

   helpname = function(arg)
               return "index"
            end,

   declare = function(arg)
                -- if it is a number we initialize here
                local default = tonumber(interpretdefaultvalue(arg)) or 1
                return string.format("long arg%d = %d;", arg.i, tonumber(default)-1)
           end,

   check = function(arg, idx)
              return string.format("lua_isnumber(L, %d)", idx)
           end,

   read = function(arg, idx)
             return string.format("arg%d = (long)lua_tonumber(L, %d)-1;", arg.i, idx)
          end,

   init = function(arg)
             -- otherwise do it here
             if arg.default then
                local default = interpretdefaultvalue(arg)
                if not tonumber(default) then
                   return string.format("arg%d = %s-1;", arg.i, default)
                end
             end
          end,

   carg = function(arg, idx)
             return string.format('arg%d', arg.i)
          end,

   creturn = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,

   precall = function(arg)
                if arg.returned then
                   return string.format('lua_pushnumber(L, (lua_Number)arg%d+1);', arg.i)
                end
             end,

   postcall = function(arg)
                 if arg.creturned then
                    return string.format('lua_pushnumber(L, (lua_Number)arg%d+1);', arg.i)
                 end
              end
}

wrap.argtypes.byte = {

   helpname = function(arg)
               return "byte"
            end,

   declare = function(arg)
                -- if it is a number we initialize here
                local default = tonumber(interpretdefaultvalue(arg)) or 0
                return string.format("unsigned char arg%d = %d;", arg.i, tonumber(default))
           end,

   check = function(arg, idx)
              return string.format("lua_isnumber(L, %d)", idx)
           end,

   read = function(arg, idx)
             return string.format("arg%d = (unsigned char)lua_tonumber(L, %d);", arg.i, idx)
          end,

   init = function(arg)
             -- otherwise do it here
             if arg.default then
                local default = interpretdefaultvalue(arg)
                if not tonumber(default) then
                   return string.format("arg%d = %s;", arg.i, default)
                end
             end
          end,

   carg = function(arg, idx)
             return string.format('arg%d', arg.i)
          end,

   creturn = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,

   precall = function(arg)
                if arg.returned then
                   return string.format('lua_pushnumber(L, (lua_Number)arg%d);', arg.i)
                end
             end,

   postcall = function(arg)
                 if arg.creturned then
                    return string.format('lua_pushnumber(L, (lua_Number)arg%d);', arg.i)
                 end
              end
}

for _,typename in ipairs({"real", "char", "short", "int", "long", "float", "double"}) do
   wrap.argtypes[typename] = {

      helpname = function(arg)
                    return typename
                 end,

      declare = function(arg)
                   -- if it is a number we initialize here
                   local default = tonumber(interpretdefaultvalue(arg)) or 0
                   return string.format("%s arg%d = %d;", typename, arg.i, tonumber(default))
                end,

      check = function(arg, idx)
                 return string.format("lua_isnumber(L, %d)", idx)
              end,

      read = function(arg, idx)
                return string.format("arg%d = (%s)lua_tonumber(L, %d);", arg.i, typename, idx)
             end,

      init = function(arg)
                -- otherwise do it here
                if arg.default then
                   local default = interpretdefaultvalue(arg)
                   if not tonumber(default) then
                      return string.format("arg%d = %s;", arg.i, default)
                   end
                end
             end,
      
      carg = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,

      creturn = function(arg, idx)
                   return string.format('arg%d', arg.i)
                end,
      
      precall = function(arg)
                   if arg.returned then
                      return string.format('lua_pushnumber(L, (lua_Number)arg%d);', arg.i)
                   end
                end,
      
      postcall = function(arg)
                    if arg.creturned then
                       return string.format('lua_pushnumber(L, (lua_Number)arg%d);', arg.i)
                    end
                 end
   }
end

wrap.argtypes.boolean = {

   helpname = function(arg)
                 return "boolean"
              end,

   declare = function(arg)
                -- if it is a number we initialize here
                local default = tonumber(interpretdefaultvalue(arg)) or 0
                return string.format("int arg%d = %d;", arg.i, tonumber(default))
             end,

   check = function(arg, idx)
              return string.format("lua_isboolean(L, %d)", idx)
           end,

   read = function(arg, idx)
             return string.format("arg%d = lua_toboolean(L, %d);", arg.i, idx)
          end,

   init = function(arg)
             -- otherwise do it here
             if arg.default then
                local default = interpretdefaultvalue(arg)
                if not tonumber(default) then
                   return string.format("arg%d = %s;", arg.i, default)
                end
             end
          end,

   carg = function(arg, idx)
             return string.format('arg%d', arg.i)
          end,

   creturn = function(arg, idx)
                return string.format('arg%d', arg.i)
             end,

   precall = function(arg)
                if arg.returned then
                   return string.format('lua_pushboolean(L, arg%d);', arg.i)
                end
             end,

   postcall = function(arg)
                 if arg.creturned then
                    return string.format('lua_pushboolean(L, arg%d);', arg.i)
                 end
              end
}
