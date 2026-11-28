--!native
--!optimize 2





if not LPH_OBFUSCATED then
	LPH_JIT = function(...)
		return ...;
	end;
	LPH_JIT_MAX = function(...)
		return ...;
	end;
	LPH_NO_VIRTUALIZE = function(...)
		return ...;
	end;
	LPH_NO_UPVALUES = function(f)
		return (function(...)
			return f(...);
		end);
	end;
	LPH_ENCSTR = function(...)
		return ...;
	end;
	LPH_ENCNUM = function(...)
		return ...;
	end;
	LPH_ENCFUNC = function(func, key1, key2)
		if key1 ~= key2 then return print("LPH_ENCFUNC mismatch") end
		return func
	end
	LPH_CRASH = function()
		return print(debug.traceback());
	end;
	SWG_DiscordUser = "miko"
	SWG_DiscordID = 1337
	SWG_SecondsLeft = 9999999999999999999999999999999
	SWG_Note = "scp,alpha"
	SWG_IsLifetime = true
end;


if (getgenv and getgenv() or _G).Library then
	(getgenv and getgenv() or _G).Library.Unload()
end

local Folder = "moneyblox"
makefolder(Folder)

local ImagesFolder = string.format( "%s\\%s\\", Folder, "Images" )
makefolder(ImagesFolder)

local FontsFolder = string.format( "%s\\%s\\", Folder, "FontsFolder" )
makefolder(FontsFolder)

local HitsoundFolder = string.format( "%s\\%s\\", Folder, "Hitsounds" )
makefolder(HitsoundFolder)

local SoundsFolder = string.format( "%s\\%s\\", Folder, "Sounds" )
makefolder(SoundsFolder)

local PicturesOnKillFolder = string.format( "%s\\%s\\", Folder, "PicturesOnKill" )

local CREATE_PRESET_IMAGES = isfolder(PicturesOnKillFolder)
makefolder(PicturesOnKillFolder)

local TempFolder = string.format( "%s\\%s\\", Folder, "TempFolder" )
makefolder(TempFolder)

local ConfigFolder = string.format( "%s\\%s\\", Folder, "Configs" )
makefolder(ConfigFolder)

local ThemeFolder = string.format( "%s\\%s\\", Folder, "Themes" )
makefolder(ThemeFolder)

