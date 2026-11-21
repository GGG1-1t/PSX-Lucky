local function isfn(f)
 return type(f)=="function"
end

local T=task
if type(T)~="table" then
 T={}
end

if not isfn(T.spawn) then
 T.spawn=function(f,...)
  if isfn(spawn) then
   return spawn(f,...)
  end
  if isfn(create) and isfn(resume) then
   local c=create(f)
   resume(c,...)
   return c
  end
  return nil
 end
end

if not isfn(T.wait) then
 if isfn(wait) then
  T.wait=wait
 else
  T.wait=function(s)
  end
 end
end

if not isfn(T.delay) then
 T.delay=function(s,f,...)
  if isfn(delay) then
   return delay(s,f,...)
  end
  return T.spawn(function()
   T.wait(s)
   if isfn(f) then
    f(...)
   end
  end)
 end
end

if not isfn(T.defer) then
 T.defer=function(f,...)
  return T.spawn(f,...)
 end
end

local indGui, indLbl
pcall(function()
 local pg0=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui",10)
 if not pg0 then
  return
 end

 indGui=Instance.new("ScreenGui")
 indGui.Name="PFEVP_IND"
 indGui.ResetOnSpawn=false
 indGui.DisplayOrder=1000
 indGui.Parent=pg0

 indLbl=Instance.new("TextLabel")
 indLbl.Size=UDim2.fromOffset(280,44)
 indLbl.Position=UDim2.new(0,12,0,12)
 indLbl.BackgroundColor3=Color3.fromRGB(22,10,14)
 indLbl.BorderSizePixel=0
 indLbl.Text="PFEVP: starting"
 indLbl.TextColor3=Color3.fromRGB(240,222,226)
 indLbl.TextSize=12
 indLbl.Font=Enum.Font.GothamBold
 indLbl.Parent=indGui
end)

