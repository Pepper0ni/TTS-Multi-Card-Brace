function onLoad(state)
 if state=="done"then
  self.script_state=""
 elseif self.held_by_color==nil then
  self.script_state="done"
  self.reload()
 end
 local scale=self.getScale()
 local params={
 function_owner=self,
 label="X",
 tooltip="Remove cards and delete brace",
 font_size=250,
 width=250,
 height=250,
 position={2.4,0,-2.2},
 scale={1/scale[1],1/scale[2],1/scale[3]},
 click_function="DeleteBrace",
 }
 self.createButton(params)
end

deleting=false
function tryObjectEnter(obj)
 if obj.type=='Deck'then
  local takeObj=nil
  local remain=nil
  cards=obj.getObjects()
  for c=#cards,1,-1 do
   if remain then
    takeObj=remain
   else
    takeObj=obj.takeObject({index=c-1})
    remain=obj.remainder
   end
   self.putObject(takeObj)
  end
  Wait.frames(function()updateAttachments()end,1)
 elseif obj.type=='Card' then
  Wait.frames(function()updateAttachments()end,1)
  return true
 end
end

function onObjectLeaveContainer(container)
 if container==self and not deleting then
  updateAttachments()
 end
end

function updateAttachments()
 self.destroyAttachments()
 local c=self.getQuantity()
 if c>2 then
  attachUnion(c)
 elseif c>0 then
  attachLegend(c)
 end
 self.script_state="done"
 self.reload()
end

function attachLegend(c)
 local cards=self.getData()["ContainedObjects"]
 table.sort(cards,function(a,b)return sortByMemo(a,b)end)
 local rot=self.GetRotation()
 rot[2]=rot[2]+90
 local obj=spawnObjectData({data=cards[1],position=self.positionToWorld({0,2,-1.05}),rotation=rot,scale={0.733,1,0.733}})
 self.addAttachment(obj)
 if c>1 then
  obj=spawnObjectData({data=cards[2],position=self.positionToWorld({0,2,1.05}),rotation=rot,scale={0.733,1,0.733}})
  self.addAttachment(obj)
 end
end

function attachUnion(c)
 local cards=self.getData()["ContainedObjects"]
 table.sort(cards,function(a,b)return sortByMemo(a,b)end)
 local rot=self.GetRotation()
 local count=0
 repeat
  local obj=spawnObjectData({data=cards[count+1],position=self.positionToWorld({1.505-((count%2)*3.01),2,-1+(math.floor(count/2)*2)}),rotation=rot,scale={0.4975,1,0.5}})
  count=count+1
  self.addAttachment(obj)
 until(count==c or count==4)
end

function sortByMemo(a,b)
 local aMemo=tonumber(a.Memo)
 local bMemo=tonumber(b.Memo)
 if aMemo and bMemo then
  return aMemo<bMemo
 end
 return a.CardID<b.CardID
end

function DeleteBrace()
 deleting=true
 local numCards=self.getQuantity()
 for c=numCards,1,-1 do
  self.takeObject({index=0,position=self.positionToWorld{0,0,0}})
 end
 self.destruct()
end