local admin_join_asset, admin_leave_asset = "", ""
local Fonts, Images = LPH_JIT(function()
	local RunService = game:GetService("RunService")
	local HttpService = game:GetService("HttpService")

	local Fonts = {
		URL = "https://raw.githubusercontent.com/zg071/moneyblox/refs/heads/main/assets/",

		Names = {
			"Tahoma",
			"TahomaXP",
			"Comfortaa",
			"Verdana",
			"SmallestPixel7",
			"Proggy",
		},

		Data = {}
	}; do
		function Fonts.Load(font)
			if not RunService:IsStudio() then
				local TTF = string.format("%s%s.ttf", FontsFolder, font)
				local JSON = string.format("%s%s.json", FontsFolder, font)

				if not isfile(TTF) then
					local success, data = pcall(function()
						return game:HttpGet( string.format("%s%s.txt", Fonts.URL, font) )
					end)

					if success and data then
						writefile(TTF, base64_decode(data))
					else
						return
					end
				end

				if not isfile(JSON) then
					local Font = {
						name = font,
						faces = {{
							name = "Regular",
							weight = 400,
							style = "normal",
							assetId = getcustomasset(TTF)
						}}
					}

					writefile(JSON, HttpService:JSONEncode(Font))
				end

				local temp_TTF = string.format("%s%s.ttf", TempFolder, font)
				local temp_JSON = string.format("%s%s.json", TempFolder, font)
				writefile(temp_TTF, readfile(TTF))
				writefile(temp_JSON, HttpService:JSONEncode({
					name = font,
					faces = {{
						name = "Regular",
						weight = 400,
						style = "normal",
						assetId = getcustomasset(temp_TTF)
					}}
				}))

				Fonts.Data[font] = Font.new(getcustomasset(temp_JSON), Enum.FontWeight.Regular)
			end
		end

		function Fonts.Get(font)
			return Fonts.Data[font]
		end

		for _,font in Fonts.Names do
			Fonts.Load(font)
		end
	end

	local Images = {
		URL = "https://raw.githubusercontent.com/zg071/moneyblox/refs/heads/main/assets/",

		Names = {
			"combat",
			"visuals",
			"misc",
			"config",
			"checkers",
			"saturation",
			"scrollbar",
			"lines"
		},

		Data = {}
	}; do
		function Images.Load(image)
			if not RunService:IsStudio() then
				local PNG = string.format("%s%s.png", ImagesFolder, image)

				if not isfile(PNG) then
					local success, data = pcall(function()
						return game:HttpGet( string.format( "%s%s.txt", Images.URL, image ) )
					end)

					if success and data then
						writefile(PNG, base64_decode(data))
					else
						return
					end
				end

				Images.Data[image] = getcustomasset(PNG)
			end
		end

		function Images.Get(image)
			return Images.Data[image]
		end

		for _,image in Images.Names do
			Images.Load(image)
		end
	end

	local Boykisser = {
		URL = "https://raw.githubusercontent.com/zg071/moneyblox/refs/heads/main/assets/",
	}; do
		function Boykisser.Load()
			if RunService:IsStudio() then return end
			local PNG = string.format("%s%s.png", ImagesFolder, "boykisser")
			if not isfile(PNG) then
				local done = false
				local success, data = pcall(function()
					return game:HttpGet(string.format("%s%s.txt", Boykisser.URL, "boykisser"))
				end)
				if success and data then
					local ok, decoded = pcall(function()
						return base64_decode(data)
					end)
					if ok and decoded then
						writefile(PNG, decoded)
						done = true
					end
				end
				if not done then
					local s2, d2 = pcall(function()
						return game:HttpGet(string.format("%s%s.png", Boykisser.URL, "boykisser"))
					end)
					if s2 and d2 then
						writefile(PNG, d2)
						done = true
					end
				end
				if not done then
					return
				end
			end
			local ok, asset = pcall(function()
				return getcustomasset(PNG)
			end)
			if ok and asset then
				boykisser_asset = asset
			end
		end
		Boykisser.Load()
	end

	local AdminSounds = {
		URL = "https://github.com/zg071/moneyblox/raw/refs/heads/main/assets/",
		Names = {"admjoin", "admleave"},
		Data = {}
	}; do
		function AdminSounds.Load(name)
			if RunService:IsStudio() then return "" end
			local MP3 = string.format("%s%s.mp3", SoundsFolder, name)
			if not isfile(MP3) then
				local success, data = pcall(function()
					return game:HttpGet(AdminSounds.URL .. name .. ".mp3")
				end)
				if success and data then
					local ok, decoded = pcall(function()
						return base64_decode(data)
					end)
					if ok and decoded then
						writefile(MP3, decoded)
					else
						writefile(MP3, data)
					end
				else
					return ""
				end
			end
			if isfile(MP3) then
				local ok, asset = pcall(function()
					return getcustomasset(MP3)
				end)
				if ok and asset then
					AdminSounds.Data[name] = asset
					return asset
				end
			end
			return ""
		end
		admin_join_asset = AdminSounds.Load("admjoin")
		admin_leave_asset = AdminSounds.Load("admleave")
	end
	return Fonts, Images
end)();
local boykisser_asset = ""
local Library, Utility = LPH_JIT(function()
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local HttpService = game:GetService("HttpService")
	local GuiService = game:GetService("GuiService")
	local TweenService = game:GetService("TweenService")
	local Stats = game:GetService("Stats")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera

	local Env = RunService:IsStudio() and _G or getgenv()
	local HiddenUI = RunService:IsStudio() and game.Players.LocalPlayer.PlayerGui  or game:GetService("CoreGui")
	local Converts = {
		[0] = "0",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
	}
	local KeyConverters = {
		escape = "ESC",
		backquote = "`",
		backspace = "BSP",
		slash = "/",
		leftquote = "'",
		rightquote = '"',
		leftbracket = "[",
		rightbracket = "]",
		semicolon = ";",
		comma = ",",
		period = ".",
		backslash = "\\",
		minus = "-",
		equals = "=",
		space = "SPC",
		[ "return" ] = "ENT",
		tab = "TAB",
		capslock = "CAP",
		leftshift = "LSH",
		mousebutton1 = "MB1",
		mousebutton2 = "MB2",
		mousebutton3 = "MB3",
		rightshift = "RSH",
		leftcontrol = "CTRL",
		leftalt = "ALT",
		leftsuper = "WIN",
		rightcontrol = "CTRL",
		rightalt = "ALT",
		rightsuper = "WIN",
		insert = "INS",
		delete = "DEL",
		home = "HME",
		pageup = "PUD",
		pagedown = "PDN",
		up = "UP",
		down = "DWN",
		left = "LFT",
		right = "RGT",
		numlock = "NUM",
		numpad0 = "N0",
		numpad1 = "N1",
		numpad2 = "N2",
		numpad3 = "N3",
		numpad4 = "N4",
		numpad5 = "N5",
		numpad6 = "N6",
		numpad7 = "N7",
		numpad8 = "N8",
		numpad9 = "N9",
	}
	local Library = {
		TweenSpeed = 0.4,
		TweenStyle = Enum.EasingStyle.Exponential,

		ThemeObjects = {},

		Font = Fonts.Get("Verdana"),
		FontSize = 16,

		Flags = {},
		ConfigFlags = {},

		Popups = {},

		CopiedColor = nil,

		Fps = 0,

		Images = {
			Lines = Images.Get("lines"),
			ScrollBar = Images.Get("scrollbar"),
			Saturation = Images.Get("saturation"),
			Checkers = Images.Get("checkers")
		},

		Theme = {
			outline = Color3.fromRGB(8, 6, 12),
			inline = Color3.fromRGB(34, 28, 46),
			["inline hovering"] = Color3.fromRGB(44, 37, 58),

			background = Color3.fromRGB(22, 18, 31),
			["dock background"] = Color3.fromRGB(15, 12, 21),

			accent = Color3.fromRGB(168, 85, 247),

			text = Color3.fromRGB(235, 231, 245),
			["dark text"] = Color3.fromRGB(94, 84, 119),
		},

	}; Library.__index = Library
	do
		Library.Utility = { Objects = {}, Connections = {} }; local Utility = Library.Utility do
			function Utility.New(object, props, theme)
				local Obj = Instance.new(object)

				if object == "TextButton" then
					Obj.AutoButtonColor = false
					Obj.Text = ""
					Obj.Style = Enum.ButtonStyle.Custom
				end

				if props then
					for prop, val in props do



						Obj[prop] = val
					end
				end

				if theme then
					Library.AddObjectTheme(Obj, theme)
				end

				table.insert(Utility.Objects, Obj)

				return Obj
			end

			function Utility.Signal(connection)
				table.insert(Utility.Connections, connection)

				return connection
			end

			function Utility.GetTransparency(obj)
				if obj:IsA("Frame") then
					return "BackgroundTransparency"
				elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
					return { "TextTransparency", "BackgroundTransparency" }
				elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					return { "BackgroundTransparency", "ImageTransparency" }
				elseif obj:IsA("ScrollingFrame") then
					return { "BackgroundTransparency", "ScrollBarImageTransparency" }
				elseif obj:IsA("TextBox") then
					return { "TextTransparency", "BackgroundTransparency" }
				elseif obj:IsA("UIStroke") then
					return "Transparency"
				end

				return nil
			end

			function Utility.Round(number, float)
				local Mult = 1 / (float or 1)

				return math.floor(number * Mult + 0.5) / Mult
			end


			function Utility.PositionOver(position, object, addedy)
				addedy = addedy or 0

				local posX, posY = object.AbsolutePosition.X, (object.AbsolutePosition.Y - addedy)
				local size = object.AbsoluteSize
				local sizeX, sizeY = posX + size.X, posY + size.Y + addedy

				if position.X >= posX and position.Y >= posY and position.X <= sizeX and position.Y <= sizeY then
					return true
				end

				return false
			end

			function Utility.MouseOver(object, input)
				local posX, posY = object.AbsolutePosition.X, object.AbsolutePosition.Y
				local size = object.AbsoluteSize
				local sizeX, sizeY = posX + size.X, posY + size.Y
				local position = input.Position

				if position.X >= posX and position.Y >= posY and position.X <= sizeX and position.Y <= sizeY then
					return true
				end

				return false
			end

			function Utility.Lerp(a, b, c)
				c = c or 1 / 8

				local offset = math.abs(b - a)
				if (offset < c) then
					return b
				end

				return a + (b - a) * c
			end

			function Utility.StringToEnum(enumstring)
				local EnumType, EnumValue = enumstring:match("Enum%.([^%.]+)%.(.+)")

				if EnumType and EnumValue then
					return Enum[EnumType][EnumValue]
				end

				return nil
			end

			function Utility.TextTriggers(text)
				local Triggers = {
					["{hour}"] = os.date("%H"),
					["{minute}"] = os.date("%M"),
					["{second}"] = os.date("%S"),
					["{ap}"] = os.date("%p"),
					["{month}"] = os.date("%b"),
					["{day}"] = os.date("%d"),
					["{year}"] = os.date("%Y"),
					["{fps}"] = Library.Fps,
					["{user}"] = SWG_DiscordUser or "admin",
					["{ping}"] = RunService:IsStudio() and 0 or math.floor(Stats.PerformanceStats.Ping:GetValue() or 0),
					["{time}"] = os.date("%H:%M:%S"),
					["{date}"] = os.date("%b. %d, %Y"),
					["{game}"] = Game and Game.Name or "Universal",
					["{n}"] = "\n"
				}

				for i,v in Triggers do
					text = string.gsub(text, i, v)
				end

				return text
			end

			function Utility.ToTitleCase(str)
				return str:gsub("(%a)([%w_']*)", function(first, rest)
					return first:upper() .. rest:lower()
				end)
			end

			function Utility.IsScrollable(frame)
				local CanvasSize = frame.AbsoluteCanvasSize
				local WindowSize = frame.AbsoluteWindowSize

				return CanvasSize.Y > WindowSize.Y
			end

			function Utility.IsAtBottom(frame)
				return frame.CanvasPosition.Y == frame.AbsoluteCanvasSize.Y - frame.AbsoluteWindowSize.Y
			end

			function Utility.RichText(text, color)
				return string.format('<font color="rgb(%s, %s, %s)">%s</font>', math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255), text)
			end

			function Utility.GetFiles(folder, extensions)
				if not isfolder(folder) then
					makefolder(folder)
				end

				local Files = isfolder(folder) and listfiles(folder) or {}
				local StoredFiles = {}
				local FileNames = {}

				for _,v in Files do
					for _,ext in extensions do
						if v:find(ext) then
							StoredFiles[#StoredFiles + 1] = v
							FileNames[#FileNames + 1] = v:gsub(folder, ""):gsub(ext, "")
						end
					end
				end

				return StoredFiles, FileNames
			end
		end

		Library.ScreenGui = Utility.New("ScreenGui", {
			Name = "\0",
			DisplayOrder = 1,
			Parent = HiddenUI,
			IgnoreGuiInset = true,
		})

		Library.ScreenGuiPopups = Utility.New("ScreenGui", {
			Name = "\0",
			DisplayOrder = -1,
			Parent = HiddenUI,
			IgnoreGuiInset = true,
		})

		local ItemsHolder = Utility.New("Frame", {
			Name = "leftholder",
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.new(0, 0, 0, 60),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Parent = Library.ScreenGuiPopups,
		})

		Utility.New("UIListLayout", {
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ItemsHolder
		})

		Library.NotificationHolder = ItemsHolder

		function Library.Tween(obj, props, tweeninfo)
			tweeninfo = tweeninfo or TweenInfo.new(Library.TweenSpeed, Library.TweenStyle)

			local Tween = TweenService:Create(obj, tweeninfo, props)

			Tween:Play()

			return Tween
		end

		function Library.Fade(obj, prop, vis)
			if not ((obj:IsA("UIStroke") and obj.Enabled or obj.Visible) and prop) then
				return
			end

			local OldTransparency = obj[prop]
			obj[prop] = vis and 1 or OldTransparency

			local Tween = Library.Tween(obj, { [prop] = vis and OldTransparency or 1 })

			Utility.Signal(Tween.Completed:Connect(function()
				if not vis then
					task.wait()
					obj[prop] = OldTransparency
				end
			end))

			return Tween
		end

		function Library.AddObjectTheme(object, props)
			local Theme = {
				Props = props,
				Object = object
			}

			for prop,v in props do
				if type(v) == "string" then
					object[prop] = Library.Theme[v]
				elseif type(v) == "function" then
					object[prop] = v()
				end
			end

			Library.ThemeObjects[object] = Theme
		end

		function Library.ChangeObjectTheme(object, props, tweened)
			local Theme = Library.ThemeObjects[object]

			if Theme then
				Theme.Props = props

				for prop,v in props do
					if type(v) == "string" then
						if tweened then
							Theme.Tween = Library.Tween(object, {
								[prop] = Library.Theme[v]
							})
						else
							object[prop] = Library.Theme[v]
						end
					elseif type(v) == "function" then
						object[prop] = v()
					end
				end
			end
		end

		function Library.UpdateTheme(theme, color)
			if not Library.Theme[theme] then
				return
			end

			Library.Theme[theme] = color

			for _,themeobj in Library.ThemeObjects do
				for prop,val in themeobj.Props do
					if val == theme then
						if themeobj.Tween then
							themeobj.Tween:Cancel()
						end

						themeobj.Object[prop] = color
					end
				end
			end
		end

		function Library.Config(cfg, default)
			local Table = { }

			for name, val in cfg do
				Table[name:lower()] = val
			end

			for name, val in default do
				if Table[name] == nil then
					Table[name] = val
				end
			end

			return Table
		end

		function Library.Resize(holder, box)
			local Start, StartSize, Resizing;
			local CurrentSize = holder.Size
			local OriginalSize = holder.Size

			Utility.Signal(box.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Resizing = true
					Start = input.Position
					StartSize = holder.Size
				end
			end))

			Utility.Signal(UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
					local ViewportSize = Camera.ViewportSize
					CurrentSize = UDim2.new(0, math.clamp(StartSize.X.Offset + (input.Position.X - Start.X), OriginalSize.X.Offset, ViewportSize.x), 0, math.clamp(StartSize.Y.Offset + (input.Position.Y - Start.Y), OriginalSize.Y.Offset, ViewportSize.y))
					holder.Size = CurrentSize
				end
			end))

			Utility.Signal(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Resizing = false
				end
			end))
		end

		function Library.Dragging(holder, box, useinset)
			useinset = useinset == nil and true or useinset

			local Start, StartPos, Dragging;
			local CurrentPos;
			local Inset = GuiService:GetGuiInset( );

			Utility.Signal(box.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
					Start = input.Position
					StartPos = holder.AbsolutePosition
				end
			end))

			Utility.Signal(UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
					local MaxSize = holder.AbsoluteSize
					local ViewportSize = Camera.ViewportSize
					CurrentPos = UDim2.new(0, math.clamp(StartPos.X + (input.Position.X - Start.X), 0, ViewportSize.x - MaxSize.x), 0, math.clamp(StartPos.Y + (input.Position.Y - Start.Y + 36), 0, ViewportSize.y - MaxSize.y) + ( useinset and (Inset.Y / 2) or 0 ))
					holder.Position = CurrentPos
				end
			end))

			Utility.Signal(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end))
		end

		function Library.CreateList(cfg)
			cfg = cfg or {}; cfg = Library.Config(cfg, {
				namestart = "Key",
				nameend = "binds",
				size = 150,
			})

			local List = {
				Objects = { },

				Items = { },

				ShowMode = cfg.showmode,

				View = "All",
			}

			function List.Refresh()
				for _, item in List.Items do
					if item.LastText ~= nil then
						item.Set(item.LastValue, item.LastText, item.LastMode, item.LastKey, item.LastOn)
					end
				end
			end

			function List.FitWidth()
				if not List.Objects.accent then return end
				local w = 150
				for _, item in List.Items do
					if item.LastText ~= nil then
						local s = "[" .. (item.LastKey or "-") .. "] " .. item.LastText .. " [" .. (item.LastMode or "") .. "]"
						w = math.max(w, #s * 7 + 50)
					end
				end
				List.Objects.accent.Size = UDim2.new(0, w, 0, 0)
			end

			local Objects = List.Objects; do
			Objects.accent = Utility.New("Frame", {
				Name = "accent",
				Position = UDim2.new(0, 20, 0.5, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.new(0, cfg.size, 0, 0),
				BorderSizePixel = 0,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(19, 19, 19),
				BackgroundTransparency = 0.5,
				Parent = Library.ScreenGuiPopups,
			})

				Library.Dragging(Objects.accent, Objects.accent, true)

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					BackgroundTransparency = 0.5,
					Parent = Objects.accent,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.background,
				})

				Objects.dock_background = Utility.New("Frame", {
					Name = "dock_background",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 23),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Parent = Objects.background,
				}, { BackgroundColor3 = "dock background" })

				Objects.textholder = Utility.New("Frame", {
					Name = "textholder",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.dock_background,
				})

				Utility.New("UIPadding", {
					PaddingRight = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					Parent = Objects.textholder,
				})

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.textholder,
				})

				Objects.text = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.namestart,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "text",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "text" })

				Objects.text2 = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(220, 100, 100),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.nameend,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "accent",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "accent" })

				Objects.content = Utility.New("Frame", {
					Name = "content",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.content,
					Padding = UDim.new(0, 0),
				})
			end

			function List.Add()
				local Item = {}

				local Holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					Visible = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.content,
				})

				Utility.New("UIPadding", {
					Parent = Holder,
					PaddingBottom = UDim.new(0, 8),
				})

				local Text = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "",
					Name = "text",
					TextStrokeTransparency = 0,
					Size = UDim2.new(1, -16, 0, 0),
					Position = UDim2.new(0, 8, 0, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Holder,
				}, { TextColor3 = "text" })

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Parent = Text,
				})

				local Accent = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(220, 100, 100),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "[]",
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "accent",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Text,
				}, { TextColor3 = "accent" })

				function Item.Set(value, text, mode, key, funcOn)
					Item.LastValue, Item.LastText, Item.LastMode, Item.LastKey, Item.LastOn = value, text, mode, key, funcOn
					local showAll = List.View == "All"
					Holder.Visible = showAll and funcOn or value
					Text.Text = string.format("[%s] %s", key or "-", text)
					Text.TextSize = 12
					Accent.Text = string.format("[%s]", mode)
					Accent.Visible = value
					if showAll and funcOn and not value then
						Text.TextColor3 = Color3.fromRGB(126, 126, 126)
					else
						Text.TextColor3 = Color3.fromRGB(230, 230, 230)
					end
					List.FitWidth()
				end

				table.insert(List.Items, Item)

				return Item
			end

			function List.Status(value)
				Objects.accent.Visible = value
			end

			return List
		end

		local KeybindList = Library.CreateList()
		Library.KeybindsList = KeybindList



		function Library.ColorpickerWindow(self)
			local Popup = {
				Visible = false,

				Tweening = false,

				Objects = { },

				Flag = nil,

				SetFunc = function() end,

				Alpha = 1,

				Color = Color3.new(1, 1, 1),

				HuePos = nil,
			}

			local Objects = Popup.Objects; do
				Objects.accent = Utility.New("Frame", {
					Size = UDim2.new(0, 200, 0, 200),
					Name = "accent",
					Position = UDim2.new(0, 0, 0, 0),
					Visible = false,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Library.ScreenGui,
				}, { BackgroundColor3 = "accent" })

				Objects.outline = Utility.New("Frame", {
					Name = "outline",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.accent,
				}, { BackgroundColor3 = "outline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.outline,
				}, { BackgroundColor3 = "background" })

				Utility.New("UIPadding", {
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					Parent = Objects.background,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.background,
				})

				Objects.satholder = Utility.New("Frame", {
					Name = "satholder",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0, 186),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Parent = Objects.satholder,
				})

				Objects.saturation = Utility.New("TextButton", {
					Name = "saturation",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 186, 0, 186),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 0, 4),
					Parent = Objects.satholder,
				})

				Objects.saturationimage = Utility.New("ImageLabel", {
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Image = Library.Images.Saturation,
					BackgroundTransparency = 1,
					Name = "saturationimage",
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.saturation,
				})

				Objects.saturationpickeroutline = Utility.New("Frame", {
					Name = "saturationpickeroutline",
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 3, 0, 3),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.saturationimage,
				})

				Objects.saturationpicker = Utility.New("Frame", {
					Name = "saturationpicker",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.saturationpickeroutline,
				})

				Objects.hue = Utility.New("TextButton", {
					Name = "hue",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 12, 0, 186),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.satholder,
				})

				Objects.huepickeroutline = Utility.New("Frame", {
					Name = "huepickeroutline",
					Position = UDim2.new(0, 0, 0.5, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 3),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.hue,
				})

				Objects.huepicker = Utility.New("Frame", {
					Name = "huepicker",
					Position = UDim2.new(0, 0, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.huepickeroutline,
				})

				Utility.New("UIGradient", {
					Rotation = -90,
					Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					},
					Parent = Objects.hue,
				})

				Objects.alphaimage = Utility.New("ImageLabel", {
					ScaleType = Enum.ScaleType.Tile,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "alphaimage",
					Image = Library.Images.Checkers,
					TileSize = UDim2.new(0, 6, 0, 6),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(0, 186, 0, 12),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Objects.alpha = Utility.New("TextButton", {
					Name = "alpha",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.alphaimage,
				})

				Objects.UIGradient = Utility.New("UIGradient", {
					Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0)
					},
					Parent = Objects.alpha,
				})

				Objects.alphapickeroutline = Utility.New("Frame", {
					Name = "alphapickeroutline",
					Position = UDim2.new(0.5, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 3, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.alpha,
				})

				Objects.alphapicker = Utility.New("Frame", {
					Name = "alphapicker",
					Position = UDim2.new(0, 1, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.alphapickeroutline,
				})

				Objects.buttonline = Utility.New("Frame", {
					Name = "buttonline",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 186, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Utility.New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.buttonline,
				})

				Library.Button({
					holder = Objects.buttonline,
				}, {Name = "Copy", Callback = function()
					Library.CopiedColor = Popup.Color
				end})

				Library.Button({
					holder = Objects.buttonline,
				}, {Name = "Paste", Callback = function()
					if not Library.CopiedColor then
						Library.Notification("Please copy a color first.", 5)
						return
					end

					Popup.Set(Library.CopiedColor, Popup.Alpha, false)
				end})
			end

			local Hue, Sat, Val;
			function Popup.Set(color, alpha, ignore)
				alpha = alpha or Popup.Alpha

				Hue, Sat, Val = color:ToHSV()

				Popup.Color = color
				Popup.Alpha = alpha

				if not ignore then
					Library.Tween(Objects.saturationpickeroutline, {
						Position = UDim2.new(
							Sat,
							0,
							1 - Val,
							0
						),
						AnchorPoint = Vector2.new(Sat, 1 - Val)
					})

					Popup.HuePos = Hue

					Library.Tween(Objects.huepickeroutline, {
						Position = UDim2.new(
							0,
							0,
							Hue,
							0
						),
						AnchorPoint = Vector2.new(0, Hue)
					})

					Library.Tween(Objects.alphapickeroutline, {
						Position = UDim2.new(
							1 - alpha,
							0,
							0,
							0
						),
						AnchorPoint = Vector2.new(1 - alpha, 0)
					})
				end

				Popup.SetFunc(color, alpha)

				Objects.huepicker.BackgroundColor3 = Color3.fromHSV(Popup.HuePos, 1, 1)
				Objects.saturationpicker.BackgroundColor3 = color
				Objects.alphapicker.BackgroundColor3 = color
				Objects.saturation.BackgroundColor3 = Color3.fromHSV(Popup.HuePos, 1, 1)
			end

			function Popup.Open(visibility, position)
				if Popup.Tweening or Popup.Visible == visibility then
					return
				end

				Popup.Tweening = true

				Popup.Visible = visibility

				if Popup.Visible then
					Objects.accent.Visible = true

					Objects.saturationpickeroutline.Position = UDim2.new(0, 0, 0, 0)
					Objects.alphapickeroutline.Position = UDim2.new(0, 0, 0, 0)
					Objects.huepickeroutline.Position = UDim2.new(0, 0, 0, 0)
				end

				local ParentObjects = Objects.accent:GetDescendants()

				table.insert(ParentObjects, Objects.accent)

				local Tween;
				for _, obj in ParentObjects do
					local Index = Utility.GetTransparency(obj)
					if not Index then continue end

					if type(Index) == "table" then
						for _, prop in Index do
							Tween = Library.Fade(obj, prop, Popup.Visible)
						end
					else
						Tween = Library.Fade(obj, Index, Popup.Visible)
					end
				end

				if not Popup.Visible then
					Library.Tween(Objects.saturationpickeroutline, {
						Position = UDim2.new(
							0,
							0,
							0,
							0
						),
						AnchorPoint = Vector2.new(0, 0)
					})

					Library.Tween(Objects.huepickeroutline, {
						Position = UDim2.new(
							0,
							0,
							0,
							0
						),
						AnchorPoint = Vector2.new(0, 0)
					})

					Library.Tween(Objects.alphapickeroutline, {
						Position = UDim2.new(
							0,
							0,
							0,
							0
						),
						AnchorPoint = Vector2.new(0, 0)
					})
				end

				if position then
					Objects.accent.Position = UDim2.new(0, position.X, 0, position.Y)
				end

				Utility.Signal(Tween.Completed:Connect(function()
					Objects.accent.Visible = Popup.Visible

					Popup.Tweening = false
				end))
			end

			function Popup.SlideSaturation(input)
				if Popup.Tweening or not Popup.Visible then return end

				local SizeX = math.clamp((input.Position.X - Objects.saturation.AbsolutePosition.X) / Objects.saturation.AbsoluteSize.X, 0, 1)
				local SizeY = 1 - math.clamp((input.Position.Y - Objects.saturation.AbsolutePosition.Y) / Objects.saturation.AbsoluteSize.Y, 0, 1)

				Objects.saturationpickeroutline.Position = UDim2.new(SizeX, 0, 1 - SizeY, 0)
				Objects.saturationpickeroutline.AnchorPoint = Vector2.new(SizeX, 1 - SizeY)

				Popup.Set(Color3.fromHSV(Popup.HuePos, SizeX, SizeY), Popup.Alpha, true)
			end

			Utility.Signal(Objects.saturation.MouseButton1Down:Connect(function()
				Popup.SlidingSaturation = true
				Popup.SlideSaturation({ Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset( ).Y) })
			end))

			function Popup.SlideHue(input)
				if Popup.Tweening or not Popup.Visible then return end

				local SizeY = math.clamp((input.Position.Y - Objects.hue.AbsolutePosition.Y) / Objects.hue.AbsoluteSize.Y, 0, 1)

				Objects.huepickeroutline.Position = UDim2.new(0, 0, SizeY, 0)
				Objects.huepickeroutline.AnchorPoint = Vector2.new(0, SizeY)
				Popup.HuePos = SizeY

				Popup.Set(Color3.fromHSV(SizeY, Sat, Val), Popup.Alpha, true)
			end

			Utility.Signal(Objects.hue.MouseButton1Down:Connect(function()
				Popup.SlidingHue = true
				Popup.SlideHue({ Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset( ).Y) })
			end))

			function Popup.SlideAlpha(input)
				if Popup.Tweening or not Popup.Visible then return end

				local SizeX = math.clamp((input.Position.X - Objects.alpha.AbsolutePosition.X) / Objects.alpha.AbsoluteSize.X, 0, 1)

				Objects.alphapickeroutline.Position = UDim2.new(SizeX, 0, 0, 0)
				Objects.alphapickeroutline.AnchorPoint = Vector2.new(SizeX, 0)
				Popup.Set(Popup.Color, 1 - SizeX, true)
			end

			Utility.Signal(Objects.alpha.MouseButton1Down:Connect(function()
				Popup.SlidingAlpha = true
				Popup.SlideAlpha({ Position = UserInputService:GetMouseLocation() })
			end))

			Utility.Signal(UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					if Popup.SlidingSaturation then Popup.SlideSaturation({ Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset( ).Y) }) end
					if Popup.SlidingHue then Popup.SlideHue({ Position = UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset( ).Y) }) end
					if Popup.SlidingAlpha then Popup.SlideAlpha({ Position = UserInputService:GetMouseLocation() }) end
				end
			end))

			Utility.Signal(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Popup.SlidingSaturation, Popup.SlidingHue, Popup.SlidingAlpha = false, false, false
				end
			end))

			return Popup
		end

		function Library.Window(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				size = UDim2.fromOffset(602, 502),
				open = true,
				namestart = "miko",
				nameend = "hub",
			})

			local Window = {
				Objects = { },

				Visible = cfg.open,

				Tweening = false,

				TabsTweening = false,

				Tabs = { },

				CurrentPage = nil,
			}

			local Objects = Window.Objects; do
				Objects.ScreenGui = Utility.New("ScreenGui", {
					Name = "\0",
					Parent = HiddenUI,
					IgnoreGuiInset = true,
				})

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					Position = UDim2.new(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = cfg.size,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.ScreenGui,
				}, { BackgroundColor3 = "accent" })

				Objects.outline = Utility.New("Frame", {
					Name = "outline",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.accent,
				}, { BackgroundColor3 = "outline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.outline,
				}, { BackgroundColor3 = "background" })

				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 44),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -14, 1, -58),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Objects.dock_background = Utility.New("Frame", {
					Name = "dock_background",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 30),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Parent = Objects.background,
				}, { BackgroundColor3 = "dock background" })

				Library.Dragging(Objects.accent, Objects.dock_background, true)

				Objects.textholder = Utility.New("Frame", {
					Name = "textholder",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.dock_background,
				})

				Utility.New("UIPadding", {
					PaddingRight = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					Parent = Objects.textholder,
				})

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.textholder,
				})

				Objects.text = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.namestart,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "text",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "text" })

				Objects.text2 = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(220, 100, 100),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.nameend,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "accent",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "accent" })

				Objects.shadow = Utility.New("Frame", {
					Name = "shadow",
					Position = UDim2.new(0, 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 8),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 16, 16),
					Parent = Objects.dock_background,
				})

				Utility.New("UIGradient", {
					Rotation = 90,
					Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					},
					Parent = Objects.shadow,
				})

				Objects.tabsholder = Utility.New("Frame", {
					BackgroundTransparency = 1,
					Name = "tabsholder",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 105, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalFlex = Enum.UIFlexAlignment.Fill,
					Parent = Objects.tabsholder,
				})

				Window.tabsholder = Objects.tabsholder

				Window.pageholder = Objects.holder
			end

			function Window.Open()
				if Window.Tweening then
					return
				end

				Window.Tweening = true

				Library.ColorpickerWindow.Open(false)

				Window.Visible = not Window.Visible

				if Window.Visible then
					Objects.accent.Visible = true
				end

				for _,popup in Library.Popups do
					popup.Open(false)
				end

				local Tween;
				for _,obj in Objects.ScreenGui:GetDescendants() do
					local Index = Utility.GetTransparency(obj)

					if not Index then continue end

					if type(Index) == "table" then
						for _,prop in Index do
							Tween = Library.Fade(obj, prop, Window.Visible)
						end
					else
						Tween = Library.Fade(obj, Index, Window.Visible)
					end
				end

				Utility.Signal(Tween.Completed:Connect(function()
					Window.Tweening = false
					Objects.accent.Visible = Window.Visible
				end))
			end

			return setmetatable(Window, Library)
		end

		function Library.Tab(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "Tab",
				image = "rbxassetid://12941020168",
				size = 45,
				side = false,
			})

			local Tab = {
				Selected = false,

				Objects = { },

				Name = cfg.name,

				Tabs = {}
			}

			local Objects = Tab.Objects; do
				Objects.holder = Utility.New("TextButton", {
					BackgroundTransparency = 1,
					Name = "holder",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 105, 0, 88),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.tabsholder,
				})

				Objects.icon = Utility.New("ImageLabel", {
					ImageColor3 = Color3.fromRGB(215, 215, 215),
					ScaleType = Enum.ScaleType.Fit,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = cfg.image,
					BackgroundTransparency = 1,
					Position = UDim2.new(0.5, -2, 0.5, 0),
					Size = UDim2.new(0, cfg.size, 0, cfg.size),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				}, { ImageColor3 = "text" })

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					Position = UDim2.new(1, -2, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 2, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.holder,
				}, { BackgroundColor3 = "accent" })

				Objects.pagetabsholder = Utility.New("Frame", {
					Name = "pagetabsholder",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 115, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -115, 0, 32),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.pageholder,
				})

				Utility.New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Parent = Objects.pagetabsholder,
				})

				Tab.pagetabsholder = Objects.pagetabsholder

				Objects.page = Utility.New("Frame", {
					Name = "page",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 115, 0, 42),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -115, 1, -42),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.pageholder,
				})

				Tab.pageholder = Objects.page
			end

			function Tab.Set(status, nested)
				Library.ChangeObjectTheme(Objects.accent, {
					BackgroundColor3 = status and "accent" or "inline",
				}, true)

				Library.ChangeObjectTheme(Objects.icon, {
					ImageColor3 = status and "text" or "dark text",
				}, true)

				Objects.pagetabsholder.Parent = status and self.pageholder or HiddenUI
				Objects.page.Parent = status and self.pageholder or HiddenUI

				Tab.Selected = status

				if not nested then
					for _,tab in self.Tabs do
						if tab == Tab then continue end

						tab.Set(false, true)
					end
				end
			end

			Utility.Signal(Objects.holder.MouseButton1Click:Connect(function()
				Tab.Set(true)
			end))

			table.insert(self.Tabs, Tab)

			return setmetatable(Tab, Library)
		end

		function Library.SubTab(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "Tab",
			})

			local Tab = {
				Selected = false,

				Objects = { },
			}

			local Objects = Tab.Objects; do
				Objects.holder = Utility.New("TextButton", {
					BackgroundTransparency = 1,
					Name = "holder",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.pagetabsholder,
				})

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					Position = UDim2.new(0, 0, 1, -2),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.holder,
				}, { BackgroundColor3 = "accent" })

				Objects.text = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.name,
					TextStrokeTransparency = 0,
					Name = "text",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.holder,
				}, { TextColor3 = "text" })

				Objects.page = Utility.New("Frame", {
					Name = "page",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.pageholder,
				})

				Utility.New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.page,
				})

				Objects.left = Utility.New("Frame", {
					BackgroundTransparency = 1,
					Name = "left",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.page,
				})

				Tab.left = Objects.left

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.left,
				})

				Objects.right = Utility.New("Frame", {
					BackgroundTransparency = 1,
					Name = "right",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.page,
				})

				Tab.right = Objects.right

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.right,
				})
			end

			function Tab.Set(status, nested)
				Library.ChangeObjectTheme(Objects.accent, {
					BackgroundColor3 = status and "accent" or "inline",
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = status and "text" or "dark text",
				}, true)

				Tab.Selected = status

				Objects.page.Parent = status and self.pageholder or HiddenUI

				if not nested then
					for _,tab in self.Tabs do
						if tab == Tab then continue end

						tab.Set(false, true)
					end
				end
			end

			Utility.Signal(Objects.holder.MouseButton1Click:Connect(function()
				Tab.Set(true)
			end))

			table.insert(self.Tabs, Tab)

			return setmetatable(Tab, Library)
		end

		function Library.Section(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "Section",
				tabs = false,
				side = "left",
				size = UDim2.new(1, 0, 1, 0)
			})

			local Side = cfg.side:lower() == "left" and self.left or self.right

			local Section = {
				Objects = {},

				Tabs = {},
			}

			local Objects = Section.Objects; do
				Objects.outline = Utility.New("Frame", {
					Name = "outline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = cfg.size,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Side,
				}, { BackgroundColor3 = "outline" })

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.outline,
				}, { BackgroundColor3 = "accent" })

				Objects.outline = Utility.New("Frame", {
					Name = "outline",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					Parent = Objects.accent,
				}, { BackgroundColor3 = "outline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.outline,
				}, { BackgroundColor3 = "background" })

				Objects.dock_background = Utility.New("Frame", {
					Name = "dock_background",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 28),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(19, 19, 19),
					Parent = Objects.background,
				}, { BackgroundColor3 = "dock background" })

				Objects.shadow = Utility.New("Frame", {
					Name = "shadow",
					Position = UDim2.new(0, 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 8),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 16, 16),
					Parent = Objects.dock_background,
				})

				Utility.New("UIGradient", {
					Rotation = 90,
					Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1)
					},
					Parent = Objects.shadow,
				})

				Objects.text = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.name,
					TextStrokeTransparency = 0,
					Name = "text",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, -2),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.dock_background,
				}, { TextColor3 = "text" })

				Objects.accent = Utility.New("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = Color3.fromRGB(220, 100, 100),
					MidImage = Library.Images.ScrollBar,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 1,
					Name = "accent",
					Size = UDim2.new(1, -12, 1, -28),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 28),
					BottomImage = Library.Images.ScrollBar,
					TopImage = Library.Images.ScrollBar,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				}, { ScrollBarImageColor3 = "accent" })

				Objects.content = Utility.New("Frame", {
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "content",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 12),
					Size = UDim2.new(1, -12, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.accent,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 9),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.content,
				})

				Utility.New("UIPadding", {
					Parent = Objects.accent,
					PaddingBottom = UDim.new(0, 4),
				})

				Section.holder = Objects.content
			end

			function Section.State(value)
				Objects.outline.Visible = value
			end

			return setmetatable(Section, Library)
		end

		function Library.Toggle(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New Toggle",
				value = false,
				callback = function() end,
				flag = nil,
			})



			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Toggle = {
				Objects = { },

				Tweening = false,

				Value = false,
			}

			local Objects = Toggle.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("TextButton", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 17, 0, 17),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

			Objects.accent = Utility.New("Frame", {
				Name = "accent",
				Position = UDim2.new(0, 1, 0, 1),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.new(1, -2, 1, -2),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(220, 100, 100),
				Parent = Objects.background,
			}, { BackgroundColor3 = "accent" })

			Objects.text = Utility.New("TextLabel", {
				FontFace = Library.Font,
				TextColor3 = Color3.fromRGB(230, 230, 230),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Text = cfg.name,
				TextStrokeTransparency = 0,
				Name = "text",
				Size = UDim2.new(1, -25, 1, -3),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, 25, 0, 0),
				BorderSizePixel = 0,
				TextSize = Library.FontSize,
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				Parent = Objects.line,
			}, { TextColor3 = "text" })

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.text,
				})

				Toggle.childholder = Objects.text
			end

			function Toggle.Set(value)
				Toggle.Value = value

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = value and "text" or "dark text"
				}, true)

				Library.Tween(Objects.accent, {
					BackgroundTransparency = value and 0 or 1
				})

				cfg.callback(value)

				Library.Flags[cfg.flag] = value

				if Library.KeybindsList then
					for _, item in Library.KeybindsList.Items do
						if item.LinkFlag and item.LinkFlag == cfg.flag and item.LastText ~= nil then
							local funcOn = Library.Flags[cfg.flag] and true or false
							item.Set(item.LastValue, item.LastText, item.LastMode, item.LastKey, funcOn)
						end
					end
				end
			end

			function Toggle.Enable()
				Toggle.Set(not Toggle.Value)
			end

			function Toggle.State(value)
				Objects.holder.Visible = value
			end

			Utility.Signal(Objects.line.MouseButton1Click:Connect(Toggle.Enable))

			Utility.Signal(Objects.line.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "text"
				}, true)
			end))

			Utility.Signal(Objects.line.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)

				if not Toggle.Value then
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end
			end))

			Toggle.Set(cfg.value)

			Library.ConfigFlags[cfg.flag] = Toggle.Set

			return setmetatable(Toggle, Library)
		end

		function Library.Slider(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New Slider",
				value = 50,
				min = 0,
				max = 100,
				float = 1,
				suffix = "%s",
				callback = function() end,
				flag = nil,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Slider = {
				Tweening = false,

				Objects = { },

				Value = cfg.value,

				Sliding = false,
			}

			local Objects = Slider.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("TextButton", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				if cfg.name ~= "" then
					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Slider.childholder = Objects.text

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})
				end

				Objects.value = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(86, 86, 86),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "50%",
					TextStrokeTransparency = 0,
					Name = "text",
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.text,
				}, { TextColor3 = "dark text" })

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					FillDirection = Enum.FillDirection.Horizontal,
					Parent = Objects.value,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.line,
				})

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 14),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0.5, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.background,
				}, { BackgroundColor3 = "accent" })

				Utility.New("UIPadding", {
					PaddingTop = UDim.new(0, 1),
					PaddingBottom = UDim.new(0, 1),
					PaddingRight = UDim.new(0, 1),
					PaddingLeft = UDim.new(0, 1),
					Parent = Objects.background,
				})
			end

			function Slider.Set(value)
				Slider.Value = math.clamp(Utility.Round(value, cfg.float), cfg.min, cfg.max)

				if Objects.value then
					Objects.value.Text = string.format(cfg.suffix, tostring(Slider.Value))
				end

				Objects.accent.Size = UDim2.new((Slider.Value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)

				cfg.callback(Slider.Value)

				Library.Flags[cfg.flag] = Slider.Value
			end

			function Slider.State(value)
				Objects.holder.Visible = value
			end

			Utility.Signal(Objects.line.MouseButton1Down:Connect(function(input)
				local MouseLocation = UserInputService:GetMouseLocation()

				Slider.Sliding = true

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "text"
				}, true)

				Library.ChangeObjectTheme(Objects.value, {
					TextColor3 = "text"
				}, true)

				Slider.Set( ((cfg.max - cfg.min) * ((MouseLocation.x - Objects.inline.AbsolutePosition.x) / Objects.inline.AbsoluteSize.x)) + cfg.min )
			end))

			Utility.Signal(Objects.line.MouseEnter:Connect(function(input)
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "text"
				}, true)

				Library.ChangeObjectTheme(Objects.value, {
					TextColor3 = "text"
				}, true)
			end))

			Utility.Signal(Objects.line.MouseLeave:Connect(function(input)
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)

				if not Slider.Sliding then
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)

					Library.ChangeObjectTheme(Objects.value, {
						TextColor3 = "dark text"
					}, true)
				end
			end))

			Utility.Signal(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and Slider.Sliding then
					Slider.Sliding = false

					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)

					Library.ChangeObjectTheme(Objects.value, {
						TextColor3 = "dark text"
					}, true)
				end
			end))

			Utility.Signal(UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement and Slider.Sliding then
					Slider.Set( ((cfg.max - cfg.min) * ((input.Position.x - Objects.inline.AbsolutePosition.x) / Objects.inline.AbsoluteSize.x)) + cfg.min )
				end
			end))

			Slider.Set(cfg.value)

			Library.ConfigFlags[cfg.flag] = Slider.Set

			return setmetatable(Slider, Library)
		end

		function Library.Button(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New Button",
				confirm = false,
				callback = function() end,
			})

			local Button = {
				Clicked = false,

				Time = 0,

				Objects = { },
			}

			local Objects = Button.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("TextButton", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 27),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.text = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(86, 86, 86),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.name,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "dark_text",
					Size = UDim2.new(1, 0, 1, -2),
					BorderSizePixel = 0,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.background,
				}, { TextColor3 = "dark text" })
			end

			function Button.StartConfirmation()
				Button.Clicked = true

				Button.Time = 5

				Objects.text.Text = string.format("Confirm %s? (%s)", cfg.name, Button.Time)

				Button.Coroutine = coroutine.create(function()
					for i = 1, 5 do
						task.wait(1)

						Button.Time -= 1

						if Button.Time > 0 then
							Objects.text.Text = string.format("Confirm %s? (%s)", cfg.name, Button.Time)
						else
							Objects.text.Text = cfg.name

							if Button.Clicked then
								Library.ChangeObjectTheme(Objects.text, {
									TextColor3 = "dark text"
								}, true)

								Button.Clicked = false
							end

							break
						end
					end
				end); coroutine.resume(Button.Coroutine)
			end

			function Button.Click()
				if cfg.confirm then
					if Button.Clicked then
						Library.ChangeObjectTheme(Objects.text, {
							TextColor3 = "dark text"
						}, true)

						coroutine.close(Button.Coroutine)

						Objects.text.Text = cfg.name

						Button.Clicked = false

						cfg.callback()
					else
						Library.ChangeObjectTheme(Objects.text, {
							TextColor3 = "text"
						}, true)

						Button.StartConfirmation()
					end
				else
					cfg.callback()

					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "text"
					}, true)

					task.wait(Library.TweenSpeed)

					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end
			end

			function Button.State(value)
				Objects.holder.Visible = value
			end

			Utility.Signal(Objects.line.MouseButton1Click:Connect(Button.Click))

			Utility.Signal(Objects.line.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)

				if not Button.Clicked then
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "text"
					}, true)
				end
			end))

			Utility.Signal(Objects.line.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)

				if not Button.Clicked then
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end
			end))

			return setmetatable(Button, Library)
		end

		function Library.Dropdown(self, cfg)
			cfg = cfg or {}; cfg = Library.Config(cfg, {
				name = "New Dropdown",
				values = { "value1", "value2", "value3", "value4", "value5", "value6" },
				value = "value1",
				multi = false,
				flag = nil,
				callback = function() end,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Dropdown = {
				Tweening = false,

				Visible = false,

				Objects = { },

				Popup = { Objects = {} },

				Items = { },

				Value = nil,
			}

			local Objects = Dropdown.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("TextButton", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.line,
				})

				if cfg.name ~= "" then
					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Dropdown.childholder = Objects.text

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})
				end

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 27),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.value = Utility.New("TextLabel", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(86, 86, 86),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "-",
					TextStrokeTransparency = 0,
					Name = "dark_text",
					Size = UDim2.new(1, -4, 1, -2),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					Position = UDim2.new(0, 4, 0, 0),
					BorderSizePixel = 0,
					ClipsDescendants = true,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.background,
				}, { TextColor3 = "dark text" })

				Objects.ImageLabel = Utility.New("ImageLabel", {
					ImageColor3 = Color3.fromRGB(86, 86, 86),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					Image = Library.Images.Lines,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.new(0, 10, 0, 7),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Objects.value.Size = UDim2.new(1, -(4 + Objects.ImageLabel.AbsoluteSize.X + 12), 1, -2)
			end

			local Popup = Dropdown.Popup; do
				local Objects = Popup.Objects

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					Position = UDim2.new(0, 618, 0, 464),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 199, 0, 60),
					BorderSizePixel = 0,
					Visible = false,
					ClipsDescendants = true,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Library.ScreenGui,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -1),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = Color3.fromRGB(220, 100, 100),
					MidImage = Library.Images.ScrollBar,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 1,
					Name = "accent",
					Size = UDim2.new(1, 1, 1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -1, 0, 0),
					BottomImage = Library.Images.ScrollBar,
					TopImage = Library.Images.ScrollBar,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				}, { ScrollBarImageColor3 = "accent" })

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.accent,
				})
			end


			Utility.Signal(Objects.inline:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				if Dropdown.Visible then
					local Size = Objects.inline.AbsoluteSize

					local Position = Objects.inline.AbsolutePosition

					Popup.Objects.inline.Position = UDim2.new(0, math.round(Position.X), 0, math.round(Position.Y) + math.round(Size.Y) + GuiService:GetGuiInset().Y - 2)
				end
			end))

			Utility.Signal(UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Visible and not Utility.MouseOver(Popup.Objects.inline, input) then
					Dropdown.Open(false)
				end
			end))


			function Dropdown.Display()
				local Value = Dropdown.Value

				if cfg.multi then
					local CurrentText = {}

					if #Value > 0 then
						for _,item in Value do
							table.insert(CurrentText, item)

							Objects.value.Text = table.concat(CurrentText, ", ")
						end
					else
						Objects.value.Text = "-"
					end
				else
					Objects.value.Text = type(Value) == "string" and Value or "-"
				end
			end

			function Dropdown.Size()
				local Size = 0

				local Count = 0

				for _,v in Popup.Objects.accent:GetChildren() do
					Count += 1

					if v:IsA("TextButton") then
						Size += v.AbsoluteSize.y
					end

					if Count > 5 then
						break
					end
				end

				return Size
			end

			function Dropdown.Open(visbility)
				if Dropdown.Tweening or Dropdown.Visible == visbility then
					return
				end

				Dropdown.Tweening = true

				Dropdown.Visible = visbility

				if Dropdown.Visible then
					Popup.Objects.inline.Visible = true
				end

				local ParentObjects = Popup.Objects.inline:GetDescendants()

				table.insert(ParentObjects, Popup.Objects.inline)

				for _, obj in ParentObjects do
					local Index = Utility.GetTransparency(obj)
					if not Index then continue end

					if type(Index) == "table" then
						for _, prop in Index do
							Library.Fade(obj, prop, Dropdown.Visible)
						end
					else
						Library.Fade(obj, Index, Dropdown.Visible)
					end
				end

				local Size = Vector2.new(Objects.inline.AbsoluteSize.x, math.round(Objects.inline.AbsoluteSize.y))

				local Position = Vector2.new(math.round(Objects.inline.AbsolutePosition.x), math.round(Objects.inline.AbsolutePosition.y))

				Popup.Objects.inline.Position = UDim2.new(0, Position.X, 0, Position.Y + Size.Y + 1 + GuiService:GetGuiInset().Y - 2)

				Popup.Objects.inline.Size = Dropdown.Visible and UDim2.new(0, Size.X, 0, 10) or UDim2.new(0, Size.X + 1, 0, Dropdown.Size())

				local Tween = Library.Tween(Popup.Objects.inline, {
					Size = Dropdown.Visible and UDim2.new(0, Size.X, 0, Dropdown.Size()) or UDim2.new(0, Size.X + 1, 0, 10),
				})

				Utility.Signal(Tween.Completed:Connect(function()
					Popup.Objects.inline.Visible = Dropdown.Visible

					Dropdown.Tweening = false
				end))
			end

			function Dropdown.Set(value, ignore)
				if cfg.multi then
					if type(value) == "table" then
						for _,item in Dropdown.Items do
							item.Select(false)
						end

						for _,item in value do
							for _,item2 in Dropdown.Items do
								if item2.Name == item then
									item2.Select(true)
								end
							end
						end

						Dropdown.Value = value

						Dropdown.Display()

						if not ignore then
							cfg.callback(Dropdown.Value)
						end

						Library.Flags[cfg.flag] = Dropdown.Value
					else
						local Index = table.find(Dropdown.Value, value)

						if Index then
							table.remove(Dropdown.Value, Index)

							for _,item in Dropdown.Items do
								if item.Name == value then
									item.Select(false)
								end
							end

							Dropdown.Display()

							if not ignore then
								cfg.callback(Dropdown.Value)
							end

							Library.Flags[cfg.flag] = Dropdown.Value
						else
							table.insert(Dropdown.Value, value)

							for _,item in Dropdown.Items do
								if item.Name == value then
									item.Select(true)
								end
							end

							Dropdown.Display()

							if not ignore then
								cfg.callback(Dropdown.Value)
							end

							Library.Flags[cfg.flag] = Dropdown.Value
						end
					end
				else
					for _,item in Dropdown.Items do
						item.Select(item.Name == value)
					end

					Dropdown.Value = value

					Dropdown.Display()

					if not ignore then
						cfg.callback(Dropdown.Value)
					end

					Library.Flags[cfg.flag] = Dropdown.Value
				end
			end

			function Dropdown.Add(name)
				local Item = {
					Objects = {},

					Name = name,

					Selected = false,
				}

				local Objects = Item.Objects; do
					Objects.holder = Utility.New("TextButton", {
						Name = "holder",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = Popup.Objects.accent,
					})

					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(230, 230, 230),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = name,
						TextStrokeTransparency = 0,
						Name = "text",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.XY,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.holder,
					}, { TextColor3 = "dark text" })

					Utility.New("UIPadding", {
						PaddingBottom = UDim.new(0, 4),
						PaddingTop = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 6),
						Parent = Objects.text,
					})

					Objects.accent = Utility.New("Frame", {
						Name = "accent",
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Size = UDim2.new(0, 1, 1, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(220, 100, 100),
						Parent = Objects.holder,
					}, { BackgroundColor3 = "accent" })

					Utility.New("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.accent,
					})
				end

				function Item.Select(value)
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = value and "text" or "dark text"
					}, true)

					Library.Tween(Objects.accent, {
						BackgroundTransparency = value and 0 or 1
					})

					Item.Selected = value
				end

				Utility.Signal(Objects.holder.MouseButton1Click:Connect(function()
					Dropdown.Set(name)
				end))

				Utility.Signal(Objects.holder.MouseEnter:Connect(function()
					if Item.Selected then return end

					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "text"
					}, true)
				end))

				Utility.Signal(Objects.holder.MouseLeave:Connect(function()
					if Item.Selected then return end

					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end))

				table.insert(Dropdown.Items, Item)

				return Item
			end

			function Dropdown.Refresh(tbl)
				for _,item in Dropdown.Items do
					item.Objects.holder:Destroy()
				end

				Dropdown.Items = { }

				Dropdown.Value = cfg.multi and { } or nil

				for _,item in tbl do
					Dropdown.Add(item)
				end

				Dropdown.Display()
			end

			function Dropdown.State(value)
				Objects.holder.Visible = value
				Dropdown.Open(false)
			end

			for _,item in cfg.values do
				Dropdown.Add(item)
			end

			Dropdown.Set(cfg.value)

			Utility.Signal(Objects.line.MouseButton1Click:Connect(function()
				Dropdown.Open(not Dropdown.Visible)
			end))

			Utility.Signal(Objects.line.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "text"
				}, true)

				Library.ChangeObjectTheme(Objects.value, {
					TextColor3 = "text"
				}, true)
			end))

			Utility.Signal(Objects.line.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "dark text"
				}, true)

				Library.ChangeObjectTheme(Objects.value, {
					TextColor3 = "dark text"
				}, true)
			end))

			Library.ConfigFlags[cfg.flag] = Dropdown.Set

			table.insert(Library.Popups, Dropdown)

			return setmetatable(Dropdown, Library)
		end

		function Library.List(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New List",
				value = "value1",
				values = { "value1", "value2", "value3", "value4", "value5", "value6" },
				multi = false,
				size = 100,
				search = false,
				callback = function() end,
				flag = nil,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local List = {
				Objects = { },

				Items = { },

				Value = nil,
			}

			function List.SearchFunc(text)
				text = text:lower()

				for _,item in List.Items do
					local Holder = item.Objects.text

					Holder.Visible = text == "" and true or item.Name:lower():find(text)
				end
			end

			local Objects = List.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("Frame", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.line,
				})

				if cfg.name ~= "" then
					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})

					List.childholder = Objects.text
				end

				Objects.box = Utility.New("Frame", {
					Name = "box",
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.line,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, -1),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.box,
				})

				if cfg.search then
					Library.Textbox({
						holder = Objects.box
					}, {
						name = "",
						callback = function(value)
							List.SearchFunc(value)
						end,
						flag = "list_search_" .. cfg.name,
					})
				end

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, cfg.size),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.box,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = Color3.fromRGB(220, 100, 100),
					MidImage = Library.Images.ScrollBar,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					ScrollBarThickness = 1,
					Name = "accent",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					BottomImage = Library.Images.ScrollBar,
					TopImage = Library.Images.ScrollBar,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				}, { ScrollBarImageColor3 = "accent" })

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.accent,
				})

				Utility.New("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4),
					Parent = Objects.accent,
				})
			end

			function List.Set(value)
				if cfg.multi then
					if type(value) == "table" then
						for _,item in List.Items do
							item.Select(false)
						end

						for _,item in value do
							for _,item2 in List.Items do
								if item2.Name == item then
									item2.Select(true)
								end
							end
						end

						List.Value = value

						cfg.callback(List.Value)

						Library.Flags[cfg.flag] = List.Value
					else
						local Index = table.find(List.Value, value)

						if Index then
							table.remove(List.Value, Index)

							for _,item in List.Items do
								if item.Name == value then
									item.Select(false)
								end
							end

							cfg.callback(List.Value)

							Library.Flags[cfg.flag] = List.Value
						else
							table.insert(List.Value, value)

							for _,item in List.Items do
								if item.Name == value then
									item.Select(true)
								end
							end

							cfg.callback(List.Value)

							Library.Flags[cfg.flag] = List.Value
						end
					end
				else
					for _,item in List.Items do
						item.Select(item.Name == value)
					end

					List.Value = value

					cfg.callback(List.Value)

					Library.Flags[cfg.flag] = List.Value
				end
			end

			function List.Add(name)
				local Item = {
					Objects = {},

					Name = name,

					Selected = false,
				}

				local Objs = Item.Objects; do
					Objs.text = Utility.New("TextButton", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.accent,
					}, { TextColor3 = "dark text" })
				end

				function Item.Select(value)
					Library.ChangeObjectTheme(Objs.text, {
						TextColor3 = value and "text" or "dark text"
					}, true)

					Item.Selected = value
				end

				Utility.Signal(Objs.text.MouseButton1Click:Connect(function()
					List.Set(name)
				end))

				Utility.Signal(Objs.text.MouseEnter:Connect(function()
					if Item.Selected then return end

					Library.ChangeObjectTheme(Objs.text, {
						TextColor3 = "text"
					}, true)
				end))

				Utility.Signal(Objs.text.MouseLeave:Connect(function()
					if Item.Selected then return end

					Library.ChangeObjectTheme(Objs.text, {
						TextColor3 = "dark text"
					}, true)
				end))

				table.insert(List.Items, Item)

				return Item
			end

			function List.Refresh(tbl)
				for _,item in List.Items do
					item.Objects.text:Destroy()
				end

				List.Items = { }

				List.Value = cfg.multi and { } or nil

				for _,item in tbl do
					List.Add(item)
				end
			end

			function List.State(value)
				Objects.holder.Visible = value
			end

			for _,item in cfg.values do
				List.Add(item)
			end

			Utility.Signal(Objects.inline.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)
			end))

			Utility.Signal(Objects.inline.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)
			end))

			List.Set(cfg.value)

			Library.ConfigFlags[cfg.flag] = List.Set

			return setmetatable(List, Library)
		end

		function Library.Textbox(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "Textbox",
				value = "",
				callback = function() end,
				flag = nil,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Textbox = {
				Objects = { },
			}

			local Objects = Textbox.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = self.holder,
				})

				Objects.line = Utility.New("Frame", {
					Name = "line",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.holder,
				})

				Utility.New("UIListLayout", {
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.line,
				})

				if cfg.name ~= "" then
					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Textbox.childholder = Objects.text

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})
				end

				Objects.inline = Utility.New("Frame", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 27),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.textbox = Utility.New("TextBox", {
					FontFace = Library.Font,
					Name = "text",
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.value,
					Size = UDim2.new(1, -5, 1, 0),
					TextStrokeTransparency = 0,
					Position = UDim2.new(0, 4, 0, 0),
					ClipsDescendants = true,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					TextSize = Library.FontSize,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				}, { TextColor3 = "dark text" })
			end

			function Textbox.Set(value)
				Objects.textbox.Text = value

				Library.Flags[cfg.flag] = value
				cfg.callback(value)
			end

			function Textbox.State(value)
				Objects.holder.Visible = value
			end

			Utility.Signal(Objects.textbox.FocusLost:Connect(function()
				Textbox.Set(Objects.textbox.Text)

				Library.ChangeObjectTheme(Objects.textbox, {
					TextColor3 = "dark text"
				}, true)
			end))

			Utility.Signal(Objects.textbox.Focused:Connect(function()
				Library.ChangeObjectTheme(Objects.textbox, {
					TextColor3 = "text"
				}, true)
			end))

			Utility.Signal(Objects.line.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "text"
				}, true)
			end))

			Utility.Signal(Objects.line.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)

				Library.ChangeObjectTheme(Objects.text, {
					TextColor3 = "dark text"
				}, true)
			end))

			Textbox.Set(cfg.value)

			Library.ConfigFlags[cfg.flag] = Textbox.Set

			return setmetatable(Textbox, Library)
		end

		function Library.Colorpicker(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New Colorpicker",
				value = Color3.new(1, 1, 1),
				alpha = 0,
				usealpha = true,
				flag = nil,
				ignore = false,
				callback = function() end,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Colorpicker = {
				Tweening = false,

				ZIndex = self.ZIndex,

				Objects = { },

				OriginalColor = cfg.value,

				Popup = { },

				Value = cfg.value,

				Alpha = cfg.alpha,
			}

			local ZIndex = Colorpicker.ZIndex

			local Objects = Colorpicker.Objects; do
				if not self.childholder then
					Objects.holder = Utility.New("Frame", {
						Name = "holder",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = self.holder,
					})

					Objects.line = Utility.New("Frame", {
						Name = "line",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = Objects.holder,
					})

					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})

					Colorpicker.childholder = Objects.text
				end

				local Parent = self.childholder or Objects.text

				Objects.inline = Utility.New("TextButton", {
					Name = "inline",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 24, 0, 12),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Parent,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.alphaimage = Utility.New("ImageLabel", {
					ScaleType = Enum.ScaleType.Tile,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Name = "alphaimage",
					Image = Library.Images.Checkers,
					TileSize = UDim2.new(0, 6, 0, 6),
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Objects.color = Utility.New("Frame", {
					BackgroundTransparency = 0,
					Name = "color",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(0, 151, 197),
					Parent = Objects.alphaimage,
				})
			end

			local ColorpickerWindow = Library.ColorpickerWindow

			function Colorpicker.Set(value, alpha)
				local Color, Alpha;

				if type(value) == "table" then
					Color = value.c
					Alpha = value.a
				else
					Color = value
					Alpha = alpha or Colorpicker.Alpha
				end

				Colorpicker.Value = Color

				if Alpha then
					Colorpicker.Alpha = Alpha

					Objects.color.BackgroundTransparency = Alpha
				end

				Objects.color.BackgroundColor3 = Color

				if not cfg.ignore then
					Library.Flags[cfg.flag] = {
						c = Color,
						a = Alpha
					}
				end

				cfg.callback({
					c = Color,
					a = Alpha
				})
			end

			function Colorpicker.State(state)
				if Objects.holder then Objects.holder.Visible = state end
				Objects.inline.Visible = state
				ColorpickerWindow.Open(false)
			end

			Utility.Signal(Objects.inline.MouseButton1Click:Connect(function(input)
				ColorpickerWindow.Flag = cfg.flag

				ColorpickerWindow.SetFunc = Colorpicker.Set

				ColorpickerWindow.OriginalColor = Colorpicker.OriginalColor

				ColorpickerWindow.Set(Colorpicker.Value, Colorpicker.Alpha)

				ColorpickerWindow.Open(not ColorpickerWindow.Visible, Objects.inline.AbsolutePosition + Vector2.new(0, Objects.inline.AbsoluteSize.Y + 2 + GuiService:GetGuiInset().Y) )

				ColorpickerWindow.Objects.alphaimage.Visible = cfg.usealpha
			end))

			Utility.Signal(UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorpickerWindow.Visible and ColorpickerWindow.Flag == cfg.flag and not (Utility.MouseOver(ColorpickerWindow.Objects.accent, input) or Utility.MouseOver(Objects.inline, input)) then
					ColorpickerWindow.Open(false, Objects.inline.AbsolutePosition + Vector2.new(0, Objects.inline.AbsoluteSize.Y + 2 + GuiService:GetGuiInset().Y) )
				end
			end))

			Utility.Signal(Objects.inline.MouseEnter:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline hovering"
				}, true)
			end))

			Utility.Signal(Objects.inline.MouseLeave:Connect(function()
				Library.ChangeObjectTheme(Objects.inline, {
					BackgroundColor3 = "inline"
				}, true)
			end))

			if Objects.line then
				Utility.Signal(Objects.line.MouseEnter:Connect(function()
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "text"
					}, true)
				end))

				Utility.Signal(Objects.line.MouseLeave:Connect(function()
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end))
			end

			Colorpicker.Set(cfg.value, cfg.alpha)

			if not cfg.ignore then
				Library.ConfigFlags[cfg.flag] = Colorpicker.Set
			end

			return setmetatable(Colorpicker, Library)
		end

		function Library.Keybind(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				name = "New Keybind",
				value = false,
				key = nil,
				mode = "Toggle",
				ignore = false,
				callback = function() end,
				flag = nil,
			})

			if not cfg.flag then
				cfg.flag = cfg.name
			end

			local Keybind = {
				Tweening = false,

				Visible = false,

				Objects = { },

				Popup = { Objects = {}, Items = {} },

				Key = nil,

				Mode = nil,

				Value = false,

				OnHold = nil,

				Listener = nil,
			}

			local Objects = Keybind.Objects; do
				if not self.childholder then
					Objects.holder = Utility.New("Frame", {
						Name = "holder",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = self.holder,
					})

					Objects.line = Utility.New("Frame", {
						Name = "line",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = Objects.holder,
					})

					Objects.text = Utility.New("TextLabel", {
						FontFace = Library.Font,
						TextColor3 = Color3.fromRGB(86, 86, 86),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						Text = cfg.name,
						TextStrokeTransparency = 0,
						Name = "text",
						Size = UDim2.new(1, 0, 0, 0),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						BorderSizePixel = 0,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextSize = Library.FontSize,
						BackgroundColor3 = Color3.fromRGB(25, 25, 25),
						Parent = Objects.line,
					}, { TextColor3 = "dark text" })

					Utility.New("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Parent = Objects.text,
					})

					Keybind.childholder = Objects.text
				end

				local Parent = self.childholder or Objects.text

				Objects.value = Utility.New("TextButton", {
					FontFace = Library.Font,
					TextColor3 = Color3.fromRGB(86, 86, 86),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "[-]",
					TextStrokeTransparency = 0,
					Name = "text",
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.X,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Parent,
				}, { TextColor3 = "dark text" })

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					FillDirection = Enum.FillDirection.Horizontal,
					Parent = Objects.value,
				})
			end

			local Popup = Keybind.Popup; do
				Popup.Objects.inline = Utility.New("Frame", {
					Name = "inline",
					Position = UDim2.new(0, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Visible = false,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(40, 42, 44),
					Parent = Library.ScreenGui,
				}, { BackgroundColor3 = "inline" })

				Popup.Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Popup.Objects.inline,
				}, { BackgroundColor3 = "background" })

				Utility.New("UIPadding", {
					PaddingBottom = UDim.new(0, 1),
					Parent = Popup.Objects.background,
				})

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Popup.Objects.background,
				})

				function Popup.SetMode(mode)
					for _,item in Popup.Items do
						item.Select(item.Mode == mode)
					end
				end

				function Popup.Add(mode)
					local Item = {
						Objects = {},

						Mode = mode,

						Selected = false,
					}

					local Objs = Item.Objects; do
						Objs.holder = Utility.New("TextButton", {
							BackgroundTransparency = 1,
							Name = "holder",
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							Parent = Popup.Objects.background,
						})

						Objs.text = Utility.New("TextLabel", {
							FontFace = Library.Font,
							TextColor3 = Color3.fromRGB(230, 230, 230),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Text = mode,
							TextStrokeTransparency = 0,
							Name = "text",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 4, 0, 0),
							BorderSizePixel = 0,
							AutomaticSize = Enum.AutomaticSize.XY,
							TextSize = 12,
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							Parent = Objs.holder,
						}, { TextColor3 = "dark text" })

						Utility.New("UIPadding", {
							PaddingBottom = UDim.new(0, 4),
							PaddingTop = UDim.new(0, 4),
							PaddingRight = UDim.new(0, 6),
							Parent = Objs.text,
						})

						Objs.accent = Utility.New("Frame", {
							Name = "accent",
							Position = UDim2.new(0, -1, 0, 0),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							Size = UDim2.new(0, 1, 1, 0),
							BorderSizePixel = 0,
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(220, 100, 100),
							Parent = Objs.holder,
						}, { BackgroundColor3 = "accent" })
					end

					function Item.Select(value)
						Library.ChangeObjectTheme(Objs.text, {
							TextColor3 = value and "text" or "dark text"
						})

						Library.Tween(Objs.accent, {
							BackgroundTransparency = value and 0 or 1
						})

						Item.Selected = value
					end

					Utility.Signal(Objs.holder.MouseButton1Click:Connect(function()
						Keybind.Set(mode)
					end))

					Utility.Signal(Objs.holder.MouseEnter:Connect(function()
						if Item.Selected then return end

						Library.ChangeObjectTheme(Objs.text, {
							TextColor3 = "text"
						})
					end))

					Utility.Signal(Objs.holder.MouseLeave:Connect(function()
						if Item.Selected then return end

						Library.ChangeObjectTheme(Objs.text, {
							TextColor3 = "dark text"
						})
					end))

					Popup.Items[mode] = Item

					return Item
				end

				Utility.Signal(Objects.value:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					if Keybind.Visible then
						local Size = Objects.value.AbsoluteSize
						local Position = Objects.value.AbsolutePosition

						Popup.Objects.inline.Position = UDim2.new(0, math.round(Position.X), 0, math.round(Position.Y) + math.round(Size.Y) + 2 + GuiService:GetGuiInset().Y)
					end
				end))
			end; Keybind.ZIndex = ZIndex

			for _,mode in cfg.modes or {"Always on", "Hold", "Toggle"} do
				Popup.Add(mode)
			end

			local Item;
			if not cfg.ignore then
				Item = Library.KeybindsList.Add()
				Item.LinkFlag = cfg.link
			end

			function Keybind.Set(value, ignore)
				if type(value) == "table" then
					for _,v in value do
						Keybind.Set(v, true)
					end

					return
				end

				local Type = typeof(value)
				if Type == "EnumItem" then
					Keybind.Key = value

					value = ( value == Enum.KeyCode.Unknown and "-" or value.Name )

					Objects.value.Text = string.format("[%s]", KeyConverters[ value:lower() ] or value)
				elseif Type == "boolean" then

					if Keybind.Mode == "Always on" and not value then
						value = true
					end

					Keybind.Value = value
				elseif Type == "string" then

					if cfg.modes and not table.find(cfg.modes, value) then
						value = cfg.modes[1]
					end

					if Keybind.OnHold and value ~= "Hold" then
						Keybind.OnHold:Disconnect( )
						Keybind.OnHold = nil
					end

					Keybind.Mode = value

					Popup.SetMode(value)

					if value == "Always on" then
						Keybind.Value = true
					end
				end

				if Item then
					local keyname = Keybind.Key and Keybind.Key.Name or "-"
					local funcOn = true
					if cfg.link then
						funcOn = Library.Flags[cfg.link] and true or false
					end
					Item.Set(Keybind.Value, cfg.name, Keybind.Mode or "Toggle", keyname, funcOn)
				end

				if not ignore then
					Library.Flags[cfg.flag] = Keybind.Value
					cfg.callback(Keybind.Value)
				end

				Library.Flags[string.format("%s_data", cfg.flag)] = {
					value = Keybind.Value,
					key = Keybind.Key,
					mode = Keybind.Mode
				}
			end

			function Keybind.Open(visibility)
				if Keybind.Tweening or Keybind.Visible == visibility then
					return
				end

				Keybind.Tweening = true

				Keybind.Visible = visibility

				if Keybind.Visible then
					Popup.Objects.inline.Visible = true
				end

				local ParentObjects = Popup.Objects.inline:GetDescendants()

				table.insert(ParentObjects, Popup.Objects.inline)

				local Tween;
				for _, obj in ParentObjects do
					local Index = Utility.GetTransparency(obj)
					if not Index then continue end

					if type(Index) == "table" then
						for _, prop in Index do
							Tween = Library.Fade(obj, prop, Keybind.Visible)
						end
					else
						Tween = Library.Fade(obj, Index, Keybind.Visible)
					end
				end

				Popup.Objects.inline.Position = UDim2.new(0, Objects.value.AbsolutePosition.X, 0, Objects.value.AbsolutePosition.Y + Objects.value.AbsoluteSize.Y + 2 + GuiService:GetGuiInset().Y)

				Utility.Signal(Tween.Completed:Connect(function()
					Keybind.Tweening = false

					Popup.Objects.inline.Visible = Keybind.Visible
				end))
			end

			function Keybind.State(state)
				if Objects.holder then Objects.holder.Visible = state end
				Objects.inline.Visible = state
				Keybind.Open(false)
			end

			Utility.Signal(Objects.value.MouseButton1Click:Connect(function(input)
				if Keybind.Listener then
					Keybind.Listener:Disconnect( )
					Keybind.Listener = nil

					return
				end

				Objects.value.Text = string.format("[%s]", "...")

				Library.ChangeObjectTheme(Objects.value, {
					TextColor3 = "text"
				}, true)

				task.wait( 1/50 )

				Keybind.Listener = Utility.Signal(UserInputService.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
						Keybind.Set( Enum.KeyCode.Unknown )

						Library.ChangeObjectTheme(Objects.value, {
							TextColor3 = "dark text"
						}, true)

						Keybind.Listener:Disconnect( )
						Keybind.Listener = nil

						return
					end

					if input.UserInputType == Enum.UserInputType.Keyboard or table.find({ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }, input.UserInputType ) then
						local Key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType or Enum.KeyCode.Unknown

						Keybind.Set( Key )

						Library.ChangeObjectTheme(Objects.value, {
							TextColor3 = "dark text"
						}, true)

						Keybind.Listener:Disconnect( )
						Keybind.Listener = nil
					end
				end))
			end))

			Utility.Signal(Objects.value.MouseButton2Click:Connect(function(input)
				Keybind.Open(not Keybind.Visible)
			end))

			Utility.Signal(UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key then
					local Value = Keybind.Mode ~= "Toggle" or not Keybind.Value
					Keybind.Set( Value )

					if Keybind.Mode == "Hold" then
						if Keybind.OnHold then
							Keybind.OnHold:Disconnect( )
						end

						Keybind.OnHold = Utility.Signal(UserInputService.InputEnded:Connect(function(input)
							if input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key then
								Keybind.Set( false )

								if Keybind.OnHold then
									Keybind.OnHold:Disconnect( )
									Keybind.OnHold = nil
								end
							end
						end))


					end
				end
			end))

			Utility.Signal(UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Visible and not Utility.MouseOver(Popup.Objects.inline, input) then
					Keybind.Open(false)
				end
			end))

			if Objects.line then
				Utility.Signal(Objects.line.MouseEnter:Connect(function(input)
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "text"
					}, true)
				end))

				Utility.Signal(Objects.line.MouseLeave:Connect(function(input)
					Library.ChangeObjectTheme(Objects.text, {
						TextColor3 = "dark text"
					}, true)
				end))
			end

			Keybind.Set({ cfg.key, cfg.mode, cfg.value }, true)

			Library.ConfigFlags[string.format("%s_data", cfg.flag)] = Keybind.Set

			table.insert(Library.Popups, Keybind)

			return setmetatable(Keybind, Library)
		end


		function Library.Watermark(self, cfg)
			cfg = cfg or { }; cfg = Library.Config(cfg, {
				text = "ping: {ping}ms | user: admin | {date}",
				titlestart = "miko",
				titleend = "hub",
				visible = true,
				rate = 1 / 20,
			})

			local Watermark = {
				Objects = {},

				Visible = cfg.visible,

				Rate = cfg.rate,

				Text = cfg.text,

				Clock = os.clock(),
			}

			local Objects = Watermark.Objects; do
				Objects.accent = Utility.New("Frame", {
					Size = UDim2.new(0, 250, 0, 0),
					Name = "accent",
					Position = UDim2.new(0, 5, 0, 60),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Library.NotificationHolder,
				}, { BackgroundColor3 = "accent" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Parent = Objects.accent,
				}, { BackgroundColor3 = "background" })

				Utility.New("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.background,
				})

				Objects.topbar = Utility.New("Frame", {
					Name = "topbar",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Objects.textholder = Utility.New("Frame", {
					Name = "textholder",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.topbar,
				})

				Utility.New("UIPadding", {
					PaddingBottom = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 4),
					Parent = Objects.topbar,
				})

				Utility.New("UIPadding", {
					PaddingRight = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					Parent = Objects.textholder,
				})

				Utility.New("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.textholder,
				})

				Objects.text = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.titlestart,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "text",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "text" })

				Objects.text2 = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(220, 100, 100),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = cfg.titleend,
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "accent",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.textholder,
				}, { TextColor3 = "accent" })

				Objects.bottombar = Utility.New("Frame", {
					Name = "bottombar",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Objects.background,
				})

				Utility.New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Objects.bottombar,
				})

				Utility.New("UIPadding", {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 14),
					PaddingLeft = UDim.new(0, 14),
					Parent = Objects.bottombar,
				})

				Objects.bottomtext = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = "",
					TextStrokeTransparency = 0,
					BackgroundTransparency = 1,
					Name = "text",
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.bottombar,
				}, { TextColor3 = "text" })
			end

			function Watermark.SetText(text)
				Watermark.Text = text
			end

			function Watermark.SetVisible(visibility)
				Objects.accent.Visible = visibility
				Watermark.Visible = visibility
			end

			function Watermark.SetRate(rate)
				Watermark.Rate = rate
			end

			local LastTime = 0
			local Frames = 0
			function Watermark.Think(step)
				Frames += 1
				if tick() - LastTime >= 1 then
					Library.Fps = Frames
					LastTime = tick()
					Frames = 0
				end

				if Watermark.Visible and os.clock() - Watermark.Clock >= Watermark.Rate then
					Watermark.Clock = os.clock()

					Objects.bottomtext.Text = Utility.TextTriggers(Watermark.Text)
				end
			end

			Utility.Signal(RunService.RenderStepped:Connect(Watermark.Think))

			return Watermark
		end

		function Library.Notification(text, time)
			local Notification = {
				Objects = { },
			}

			local Objects = Notification.Objects; do
				Objects.holder = Utility.New("Frame", {
					Name = "holder",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 70),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = Library.NotificationHolder,
				})

				Objects.background = Utility.New("Frame", {
					BackgroundTransparency = 0.5,
					Name = "background",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(23, 25, 26),
					Position = UDim2.new(-1, 0, 0, 0),
					Parent = Objects.holder,
				}, { BackgroundColor3 = "background" })

				Objects.text = Utility.New("TextLabel", {
					FontFace = Fonts.Get("TahomaXP"),
					TextColor3 = Color3.fromRGB(230, 230, 230),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Text = text,
					RichText = true,
					TextStrokeTransparency = 0,
					Name = "text",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 4, 0, 0),
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 12,
					BackgroundColor3 = Color3.fromRGB(25, 25, 25),
					Parent = Objects.background,
				}, { TextColor3 = "text" })

				Utility.New("UIPadding", {
					PaddingBottom = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					Parent = Objects.text,
				})

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 2, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(220, 100, 100),
					Parent = Objects.background,
				}, { BackgroundColor3 = "accent" })
			end

			task.spawn(function()
				Library.Tween(Objects.background, {
					Position = UDim2.new(0, 0, 0, 0),
				})

				task.wait(time)

				Library.Tween(Objects.background, {
					Position = UDim2.new(-1, 0, 0, 0),
				})

				task.wait(Library.TweenSpeed)

				local Size = Objects.holder.AbsoluteSize

				Objects.holder.AutomaticSize = Enum.AutomaticSize.None

				Objects.background:Destroy()

				Objects.holder.Size = UDim2.new(0, Size.X, 0, Size.Y)

				Library.Tween(Objects.holder, {
					Size = UDim2.new(0, Size.X, 0, 0),
				})

				task.wait(Library.TweenSpeed)

				Notification.Objects.holder:Destroy()
			end)

			return Notification
		end

		Library.ColorpickerWindow = Library.ColorpickerWindow()



		function Library.GetConfig()
			local Config = { }

			for _, v in Library.ConfigFlags do
				local Value = Library.Flags[_]

				if type(Value) == "table" and Value["key"] then
					Config[_] = {value = Value.value, mode = Value.mode, key = tostring(Value.key)}
				elseif type(Value) == "table" and Value["a"] and Value["c"] then
					Config[_] = {a = Value.a, c = Value.c:ToHex()}
				else
					Config[_] = Value
				end
			end

			return HttpService:JSONEncode(Config)
		end

		function Library.GetTheme()
			local Theme = { }

			for theme,v in Library.Theme do
				if typeof(v) == "Color3" then
					Theme[theme] = v:ToHex()
				end
			end

			return HttpService:JSONEncode(Theme)
		end

		function Library.GetThemeData(data)
			data = HttpService:JSONDecode(data)

			local RawData = {  }
			for theme,v in data do
				RawData[theme] = Color3.fromHex(v)
			end

			return RawData
		end

		function Library.LoadConfig(data)
			data = HttpService:JSONDecode(data)

			for i,v in data do
				local Config = Library.ConfigFlags[i]

				if Config then
					if type(v) == "table" and v["a"] and v["c"] then
						Config({
							a = v.a,
							c = type(v.c) == "string" and Color3.fromHex(v.c) or v.c
						})
					elseif type(v) == "table" and v["key"] then
						Config({
							value = v.value,
							mode = v.mode,
							key = Utility.StringToEnum(v.key)
						}, true)
					else
						Config(v)
					end
				end
			end
			pcall(function()
				Library.KeybindsList.Refresh()
			end)
		end

		function Library.Unload()
			for _,obj in Utility.Connections do
				obj:Disconnect()
			end

			for _,obj in Utility.Objects do
				obj:Destroy()
			end

			Env.Library = nil
		end
	end;
	Env.Library = Library
	Env.Utility = Library.Utility
	return Library, Library.Utility
