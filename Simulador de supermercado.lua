print("SCRIPT RODANDO")

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")

local DS = nil
local okDS = pcall(function()
	DS = game:GetService("DataStoreService"):GetDataStore("SupermercadoCity_v2")
end)
if not okDS then
	DS = nil
	warn("Save desligado neste modo")
end

local acao = Instance.new("RemoteEvent")
acao.Name = "Acao"
acao.Parent = RS
local estadoEv = Instance.new("RemoteEvent")
estadoEv.Name = "Estado"
estadoEv.Parent = RS

local NPLOTS = 6
local ESP = 70
local XP_VENDA = 10
local XP_NIVEL = 100
local DESCANSO = 6
local MAX_ITENS = 4
local OFF_CLI = Vector3.new(2.4, -0.2, -0.8)
local OFF_MAO2 = Vector3.new(-2.4, -0.2, -0.8)
local LIM = {x1 = -20, x2 = 12, z1 = -24, z2 = 4}
local plots = {}
local dados = {}

local PRODS = {
	{nome = "Pao", tipo = "Padrao", custo = 20, preco = 5, nivel = 1},
	{nome = "Farinha", tipo = "Padrao", custo = 30, preco = 8, nivel = 5},
	{nome = "Suco", tipo = "Geladeira", custo = 50, preco = 12, nivel = 10},
	{nome = "Videogame", tipo = "Eletronicos", custo = 700, preco = 120, nivel = 15},
	{nome = "GiftCard", tipo = "GiftCard", custo = 250, preco = 40, nivel = 20},
}

local TPRAT = {
	{id = "Padrao", custo = 100, nivel = 1, cor = Color3.fromRGB(150, 100, 50)},
	{id = "Geladeira", custo = 300, nivel = 10, cor = Color3.fromRGB(150, 210, 255)},
	{id = "Eletronicos", custo = 800, nivel = 15, cor = Color3.fromRGB(50, 50, 70)},
	{id = "GiftCard", custo = 500, nivel = 20, cor = Color3.fromRGB(170, 70, 200)},
}

local LOJAS = {
	{custo = 0, nivel = 1, mult = 1},
	{custo = 500, nivel = 3, mult = 1.25},
	{custo = 1500, nivel = 10, mult = 1.5},
}

local ESTILO = {
	{piso = Enum.Material.SmoothPlastic, pisoC = Color3.fromRGB(235, 235, 235), par = Enum.Material.SmoothPlastic, parC = Color3.fromRGB(225, 225, 230), teto = Enum.Material.SmoothPlastic, tetoC = Color3.fromRGB(90, 90, 100)},
	{piso = Enum.Material.WoodPlanks, pisoC = Color3.fromRGB(190, 150, 100), par = Enum.Material.Brick, parC = Color3.fromRGB(215, 195, 175), teto = Enum.Material.Wood, tetoC = Color3.fromRGB(110, 80, 55)},
	{piso = Enum.Material.Marble, pisoC = Color3.fromRGB(235, 235, 245), par = Enum.Material.Marble, parC = Color3.fromRGB(245, 240, 230), teto = Enum.Material.Metal, tetoC = Color3.fromRGB(60, 60, 75)},
}

local function achaProd(nome)
	for _, o in ipairs(PRODS) do
		if o.nome == nome then return o end
	end
	return nil
end

local function achaTipo(id)
	for _, t in ipairs(TPRAT) do
		if t.id == id then return t end
	end
	return nil
end

-- Idiomas (textos do mundo)
local TX = {
	pt = {
		loja = "Supermercado de %s\nNivel %d", hud = "Dinheiro: R$ %d\nNivel da loja: %d",
		entrada = "ENTRADA", atender = "Atender cliente", caixa = "Caixa", repo = "Repositor",
		contratar = "Contratar", contratado = "contratado!", descansa = "Descansando",
		estoque = "Estoque: %d/30", vazia = "Vazia",
		n_Pao = "Pao", n_Farinha = "Farinha", n_Suco = "Suco", n_Videogame = "Videogame", n_GiftCard = "Gift Card",
		t_Padrao = "Prateleira Padrao", t_Geladeira = "Geladeira", t_Eletronicos = "Prateleira Eletronicos", t_GiftCard = "Prateleira Gift Card",
	},
	en = {
		loja = "%s's Supermarket\nLevel %d", hud = "Money: $ %d\nStore level: %d",
		entrada = "ENTRANCE", atender = "Serve customer", caixa = "Cashier", repo = "Stocker",
		contratar = "Hire", contratado = "hired!", descansa = "Resting",
		estoque = "Stock: %d/30", vazia = "Empty",
		n_Pao = "Bread", n_Farinha = "Flour", n_Suco = "Juice", n_Videogame = "Video game", n_GiftCard = "Gift Card",
		t_Padrao = "Standard shelf", t_Geladeira = "Fridge", t_Eletronicos = "Electronics shelf", t_GiftCard = "Gift card shelf",
	},
	es = {
		loja = "Supermercado de %s\nNivel %d", hud = "Dinero: $ %d\nNivel de la tienda: %d",
		entrada = "ENTRADA", atender = "Atender cliente", caixa = "Cajero", repo = "Reponedor",
		contratar = "Contratar", contratado = "contratado!", descansa = "Descansando",
		estoque = "Existencias: %d/30", vazia = "Vacia",
		n_Pao = "Pan", n_Farinha = "Harina", n_Suco = "Jugo", n_Videogame = "Videojuego", n_GiftCard = "Tarjeta de regalo",
		t_Padrao = "Estante estandar", t_Geladeira = "Nevera", t_Eletronicos = "Estante de electronicos", t_GiftCard = "Estante de tarjetas",
	},
}

local function tr(pl, k, ...)
	local d = pl and dados[pl]
	local lg = (d and d.lang) or "pt"
	local s = (TX[lg] and TX[lg][k]) or TX.pt[k] or k
	if select("#", ...) > 0 then
		return string.format(s, ...)
	end
	return s
end

-- Ajudantes
local function parte(pai, tam, pos, cor)
	local p = Instance.new("Part")
	p.Size = tam
	p.Position = pos
	p.Color = cor
	p.Anchored = true
	p.Parent = pai
	return p
end

local function vidro(pai, tam, pos)
	local v = parte(pai, tam, pos, Color3.fromRGB(170, 215, 245))
	v.Material = Enum.Material.Glass
	v.Transparency = 0.5
	return v
end

local function rotulo(p, texto, alt, dist)
	local g = Instance.new("BillboardGui")
	g.Size = UDim2.new(0, 150, 0, 50)
	g.StudsOffset = Vector3.new(0, alt, 0)
	g.MaxDistance = dist or 25
	g.Parent = p
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, 0, 1, 0)
	t.BackgroundTransparency = 1
	t.TextScaled = true
	t.TextWrapped = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Text = texto
	t.Parent = g
	return t
