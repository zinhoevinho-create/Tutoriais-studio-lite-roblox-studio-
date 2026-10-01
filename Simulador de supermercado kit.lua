local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

local NPLOTS = 6
local ESP = 70
local plots = {}
local dados = {}

local OFERTAS = {
	{nome = "Pao", tipo = "Prateleira Padrao", custo = 100, preco = 5, un = 2, cor = Color3.fromRGB(150, 100, 50)},
	{nome = "Farinha", tipo = "Prateleira Padrao", custo = 150, preco = 8, un = 3, cor = Color3.fromRGB(190, 150, 90)},
	{nome = "Suco", tipo = "Geladeira", custo = 300, preco = 12, un = 5, cor = Color3.fromRGB(120, 200, 255)},
	{nome = "Videogame", tipo = "Prateleira Eletronicos", custo = 800, preco = 120, un = 70, cor = Color3.fromRGB(40, 40, 60)},
	{nome = "Gift Card", tipo = "Prateleira Gift Card", custo = 500, preco = 40, un = 25, cor = Color3.fromRGB(170, 70, 200)},
}

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

local function prompt(p, acao, obj, fn)
	local pp = Instance.new("ProximityPrompt")
	pp.ActionText = acao
	pp.ObjectText = obj
	pp.MaxActivationDistance = 10
	pp.RequiresLineOfSight = false
	pp.Parent = p
	pp.Triggered:Connect(fn)
	return pp
end

local function mover(part, pos)
	local d = (part.Position - pos).Magnitude
	local tw = TS:Create(part, TweenInfo.new(math.max(0.2, d / 14), Enum.EasingStyle.Linear), {Position = pos})
	tw:Play()
	tw.Completed:Wait()
end

local function posFila(p, i)
	return Vector3.new(p.cx + 18, 2, 15 + (i - 1) * 4)
end

-- Dinheiro, nivel e painel (fonte unica)
local function atualizar(pl)
	local d = dados[pl]
	if not d then return end
	d.hud.Text = "Dinheiro: R$ " .. d.din.Value .. "\nNivel da loja: " .. d.nivel
	if d.plot and d.plot.placa then
		d.plot.placa.Text = "Supermercado de " .. pl.Name .. "\nNivel " .. d.nivel
	end
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
	d.ganho = d.ganho + v
	d.nivel = math.floor(d.ganho / 300) + 1
	atualizar(pl)
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
	local pl = Instance.new("PointLight")
	pl.Range = 40
	pl.Brightness = 1
	pl.Parent = luz

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

-- Mercadoria e compras
local function atualizarPrat(pr)
	pr.lab.Text = pr.o.nome .. "\nEstoque: " .. pr.est .. "/30"
end

local function repor(p, pr)
	local custo = pr.o.un * 10
	if pr.est >= 30 or not p.dono then return false end
	if not gastar(p.dono, custo) then return false end
	pr.est = math.min(30, pr.est + 10)
	atualizarPrat(pr)
	return true
end

local function criarPrat(p, pasta, o)
	local n = #p.prat + 1
	local col = (n - 1) % 4
	local lin = math.floor((n - 1) / 4)
	local x = p.cx - 21 + col * 14
	local z = -16 + lin * 12
	local s = parte(pasta, Vector3.new(10, 6, 3), Vector3.new(x, 3.4, z), o.cor)
	if o.tipo == "Geladeira" then
		s.Material = Enum.Material.Glass
	elseif o.tipo == "Prateleira Eletronicos" then
		s.Material = Enum.Material.Metal
	end
	local pr = {part = s, o = o, est = 10, x = x, z = z}
	pr.lab = rotulo(s, "", 5, 22)
	atualizarPrat(pr)
	prompt(s, "Repor +10", o.nome .. " R$" .. (o.un * 10), function(who)
		if who == p.dono then repor(p, pr) end
	end)
	table.insert(p.prat, pr)
end