end)();

local cloneref = cloneref or function(...) return ... end
local checkcaller = checkcaller
local getnamecallmethod = getnamecallmethod
local getcallingscript = getcallingscript
local tablecreate = table.create
local mathfloor = math.floor
local mathround = math.round
local mathrandom = math.random
local tostring = tostring
local unpack = table.unpack
local getupvalues = debug.getupvalues
local getupvalue = debug.getupvalue
local setupvalue = debug.setupvalue
local getconstants = debug.getconstants
local getconstant = debug.getconstant
local setconstant = debug.setconstant
local getstack = debug.getstack
local setstack = debug.setstack
local getinfo = debug.getinfo
local debugtraceback = debug.traceback
local rawget = rawget
local tick = tick

local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiInset = game:GetService("GuiService"):GetGuiInset()
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local _CFramenew = CFrame.new
local _Vector2new = Vector2.new
local _Vector3new = Vector3.new
local _IsDescendantOf = game.IsDescendantOf
local _FindFirstChild = game.FindFirstChild
local _FindFirstChildOfClass = game.FindFirstChildOfClass
local _Raycast = workspace.Raycast
local _IsKeyDown = UserInputService.IsKeyDown
local _WorldToViewportPoint = Camera.WorldToViewportPoint
local _Vector3zeromin = Vector3.zero.Min
local _Vector2zeromin = Vector2.zero.Min
local _Vector3zeromax = Vector3.zero.Max
local _Vector2zeromax = Vector2.zero.Max
local _VectorToObjectSpace = CFrame.new().VectorToObjectSpace
local _IsA = game.IsA

