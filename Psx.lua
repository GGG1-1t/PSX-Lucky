local function isfn(f) return type(f)=="function" end
local T=task
if type(T)~="table" then T={} end
if not isfn(T.spawn) then
 T.spawn=function(f,...)
  if isfn(spawn) then return spawn(f,...) end
  if isfn(create) and isfn(resume) then local c=create(f); resume(c,...); return c end
  return nil
 end
end
if not isfn(T.wait) then T.wait=isfn(wait) and wait or function(s) end end
if not isfn(T.delay) then
 T.delay=function(s,f,...)
  if isfn(delay) then return delay(s,f,...) end
  return T.spawn(function() T.wait(s); if isfn(f) then f(...) end end)
 end
end
if not isfn(T.defer) then T.defer=function(f,...) return T.spawn(f,...) end end

local ok,err=pcall(function()
local PS=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local UIS=game:GetService("UserInputService")
local TW=game:GetService("TweenService")
local RUN=game:GetService("RunService")
local LIT=game:GetService("Lighting")
local lp=PS.LocalPlayer
local pg=lp:WaitForChild("PlayerGui",15)

pcall(function()
 for _,d in ipairs(pg:GetChildren()) do
  if d:IsA("ScreenGui") and (d.Name:find("PFEV") or d.Name:find("PFVOID") or d.Name:find("PFTEST")) then
   d:Destroy()
  end
 end
end)

local function C(r,g,b) return Color3.fromRGB(r,g,b) end
local K={bg=C(14,8,10),pn=C(26,13,17),ov=C(42,20,26),hi=C(60,28,35),red=C(226,28,58),em=C(255,96,40),tx=C(240,222,226),dm=C(152,128,134),gr=C(120,230,120),am=C(255,176,40),ink=C(8,4,5)}

local S={run=false,loop=false,pets={},tg=1,slots={},skip={},gap=0.9,sent=0,brk=0,errs=0,grace=0,idle=0,unst=0,foff=false,cand=0,cf=nil,rf=nil,rf75=nil,egg="",egN=8,egAuto=false,egLoop=false,egOk=0,egFl=0,iv=2.45,last=0,cap=false,fps=0,fr=0,lines={}}
local AF={farm=false,egg=false,eggUntil=0,hideCoins=false,qF={},qE={},conns={},killed=0,hidden=0,light=false,lightUntil=0,events=0,eventT=0}
local GEN=(isfn(getgenv) and getgenv()) or _G
if type(GEN)~="table" then GEN={} end
local VD=GEN.PFVOID
if type(VD)~="table" then VD={} GEN.PFVOID=VD end
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
local oldH,hookOn=nil,false
local cM=setmetatable({},{__mode="k"})
local errL

local function log(x) S.lines[#S.lines+1]=tostring(x) if #S.lines>40 then table.remove(S.lines,1) end end
local function showErr(m)
 log("ERR: "..tostring(m))
 if errL and errL.Parent then errL.Text="ERR: "..tostring(m):sub(1,80) errL.TextColor3=K.red end
 warn("PFEV:",m)
end

local function cor(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=o end
local function stk(o,t) local s=Instance.new("UIStroke") s.Color=K.red s.Thickness=1 s.Transparency=t or 0.5 s.Parent=o end
local function grd(o,a,b,r) local g=Instance.new("UIGradient") g.Color=ColorSequence.new(a,b) g.Rotation=r or 90 g.Parent=o end
local function frm(p,x,y,w,h,c,t) local f=Instance.new("Frame") f.Size=UDim2.fromOffset(w,h) f.Position=UDim2.fromOffset(x,y) f.BackgroundColor3=c or K.pn f.BackgroundTransparency=t or 0 f.BorderSizePixel=0 f.Parent=p return f end
local function lbl(p,x,y,w,h,t,s,c,f,a) local l=Instance.new("TextLabel") l.BackgroundTransparency=1 l.Size=UDim2.fromOffset(w,h) l.Position=UDim2.fromOffset(x,y) l.Text=t l.TextSize=s or 9 l.TextColor3=c or K.tx l.Font=f or Enum.Font.GothamBold l.TextXAlignment=a or Enum.TextXAlignment.Left l.TextYAlignment=Enum.TextYAlignment.Center l.Parent=p return l end
local function btn(p,x,y,w,h,t,c,s,tc)
 local b=Instance.new("TextButton")
 b.Size=UDim2.fromOffset(w,h) b.Position=UDim2.fromOffset(x,y) b.BackgroundColor3=c or K.ov b.Text=t b.TextSize=s or 9 b.Font=Enum.Font.GothamBold b.TextColor3=tc or K.tx b.BorderSizePixel=0 b.AutoButtonColor=false b.ZIndex=6 b.Parent=p
 cor(b) stk(b)
 b.MouseButton1Down:Connect(function() pcall(function() TW:Create(b,TweenInfo.new(0.08),{BackgroundColor3=K.hi}):Play() end) end)
 b.MouseButton1Up:Connect(function() pcall(function() TW:Create(b,TweenInfo.new(0.18),{BackgroundColor3=c or K.ov}):Play() end) end)
 b.MouseLeave:Connect(function() pcall(function() TW:Create(b,TweenInfo.new(0.18),{BackgroundColor3=c or K.ov}):Play() end) end)
 return b
end

local gui=Instance.new("ScreenGui")
gui.Name="PFEVC" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=80 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.Parent=pg

local root=frm(gui,0,0,252,250,K.bg,0)
root.Position=UDim2.new(1,-264,0,60) root.ClipsDescendants=true cor(root,14) stk(root,0.25) grd(root,C(48,10,20),K.bg,130)

local pill=Instance.new("TextButton")
pill.Size=UDim2.fromOffset(116,36) pill.Position=UDim2.new(1,-264,0,60) pill.BackgroundColor3=C(30,12,18) pill.Text="" pill.BorderSizePixel=0 pill.Visible=false pill.AutoButtonColor=false pill.ZIndex=20 pill.Parent=gui
cor(pill,12) stk(pill,0.2) grd(pill,C(90,12,26),C(16,8,10),120)
local function pdot(x,y,w,h,c,r,rot) local f=frm(pill,x,y,w,h,c,0) f.Rotation=rot or 0 cor(f,r or 2) return f end
pdot(12,14,7,6,C(255,235,235),3) pdot(23,14,7,6,C(255,235,235),3) pdot(11,11,9,2,K.ink,1,22) pdot(22,11,9,2,K.ink,1,-22) pdot(15,23,8,3,K.ink,1)
grd(lbl(pill,38,0,70,36,"EVIL PETS",10,K.tx,Enum.Font.GothamBlack),K.red,K.em,0)

local hd=frm(root,0,0,252,32,K.pn,0.1) hd.ZIndex=5 hd.Active=true cor(hd,14) frm(hd,0,31,252,1,K.red,0.35)
grd(lbl(hd,8,3,150,15,"EVIL PETS",13,K.tx,Enum.Font.GothamBlack),K.red,K.em,0)
lbl(hd,8,18,190,10,"safe build - void - capture",7,K.dm,Enum.Font.GothamMedium)
local minB=btn(hd,222,6,22,20,"-",K.ov,12)

local tab=frm(root,8,38,236,22,K.pn,0.2) tab.ZIndex=5 cor(tab,8)
local ind=frm(tab,2,18,116,3,K.red,0) ind.ZIndex=7 cor(ind,2)
local tb={}
for i,n in ipairs({"FARM","EGGS"}) do
 local b=Instance.new("TextButton")
 b.Size=UDim2.fromOffset(118,20) b.Position=UDim2.fromOffset(1+(i-1)*118,1) b.BackgroundTransparency=1 b.Text=n b.TextSize=10 b.Font=Enum.Font.GothamBold b.TextColor3=(i==1) and K.tx or K.dm b.BorderSizePixel=0 b.AutoButtonColor=false b.ZIndex=6 b.Parent=tab
 tb[i]=b
end

local p1=frm(root,8,64,236,150,K.bg,1) p1.ZIndex=4
local p2=frm(root,8,64,236,150,K.bg,1) p2.ZIndex=4 p2.Visible=false
errL=lbl(root,8,216,236,12,"",7,K.dm,Enum.Font.Code)

local foot=frm(root,8,230,236,18,K.pn,0.25) foot.ZIndex=5 cor(foot,7)
local dot=frm(foot,7,6,6,6,K.gr,0) cor(dot,3)
local stt=lbl(foot,18,0,178,18,"boot",8,K.dm,Enum.Font.Code)

local startB=btn(p1,0,0,236,34,"START FARM",K.red,14,K.ink) grd(startB,K.red,K.em,0)
local sub=lbl(p1,0,34,236,12,"",8,K.dm,Enum.Font.Code,Enum.TextXAlignment.Center)
local row=frm(p1,0,48,236,24,K.pn,0.25) cor(row,8) stk(row,0.7)
lbl(row,8,0,40,24,"PETS",8,K.dm)
local mn=btn(row,52,2,26,20,"-",K.ov,12)
local pv=lbl(row,80,0,74,24,"1 / 1",11,K.tx,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
local pl=btn(row,156,2,26,20,"+",K.ov,12)
local mx=btn(row,186,2,44,20,"MAX",K.ov,8)
local stat=lbl(p1,0,74,236,40,"",8,K.dm,Enum.Font.Code) stat.TextYAlignment=Enum.TextYAlignment.Top stat.TextWrapped=true
local farmB=btn(p1,0,116,114,22,"FARM FX OFF",K.ov,8)
local hideB=btn(p1,122,116,114,22,"HIDE COINS OFF",K.ov,8)
local voidB=btn(p1,0,140,114,22,"VOID OFF",K.ov,8)
local voidC=btn(p1,122,140,114,22,"VOID SCAN",K.ov,8)

local nb=Instance.new("TextBox")
nb.Size=UDim2.fromOffset(236,24) nb.Position=UDim2.fromOffset(0,0) nb.BackgroundColor3=K.pn nb.Text="" nb.PlaceholderText="egg name or CAPTURE" nb.PlaceholderColor3=K.dm nb.TextSize=9 nb.Font=Enum.Font.GothamBold nb.TextColor3=K.tx nb.ClearTextOnFocus=false nb.BorderSizePixel=0 nb.ZIndex=6 nb.TextXAlignment=Enum.TextXAlignment.Left nb.Parent=p2
cor(nb,8) stk(nb,0.6)
local npd=Instance.new("UIPadding") npd.PaddingLeft=UDim.new(0,8) npd.Parent=nb
local capB=btn(p2,0,28,236,22,"CAPTURE",K.ov,8,K.am)
local n1=btn(p2,0,54,76,20,"1",K.ov,9)
local n3=btn(p2,80,54,76,20,"3",K.ov,9)
local n8=btn(p2,160,54,76,20,"8",K.red,9,K.ink)
local opB=btn(p2,0,78,114,28,"OPEN",K.ov,11)
local auB=btn(p2,122,78,114,28,"AUTO",K.red,11,K.ink) grd(auB,K.red,K.em,0)
local est=lbl(p2,0,110,236,30,"",8,K.dm,Enum.Font.Code) est.TextYAlignment=Enum.TextYAlignment.Top est.TextWrapped=true
local eggB=btn(p2,0,142,236,22,"EGG FX OFF",K.ov,8)

local function low(s) return tostring(s):lower() end
local function getPath(i) if not i then return "?" end local o,s=pcall(function() return i:GetFullName() end) return o and tostring(s) or "?" end
local function ownPath(p) return p:find("pfevc",1,true)~=nil end
local function isChar(i) local ok,ch=pcall(function() return lp.Character end) if not ok or not ch then return false end local ok2,res=pcall(function() return i==ch or i:IsDescendantOf(ch) end) return ok2 and res==true end
local function prop(i,p) local o,v=pcall(function() return i[p] end) return o,v end

local VD_OFF={ParticleEmitter=true,Trail=true,Sparkles=true,Fire=true,Smoke=true,Beam=true,PointLight=true,SpotLight=true,SurfaceLight=true,Sound=true,BillboardGui=true,SurfaceGui=true,ColorCorrection=true,Blur=true,DepthOfField=true,Bloom=true,SunRays=true}
local VD_TRANS={Decal=true,Texture=true}
local SKY_PROPS={"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp","EqTexture","SunTexture","MoonTexture","StarsTexture"}

local function voidUpd()
 voidB.Text=VD.on and "VOID ON" or "VOID OFF"
 voidB.BackgroundColor3=VD.on and K.gr or K.ov
 voidB.TextColor3=VD.on and K.ink or K.tx
end
local function vdSave(i,d) if not i or VD.saved[i] then return end VD.saved[i]=d VD.arr[#VD.arr+1]=i if #VD.arr>70000 then local old=table.remove(VD.arr,1) VD.saved[old]=nil end end
local function vdDisable(i)
 if not i then return end
 local okp,parent=pcall(function() return i.Parent end) if not okp or not parent then return end
 if i:IsA("Sound") then
  local ov,vol=prop(i,"Volume") local op,play=prop(i,"Playing")
  vdSave(i,{k="snd",v=ov and vol or 0.5,p=op and play or false})
  pcall(function() i.Volume=0 i.Playing=false end) VD.hidden=VD.hidden+1 return
 end
 if VD_TRANS[i.ClassName] then
  local ot,tr=prop(i,"Transparency")
  if ot then vdSave(i,{k="tr",v=tr}) pcall(function() i.Transparency=1 end) VD.hidden=VD.hidden+1 end
  return
 end
 local oe,en=prop(i,"Enabled")
 if oe then vdSave(i,{k="en",v=en}) pcall(function() i.Enabled=false end) VD.hidden=VD.hidden+1 end
end
local function vdPart(p)
 if not p then return end
 local okp,parent=pcall(function() return p.Parent end) if not okp or not parent then return end
 local ot,t=prop(p,"Transparency") if not ot then return end
 local ocs,cs=prop(p,"CastShadow") local orf,rf=prop(p,"Reflectance") local om,mt=prop(p,"Material")
 local csVal=true if ocs then csVal=cs end
 local rfVal=0 if orf then rfVal=rf end
 local mtVal=Enum.Material.Plastic if om then mtVal=mt end
 local tex if p:IsA("MeshPart") then local otx,x=prop(p,"TextureId") if otx then tex=x end end
 vdSave(p,{k="p",t=t,cs=csVal,rf=rfVal,mt=mtVal,tex=tex})
 pcall(function()
  p.Transparency=1
  if ocs then p.CastShadow=false end
  if orf then p.Reflectance=0 end
  if om then p.Material=Enum.Material.Plastic end
  if p:IsA("MeshPart") and tex~=nil then p.TextureId="" end
 end)
 VD.plast=VD.plast+1
end
local function vdTerrain(t)
 local ow,wt=prop(t,"WaterTransparency") local or,wr=prop(t,"WaterReflectance") local os,ws=prop(t,"WaterWaveSpeed")
 if not (ow or or or os) then return end
 vdSave(t,{k="terr",wt=ow and wt or 0,wr=or and wr or 0,ws=os and ws or 0})
 pcall(function() if ow then t.WaterTransparency=1 end if or then t.WaterReflectance=0 end if os then t.WaterWaveSpeed=0 end end)
 VD.hidden=VD.hidden+1
end
local function vdSky(s)
 local d={k="sky",vals={}}
 for _,p in ipairs(SKY_PROPS) do local o,v=prop(s,p) if o and typeof(v)=="string" then d.vals[p]=v pcall(function() s[p]="" end) end end
 if next(d.vals) then vdSave(s,d) VD.hidden=VD.hidden+1 end
end
local function vdAtmos(a) local o,d=prop(a,"Density") if o then vdSave(a,{k="atm",d=d}) pcall(function() a.Density=0 end) VD.hidden=VD.hidden+1 end end
local function voidProcess(i)
 if not VD.on or not i then return end
 local okp,parent=pcall(function() return i.Parent end) if not okp or not parent then return end
 if isChar(i) then return end
 local p=low(getPath(i)) if ownPath(p) or p:find("currentcamera",1,true) then return end
 local cls=i.ClassName
 if cls=="Terrain" then vdTerrain(i) return end
 if i:IsA("BasePart") then vdPart(i) return end
 if cls=="Sky" then vdSky(i) return end
 if cls=="Atmosphere" then vdAtmos(i) return end
 if VD_OFF[cls] or VD_TRANS[cls] then vdDisable(i) end
end
local function voidScan(r,limit)
 if not r or not VD.on or limit<=0 then return end
 local stack={r} local n=0
 while #stack>0 and n<limit and VD.on do
  local x=table.remove(stack) n=n+1
  if x then
   voidProcess(x)
   if not isChar(x) and x.ClassName~="BillboardGui" and x.ClassName~="SurfaceGui" then
    local ok,ch=pcall(function() return x:GetChildren() end)
    if ok and ch then for i=#ch,1,-1 do stack[#stack+1]=ch[i] end end
   end
  end
  if n%2000==0 then T.wait(0) end
 end
end
local function vdLightOn()
 if VD.light then return end
 local oBr,br=prop(LIT,"Brightness") local oAm,am=prop(LIT,"Ambient") local oOa,oa=prop(LIT,"OutdoorAmbient")
 local oEds,eds=prop(LIT,"EnvironmentDiffuseScale") local oEss,ess=prop(LIT,"EnvironmentSpecularScale") local oGs,gs=prop(LIT,"GlobalShadows")
 local gsVal=true if oGs then gsVal=gs end
 VD.light={br=oBr and br or 2,am=oAm and am or Color3.new(0.5,0.5,0.5),oa=oOa and oa or Color3.new(0.5,0.5,0.5),eds=oEds and eds or 1,ess=oEss and ess or 1,gs=gsVal}
 pcall(function() LIT.Brightness=0 LIT.Ambient=Color3.new(0,0,0) LIT.OutdoorAmbient=Color3.new(0,0,0) LIT.EnvironmentDiffuseScale=0 LIT.EnvironmentSpecularScale=0 LIT.GlobalShadows=false end)
end
local function vdLightRestore()
 if not VD.light then return end
 local d=VD.light
 pcall(function() LIT.Brightness=d.br LIT.Ambient=d.am LIT.OutdoorAmbient=d.oa LIT.EnvironmentDiffuseScale=d.eds LIT.EnvironmentSpecularScale=d.ess LIT.GlobalShadows=d.gs end)
 VD.light=nil
end
local function vdDetach()
 if VD.conns.ws then pcall(function() VD.conns.ws:Disconnect() end) VD.conns.ws=nil end
 if VD.conns.lit then pcall(function() VD.conns.lit:Disconnect() end) VD.conns.lit=nil end
end
local function vdAttach()
 vdDetach() if not VD.on then return end
 local o1,c1=pcall(function() return WS.DescendantAdded:Connect(function(d) if VD.on and #VD.queue<5000 then table.insert(VD.queue,d) end end) end)
 if o1 then VD.conns.ws=c1 end
 local o2,c2=pcall(function() return LIT.DescendantAdded:Connect(function(d) if VD.on and #VD.queue<5000 then table.insert(VD.queue,d) end end) end)
 if o2 then VD.conns.lit=c2 end
end
local function vdRestore()
 VD.on=false vdDetach()
 for i=#VD.arr,1,-1 do
  local inst=VD.arr[i] local d=inst and VD.saved[inst]
  if inst and d then
   local okp,parent=pcall(function() return inst.Parent end)
   if okp and parent then
    if d.k=="p" then pcall(function() inst.Transparency=d.t if d.cs~=nil then inst.CastShadow=d.cs end if d.rf~=nil then inst.Reflectance=d.rf end if d.mt then inst.Material=d.mt end if inst:IsA("MeshPart") and d.tex~=nil then inst.TextureId=d.tex end end)
    elseif d.k=="en" then pcall(function() inst.Enabled=d.v end)
    elseif d.k=="snd" then pcall(function() inst.Volume=d.v inst.Playing=d.p end)
    elseif d.k=="tr" then pcall(function() inst.Transparency=d.v end)
    elseif d.k=="terr" then pcall(function() inst.WaterTransparency=d.wt inst.WaterReflectance=d.wr inst.WaterWaveSpeed=d.ws end)
    elseif d.k=="sky" then for p,v in pairs(d.vals) do pcall(function() inst[p]=v end) end
    elseif d.k=="atm" then pcall(function() inst.Density=d.d end)
    end
   end
  end
  VD.saved[inst]=nil VD.arr[i]=nil
 end
 VD.arr={} VD.saved=setmetatable({},{__mode="k"}) VD.queue={} VD.hidden=0 VD.plast=0 VD.busy=false
 vdLightRestore() voidUpd()
end
local function setVoid(on)
 if on==VD.on then return end
 if on then
  VD.on=true vdLightOn() vdAttach() voidUpd()
  if not VD.busy then VD.busy=true T.spawn(function() voidScan(WS,25000) voidScan(LIT,6000) VD.busy=false if VD.on then stt.Text="void scan done" end end) end
 else
  vdRestore()
 end
end

local DESTROY={ParticleEmitter=true,Trail=true,Sparkles=true,Fire=true,Smoke=true,Beam=true,Decal=true,Texture=true,PointLight=true,SpotLight=true,SurfaceLight=true,Sound=true}
local DISABLE={BillboardGui=true,SurfaceGui=true}
local EPAT={"egg","reward","hatch","open","preview","spawn","effect","fx","particle","trail","beam","burst","confetti","flash","glow","shine","spark","pop","boom","blast","impact","hit","damage","bonus","billboard","coin particle","orb","loot","debris","break","broken"}
local function petPath(p) return p:find("__things.pets",1,true)~=nil or p:find(".pets.",1,true)~=nil end
local function protPath(p) return p:find("playergui",1,true)~=nil or p:find("character",1,true)~=nil or p:find("__map",1,true)~=nil end
local function skipPath(p) return protPath(p) or petPath(p) or ownPath(p) end
local function matchAny(s,list) s=low(s) for _,x in ipairs(list) do if s:find(x,1,true) then return true end end return false end
local function th() return WS:FindFirstChild("__THINGS") end
local function eggish(i)
 local p=low(getPath(i)) if skipPath(p) then return false end
 if p:find("__things.coins",1,true) or p:find("__things.orbs",1,true) or p:find("__things.lootbags",1,true) then return false end
 return DESTROY[i.ClassName] or DISABLE[i.ClassName] or matchAny(i.Name,EPAT) or matchAny(p,EPAT)
end
local function noteEvent()
 local now=os.clock()
 if now-AF.eventT>0.25 then AF.eventT=now AF.events=0 end
 AF.events=AF.events+1
 if AF.events>35 then AF.light=true AF.lightUntil=now+1.2 end
 if AF.light and now>AF.lightUntil then AF.light=false end
end
local function destroyEffect(i)
 if VD.on then vdDisable(i) return end
 pcall(function() if i.Enabled~=nil then i.Enabled=false end if i:IsA("Sound") then i.Volume=0 i.Playing=false end end)
 pcall(function() i:Destroy() end) AF.killed=AF.killed+1
end
local function disableGui(i) if VD.on then vdDisable(i) return end pcall(function() i.Enabled=false end) AF.hidden=AF.hidden+1 end
local function hidePart(i) if VD.on then vdPart(i) return end pcall(function() i.Transparency=1 i.CastShadow=false end) AF.hidden=AF.hidden+1 end
local function shouldHide(i,src,p)
 if src=="DEBRIS" or src=="CAM" or src=="LG" or src=="ORB" or src=="LOOT" then return true end
 if src=="COIN" then if not AF.hideCoins then return false end return i:IsA("MeshPart") or low(i.Name):find("coin",1,true)~=nil end
 if src=="EWS" or src=="ETH" then return matchAny(i.Name,EPAT) or matchAny(p,EPAT) end
 return false
end
local function processTree(top,src)
 if not top or not top.Parent then return end
 local tp=low(getPath(top)) if skipPath(tp) then return end
 if src=="EWS" or src=="ETH" then
  local nm=top.Name
  if nm=="Coins" or nm=="Orbs" or nm=="Lootbags" or nm=="Pets" or nm=="__DEBRIS" or nm=="__MAP" or nm=="CurrentCamera" or nm=="__THINGS" then return end
  if not eggish(top) then return end
 end
 local stack={top} local n=0 local lim=AF.light and 90 or 140
 while #stack>0 and n<lim do
  local x=table.remove(stack) n=n+1
  if x and x.Parent then
   local p=low(getPath(x))
   if not skipPath(p) then
    local cls=x.ClassName
    if DESTROY[cls] then destroyEffect(x)
    elseif DISABLE[cls] then disableGui(x)
    else
     if x:IsA("BasePart") and shouldHide(x,src,p) then hidePart(x) end
     if cls~="BillboardGui" and cls~="SurfaceGui" then
      local ok,ch=pcall(function() return x:GetChildren() end)
      if ok and ch then for i=#ch,1,-1 do stack[#stack+1]=ch[i] end end
     end
    end
   end
  end
 end
end
local function push(q,item,max) if #q>=max then table.remove(q,1) end table.insert(q,item) end
local function enqueue(i,src)
 if not i or not i.Parent then return end
 if src=="COIN" and not AF.farm then return end
 if (src=="EWS" or src=="ETH") and not AF.egg then return end
 if (src=="ORB" or src=="LOOT" or src=="DEBRIS" or src=="CAM" or src=="LG") and not (AF.farm or AF.egg) then return end
 noteEvent()
 if src=="COIN" then push(AF.qF,{i,src},1200)
 elseif src=="EWS" or src=="ETH" then push(AF.qE,{i,src},900)
 elseif AF.farm then push(AF.qF,{i,src},1200)
 else push(AF.qE,{i,src},900) end
end
local function srcParent(src)
 local t=th()
 if src=="COIN" then return t and t:FindFirstChild("Coins") end
 if src=="ORB" then return t and t:FindFirstChild("Orbs") end
 if src=="LOOT" then return t and t:FindFirstChild("Lootbags") end
 if src=="DEBRIS" then return WS:FindFirstChild("__DEBRIS") end
 if src=="CAM" then return WS.CurrentCamera end
 if src=="LG" then return LIT end
 if src=="EWS" then return WS end
 if src=="ETH" then return t end
end
local function wantSrc(src)
 if src=="COIN" then return AF.farm end
 if src=="EWS" or src=="ETH" then return AF.egg end
 return AF.farm or AF.egg
end
local function detach(src) local o=AF.conns[src] if o then pcall(function() o.c:Disconnect() end) AF.conns[src]=nil end end
local function attach(src)
 detach(src) if not wantSrc(src) then return end
 local p=srcParent(src) if not p then return end
 local ok,c=pcall(function() return p.ChildAdded:Connect(function(ch) enqueue(ch,src) end) end)
 if ok then AF.conns[src]={c=c,p=p} end
end
local function refresh()
 for _,src in ipairs({"COIN","ORB","LOOT","DEBRIS","CAM","LG","EWS","ETH"}) do
  local o=AF.conns[src] local p=srcParent(src)
  if not wantSrc(src) then if o then detach(src) end
  else
   local ok,connected=pcall(function() return o and o.c and o.c.Connected and o.p==p end)
   if not (ok and connected) then attach(src) end
  end
 end
end
local function queueSrc(src,lim)
 if not wantSrc(src) then return end
 local p=srcParent(src) if not p then return end
 local ok,ch=pcall(function() return p:GetChildren() end)
 if ok and ch then for i=1,math.min(#ch,lim or 120) do enqueue(ch[i],src) end end
end
local function queueAll() queueSrc("COIN",220) queueSrc("ORB",160) queueSrc("LOOT",120) queueSrc("DEBRIS",220) queueSrc("CAM",90) queueSrc("LG",90) queueSrc("EWS",80) queueSrc("ETH",80) end
local function drain(q,cap)
 local taken=0 local idx=1
 while idx<=#q and taken<cap do
  local item=q[idx]
  if item and item[1] and item[1].Parent then processTree(item[1],item[2]) taken=taken+1 end
  idx=idx+1
 end
 local newn=0
 for i=idx,#q do newn=newn+1 q[newn]=q[i] end
 for i=newn+1,#q do q[i]=nil end
end
local function updAF()
 farmB.Text=AF.farm and "FARM FX ON" or "FARM FX OFF" farmB.BackgroundColor3=AF.farm and K.red or K.ov farmB.TextColor3=AF.farm and K.ink or K.tx
 hideB.Text=AF.hideCoins and "HIDE COINS ON" or "HIDE COINS OFF" hideB.BackgroundColor3=AF.hideCoins and K.em or K.ov hideB.TextColor3=AF.hideCoins and K.ink or K.tx
 eggB.Text=AF.egg and "EGG FX ON" or "EGG FX OFF" eggB.BackgroundColor3=AF.egg and K.am or K.ov eggB.TextColor3=AF.egg and K.ink or K.tx
 voidUpd()
end
local function setFarm(on) AF.farm=on if on then queueAll() end refresh() updAF() stt.Text=on and "farm fx on" or "farm fx off" end
local function setEgg(on,persist) AF.egg=on AF.eggUntil=(on and not persist) and (os.clock()+8) or 0 if on then queueAll() end refresh() updAF() stt.Text=on and (persist and "egg fx on" or "egg fx 8s") or "egg fx off" end

local function byRF(n) local c=0 for _,d in ipairs(RS:GetChildren()) do if d:IsA("RemoteFunction") then c=c+1 if c==n then return d end end end end
S.rf=byRF(10) S.rf75=byRF(75)
local function fold() if S.cf and S.cf.Parent then return S.cf end local t=th() S.cf=t and t:FindFirstChild("Coins") return S.cf end
local function coins() local f=fold() return f and #f:GetChildren() or 0 end
local function alive(c) if not c or not c.Parent then return false end if c:GetAttribute("IsFalling")==true then return false end local h=tonumber(c:GetAttribute("Health")) if h and h<=0 then return false end return true end
local function meta(c) local m=cM[c] if not m then local i=c:GetAttribute("ID") m={id=(typeof(i)=="string" and i~="" and i) or nil} cM[c]=m end return m end
local function boot()
 if Lib then return true end
 local o,r=pcall(function() return require(RS:WaitForChild("Library",10)) end)
 if not o or typeof(r)~="table" then return false end
 Lib=r
 local t=os.clock()
 while not Lib.Loaded and os.clock()-t<10 do T.wait(0.2) end
 return true
end
local function save() if not Lib then return nil end local o,v=pcall(function() return Lib.Save.Get() end) if o and typeof(v)=="table" then return v end end
local function pets()
 local s=save() local eq={} local lim=0
 if s then
  lim=tonumber(s.MaxEquipped) or 0
  if typeof(s.Pets)=="table" then for _,p in pairs(s.Pets) do if typeof(p)=="table" and p.e==true and typeof(p.uid)=="string" then eq[#eq+1]=p.uid end end end
 end
 if #eq==0 then
  local t=th() local f=t and t:FindFirstChild("Pets")
  if f then for _,p in ipairs(f:GetChildren()) do local i=p:GetAttribute("ID") or p.Name if typeof(i)=="string" and i:sub(1,2)=="id" then eq[#eq+1]=i end end end
 end
 table.sort(eq)
 local cap=math.clamp(math.max(lim,#eq),1,80) local out={}
 for i=1,math.min(cap,#eq) do out[#out+1]=eq[i] end
 return out
end
local function slots()
 S.tg=math.clamp(S.tg,1,math.max(1,#S.pets)) S.slots={} pv.Text=S.tg.." / "..math.max(1,#S.pets)
 if #S.pets<1 then return end
 local per=math.ceil(#S.pets/S.tg) local i=1 local now=os.clock()
 for n=1,S.tg do
  local g={}
  for _=1,per do if i<=#S.pets then g[#g+1]=S.pets[i] i=i+1 end end
  if #g>0 then S.slots[#S.slots+1]={g=g,cur=nil,next=now+(n-1)*0.18} end
 end
end
local function cands(used)
 local f=fold() if not f then return {} end
 local now=os.clock() local k=f:GetChildren() local out={}
 for i=1,#k do
  local c=k[i]
  if c and c.Parent then
   local m=meta(c) local id=m.id
   if id and not used[id] and not (S.skip[id] and S.skip[id]>now) then
    local h=tonumber(c:GetAttribute("Health"))
    if (not h or h>0) and c:GetAttribute("IsFalling")~=true then out[#out+1]={c=c,id=id,hp=h or 999999} end
   end
  end
 end
 table.sort(out,function(a,b) return a.hp<b.hp end)
 return out
end
local function memoSet(e) e=tostring(e or "") if e=="" then return end S.egg=e if nb and nb.Parent then nb.Text=e end pcall(function() if isfn(getgenv) then getgenv().EvilPetsEgg=e end end) end
local function memoGet() local e pcall(function() if isfn(getgenv) then e=getgenv().EvilPetsEgg end end) return typeof(e)=="string" and e or "" end
local function installHook()
 if hookOn then return true end
 if not isfn(hookmetamethod) or not isfn(getnamecallmethod) then return false end
 local o=pcall(function()
  oldH=hookmetamethod(game,"__namecall",function(self,...)
   if typeof(self)=="Instance" then
    local oc,cls=pcall(function() return self.ClassName end)
    if oc and cls=="RemoteFunction" then
     local om,m=pcall(function() return getnamecallmethod() end)
     if om and (m=="InvokeServer" or m=="InvokeClient") then
      local a={...}
      if typeof(a[1])=="string" and typeof(a[2])=="number" then
       local s=low(a[1])
       if S.cap or s:find("egg",1,true) or s:find("open",1,true) or s:find("hatch",1,true) then
        pcall(function()
         memoSet(a[1])
         if S.cap then S.cap=false capB.Text="CAPTURE" capB.TextColor3=K.am stt.Text="captured "..a[1] end
        end)
       end
      end
     end
    end
   end
   if oldH then return oldH(self,...) end
  end)
 end)
 if o and oldH then hookOn=true return true end
 return false
end
local function eggCall()
 if not S.egg or S.egg=="" then S.egg=nb.Text or memoGet() end
 if not S.egg or S.egg=="" then return false,"no egg" end
 memoSet(S.egg)
 if not S.rf75 or not S.rf75.Parent then S.rf75=byRF(75) end
 if not S.rf75 then return false,"no RF75" end
 local o,a,b=pcall(function() return S.rf75:InvokeServer(S.egg,S.egN) end)
 if not o then return false,"err" end
 if a==true then return true,"true" end
 if typeof(a)=="table" then return true,"t"..#a end
 return false,tostring(b or a)
end
local function eggStop(m) S.egAuto=false auB.Text="AUTO" setEgg(false,false) if m then log(m) end end
local function eggLoop()
 while S.egAuto and gui.Parent do
  S.egg=nb.Text or S.egg or memoGet()
  if S.egg=="" then eggStop("no name") break end
  memoSet(S.egg)
  if S.iv<0.8 then S.iv=0.8 end
  local w=S.iv-(os.clock()-S.last) if w>0 then T.wait(w) end
  if not S.egAuto then break end
  local o,m=eggCall()
  if o then S.last=os.clock() S.egOk=S.egOk+1 S.egFl=0 S.iv=math.max(0.8,S.iv-0.02)
  else
   S.egFl=S.egFl+1
   if m:find("quickly",1,true) then S.iv=math.min(4,S.iv+0.15) else S.iv=math.min(4,S.iv+0.3) end
   if S.egFl>=12 then eggStop("12 rejects") break end
   T.wait(0.2)
  end
 end
 S.egLoop=false
end
local function stopF(m) S.run=false S.slots={} S.skip={} S.idle=0 startB.Text="START FARM" sub.Text="" setFarm(false) stt.Text=m or "stopped" log(m or "stop") end
local function tick()
 if os.clock()<S.grace then return "grace" end
 if not S.rf or not S.rf.Parent then S.rf=byRF(10) end
 if not S.rf then return "no RF10" end
 if #S.pets<1 then S.pets=pets() slots() end
 if #S.slots~=S.tg then slots() end
 if #S.slots<1 then return "no pets" end
 local f=fold() if not f then return "no coins" end
 local tot=#f:GetChildren() if tot==0 then return "no coins" end
 local now=os.clock()
 for _,sl in ipairs(S.slots) do
  if sl.cur then
   if not alive(sl.cur.p) then S.brk=S.brk+1 sl.cur=nil sl.next=now+S.gap
   else
    local h=tonumber(sl.cur.p:GetAttribute("Health"))
    if h and sl.cur.hp and h<sl.cur.hp then sl.cur.hp=h sl.cur.hit=now end
    if now-sl.cur.hit>8 or now-sl.cur.born>22 then S.skip[sl.cur.id]=now+8 sl.cur=nil sl.next=now+0.4 end
   end
  end
 end
 local used={} for _,sl in ipairs(S.slots) do if sl.cur then used[sl.cur.id]=true end end
 local list=cands(used) S.cand=#list local li=1
 for _,sl in ipairs(S.slots) do
  if not sl.cur and now>=sl.next then
   local e=list[li]
   if e then
    li=li+1
    local o,r=pcall(function() return S.rf:InvokeServer(e.id,sl.g) end)
    S.sent=S.sent+1
    if o and typeof(r)=="table" then S.errs=0 else S.errs=S.errs+1 end
    sl.cur={p=e.c,id=e.id,hp=e.hp,hit=now,born=now} sl.next=now+S.gap
   else sl.next=now+0.4 end
  end
 end
 local a=0 for _,sl in ipairs(S.slots) do if sl.cur then a=a+1 end end
 if a==0 and #list==0 then
  S.idle=S.idle+0.25
  if S.idle>=4 and S.unst<1 then S.unst=1 S.skip={} end
  if S.idle>=8 and S.unst<2 then S.unst=2 S.foff=true log("filter off") end
  if S.idle>=20 then stopF("no targets 20s") return "stop" end
 else S.idle=0 S.unst=0 end
 if S.errs>=40 then stopF("rejects") return "stop" end
 if S.sent>=220 and S.brk==0 then stopF("no damage") return "stop" end
 return ("farm a=%d c=%d q=%d/%d void=%s"):format(a,tot,#AF.qF,#AF.qE,VD.on and "on" or "off")
end
local function startLoop()
 if S.loop then return end
 S.loop=true
 T.spawn(function()
  while S.run and gui.Parent do
   local o,m=pcall(tick)
   stt.Text=o and tostring(m) or "err"
   T.wait(0.25)
  end
  S.loop=false
 end)
end
local function show(n)
 p1.Visible=(n==1) p2.Visible=(n==2)
 for i=1,2 do tb[i].TextColor3=(i==n) and K.tx or K.dm end
 pcall(function() TW:Create(ind,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=UDim2.fromOffset(1+(n-1)*118,18)}):Play() end)
 if n==2 then local mem=memoGet() if mem~="" then nb.Text=mem end end
end
local function hud()
 local a=0 for _,sl in ipairs(S.slots) do if sl.cur then a=a+1 end end
 stat.Text=("breaks %d sent %d active %d\ncoins %d targets %d fps %d\npets %d/%d q %d/%d\nvoid %s hid %d plast %d"):format(S.brk,S.sent,a,coins(),S.cand,S.fps,S.tg,math.max(1,#S.pets),#AF.qF,#AF.qE,VD.on and "ON" or "off",VD.hidden,VD.plast)
 stat.TextColor3=(S.cand>0 or not S.run) and K.dm or K.am
 est.Text=("egg %s\nok %d rej %d pace %.2fs\nfarm=%s egg=%s hide=%s void=%s"):format(tostring(S.egg or "-"),S.egOk,S.egFl,S.iv,tostring(AF.farm),tostring(AF.egg),tostring(AF.hideCoins),tostring(VD.on))
 pv.Text=S.tg.." / "..math.max(1,#S.pets)
 dot.BackgroundColor3=S.run and K.gr or K.dm
end

startB.MouseButton1Click:Connect(function()
 if S.run then stopF("stopped") return end
 S.pets=pets()
 if #S.pets<1 then stt.Text="no pets" return end
 slots()
 S.run=true S.skip={} S.sent=0 S.brk=0 S.errs=0 S.idle=0 S.unst=0 S.foff=false S.grace=os.clock()+1
 startB.Text="STOP FARM" sub.Text=("targets %d gap %.2fs farm fx on"):format(S.tg,S.gap)
 setFarm(true) startLoop()
end)
mn.MouseButton1Click:Connect(function() S.tg=math.max(1,S.tg-1) slots() end)
pl.MouseButton1Click:Connect(function() S.pets=pets() S.tg=math.min(math.max(1,#S.pets),S.tg+1) slots() end)
mx.MouseButton1Click:Connect(function() S.pets=pets() S.tg=math.max(1,#S.pets) slots() end)
farmB.MouseButton1Click:Connect(function() setFarm(not AF.farm) end)
hideB.MouseButton1Click:Connect(function() AF.hideCoins=not AF.hideCoins updAF() if AF.hideCoins and AF.farm then queueSrc("COIN",220) end stt.Text=AF.hideCoins and "hide coins on" or "hide coins off" end)
voidB.MouseButton1Click:Connect(function() setVoid(not VD.on) stt.Text=VD.on and "void on - world hidden" or "void off - restore" end)
voidC.MouseButton1Click:Connect(function()
 if not VD.on then setVoid(true) return end
 if VD.busy then stt.Text="void busy" return end
 VD.busy=true T.spawn(function() voidScan(WS,25000) voidScan(LIT,6000) VD.busy=false stt.Text="void scan done" end)
end)
capB.MouseButton1Click:Connect(function()
 if S.cap then S.cap=false capB.Text="CAPTURE" capB.TextColor3=K.am stt.Text="capture off" return end
 if not installHook() then stt.Text="no hook api" return end
 S.cap=true capB.Text="LISTENING..." capB.TextColor3=K.gr stt.Text="capture on - open egg"
end)
local function setN(v,b) S.egN=v for _,x in ipairs({n1,n3,n8}) do x.BackgroundColor3=K.ov x.TextColor3=K.tx end b.BackgroundColor3=K.red b.TextColor3=K.ink end
n1.MouseButton1Click:Connect(function() setN(1,n1) end)
n3.MouseButton1Click:Connect(function() setN(3,n3) end)
n8.MouseButton1Click:Connect(function() setN(8,n8) end)
opB.MouseButton1Click:Connect(function()
 if nb.Text=="" then nb.Text=memoGet() end
 S.egg=nb.Text memoSet(S.egg) setEgg(true,false)
 T.spawn(function() local o,m=eggCall() if o then S.egOk=S.egOk+1 S.last=os.clock() else S.egFl=S.egFl+1 end stt.Text="open "..m end)
end)
auB.MouseButton1Click:Connect(function()
 if S.egAuto then eggStop("auto off") return end
 if nb.Text=="" then nb.Text=memoGet() end
 S.egg=nb.Text
 if S.egg=="" then stt.Text="select egg" return end
 memoSet(S.egg) setEgg(true,true) S.egAuto=true S.egOk=0 S.egFl=0 S.last=0 S.iv=2.45 auB.Text="STOP" stt.Text="auto on pace 2.45s"
 if not S.egLoop then S.egLoop=true T.spawn(eggLoop) end
end)
eggB.MouseButton1Click:Connect(function() setEgg(not AF.egg,true) end)
minB.MouseButton1Click:Connect(function()
 pcall(function() TW:Create(root,TweenInfo.new(0.16),{Size=UDim2.fromOffset(252,0)}):Play() end)
 T.delay(0.18,function()
  if not gui.Parent then return end
  root.Visible=false
  pill.Position=UDim2.new(root.Position.X.Scale,root.Position.X.Offset,root.Position.Y.Scale,root.Position.Y.Offset)
  pill.Visible=true pill.Size=UDim2.fromOffset(0,36)
  pcall(function() TW:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(116,36)}):Play() end)
 end)
end)
pill.MouseButton1Click:Connect(function()
 pill.Visible=false root.Visible=true root.Size=UDim2.fromOffset(252,0)
 pcall(function() TW:Create(root,TweenInfo.new(0.26,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(252,250)}):Play() end)
end)

local d1,s1,f1=false,nil,nil
local d2,s2,f2=false,nil,nil
hd.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d1=true s1=i.Position f1=root.Position end end)
pill.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2=true s2=i.Position f2=pill.Position end end)
UIS.InputChanged:Connect(function(i)
 if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
 if d1 then local v=i.Position-s1 root.Position=UDim2.new(f1.X.Scale,f1.X.Offset+v.X,f1.Y.Scale,f1.Y.Offset+v.Y) end
 if d2 then local v=i.Position-s2 pill.Position=UDim2.new(f2.X.Scale,f2.X.Offset+v.X,f2.Y.Scale,f2.Y.Offset+v.Y) end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d1=false d2=false end end)
for i,b in ipairs(tb) do b.MouseButton1Click:Connect(function() show(i) end) end

RUN.RenderStepped:Connect(function() S.fr=S.fr+1 end)
RUN.Heartbeat:Connect(function()
 local now=os.clock()
 if AF.egg and not S.egAuto and AF.eggUntil>0 and now>AF.eggUntil then setEgg(false,false) end
 if not (AF.farm or AF.egg) then AF.qF={} AF.qE={} return end
 local fc=AF.light and 5 or 10
 local ec=AF.light and 3 or 6
 drain(AF.qF,fc) drain(AF.qE,ec)
end)
RUN.Heartbeat:Connect(function()
 if not VD.on then if #VD.queue>0 then VD.queue={} end return end
 local q=VD.queue if #q==0 then return end
 local taken=0 local idx=1
 while idx<=#q and taken<120 do local i=q[idx] if i then voidProcess(i) taken=taken+1 end idx=idx+1 end
 local newn=0 for i=idx,#q do newn=newn+1 q[newn]=q[i] end for i=newn+1,#q do q[i]=nil end
end)

T.spawn(function()
 while gui.Parent do
  T.wait(1)
  S.fps=S.fr S.fr=0
  hud()
 end
end)
T.spawn(function()
 while gui.Parent do
  T.wait(3)
  if AF.farm or AF.egg then refresh() end
  if VD.on then vdAttach() end
 end
end)
T.spawn(function()
 while gui.Parent do
  T.wait(10)
  local old=#S.pets local wasMax=(S.tg>=old) local np=pets()
  if #np~=old then S.pets=np if wasMax then S.tg=math.max(1,#np) end slots() log("pets "..old.."->"..#np) end
 end
end)
T.spawn(function()
 local last=fold()
 while gui.Parent do
  T.wait(0.5)
  local c=fold()
  if c~=last then last=c S.cf=c S.slots={} S.skip={} S.idle=0 S.unst=0 S.grace=os.clock()+3 S.pets=pets() slots() end
 end
end)

show(1) hud() updAF()
if not VD.on and #VD.arr>0 then vdRestore() end
if VD.on then vdLightOn() vdAttach() voidUpd() T.spawn(function() voidScan(WS,25000) voidScan(LIT,6000) end) else vdDetach() voidUpd() end

T.spawn(function()
 local o=pcall(function()
  S.pets=pets() S.tg=math.max(1,#S.pets) slots()
  local mem=memoGet() if mem~="" then S.egg=mem nb.Text=mem end
  installHook()
  if boot() then S.pets=pets() S.tg=math.max(1,#S.pets) slots() hud() stt.Text="ready - safe build" else stt.Text="no library - basic" end
 end)
 if not o then showErr("bg init") end
end)
end)

if not ok then
 warn("EVIL PETS SAFE:",err)
 pcall(function()
  local l=game:GetService("Players").LocalPlayer
  local p=l and l:WaitForChild("PlayerGui",8)
  if p then
   local g=Instance.new("ScreenGui") g.Name="PFEV_ERR" g.ResetOnSpawn=false g.DisplayOrder=999 g.Parent=p
   local f=Instance.new("Frame") f.Size=UDim2.fromOffset(270,130) f.Position=UDim2.new(0,12,0,300) f.BackgroundColor3=Color3.fromRGB(26,10,14) f.BorderSizePixel=0 f.Parent=g
   local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,10) c.Parent=f
   local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-14,1,-14) t.Position=UDim2.fromOffset(7,7) t.BackgroundTransparency=1 t.Text="ERR\n"..tostring(err):sub(1,300) t.TextColor3=Color3.fromRGB(255,140,150) t.TextSize=9 t.Font=Enum.Font.Code t.TextWrapped=true t.TextXAlignment=Enum.TextXAlignment.Left t.TextYAlignment=Enum.TextYAlignment.Top t.Parent=f
  end
 end)
end