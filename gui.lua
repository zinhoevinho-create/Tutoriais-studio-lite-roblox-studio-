local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local pl = Players.LocalPlayer
local pg = pl:WaitForChild("PlayerGui")
local acao = RS:WaitForChild("Acao")
local estadoEv = RS:WaitForChild("Estado")

local lang = "pt"
local cat = nil
local est = nil
local shopAberta = false
local rebAberto = false

local T = {
	pt = {
		shop = "Loja", rebirth = "Rebirth", produtos = "Produtos (pacote x10)", prateleiras = "Prateleiras",
		melhorar = "Melhorar loja", maxloja = "Loja no maximo", comprar = "Comprar", bloq = "Nivel %d",
		tem = "Tem: %d", rebq = "Reiniciar TUDO?", sim = "Sim", nao = "Nao",
		pos = "Posicione a prateleira", ok = "OK", cancel = "Cancelar",
		dinheiro = "Dinheiro insuficiente", nivel = "Nivel insuficiente", nada = "Nada para colocar aqui",
		cheia = "Cheio", longe = "Chegue perto de uma prateleira", posicao = "Posicao invalida",
		limite = "Limite de 8 prateleiras", espaco = "Sem espaco na loja",
		n_Pao = "Pao", n_Farinha = "Farinha", n_Suco = "Suco", n_Videogame = "Videogame", n_GiftCard = "Gift Card",
		t_Padrao = "Prateleira Padrao", t_Geladeira = "Geladeira", t_Eletronicos = "Prateleira Eletronicos", t_GiftCard = "Prateleira Gift Card",
		l2 = "Loja Melhorada", l3 = "Loja Premium",
	},
	en = {
		shop = "Shop", rebirth = "Rebirth", produtos = "Products (pack of 10)", prateleiras = "Shelves",
		melhorar = "Upgrade store", maxloja = "Store maxed", comprar = "Buy", bloq = "Level %d",
		tem = "Have: %d", rebq = "Reset EVERYTHING?", sim = "Yes", nao = "No",
		pos = "Place the shelf", ok = "OK", cancel = "Cancel",
		dinheiro = "Not enough money", nivel = "Level too low", nada = "Nothing to put here",
		cheia = "Full", longe = "Get close to a shelf", posicao = "Invalid position",
		limite = "Limit of 8 shelves", espaco = "No room in the store",
		n_Pao = "Bread", n_Farinha = "Flour", n_Suco = "Juice", n_Videogame = "Video game", n_GiftCard = "Gift Card",
		t_Padrao = "Standard shelf", t_Geladeira = "Fridge", t_Eletronicos = "Electronics shelf", t_GiftCard = "Gift card shelf",
		l2 = "Improved store", l3 = "Premium store",
	},
	es = {
		shop = "Tienda", rebirth = "Rebirth", produtos = "Productos (paquete x10)", prateleiras = "Estantes",
		melhorar = "Mejorar tienda", maxloja = "Tienda al maximo", comprar = "Comprar", bloq = "Nivel %d",
		tem = "Tienes: %d", rebq = "Reiniciar TODO?", sim = "Si", nao = "No",
		pos = "Coloca el estante", ok = "OK", cancel = "Cancelar",
		dinheiro = "Dinero insuficiente", nivel = "Nivel insuficiente", nada = "Nada que colocar aqui",
		cheia = "Lleno", longe = "Acercate a un estante", posicao = "Posicion invalida",
		limite = "Limite de 8 estantes", espaco = "Sin espacio en la tienda",
		n_Pao = "Pan", n_Farinha = "Harina", n_Suco = "Jugo", n_Videogame = "Videojuego", n_GiftCard = "Tarjeta de regalo",
		t_Padrao = "Estante estandar", t_Geladeira = "Nevera", t_Eletronicos = "Estante de electronicos", t_GiftCard = "Estante de tarjetas",
		l2 = "Tienda mejorada", l3 = "Tienda premium",
	},
}

local function t(k, ...)
	local s = (T[lang] and T[lang][k]) or T.pt[k] or k
	if select("#", ...) > 0 then
		return string.format(s, ...)
	end
	return s
end