local ok, err = pcall(function()
 local PS=game:GetService("Players")
 local RS=game:GetService("ReplicatedStorage")
 local WS=game:GetService("Workspace")
 local LIT=game:GetService("Lighting")
 local lp=PS.LocalPlayer
 local pg=lp:WaitForChild("PlayerGui",15)

 if not pg then
  error("no PlayerGui")
 end

 pcall(function()
  for _,d in ipairs(pg:GetChildren()) do
   if d:IsA("ScreenGui") and (d.Name=="PFEVP" or d.Name:find("PFEV_ERR")) then
    d:Destroy()
   end
  end
 end)

 local BG=Color3.fromRGB(14,8,10)
 local PN=Color3.fromRGB(26,13,17)
 local OV=Color3.fromRGB(42,20,26)
 local RED=Color3.fromRGB(226,28,58)
 local ORANGE=Color3.fromRGB(255,96,40)
 local TEXT=Color3.fromRGB(240,222,226)
 local DIM=Color3.fromRGB(152,128,134)
 local GREEN=Color3.fromRGB(120,230,120)
 local AMBER=Color3.fromRGB(255,176,40)
 local INK=Color3.fromRGB(8,4,5)

 local S={
  run=false,
  loop=false,
  pets={},
  tg=1,
  slots={},
  skip={},
  gap=0.9,
  sent=0,
  brk=0,
  errs=0,
  grace=0,
  idle=0,
  unst=0,
  cand=0,
  cf=nil,
  rf=nil,
  rf75=nil,
  egg="",
  egN=8,
  egAuto=false,
  egLoop=false,
  egOk=0,
  egFl=0,
  iv=2.45,
  last=0,
  lines={}
 }

 local AF={
  farm=false,
  egg=false,
  eggUntil=0,
  hideCoins=false,
  killed=0,
  hidden=0,
  light=false,
  lightUntil=0,
  events=0,
  eventT=0
 }

 local GEN=_G
 pcall(function()
  if isfn(getgenv) then
   local g=getgenv()
   if type(g)=="table" then
    GEN=g
   end
  end
 end)

 if type(GEN)~="table" then
  GEN=_G
 end

 local VD=GEN.PFVOIDP
 if type(VD)~="table" then
  VD={}
  GEN.PFVOIDP=VD
 end

 VD.on=VD.on==true
 VD.saved=VD.saved or setmetatable({},{__mode="k"})
 VD.arr=VD.arr or {}
 VD.queue=VD.queue or {}
 VD.conns=VD.conns or {}
 VD.hidden=tonumber(VD.hidden) or 0
 VD.plast=tonumber(VD.plast) or 0
 VD.light=VD.light or nil
 VD.busy=false

 local Lib=nil
 local cM=setmetatable({},{__mode="k"})

 local gui=Instance.new("ScreenGui")
 gui.Name="PFEVP"
 gui.ResetOnSpawn=false
 gui.DisplayOrder=999
 gui.Parent=pg

 local root=Instance.new("Frame")
 root.Size=UDim2.fromOffset(252,260)
 root.Position=UDim2.new(1,-264,0,60)
 root.BackgroundColor3=BG
 root.BorderSizePixel=0
 root.Parent=gui

 local function lab(parent,x,y,w,h,text,size,color)
  local l=Instance.new("TextLabel")
  l.Size=UDim2.fromOffset(w,h)
  l.Position=UDim2.fromOffset(x,y)
  l.BackgroundTransparency=1
  l.Text=text or ""
  l.TextSize=size or 9
  l.TextColor3=color or TEXT
  l.Font=Enum.Font.GothamBold
  l.Parent=parent
  return l
 end

 local function bt(parent,x,y,w,h,text,bg,tc,size)
  local b=Instance.new("TextButton")
  b.Size=UDim2.fromOffset(w,h)
  b.Position=UDim2.fromOffset(x,y)
  b.BackgroundColor3=bg or OV
  b.Text=text or ""
  b.TextSize=size or 9
  b.Font=Enum.Font.GothamBold
  b.TextColor3=tc or TEXT
  b.BorderSizePixel=0
  b.Parent=parent
  return b
 end

 lab(root,8,4,200,18,"EVIL PETS PLAIN",13,TEXT)
 local stt=lab(root,8,22,236,14,"boot",8,DIM)
 local errL=lab(root,8,36,236,14,"",8,DIM)

 local tabF=bt(root,8,54,118,22,"FARM",OV,TEXT,10)
 local tabE=bt(root,128,54,118,22,"EGGS",PN,DIM,10)

 local pageF=Instance.new("Frame")
 pageF.Size=UDim2.fromOffset(236,170)
 pageF.Position=UDim2.fromOffset(8,80)
 pageF.BackgroundTransparency=1
 pageF.BorderSizePixel=0
 pageF.Parent=root

 local pageE=Instance.new("Frame")
 pageE.Size=UDim2.fromOffset(236,170)
 pageE.Position=UDim2.fromOffset(8,80)
 pageE.BackgroundTransparency=1
 pageE.BorderSizePixel=0
 pageE.Visible=false
 pageE.Parent=root

 local startB=bt(pageF,0,0,236,34,"START FARM",RED,INK,14)
 local sub=lab(pageF,0,34,236,12,"",8,DIM)

 local row=Instance.new("Frame")
 row.Size=UDim2.fromOffset(236,24)
 row.Position=UDim2.fromOffset(0,50)
 row.BackgroundColor3=PN
 row.BackgroundTransparency=0.25
 row.BorderSizePixel=0
 row.Parent=pageF

 lab(row,8,0,40,24,"PETS",8,DIM)
 local mn=bt(row,52,2,26,20,"-",OV,TEXT,12)
 local pv=lab(row,80,0,74,24,"1 / 1",11,TEXT)
 local pl=bt(row,156,2,26,20,"+",OV,TEXT,12)
 local mx=bt(row,186,2,44,20,"MAX",OV,TEXT,8)

 local stat=lab(pageF,0,78,236,40,"",8,DIM)
 local farmB=bt(pageF,0,122,114,22,"FARM FX OFF",OV,TEXT,8)
 local hideB=bt(pageF,122,122,114,22,"HIDE COINS OFF",OV,TEXT,8)
 local voidB=bt(pageF,0,148,114,22,"VOID OFF",OV,TEXT,8)
 local voidC=bt(pageF,122,148,114,22,"VOID SCAN",OV,TEXT,8)

 local nb=Instance.new("TextBox")
 nb.Size=UDim2.fromOffset(236,24)
 nb.Position=UDim2.fromOffset(0,0)
 nb.BackgroundColor3=PN
 nb.Text=""
 nb.PlaceholderText="egg name"
 nb.TextSize=9
 nb.Font=Enum.Font.GothamBold
 nb.TextColor3=TEXT
 nb.BorderSizePixel=0
 nb.Parent=pageE

 local capB=bt(pageE,0,28,236,22,"SET EGG",OV,AMBER,8)
 local n1=bt(pageE,0,54,76,20,"1",OV,TEXT,9)
 local n3=bt(pageE,80,54,76,20,"3",OV,TEXT,9)
 local n8=bt(pageE,160,54,76,20,"8",RED,INK,9)
 local opB=bt(pageE,0,78,114,30,"OPEN",OV,TEXT,11)
 local auB=bt(pageE,122,78,114,30,"AUTO",RED,INK,11)
 local est=lab(pageE,0,112,236,34,"",8,DIM)
 local eggB=bt(pageE,0,150,236,20,"EGG FX OFF",OV,TEXT,8)

 local minB=bt(root,222,6,22,20,"-",OV,TEXT,12)

 local pill=bt(gui,0,0,130,36,"EVIL PETS PLAIN",PN,TEXT,10)
 pill.Position=UDim2.new(1,-264,0,60)
 pill.Visible=false

 local function log(x)
  S.lines[#S.lines+1]=tostring(x)
  if #S.lines>40 then
   table.remove(S.lines,1)
  end
 end

 local function setStatus(t)
  if stt and stt.Parent then
   stt.Text=tostring(t)
  end
 end

 local function setError(t)
  if errL and errL.Parent then
   errL.Text="ERR: "..tostring(t):sub(1,90)
   errL.TextColor3=RED
  end
  log(t)
 end

 local function clamp(v,lo,hi)
  if v<lo then
   return lo
  elseif v>hi then
   return hi
  end
  return v
 end

 local function low(s)
  return tostring(s):lower()
 end

 local function fpath(i)
  if not i then
   return "?"
  end
  local ok,s=pcall(function()
   return i:GetFullName()
  end)
  if ok then
   return tostring(s)
  end
  return "?"
 end

 local function attr(i,n)
  if not i then
   return nil
  end
  local ok,v=pcall(function()
   return i:GetAttribute(n)
  end)
  if ok then
   return v
  end
  return nil
 end

 local function th()
  local ok,t=pcall(function()
   return WS:FindFirstChild("__THINGS")
  end)
  if ok then
   return t
  end
  return nil
 end

 local function byRF(n)
  local c=0
  local ok,list=pcall(function()
   return RS:GetChildren()
  end)
  if not ok or not list then
   return nil
  end
  for _,d in ipairs(list) do
   local ok2,cls=pcall(function()
    return d.ClassName
   end)
   if ok2 and cls=="RemoteFunction" then
    c=c+1
    if c==n then
     return d
    end
   end
  end
  return nil
 end

 S.rf=byRF(10)
 S.rf75=byRF(75)

 local function fold()
  if S.cf and S.cf.Parent then
   return S.cf
  end
  local t=th()
  if t then
   S.cf=t:FindFirstChild("Coins")
  end
  return S.cf
 end

 local function coins()
  local f=fold()
  if not f then
   return 0
  end
  local ok,ch=pcall(function()
   return f:GetChildren()
  end)
  if ok and ch then
   return #ch
  end
  return 0
 end

 local function alive(c)
  if not c or not c.Parent then
   return false
  end
  if attr(c,"IsFalling")==true then
   return false
  end
  local h=tonumber(attr(c,"Health"))
  if h and h<=0 then
   return false
  end
  return true
 end

 local function meta(c)
  local m=cM[c]
  if not m then
   local i=attr(c,"ID")
   m={
    id=(type(i)=="string" and i~="" and i) or nil
   }
   cM[c]=m
  end
  return m
 end

 local function memoSet(e)
  e=tostring(e or "")
  if e=="" then
   return
  end
  S.egg=e
  if nb and nb.Parent then
   nb.Text=e
  end
  pcall(function()
   GEN.EvilPetsEggP=e
  end)
 end

 local function memoGet()
  local e
  pcall(function()
   e=GEN.EvilPetsEggP
  end)
  if type(e)=="string" then
   return e
  end
  return ""
 end

 local function show(n)
  pageF.Visible=(n==1)
  pageE.Visible=(n==2)

  tabF.BackgroundColor3=(n==1) and OV or PN
  tabF.TextColor3=(n==1) and TEXT or DIM
  tabE.BackgroundColor3=(n==2) and OV or PN
  tabE.TextColor3=(n==2) and TEXT or DIM

  if n==2 then
   local mem=memoGet()
   if mem~="" then
    nb.Text=mem
   end
  end
 end

 local function boot()
  if Lib then
   return true
  end
  local ok,lib=pcall(function()
   return require(RS:WaitForChild("Library",5))
  end)
  if not ok or type(lib)~="table" then
   return false
  end
  Lib=lib
  local t0=os.clock()
  while Lib and Lib.Loaded==false and os.clock()-t0<5 do
   T.wait(0.2)
  end
  return true
 end

 local function save()
  if not Lib then
   return nil
  end
  local ok,v=pcall(function()
   return Lib.Save.Get()
  end)
  if ok and type(v)=="table" then
   return v
  end
  return nil
 end

 local function pets()
  local s=save()
  local eq={}
  local lim=0

  if s then
   lim=tonumber(s.MaxEquipped) or 0
   if type(s.Pets)=="table" then
    for _,p in pairs(s.Pets) do
     if type(p)=="table" and p.e==true and type(p.uid)=="string" then
      eq[#eq+1]=p.uid
     end
    end
   end
  end

  if #eq==0 then
   local t=th()
   local f=t and t:FindFirstChild("Pets")
   if f then
    local ok,ch=pcall(function()
     return f:GetChildren()
    end)
    if ok and ch then
     for _,p in ipairs(ch) do
      local id=attr(p,"ID") or p.Name
      if type(id)=="string" and id:sub(1,2)=="id" then
       eq[#eq+1]=id
      end
     end
    end
   end
  end

  table.sort(eq,function(a,b)
   return tostring(a)<tostring(b)
  end)

  local cap=clamp(math.max(lim,#eq),1,80)
  local out={}
  for i=1,math.min(cap,#eq) do
   out[#out+1]=eq[i]
  end
  return out
 end

 local function slots()
  S.tg=clamp(S.tg,1,math.max(1,#S.pets))
  S.slots={}

  if pv and pv.Parent then
   pv.Text=S.tg.." / "..math.max(1,#S.pets)
  end

  if #S.pets<1 then
   return
  end

  local per=math.ceil(#S.pets/S.tg)
  local i=1
  local now=os.clock()

  for n=1,S.tg do
   local g={}
   for _=1,per do
    if i<=#S.pets then
     g[#g+1]=S.pets[i]
     i=i+1
    end
   end
   if #g>0 then
    S.slots[#S.slots+1]={
     g=g,
     cur=nil,
     next=now+(n-1)*0.18
    }
   end
  end
 end

 local function cands(used)
  local f=fold()
  if not f then
   return {}
  end

  local ok,ch=pcall(function()
   return f:GetChildren()
  end)
  if not ok or not ch then
   return {}
  end

  local now=os.clock()
  local out={}

  for i=1,#ch do
   local c=ch[i]
   if c and c.Parent then
    local m=meta(c)
    local id=m.id
    if id and not used[id] and not (S.skip[id] and S.skip[id]>now) then
     local h=tonumber(attr(c,"Health"))
     if (not h or h>0) and attr(c,"IsFalling")~=true then
      out[#out+1]={
       c=c,
       id=id,
       hp=h or 999999
      }
     end
    end
   end
  end

  table.sort(out,function(a,b)
   return a.hp<b.hp
  end)

  return out
 end

 local function tick()
  if os.clock()<S.grace then
   return "grace"
  end

  if not S.rf or not S.rf.Parent then
   S.rf=byRF(10)
  end
  if not S.rf then
   return "no RF10"
  end

  if #S.pets<1 then
   S.pets=pets()
   slots()
  end
  if #S.slots~=S.tg then
   slots()
  end
  if #S.slots<1 then
   return "no pets"
  end

  local f=fold()
  if not f then
   return "no coins"
  end

  local okch,ch=pcall(function()
   return f:GetChildren()
  end)
  if not okch or not ch or #ch==0 then
   return "no coins"
  end

  local now=os.clock()

  for _,sl in ipairs(S.slots) do
   if sl.cur then
    if not alive(sl.cur.p) then
     S.brk=S.brk+1
     sl.cur=nil
     sl.next=now+S.gap
    else
     local h=tonumber(attr(sl.cur.p,"Health"))
     if h and sl.cur.hp and h<sl.cur.hp then
      sl.cur.hp=h
      sl.cur.hit=now
     end
     if now-(sl.cur.hit or now)>8 or now-(sl.cur.born or now)>22 then
      S.skip[sl.cur.id]=now+8
      sl.cur=nil
      sl.next=now+0.4
     end
    end
   end
  end

  local used={}
  for _,sl in ipairs(S.slots) do
   if sl.cur then
    used[sl.cur.id]=true
   end
  end

  local list=cands(used)
  S.cand=#list
  local li=1

  for _,sl in ipairs(S.slots) do
   if not sl.cur and now>=sl.next then
    local e=list[li]
    if e then
     li=li+1
     local oki,r=pcall(function()
      return S.rf:InvokeServer(e.id,sl.g)
     end)
     S.sent=S.sent+1
     if oki and type(r)=="table" then
      S.errs=0
     else
      S.errs=S.errs+1
     end
     sl.cur={
      p=e.c,
      id=e.id,
      hp=e.hp,
      hit=now,
      born=now
     }
     sl.next=now+S.gap
    else
     sl.next=now+0.4
    end
   end
  end

  local a=0
  for _,sl in ipairs(S.slots) do
   if sl.cur then
    a=a+1
   end
  end

  if a==0 and #list==0 then
   S.idle=S.idle+0.25
   if S.idle>=4 and S.unst<1 then
    S.unst=1
    S.skip={}
   end
   if S.idle>=20 then
    return "stop"
   end
  else
   S.idle=0
   S.unst=0
  end

  if S.errs>=40 then
   return "rejects"
  end
  if S.sent>=220 and S.brk==0 then
   return "no damage"
  end

  return "farm a="..a.." c="..#ch.." void="..(VD.on and "on" or "off")
 end

 local function stopF(m)
  S.run=false
  S.slots={}
  S.skip={}
  S.idle=0
  if startB and startB.Parent then
   startB.Text="START FARM"
  end
  if sub and sub.Parent then
   sub.Text=""
  end
  setFarm(false)
  setStatus(m or "stopped")
 end

 local function startLoop()
  if S.loop then
   return
  end
  S.loop=true
  T.spawn(function()
   while S.run and gui and gui.Parent do
    local okm,m=pcall(tick)
    if okm then
     if m=="stop" or m=="rejects" or m=="no damage" then
      stopF(m)
     else
      setStatus(m)
     end
    else
     setError(m)
     S.run=false
     if startB and startB.Parent then
      startB.Text="START FARM"
     end
    end
    T.wait(0.25)
   end
   S.loop=false
  end)
 end

 local function hud()
  local a=0
  for _,sl in ipairs(S.slots) do
   if sl.cur then
    a=a+1
   end
  end

  if stat and stat.Parent then
   stat.Text="breaks "..S.brk.." sent "..S.sent.." active "..a.."\ncoins "..coins().." targets "..S.cand.."\npets "..S.tg.."/"..math.max(1,#S.pets).."\nvoid "..(VD.on and "ON" or "off").." hid "..VD.hidden
  end

  if est and est.Parent then
   est.Text="egg "..tostring(S.egg or "-").."\nok "..S.egOk.." rej "..S.egFl.." pace "..string.format("%.2f",S.iv).."\nfarm "..tostring(AF.farm).." eggfx "..tostring(AF.egg).." void "..tostring(VD.on)
  end

  if pv and pv.Parent then
   pv.Text=S.tg.." / "..math.max(1,#S.pets)
  end
 end

 local VD_DISABLE={
  ParticleEmitter=true,
  Trail=true,
  Sparkles=true,
  Fire=true,
  Smoke=true,
  Beam=true,
  PointLight=true,
  SpotLight=true,
  SurfaceLight=true,
  Sound=true,
  BillboardGui=true,
  SurfaceGui=true,
  ColorCorrection=true,
  Blur=true,
  DepthOfField=true,
  Bloom=true,
  SunRays=true,
  Decal=true,
  Texture=true
 }

 local function vdProp(i,p)
  local ok,v=pcall(function()
   return i[p]
  end)
  return ok,v
 end

 local function vdSave(i,d)
  if not i then
   return
  end
  if VD.saved[i] then
   return
  end
  VD.saved[i]=d
  VD.arr[#VD.arr+1]=i
  if #VD.arr>50000 then
   local old=table.remove(VD.arr,1)
   VD.saved[old]=nil
  end
 end

 local function vdDisable(i)
  if not i then
   return
  end

  local okp,parent=pcall(function()
   return i.Parent
  end)
  if not okp or not parent then
   return
  end

  local okcls,cls=pcall(function()
   return i.ClassName
  end)
  if not okcls then
   return
  end

  if cls=="Sound" then
   local ov,vol=vdProp(i,"Volume")
   local op,play=vdProp(i,"Playing")
   vdSave(i,{k="snd",v=ov and vol or 0.5,p=op and play or false})
   pcall(function()
    i.Volume=0
    i.Playing=false
   end)
   VD.hidden=VD.hidden+1
   return
  end

  if cls=="Decal" or cls=="Texture" then
   local ot,tr=vdProp(i,"Transparency")
   if ot then
    vdSave(i,{k="tr",v=tr})
    pcall(function()
     i.Transparency=1
    end)
    VD.hidden=VD.hidden+1
   end
   return
  end

  local oe,en=vdProp(i,"Enabled")
  if oe then
   vdSave(i,{k="en",v=en})
   pcall(function()
    i.Enabled=false
   end)
   VD.hidden=VD.hidden+1
  end
 end

 local function vdPart(p)
  if not p then
   return
  end

  local okp,parent=pcall(function()
   return p.Parent
  end)
  if not okp or not parent then
   return
  end

  local ot,t=vdProp(p,"Transparency")
  if not ot then
   return
  end

  local ocs,cs=vdProp(p,"CastShadow")
  local orf,rf=vdProp(p,"Reflectance")
  local om,mt=vdProp(p,"Material")

  local csVal=true
  if ocs then
   csVal=cs
  end

  local rfVal=0
  if orf then
   rfVal=rf
  end

  local mtVal=Enum.Material.Plastic
  if om then
   mtVal=mt
  end

  local tex
  local okmesh,isMesh=pcall(function()
   return p:IsA("MeshPart")
  end)
  if okmesh and isMesh then
   local otx,x=vdProp(p,"TextureId")
   if otx then
    tex=x
   end
  end

  vdSave(p,{k="p",t=t,cs=csVal,rf=rfVal,mt=mtVal,tex=tex})

  pcall(function()
   p.Transparency=1
   if ocs then
    p.CastShadow=false
   end
   if orf then
    p.Reflectance=0
   end
   if om then
    p.Material=Enum.Material.Plastic
   end
   if okmesh and isMesh and tex~=nil then
    p.TextureId=""
   end
  end)

  VD.plast=VD.plast+1
 end

 local function voidProcess(i)
  if not VD.on or not i then
   return
  end

  local okp,parent=pcall(function()
   return i.Parent
  end)
  if not okp or not parent then
   return
  end

  local okchar,char=pcall(function()
   return lp.Character
  end)
  if okchar and char then
   local okdesc,desc=pcall(function()
    return i==char or i:IsDescendantOf(char)
   end)
   if okdesc and desc then
    return
   end
  end

  local pl=low(fpath(i))
  if pl:find("pfevp") or pl:find("playergui") or pl:find("currentcamera") then
   return
  end

  local okisa,isa=pcall(function()
   return i:IsA("BasePart")
  end)
  if okisa and isa then
   vdPart(i)
   return
  end

  local okcls,cls=pcall(function()
   return i.ClassName
  end)
  if okcls and VD_DISABLE[cls] then
   vdDisable(i)
  end
 end

 local function voidScan(r,limit)
  if not r or not VD.on or limit<=0 then
   return
  end

  local stack={r}
  local n=0
  while #stack>0 and n<limit and VD.on do
   local x=table.remove(stack)
   n=n+1
   if x then
    pcall(voidProcess,x)
    local okch,ch=pcall(function()
     return x:GetChildren()
    end)
    if okch and ch then
     for i=#ch,1,-1 do
      stack[#stack+1]=ch[i]
     end
    end
   end
   if n%2000==0 then
    T.wait(0)
   end
  end
 end

 local function vdLightOn()
  if VD.light then
   return
  end

  local oBr,br=vdProp(LIT,"Brightness")
  local oAm,am=vdProp(LIT,"Ambient")
  local oOa,oa=vdProp(LIT,"OutdoorAmbient")
  local oEds,eds=vdProp(LIT,"EnvironmentDiffuseScale")
  local oEss,ess=vdProp(LIT,"EnvironmentSpecularScale")
  local oGs,gs=vdProp(LIT,"GlobalShadows")

  local gsVal=true
  if oGs then
   gsVal=gs
  end

  VD.light={
   br=oBr and br or 2,
   am=oAm and am or Color3.new(0.5,0.5,0.5),
   oa=oOa and oa or Color3.new(0.5,0.5,0.5),
   eds=oEds and eds or 1,
   ess=oEss and ess or 1,
   gs=gsVal
  }

  pcall(function()
   LIT.Brightness=0
   LIT.Ambient=Color3.new(0,0,0)
   LIT.OutdoorAmbient=Color3.new(0,0,0)
   LIT.EnvironmentDiffuseScale=0
   LIT.EnvironmentSpecularScale=0
   LIT.GlobalShadows=false
  end)
 end

 local function vdLightRestore()
  if not VD.light then
   return
  end
  local d=VD.light
  pcall(function()
   LIT.Brightness=d.br
   LIT.Ambient=d.am
   LIT.OutdoorAmbient=d.oa
   LIT.EnvironmentDiffuseScale=d.eds
   LIT.EnvironmentSpecularScale=d.ess
   LIT.GlobalShadows=d.gs
  end)
  VD.light=nil
 end

 local function vdDetach()
  if VD.conns.ws then
   pcall(function()
    VD.conns.ws:Disconnect()
   end)
   VD.conns.ws=nil
  end
  if VD.conns.lit then
   pcall(function()
    VD.conns.lit:Disconnect()
   end)
   VD.conns.lit=nil
  end
 end

 local function vdAttach()
  vdDetach()
  if not VD.on then
   return
  end

  local ok1,c1=pcall(function()
   return WS.DescendantAdded:Connect(function(d)
    if VD.on and #VD.queue<3000 then
     table.insert(VD.queue,d)
    end
   end)
  end)
  if ok1 then
   VD.conns.ws=c1
  end

  local ok2,c2=pcall(function()
   return LIT.DescendantAdded:Connect(function(d)
    if VD.on and #VD.queue<3000 then
     table.insert(VD.queue,d)
    end
   end)
  end)
  if ok2 then
   VD.conns.lit=c2
  end
 end

 local function vdRestore()
  VD.on=false
  vdDetach()

  for i=#VD.arr,1,-1 do
   local inst=VD.arr[i]
   local d=inst and VD.saved[inst]
   if inst and d then
    local okp,parent=pcall(function()
     return inst.Parent
    end)
    if okp and parent then
     if d.k=="p" then
      pcall(function()
       inst.Transparency=d.t
       if d.cs~=nil then
        inst.CastShadow=d.cs
       end
       if d.rf~=nil then
        inst.Reflectance=d.rf
       end
       if d.mt then
        inst.Material=d.mt
       end
       local okmesh,isMesh=pcall(function()
        return inst:IsA("MeshPart")
       end)
       if okmesh and isMesh and d.tex~=nil then
        inst.TextureId=d.tex
       end
      end)
     elseif d.k=="en" then
      pcall(function()
       inst.Enabled=d.v
      end)
     elseif d.k=="snd" then
      pcall(function()
       inst.Volume=d.v
       inst.Playing=d.p
      end)
     elseif d.k=="tr" then
      pcall(function()
       inst.Transparency=d.v
      end)
     end
    end
   end
   VD.saved[inst]=nil
   VD.arr[i]=nil
  end

  VD.arr={}
  VD.saved=setmetatable({},{__mode="k"})
  VD.queue={}
  VD.hidden=0
  VD.plast=0
  VD.busy=false
  vdLightRestore()
  voidUpd()
 end

 local function voidUpd()
  if voidB and voidB.Parent then
   voidB.Text=VD.on and "VOID ON" or "VOID OFF"
   voidB.BackgroundColor3=VD.on and GREEN or OV
   voidB.TextColor3=VD.on and INK or TEXT
  end
 end

 local function setVoid(on)
  if on==VD.on then
   return
  end

  if on then
   VD.on=true
   vdLightOn()
   vdAttach()
   voidUpd()
   if not VD.busy then
    VD.busy=true
    T.spawn(function()
     voidScan(WS,15000)
     voidScan(LIT,4000)
     VD.busy=false
     if VD.on then
      setStatus("void scan done")
     end
    end)
   end
  else
   vdRestore()
  end
 end

 local KILL_CLASSES={
  ParticleEmitter=true,
  Trail=true,
  Sparkles=true,
  Fire=true,
  Smoke=true,
  Beam=true,
  PointLight=true,
  SpotLight=true,
  SurfaceLight=true,
  Sound=true
 }

 local function killFx(i)
  if not i then
   return false
  end

  local okcls,cls=pcall(function()
   return i.ClassName
  end)
  if not okcls or not KILL_CLASSES[cls] then
   return false
  end

  pcall(function()
   if i.Enabled~=nil then
    i.Enabled=false
   end
  end)

  if cls=="Sound" then
   pcall(function()
    i.Volume=0
    i.Playing=false
   end)
  end

  pcall(function()
   i:Destroy()
  end)

  AF.killed=AF.killed+1
  return true
 end

 local function scanFolder(folder,limit)
  if not folder or not folder.Parent then
   return
  end

  local stack={folder}
  local n=0
  limit=limit or 120

  while #stack>0 and n<limit do
   local x=table.remove(stack)
   n=n+1
   if x and x.Parent then
    local okname,name=pcall(function()
     return x.Name
    end)
    local skip=false
    if okname then
     if name=="Coins" or name=="Orbs" or name=="Lootbags" or name=="Pets" or name=="__MAP" or name=="__DEBRIS" or name=="CurrentCamera" then
      skip=true
     end
    end
    if not skip then
     pcall(killFx,x)
     local okch,ch=pcall(function()
      return x:GetChildren()
     end)
     if okch and ch then
      for i=#ch,1,-1 do
       stack[#stack+1]=ch[i]
      end
     end
    end
   end
  end
 end

 local function updAF()
  if farmB and farmB.Parent then
   farmB.Text=AF.farm and "FARM FX ON" or "FARM FX OFF"
   farmB.BackgroundColor3=AF.farm and RED or OV
   farmB.TextColor3=AF.farm and INK or TEXT
  end

  if hideB and hideB.Parent then
   hideB.Text=AF.hideCoins and "HIDE COINS ON" or "HIDE COINS OFF"
   hideB.BackgroundColor3=AF.hideCoins and ORANGE or OV
   hideB.TextColor3=AF.hideCoins and INK or TEXT
  end

  if eggB and eggB.Parent then
   eggB.Text=AF.egg and "EGG FX ON" or "EGG FX OFF"
   eggB.BackgroundColor3=AF.egg and AMBER or OV
   eggB.TextColor3=AF.egg and INK or TEXT
  end

  voidUpd()
 end

 local function setFarm(on)
  AF.farm=on
  updAF()
  setStatus(on and "farm fx on" or "farm fx off")
 end

 local function setEgg(on,persist)
  AF.egg=on
  AF.eggUntil=(on and not persist) and (os.clock()+8) or 0
  updAF()
  setStatus(on and (persist and "egg fx on" or "egg fx 8s") or "egg fx off")
 end

 local function eggCall()
  if not S.egg or S.egg=="" then
   S.egg=nb.Text or memoGet()
  end
  if not S.egg or S.egg=="" then
   return false,"no egg"
  end

  memoSet(S.egg)

  if not S.rf75 or not S.rf75.Parent then
   S.rf75=byRF(75)
  end
  if not S.rf75 then
   return false,"no RF75"
  end

  local ok,a,b=pcall(function()
   return S.rf75:InvokeServer(S.egg,S.egN)
  end)

  if not ok then
   return false,"err"
  end
  if a==true then
   return true,"true"
  end
  if type(a)=="table" then
   return true,"t"..#a
  end
  return false,tostring(b or a)
 end

 local function eggStop(m)
  S.egAuto=false
  if auB and auB.Parent then
   auB.Text="AUTO"
  end
  setEgg(false,false)
  if m then
   log(m)
  end
 end

 local function eggLoop()
  while S.egAuto and gui and gui.Parent do
   S.egg=nb.Text or S.egg or memoGet()
   if S.egg=="" then
    eggStop("no name")
    break
   end

   memoSet(S.egg)

   if S.iv<0.8 then
    S.iv=0.8
   end

   local w=S.iv-(os.clock()-S.last)
   if w>0 then
    T.wait(w)
   end

   if not S.egAuto then
    break
   end

   local okm,m=eggCall()
   if okm then
    S.last=os.clock()
    S.egOk=S.egOk+1
    S.egFl=0
    S.iv=math.max(0.8,S.iv-0.02)
   else
    S.egFl=S.egFl+1
    if type(m)=="string" and low(m):find("quickly") then
     S.iv=math.min(4,S.iv+0.15)
    else
     S.iv=math.min(4,S.iv+0.3)
    end
    if S.egFl>=12 then
     eggStop("12 rejects")
     break
    end
    T.wait(0.2)
   end
  end
  S.egLoop=false
 end

 local function setN(v,b)
  S.egN=v
  for _,x in ipairs({n1,n3,n8}) do
   if x and x.Parent then
    x.BackgroundColor3=OV
    x.TextColor3=TEXT
   end
  end
  if b and b.Parent then
   b.BackgroundColor3=RED
   b.TextColor3=INK
  end
  setStatus("egg count "..v)
 end

 tabF.MouseButton1Click:Connect(function()
  pcall(show,1)
 end)

 tabE.MouseButton1Click:Connect(function()
  pcall(show,2)
 end)

 startB.MouseButton1Click:Connect(function()
  pcall(function()
   if S.run then
    stopF("stopped")
    return
   end

   S.pets=pets()
   if #S.pets<1 then
    setStatus("no pets")
    return
   end

   slots()
   S.run=true
   S.skip={}
   S.sent=0
   S.brk=0
   S.errs=0
   S.idle=0
   S.unst=0
   S.grace=os.clock()+1

   if startB and startB.Parent then
    startB.Text="STOP FARM"
   end
   if sub and sub.Parent then
    sub.Text="targets "..S.tg.." gap "..S.gap
   end

   setFarm(true)
   startLoop()
  end)
 end)

 mn.MouseButton1Click:Connect(function()
  pcall(function()
   S.tg=clamp(S.tg-1,1,math.max(1,#S.pets))
   slots()
  end)
 end)

 pl.MouseButton1Click:Connect(function()
  pcall(function()
   S.pets=pets()
   S.tg=clamp(S.tg+1,1,math.max(1,#S.pets))
   slots()
  end)
 end)

 mx.MouseButton1Click:Connect(function()
  pcall(function()
   S.pets=pets()
   S.tg=math.max(1,#S.pets)
   slots()
  end)
 end)

 farmB.MouseButton1Click:Connect(function()
  pcall(function()
   setFarm(not AF.farm)
  end)
 end)

 hideB.MouseButton1Click:Connect(function()
  pcall(function()
   AF.hideCoins=not AF.hideCoins
   updAF()
   setStatus(AF.hideCoins and "hide coins on" or "hide coins off")
  end)
 end)

 voidB.MouseButton1Click:Connect(function()
  pcall(function()
   setVoid(not VD.on)
   setStatus(VD.on and "void on - world hidden" or "void off - restore")
  end)
 end)

 voidC.MouseButton1Click:Connect(function()
  pcall(function()
   if not VD.on then
    setVoid(true)
    return
   end
   if VD.busy then
    setStatus("void busy")
    return
   end
   VD.busy=true
   T.spawn(function()
    voidScan(WS,15000)
    voidScan(LIT,4000)
    VD.busy=false
    setStatus("void scan done")
   end)
  end)
 end)

 capB.MouseButton1Click:Connect(function()
  pcall(function()
   if nb.Text=="" then
    nb.Text=memoGet()
   end
   if nb.Text=="" then
    setStatus("enter egg name")
    return
   end
   memoSet(nb.Text)
   setStatus("egg set: "..S.egg)
  end)
 end)

 n1.MouseButton1Click:Connect(function()
  pcall(setN,1,n1)
 end)

 n3.MouseButton1Click:Connect(function()
  pcall(setN,3,n3)
 end)

 n8.MouseButton1Click:Connect(function()
  pcall(setN,8,n8)
 end)

 opB.MouseButton1Click:Connect(function()
  pcall(function()
   if nb.Text=="" then
    nb.Text=memoGet()
   end
   S.egg=nb.Text
   memoSet(S.egg)
   setEgg(true,false)
   T.spawn(function()
    local okm,m=eggCall()
    if okm then
     S.egOk=S.egOk+1
     S.last=os.clock()
    else
     S.egFl=S.egFl+1
    end
    setStatus("open "..m)
   end)
  end)
 end)

 auB.MouseButton1Click:Connect(function()
  pcall(function()
   if S.egAuto then
    eggStop("auto off")
    return
   end

   if nb.Text=="" then
    nb.Text=memoGet()
   end

   S.egg=nb.Text
   if S.egg=="" then
    setStatus("select egg")
    return
   end

   memoSet(S.egg)
   setEgg(true,true)
   S.egAuto=true
   S.egOk=0
   S.egFl=0
   S.last=0
   S.iv=2.45

   if auB and auB.Parent then
    auB.Text="STOP"
   end

   setStatus("auto on pace 2.45s")

   if not S.egLoop then
    S.egLoop=true
    T.spawn(eggLoop)
   end
  end)
 end)

 eggB.MouseButton1Click:Connect(function()
  pcall(function()
   setEgg(not AF.egg,true)
  end)
 end)

 minB.MouseButton1Click:Connect(function()
  pcall(function()
   root.Visible=false
   pill.Position=root.Position
   pill.Visible=true
  end)
 end)

 pill.MouseButton1Click:Connect(function()
  pcall(function()
   pill.Visible=false
   root.Visible=true
  end)
 end)

 T.spawn(function()
  while gui and gui.Parent do
   T.wait(1)
   pcall(hud)
  end
 end)

 T.spawn(function()
  while gui and gui.Parent do
   T.wait(0.2)
   if AF.farm or AF.egg then
    local t=th()
    if t then
     pcall(scanFolder,t,120)
    end
    if AF.egg then
     pcall(scanFolder,WS,80)
    end
   end
  end
 end)

 T.spawn(function()
  while gui and gui.Parent do
   T.wait(0.1)
   if VD.on then
    local q=VD.queue
    if #q>0 then
     local taken=0
     local idx=1
     while idx<=#q and taken<80 do
      local i=q[idx]
      if i then
       pcall(voidProcess,i)
       taken=taken+1
      end
      idx=idx+1
     end
     local newn=0
     for i=idx,#q do
      newn=newn+1
      q[newn]=q[i]
     end
     for i=newn+1,#q do
      q[i]=nil
     end
    end
   else
    if #VD.queue>0 then
     VD.queue={}
    end
   end
  end
 end)

 T.spawn(function()
  while gui and gui.Parent do
   T.wait(0.5)
   if AF.egg and not S.egAuto and AF.eggUntil>0 and os.clock()>AF.eggUntil then
    pcall(setEgg,false,false)
   end
  end
 end)

 T.spawn(function()
  while gui and gui.Parent do
   T.wait(3)
   if VD.on then
    pcall(vdAttach)
   end
  end
 end)

 show(1)

 S.pets=pets()
 S.tg=math.max(1,#S.pets)
 slots()

 local mem=memoGet()
 if mem~="" then
  S.egg=mem
  nb.Text=mem
 end

 hud()
 updAF()

 if VD.on then
  vdLightOn()
  vdAttach()
  voidUpd()
  T.spawn(function()
   voidScan(WS,15000)
   voidScan(LIT,4000)
  end)
 else
  vdDetach()
  voidUpd()
 end

 setStatus("ready - plain safe")

 pcall(function()
  if indGui and indGui.Parent then
   indGui:Destroy()
  end
 end)
end)

if not ok then
 warn("PFEVP:",err)
 pcall(function()
  if indLbl and indLbl.Parent then
   indLbl.Size=UDim2.fromOffset(330,90)
   indLbl.Text="PFEVP ERR: "..tostring(err):sub(1,180)
   indLbl.TextColor3=Color3.fromRGB(255,120,130)
  else
   local pg=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui",10)
   if pg then
    local g=Instance.new("ScreenGui")
    g.Name="PFEV_ERR"
    g.ResetOnSpawn=false
    g.DisplayOrder=1000
    g.Parent=pg

    local f=Instance.new("Frame")
    f.Size=UDim2.fromOffset(330,110)
    f.Position=UDim2.new(0,12,0,12)
    f.BackgroundColor3=Color3.fromRGB(26,10,14)
    f.BorderSizePixel=0
    f.Parent=g

    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(1,-14,1,-14)
    t.Position=UDim2.fromOffset(7,7)
    t.BackgroundTransparency=1
    t.Text="PFEVP ERR: "..tostring(err):sub(1,220)
    t.TextColor3=Color3.fromRGB(255,120,130)
    t.TextSize=10
    t.Font=Enum.Font.GothamBold
    t.Parent=f
   end
  end
 end)
end