-- Caixa
local function atender(p)
	local c = p.fila[1]
	if not c or not c.pronto or not p.dono then return false end
	table.remove(p.fila, 1)
	ganhar(p.dono, c.preco)
	for i, o in ipairs(p.fila) do
		TS:Create(o.part, TweenInfo.new(0.6), {Position = posFila(p, i)}):Play()
	end
	task.spawn(function()
		mover(c.part, Vector3.new(p.cx + 18, 2, 42))
		c.part:Destroy()
	end)
	return true
end

-- Cliente
local function cliente(p, tok)
	if p.tok ~= tok or #p.fila >= 5 then return end
	local lista = {}
	for _, pr in ipairs(p.prat) do
		if pr.est > 0 then table.insert(lista, pr) end
	end
	if #lista == 0 then return end
	local pr = lista[math.random(#lista)]

	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(3, 3, 3)
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromHSV(math.random(), 0.5, 1)
	part.Position = Vector3.new(p.cx, 2, 42)
	part.Parent = p.pasta
	rosto(part, Enum.NormalId.Front)
	local c = {part = part, pronto = false, preco = pr.o.preco}

	mover(part, Vector3.new(pr.x, 2, pr.z + 4))
	if p.tok ~= tok then return end
	task.wait(1)
	if p.tok ~= tok then return end

	if pr.est > 0 then
		pr.est = pr.est - 1
		atualizarPrat(pr)
		table.insert(p.fila, c)
		mover(part, posFila(p, table.find(p.fila, c)))
		c.pronto = true
	else
		mover(part, Vector3.new(p.cx, 2, 42))
		part:Destroy()
	end
end

-- Construir loja do jogador
local function construir(p, pl)
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
	local cx = p.cx

	parte(pasta, Vector3.new(60, 0.4, 60), Vector3.new(cx, 0.2, 0), Color3.fromRGB(235, 235, 235))
	local parede = parte(pasta, Vector3.new(60, 14, 1), Vector3.new(cx, 7, -30.5), Color3.fromRGB(200, 60, 60))

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
	placa.Text = "Supermercado de " .. pl.Name .. "\nNivel 1"
	placa.Parent = sg
	p.placa = placa

	-- Balcao do caixa
	local balcao = parte(pasta, Vector3.new(12, 4, 3), Vector3.new(cx + 18, 2.4, 10), Color3.fromRGB(60, 60, 200))
	prompt(balcao, "Atender cliente", "Caixa", function(who)
		if who == p.dono then atender(p) end
	end)

	-- Comprar prateleiras
	for k, o in ipairs(OFERTAS) do
		local pad = parte(pasta, Vector3.new(8, 0.4, 4), Vector3.new(cx + (k - 3) * 11, 0.6, -26), o.cor)
		rotulo(pad, o.nome .. "\nR$" .. o.custo, 4, 18)
		prompt(pad, "Comprar", o.tipo .. ": " .. o.nome, function(who)
			if who ~= p.dono or p.tok ~= tok or #p.prat >= 8 then return end
			if not gastar(who, o.custo) then return end
			criarPrat(p, pasta, o)
		end)
	end

	-- Funcionarios (corpo + cabeca com rosto)
	local function corpo(nome, pos, cor)
		parte(pasta, Vector3.new(2, 4, 2), Vector3.new(pos.X, 2.4, pos.Z), cor)
		local cab = parte(pasta, Vector3.new(2.6, 2.6, 2.6), Vector3.new(pos.X, 5.7, pos.Z), Color3.fromRGB(255, 220, 180))
		cab.Shape = Enum.PartType.Ball
		rosto(cab, Enum.NormalId.Back)
		rotulo(cab, nome, 2.5, 15)
	end

	local function contratar(nome, custo, z, aoContratar)
		local feito = false
		local pad = parte(pasta, Vector3.new(6, 0.4, 6), Vector3.new(cx - 24, 0.6, z), Color3.fromRGB(40, 180, 80))
		local lab = rotulo(pad, nome .. "\nR$" .. custo, 4, 18)
		prompt(pad, "Contratar", nome .. " R$" .. custo, function(who)
			if who ~= p.dono or p.tok ~= tok or feito then return end
			if not gastar(who, custo) then return end
			feito = true
			lab.Text = nome .. "\ncontratado!"
			aoContratar()
		end)
	end

	contratar("Caixa", 300, 12, function()
		corpo("Caixa", Vector3.new(cx + 18, 2.9, 6), Color3.fromRGB(255, 200, 80))
		task.spawn(function()
			while p.tok == tok do
				task.wait(3)
				if p.tok == tok then atender(p) end
			end
		end)
	end)

	contratar("Repositor", 400, 22, function()
		corpo("Repositor", Vector3.new(cx - 12, 2.9, 8), Color3.fromRGB(80, 200, 255))
		task.spawn(function()
			while p.tok == tok do
				task.wait(4)
				if p.tok ~= tok then break end
				local alvo = nil
				for _, pr in ipairs(p.prat) do
					if pr.est <= 20 and (not alvo or pr.est < alvo.est) then alvo = pr end
				end
				if alvo then repor(p, alvo) end
			end
		end)
	end)

	-- Chegada de clientes (nivel alto = clientes mais rapidos)
	task.spawn(function()
		while p.tok == tok do
			local nv = 1
			if dados[pl] then nv = dados[pl].nivel end
			task.wait(math.max(2, 10 - #p.prat - (nv - 1)))
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
	p.fila = {}
	p.prat = {}
	parte(pasta, Vector3.new(60, 0.4, 60), Vector3.new(p.cx, 0.2, 0), Color3.fromRGB(160, 160, 160))
	local w = parte(pasta, Vector3.new(60, 14, 1), Vector3.new(p.cx, 7, -30.5), Color3.fromRGB(100, 100, 100))
	rotulo(w, "LOTE LIVRE", 4, 90)
end

for i = 1, NPLOTS do
	plots[i] = {i = i, cx = (i - 1) * ESP - 175, tok = 0}
	livre(plots[i])
end

-- Jogadores
local function entrar(pl)
	if dados[pl] then return end

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
	din.Value = 200

	-- Painel na tela
	local pg = pl:WaitForChild("PlayerGui")
	local sg = Instance.new("ScreenGui")
	sg.Name = "HUD"
	sg.ResetOnSpawn = false
	sg.Parent = pg
	local hud = Instance.new("TextLabel")
	hud.Size = UDim2.new(0, 260, 0, 64)
	hud.Position = UDim2.new(0.5, -130, 0, 50)
	hud.BackgroundColor3 = Color3.new(0, 0, 0)
	hud.BackgroundTransparency = 0.4
	hud.TextColor3 = Color3.new(1, 1, 1)
	hud.TextScaled = true
	hud.Font = Enum.Font.GothamBold
	hud.Parent = sg
	local cor = Instance.new("UICorner")
	cor.Parent = hud

	dados[pl] = {din = din, ganho = 0, nivel = 1, hud = hud}

	local meu = nil
	for _, p in ipairs(plots) do
		if not p.dono then
			meu = p
			break
		end
	end
	if not meu then
		pl:Kick("Cidade cheia")
		return
	end
	construir(meu, pl)
	dados[pl].plot = meu
	atualizar(pl)

	local function levar(ch)
		ch:WaitForChild("HumanoidRootPart")
		task.wait(0.3)
		ch:PivotTo(CFrame.new(meu.cx, 5, 24))
	end
	pl.CharacterAdded:Connect(levar)
	if pl.Character then task.spawn(levar, pl.Character) end
end

Players.PlayerAdded:Connect(entrar)
for _, pl in ipairs(Players:GetPlayers()) do
	task.spawn(entrar, pl)
end

Players.PlayerRemoving:Connect(function(pl)
	for _, p in ipairs(plots) do
		if p.dono == pl then livre(p) end
	end
	dados[pl] = nil
end)
