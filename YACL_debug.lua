-- ******************************************************************
--
-- important 2.4 Functions:
--          UnitGUID(unitID)
--          name,rank =GetSpellInfo(spellID)
--          GetSpellLink
--          UnitInRange()       based on healing range
--
-- ******************************************************************

if(not UnitGUID) then
   print("UnitGUID not implemented !");
   UnitGUID=function(unitID)
      return UnitName(unitID);
   end
end

if(not GetSpellInfo) then
   print("GetSpellInfo not implemented !");
   GetSpellInfo=function(spellID)
      return "Unknown";
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:analyse_arguments(text)
   if(arg1) then text=text .. " 1:" .. arg1; end
   if(arg2) then text=text .. " 2:" .. arg2; end
   if(arg3) then text=text .. " 3:" .. arg3; end
   if(arg4) then text=text .. " 4:" .. arg4; end
   if(arg5) then text=text .. " 5:" .. arg5; end
   print(text);
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:debug(text)
   DEFAULT_CHAT_FRAME:AddMessage(text,1,1,0);
end

-- ******************************************************************
--
-- ******************************************************************

local _SETMETA=setmetatable;
local _COPY  ;
function yacl_copy_table(source)
   local result={};
   for key, value in pairs(source) do
      if( type(value)=="table" ) then
         result[key]=_COPY(value);
      else
         result[key]=value;
      end
   end
   _SETMETA(result,getmetatable(source));
   return result;
end
_COPY   =yacl_copy_table;

-- ******************************************************************
-- zero garbage table merging:
-- ******************************************************************

local _MERGE ;
function yacl_merge_table(source,dest)
   for key, value in pairs(source) do
      if( type(value)=="table" ) then
         local dest_entry=dest[key];
         if(not dest_entry) then
            dest_entry={};
            dest[key]=dest_entry;
         end
         _MERGE(value,dest_entry);
      else
         dest[key]=value;
      end
   end
   _SETMETA(dest,getmetatable(source));
   return dest;
end
_MERGE  =yacl_merge_table