end

local function rosto(p, lado)
	local d = Instance.new("Decal")
	d.Texture = "rbxasset://textures/face.png"
	d.Face = lado
	d.Parent = p
end

local function prompt(p, acaoTxt, obj, fn)
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = acaoTxt
	pp.ObjectText = obj
	pp.MaxActivationDistance = 10
	pp.RequiresLineOfSight = false
	pp.Parent = p
	pp.Triggered:Connect(fn)
	return pp
end

-- Objetos que simbolizam os produtos (esc = escala)
local function criarItem(nome, esc)
	esc = esc or 1
	local tam = Vector3.new(1.4, 1.4, 1.4)
	local cor = Color3.fromRGB(200, 200, 200)
	if nome == "Pao" then
		tam = Vector3.new(1.8, 1, 1.2)
		cor = Color3.fromRGB(205, 140, 70)
	elseif nome == "Farinha" then
		tam = Vector3.new(1.2, 1.6, 0.8)
		cor = Color3.fromRGB(245, 245, 235)
	elseif nome == "Suco" then
		tam = Vector3.new(0.9, 1.7, 0.9)
		cor = Color3.fromRGB(255, 150, 40)
	elseif nome == "Videogame" then
		tam = Vector3.new(1.8, 0.5, 1.2)
		cor = Color3.fromRGB(30, 60, 160)
	elseif nome == "GiftCard" then
		tam = Vector3.new(1.6, 1, 0.2)
		cor = Color3.fromRGB(190, 80, 220)
	end
	local it = Instance.new("Part")
	it.Name = "Item"
	it.Size = tam * esc
	it.Color = cor
	return it
end

local function criarSacola()
	local s = Instance.new("Part")
	s.Name = "Sacola"
	s.Size = Vector3.new(1.4, 1.7, 0.8)
	s.Color = Color3.fromRGB(235, 205, 145)
	return s
end

local function criarCesta()
	local s = Instance.new("Part")
	s.Name = "Cesta"
	s.Size = Vector3.new(1.8, 0.9, 1.4)
	s.Color = Color3.fromRGB(190, 60, 60)
	return s
end

-- Prende um objeto do lado de quem esta segurando
local function segurar(dono, item, off)
	item.Anchored = false
	item.CanCollide = false
	item.CanTouch = false
	item.Massless = true
	item.Parent = dono
	item.CFrame = dono.CFrame * CFrame.new(off)
	local w = Instance.new("WeldConstraint")
	w.Part0 = dono
	w.Part1 = item
	w.Parent = item
end

-- Cliente: vira rapido para onde vai e depois anda
local function mover(part, pos)
	local de = part.Position
	local dir = Vector3.new(pos.X - de.X, 0, pos.Z - de.Z)
	local alvo = CFrame.new(pos)
	if dir.Magnitude > 0.1 then
		alvo = CFrame.lookAt(pos, pos + dir)
		local girar = TS:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {CFrame = CFrame.lookAt(de, de + dir)})
		girar:Play()
		girar.Completed:Wait()
	end
	local d = (de - pos).Magnitude
	local tw = TS:Create(part, TweenInfo.new(math.max(0.2, d / 14), Enum.EasingStyle.Linear), {CFrame = alvo})
	tw:Play()
	tw.Completed:Wait()
end

local function olhar(part, dx, dz)
	local pos = part.Position
	part.CFrame = CFrame.lookAt(pos, pos + Vector3.new(dx, 0, dz))
end

local function posFila(p, i)
	return Vector3.new(p.cx + 18, 2, 14 + (i - 1) * 3)
end