local BRANCO = Color3.new(1, 1, 1)
local VERDE = Color3.fromRGB(50, 170, 80)
local CINZA = Color3.fromRGB(90, 90, 100)
local ESCURO = Color3.fromRGB(30, 30, 40)

local function mk(classe, props, pai)
	local o = Instance.new(classe)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = pai
	return o
end

local function canto(o, r)
	mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)
end

local gui = mk("ScreenGui", {Name = "UI2", ResetOnSpawn = false, DisplayOrder = 5}, pg)

-- Tela de idioma
local fIdioma = mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, Visible = false, ZIndex = 30}, gui)
mk("TextLabel", {Size = UDim2.new(1, 0, 0.18, 0), Position = UDim2.new(0, 0, 0.1, 0), BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = BRANCO, Text = "Idioma / Language / Idioma", ZIndex = 31}, fIdioma)

-- Botoes principais
local btnLoja = mk("TextButton", {Size = UDim2.new(0, 120, 0, 46), Position = UDim2.new(0, 10, 0.36, 0), BackgroundColor3 = VERDE, TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "Loja"}, gui)
canto(btnLoja)
local btnReb = mk("TextButton", {Size = UDim2.new(0, 120, 0, 46), Position = UDim2.new(0, 10, 0.36, 56), BackgroundColor3 = Color3.fromRGB(170, 60, 190), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "Rebirth"}, gui)
canto(btnReb)

-- Botao B (colocar na prateleira)
local btnB = mk("TextButton", {Size = UDim2.new(0, 80, 0, 80), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -300, 1, -120), BackgroundColor3 = Color3.fromRGB(220, 120, 40), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "B"}, gui)
mk("UICorner", {CornerRadius = UDim.new(1, 0)}, btnB)
btnB.Activated:Connect(function()
	acao:FireServer("colocar")
end)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.B then
		acao:FireServer("colocar")
	end
end)

-- Aviso (toast)
local toast = mk("TextLabel", {Size = UDim2.new(0, 340, 0, 40), Position = UDim2.new(0.5, -170, 0.7, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "", Visible = false, ZIndex = 40}, gui)
canto(toast)
local toastId = 0
local function aviso(txt)
	toastId = toastId + 1
	local meu = toastId
	toast.Text = txt
	toast.Visible = true
	task.delay(2.2, function()
		if toastId == meu then toast.Visible = false end
	end)
end

-- Painel da loja
local fShop = mk("Frame", {Size = UDim2.new(0.62, 0, 0.8, 0), Position = UDim2.new(0.19, 0, 0.1, 0), BackgroundColor3 = ESCURO, BackgroundTransparency = 0.05, Visible = false, ZIndex = 10}, gui)
canto(fShop, 12)
local tituloShop = mk("TextLabel", {Size = UDim2.new(0.8, 0, 0, 36), Position = UDim2.new(0.02, 0, 0, 4), BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = BRANCO, TextXAlignment = Enum.TextXAlignment.Left, Text = "Loja", ZIndex = 11}, fShop)
local btnFechar = mk("TextButton", {Size = UDim2.new(0, 40, 0, 36), Position = UDim2.new(1, -46, 0, 4), BackgroundColor3 = Color3.fromRGB(190, 60, 60), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "X", ZIndex = 11}, fShop)
canto(btnFechar)
local lista = mk("ScrollingFrame", {Size = UDim2.new(1, -16, 1, -52), Position = UDim2.new(0, 8, 0, 46), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 6, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 11}, fShop)
mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, lista)