local cheat = {
	Library = nil,
	Toggles = nil,
	Options = nil,
	ThemeManager = nil,
	SaveManager = nil,
	connections = {
		heartbeats = {},
		renderstepped = {}
	},
	drawings = {},
	hooks = {},
	hitsounds = {}
}

local project_delta = {
	fps_object = nil,
	fps_hooks = {},
	fps_module = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("FPS")),
	universaltable_module = require(game:GetService("ReplicatedStorage").Modules:WaitForChild("UniversalTables")),
	reload_remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Reload"),
	equip_remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Equip"),
	updatetilt_remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateTilt"),
	inventorymove_remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("InventoryMove"),
	aizones = workspace:WaitForChild("AiZones"),
	droppeditems = workspace:WaitForChild("DroppedItems"),
	itemslist = game:GetService("ReplicatedStorage"):WaitForChild("ItemsList"),
	hitboxes_priority = {
		"FaceHitBox",
		"HeadTopHitBox",
		"Head",
		"UpperTorso",
		"LowerTorso",
		"LeftUpperArm",
		"LeftLowerArm",
		"LeftHand",
		"RightUpperArm",
		"RightLowerArm",
		"RightHand",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot",
		"LeftUpperLeg",
		"LeftLowerLeg",
		"LeftFoot"
	},
	hitboxes = {
		["FaceHitBox"] = true,
		["HeadTopHitBox"] = true,
		["Head"] = true,
		["UpperTorso"] = true,
		["LowerTorso"] = true,
		["LeftUpperArm"] = true,
		["LeftLowerArm"] = true,
		["LeftHand"] = true,
		["RightUpperArm"] = true,
		["RightLowerArm"] = true,
		["RightHand"] = true,
		["RightUpperLeg"] = true,
		["RightLowerLeg"] = true,
		["RightFoot"] = true,
		["LeftUpperLeg"] = true,
		["LeftLowerLeg"] = true,
		["LeftFoot"] = true
	}
}