-- Funcionario: bola com rosto e chapeu (igual aos clientes)
local function criarBola(pai, nome, pos, corB, corH)
	local m = Instance.new("Model")
	m.Name = "Funcionario"
	local b = parte(m, Vector3.new(3, 3, 3), pos, corB)
	b.Shape = Enum.PartType.Ball
	rosto(b, Enum.NormalId.Front)
	local brim = parte(m, Vector3.new(0.3, 2.8, 2.8), pos, corH)
	brim.Shape = Enum.PartType.Cylinder
	brim.CFrame = CFrame.new(pos + Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	local top = parte(m, Vector3.new(1.2, 1.8, 1.8), pos, corH)
	top.Shape = Enum.PartType.Cylinder
	top.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	for _, x in ipairs(m:GetChildren()) do
		x.CanCollide = false
	end
	local lab = rotulo(b, nome, 3, 15)
	m.PrimaryPart = b
	m.Parent = pai
	return m, lab
end

local function virar(m, dx, dz)
	if not m.Parent then return end
	local pos = m:GetPivot().Position
	m:PivotTo(CFrame.lookAt(pos, pos + Vector3.new(dx, 0, dz)))
end

local function andarF(m, dest, vel)
	if not m.Parent then return end
	local de = m:GetPivot().Position
	local dir = Vector3.new(dest.X - de.X, 0, dest.Z - de.Z)
	if dir.Magnitude < 0.1 then return end
	local rot = CFrame.lookAt(de, de + dir).Rotation
	m:PivotTo(CFrame.new(de) * rot)
	local t = dir.Magnitude / (vel or 12)
	local ini = os.clock()
	while true do
		if not m.Parent then return end
		local a = (os.clock() - ini) / t
		if a >= 1 then break end
		m:PivotTo(CFrame.new(de:Lerp(dest, a)) * rot)
		task.wait()
	end
	m:PivotTo(CFrame.new(dest) * rot)
end

-- Mexidinha do caixa (gira um pouco e volta)
local function mexer(m, base, a)
	for i = 1, 6 do
		if not m.Parent then return end
		m:PivotTo(base * CFrame.Angles(0, math.rad(a * i / 6), 0))
		task.wait(0.04)
	end
	task.wait(0.5)
	for i = 5, 0, -1 do
		if not m.Parent then return end
		m:PivotTo(base * CFrame.Angles(0, math.rad(a * i / 6), 0))
		task.wait(0.04)
	end
end

-- Aviso na tela do jogador
local function aviso(pl, chave)
	estadoEv:FireClient(pl, {msg = chave})
end

-- Dinheiro, XP, nivel, painel e estado do cliente
local function atualizar(pl)
	local d = dados[pl]
	if not d then return end
	d.hud.Text = tr(pl, "hud", d.din.Value, d.nivel)
	local xpn = d.xp % XP_NIVEL
	d.xptxt.Text = "XP " .. xpn .. "/" .. XP_NIVEL
	TS:Create(d.fill, TweenInfo.new(0.25), {Size = UDim2.new(xpn / XP_NIVEL, 0, 1, 0)}):Play()
	local p = d.plot
	if p and p.placa then
		p.placa.Text = tr(pl, "loja", pl.Name, d.nivel)
	end
	if p and p.regs then
		for _, f in ipairs(p.regs) do
			pcall(f)
		end
	end
	estadoEv:FireClient(pl, {
		din = d.din.Value, nivel = d.nivel, tier = d.tier, reb = d.reb,
		inv = d.inv, mao = d.mao, colocando = (d.colocando ~= nil),
	})
end

local function gastar(pl, v)
	local d = dados[pl]
	if not d or d.din.Value < v then return false end
	d.din.Value = d.din.Value - v
	atualizar(pl)
	return true
end

local function ganhar(pl, v)
	local d = dados[pl]
	if not d then return end
	d.din.Value = d.din.Value + v
	d.xp = d.xp + XP_VENDA
	d.nivel = math.floor(d.xp / XP_NIVEL) + 1
	atualizar(pl)
end

-- Save
local function chave(pl)
	return "Jogador_" .. pl.UserId
end

local function salvar(pl)
	if not DS then return end
	local d = dados[pl]
	if not d or d.semSave then return end
	local lista = {}
	if d.plot then
		for _, pr in ipairs(d.plot.prat) do
			table.insert(lista, {tipo = pr.tipo.id, prod = pr.prod and pr.prod.nome or nil, est = pr.est, dx = pr.dx, dz = pr.dz})
		end
	end
	local inv = {}
	for k, v in pairs(d.inv) do
		inv[k] = v
	end
	local info = {din = d.din.Value, xp = d.xp, prat = lista, inv = inv, tier = d.tier, reb = d.reb, caixa = d.caixa, repo = d.repo}
	local ok, err = pcall(function()
		DS:SetAsync(chave(pl), info)
	end)
	if not ok then warn("Erro ao salvar: " .. tostring(err)) end
end

-- Predios da cidade (entra mas nao faz nada)
local function def(w, d, h, cor, mob, sinal)
	return {w = w, d = d, h = h, cor = cor, mob = mob, sinal = sinal,
		teto = Color3.fromRGB(80, 80, 90), piso = Color3.fromRGB(225, 225, 225)}
end

local TIPOS = {
	Casa = def(30, 26, 12, nil, Color3.fromRGB(120, 80, 50), false),
	Apartamentos = def(40, 30, 42, Color3.fromRGB(190, 180, 170), Color3.fromRGB(110, 110, 120), true),
	Pizzaria = def(34, 28, 14, Color3.fromRGB(210, 70, 60), Color3.fromRGB(120, 70, 40), true),
	Banco = def(36, 28, 16, Color3.fromRGB(200, 200, 215), Color3.fromRGB(90, 90, 110), true),
	Hotel = def(40, 30, 30, Color3.fromRGB(220, 190, 140), Color3.fromRGB(130, 90, 60), true),
	Cinema = def(38, 30, 18, Color3.fromRGB(70, 60, 110), Color3.fromRGB(40, 40, 50), true),
	Farmacia = def(32, 26, 14, Color3.fromRGB(90, 190, 130), Color3.fromRGB(240, 240, 240), true),
	Hospital = def(42, 30, 24, Color3.fromRGB(235, 235, 240), Color3.fromRGB(240, 240, 240), true),
	Escola = def(40, 28, 16, Color3.fromRGB(230, 190, 70), Color3.fromRGB(150, 110, 60), true),
	Padaria = def(30, 26, 13, Color3.fromRGB(230, 170, 110), Color3.fromRGB(140, 90, 50), true),
}

local function predio(pai, cx, cz, s, tipo)
	local T = TIPOS[tipo]
	local w, d, h = T.w, T.d, T.h
	local dw, dh = 8, 9
	local cor = T.cor or Color3.fromHSV(math.random(), 0.35, 0.9)
	local zf = cz + s * d / 2
	local zb = cz - s * d / 2

	parte(pai, Vector3.new(w, 0.4, d), Vector3.new(cx, 0.2, cz), T.piso)
	parte(pai, Vector3.new(w, h, 1), Vector3.new(cx, h / 2, zb), cor)
	parte(pai, Vector3.new(1, h, d), Vector3.new(cx - w / 2, h / 2, cz), cor)
	parte(pai, Vector3.new(1, h, d), Vector3.new(cx + w / 2, h / 2, cz), cor)
	local seg = (w - dw) / 2
	parte(pai, Vector3.new(seg, h, 1), Vector3.new(cx - dw / 2 - seg / 2, h / 2, zf), cor)
	parte(pai, Vector3.new(seg, h, 1), Vector3.new(cx + dw / 2 + seg / 2, h / 2, zf), cor)
	parte(pai, Vector3.new(dw, h - dh, 1), Vector3.new(cx, dh + (h - dh) / 2, zf), cor)
	parte(pai, Vector3.new(w + 2, 1, d + 2), Vector3.new(cx, h + 0.5, cz), T.teto)

	local luz = parte(pai, Vector3.new(1, 1, 1), Vector3.new(cx, 9, cz), Color3.new(1, 1, 1))
	luz.Transparency = 1
	luz.CanCollide = false
	local lz = Instance.new("PointLight")
	lz.Range = 40
	lz.Brightness = 1
	lz.Parent = luz

	if T.sinal then
		local placa = parte(pai, Vector3.new(10, 2.5, 0.5), Vector3.new(cx, dh + 2, zf + s * 0.75), Color3.fromRGB(30, 30, 35))
		rotulo(placa, tipo, 2.5, 55)
	end

	local function mesa(x, z)
		parte(pai, Vector3.new(5, 0.5, 5), Vector3.new(x, 3, z), T.mob)
		parte(pai, Vector3.new(1, 3, 1), Vector3.new(x, 1.5, z), T.mob)
	end

	if tipo == "Casa" then
		parte(pai, Vector3.new(6, 2, 9), Vector3.new(cx - w / 4, 1.4, zb + s * 6), Color3.fromRGB(240, 240, 240))
		parte(pai, Vector3.new(10, 2.5, 3), Vector3.new(cx + w / 4, 1.6, zb + s * 4), Color3.fromRGB(70, 110, 190))
		mesa(cx + w / 4, cz)
	elseif tipo == "Cinema" then
		parte(pai, Vector3.new(w - 6, 10, 0.5), Vector3.new(cx, 7, zb + s * 1), Color3.fromRGB(20, 20, 25))
		for r = 0, 2 do
			parte(pai, Vector3.new(w - 10, 2, 2), Vector3.new(cx, 1.2, zb + s * (10 + r * 5)), Color3.fromRGB(180, 40, 50))
		end
	else
		parte(pai, Vector3.new(w * 0.6, 3.5, 3), Vector3.new(cx, 1.9, zb + s * 5), T.mob)
		mesa(cx - w / 4, cz)
		mesa(cx + w / 4, cz)
		if tipo == "Pizzaria" then
			parte(pai, Vector3.new(6, 6, 3), Vector3.new(cx + w / 3, 3.4, zb + s * 2), Color3.fromRGB(190, 70, 30))
		end
	end
end

-- Cidade
local cidade = Instance.new("Folder")
cidade.Name = "Cidade"
cidade.Parent = workspace
parte(cidade, Vector3.new(800, 1, 450), Vector3.new(0, -0.5, 0), Color3.fromRGB(110, 170, 100))
parte(cidade, Vector3.new(800, 0.2, 26), Vector3.new(0, 0.1, 60), Color3.fromRGB(50, 50, 55))
parte(cidade, Vector3.new(800, 0.05, 0.6), Vector3.new(0, 0.22, 60), Color3.fromRGB(240, 240, 240))
parte(cidade, Vector3.new(800, 0.3, 8), Vector3.new(0, 0.15, 42), Color3.fromRGB(190, 190, 190))

local LISTA_A = {"Casa", "Casa", "Apartamentos", "Casa"}
local LISTA_B = {"Pizzaria", "Apartamentos", "Banco", "Hotel", "Cinema", "Farmacia", "Apartamentos",
	"Hospital", "Escola", "Padaria", "Apartamentos", "Pizzaria", "Hotel", "Banco"}

for k = 1, 14 do
	local x = -350 + (k - 1) * 54
	predio(cidade, x, -110, 1, LISTA_A[(k - 1) % 4 + 1])
	predio(cidade, x, 110, -1, LISTA_B[k])
end

-- Estilo (textura) da loja por nivel de evolucao
local function aplicarEstilo(p, t)
	local e = ESTILO[t] or ESTILO[1]
	for _, x in ipairs(p.estilo) do
		if x.k == "piso" then
			x.p.Material = e.piso
			x.p.Color = e.pisoC
		elseif x.k == "parede" then
			x.p.Material = e.par
			x.p.Color = e.parC
		elseif x.k == "fundo" then
			x.p.Material = e.par
		elseif x.k == "teto" then
			x.p.Material = e.teto
			x.p.Color = e.tetoC
		end
	end
end

-- Prateleiras
local function posValida(p, dx, dz)
	if dx < LIM.x1 or dx > LIM.x2 or dz < LIM.z1 or dz > LIM.z2 then return false end
	for _, pr in ipairs(p.prat) do
		if math.abs(pr.dx - dx) < 11 and math.abs(pr.dz - dz) < 6 then
			return false
		end
	end
	return true
end

local function criarPrat(p, pasta, t, dx, dz, prodNome, est)
	local x = p.cx + dx
	local s = parte(pasta, Vector3.new(10, 6, 3), Vector3.new(x, 3.4, dz), t.cor)
	if t.id == "Geladeira" then
		s.Material = Enum.Material.Glass
	elseif t.id == "Eletronicos" then
		s.Material = Enum.Material.Metal
	end
	local pr = {part = s, tipo = t, prod = achaProd(prodNome), est = est or 0, x = x, z = dz, dx = dx, dz = dz}
	pr.lab = rotulo(s, "", 5, 22)
	pr.upd = function()
		local dono = p.dono
		if pr.prod then
			pr.lab.Text = tr(dono, "n_" .. pr.prod.nome) .. "\n" .. tr(dono, "estoque", pr.est)
		else
			pr.lab.Text = tr(dono, "t_" .. t.id) .. "\n" .. tr(dono, "vazia")
		end
	end
	pr.upd()
	table.insert(p.regs, pr.upd)
	table.insert(p.prat, pr)
	return pr
end

-- Item que o jogador carrega na mao
local function atualizarMao(pl)
	local d = dados[pl]
	local ch = pl.Character
	if not d or not ch then return end
	local hrp = ch:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local velho = hrp:FindFirstChild("MaoItem")
	if velho then velho:Destroy() end
	local nome = d.mao
	if not nome or (d.inv[nome] or 0) <= 0 then
		nome = nil
		for _, o in ipairs(PRODS) do
			if (d.inv[o.nome] or 0) > 0 then
				nome = o.nome
				break
			end
		end
		d.mao = nome
	end
	if nome then
		local it = criarItem(nome, 0.9)
		it.Name = "MaoItem"
		segurar(hrp, it, Vector3.new(1.6, 0.2, -1.6))
	end
end

-- Botao B: coloca tudo na prateleira mais proxima
local function colocar(pl)
	local d = dados[pl]
	if not d or not d.plot then return end
	local p = d.plot
	local ch = pl.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local alvo = nil
	local melhor = 14
	for _, pr in ipairs(p.prat) do
		local dist = (Vector3.new(pr.x, hrp.Position.Y, pr.z) - hrp.Position).Magnitude
		if dist < melhor then
			melhor = dist
			alvo = pr
		end
	end
	if not alvo then
		aviso(pl, "longe")
		return
	end
	local prod = alvo.prod
	if not prod then
		local escolha = nil
		if d.mao then
			local o = achaProd(d.mao)
			if o and o.tipo == alvo.tipo.id and (d.inv[o.nome] or 0) > 0 then escolha = o end
		end
		if not escolha then
			for _, o in ipairs(PRODS) do
				if o.tipo == alvo.tipo.id and (d.inv[o.nome] or 0) > 0 then
					escolha = o
					break
				end
			end
		end
		prod = escolha
	end
	if not prod then
		aviso(pl, "nada")
		return
	end
	local tem = d.inv[prod.nome] or 0
	local cabe = 30 - alvo.est
	if cabe <= 0 then
		aviso(pl, "cheia")
		return
	end
	if tem <= 0 then
		aviso(pl, "nada")
		return
	end
	local n = math.min(tem, cabe)
	d.inv[prod.nome] = tem - n
	alvo.prod = prod
	alvo.est = alvo.est + n
	alvo.upd()
	atualizarMao(pl)
	atualizar(pl)
end

-- Loja: comprar produtos
local function comprarProd(pl, id)
	local d = dados[pl]
	local o = achaProd(id)
	if not d or not o then return end
	if d.nivel < o.nivel then
		aviso(pl, "nivel")
		return
	end
	if (d.inv[o.nome] or 0) >= 200 then
		aviso(pl, "cheia")
		return
	end
	if not gastar(pl, o.custo) then
		aviso(pl, "dinheiro")
		return
	end
	d.inv[o.nome] = (d.inv[o.nome] or 0) + 10
	d.mao = o.nome
	atualizarMao(pl)
	atualizar(pl)
end

-- Loja: evoluir a loja (muda a textura)
local function comprarLoja(pl)
	local d = dados[pl]
	if not d or not d.plot then return end
	local prox = d.tier + 1
	local l = LOJAS[prox]
	if not l then return end
	if d.nivel < l.nivel then
		aviso(pl, "nivel")
		return
	end
	if not gastar(pl, l.custo) then
		aviso(pl, "dinheiro")
		return
	end
	d.tier = prox
	aplicarEstilo(d.plot, prox)
	atualizar(pl)
end

-- Posicionar prateleira
local function refGhost(pl)
	local d = dados[pl]
	local c = d and d.colocando
	if not c then return end
	local p = d.plot
	c.ghost.Position = Vector3.new(p.cx + c.dx, 3.4, c.dz)
	if posValida(p, c.dx, c.dz) then
		c.ghost.Color = Color3.fromRGB(80, 255, 120)
	else
		c.ghost.Color = Color3.fromRGB(255, 70, 70)
	end
end

local function iniciarColoc(pl, id)
	local d = dados[pl]
	local t = achaTipo(id)
	if not d or not t or not d.plot or d.colocando then return end
	local p = d.plot
	if d.nivel < t.nivel then
		aviso(pl, "nivel")
		return
	end
	if d.din.Value < t.custo then
		aviso(pl, "dinheiro")
		return
	end
	if #p.prat >= 8 then
		aviso(pl, "limite")
		return
	end
	local sx = nil
	local sz = nil
	for z = LIM.z1, LIM.z2, 2 do
		for x = LIM.x1, LIM.x2, 2 do
			if not sx and posValida(p, x, z) then
				sx = x
				sz = z
			end
		end
	end
	if not sx then
		aviso(pl, "espaco")
		return
	end
	local g = parte(p.pasta, Vector3.new(10, 6, 3), Vector3.new(p.cx + sx, 3.4, sz), t.cor)
	g.Transparency = 0.5
	g.CanCollide = false
	d.colocando = {tipo = t, dx = sx, dz = sz, ghost = g}
	refGhost(pl)
	atualizar(pl)
end

local function sgn(v)
	if v == 1 then return 1 end
	if v == -1 then return -1 end
	return 0
end

local function moverGhost(pl, dx, dz)
	local d = dados[pl]
	local c = d and d.colocando
	if not c then return end
	c.dx = math.clamp(c.dx + sgn(dx) * 2, LIM.x1, LIM.x2)
	c.dz = math.clamp(c.dz + sgn(dz) * 2, LIM.z1, LIM.z2)
	refGhost(pl)
end

local function cancelar(pl)
	local d = dados[pl]
	local c = d and d.colocando
	if not c then return end
	if c.ghost then c.ghost:Destroy() end
	d.colocando = nil
	atualizar(pl)
end

local function confirmar(pl)
	local d = dados[pl]
	local c = d and d.colocando
	if not c then return end
	local p = d.plot
	if not posValida(p, c.dx, c.dz) then
		aviso(pl, "posicao")
		return
	end
	if #p.prat >= 8 then
		aviso(pl, "limite")
		return
	end
	if not gastar(pl, c.tipo.custo) then
		aviso(pl, "dinheiro")
		return
	end
	c.ghost:Destroy()
	d.colocando = nil
	criarPrat(p, p.pasta, c.tipo, c.dx, c.dz, nil, 0)
	atualizar(pl)
end

-- Caixa: troca cesta e itens por uma sacolinha e o cliente sai pela porta
local function atender(p)
	local c = p.fila[1]
	if not c or not c.pronto or not p.dono then return false end
	table.remove(p.fila, 1)
	local d = dados[p.dono]
	local mult = 1
	if d and LOJAS[d.tier] then mult = LOJAS[d.tier].mult end
	ganhar(p.dono, math.floor(c.preco * mult))
	for _, it in ipairs(c.itens) do
		it:Destroy()
	end
	c.itens = {}
	if c.cesta then
		c.cesta:Destroy()
		c.cesta = nil
	end
	segurar(c.part, criarSacola(), OFF_CLI)
	for i, o in ipairs(p.fila) do
		local alvo = posFila(p, i)
		TS:Create(o.part, TweenInfo.new(0.6), {CFrame = CFrame.lookAt(alvo, alvo + Vector3.new(0, 0, -1))}):Play()
	end
	task.spawn(function()
		mover(c.part, Vector3.new(p.cx, 2, 27))
		mover(c.part, Vector3.new(p.cx, 2, 42))
		c.part:Destroy()
	end)
	return true
end

-- Cliente: entra pela porta, pega de 1 a 4 itens (videogame so 1)
local function cliente(p, tok)
	if p.tok ~= tok or #p.fila >= 5 then return end
	local disp = {}
	for _, pr in ipairs(p.prat) do
		if pr.prod and pr.est > 0 then table.insert(disp, pr) end
	end
	if #disp == 0 then return end

	local n = math.random(1, MAX_ITENS)
	local plano = {}
	local ult = nil
	for _ = 1, n do
		local pr
		if ult and math.random() < 0.5 then
			pr = ult
		else
			pr = disp[math.random(#disp)]
		end
		ult = pr
		local achou = false
		for _, x in ipairs(plano) do
			if x.pr == pr then
				x.qtd = x.qtd + 1
				achou = true
				break
			end
		end
		if not achou then table.insert(plano, {pr = pr, qtd = 1}) end
	end

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(3, 3, 3)
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromHSV(math.random(), 0.5, 1)
	part.Position = Vector3.new(p.cx, 2, 42)
	part.Parent = p.pasta
	rosto(part, Enum.NormalId.Front)

	local cesta = criarCesta()
	segurar(part, cesta, OFF_CLI)
	local c = {part = part, pronto = false, preco = 0, itens = {}, cesta = cesta, nslot = 0, video = false}

	mover(part, Vector3.new(p.cx, 2, 34))
	if p.tok ~= tok then return end

	local slots = {Vector3.new(-0.35, 0, -0.3), Vector3.new(0.35, 0, -0.3), Vector3.new(-0.35, 0, 0.3), Vector3.new(0.35, 0, 0.3)}

	for _, x in ipairs(plano) do
		mover(part, Vector3.new(x.pr.x, 2, x.pr.z + 4))
		if p.tok ~= tok then return end
		task.wait(0.5)
		for _ = 1, x.qtd do
			if p.tok ~= tok then return end
			local nome = x.pr.prod and x.pr.prod.nome
			if nome and x.pr.est > 0 and #c.itens < MAX_ITENS and not (nome == "Videogame" and c.video) then
				x.pr.est = x.pr.est - 1
				x.pr.upd()
				local item
				if nome == "Videogame" then
					item = criarItem(nome, 1)
					segurar(part, item, OFF_MAO2)
					c.video = true
				else
					item = criarItem(nome, 0.5)
					c.nslot = c.nslot + 1
					local s = slots[c.nslot]
					local off = Vector3.new(OFF_CLI.X + s.X, OFF_CLI.Y + 0.45 + item.Size.Y / 2, OFF_CLI.Z + s.Z)
					segurar(part, item, off)
				end
				table.insert(c.itens, item)
				c.preco = c.preco + x.pr.prod.preco
				task.wait(0.6)
			end
		end
	end
	if p.tok ~= tok then return end

	if #c.itens > 0 then
		table.insert(p.fila, c)
		mover(part, posFila(p, table.find(p.fila, c)))
		olhar(part, 0, -1)
		c.pronto = true
	else
		mover(part, Vector3.new(p.cx, 2, 34))
		mover(part, Vector3.new(p.cx, 2, 42))
		part:Destroy()
	end
end

-- Construir loja do jogador
local function construir(p, pl, salvo)
	p.tok = p.tok + 1
	local tok = p.tok
	if p.pasta then p.pasta:Destroy() end
	local pasta = Instance.new("Folder")
	pasta.Name = "Loja_" .. pl.Name
	pasta.Parent = workspace
	p.pasta = pasta
	p.dono = pl
	p.fila = {}
	p.prat = {}
	p.regs = {}
	p.estilo = {}
	local cx = p.cx

	local function reg(fn)
		fn()
		table.insert(p.regs, fn)
	end

	local piso = parte(pasta, Vector3.new(60, 0.4, 60), Vector3.new(cx, 0.2, 0), Color3.fromRGB(235, 235, 235))
	table.insert(p.estilo, {p = piso, k = "piso"})
	local parede = parte(pasta, Vector3.new(62, 14, 1), Vector3.new(cx, 7, -30.5), Color3.fromRGB(200, 60, 60))
	table.insert(p.estilo, {p = parede, k = "fundo"})

	local function par(tam, pos)
		local x = parte(pasta, tam, pos, Color3.fromRGB(225, 225, 230))
		table.insert(p.estilo, {p = x, k = "parede"})
		return x
	end

	-- Paredes laterais com janelas
	for _, lado in ipairs({-30.5, 30.5}) do
		local x = cx + lado
		par(Vector3.new(1, 5, 62), Vector3.new(x, 2.5, 0))
		par(Vector3.new(1, 4, 62), Vector3.new(x, 12, 0))
		par(Vector3.new(1, 5, 10), Vector3.new(x, 7.5, -26))
		par(Vector3.new(1, 5, 18), Vector3.new(x, 7.5, 0))
		par(Vector3.new(1, 5, 10), Vector3.new(x, 7.5, 26))
		vidro(pasta, Vector3.new(0.4, 5, 12), Vector3.new(x, 7.5, -15))
		vidro(pasta, Vector3.new(0.4, 5, 12), Vector3.new(x, 7.5, 15))
	end

	-- Frente com porta e janelas
	for _, lado in ipairs({-18, 18}) do
		local x = cx + lado
		par(Vector3.new(24, 5, 1), Vector3.new(x, 2.5, 30.5))
		par(Vector3.new(24, 4, 1), Vector3.new(x, 12, 30.5))
		par(Vector3.new(6, 5, 1), Vector3.new(x - 9, 7.5, 30.5))
		par(Vector3.new(6, 5, 1), Vector3.new(x + 9, 7.5, 30.5))
		vidro(pasta, Vector3.new(12, 5, 0.4), Vector3.new(x, 7.5, 30.5))
	end
	local verga = par(Vector3.new(12, 4, 1), Vector3.new(cx, 12, 30.5))
	local labV = rotulo(verga, "", 3, 40)
	reg(function() labV.Text = tr(pl, "entrada") end)

	-- Teto
	local teto = parte(pasta, Vector3.new(64, 1, 64), Vector3.new(cx, 14.5, 0), Color3.fromRGB(90, 90, 100))
	table.insert(p.estilo, {p = teto, k = "teto"})

	-- Nome da loja fixo na parede
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Back
	sg.CanvasSize = Vector2.new(1200, 280)
	sg.Parent = parede
	local placa = Instance.new("TextLabel")
	placa.Size = UDim2.new(1, 0, 1, 0)
	placa.BackgroundTransparency = 1
	placa.TextScaled = true
	placa.Font = Enum.Font.GothamBold
	placa.TextColor3 = Color3.new(1, 1, 1)
	placa.Text = tr(pl, "loja", pl.Name, 1)
	placa.Parent = sg
	p.placa = placa

	-- Luz interna
	local luzP = parte(pasta, Vector3.new(1, 1, 1), Vector3.new(cx, 12, 0), Color3.new(1, 1, 1))
	luzP.Transparency = 1
	luzP.CanCollide = false
	local lz = Instance.new("PointLight")
	lz.Range = 60
	lz.Brightness = 1.5
	lz.Parent = luzP

	-- Balcao do caixa
	local balcao = parte(pasta, Vector3.new(12, 4, 3), Vector3.new(cx + 18, 2.4, 10), Color3.fromRGB(60, 60, 200))
	local ppB = prompt(balcao, "", "", function(who)
		if who == p.dono then atender(p) end
	end)
	reg(function()
		ppB.ActionText = tr(pl, "atender")
		ppB.ObjectText = tr(pl, "caixa")
	end)

	local function contratar(chaveNome, custo, z, inicial, aoContratar)
		local feito = false
		local pad = parte(pasta, Vector3.new(6, 0.4, 6), Vector3.new(cx - 24, 0.6, z), Color3.fromRGB(40, 180, 80))
		local lab = rotulo(pad, "", 4, 18)
		local pp = prompt(pad, "", "", function(who)
			if who ~= p.dono or p.tok ~= tok or feito then return end
			if not gastar(who, custo) then return end
			feito = true
			aoContratar()
			atualizar(pl)
		end)
		reg(function()
			if feito then
				lab.Text = tr(pl, chaveNome) .. "\n" .. tr(pl, "contratado")
			else
				lab.Text = tr(pl, chaveNome) .. "\nR$" .. custo
			end
			pp.ActionText = tr(pl, "contratar")
			pp.ObjectText = tr(pl, chaveNome) .. " R$" .. custo
		end)
		if inicial then
			feito = true
			aoContratar()
		end
	end

	local temCaixa = salvo and salvo.caixa
	local temRepo = salvo and salvo.repo

	-- Caixa: bola sentada numa cadeira, com chapeu, que mexe um pouquinho
	contratar("caixa", 300, 12, temCaixa, function()
		if dados[pl] then dados[pl].caixa = true end
		local cor = Color3.fromRGB(70, 70, 80)
		parte(pasta, Vector3.new(3.4, 0.5, 3.4), Vector3.new(cx + 18, 1.7, 6), cor)
		parte(pasta, Vector3.new(3.4, 3, 0.5), Vector3.new(cx + 18, 3.2, 4.3), cor)
		parte(pasta, Vector3.new(0.6, 1.1, 0.6), Vector3.new(cx + 18, 0.95, 6), cor)
		local pos = Vector3.new(cx + 18, 3.45, 6)
		local m, labF = criarBola(pasta, "", pos, Color3.fromRGB(255, 210, 130), Color3.fromRGB(200, 40, 40))
		reg(function() labF.Text = tr(pl, "caixa") end)
		local base = CFrame.lookAt(pos, pos + Vector3.new(0, 0, 1))
		m:PivotTo(base)
		task.spawn(function()
			local n = 0
			while p.tok == tok and m.Parent do
				task.wait(0.5)
				n = n + 1
				local c = p.fila[1]
				if c and c.pronto then
					m:PivotTo(base * CFrame.new(0, 0.7, 0))
					task.wait(0.15)
					m:PivotTo(base)
					atender(p)
					task.wait(1.5)
				elseif n % 5 == 0 then
					mexer(m, base, math.random(-18, 18))
				end
			end
		end)
	end)

	-- Repositor: pega do seu estoque pessoal, leva ate a prateleira, estoca e descansa
	contratar("repo", 400, 22, temRepo, function()
		if dados[pl] then dados[pl].repo = true end
		local casa = Vector3.new(cx - 12, 2, 8)
		local m, labF = criarBola(pasta, "", casa, Color3.fromRGB(100, 210, 255), Color3.fromRGB(40, 90, 200))
		local descansando = false
		reg(function()
			if descansando then
				labF.Text = tr(pl, "repo") .. "\n" .. tr(pl, "descansa")
			else
				labF.Text = tr(pl, "repo")
			end
		end)
		virar(m, 0, 1)
		task.spawn(function()
			while p.tok == tok and m.Parent do
				task.wait(4)
				if p.tok ~= tok then break end
				local d = dados[pl]
				local alvo = nil
				local prodAlvo = nil
				if d then
					for _, pr in ipairs(p.prat) do
						if pr.est <= 20 then
							local o = pr.prod
							if not o then
								for _, q in ipairs(PRODS) do
									if q.tipo == pr.tipo.id and (d.inv[q.nome] or 0) > 0 then
										o = q
										break
									end
								end
							end
							if o and (d.inv[o.nome] or 0) > 0 and (not alvo or pr.est < alvo.est) then
								alvo = pr
								prodAlvo = o
							end
						end
					end
				end
				if alvo then
					local n = math.min(10, 30 - alvo.est, d.inv[prodAlvo.nome])
					d.inv[prodAlvo.nome] = d.inv[prodAlvo.nome] - n
					atualizarMao(pl)
					atualizar(pl)
					local item = criarItem(prodAlvo.nome, 1)
					segurar(m.PrimaryPart, item, OFF_CLI)
					task.wait(0.5)

					andarF(m, Vector3.new(alvo.x, 2, 8), 12)
					andarF(m, Vector3.new(alvo.x, 2, alvo.z + 5), 12)
					virar(m, 0, -1)
					task.wait(1)
					if p.tok ~= tok then break end
					if not alvo.prod or alvo.prod == prodAlvo then
						alvo.prod = prodAlvo
						alvo.est = math.min(30, alvo.est + n)
						alvo.upd()
					else
						d.inv[prodAlvo.nome] = (d.inv[prodAlvo.nome] or 0) + n
						atualizar(pl)
					end
					item:Destroy()
					task.wait(0.5)

					andarF(m, Vector3.new(alvo.x, 2, 8), 12)
					andarF(m, casa, 12)
					virar(m, 0, 1)
					descansando = true
					atualizar(pl)
					task.wait(DESCANSO)
					descansando = false
					atualizar(pl)
				end
			end
		end)
	end)

	-- Restaurar prateleiras salvas
	if salvo and type(salvo.prat) == "table" then
		for _, it in ipairs(salvo.prat) do
			if #p.prat >= 8 then break end
			local t = achaTipo(it.tipo)
			if t and type(it.dx) == "number" and type(it.dz) == "number" then
				criarPrat(p, pasta, t, math.clamp(it.dx, LIM.x1, LIM.x2), math.clamp(it.dz, LIM.z1, LIM.z2), it.prod, math.clamp(tonumber(it.est) or 0, 0, 30))
			end
		end
	end

	aplicarEstilo(p, (dados[pl] and dados[pl].tier) or 1)

	-- Chegada de clientes
	task.spawn(function()
		while p.tok == tok do
			local nv = 1
			if dados[pl] then nv = dados[pl].nivel end
			task.wait(math.max(2, 10 - #p.prat - math.floor((nv - 1) / 2)))
			if p.tok == tok then task.spawn(cliente, p, tok) end
		end
	end)
end

local function livre(p)
	p.tok = p.tok + 1
	if p.pasta then p.pasta:Destroy() end
	local pasta = Instance.new("Folder")
	pasta.Name = "LoteLivre"
	pasta.Parent = workspace
	p.pasta = pasta
	p.dono = nil
	p.placa = nil
	p.regs = {}
	p.estilo = {}
	p.fila = {}
	p.prat = {}
	parte(pasta, Vector3.new(60, 0.4, 60), Vector3.new(p.cx, 0.2, 0), Color3.fromRGB(160, 160, 160))
	local w = parte(pasta, Vector3.new(60, 14, 1), Vector3.new(p.cx, 7, -30.5), Color3.fromRGB(100, 100, 100))
	rotulo(w, "LOTE LIVRE / FREE LOT", 4, 90)
end

for i = 1, NPLOTS do
	plots[i] = {i = i, cx = (i - 1) * ESP - 175, tok = 0, fila = {}, prat = {}, regs = {}, estilo = {}}
	livre(plots[i])
end

print("CIDADE CRIADA")

local function levar(pl)
	local d = dados[pl]
	local ch = pl.Character
	if not d or not ch or not d.plot then return end
	ch:WaitForChild("HumanoidRootPart")
	ch:PivotTo(CFrame.new(d.plot.cx, 5, 24))
end

-- Rebirth: reinicia tudo
local function rebirth(pl)
	local d = dados[pl]
	if not d or d.travado or not d.plot then return end
	d.travado = true
	if d.colocando then cancelar(pl) end
	d.reb = d.reb + 1
	d.din.Value = 200
	d.xp = 0
	d.nivel = 1
	d.tier = 1
	d.inv = {}
	d.mao = nil
	d.caixa = false
	d.repo = false
	if d.rebv then d.rebv.Value = d.reb end
	construir(d.plot, pl, nil)
	atualizarMao(pl)
	atualizar(pl)
	task.spawn(levar, pl)
	salvar(pl)
	d.travado = false
end

local function catalogo()
	local c = {prods = {}, prats = {}, lojas = {}}
	for _, o in ipairs(PRODS) do
		table.insert(c.prods, {id = o.nome, custo = o.custo, nivel = o.nivel})
	end
	for _, t in ipairs(TPRAT) do
		table.insert(c.prats, {id = t.id, custo = t.custo, nivel = t.nivel})
	end
	for _, l in ipairs(LOJAS) do
		table.insert(c.lojas, {custo = l.custo, nivel = l.nivel})
	end
	return c
end

-- Jogadores
local function entrar(pl)
	if dados[pl] then return end

	local meu = nil
	for _, p in ipairs(plots) do
		if not p.dono then
			meu = p
			break
		end
	end
	if not meu then
		pl:Kick("Cidade cheia / City full")
		return
	end
	meu.dono = pl

	local salvo = nil
	local semSave = true
	if DS then
		local ok, res = pcall(function()
			return DS:GetAsync(chave(pl))
		end)
		if ok then
			salvo = res
			semSave = false
		else
			warn("Erro ao carregar: " .. tostring(res))
		end
	end
	if type(salvo) ~= "table" then salvo = nil end

	local ls = pl:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = pl
	end
	local din = ls:FindFirstChild("Dinheiro")
	if not din then
		din = Instance.new("IntValue")
		din.Name = "Dinheiro"
		din.Parent = ls
	end
	din.Value = (salvo and tonumber(salvo.din)) or 200
	local rebv = ls:FindFirstChild("Rebirths")
	if not rebv then
		rebv = Instance.new("IntValue")
		rebv.Name = "Rebirths"
		rebv.Parent = ls
	end
	rebv.Value = (salvo and tonumber(salvo.reb)) or 0

	-- Painel na tela
	local pg = pl:WaitForChild("PlayerGui")
	local sg = Instance.new("ScreenGui")
	sg.Name = "HUD"
	sg.ResetOnSpawn = false
	sg.Parent = pg

	local fr = Instance.new("Frame")
	fr.Size = UDim2.new(0, 260, 0, 84)
	fr.Position = UDim2.new(0.5, -130, 0, 50)
	fr.BackgroundColor3 = Color3.new(0, 0, 0)
	fr.BackgroundTransparency = 0.4
	fr.Parent = sg
	local c1 = Instance.new("UICorner")
	c1.Parent = fr

	local hud = Instance.new("TextLabel")
	hud.Size = UDim2.new(1, 0, 0, 52)
	hud.BackgroundTransparency = 1
	hud.TextColor3 = Color3.new(1, 1, 1)
	hud.TextScaled = true
	hud.Font = Enum.Font.GothamBold
	hud.Parent = fr

	local fundo = Instance.new("Frame")
	fundo.Size = UDim2.new(0.9, 0, 0, 20)
	fundo.Position = UDim2.new(0.05, 0, 0, 56)
	fundo.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	fundo.Parent = fr
	local c2 = Instance.new("UICorner")
	c2.Parent = fundo

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(60, 210, 90)
	fill.Parent = fundo
	local c3 = Instance.new("UICorner")
	c3.Parent = fill

	local xptxt = Instance.new("TextLabel")
	xptxt.Size = UDim2.new(1, 0, 1, 0)
	xptxt.BackgroundTransparency = 1
	xptxt.TextColor3 = Color3.new(1, 1, 1)
	xptxt.TextStrokeTransparency = 0.3
	xptxt.TextScaled = true
	xptxt.Font = Enum.Font.GothamBold
	xptxt.ZIndex = 2
	xptxt.Parent = fundo

	local xp = (salvo and tonumber(salvo.xp)) or 0
	local inv = {}
	if salvo and type(salvo.inv) == "table" then
		for _, o in ipairs(PRODS) do
			local v = tonumber(salvo.inv[o.nome])
			if v and v > 0 then inv[o.nome] = math.min(200, math.floor(v)) end
		end
	end
	local tier = 1
	if salvo and tonumber(salvo.tier) then
		tier = math.clamp(math.floor(tonumber(salvo.tier)), 1, #LOJAS)
	end

	dados[pl] = {
		din = din, rebv = rebv, xp = xp, nivel = math.floor(xp / XP_NIVEL) + 1,
		hud = hud, fill = fill, xptxt = xptxt,
		plot = meu, caixa = false, repo = false, semSave = semSave,
		lang = "pt", tier = tier, reb = rebv.Value, inv = inv, mao = nil, colocando = nil,
	}

	pl.CameraMode = Enum.CameraMode.LockFirstPerson

	construir(meu, pl, salvo)
	atualizar(pl)

	local function aoNascer(ch)
		ch:WaitForChild("HumanoidRootPart")
		task.wait(0.3)
		levar(pl)
		atualizarMao(pl)
	end
	pl.CharacterAdded:Connect(aoNascer)
	if pl.Character then task.spawn(aoNascer, pl.Character) end
end

-- Pedidos dos botoes do jogador
acao.OnServerEvent:Connect(function(pl, nome, a, b)
	if type(nome) ~= "string" then return end
	if nome == "pronto" then
		local t = 0
		while not dados[pl] and t < 20 do
			task.wait(0.2)
			t = t + 0.2
		end
		if dados[pl] then
			estadoEv:FireClient(pl, {cat = catalogo(), perguntar = true})
			atualizar(pl)
		end
		return
	end
	local d = dados[pl]
	if not d then return end
	if nome == "idioma" then
		if type(a) == "string" and TX[a] then
			d.lang = a
			atualizar(pl)
		end
	elseif nome == "prod" and type(a) == "string" then
		comprarProd(pl, a)
	elseif nome == "prat" and type(a) == "string" then
		iniciarColoc(pl, a)
	elseif nome == "loja" then
		comprarLoja(pl)
	elseif nome == "mover" then
		moverGhost(pl, a, b)
	elseif nome == "ok" then
		confirmar(pl)
	elseif nome == "cancelar" then
		cancelar(pl)
	elseif nome == "colocar" then
		colocar(pl)
	elseif nome == "rebirth" then
		rebirth(pl)
	end
end)

Players.PlayerAdded:Connect(entrar)
for _, pl in ipairs(Players:GetPlayers()) do
	task.spawn(entrar, pl)
end

Players.PlayerRemoving:Connect(function(pl)
	if dados[pl] and dados[pl].colocando then cancelar(pl) end
	salvar(pl)
	for _, p in ipairs(plots) do
		if p.dono == pl then livre(p) end
	end
	dados[pl] = nil
end)

task.spawn(function()
	while true do
		task.wait(60)
		for _, pl in ipairs(Players:GetPlayers()) do
			salvar(pl)
		end
	end
end)

game:BindToClose(function()
	for _, pl in ipairs(Players:GetPlayers()) do
		salvar(pl)
	end
	task.wait(2)
end)

print("SCRIPT COMPLETO")