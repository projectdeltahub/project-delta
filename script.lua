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
	SWG_DiscordUser = "furra"
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
			outline = Color3.fromRGB(0, 0, 0),
			inline = Color3.fromRGB(43, 31, 55),
			["inline hovering"] = Color3.fromRGB(58, 42, 75),

			background = Color3.fromRGB(16, 12, 22),
			["dock background"] = Color3.fromRGB(11, 9, 16),

			accent = Color3.fromRGB(166, 107, 255),

			text = Color3.fromRGB(230, 230, 230),
			["dark text"] = Color3.fromRGB(86, 86, 86),
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
				BackgroundColor3 = Color3.fromRGB(11, 9, 16),
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
					BackgroundColor3 = Color3.fromRGB(11, 9, 16),
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
					BackgroundColor3 = Color3.fromRGB(11, 9, 16),
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
					TextColor3 = Color3.fromRGB(166, 107, 255),
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
					TextColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
				namestart = "Miko",
				nameend = "Hub",
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(11, 9, 16),
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
					Padding = UDim.new(0, 4),
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
					TextColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
					Parent = Objects.outline,
				}, { BackgroundColor3 = "background" })

				Objects.dock_background = Utility.New("Frame", {
					Name = "dock_background",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, 0, 0, 28),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(11, 9, 16),
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
					ScrollBarImageColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

			Objects.accent = Utility.New("Frame", {
				Name = "accent",
				Position = UDim2.new(0, 1, 0, 1),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				Size = UDim2.new(1, -2, 1, -2),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("Frame", {
					Name = "accent",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0.5, 0, 1, 0),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Library.ScreenGui,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 0),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -1),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = Color3.fromRGB(166, 107, 255),
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
						BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.box,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
					Parent = Objects.inline,
				}, { BackgroundColor3 = "background" })

				Objects.accent = Utility.New("ScrollingFrame", {
					Active = true,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarImageColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Objects.line,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Parent,
				}, { BackgroundColor3 = "inline" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(43, 31, 55),
					Parent = Library.ScreenGui,
				}, { BackgroundColor3 = "inline" })

				Popup.Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
							BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
				titlestart = "Miko ",
				titleend = "Hub",
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
					Parent = Library.NotificationHolder,
				}, { BackgroundColor3 = "accent" })

				Objects.background = Utility.New("Frame", {
					Name = "background",
					Position = UDim2.new(0, 1, 0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(1, -2, 1, -2),
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					TextColor3 = Color3.fromRGB(166, 107, 255),
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
					BackgroundColor3 = Color3.fromRGB(16, 12, 22),
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
					BackgroundColor3 = Color3.fromRGB(166, 107, 255),
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
			if Library.OnUnload then -- FPS fix 2026-11-03: run cheat cleanup hooks
				local unload_hooks = Library.OnUnload
				Library.OnUnload = nil
				for _,hookfn in unload_hooks do
					pcall(hookfn)
				end
			end
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

local workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local _CFramenew, _Vector2new, _Vector3new = CFrame.new, Vector2.new, Vector3.new
local _FindFirstChild, _FindFirstChildOfClass = game.FindFirstChild, game.FindFirstChildOfClass
local _IsKeyDown = UserInputService.IsKeyDown
local unpack = table.unpack
local cheat = {nc_state = {on = false, key = false, speed = 1, kinds = {"Floors", "Walls"}, layers = 1}, utility = {}}
-- FPS fix 2026-11-03: track every cheat connection/loop so Unload stops them all (no stacked loops on re-inject)
cheat.utility.cleanup = {conns = {}, dead = false}
cheat.utility.track = function(conn)
	if conn then
		cheat.utility.cleanup.conns[#cheat.utility.cleanup.conns + 1] = conn
	end
	return conn
end
cheat.utility.on_unload = function(fn)
	local Lib0 = (getgenv and getgenv() or _G).Library
	if Lib0 then
		Lib0.OnUnload = Lib0.OnUnload or {}
		table.insert(Lib0.OnUnload, fn)
	end
end
cheat.utility.new_heartbeat = function(f) return cheat.utility.track(RunService.Heartbeat:Connect(f)) end
cheat.utility.new_renderstepped = function(f) return cheat.utility.track(RunService.RenderStepped:Connect(f)) end
cheat.utility.on_unload(function()
	cheat.utility.cleanup.dead = true
	for _, c in cheat.utility.cleanup.conns do
		pcall(function() c:Disconnect() end)
	end
	cheat.utility.cleanup.conns = {}
end)
local project_delta = {}
local ui = {window = Library:Window({namestart = "Miko", nameend = "Hub"})}
ui.tabs = {
 skins = ui.window:Tab({name = "Skins", image = "rbxassetid://17415964540", size = 76}),
 main = ui.window:Tab({name = "Main", image = Images.Get("misc")}),
 settings = ui.window:Tab({name = "Settings", image = Images.Get("config")})
}
ui.subtabs = {skins = ui.tabs.skins:SubTab({Name = "Skin Changer"}), skins_weapon = ui.tabs.skins:SubTab({Name = "Weapon Editor"}), main = ui.tabs.main:SubTab({Name = "Main"}), settings = ui.tabs.settings:SubTab({Name = "Config"})}
ui.sections = {
 skins_browser = ui.subtabs.skins:Section({Name = "Weapons", Side = "Left"}),
 skins_actions = ui.subtabs.skins:Section({Name = "Skins", Side = "Right"}),
 weapon_mods = ui.subtabs.skins_weapon:Section({Name = "Attachments", Side = "Left"}),
 weapon_list = ui.subtabs.skins_weapon:Section({Name = "Weapons", Side = "Right"}),
 movement = ui.subtabs.main:Section({Name = "Movement", Side = "Left"}),
 misc = ui.subtabs.main:Section({Name = "Misc", Side = "Right"}),
 settings_config = ui.subtabs.settings:Section({Name = "Config", Side = "Left"})
}
ui.tabs.main.Set(true)
ui.subtabs.skins.Set(true)
ui.subtabs.main.Set(true)
ui.subtabs.settings.Set(true)
ui.sections.settings_config:Toggle({Name = "Show keybinds", Value = true, Flag = "show_keybinds", Callback = function(visible)
 Library.KeybindsList.Status(visible)
end})
cheat.utility.track(UserInputService.InputBegan:Connect(function(input, processed)
 if not processed and input.KeyCode == Enum.KeyCode.Delete then ui.window.Open() end
end))
		cheat.dressSkin = function(model, item_name, selected_skin)
			local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Skins")
			if not model or not folder then return end
			local item = folder:FindFirstChild(item_name)
			local skin = item and item:FindFirstChild(selected_skin)
			if not skin then return end
			local textures = skin:FindFirstChild("Textures")
			local materials = skin:FindFirstChild("Materials")
			if not textures and not materials then return end
			local parts = {}
			for _, child in model:GetChildren() do
				table.insert(parts, child)
				for _, nested in child:GetChildren() do
					table.insert(parts, nested)
				end
			end
			for _, part in parts do
				local key = part:GetAttribute("Skinnable")
				local texture = key and textures and textures:FindFirstChild(key)
				if texture then
					pcall(function()
						for _, old in part:GetChildren() do
							if old:IsA(texture.ClassName) then old:Destroy() end
						end
						local copy = texture:Clone()
						copy.Name = "SurfaceAppearance"
						copy.Parent = part
						local transparency = copy:GetAttribute("Transparency")
						if transparency and part:IsA("BasePart") and part.Transparency ~= 1 then part.Transparency = transparency end
					end)
				end
				local material = key and materials and materials:FindFirstChild(key)
				if material and part:IsA("BasePart") then
					pcall(function()
						for _, old in part:GetChildren() do
							if old:IsA("SurfaceAppearance") then old:Destroy() end
						end
						local color = material:GetAttribute("Color")
						local transparency = material:GetAttribute("Transparency")
						local material_name = material:GetAttribute("Name")
						if color then part.Color = color end
						if transparency then part.Transparency = transparency end
						if material_name and Enum.Material[material_name] then part.Material = Enum.Material[material_name] end
					end)
				end
			end
		end

do
	local skin_weapons_sec = ui.sections.skins_browser
	local skin_list_sec = ui.sections.skins_actions
	local function skins_folder()
		return game:GetService("ReplicatedStorage"):FindFirstChild("Skins")
	end
	local function items_list()
		return game:GetService("ReplicatedStorage"):FindFirstChild("ItemsList")
	end
	local function items_models()
		return game:GetService("ReplicatedStorage"):FindFirstChild("ItemsListModels")
	end
	local function skin_item_names()
		local f = skins_folder()
		local out = {}
		if f then
			for _, i in f:GetChildren() do out[#out + 1] = i.Name end
		end
		table.sort(out)
		return out
	end
	local function item_icon(name)
		local list = items_list()
		if not list then return "" end
		local function icon_of(entry)
			if not entry then return nil end
			local props = entry:FindFirstChild("ItemProperties")
			if props then
				local attr = props:GetAttribute("ItemIcon") or props:GetAttribute("Icon")
				if type(attr) == "string" and attr:find("://", 1, true) then return attr end
				local icon = props:FindFirstChild("ItemIcon")
				if icon and icon.Image ~= "" then return icon.Image end
			end
			local deep = entry:FindFirstChild("ItemIcon", true)
			if deep and deep:IsA("ImageLabel") and deep.Image ~= "" then return deep.Image end
			return nil
		end
		local direct = list:FindFirstChild(name)
		local img = icon_of(direct)
		if img then return img end
		local f = skins_folder()
		local folder = f and f:FindFirstChild(name)
		if folder then
			for _, skn in folder:GetChildren() do
				local attr = skn:GetAttribute("ItemIcon")
				if type(attr) == "string" and attr:find("://", 1, true) then return attr end
				local sic = skn:FindFirstChild("ItemIcon", true)
				if sic and sic:IsA("ImageLabel") and sic.Image ~= "" then return sic.Image end
			end
		end
		local base = tostring(name):gsub("_unlocked$", ""):gsub("_T%d+$", "")
		if base ~= name then
			img = icon_of(list:FindFirstChild(base))
			if img then return img end
		end
		for _, entry in list:GetChildren() do
			if entry.Name == base or string.find(entry.Name, base, 1, true) or string.find(base, entry.Name, 1, true) then
				img = icon_of(entry)
				if img then return img end
			end
		end
		return ""
	end
	local function skin_icon(item, skin)
		local f = skins_folder()
		local folder = f and f:FindFirstChild(item)
		local skn = folder and folder:FindFirstChild(skin)
		if skn then
			local attr = skn:GetAttribute("ItemIcon")
			if type(attr) == "string" and attr:find("://", 1, true) then return attr end
			local icon = skn:FindFirstChild("ItemIcon", true)
			if icon and icon:IsA("ImageLabel") and icon.Image ~= "" then return icon.Image end
		end
		return item_icon(item)
	end
	local function skin_names_of(item, filter)
		local f = skins_folder()
		local folder = f and f:FindFirstChild(item)
		local out = {}
		if folder then
			for _, s in folder:GetChildren() do
				if not filter or filter == "" or string.find(string.lower(s.Name), string.lower(filter), 1, true) then
					out[#out + 1] = s.Name
				end
			end
		end
		table.sort(out)
		if #out == 0 then out = {"Default"} end
		return out
	end
	local skin_choices = {}
	local skin_item, skin_name, skin_filter = nil, "Default", ""
	local skin_auto = true
	local skin_last_model = nil
	local function skin_key_of(obj)
		if typeof(obj) ~= "Instance" or not obj:IsA("ObjectValue") then return nil end
		local ref = obj.Value
		if not ref then return nil end
		local props = ref:FindFirstChild("ItemProperties")
		local special = props and props:GetAttribute("SpecialSkinItem")
		if type(special) == "string" and special ~= "" then return special end
		return ref.Name
	end
	local function skin_owned(item)
		local out = {}
		local seen = {}
		local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local data = folder and folder:FindFirstChild(LocalPlayer.Name)
		if not data then return out end
		local valid = {[item] = true}
		local f = skins_folder()
		local skins = f and f:FindFirstChild(item)
		if skins then
			for _, s in skins:GetChildren() do
				local ms = s:GetAttribute("ModelSkin")
				if type(ms) == "string" and ms ~= "" then valid[ms] = true end
			end
		end
		local function scan(root)
			if not root then return end
			for _, v in root:GetChildren() do
				if not seen[v] and v:IsA("ObjectValue") then
					if valid[v.Name] or valid[skin_key_of(v) or ""] then
						seen[v] = true
						out[#out + 1] = v
					end
				end
				local inner = v:FindFirstChild("Inventory")
				if inner then scan(inner) end
			end
		end
		scan(data:FindFirstChild("Inventory"))
		scan(data:FindFirstChild("Hotbar"))
		return out
	end
	local function skin_stamp(obj, item, skin)
		local list = items_list()
		local f = skins_folder()
		local sk = f and f:FindFirstChild(item)
		local skn = sk and sk:FindFirstChild(skin)
		local model_skin = skn and skn:GetAttribute("ModelSkin")
		local target = (type(model_skin) == "string" and model_skin ~= "" and model_skin) or nil
		if not target and list and list:FindFirstChild(item) then target = item end
		if obj:GetAttribute("Skin") == skin and (not target or obj.Name == target) then return false end
		if target and obj.Name ~= target then
			obj.Name = target
			local ref = list and list:FindFirstChild(target)
			if ref then obj.Value = ref end
		end
		obj:SetAttribute("Skin", skin)
		return true
	end
	local function skin_apply(item, skin)
		local n = 0
		for _, obj in skin_owned(item) do
			if skin_stamp(obj, item, skin) then n += 1 end
		end
		local vm = Camera and _FindFirstChildOfClass(Camera, "Model")
		if vm then cheat.dressSkin(vm, item, skin) end
		local char = LocalPlayer.Character
		local tool = char and _FindFirstChildOfClass(char, "Tool")
		if tool then cheat.dressSkin(tool, item, skin) end
		return n
	end
	local function skin_serialize()
		local out = {}
		for item, skin in skin_choices do
			out[#out + 1] = item .. "/" .. skin
		end
		table.sort(out)
		return table.concat(out, ";")
	end
	Library.Flags["skins_saves"] = Library.Flags["skins_saves"] or ""
	Library.ConfigFlags["skins_saves"] = function(v)
		if type(v) ~= "string" or v == "" then return end
		local n = 0
		for chunk in v:gmatch("[^;]+") do
			local item, skin = chunk:match("^%s*([^/]+)/([^/]+)%s*$")
			if item and skin then
				skin_choices[item] = skin
				n += skin_apply(item, skin)
			end
		end
		Library.Flags["skins_saves"] = v
		Library.Notification("Skins loaded (" .. n .. " applied)", 3)
	end
	local function make_grid(parent)
		local f = Instance.new("Frame")
		f.Name = "IconGrid"
		f.BackgroundTransparency = 1
		f.BorderSizePixel = 0
		f.Size = UDim2.new(1, 0, 0, 0)
		f.AutomaticSize = Enum.AutomaticSize.Y
		f.Parent = parent
		local layout = Instance.new("UIGridLayout")
		layout.CellSize = UDim2.fromOffset(52, 52)
		layout.CellPadding = UDim2.fromOffset(4, 4)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = f
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 10)
		pad.Parent = f
		return f
	end
	local function grid_cell(grid, image, caption, order)
		local b = Instance.new("ImageButton")
		b.Name = caption
		b.LayoutOrder = order or 0
		b.BackgroundColor3 = Color3.fromRGB(24, 17, 33)
		b.BorderSizePixel = 0
		b.Image = image or ""
		b.ScaleType = Enum.ScaleType.Fit
		b.Parent = grid
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = Color3.fromRGB(70, 70, 70)
		stroke.Parent = b
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.AnchorPoint = Vector2.new(0, 1)
		label.Position = UDim2.new(0, 0, 1, 0)
		label.Size = UDim2.new(1, 0, 0, 14)
		label.Font = Enum.Font.Gotham
		label.TextSize = 9
		label.TextColor3 = Color3.fromRGB(220, 220, 220)
		label.TextStrokeTransparency = 0.5
		label.TextTruncate = Enum.TextTruncate.AtEnd
		label.Text = caption
		label.Parent = b
		return b, stroke
	end
	local skin_weapon_grid = make_grid(skin_weapons_sec.holder)
	local skin_grid = make_grid(skin_list_sec.holder)
	local skin_weapon_buttons, skin_buttons = {}, {}
	local function skin_select_weapon(item)
		skin_item = item
		for name, pair in skin_weapon_buttons do
			pair[2].Color = (name == item) and Library.Theme.accent or Color3.fromRGB(70, 70, 70)
		end
		for _, c in skin_grid:GetChildren() do
			if c:IsA("ImageButton") then c:Destroy() end
		end
		table.clear(skin_buttons)
		local names = skin_names_of(item, "")
		skin_name = names[1]
		for idx, name in names do
			local b, stroke = grid_cell(skin_grid, skin_icon(item, name), name, idx)
			skin_buttons[name] = {b, stroke}
			b.MouseButton1Click:Connect(function()
				skin_name = name
				for n2, pair in skin_buttons do
					pair[2].Color = (n2 == name) and Library.Theme.accent or Color3.fromRGB(70, 70, 70)
				end
			end)
		end
		local first = skin_buttons[skin_name]
		if first then first[2].Color = Library.Theme.accent end
	end
	local function skin_rebuild_weapons()
		for _, c in skin_weapon_grid:GetChildren() do
			if c:IsA("ImageButton") then c:Destroy() end
		end
		table.clear(skin_weapon_buttons)
		local items = skin_item_names()
		local idx = 0
		for _, item in items do
			if skin_filter == "" or string.find(string.lower(item), string.lower(skin_filter), 1, true) then
				idx += 1
				local b, stroke = grid_cell(skin_weapon_grid, item_icon(item), item, idx)
				skin_weapon_buttons[item] = {b, stroke}
				b.MouseButton1Click:Connect(function()
					skin_select_weapon(item)
				end)
			end
		end
		if skin_item and not skin_weapon_buttons[skin_item] then skin_item = nil end
	end
	skin_list_sec:Textbox({Name = "Search", Value = "", Flag = "skins_search", Callback = function()
		skin_filter = Library.Flags["skins_search"] or ""
		skin_rebuild_weapons()
		if skin_item and skin_weapon_buttons[skin_item] then skin_select_weapon(skin_item) end
	end})
	skin_list_sec:Button({Name = "Apply skin", Callback = function()
		if not skin_item or not skin_name then
			Library.Notification("Pick a weapon and a skin", 2.5)
			return
		end
		skin_choices[skin_item] = skin_name
		local n = skin_apply(skin_item, skin_name)
		Library.Flags["skins_saves"] = skin_serialize()
		Library.Notification("Skin set on " .. n .. " item(s): " .. skin_item, 3)
	end})
	skin_list_sec:Button({Name = "Remove skin", Callback = function()
		if not skin_item then
			Library.Notification("Pick a weapon first", 2.5)
			return
		end
		skin_choices[skin_item] = nil
		local n = skin_apply(skin_item, "Default")
		Library.Flags["skins_saves"] = skin_serialize()
		Library.Notification("Skin cleared on " .. n .. " item(s)", 3)
	end})
	skin_rebuild_weapons()
	local skin_vm_tick = 0
	cheat.utility.new_heartbeat(function()
		if not skin_auto then return end
		-- FPS fix 2026-11-03: poll the viewmodel at 10Hz instead of every frame
		local nowvm = os.clock()
		if nowvm - skin_vm_tick < 0.1 then return end
		skin_vm_tick = nowvm
		local vm = Camera and _FindFirstChildOfClass(Camera, "Model")
		if vm and vm ~= skin_last_model then
			skin_last_model = vm
			local it = _FindFirstChild(vm, "Item")
			local name = (it and skin_choices[it.Name] and it.Name) or (skin_choices[vm.Name] and vm.Name)
			if name then cheat.dressSkin(vm, name, skin_choices[name]) end
		end
	end)
	local skin_attr_tick = 0
	cheat.utility.new_heartbeat(function()
		if not skin_auto or os.clock() - skin_attr_tick < 2 then return end
		skin_attr_tick = os.clock()
		for item, skin in skin_choices do
			local owned = skin_owned(item)
			if #owned > 0 then
				local need = false
				for _, obj in owned do
					if obj:GetAttribute("Skin") ~= skin then need = true break end
				end
				if need then skin_apply(item, skin) end
			end
		end
	end)

	-- ==================== Weapon Editor (เอามาจาก swim hub ตามที่ผู้ใช้ขอ) ====================
	local mods_sec = ui.sections.weapon_mods
	local guns_sec = ui.sections.weapon_list
	print("[Miko Hub] Weapon Editor loaded - Skins tab > Weapon Editor")
	local attach_defaults = {
		AKMN = {Stock = "StockAKMN", Front = "FrontAKMN", Handle = "HandleAKMN", Magazine = "762x39MAG"},
		AKM = {Stock = "ImprStockAKM", Handle = "ImprHandleAKM", Magazine = "762x39ImprMAG"},
		SKS = {Stock = "StockSKS", Front = "FrontSKS"},
		M4 = {Stock = "StockM4", Front = "FrontM4", Handle = "HandleM4", Magazine = "Mag556"},
		ADAR15 = {Stock = "StockADAR", Front = "FrontADAR", Magazine = "Mag556"},
		FAL = {Stock = "StockFAL", Front = "FrontFAL", Handle = "HandleFAL"},
		AsVal = {Stock = "StockAsVal", Front = "FrontAsVal", Handle = "HandleAsVal", Magazine = "9x39Mag"},
		SOCOM556 = {Magazine = "Mag556"},
		SVD = {Stock = "StockSVD", Front = "FrontSVD", Magazine = "762x54Rnd10Mag"},
		Mosin = {Stock = "DefaultStockMosin", Front = "DefaultFrontMosin"},
		R700 = {Front = "FrontTimberwolf", Magazine = "MagR700"},
		TFZ98S = {Magazine = "MagTFZ98"},
		PPSH41 = {Stock = "StockPPSH41", Magazine = "762x25Rnd71Mag"},
		VZ61 = {Magazine = "9x18vzMag"},
		Saiga12 = {Front = "FrontSaiga", Magazine = "SaigaMag5rnd"},
		IZh81 = {Stock = "StockIZh81", Front = "FrontIZh81"},
		IZh12 = {Stock = "StockIZh12", Front = "FrontIZh12"},
		TOZ106 = {Magazine = "MagTOZ106"},
		Makarov = {Magazine = "9x18MakarovMAG"},
		GoldenMakarov = {Magazine = "9x18MakarovMAG"},
		MP443 = {Magazine = "9x19MP443MAG"},
		TT33 = {Magazine = "762x25TTMAG"},
		MK23 = {Magazine = "MK23ExtMag"}
	}
	local wep_edits = ""
	local wep_auto, wep_unlock = true, false
	local wep_weapon, wep_slot, wep_att = nil, nil, nil
	local wep_slot_dd, wep_att_dd
	local function wep_display(name)
		local list = items_list()
		local it = list and list:FindFirstChild(name)
		local props = it and it:FindFirstChild("ItemProperties")
		local disp = props and props:GetAttribute("Name")
		if type(disp) == "string" and disp ~= "" then return disp end
		return tostring(name)
	end
	local function wep_is_gun(name)
		local list = items_list()
		local it = list and list:FindFirstChild(name)
		local props = it and it:FindFirstChild("ItemProperties")
		if not props then return true end
		local t = props:GetAttribute("ItemType")
		if type(t) ~= "string" or t == "" then return true end
		return t == "RangedWeapon"
	end
	local function wep_gun_names()
		local models = items_models()
		local out = {}
		if models then
			for _, m in models:GetChildren() do
				if m:FindFirstChild("AttachmentPoints") and wep_is_gun(m.Name) then
					out[#out + 1] = m.Name
				end
			end
		end
		table.sort(out)
		return out
	end
	local function wep_slots(weapon)
		local models = items_models()
		local out = {}
		local seen = {}
		local m = models and models:FindFirstChild(weapon)
		local ap = m and m:FindFirstChild("AttachmentPoints")
		if ap then
			for _, s in ap:GetChildren() do
				if s.Name ~= "Magazine" and not seen[s.Name] then
					seen[s.Name] = true
					out[#out + 1] = s.Name
				end
			end
		end
		if wep_unlock then
			for _, s in {"Front", "Handle", "Stock", "Grip"} do
				if not seen[s] then
					seen[s] = true
					out[#out + 1] = s
				end
			end
		end
		table.sort(out)
		return out
	end
	local function wep_compat()
		local list = items_list()
		local map = {}
		if list then
			for _, it in list:GetChildren() do
				local props = it:FindFirstChild("ItemProperties")
				local cp = props and props:FindFirstChild("CompatibleParts")
				if cp then
					local ok, attrs = pcall(function() return cp:GetAttributes() end)
					if ok and type(attrs) == "table" then
						for att, slot in attrs do
							if type(slot) == "string" and slot ~= "" and list:FindFirstChild(att) then
								map[slot] = map[slot] or {}
								map[slot][att] = true
							end
						end
					end
				end
			end
		end
		return map
	end
	local wep_compat_cache = nil
	local function wep_options(weapon, slot)
		if not wep_compat_cache then wep_compat_cache = wep_compat() end
		local set = {}
		if wep_compat_cache[slot] then
			for att in wep_compat_cache[slot] do set[att] = true end
		end
		local def = attach_defaults[weapon] and attach_defaults[weapon][slot]
		if def then set[def] = true end
		local guess = items_list() and items_list():FindFirstChild(slot .. weapon)
		if guess then set[slot .. weapon] = true end
		local out = {}
		for att in set do out[#out + 1] = att end
		table.sort(out)
		return out
	end
	local function wep_owned(name)
		local out = {}
		local seen = {}
		local folder = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
		local data = folder and folder:FindFirstChild(LocalPlayer.Name)
		if not data then return out end
		local function scan(root)
			if not root then return end
			for _, v in root:GetChildren() do
				if not seen[v] and v:FindFirstChild("Attachments") then
					if name == nil or v.Name == name then
						seen[v] = true
						out[#out + 1] = v
					end
				end
				local inner = v:FindFirstChild("Inventory")
				if inner then scan(inner) end
			end
		end
		scan(data:FindFirstChild("Inventory"))
		scan(data:FindFirstChild("Hotbar"))
		return out
	end
	local function wep_current(gun, slot)
		local atts = gun:FindFirstChild("Attachments")
		if not atts then return nil end
		for _, a in atts:GetChildren() do
			if a:GetAttribute("Slot") == slot then return a.Name end
		end
		return nil
	end
	local function wep_default(weapon, slot)
		local d = attach_defaults[weapon] and attach_defaults[weapon][slot]
		if d then return d end
		local guess = slot .. weapon
		if items_list() and items_list():FindFirstChild(guess) then return guess end
		return nil
	end
	local function wep_parse(str)
		local map = {}
		for chunk in tostring(str or ""):gmatch("[^;]+") do
			local w, s, a = chunk:match("^%s*([^/]+)/([^/]+)/([^/]+)%s*$")
			if w and s and a then
				map[w] = map[w] or {}
				map[w][s] = a
			end
		end
		return map
	end
	local function wep_serialize(map)
		local out = {}
		for w, slots in map do
			for s, a in slots do out[#out + 1] = w .. "/" .. s .. "/" .. a end
		end
		return table.concat(out, ";")
	end
	local function wep_stamp(gun, slot, att)
		local atts = gun:FindFirstChild("Attachments")
		if not atts then return end
		local cur = nil
		for _, a in atts:GetChildren() do
			if a:GetAttribute("Slot") == slot then cur = a break end
		end
		-- FPS fix 2026-11-03: skip re-stamp when already correct (stops instance churn every second)
		if cur and cur.Name == att then
			local list0 = items_list()
			local ref0 = list0 and list0:FindFirstChild(att)
			if cur.Value == ref0 and atts:GetAttribute(slot) == att then return end
		end
		if not cur then
			cur = Instance.new("ObjectValue")
			cur.Parent = atts
		end
		pcall(function()
			cur.Name = att
			local list = items_list()
			cur.Value = list and list:FindFirstChild(att)
			cur:SetAttribute("Slot", slot)
			atts:SetAttribute(slot, att)
		end)
	end
	local function wep_apply_all()
		local map = wep_parse(wep_edits)
		if not next(map) then return 0 end
		local n = 0
		for _, gun in wep_owned(nil) do
			local slots = map[gun.Name]
			if slots then
				for slot, att in slots do
					if att == "-" then
						local atts = gun:FindFirstChild("Attachments")
						local cur = atts and (function()
							for _, a in atts:GetChildren() do
								if a:GetAttribute("Slot") == slot then return a end
							end
						end)()
						if cur then pcall(function() cur:Destroy() end) n += 1 end
					else
						wep_stamp(gun, slot, att)
						n += 1
					end
				end
			end
		end
		return n
	end
	local function wep_status()
		if not wep_weapon or not wep_slot then return "pick a weapon and slot" end
		local map = wep_parse(wep_edits)
		local edited = map[wep_weapon] and map[wep_weapon][wep_slot]
		if edited then return "edited: " .. edited end
		local gun = wep_owned(wep_weapon)[1]
		local fitted = gun and wep_current(gun, wep_slot)
		if fitted then return "fitted: " .. fitted end
		local def = wep_default(wep_weapon, wep_slot)
		if def then return "default: " .. def end
		return "empty"
	end
	local wep_refresh_slots, wep_refresh_atts
	local gun_grid = make_grid(guns_sec.holder)
	local att_grid = make_grid(mods_sec.holder)
	local gun_buttons, att_buttons = {}, {}
	wep_refresh_slots = function()
		local slots = wep_weapon and wep_slots(wep_weapon) or {}
		wep_slot = slots[1]
		if wep_slot_dd then
			wep_slot_dd.Refresh(slots)
			if wep_slot then wep_slot_dd.Set(wep_slot, true) end
		end
		wep_refresh_atts()
	end
	wep_refresh_atts = function()
		if not att_grid then return end
		for _, c in att_grid:GetChildren() do
			if c:IsA("ImageButton") then c:Destroy() end
		end
		table.clear(att_buttons)
		wep_att = "Empty"
		if not (wep_weapon and wep_slot) then return end
		local opts = wep_options(wep_weapon, wep_slot)
		local vals = {"Empty"}
		for _, o in opts do vals[#vals + 1] = o end
		for idx, name in vals do
			local b, stroke = grid_cell(att_grid, name == "Empty" and "" or item_icon(name), name, idx)
			att_buttons[name] = {b, stroke}
			b.MouseButton1Click:Connect(function()
				wep_att = name
				for n2, pair in att_buttons do
					pair[2].Color = (n2 == name) and Library.Theme.accent or Color3.fromRGB(70, 70, 70)
				end
			end)
		end
		local first = att_buttons["Empty"]
		if first then first[2].Color = Library.Theme.accent end
	end
	local function wep_select_gun(name)
		wep_weapon = name
		wep_compat_cache = nil
		for n2, pair in gun_buttons do
			pair[2].Color = (n2 == name) and Library.Theme.accent or Color3.fromRGB(70, 70, 70)
		end
		wep_refresh_slots()
	end
	do
		local guns = wep_gun_names()
		for idx, name in guns do
			local b, stroke = grid_cell(gun_grid, item_icon(name), name, idx)
			gun_buttons[name] = {b, stroke}
			b.MouseButton1Click:Connect(function()
				wep_select_gun(name)
			end)
		end
	end
	wep_slot_dd = mods_sec:Dropdown({Name = "Slot", Values = {}, Value = nil, Flag = "wep_slot", Multi = false, Callback = function(value)
		wep_slot = value
		wep_refresh_atts()
	end})
	mods_sec:Button({Name = "Apply attachment", Callback = function()
		if not wep_weapon or not wep_slot then
			Library.Notification("Pick a weapon and slot", 2.5)
			return
		end
		local map = wep_parse(wep_edits)
		map[wep_weapon] = map[wep_weapon] or {}
		if not wep_att or wep_att == "Empty" then
			map[wep_weapon][wep_slot] = "-"
		else
			map[wep_weapon][wep_slot] = wep_att
		end
		if not next(map[wep_weapon]) then map[wep_weapon] = nil end
		wep_edits = wep_serialize(map)
		Library.Flags["weapon_edits"] = wep_edits
		local n = wep_apply_all()
		Library.Notification("Edits: " .. wep_status() .. " (" .. n .. " stamped)", 3)
	end})
	mods_sec:Button({Name = "Clear slot", Callback = function()
		if not wep_weapon or not wep_slot then
			Library.Notification("Pick a weapon and slot", 2.5)
			return
		end
		local map = wep_parse(wep_edits)
		map[wep_weapon] = map[wep_weapon] or {}
		map[wep_weapon][wep_slot] = "-"
		if not next(map[wep_weapon]) then map[wep_weapon] = nil end
		wep_edits = wep_serialize(map)
		Library.Flags["weapon_edits"] = wep_edits
		local n = wep_apply_all()
		Library.Notification("Slot cleared (" .. n .. " removed)", 3)
	end})
	Library.Flags["weapon_edits"] = Library.Flags["weapon_edits"] or ""
	Library.ConfigFlags["weapon_edits"] = function(v)
		wep_edits = tostring(v or "")
		Library.Flags["weapon_edits"] = wep_edits
		local n = wep_apply_all()
		Library.Notification("Weapon edits loaded (" .. n .. " stamped)", 3)
	end
	local wep_auto_tick = 0
	cheat.utility.new_heartbeat(function()
		if wep_auto and wep_edits ~= "" and os.clock() - wep_auto_tick > 1 then
			wep_auto_tick = os.clock()
			wep_apply_all()
		end
	end)
end

do
local Config = ui.sections.settings_config
				local _, Files = Utility.GetFiles(ConfigFolder, { ".cfg" })
				local LastFiles = Files
				local ConfigName;
				local ConfigList = Config:List({
					Values = Files,
					Value = Files[1] or "",
					Size = 135,
					Name = "",
					Flag = "settings_config_list",
					Search = true,
					Callback = function(v)
						if ConfigName and v then
							ConfigName.Set(v)
						end
					end
				})

				ConfigName = Config:Textbox({
					Name = "Name",
					Value = "",
					Flag = "settings_config_name"
				})

				Config:Button({
					Name = "Save",
					Confirm = true,
					Callback = function()
						local ConfigName = Library.Flags["settings_config_name"]

						if ConfigName and ConfigName ~= "" then
							local ConfigFilePath = string.format("%s%s.cfg", ConfigFolder, ConfigName)

							if isfile(ConfigFilePath) then
								writefile(ConfigFilePath, Library:GetConfig())

								Library.Notification(
									string.format( "Successfully saved config (%s.cfg).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
								)

								local _, Files = Utility.GetFiles(ConfigFolder, { ".cfg" })

								ConfigList.Refresh(Files)

								ConfigList.Set(ConfigName)
							else
								writefile(ConfigFilePath, Library:GetConfig())

								Library.Notification(
									string.format( "Successfully created config (%s.cfg).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
								)

								local _, Files = Utility.GetFiles(ConfigFolder, { ".cfg" })

								ConfigList.Refresh(Files)

								ConfigList.Set(ConfigName)
							end
						else
							Library.Notification(
								string.format( "Invalid config name (%s).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
							)
						end
					end,
				})

				Config:Button({
					Name = "Load",
					Confirm = true,
					Callback = function()
						local ConfigName = Library.Flags["settings_config_list"]

						if ConfigName and ConfigName ~= "" then
							local ConfigFilePath = string.format("%s%s.cfg", ConfigFolder, ConfigName)

							if isfile(ConfigFilePath) then
								Library.LoadConfig(readfile(ConfigFilePath))

								Library.Notification(
									string.format( "Successfully loaded config (%s.cfg).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
								)
							else
								Library.Notification(
									string.format( "Couldn't find config (%s.cfg).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
								)
							end
						end
					end,
				})

				Config:Button({
					Name = "Delete",
					Confirm = true,
					Callback = function()
						local ConfigName = Library.Flags["settings_config_list"]

						if ConfigName and ConfigName ~= "" then
							local ConfigFilePath = string.format("%s%s.cfg", ConfigFolder, ConfigName)

							if isfile(ConfigFilePath) then
								delfile(ConfigFilePath)

								Library.Notification(
									string.format( "Successfully deleted config (%s.cfg).", Utility.RichText( ConfigName, Library.Theme.accent ) ), 5
								)

								local _, Files = Utility.GetFiles(ConfigFolder, { ".cfg" })

								ConfigList.Refresh(Files)

								ConfigList.Set(Files[1] or "")
							end
						end
					end,
				})

	task.spawn(function()
		while task.wait(5) do
			if cheat.utility.cleanup.dead then break end -- FPS fix 2026-11-03
			if ui.window.Visible then
				local _, Files = Utility.GetFiles(ConfigFolder, { ".cfg" })

							if #Files ~= #LastFiles then
								LastFiles = Files

								ConfigList.Refresh(Files)

								ConfigList.Set(Files[1] or "")
							end
						end
					end
				end)

end

do
local gunsec = ui.sections.misc
local ranged
for _, v in getgc(true) do
 if type(v) == "table" then
  if rawget(v, "springs") and rawget(v, "characterAnimations") then project_delta.fps_object = v end
  if type(rawget(v, "RangedWeaponDefault")) == "function" and type(rawget(v, "MeleeWeaponDefault")) == "function" then ranged = v end
 end
end
if ranged then
 pcall(function() project_delta.remove_bullet = debug.getupvalue(ranged.RangedWeaponDefault, 4) end)
end
		do
			local auto_reload, auto_refill = false

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

				gunsec:Toggle({Name = "Auto reload", Value = false, Flag = "gunmods_auto_reload", Callback = function(bool)
					auto_reload = bool
				end})



			end
		end

end

do
local mscsec = ui.sections.misc
		local boss_toggle = mscsec:Toggle({Name = "Boss tracker", Value = false, Flag = "boss_tracker", Callback = function(bool)
			cheat.boss_tracker = bool
		end})
		cheat.boss_notify = false
		mscsec:Toggle({Name = "Boss spawn notify", Value = false, Flag = "boss_notify", Callback = function(bool)
			cheat.boss_notify = bool
		end})
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
			local boss_gui = Instance.new("ScreenGui")
			boss_gui.Name = "SwimBossTracker"
			boss_gui.ResetOnSpawn = false
			boss_gui.IgnoreGuiInset = true
			boss_gui.DisplayOrder = -1
			boss_gui.Enabled = false
			boss_gui.Parent = game:GetService("CoreGui")
			cheat.utility.on_unload(function() pcall(function() boss_gui:Destroy() end) end) -- FPS fix 2026-11-03
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
				cheat.utility.track(UserInputService.InputChanged:Connect(function(input)
					if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
						local vs = Camera.ViewportSize
						boss_outer.Position = UDim2.new(0, math.clamp(ox + input.Position.X - mx, 0, math.max(vs.X - boss_outer.AbsoluteSize.X, 0)), 0, math.clamp(oy + input.Position.Y - my, 0, math.max(vs.Y - boss_outer.AbsoluteSize.Y, 0)))
					end
				end))
				cheat.utility.track(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
				end))
			end
			local boss_stroke = Instance.new("UIStroke")
			boss_stroke.Thickness = 1
			boss_stroke.Color = Library.Theme.accent
			boss_stroke.Parent = boss_outer
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
				boss_gui.Enabled = not not cheat.boss_tracker
				if not cheat.boss_tracker and not cheat.boss_notify then
					table.clear(boss_seen)
					return
				end
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
							-- FPS fix 2026-11-03: only descend into Models/Folders (was a GetChildren() alloc on every node)
							if model:IsA("Model") or model:IsA("Folder") then
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

end

do
local movebox = ui.sections.movement
	local speedhack, speedhack_speed = false, 18.2
	local speedhack_autospeed, speedhack_autospeed_offset = false, 3.5
	local flyhack, flyhack_key, flyhack_speed, flyhack_speed_y = false, false, 100, 100

local spiderman, spiderman_key = false, false
	do
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
		local old_nofall_pos, should_no_fall = nil, false
























	task.spawn(function()
		-- FPS fix 2026-11-03: check toggle first (was scanning the character every Heartbeat even when off)
		while RunService.Heartbeat:Wait() do
			if cheat.utility.cleanup.dead then break end
			if not nofall then
				should_no_fall = false
				continue
			end
			local character = LocalPlayer.Character
			if not character then
				continue
			end

			local hrp = _FindFirstChild(character, "HumanoidRootPart")
			local hum = _FindFirstChildOfClass(character, "Humanoid")
			if not (hrp and hum) then
				continue
			end

			if not table.find(falling_states, hum:GetState()) then
				should_no_fall = false
				continue
			end

			hum:ChangeState(Enum.HumanoidStateType.Running)
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
			state_connection = cheat.utility.track(hum.StateChanged:Connect(state_changed))
		end
		cheat.utility.track(LocalPlayer.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			hum = humanoid
			if state_connection then state_connection:Disconnect() end
			state_connection = cheat.utility.track(humanoid.StateChanged:Connect(state_changed))
		end))
	end
		local speed_toggle = movebox:Toggle({Name = "Speedhack", Value = false, Flag = "speedhack", Callback = function(bool)
			speedhack = bool
		end})
		movebox:Toggle({Name = "Speedhack auto speed", Value = false, Flag = "speedhack_autospeed", Callback = function(bool)
			speedhack_autospeed = bool
		end})
		movebox:Slider({Name = "Speedhack speed", Min = 1, Max = 18.1, Float = 0.1, Value = 18.2, Flag = "speedhack_speed", Callback = function(int)
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
		movebox:Slider({Name = "Flyhack speed Y", Min = 0, Max = 50, Float = 1, Value = 25, Flag = "flyhack_speed_y", Callback = function(int)
			flyhack_speed_y = int
		end})

		local nc_kinds_dropdown, nc_layers_slider, nc_speed_slider = nil, nil, nil
		local nc_toggle = movebox:Toggle({Name = "Noclip", Value = false, Flag = "noclip", Callback = function(bool)
			cheat.nc_state.on = bool
			local vis = bool and true or false
			if nc_kinds_dropdown then nc_kinds_dropdown.State(vis) end
			if nc_layers_slider then nc_layers_slider.State(vis) end
			if nc_speed_slider then nc_speed_slider.State(vis) end
		end})
		local nc_keybind; nc_keybind = nc_toggle:Keybind({Name = "Noclip", Mode = "Toggle", Modes = {"Hold", "Toggle"}, Key = Enum.KeyCode.C, Value = false, Flag = "noclip_key", Link = "noclip", Callback = function(bool)
			cheat.nc_state.key = cheat.nc_state.on and bool
			nc_keybind.Set(cheat.nc_state.key, true)
		end})
		nc_kinds_dropdown = movebox:Dropdown({Name = "Clip through", Values = {"Floors", "Walls"}, Value = {"Floors", "Walls"}, Flag = "noclip_kinds", Multi = true, Callback = function(tbl)
			cheat.nc_state.kinds = (tbl and #tbl > 0) and tbl or {"Floors", "Walls"}
		end})
		nc_kinds_dropdown.State(false)
		nc_layers_slider = movebox:Slider({Name = "Max layers", Min = 1, Max = 4, Float = 1, Value = 1, Flag = "noclip_layers", Callback = function(int)
			cheat.nc_state.layers = math.max(1, math.floor(int))
		end})
		nc_layers_slider.State(false)
		nc_speed_slider = movebox:Slider({Name = "Clip speed", Min = 0.5, Max = 8, Float = 0.5, Value = 1, Flag = "noclip_speed", Callback = function(int)
			cheat.nc_state.speed = int
		end})
		nc_speed_slider.State(false)

		local sp_keybind; sp_keybind = movebox:Toggle({Name = "Spiderman", Value = false, Flag = "spiderman", Callback = function(bool)
			spiderman = bool
		end}):Keybind({Name = "Spiderman", Mode = "Hold", Key = Enum.KeyCode.F, Value = false, Flag = "spiderman_key", Link = "spiderman", Callback = function(bool)
			spiderman_key = spiderman and bool
			sp_keybind.Set(spiderman_key, true)
		end})

local aspd_buffs, aspd_checked = nil, 0
cheat.utility.new_renderstepped(function(delta) -- FPS fix 2026-11-03: tracked connection
 local char = LocalPlayer.Character
 local hrp = char and _FindFirstChild(char, "HumanoidRootPart")
 local hum = char and _FindFirstChildOfClass(char, "Humanoid")
 if not (hrp and hum) then return end
 local calcspeed = speedhack_speed
 if speedhack_autospeed then
  local movement_mod = project_delta.fps_object and project_delta.fps_object.movementModifier or 0
  local total_mod = (hrp:GetAttribute("MovementModifier") or 0) + math.clamp(movement_mod, -10, 0)
  -- FPS fix 2026-11-03: cache Buffs path (was a 6-deep FindFirstChild chain every frame)
  local buffs = aspd_buffs
  if not (buffs and buffs.Parent) and os.clock() - aspd_checked >= 2 then
   aspd_checked = os.clock()
   local players = game:GetService("ReplicatedStorage"):FindFirstChild("Players")
   local data = players and players:FindFirstChild(LocalPlayer.Name)
   local status = data and data:FindFirstChild("Status")
   local vars = status and status:FindFirstChild("GameplayVariables")
   buffs = vars and vars:FindFirstChild("Buffs")
   aspd_buffs = buffs
  end
  if buffs and buffs:GetAttribute("SerumRed") then total_mod = total_mod * 0.5 + 1 end
  calcspeed = 18.2 + total_mod + speedhack_autospeed_offset
 end
 if speedhack then hum.WalkSpeed = calcspeed end
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
			ydir = _IsKeyDown(UserInputService, Enum.KeyCode.Space)	      and ydir + Vector3.yAxis or ydir;
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
			params.FilterDescendantsInstances = {char, workspace.NoCollision}
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

end)
end
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
	cheat.utility.on_unload(function() pcall(function() nc_probe_part:Destroy() end) end) -- FPS fix 2026-11-03
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
	local nc_old_gui = game:GetService("CoreGui"):FindFirstChild("SwimNoclip")
	if nc_old_gui then nc_old_gui:Destroy() end
	local nc_gui = Instance.new("ScreenGui")
	nc_gui.Name = "SwimNoclip"
	nc_gui.ResetOnSpawn = false
	nc_gui.IgnoreGuiInset = true
	nc_gui.DisplayOrder = 10
	nc_gui.Parent = game:GetService("CoreGui")
	cheat.utility.on_unload(function() pcall(function() nc_gui:Destroy() end) end) -- FPS fix 2026-11-03
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
	cheat.utility.track(RunService.Stepped:Connect(function()
		local c = nc_clip
		if not c then return end
		for _, p in c.parts do
			if p.CanCollide then p.CanCollide = false end
		end
	end))
	cheat.utility.track(RunService.Heartbeat:Connect(function(dt)
		local active = cheat.nc_state.on and cheat.nc_state.key
		-- FPS fix 2026-11-03: skip the character scan entirely when noclip is off and idle
		if not active and not nc_clip then
			if nc_label.Visible then nc_label.Visible = false end
			nc_plan = nil
			return
		end
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
	end))
	cheat.utility.track(LocalPlayer.CharacterAdded:Connect(function()
		nc_clip = nil
		nc_plan = nil
		nc_last_part = nil
		cheat.clipActive = false
	end))
end


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
	cheat.utility.track(Players.PlayerRemoving:Connect(function(player)
		mod_group_cache[player] = nil
		if mod_tracked[player] then
			mod_tracked[player] = nil
			if mod_enabled then
				Library.Notification("moderator leave " .. player.Name, 9999)
				mod_play(admin_leave_asset)
			end
		end
	end))
	task.spawn(function()
		while task.wait(2) do
			if cheat.utility.cleanup.dead then break end -- FPS fix 2026-11-03
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
			if cheat.utility.cleanup.dead then break end -- FPS fix 2026-11-03
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
		cheat.utility.track(recent_folder.ChildAdded:Connect(function(child)
			if cheat.report_notifications then
				local name = child.Name:match("(.+)_([^_]+)$")
				if name == LocalPlayer.Name then
					Library.Notification("Added to Recent Reports list!", 7)
				end
			end
		end))
	end

end