local function rebuildShop()
	for _, c in ipairs(lista:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end
	if not cat or not est then return end
	local ord = 0
	local function cab(txt)
		ord = ord + 1
		mk("TextLabel", {LayoutOrder = ord, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1, Text = txt, TextColor3 = Color3.fromRGB(255, 220, 80), Font = Enum.Font.GothamBold, TextScaled = true, ZIndex = 12}, lista)
	end
	local function linha(txt, custo, nivelReq, aoClicar)
		ord = ord + 1
		local ok = est.nivel >= nivelReq
		local f = mk("Frame", {LayoutOrder = ord, Size = UDim2.new(1, -8, 0, 48), BackgroundColor3 = Color3.fromRGB(50, 50, 62), ZIndex = 12}, lista)
		canto(f)
		mk("TextLabel", {Size = UDim2.new(0.56, 0, 1, 0), Position = UDim2.new(0.02, 0, 0, 0), BackgroundTransparency = 1, TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left, Text = txt, TextColor3 = BRANCO, Font = Enum.Font.Gotham, ZIndex = 13}, f)
		local rotuloBtn = t("comprar") .. " R$" .. custo
		if not ok then rotuloBtn = t("bloq", nivelReq) end
		local cor = CINZA
		if ok then cor = VERDE end
		local b = mk("TextButton", {Size = UDim2.new(0.38, 0, 0.8, 0), Position = UDim2.new(0.6, 0, 0.1, 0), BackgroundColor3 = cor, TextScaled = true, Text = rotuloBtn, TextColor3 = BRANCO, Font = Enum.Font.GothamBold, ZIndex = 13}, f)
		canto(b)
		if ok then
			b.Activated:Connect(aoClicar)
		end
	end

	cab(t("produtos"))
	for _, pr in ipairs(cat.prods) do
		local tem = 0
		if est.inv and est.inv[pr.id] then tem = est.inv[pr.id] end
		linha(t("n_" .. pr.id) .. " (" .. t("tem", tem) .. ")", pr.custo, pr.nivel, function()
			acao:FireServer("prod", pr.id)
		end)
	end

	cab(t("prateleiras"))
	for _, pr in ipairs(cat.prats) do
		linha(t("t_" .. pr.id), pr.custo, pr.nivel, function()
			acao:FireServer("prat", pr.id)
		end)
	end

	cab(t("melhorar"))
	local prox = est.tier + 1
	local l = cat.lojas[prox]
	if l then
		linha(t("l" .. prox), l.custo, l.nivel, function()
			acao:FireServer("loja")
		end)
	else
		ord = ord + 1
		mk("TextLabel", {LayoutOrder = ord, Size = UDim2.new(1, -8, 0, 36), BackgroundTransparency = 1, Text = t("maxloja"), TextColor3 = BRANCO, Font = Enum.Font.Gotham, TextScaled = true, ZIndex = 12}, lista)
	end
end

-- Confirmacao do rebirth
local fReb = mk("Frame", {Size = UDim2.new(0, 300, 0, 130), Position = UDim2.new(0.5, -150, 0.35, 0), BackgroundColor3 = ESCURO, Visible = false, ZIndex = 20}, gui)
canto(fReb, 12)
local rebTxt = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = BRANCO, Text = "", ZIndex = 21}, fReb)
local rebSim = mk("TextButton", {Size = UDim2.new(0, 120, 0, 44), Position = UDim2.new(0, 20, 0, 70), BackgroundColor3 = Color3.fromRGB(190, 60, 60), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "Sim", ZIndex = 21}, fReb)
canto(rebSim)
local rebNao = mk("TextButton", {Size = UDim2.new(0, 120, 0, 44), Position = UDim2.new(0, 160, 0, 70), BackgroundColor3 = CINZA, TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "Nao", ZIndex = 21}, fReb)
canto(rebNao)

-- Painel de posicionar prateleira
local fPos = mk("Frame", {Size = UDim2.new(0, 300, 0, 180), Position = UDim2.new(0.5, -150, 1, -200), BackgroundColor3 = ESCURO, BackgroundTransparency = 0.2, Visible = false, ZIndex = 15}, gui)
canto(fPos, 12)
local posTxt = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = BRANCO, Text = "", ZIndex = 16}, fPos)

local function seta(txt, x, y, dx, dz)
	local b = mk("TextButton", {Size = UDim2.new(0, 60, 0, 40), Position = UDim2.new(0, x, 0, y), BackgroundColor3 = Color3.fromRGB(70, 110, 200), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = txt, ZIndex = 16}, fPos)
	canto(b)
	b.Activated:Connect(function()
		acao:FireServer("mover", dx, dz)
	end)
end
seta("^", 120, 32, 0, -1)
seta("<", 50, 78, -1, 0)
seta("v", 120, 78, 0, 1)
seta(">", 190, 78, 1, 0)