for i, v in getgc(true) do
	if type(v) == "table" then
		if rawget(v, "springs") and rawget(v, "characterAnimations") then
			project_delta.fps_object = v
		end
		if type(rawget(v, "RangedWeaponDefault")) == "function" and type(rawget(v, "MeleeWeaponDefault")) == "function" then
			project_delta.fps_usetypes = v
		end
		if rawget(v, "loadByHand") and type(rawget(v, "magazine")) == "function" then


			project_delta.fps_reloadtypes = v
		end
	end
end


local desync_enabled, desync_enabled_key = false, false
local old_cframe, old_velocity, replicated_hrp_cframe, forced_cframe

do
	project_delta.fps_bindable = Instance.new("BindableEvent")

	project_delta.add_fps_hook = function(f)
		project_delta.fps_bindable.Event:Connect(f)
	end

	local fps_module = project_delta.fps_module
	local old = fps_module.new

	project_delta.update_fps = getupvalue(old, 5)
	if type(project_delta.update_fps) ~= "function" then
		project_delta.update_fps = function(...) end
	end
	project_delta.remove_bullet = getupvalue(project_delta.fps_usetypes.RangedWeaponDefault, 4)

	fps_module.new = function(player, character)
		local returns = old(player, character)
		task.delay(0.5, function()
			project_delta.fps_object = returns
			project_delta.fps_bindable:Fire()
		end)
		return returns
	end

	local player_folder = game:GetService("ReplicatedStorage"):WaitForChild("Players")
	local local_game_data = player_folder:WaitForChild(LocalPlayer.Name, 9e9)

	project_delta.local_game_data = local_game_data

	project_delta.FindFirstChildOfSlotType = LPH_NO_VIRTUALIZE(function(instance, slottype)
		for _, v in instance:GetChildren() do
			if v:GetAttribute("SlotType") == slottype then
				return v
			end
			if v:GetAttribute("Slot") == slottype then
				return v
			end
		end
	end)

	local findfirstchildofslottype = project_delta.FindFirstChildOfSlotType
	project_delta.get_visor_status = LPH_NO_VIRTUALIZE(function(inventory)
		local helmet_visor = findfirstchildofslottype(inventory, "ClothingHeadware")
		if not helmet_visor then
			return false
		end

		local attachments = _FindFirstChild(helmet_visor, "Attachments")
		if not attachments then
			return false
		end

		if not attachments:GetAttribute("Visor") then
			return false
		end

		helmet_visor = findfirstchildofslottype(attachments, "Visor")

		return (helmet_visor and helmet_visor:GetAttribute("Toggle") or false)
	end)

	project_delta.get_current_magazine = LPH_NO_VIRTUALIZE(function(gun)
		return findfirstchildofslottype(gun, "Magazine")
	end)


	project_delta.calculate_speed = LPH_NO_VIRTUALIZE(function(hrp)
		local external_mod = hrp:GetAttribute("MovementModifier")
		local movement_mod = project_delta.fps_object and project_delta.fps_object.movementModifier or 0
		local total_mod = external_mod + math.clamp(movement_mod, -10, 0)
		if local_game_data.Status.GameplayVariables.Buffs:GetAttribute("SerumRed") then
			total_mod = total_mod * 0.5 + 1
		end
		return 18.2 + total_mod
	end)

	project_delta.get_compatible_mag = LPH_NO_VIRTUALIZE(function(fps_object)
		local chosen_mag, loaded_mag_ammo = nil, 0
		local compatable_mags = fps_object.itemProperties.CompatibleMagazines
		for _, container in local_game_data.Inventory:GetChildren() do
			local inventory = _FindFirstChild(container, "Inventory")
			if not inventory then continue end
			for _, item in inventory:GetChildren() do
				if not compatable_mags:GetAttribute(item.Name) then continue end

				local loaded_ammo = item:GetAttribute("LoadedAmmo") or 0
				if chosen_mag and (loaded_ammo <= 0 or loaded_mag_ammo >= loaded_ammo) then continue end

				chosen_mag = item
				loaded_mag_ammo = loaded_ammo
			end
		end
		return chosen_mag, loaded_mag_ammo
	end)

	project_delta.get_compatible_ammo = LPH_NO_VIRTUALIZE(function(fps_object, arg_ammo)
		local needed_ammo = fps_object.MaxAmmo - fps_object.Bullets
		local chosen_ammo, ammo_amount = arg_ammo, arg_ammo and arg_ammo:GetAttribute("Amount") or 0

		if needed_ammo <= 0 or (chosen_ammo and ammo_amount) then
			return chosen_ammo, needed_ammo > ammo_amount and ammo_amount or needed_ammo
		end

		local item_properties = fps_object.itemProperties
		local compatible_ammo = item_properties.CompatibleAmmo
		local preferred_ammo = item_properties:GetAttribute("PreferredAmmo")
		for _, container in local_game_data.Inventory:GetChildren() do
			local inventory = _FindFirstChild(container, "Inventory")
			if not inventory then continue end

			for _, item in inventory:GetChildren() do
				if not compatible_ammo:GetAttribute(item.Name) then continue end
				if preferred_ammo and preferred_ammo ~= item.Name then continue end

				local loaded_ammo = (item:GetAttribute("Amount") or 0)
				if chosen_ammo and ammo_amount >= loaded_ammo then continue end

				ammo_amount = loaded_ammo
				chosen_ammo = item
			end
		end

		return chosen_ammo, needed_ammo > ammo_amount and ammo_amount or needed_ammo
	end)

	project_delta.get_mags_ammo = LPH_NO_VIRTUALIZE(function()
		local mags, ammo = {}, {}
		for _, container in local_game_data.Inventory:GetChildren() do
			local inventory = _FindFirstChild(container, "Inventory")
			if not inventory then continue end
			for _, item in inventory:GetChildren() do
				local item_prop = item.Value
				if not item_prop then continue end

				local item_type = item_prop:GetAttribute("ItemType")
				if item_type == "Magazine" then
					table.insert(mags, {item:GetAttribute("LoadedAmmo"), item:GetAttribute("AmmoType"), item:GetAttribute("Slot"), item, item_prop})
				elseif item_type == "Ammo" then
					table.insert(ammo, {item:GetAttribute("Amount"), item:GetAttribute("SlotType"), item:GetAttribute("Slot"), item, item_prop})
				end
			end
		end
		return mags, ammo
	end)

	local wallpen_params = RaycastParams.new()
	wallpen_params.FilterType = Enum.RaycastFilterType.Include
	wallpen_params.IgnoreWater = true
	wallpen_params.CollisionGroup = "WeaponRay"

	local material_ballistics = project_delta.universaltable_module.UniversalTable.MaterialBallistics
	local global_ignorelist_proj = project_delta.universaltable_module.UniversalTable.GlobalIgnoreListProjectile

	project_delta.calculate_penetration = LPH_NO_VIRTUALIZE(function(hit_part, hit_position, direction_vector, penetration_power)
		if hit_part:GetAttribute("NoPen") then return 0 end

		wallpen_params.FilterDescendantsInstances = { hit_part }

		local backwards_ray_origin = hit_position + direction_vector * 5
		local reverse_direction = -direction_vector

		local exit_ray_result = _Raycast(workspace, backwards_ray_origin, reverse_direction * 5, wallpen_params)

		if not exit_ray_result then return 0 end

		local exit_part = exit_ray_result.Instance
		local exit_position = exit_ray_result.Position
		local exit_normal = exit_ray_result.Normal
		local exit_material = exit_ray_result.Material
		local thickness = (exit_position - hit_position).Magnitude
		local material_properties = material_ballistics[exit_material.Name]

		if not material_properties then return 0 end

		local penetration_cost = hit_part:GetAttribute("PenResistance") and hit_part:GetAttribute("PenResistance") * thickness or material_properties.StrengthPerStud * thickness

		if not (penetration_cost and penetration_cost < penetration_power) then return 0 end

		return penetration_power - penetration_cost, hit_position + direction_vector * 0.03
	end)

	local weapon_params = RaycastParams.new()
	weapon_params.FilterType = Enum.RaycastFilterType.Exclude
	weapon_params.IgnoreWater = false
	weapon_params.CollisionGroup = "WeaponRay"

	local calculate_penetration, hitboxes = project_delta.calculate_penetration, project_delta.hitboxes

	project_delta.target_wall_penetration = LPH_NO_VIRTUALIZE(function(origin, target_character, target_part, target_position, bullet_stats)
		local character = LocalPlayer.Character
		weapon_params.FilterDescendantsInstances = { character, Camera, global_ignorelist_proj }

		local penetration_power, muzzle_velocity = bullet_stats:GetAttribute("ArmorPen"), bullet_stats:GetAttribute("MuzzleVelocity")

		local direction = (target_position - origin).Unit * muzzle_velocity * 1/120
		while true do
			local raycast_result = _Raycast(workspace, origin, direction, weapon_params)

			if not raycast_result then
				origin += direction
				continue
			end

			local hit_instance, hit_pos = raycast_result.Instance, raycast_result.Position

			if _IsDescendantOf(hit_instance, target_character) and hitboxes[hit_instance.Name] then
				return true
			end

			local pen_rem, pen_pos = calculate_penetration(hit_instance, hit_pos, direction, penetration_power)
			penetration_power = pen_rem

			if penetration_power <= 0 then
				return false
			end

			origin = pen_pos
		end

		return false
	end)

	local noclip_params = RaycastParams.new()
	noclip_params.FilterType = Enum.RaycastFilterType.Exclude
	noclip_params.IgnoreWater = true
	noclip_params.CollisionGroup = "NoclipRay"

	project_delta.get_estimated_origin = LPH_NO_VIRTUALIZE(function(player, position)
		local character = player.Character
		local leaning_factor = character:GetAttribute("Leaning") or 0
		local hrp = character.HumanoidRootPart
		local hum = character.Humanoid;
		local estimated_camera = (position or (
			player == LocalPlayer and replicated_hrp_cframe and replicated_hrp_cframe.Position or hrp.Position)
		) + (hum:GetAttribute("Crouch") and _Vector3new(0, 0.6, 0, 0) or _Vector3new(0, 1.6, 0, 0))
		if leaning_factor == 0 then
			return estimated_camera
		else
			noclip_params.FilterDescendantsInstances = { workspace.NoCollision, workspace.DroppedItems, Camera }
			local new_camera = _CFramenew(estimated_camera - hrp.CFrame.RightVector * leaning_factor * 1.18).Position
			local result = _Raycast(workspace, estimated_camera, (new_camera - estimated_camera), noclip_params)
			if result then
				return (estimated_camera + result.Position) * 0.8
			else
				return new_camera
			end
		end
	end)
