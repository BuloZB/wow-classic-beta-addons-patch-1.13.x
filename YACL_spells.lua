-- ************************************************************
-- all info in the database is base on this spell object
-- ************************************************************

local _SETMETA =setmetatable;
local _FLOOR   =math.floor;

yacl_spell_default=
{
   n =0;  -- total events number
   a =0;  -- average damage/healing
   s =0;  -- sum of damage or healing
   e =0;  -- effective damage or healing
   o =0;  -- over damage or healing
   c =0;  -- crit counter
   l =0;  -- glancing blow counter (player versus mob)
   g =0;  -- dodge counter
   p =0;  -- parry counter
   m =0;  -- miss counter
   b =0;  -- block counter
   r =0;  -- crushing counter
   x =0;  -- max damage
   
   k =0;  -- kill counter
   d =0;  -- death counter
   t =0;  -- overall active combat time
   
   S =0;  -- total sum of damage done for player
   T =0;  -- total sum of damage taken for player
   H =0;  -- total sum of healing done for player
   I =0;  -- total sum of healing received for player
   
   meta_check=1;
};

yacl_spell=
{
   meta=
   {
      __index=yacl_spell_default;
   };
   
   new=function()
      local spell={};
      _SETMETA(spell,yacl_spell.meta);
      return spell;
   end;
   
   add=function(self,amount,effective,resisted,blocked,critical,glancing,crushing)
      self.n=self.n+1;
      self.s=self.s+amount;
      self.e=self.e+effective;
      if(amount~=effective) then
         self.o=self.o + (amount-effective);
      end
      if(resisted) then
         local m=self.m;
         m =m +resisted/(resisted+amount);
         m =_FLOOR(m*100)/100;
         self.m=m;
      end
      if(blocked) then
         local b=self.b;
         b =b +blocked/(blocked+amount);
         b =_FLOOR(b*100)/100;
         self.b=b;
      end
      if(critical) then self.c =self.c +1; end
      if(glancing) then self.l =self.l +1; end
      if(crushing) then self.r =self.r +1; end
      if(amount>self.x) then self.x=amount; end
   end;
   
   add_spell=function(self,spell)
      for key,value in pairs(spell) do
         if(key=="x") then
            if(value>self[key]) then
               self[key]=value;
            end
         else
            self[key]=self[key] + value;
         end
      end
   end;
   
   sub_spell=function(self,spell)
      for key,value in pairs(spell) do
         if(key~="x") then
            self[key]=self[key] - value;
         end
      end
   end;
   
   clear=function(self)
      for key,value in pairs(self) do
         self[key]=nil;
      end
   end;
   
   delta=function(self,spell)
      for key,value in pairs(spell) do
         local old=self[key] or 0;
         if(old~=value) then
            if(key~="x") then
               self[key]=value - old;
            else
               self[key]=value;
            end
         else
            self[key]=nil;
         end
      end
   end;
   
};