local btnOk = mk("TextButton", {Size = UDim2.new(0, 130, 0, 40), Position = UDim2.new(0, 15, 0, 130), BackgroundColor3 = VERDE, TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "OK", ZIndex = 16}, fPos)
canto(btnOk)
local btnCan = mk("TextButton", {Size = UDim2.new(0, 130, 0, 40), Position = UDim2.new(0, 155, 0, 130), BackgroundColor3 = Color3.fromRGB(190, 60, 60), TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = "Cancelar", ZIndex = 16}, fPos)
canto(btnCan)
btnOk.Activated:Connect(function()
	acao:FireServer("ok")
end)
btnCan.Activated:Connect(function()
	acao:FireServer("cancelar")
end)

-- Textos conforme o idioma
local function textos()
	btnLoja.Text = t("shop")
	tituloShop.Text = t("shop")
	local n = 0
	if est then n = est.reb end
	btnReb.Text = t("rebirth") .. " (" .. n .. ")"
	rebTxt.Text = t("rebq")
	rebSim.Text = t("sim")
	rebNao.Text = t("nao")
	posTxt.Text = t("pos")
	btnOk.Text = t("ok")
	btnCan.Text = t("cancel")
	if shopAberta then rebuildShop() end
end

-- Idioma: 3 botoes
local langs = {{"pt", "Portugues"}, {"en", "English"}, {"es", "Espanol"}}
for i, l in ipairs(langs) do
	local b = mk("TextButton", {Size = UDim2.new(0.5, 0, 0.13, 0), Position = UDim2.new(0.25, 0, 0.32 + (i - 1) * 0.18, 0), BackgroundColor3 = VERDE, TextColor3 = BRANCO, TextScaled = true, Font = Enum.Font.GothamBold, Text = l[2], ZIndex = 31}, fIdioma)
	canto(b, 12)
	b.Activated:Connect(function()
		lang = l[1]
		fIdioma.Visible = false
		acao:FireServer("idioma", lang)
		textos()
	end)
end

-- Abrir/fechar
btnLoja.Activated:Connect(function()
	shopAberta = not shopAberta
	fShop.Visible = shopAberta
	if shopAberta then rebuildShop() end
end)
btnFechar.Activated:Connect(function()
	shopAberta = false
	fShop.Visible = false
end)
btnReb.Activated:Connect(function()
	fReb.Visible = true
end)
rebNao.Activated:Connect(function()
	fReb.Visible = false
end)
rebSim.Activated:Connect(function()
	fReb.Visible = false
	acao:FireServer("rebirth")
end)

-- Estado vindo do servidor
estadoEv.OnClientEvent:Connect(function(d)
	if type(d) ~= "table" then return end
	if d.cat then cat = d.cat end
	if d.perguntar then fIdioma.Visible = true end
	if d.msg then aviso(t(d.msg)) end
	if d.din then
		est = d
		fPos.Visible = d.colocando
		if d.colocando then
			shopAberta = false
			fShop.Visible = false
		end
		textos()
		if shopAberta then rebuildShop() end
	end
end)

-- Botao A (pulo) no lugar do botao de pulo padrao
local function aplicarA()
	pcall(function()
		local tg = pg:FindFirstChild("TouchGui") or pg:WaitForChild("TouchGui", 6)
		if not tg then return end
		local jb = tg:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		jb.Image = ""
		jb.PressedImage = ""
		jb.ImageTransparency = 1
		if jb:FindFirstChild("BotaoA") then return end
		local f = mk("Frame", {Name = "BotaoA", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(60, 180, 90), BackgroundTransparency = 0.1, Active = false}, jb)
		mk("UICorner", {CornerRadius = UDim.new(1, 0)}, f)
		mk("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "A", TextScaled = true, Font = Enum.Font.GothamBold, TextColor3 = BRANCO}, f)
	end)
end
task.spawn(aplicarA)
pl.CharacterAdded:Connect(function()
	task.wait(1)
	aplicarA()
end)

-- Avisa o servidor que a tela esta pronta (ele pergunta o idioma)
acao:FireServer("pronto")