end

cheat.utility = {} do
	cheat.utility.new_heartbeat = function(func)
		local obj = {}
		cheat.connections.heartbeats[func] = func
		function obj:Disconnect()
			if func then
				cheat.connections.heartbeats[func] = nil
				func = nil
			end
		end
		return obj
	end
	cheat.utility.new_renderstepped = function(func)
		local obj = {}
		cheat.connections.renderstepped[func] = func
		function obj:Disconnect()
			if func then
				cheat.connections.renderstepped[func] = nil
				func = nil
			end
		end
		return obj
	end
	cheat.utility.new_drawing = function(drawobj, args)
		local obj = Drawing.new(drawobj)
		for i, v in (args) do
			obj[i] = v
		end
		cheat.drawings[obj] = obj
		return obj
	end
	cheat.utility.new_hook = function(f, newf, usecclosure) LPH_NO_VIRTUALIZE(function()
			if usecclosure then
				local old; old = hookfunction(f, newcclosure(function(...)
					return newf(old, ...)
				end))
				cheat.hooks[f] = old
				return old
			else
				local old; old = hookfunction(f, function(...)
					return newf(old, ...)
				end)
				cheat.hooks[f] = old
				return old
			end
		end)() end
	local connection; connection = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(delta)
		for _, func in (cheat.connections.heartbeats) do
			func(delta)
		end
	end))
	local connection1; connection1 = RunService.PreRender:Connect(LPH_NO_VIRTUALIZE(function(delta)
		for _, func in (cheat.connections.renderstepped) do
			func(delta)
		end
	end))
	cheat.utility.unload = function()
		connection:Disconnect()
		connection1:Disconnect()
		for key, _ in (cheat.connections.heartbeats) do
			cheat.connections.heartbeats[key] = nil
		end
		for key, _ in (cheat.connections.renderstepped) do
			cheat.connections.heartbeats[key] = nil
		end
		for _, drawing in (cheat.drawings) do
			drawing:Remove()
			cheat.drawings[_] = nil
		end
		for hooked, original in (cheat.hooks) do
			if type(original) == "function" then
				hookfunction(hooked, clonefunction(original))
			else
				hookmetamethod(original["instance"], original["metamethod"], clonefunction(original["func"]))
			end
		end
	end
end

local notification_queue = {}

do
    cheat.utility.new_renderstepped(function()
        for i, v in notification_queue do
			Library.Notification(v.text, v.duration)
            notification_queue[i] = nil
        end
    end)
	cheat.utility.new_heartbeat(function()
		Camera = workspace.CurrentCamera
	end)
end


if setfflag then
	setfflag("AdornShadingAPI", "true")
end

-- =========================================================
-- // Miko Hub | UI (purple neon) + selected features only
-- =========================================================

local ui = {
	window = Library:Window({
		namestart = "miko",
		nameend = "hub"
	})
}

ui.tabs = {
	movement = ui.window:Tab({name = "Movement", image = Images.Get("combat") or "rbxassetid://12941020168"}),
	misc = ui.window:Tab({name = "Misc", image = Images.Get("misc") or "rbxassetid://12941020168"}),
	settings = ui.window:Tab({name = "Settings", image = Images.Get("config") or "rbxassetid://12941020168"})
}

ui.subtabs = {
	movement_main = ui.tabs.movement:SubTab({Name = "Main"}),
	misc_main = ui.tabs.misc:SubTab({Name = "Main"}),
	settings_theme = ui.tabs.settings:SubTab({Name = "Themeing"})
}

ui.sections = {
	movement = ui.subtabs.movement_main:Section({Name = "Movement", Side = "Left"}),
	misc = ui.subtabs.movement_main:Section({Name = "Misc", Side = "Right"}),

	menu = ui.subtabs.misc_main:Section({Name = "Menu", Side = "Left"}),
	animations = ui.subtabs.misc_main:Section({Name = "Animations", Side = "Right"}),

	theme_config = ui.subtabs.settings_theme:Section({Name = "Theme", Side = "Left"}),
	theme_colors = ui.subtabs.settings_theme:Section({Name = "Colors", Side = "Right"})
}

do
	ui.tabs.movement.Set(true)

	ui.subtabs.movement_main.Set(true)
	ui.subtabs.misc_main.Set(true)
	ui.subtabs.settings_theme.Set(true)
end

-- // menu / personalization
do
	local Menu = ui.sections.menu

	Menu:Keybind({Name = "Window key", Ignore = true, Key = Enum.KeyCode.Delete, Flag = "menu_key", Callback = function()
		ui.window.Open()
	end})

	Menu:Toggle({Name = "Keybind list", Flag = "menu_keybind_list", Value = true, Callback = function(v)
		Library.KeybindsList.Status(v)
	end})

	Menu:Dropdown({Name = "Keybind style", Values = {"Pressed", "All"}, Value = "All", Flag = "menu_keybind_style", Multi = false, Callback = function(v)
		Library.KeybindsList.View = v
		Library.KeybindsList.Refresh()
	end})

	local Watermark = Library:Watermark({
		titlestart = "miko",
		titleend = "hub"
	})

	local WatermarkText;
	Menu:Toggle({Name = "Watermark", Flag = "menu_watermark", Value = true, Callback = function(v)
		Watermark.SetVisible(v)
		if WatermarkText then
			WatermarkText.State(v)
		end
	end})

	WatermarkText = Menu:Textbox({
		Name = "Watermark text",
		Value = "ping: {ping}ms | fps: {fps} | user: {user} | {date}",
		Flag = "menu_watermark_text",
		Callback = function(v)
			Watermark.SetText(v)
		end
	})

	Menu:Button({Name = "Unload", Confirm = true, Callback = function()
		Library.Unload()
	end})
end

do
	local Animations = ui.sections.animations

	Animations:Slider({Name = "Animation speed", Min = 0, Max = 100, Value = 40, Flag = "menu_animation_speed", Callback = function(v)
		Library.TweenSpeed = v / 100
	end})

	local TweenTypes = {}
	for _, v in Enum.EasingStyle:GetEnumItems() do
		table.insert(TweenTypes, v.Name)
	end

	Animations:Dropdown({Name = "Animation style", Values = TweenTypes, Value = "Exponential", Flag = "menu_animation_type", Callback = function(v)
		Library.TweenStyle = Enum.EasingStyle[v]
	end})
end

-- // skin changer / themeing
do
	local ThemeColorpickers = { }
	local Config = ui.sections.theme_config
	local SkinsReady = false

	local SkinOrder = {"Purple Neon", "Crimson", "Ocean", "Emerald", "Sunset", "Midnight"}

	local SkinPresets = {
		["Purple Neon"] = {
			outline = "08060C",
			inline = "221C2E",
			["inline hovering"] = "2C253A",
			background = "16121F",
			["dock background"] = "0F0C15",
			accent = "A855F7",
			text = "EBE7F5",
			["dark text"] = "5E5477"
		},
		["Crimson"] = {
			outline = "0C0708",
			inline = "2E1C1E",
			["inline hovering"] = "3A2527",
			background = "1F1214",
			["dock background"] = "150C0E",
			accent = "F43F5E",
			text = "F5EBEC",
			["dark text"] = "77575C"
		},
		["Ocean"] = {
			outline = "06090C",
			inline = "1C2733",
			["inline hovering"] = "253343",
			background = "121820",
			["dock background"] = "0C1015",
			accent = "38BDF8",
			text = "E7EDF5",
			["dark text"] = "54677A"
		},
		["Emerald"] = {
			outline = "060B08",
			inline = "1C2E24",
			["inline hovering"] = "253B2E",
			background = "121F18",
			["dock background"] = "0C150F",
			accent = "34D399",
			text = "E8F5EE",
			["dark text"] = "557A66"
		},
		["Sunset"] = {
			outline = "0C0806",
			inline = "2E241C",
			["inline hovering"] = "3A2E25",
			background = "1F1812",
			["dock background"] = "150F0C",
			accent = "FB923C",
			text = "F5EFE8",
			["dark text"] = "7A6553"
		},
		["Midnight"] = {
			outline = "070708",
			inline = "232326",
			["inline hovering"] = "2D2D31",
			background = "171719",
			["dock background"] = "101012",
			accent = "9CA3AF",
			text = "ECECED",
			["dark text"] = "5F5F66"
		}
	}

	local apply_skin = function(preset)
		for theme, hex in preset do
			local picker = ThemeColorpickers[theme]
			if picker then
				picker.Set({c = Color3.fromHex(hex), a = 0})
			else
				Library.UpdateTheme(theme, Color3.fromHex(hex))
			end
		end
	end

	Config:Dropdown({
		Name = "Skin",
		Values = SkinOrder,
		Value = "Purple Neon",
		Flag = "settings_skin",
		Multi = false,
		Callback = function(str)
			local preset = SkinPresets[str]

			if preset then
				apply_skin(preset)

				if SkinsReady then
					Library.Notification(
						string.format("Skin changed to %s", Utility.RichText(str, Library.Theme.accent)), 3
					)
				end
			end
		end
	})

	local _, Files = Utility.GetFiles(ThemeFolder, { ".cfg" })
	local LastFiles = Files
	local ThemeName;

	local ThemeList = Config:List({
		Values = Files,
		Value = Files[1] or "",
		Size = 135,
		Name = "",
		Flag = "settings_theme_list",
		Search = true,
		Callback = function(v)
			if ThemeName and v then
				ThemeName.Set(v)
			end
		end
	})

	ThemeName = Config:Textbox({
		Name = "Name",
		Value = "",
		Flag = "settings_theme_name"
	})

	Config:Button({
		Name = "Save",
		Confirm = true,
		Callback = function()
			local ConfigName = Library.Flags["settings_theme_name"]

			if ConfigName and ConfigName ~= "" then
				local ConfigFilePath = string.format("%s%s.cfg", ThemeFolder, ConfigName)

				writefile(ConfigFilePath, Library.GetTheme())

				Library.Notification(
					string.format("Successfully saved skin (%s).", Utility.RichText(ConfigName, Library.Theme.accent)), 5
				)

				local _, Files = Utility.GetFiles(ThemeFolder, { ".cfg" })

				ThemeList.Refresh(Files)
				ThemeList.Set(ConfigName)
			else
				Library.Notification(
					string.format("Invalid skin name (%s).", Utility.RichText(ConfigName or "", Library.Theme.accent)), 5
				)
			end
		end,
	})

	Config:Button({
		Name = "Load",
		Confirm = true,
		Callback = function()
			local ConfigName = Library.Flags["settings_theme_list"]

			if ConfigName and ConfigName ~= "" then
				local ConfigFilePath = string.format("%s%s.cfg", ThemeFolder, ConfigName)

				if isfile(ConfigFilePath) then
					local Data = Library.GetThemeData(readfile(ConfigFilePath))

					for theme, v in Data do
						local picker = ThemeColorpickers[theme]
						if picker then
							picker.Set({c = v, a = 0})
						else
							Library.UpdateTheme(theme, v)
						end
					end

					Library.Notification(
						string.format("Successfully loaded skin (%s).", Utility.RichText(ConfigName, Library.Theme.accent)), 5
					)
				else
					Library.Notification(
						string.format("Couldn't find skin (%s).", Utility.RichText(ConfigName, Library.Theme.accent)), 5
					)
				end
			end
		end,
	})

	Config:Button({
		Name = "Delete",
		Confirm = true,
		Callback = function()
			local ConfigName = Library.Flags["settings_theme_list"]

			if ConfigName and ConfigName ~= "" then
				local ConfigFilePath = string.format("%s%s.cfg", ThemeFolder, ConfigName)

				if isfile(ConfigFilePath) then
					delfile(ConfigFilePath)

					Library.Notification(
						string.format("Successfully deleted skin (%s).", Utility.RichText(ConfigName, Library.Theme.accent)), 5
					)

					local _, Files = Utility.GetFiles(ThemeFolder, { ".cfg" })

					ThemeList.Refresh(Files)
					ThemeList.Set(Files[1] or "")
				end
			end
		end,
	})

	task.spawn(function()
		while task.wait(5) do
			if ui.window.Visible then
				local _, Files = Utility.GetFiles(ThemeFolder, { ".cfg" })

				if #Files ~= #LastFiles then
					LastFiles = Files

					ThemeList.Refresh(Files)
					ThemeList.Set(Files[1] or "")
				end
			end
		end
	end)

	local Colors = ui.sections.theme_colors do
		for theme, color in (Library.Theme) do
			ThemeColorpickers[theme] = Colors:Colorpicker({Name = Utility.ToTitleCase(theme), Flag = "settings_" .. theme, Usealpha = true, Ignore = true, Value = color, Callback = function(v)
				Library.UpdateTheme(theme, v.c)
			end})
		end

		SkinsReady = true
	end
end

-- // auto reload
do
	local miscsec = ui.sections.misc
	local auto_reload = false

	local newlclosure = newlclosure or LPH_NO_VIRTUALIZE(function(f)
		return function(...)
			return f(...)
		end
	end)

	local success, old_remove
	success, old_remove = pcall(hookfunction, project_delta.remove_bullet, newlclosure(function(fps_object, ...)
		local hmm = {old_remove(fps_object, ...)}

		if not auto_reload then
			return unpack(hmm)
		end
		if fps_object.Bullets > 0 then
			return unpack(hmm)
		end

		task.spawn(fps_object.reload, fps_object)

		return unpack(hmm)
	end))

	if not success then
		print("failed to hook remove_bullet", old_remove, getgenv().newlclosure)
	else
		miscsec:Toggle({Name = "Auto reload", Value = false, Flag = "gunmods_auto_reload", Callback = function(bool)
			auto_reload = bool
		end})
	end
end

-- // movement
cheat.nc_state = {on = false, key = false, speed = 1, kinds = {"Floors", "Walls"}, layers = 1}
cheat.clipActive = false

do
	local movebox = ui.sections.movement

	local speedhack, speedhack_speed = false, 18.1
	local speedhack_autospeed, speedhack_autospeed_offset = false, 3.5
	local flyhack, flyhack_key, flyhack_speed, flyhack_speed_y = false, false, 25, 2.5
	local spiderman, spiderman_key = false, false

	do -- // no fall damage
		local nofall = false

		movebox:Toggle({Name = "No fall damage", Value = false, Flag = "no_fall_damage", Callback = function(bool)
			nofall = bool
		end})

		local falling_states = {
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Freefall,
			Enum.HumanoidStateType.PlatformStanding
		}

		local character = LocalPlayer.Character
		local hum = character and _FindFirstChildOfClass(character, "Humanoid")
		local should_no_fall = false

		task.spawn(function()
			while RunService.Heartbeat:Wait() do
				local character = LocalPlayer.Character
				if not character then
					continue
				end

				local hrp = _FindFirstChild(character, "HumanoidRootPart")
				local humanoid = _FindFirstChildOfClass(character, "Humanoid")
				if not (hrp and humanoid) then
					continue
				end

				if not nofall or not table.find(falling_states, humanoid:GetState()) then
					should_no_fall = false
					continue
				end

				humanoid:ChangeState(Enum.HumanoidStateType.Running)
				should_no_fall = true
			end
		end)

		local state_changed = LPH_NO_VIRTUALIZE(function(old, new)
			if should_no_fall and table.find(falling_states, new) then
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end
		end)

		local state_connection
		if hum then
			state_connection = hum.StateChanged:Connect(state_changed)
		end

		LocalPlayer.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			hum = humanoid
			if state_connection then state_connection:Disconnect() end
			state_connection = humanoid.StateChanged:Connect(state_changed)
		end)
	end

	do -- // speedhack / flyhack / noclip / spiderman
		movebox:Toggle({Name = "Speedhack", Value = false, Flag = "speedhack", Callback = function(bool)
			speedhack = bool
		end})
		movebox:Toggle({Name = "Speedhack auto speed", Value = false, Flag = "speedhack_autospeed", Callback = function(bool)
			speedhack_autospeed = bool
		end})
		movebox:Slider({Name = "Speedhack speed", Min = 1, Max = 24, Float = 0.1, Value = 18.1, Flag = "speedhack_speed", Callback = function(int)
			speedhack_speed = int
		end})
		movebox:Slider({Name = "Auto speed offset", Min = -5, Max = 5, Float = 0.1, Value = 3.5, Flag = "speedhack_autospeed_offset", Callback = function(int)
			speedhack_autospeed_offset = int
		end})

		local fh_keybind; fh_keybind = movebox:Toggle({Name = "Flyhack", Value = false, Flag = "flyhack", Callback = function(bool)
			flyhack = bool
		end}):Keybind({Name = "Flyhack", Mode = "Toggle", Key = Enum.KeyCode.X, Value = false, Flag = "flyhack_key", Link = "flyhack", Callback = function(bool)
			flyhack_key = flyhack and bool
			fh_keybind.Set(flyhack_key, true)
		end})
		movebox:Slider({Name = "Flyhack speed", Min = 0, Max = 50, Float = 1, Value = 25, Flag = "flyhack_speed", Callback = function(int)
			flyhack_speed = int
		end})
		movebox:Slider({Name = "Flyhack speed Y", Min = 0, Max = 50, Float = 1, Value = 2.5, Flag = "flyhack_speed_y", Callback = function(int)
			flyhack_speed_y = int
		end})

		local nc_keybind; nc_keybind = movebox:Toggle({Name = "Noclip", Value = false, Flag = "noclip", Callback = function(bool)
			cheat.nc_state.on = bool
		end}):Keybind({Name = "Noclip", Mode = "Toggle", Modes = {"Hold", "Toggle"}, Key = Enum.KeyCode.C, Value = false, Flag = "noclip_key", Link = "noclip", Callback = function(bool)
			cheat.nc_state.key = cheat.nc_state.on and bool
			nc_keybind.Set(cheat.nc_state.key, true)
		end})

		local sp_keybind; sp_keybind = movebox:Toggle({Name = "Spiderman", Value = false, Flag = "spiderman", Callback = function(bool)
			spiderman = bool
		end}):Keybind({Name = "Spiderman", Mode = "Hold", Key = Enum.KeyCode.F, Value = false, Flag = "spiderman_key", Link = "spiderman", Callback = function(bool)
			spiderman_key = spiderman and bool
			sp_keybind.Set(spiderman_key, true)
		end})
	end

	cheat.utility.new_renderstepped(LPH_NO_VIRTUALIZE(function(delta)
		local char = LocalPlayer.Character
		local hrp = char and _FindFirstChild(char, "HumanoidRootPart")
		local hum = char and _FindFirstChildOfClass(char, "Humanoid")

		if not (hrp and hum) then return end

		local calcspeed = speedhack_autospeed and project_delta.calculate_speed(hrp) + speedhack_autospeed_offset or speedhack_speed
		if speedhack then
			hum.WalkSpeed = calcspeed
		end

		local cameralook = (_Vector3new(1, 0, 1) * Camera.CFrame.LookVector).Unit
		local direction = _Vector3new(0, 0, 0)
		direction = _IsKeyDown(UserInputService, Enum.KeyCode.W) and direction + cameralook or direction;
		direction = _IsKeyDown(UserInputService, Enum.KeyCode.S) and direction - cameralook or direction;
		direction = _IsKeyDown(UserInputService, Enum.KeyCode.D) and direction + _Vector3new(-cameralook.Z, 0, cameralook.X) or direction;
		direction = _IsKeyDown(UserInputService, Enum.KeyCode.A) and direction + _Vector3new(cameralook.Z, 0, -cameralook.X) or direction;
		if direction ~= Vector3.zero then
			direction = direction.Unit
		end
		if flyhack and flyhack_key then
			local ydir = Vector3.zero
			ydir = _IsKeyDown(UserInputService, Enum.KeyCode.Space)       and ydir + Vector3.yAxis or ydir;
			ydir = _IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) and ydir - Vector3.yAxis or ydir;
			hrp.AssemblyLinearVelocity = _Vector3new(0, 0, 0)
			hrp.CFrame = hrp.CFrame + (_Vector3new(1, 0, 1) * direction * flyhack_speed * delta + flyhack_speed_y * ydir * delta)
		elseif speedhack then
			local hmm = direction * calcspeed
			hrp.AssemblyLinearVelocity = _Vector3new(hmm.X, hrp.AssemblyLinearVelocity.Y, hmm.Z)
		end
		if spiderman and spiderman_key then
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local nocol = workspace:FindFirstChild("NoCollision")
			params.FilterDescendantsInstances = nocol and {char, nocol} or {char}
			params.IgnoreWater = true
			local hit = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2, params)
			if hit and hit.Instance then
				local flat = _Vector3new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
				if flat.Magnitude > 0.01 then
					hrp.AssemblyLinearVelocity = _Vector3new(flat.Unit.X * hrp.AssemblyLinearVelocity.X, 30, flat.Unit.Z * hrp.AssemblyLinearVelocity.Z)
				else
					hrp.AssemblyLinearVelocity = _Vector3new(0, 30, 0)
				end
				if hum:GetState() ~= Enum.HumanoidStateType.Climbing then
					hum:ChangeState(Enum.HumanoidStateType.Climbing)
				end
			end
		end
	end))
end

-- // boss tracker
do
	local miscsec = ui.sections.misc

	miscsec:Toggle({Name = "Boss tracker", Value = false, Flag = "boss_tracker", Callback = function(bool)
		cheat.boss_tracker = bool
	end})

	cheat.boss_notify = false

	miscsec:Toggle({Name = "Boss spawn notify", Value = false, Flag = "boss_notify", Callback = function(bool)
		cheat.boss_notify = bool
	end})
end

-- // noclip system
do
	local NC_PROBE_WAIT = 0.05
	local NC_SINK = 0.35
	local NC_RISE = 0.25
	local NC_REACH = 3
	local NC_MAXDROP = 6
	local NC_DROP_SEARCH = 10
	local NC_DWELL = 0.25
	local NC_HELD_DIST = 4
	local NC_HELD_TIME = 4
	local NC_WALL_ROT = CFrame.Angles(math.pi / 2, 0, 0)
	local NC_OK = Color3.fromRGB(130, 255, 170)
	local NC_BAD = Color3.fromRGB(255, 93, 120)
	local NC_MID = Color3.fromRGB(255, 210, 120)
	local NC_IDLE = Color3.fromRGB(210, 210, 210)
	local function nc_rig()
		local c = LocalPlayer.Character
		local h = c and _FindFirstChild(c, "HumanoidRootPart")
		local hm = c and _FindFirstChildOfClass(c, "Humanoid")
		return c, h, hm
	end
	local function nc_uac_pos()
		local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local data = folder and folder:FindFirstChild(LocalPlayer.Name)
		local status = data and data:FindFirstChild("Status")
		local uac = status and status:FindFirstChild("UAC")
		local pos = uac and uac:GetAttribute("LastVerifiedPos")
		if typeof(pos) == "Vector3" then return pos end
		return nil
	end
	local nc_ray = RaycastParams.new()
	nc_ray.FilterType = Enum.RaycastFilterType.Exclude
	nc_ray.IgnoreWater = true
	pcall(function() nc_ray.RespectCanCollide = true end)
	local nc_over = OverlapParams.new()
	nc_over.FilterType = Enum.RaycastFilterType.Exclude
	pcall(function() nc_over.RespectCanCollide = true end)
	pcall(function() nc_over.MaxParts = 8 end)
	local function nc_filter(char)
		nc_ray.FilterDescendantsInstances = {char, workspace:FindFirstChild("NoCollision"), workspace:FindFirstChild("DroppedItems")}
	end
	cheat.groundBelow = function(pos, char)
		if char then nc_filter(char) end
		return workspace:Raycast(pos + _Vector3new(0, 2, 0), _Vector3new(0, -4096, 0), nc_ray)
	end
	local nc_probe_part = Instance.new("Part")
	nc_probe_part.Name = "NoclipProbe"
	nc_probe_part.Anchored = true
	nc_probe_part.CanCollide = false
	nc_probe_part.CanTouch = false
	nc_probe_part.CanQuery = false
	nc_probe_part.CastShadow = false
	nc_probe_part.Transparency = 1
	nc_probe_part.Size = _Vector3new(1, 1, 1)
	nc_probe_part.Parent = workspace.Terrain
	local function nc_box_free(cf, size, char)
		nc_over.FilterDescendantsInstances = {char, workspace:FindFirstChild("NoCollision"), workspace:FindFirstChild("DroppedItems"), workspace.Terrain}
		if nc_probe_part.Parent ~= workspace.Terrain then nc_probe_part.Parent = workspace.Terrain end
		nc_probe_part.Size = size
		nc_probe_part.CFrame = cf
		for _, p in workspace:GetPartsInPart(nc_probe_part, nc_over) do
			local s = p.Size
			if math.max(s.X, s.Y, s.Z) >= 1 then return p end
		end
	end
	local function nc_fit(char, cf, feet, top)
		return nc_box_free(cf * _CFramenew(0, (top - feet) / 2, 0), _Vector3new(1.2, math.max(1, feet + top - 0.7), 1), char)
	end
	for _, nc_old_name in {"SwimNoclip", "MikoNoclip"} do
		local nc_old_gui = game:GetService("CoreGui"):FindFirstChild(nc_old_name)
		if nc_old_gui then nc_old_gui:Destroy() end
	end
	local nc_gui = Instance.new("ScreenGui")
	nc_gui.Name = "MikoNoclip"
	nc_gui.ResetOnSpawn = false
	nc_gui.IgnoreGuiInset = true
	nc_gui.DisplayOrder = 10
	nc_gui.Parent = game:GetService("CoreGui")
	local nc_label = Instance.new("TextLabel")
	nc_label.AnchorPoint = _Vector2new(0.5, 0)
	nc_label.Position = UDim2.new(0.5, 0, 0.5, 24)
	nc_label.Size = UDim2.fromOffset(300, 14)
	nc_label.BackgroundTransparency = 1
	nc_label.Font = Enum.Font.Gotham
	nc_label.TextSize = 12
	nc_label.TextStrokeTransparency = 0.35
	nc_label.TextColor3 = NC_IDLE
	nc_label.Text = ""
	nc_label.Visible = false
	nc_label.Parent = nc_gui
	local function nc_status(text, color)
		if nc_label.Text ~= text then nc_label.Text = text end
		if nc_label.TextColor3 ~= color then nc_label.TextColor3 = color end
	end
	local nc_clip, nc_plan, nc_plan_err, nc_last_probe, nc_last_part, nc_part_time, nc_cooling, nc_cool_until = nil, nil, nil, 0, nil, 0, false, 0
	local function nc_kind_allowed(kind)
		if type(cheat.nc_state.kinds) ~= "table" then return true end
		return table.find(cheat.nc_state.kinds, kind) ~= nil
	end
	local function nc_dims(char, hrp, hum)
		local feet = hum.HipHeight > 0 and hum.HipHeight + hrp.Size.Y / 2 or 3
		local neck = 1
		local top = 6
		local head = char and _FindFirstChild(char, "Head")
		if head and head:IsA("BasePart") then
			local y = hrp.CFrame:PointToObjectSpace(head.Position).Y
			neck = y - head.Size.Y / 2
			top = y + head.Size.Y / 2
		end
		local min_neck = math.max(0.2, neck)
		return feet, min_neck, math.max(min_neck + 0.5, top)
	end
	local function nc_scan_layer(origin, dir, from_d, to_d)
		local lo = from_d
		for _ = 1, 8 do
			local hit = workspace:Raycast(origin + dir * (lo + 0.02), dir * math.max(0.05, to_d - lo - 0.02), nc_ray)
			local edge = hit and (hit.Position - origin):Dot(dir) - 0.02 or to_d
			if lo + 0.005 < edge then
				local back = workspace:Raycast(origin + dir * edge, -dir * (edge - from_d + 0.01), nc_ray)
				if back then
					local t = (back.Position - origin):Dot(dir)
					if from_d + 0.01 < t then return t end
				end
			end
			if not hit then return nil end
			lo = (hit.Position - origin):Dot(dir)
			if to_d <= lo then return nil end
		end
	end
	local function nc_scan_stack(origin, dir, first_len, need_room, max_dist, max_layers)
		local d = 0
		local layers = 0
		while true do
			local thick = nc_scan_layer(origin, dir, d, first_len)
			if not thick then
				return nil, layers == 0 and "too thick" or "a layer below is too thick"
			end
			layers += 1
			local fwd = workspace:Raycast(origin + dir * (thick + 0.02), dir * max_dist, nc_ray)
			local room = fwd and (fwd.Position - origin):Dot(dir) - thick or nil
			if not room or room >= need_room then
				return thick, room, layers
			end
			if max_layers <= layers then break end
			d = thick + room
		end
		return nil, ("%d+ floors thick, raise Max Floors"):format(layers + 1)
	end
	local function nc_cf_at(plan, d)
		return _CFramenew(plan.surf + plan.n * d) * plan.rot
	end
	local function nc_snap_ground(char, hrp, feet)
		if not (hrp and hrp.Parent) then return end
		if char then nc_filter(char) end
		local p = hrp.Position
		local hit = workspace:Raycast(p + _Vector3new(0, 1, 0), _Vector3new(0, -256, 0), nc_ray)
		if not hit then return end
		local drop = p.Y - hit.Position.Y + feet
		if drop > 0.05 then hrp.CFrame = hrp.CFrame - _Vector3new(0, drop, 0) end
	end
	local function nc_finish(mode, msg)
		local c = nc_clip
		if not c then return end
		nc_clip = nil
		cheat.clipActive = false
		local char, hrp = nc_rig()
		if hrp and hrp.Parent then
			pcall(function()
				if mode == "back" then
					hrp.CFrame = c.start
				elseif mode == "finish" then
					hrp.CFrame = c.kind == "floor" and nc_cf_at(c, c.uEnd) or c.final
				end
				local done = mode ~= "back" and (mode == "finish" or (c.phase or 0) >= 2)
				if done then
					nc_snap_ground(char, hrp, c.feet or 3)
					local cf = hrp.CFrame
					local lv = cf.LookVector
					local flat = _Vector3new(lv.X, 0, lv.Z)
					if flat.Magnitude < 0.001 then flat = cf.RightVector end
					hrp.CFrame = CFrame.lookAt(cf.Position, cf.Position + flat.Unit)
				end
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
		for _, p in c.parts do
			if p.Parent then pcall(function() p.CanCollide = true end) end
		end
		if c.hum and c.hum.Parent then
			pcall(function() c.hum.PlatformStand = c.stood == true end)
		end
		nc_cooling = true
		nc_cool_until = os.clock() + 0.75
		nc_plan = nil
		if msg then Library.Notification("Noclip: " .. msg, 3) end
	end
	local function nc_start(plan, char, hrp, hum)
		plan.start = hrp.CFrame
		plan.hum = hum
		plan.stood = hum.PlatformStand
		if plan.kind == "floor" then
			plan.u = plan.surf.Y - hrp.Position.Y
			plan.phase = 1
		else
			plan.u = math.max((hrp.Position - plan.surf):Dot(plan.n), -plan.feet)
			plan.phase = 0
		end
		plan.uStart = plan.u
		plan.phaseAt = os.clock()
		plan.waited = 0
		local base = nc_uac_pos()
		plan.uacBase = base and base - hrp.Position or nil
		plan.parts = {}
		for _, p in char:GetDescendants() do
			if p:IsA("BasePart") and p.CanCollide then
				plan.parts[#plan.parts + 1] = p
				p.CanCollide = false
			end
		end
		hum.PlatformStand = true
		nc_clip = plan
		cheat.clipActive = true
	end
	local function nc_step(dt, hrp)
		local c = nc_clip
		local now = os.clock()
		local target
		if c.phase == 0 then
			local k = math.min(1, (now - c.phaseAt) / NC_SINK)
			target = c.start:Lerp(nc_cf_at(c, c.u), 1 - (1 - k) ^ 4)
			if k >= 1 then c.phase = 1 c.phaseAt = now end
		elseif c.phase == 3 then
			local k = math.min(1, (now - c.phaseAt) / NC_RISE)
			target = nc_cf_at(c, c.uEnd):Lerp(c.final, 1 - (1 - k) ^ 4)
			if k >= 1 then
				hrp.CFrame = c.final
				return nc_finish(nil)
			end
		else
			local uac = c.uacBase and nc_uac_pos()
			c.held = uac and (uac - hrp.Position - c.uacBase).Magnitude > NC_HELD_DIST or false
			if c.held then
				c.waited = c.waited + dt
				if NC_HELD_TIME < c.waited then
					return nc_finish("back", "the server never caught up, put you back")
				end
			else
				c.waited = 0
				c.u = c.u + math.max(0.5, cheat.nc_state.speed) * math.min(dt, 0.1)
				if c.phase == 1 and c.u >= c.neck then c.phase = 2 c.phaseAt = now end
				if c.phase == 2 and c.u >= c.uEnd then
					c.u = c.uEnd
					if c.kind == "floor" then
						hrp.CFrame = nc_cf_at(c, c.uEnd)
						return nc_finish(nil)
					end
					c.phase = 3
					c.phaseAt = now
				end
			end
			target = nc_cf_at(c, c.u)
		end
		hrp.CFrame = target
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	local function nc_probe(char, hrp, hum)
		if hum.Sit then return nil, "seated" end
		local cam_cf = Camera.CFrame
		local pos = hrp.Position
		nc_filter(char)
		local feet, neck, top = nc_dims(char, hrp, hum)
		local down = workspace:Raycast(pos, _Vector3new(0, -(feet + 3), 0), nc_ray)
		if hum.FloorMaterial == Enum.Material.Air and not down then
			return nil, "not on the ground"
		end
		local cam_hit = workspace:Raycast(cam_cf.Position, cam_cf.LookVector * math.min(80, (cam_cf.Position - pos).Magnitude + NC_REACH + 6), nc_ray)
		if not cam_hit then return nil end
		local look = hrp.CFrame.LookVector
		local flat = _Vector3new(look.X, 0, look.Z)
		local yaw = CFrame.lookAt(Vector3.zero, flat.Magnitude > 0.001 and flat.Unit or _Vector3new(0, 0, -1))
		local plan = {part = cam_hit.Instance, feet = feet, neck = neck, top = top}
		local layers = math.max(1, math.floor(cheat.nc_state.layers or 1))
		local dist2d = _Vector3new(cam_hit.Position.X - pos.X, 0, cam_hit.Position.Z - pos.Z).Magnitude
		if cam_hit.Normal.Y > 0.5 then
			if dist2d > NC_REACH + 3 or math.abs(cam_hit.Position.Y - pos.Y - feet) > 3 then return nil end
			if not nc_kind_allowed("Floors") then return nil, "floors are off" end
			if not (down and down.Normal.Y > 0.5) then return nil, "not standing on it" end
			plan.kind = "floor"
			plan.n = _Vector3new(0, -1, 0)
			plan.rot = yaw
			plan.surf = _Vector3new(pos.X, down.Position.Y, pos.Z)
			plan.part = down.Instance
			local need = feet + top + 0.3
			local thick, room, n = nc_scan_stack(plan.surf, plan.n, NC_MAXDROP + 0.5, need, NC_DROP_SEARCH + need + 1, layers)
			if not thick then return nil, room end
			if not room then return nil, "drop is past Max Drop" end
			plan.t = thick
			plan.layers = n
			local floor_y = plan.surf.Y - thick - top - 0.3
			plan.uEnd = plan.surf.Y - floor_y
			plan.final = _CFramenew(_Vector3new(pos.X, floor_y, pos.Z)) * yaw
			local blocked = nc_fit(char, plan.final, feet, top)
			if blocked then return nil, "blocked by " .. blocked.Name end
			return plan
		end
		if math.abs(cam_hit.Normal.Y) < 0.6 then
			if dist2d > NC_REACH + 3 or cam_hit.Position.Y < pos.Y - feet - 1 or cam_hit.Position.Y > pos.Y + top + 3 then return nil end
			if not nc_kind_allowed("Walls") then return nil, "walls are off" end
			local nrm = _Vector3new(-cam_hit.Normal.X, 0, -cam_hit.Normal.Z)
			if nrm.Magnitude < 0.001 then return nil, "too steep" end
			local dir = nrm.Unit
			local side = nil
			for _, h in {0, -feet * 0.6, neck} do
				local r = workspace:Raycast(pos + _Vector3new(0, h, 0), dir * (NC_REACH + 1.5), nc_ray)
				if r and math.abs(r.Normal.Y) < 0.6 then side = r break end
			end
			if not side then return nil, "too far to reach" end
			local out = _Vector3new(-side.Normal.X, 0, -side.Normal.Z).Unit
			plan.kind = "wall"
			plan.n = out
			plan.rot = CFrame.lookAt(Vector3.zero, out) * NC_WALL_ROT
			plan.surf = pos + out * (side.Position - pos):Dot(out)
			plan.part = side.Instance
			local thick, room, n = nc_scan_stack(plan.surf, out, NC_MAXDROP + 0.5, 1.6, top + 3.5, layers)
			if not thick then return nil, room end
			plan.t = thick
			plan.layers = n
			plan.uEnd = thick + top + 0.3
			local blocked_name = nil
			local nofloor = false
			for _, lift in {0, 0.75, 1.5, 2.5} do
				local d = thick + 0.9 + lift
				if room and d - thick + 0.6 > room then break end
				local beyond = plan.surf + out * d
				local floor_hit = workspace:Raycast(beyond + _Vector3new(0, 2.5, 0), _Vector3new(0, -(feet + 7), 0), nc_ray)
				local fy = floor_hit and floor_hit.Position.Y + feet
				if fy and fy <= pos.Y + 2.5 and fy >= pos.Y - 4 then
					local fpos = _Vector3new(beyond.X, fy, beyond.Z)
					local fcf = CFrame.lookAt(fpos, fpos + out)
					local b = nc_fit(char, fcf, feet, top)
					if not b then plan.final = fcf return plan end
					blocked_name = b
				else
					nofloor = true
				end
			end
			if blocked_name then return nil, "blocked by " .. blocked_name.Name end
			return nil, nofloor and "no floor behind it" or "no room behind it"
		end
		return nil, "too steep"
	end
	RunService.Stepped:Connect(function()
		local c = nc_clip
		if not c then return end
		for _, p in c.parts do
			if p.CanCollide then p.CanCollide = false end
		end
	end)
	RunService.Heartbeat:Connect(function(dt)
		local active = cheat.nc_state.on and cheat.nc_state.key
		local char, hrp, hum = nc_rig()
		local alive = hrp ~= nil and hum ~= nil and hum.Health > 0
		nc_label.Visible = active and alive
		if nc_clip then
			if not (alive and nc_clip.hum == hum) then
				nc_finish(nil)
			elseif not active then
				nc_finish((nc_clip.phase or 0) >= 2 and "finish" or "back")
			else
				local ok = pcall(nc_step, dt, hrp)
				if not ok then nc_finish("back", "stopped on an error, put you back") end
			end
			local c = nc_clip
			if c then
				local h = math.max(0.001, c.uEnd - c.uStart)
				local pct = math.floor(math.clamp((c.u - c.uStart) / h, 0, 1) * 100)
				nc_status(c.held and ("CLIPPING %d%%  waiting on server"):format(pct) or ("CLIPPING %d%%"):format(pct), NC_MID)
			end
			return
		end
		if not (active and alive) then nc_plan = nil return end
		local now = os.clock()
		if now - nc_last_probe >= NC_PROBE_WAIT then
			nc_last_probe = now
			local ok, plan, err = pcall(nc_probe, char, hrp, hum)
			nc_plan, nc_plan_err = ok and plan or nil, ok and err or "probe failed"
		end
		if nc_cooling then
			if nc_plan then
				nc_status("LOOK AWAY TO CLIP AGAIN", NC_IDLE)
				return
			end
			nc_cooling = false
		end
		if not nc_plan then
			nc_status(nc_plan_err and "NOT CLIPPABLE  " .. nc_plan_err or "NOT CLIPPABLE", nc_plan_err and NC_BAD or NC_IDLE)
			return
		end
		nc_status(("CLIPPABLE  %s %.1fst%s"):format(nc_plan.kind, nc_plan.t, (nc_plan.layers or 1) > 1 and (("  %d floors"):format(nc_plan.layers)) or ""), NC_OK)
		if nc_plan.part ~= nc_last_part then nc_last_part, nc_part_time = nc_plan.part, now end
		if now - nc_part_time >= NC_DWELL and now >= nc_cool_until then
			local q = nc_plan
			nc_plan = nil
			if not pcall(nc_start, q, char, hrp, hum) then
				nc_clip = q.parts and q or nil
				nc_finish("back", "could not start")
			end
		end
	end)
	LocalPlayer.CharacterAdded:Connect(function()
		nc_clip = nil
		nc_plan = nil
		nc_last_part = nil
		cheat.clipActive = false
	end)
end

-- // boss tracker panel
		do
			local boss_defs = {
				Anton = Color3.fromRGB(255, 140, 50),
				Dozer = Color3.fromRGB(255, 112, 112),
				Whisper = Color3.fromRGB(180, 100, 255),
				ScavKing = Color3.fromRGB(255, 192, 50),
				Grif = Color3.fromRGB(90, 190, 255),
				BTR80 = Color3.fromRGB(100, 255, 150),
				MI24V = Color3.fromRGB(100, 255, 150),
				Death = Color3.fromRGB(220, 20, 60)
			}
			local boss_order = {"Anton", "Dozer", "Whisper", "ScavKing", "Grif", "BTR80", "MI24V", "Death"}
			for _, boss_old_name in {"SwimBossTracker", "MikoBossTracker"} do
				local boss_old_gui = game:GetService("CoreGui"):FindFirstChild(boss_old_name)
				if boss_old_gui then boss_old_gui:Destroy() end
			end
			local boss_gui = Instance.new("ScreenGui")
			boss_gui.Name = "MikoBossTracker"
			boss_gui.ResetOnSpawn = false
			boss_gui.IgnoreGuiInset = true
			boss_gui.DisplayOrder = -1
			boss_gui.Enabled = false
			boss_gui.Parent = game:GetService("CoreGui")
			local boss_outer = Instance.new("Frame")
			boss_outer.Name = "Panel"
			boss_outer.AnchorPoint = Vector2.new(0, 0)
			do
				local vs = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
				boss_outer.Position = UDim2.new(0, math.max(vs.X - 270, 0), 0, 120)
			end
			boss_outer.Size = UDim2.fromOffset(230, 190)
			boss_outer.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
			boss_outer.BorderSizePixel = 0
			boss_outer.Active = true
			boss_outer.Parent = boss_gui
			do
				local drag, ox, oy, mx, my = false, 0, 0, 0, 0
				boss_outer.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						drag = true
						ox, oy = boss_outer.Position.X.Offset, boss_outer.Position.Y.Offset
						mx, my = input.Position.X, input.Position.Y
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
						local vs = Camera.ViewportSize
						boss_outer.Position = UDim2.new(0, math.clamp(ox + input.Position.X - mx, 0, math.max(vs.X - boss_outer.AbsoluteSize.X, 0)), 0, math.clamp(oy + input.Position.Y - my, 0, math.max(vs.Y - boss_outer.AbsoluteSize.Y, 0)))
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
				end)
			end
			local boss_stroke = Instance.new("UIStroke")
			boss_stroke.Thickness = 1
			boss_stroke.Color = Library.Theme.accent
			boss_stroke.Parent = boss_outer
			Library.AddObjectTheme(boss_stroke, { Color = "accent" })
			local boss_title = Instance.new("TextLabel")
			boss_title.BackgroundTransparency = 1
			boss_title.BorderSizePixel = 0
			boss_title.Position = UDim2.new(0, 8, 0, 4)
			boss_title.Size = UDim2.new(1, -16, 0, 16)
			boss_title.FontFace = Fonts.Get("TahomaXP")
			boss_title.TextSize = 12
			boss_title.TextXAlignment = Enum.TextXAlignment.Left
			boss_title.TextColor3 = Library.Theme.accent
			boss_title.Text = "Boss tracker"
			boss_title.Parent = boss_outer
			Library.AddObjectTheme(boss_title, { TextColor3 = "accent" })
			local boss_empty = Instance.new("TextLabel")
			boss_empty.BackgroundTransparency = 1
			boss_empty.BorderSizePixel = 0
			boss_empty.Position = UDim2.new(0, 8, 0, 22)
			boss_empty.Size = UDim2.new(1, -16, 0, 16)
			boss_empty.FontFace = Fonts.Get("TahomaXP")
			boss_empty.TextSize = 12
			boss_empty.TextXAlignment = Enum.TextXAlignment.Left
			boss_empty.TextColor3 = Color3.fromRGB(230, 230, 230)
			boss_empty.TextTruncate = Enum.TextTruncate.AtEnd
			boss_empty.Text = "no bosses alive"
			boss_empty.Visible = false
			boss_empty.Parent = boss_outer
			local boss_rows = {}
			for i, name in boss_order do
				local row = Instance.new("Frame")
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0
				row.Position = UDim2.new(0, 8, 0, 22 + (i - 1) * 20)
				row.Size = UDim2.new(1, -16, 0, 20)
				row.Visible = false
				row.Parent = boss_outer
				local pip = Instance.new("Frame")
				pip.AnchorPoint = Vector2.new(0, 0.5)
				pip.Position = UDim2.new(0, 0, 0.5, 0)
				pip.Size = UDim2.fromOffset(6, 6)
				pip.BorderSizePixel = 0
				pip.BackgroundColor3 = boss_defs[name]
				pip.Parent = row
				local n = Instance.new("TextLabel")
				n.BackgroundTransparency = 1
				n.BorderSizePixel = 0
				n.Position = UDim2.new(0, 10, 0, 0)
				n.Size = UDim2.new(0.45, -10, 1, 0)
				n.FontFace = Fonts.Get("TahomaXP")
				n.TextSize = 12
				n.TextXAlignment = Enum.TextXAlignment.Left
				n.TextColor3 = boss_defs[name]
				n.TextTruncate = Enum.TextTruncate.AtEnd
				n.Text = name
				n.Parent = row
				local info = Instance.new("TextLabel")
				info.BackgroundTransparency = 1
				info.BorderSizePixel = 0
				info.Position = UDim2.new(0.45, 0, 0, 0)
				info.Size = UDim2.new(0.55, 0, 1, 0)
				info.FontFace = Fonts.Get("TahomaXP")
				info.TextSize = 12
				info.TextXAlignment = Enum.TextXAlignment.Right
				info.TextColor3 = Color3.fromRGB(230, 230, 230)
				info.TextTruncate = Enum.TextTruncate.AtEnd
				info.Text = ""
				info.Parent = row
				local barbg = Instance.new("Frame")
				barbg.Position = UDim2.new(0, 10, 1, -4)
				barbg.Size = UDim2.new(1, -10, 0, 3)
				barbg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
				barbg.BorderSizePixel = 0
				barbg.Parent = row
				local bar = Instance.new("Frame")
				bar.Size = UDim2.new(1, 0, 1, 0)
				bar.BackgroundColor3 = boss_defs[name]
				bar.BorderSizePixel = 0
				bar.Parent = barbg
				boss_rows[name] = {row = row, info = info, bar = bar}
			end
			local boss_seen = {}
			local boss_tick = 0
			local function boss_anchor(model)
				return _FindFirstChild(model, "HumanoidRootPart") or _FindFirstChild(model, "Head") or _FindFirstChild(model, "UpperTorso") or _FindFirstChild(model, "Chassis") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
			end
			cheat.utility.new_renderstepped(function()
				if not cheat.boss_tracker then
					boss_gui.Enabled = false
					return
				end
				boss_gui.Enabled = true
				local now = os.clock()
				if now - boss_tick < 0.5 then return end
				boss_tick = now
				local campos = Camera.CFrame.Position
				local found = {}
				local zones = workspace:FindFirstChild("AiZones")
				local function scan_boss_zone(zone, depth)
					if depth > 6 then return end
					for _, model in zone:GetChildren() do
							if model:IsA("Model") and boss_defs[model.Name] then
								local hum = _FindFirstChildOfClass(model, "Humanoid")
								local alive = false
								local hp, maxhp = 0, 0
								if hum then
									alive = hum.Health > 0
									hp, maxhp = math.floor(hum.Health), math.floor(hum.MaxHealth)
								else
									local root = boss_anchor(model)
									local h = root and root:GetAttribute("Health")
									if h then
										hp = math.floor(h)
										alive = hp ~= 0
									end
								end
								if alive then
									local anchor = boss_anchor(model)
									if anchor then
										found[model.Name] = true
										if not boss_seen[model.Name] then
											boss_seen[model.Name] = true
											if cheat.boss_notify then
												Library.Notification("BOSS SPAWNED: " .. model.Name .. " (" .. zone.Name .. ")", 5)
											end
										end
										local dist = math.floor((campos - anchor.Position).Magnitude / 3)
										local hps = maxhp > 0 and (" " .. math.floor(hp / maxhp * 100) .. "%") or (hp > 0 and (" " .. hp) or "")
										local brow = boss_rows[model.Name]
										if brow then
											brow.info.Text = (zone.Name or "?") .. "  " .. dist .. "m" .. hps
											brow.row.Visible = true
											local k = maxhp > 0 and math.clamp(hp / maxhp, 0, 1) or 1
											brow.bar.Size = UDim2.new(k, 0, 1, 0)
											brow.bar.BackgroundColor3 = k < 0.5 and Color3.fromRGB(225, 65, 65):Lerp(Color3.fromRGB(235, 200, 70), k / 0.5) or Color3.fromRGB(235, 200, 70):Lerp(Color3.fromRGB(75, 215, 95), (k - 0.5) / 0.5)
										end
									end
								end
							end
							if #model:GetChildren() > 0 then
								scan_boss_zone(model, depth + 1)
							end
						end
					end
				if zones then
					scan_boss_zone(zones, 0)
				end
				for _, name in boss_order do
					local brow = boss_rows[name]
					if brow and not found[name] then
						brow.row.Visible = false
					end
				end
				boss_empty.Visible = next(found) == nil
				for name, _ in boss_seen do
					if not found[name] then
						boss_seen[name] = nil
					end
				end
			end)
		end

-- // moderator detector + report notifications
do
	local miscsec = ui.sections.misc

	local mod_enabled, mod_volume = false, 3
	local mod_tracked = {}
	local mod_group_id = 3765739
	local mod_group_roles = {
		["Tester"] = true,
		["Content Creator"] = true,
		["Test Coordinator"] = true,
		["New Devs"] = true,
		["Dev Team"] = true,
		["Moderator"] = true,
		["Head Moderator"] = true,
		["Admin"] = true,
		["Developer"] = true,
		["Lead developer"] = true
	}
	local mod_group_cache = {}
	local function mod_group_role(player)
		if player == LocalPlayer then return false end
		local cached = mod_group_cache[player]
		if cached ~= nil then return cached end
		mod_group_cache[player] = false
		task.spawn(function()
			local ok, role = pcall(function()
				return player:GetRoleInGroup(mod_group_id)
			end)
			if ok and role and mod_group_roles[role] then
				mod_group_cache[player] = true
			end
		end)
		return false
	end
	local function mod_play(asset)
		if asset == "" then return end
		local s = Instance.new("Sound")
		s.SoundId = asset
		s.Volume = mod_volume
		s.Parent = SoundService
		s.PlayOnRemove = true
		s:Destroy()
	end
	local function mod_is_mod(player)
		if player == LocalPlayer then return false end
		return mod_group_role(player)
	end
	local function mod_scan()
		for _, player in Players:GetPlayers() do
			if mod_is_mod(player) then
				if not mod_tracked[player] then
					mod_tracked[player] = true
					Library.Notification("moderator join " .. player.Name, 9999)
					mod_play(admin_join_asset)
				end
			elseif mod_tracked[player] then
				mod_tracked[player] = nil
				Library.Notification("moderator leave " .. player.Name, 9999)
				mod_play(admin_leave_asset)
			end
		end
	end
	local mod_volume_slider = nil
	local mod_toggle = miscsec:Toggle({Name = "Moderator detector", Value = false, Flag = "misc_moderator_detector", Callback = function(bool)
		mod_enabled = bool
		if mod_volume_slider then mod_volume_slider.State(bool) end
		if bool then
			mod_scan()
		else
			table.clear(mod_tracked)
		end
	end})
	mod_volume_slider = miscsec:Slider({Name = "Moderator volume", Min = 0.1, Max = 10, Float = 0.1, Value = 3, Flag = "misc_moderator_volume", Suffix = "%s", Callback = function(int)
		mod_volume = int
	end})
	mod_volume_slider.State(false)
	local cheater_detector = false
	miscsec:Toggle({Name = "Cheater detector", Value = false, Flag = "cheatwatch_enabled", Callback = function(bool)
		cheater_detector = bool
	end})
	Players.PlayerRemoving:Connect(function(player)
		mod_group_cache[player] = nil
		if mod_tracked[player] then
			mod_tracked[player] = nil
			if mod_enabled then
				Library.Notification("moderator leave " .. player.Name, 9999)
				mod_play(admin_leave_asset)
			end
		end
	end)
	task.spawn(function()
		while task.wait(2) do
			if mod_enabled then
				mod_scan()
			end
		end
	end)
	miscsec:Toggle({Name = "Report notifications", Value = false, Flag = "misc_report_notifications", Callback = function(bool)
		cheat.report_notifications = bool
	end})
	miscsec:Button({Name = "Show current Reports", Callback = function()
		local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local data = folder and folder:FindFirstChild(LocalPlayer.Name)
		local status = data and data:FindFirstChild("Status")
		local uac = status and status:FindFirstChild("UAC")
		local reports = uac and uac:FindFirstChild("Reports")
		local total = reports and reports:GetAttribute("1") or 0
		Library.Notification("You currently have " .. tostring(total) .. " report(s)", 4)
	end})
	cheat.report_notifications = false
	local report_last_total = nil
	local function report_total()
		local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local data = folder and folder:FindFirstChild(LocalPlayer.Name)
		local status = data and data:FindFirstChild("Status")
		local uac = status and status:FindFirstChild("UAC")
		local reps = uac and uac:FindFirstChild("Reports")
		if not reps then return 0 end
		local n = 0
		for _, v in reps:GetAttributes() do
			if typeof(v) == "number" then
				n += v
			end
		end
		return n
	end
	task.spawn(function()
		while task.wait(0.5) do
			if cheat.report_notifications then
				local total = report_total()
				if report_last_total == nil then
					report_last_total = total
				elseif total > report_last_total then
					Library.Notification("You were reported! (+" .. (total - report_last_total) .. " report(s), Total: " .. total .. ")", 7)
					report_last_total = total
				elseif total < report_last_total then
					report_last_total = total
				end
			end
		end
	end)
	local recent_folder = game:GetService("ReplicatedStorage"):FindFirstChild("ReportList")
	recent_folder = recent_folder and recent_folder:FindFirstChild("Recent")
	if recent_folder then
		recent_folder.ChildAdded:Connect(function(child)
			if cheat.report_notifications then
				local name = child.Name:match("(.+)_([^_]+)$")
				if name == LocalPlayer.Name then
					Library.Notification("Added to Recent Reports list!", 7)
				end
			end
		end)
	end
end
