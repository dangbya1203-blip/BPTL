local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ============================================================
-- Cấu hình
-- ============================================================
getgenv().PMT_MAX_STEP_DIST   = getgenv().PMT_MAX_STEP_DIST   or 9000
getgenv().PMT_HOLD_TIME       = getgenv().PMT_HOLD_TIME       or 1.0
getgenv().PMT_HOLD_STEP       = getgenv().PMT_HOLD_STEP       or 0.03
getgenv().PMT_RESPAWN_TIMEOUT = getgenv().PMT_RESPAWN_TIMEOUT or 7
getgenv().PMT_SKIP_IF_NEAR    = getgenv().PMT_SKIP_IF_NEAR    or 800

-- ============================================================
-- Dữ liệu đảo
-- ============================================================
local IslandCF = {
    ["WindMill"]           = CFrame.new(979.799,    16.516,   1429.047),
    ["Marine"]             = CFrame.new(-2566.43,    6.856,   2045.256),
    ["Middle Town"]        = CFrame.new(-690.331,   15.094,   1582.238),
    ["Jungle"]             = CFrame.new(-1612.796,  36.852,    149.128),
    ["Pirate Village"]     = CFrame.new(-1181.309,   4.751,   3803.546),
    ["Desert"]             = CFrame.new(944.158,    20.92,    4373.3),
    ["Snow Island"]        = CFrame.new(1347.807,  104.668,  -1319.737),
    ["MarineFord"]         = CFrame.new(-4914.821,  50.964,   4281.028),
    ["Colosseum"]          = CFrame.new(-1427.62,    7.288,  -2792.772),
    ["Sky Island 1"]       = CFrame.new(-4869.103, 733.461,  -2667.018),
    ["Sky Island 2"]       = CFrame.new(-11.311,    29.277,   2771.522),
    ["Sky Island 3"]       = CFrame.new(-483.734,  332.038,    595.327),
    ["Prison"]             = CFrame.new(4875.33,     5.652,    734.85),
    ["Magma Village"]      = CFrame.new(-5247.716,  12.884,   8504.969),
    ["Under Water Island"] = CFrame.new(61163.852,  11.68,    1819.784),
    ["Fountain City"]      = CFrame.new(5127.128,   59.501,   4105.446),

    ["The Cafe"]           = CFrame.new(-380.479,   77.22,     255.826),
    ["Frist Spot"]         = CFrame.new(-9515.372, 164.006,   5786.061),
    ["Dark Area"]          = CFrame.new(3780.03,    22.652,  -3498.586),
    ["Flamingo Mansion"]   = CFrame.new(-3032.764, 317.897, -10075.373),
    ["Flamingo Room"]      = CFrame.new(2284.414,   15.152,    875.725),
    ["Green Zone"]         = CFrame.new(-2448.53,   73.016,  -3210.631),
    ["Factory"]            = CFrame.new(424.127,   211.162,   -427.54),
    ["Colossuim"]          = CFrame.new(-1503.622, 219.796,   1369.31),
    ["Zombie Island"]      = CFrame.new(-5622.033, 492.196,   -781.786),
    ["Two Snow Mountain"]  = CFrame.new(753.143,   408.236,  -5274.615),
    ["Punk Hazard"]        = CFrame.new(-6127.654,  15.952,  -5040.286),
    ["Cursed Ship"]        = CFrame.new(923.402,   125.057,  32885.875),
    ["Ice Castle"]         = CFrame.new(6148.412,  294.387,  -6741.117),
    ["Forgotten Island"]   = CFrame.new(2681.274,  1682.809, -7190.985),

    ["Sea castle"]         = CFrame.new(-5496.452, 313.809,  -2857.703),
    ["Mini Sky Island"]    = CFrame.new(-288.741, 49326.316,-35248.594),
    ["Great Tree"]         = CFrame.new(2681.274,  1682.809, -7190.985),
    ["Port Town"]          = CFrame.new(-226.751,   20.603,   5538.34),
    ["Hydra Island"]       = CFrame.new(5291.249,  1005.443,   393.762),
    ["Mansion"]            = CFrame.new(-12633.672, 459.521, -7425.463),
    ["Haunted Castle"]     = CFrame.new(-9366.803, 141.366,   5443.941),
    ["Ice Cream Island"]   = CFrame.new(-902.568,   79.932, -10988.848),
    ["Peanut Island"]      = CFrame.new(-2062.748,  50.474, -10232.568),
    ["Cake Island"]        = CFrame.new(-1884.775,  19.328, -11666.897),
    ["Cocoa Island"]       = CFrame.new(87.943,     73.555, -12319.465),
    ["Candy Island"]       = CFrame.new(-1014.424, 149.111, -14555.963),
    ["Tiki Outpost"]       = CFrame.new(-16218.683,  9.086,    445.618),
    ["Dragon Dojo"]        = CFrame.new(5743.319,  1206.91,    936.011),
}

local Alias = {
    ["MiniSky"]   = "Mini Sky Island",
    ["Colosseum"] = "Colosseum",
    ["Colossuim"] = "Colossuim",
}

local WorldIslands = {
    World1 = {"WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert","Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2","Sky Island 3","Prison","Magma Village","Under Water Island","Fountain City"},
    World2 = {"The Cafe","Frist Spot","Dark Area","Flamingo Mansion","Flamingo Room","Green Zone","Factory","Colossuim","Zombie Island","Two Snow Mountain","Punk Hazard","Cursed Ship","Ice Castle","Forgotten Island"},
    World3 = {"Sea castle","Mini Sky Island","Great Tree","Port Town","Hydra Island","Mansion","Haunted Castle","Ice Cream Island","Peanut Island","Cake Island","Cocoa Island","Candy Island","Tiki Outpost","Dragon Dojo"},
}

-- ============================================================
-- Cache
-- ============================================================
local _cachedWorldKey = nil
local _cachedNodes    = nil
local _cachedAdj      = nil

local function getWorldKey()
    if _cachedWorldKey then return _cachedWorldKey end
    if _G.CurrentWorld == 2 then _cachedWorldKey = "World2"
    elseif _G.CurrentWorld == 3 then _cachedWorldKey = "World3"
    else _cachedWorldKey = "World1" end
    return _cachedWorldKey
end

local function getNodes()
    if _cachedNodes then return _cachedNodes end
    local list = WorldIslands[getWorldKey()] or {}
    local nodes = {}
    for _, n in ipairs(list) do
        if IslandCF[n] then nodes[#nodes+1] = n end
    end
    _cachedNodes = nodes
    return nodes
end

local function getAdj()
    if _cachedAdj then return _cachedAdj end
    local nodes   = getNodes()
    local maxStep = getgenv().PMT_MAX_STEP_DIST
    local adj = {}
    for _, a in ipairs(nodes) do adj[a] = {} end
    for i = 1, #nodes do
        local ai = nodes[i]
        local ap = IslandCF[ai].Position
        for j = i+1, #nodes do
            local bj = nodes[j]
            local bp = IslandCF[bj].Position
            local d  = (ap - bp).Magnitude
            if d <= maxStep then
                adj[ai][bj] = d
                adj[bj][ai] = d
            end
        end
    end
    _cachedAdj = adj
    return adj
end

function PMT_ResetCache()
    _cachedWorldKey = nil
    _cachedNodes    = nil
    _cachedAdj      = nil
end

-- ============================================================
-- Helpers
-- ============================================================
local function normName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return Alias[name] or name
end

local function dist(a, b) return (a - b).Magnitude end

local function GetChar()
    local c   = LP.Character or LP.CharacterAdded:Wait()
    local hrp = c:WaitForChild("HumanoidRootPart", 10)
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    return c, hrp, hum
end

local function nearestIsland(pos)
    local nodes = getNodes()
    local best, bestD
    for _, n in ipairs(nodes) do
        local d = dist(pos, IslandCF[n].Position)
        if not bestD or d < bestD then bestD, best = d, n end
    end
    return best
end

local function dijkstra(startName, goalName)
    local nodes = getNodes()
    local adj   = getAdj()
    local distMap, prev, used = {}, {}, {}
    for _, n in ipairs(nodes) do distMap[n] = math.huge end
    distMap[startName] = 0
    while true do
        local u, best = nil, math.huge
        for _, n in ipairs(nodes) do
            if not used[n] and distMap[n] < best then best, u = distMap[n], n end
        end
        if not u or u == goalName then break end
        used[u] = true
        for v, w in pairs(adj[u]) do
            if not used[v] then
                local nd = distMap[u] + w
                if nd < distMap[v] then distMap[v], prev[v] = nd, u end
            end
        end
    end
    if distMap[goalName] == math.huge then return nil end
    local path, cur = {}, goalName
    while cur do table.insert(path, 1, cur); cur = prev[cur] end
    return path
end

-- ============================================================
-- Teleport helpers
-- ============================================================
local _STOP, _RUN = false, false

-- Chỉ set CFrame, KHÔNG die — dùng cho đảo trung gian
local function QuickTP(pos)
    local c, hrp, hum = GetChar()
    if not c then return false end
    local cf = CFrame.new(pos)
    -- Giữ vị trí trong PMT_HOLD_TIME để server accept
    local t0 = os.clock()
    while os.clock() - t0 < getgenv().PMT_HOLD_TIME do
        if _STOP then return false end
        if not (hrp and hrp.Parent and hum and hum.Parent and hum.Health > 0) then return false end
        pcall(function()
            hrp.CFrame = cf
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(getgenv().PMT_HOLD_STEP)
    end
    return true
end

-- Die + respawn — chỉ dùng 1 lần ở đích cuối
local function DieAndRespawn(pos)
    local c, hrp, hum = GetChar()
    if not c then return false end
    local cf = CFrame.new(pos)

    -- Set vị trí đích
    pcall(function()
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)

    -- Giữ ngắn rồi die
    local t0 = os.clock()
    while os.clock() - t0 < getgenv().PMT_HOLD_TIME do
        if _STOP then return false end
        if not (hrp and hrp.Parent and hum and hum.Parent and hum.Health > 0) then break end
        pcall(function()
            hrp.CFrame = cf
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        task.wait(getgenv().PMT_HOLD_STEP)
    end

    if _STOP then return false end
    pcall(function() hum.Health = 0 end)

    -- Đợi respawn
    local t1 = os.clock()
    while os.clock() - t1 < getgenv().PMT_RESPAWN_TIMEOUT do
        if _STOP then return false end
        local nc   = LP.Character
        local nhrp = nc and nc:FindFirstChild("HumanoidRootPart")
        local nhum = nc and nc:FindFirstChildOfClass("Humanoid")
        if nhrp and nhum and nhum.Health > 0 then return true end
        task.wait(0.15)
    end
    return false
end

-- ============================================================
-- Public API
-- ============================================================
function PMT_FastHopTo(targetName)
    targetName = normName(targetName)
    if not (targetName and IslandCF[targetName]) then
        warn("PMT: Đảo không hợp lệ: " .. tostring(targetName))
        return false
    end

    local nodes = getNodes()
    if #nodes == 0 then return false end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        -- Chờ respawn nếu chưa có character
        local t0 = os.clock()
        while os.clock() - t0 < getgenv().PMT_RESPAWN_TIMEOUT do
            hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then break end
            task.wait(0.15)
        end
    end
    if not hrp then return false end

    local startIsland = nearestIsland(hrp.Position)
    local path = dijkstra(startIsland, targetName)
    if not path then
        warn("PMT: Không tìm được đường đến " .. targetName)
        return false
    end

    _RUN, _STOP = true, false
    local total = #path

    for i, name in ipairs(path) do
        if _STOP then break end

        local pos  = IslandCF[name].Position
        local ch   = LP.Character
        local hrp2 = ch and ch:FindFirstChild("HumanoidRootPart")

        -- Bỏ qua nếu đã đủ gần
        if hrp2 and dist(hrp2.Position, pos) <= getgenv().PMT_SKIP_IF_NEAR then
            task.wait(0.05)

        elseif i == total then
            -- ĐÂY LÀ ĐÍCH CUỐI → die + respawn 1 lần duy nhất
            if not DieAndRespawn(pos) then break end

        else
            -- Đảo TRUNG GIAN → thử QuickTP trước
            local ok = QuickTP(pos)
            if _STOP then break end

            -- Kiểm tra thực tế: có đến nơi chưa?
            local c2   = LP.Character
            local hrp3 = c2 and c2:FindFirstChild("HumanoidRootPart")
            local arrived = hrp3 and dist(hrp3.Position, pos) <= getgenv().PMT_SKIP_IF_NEAR

            if not arrived then
                -- Server không accept → fallback die+respawn
                warn("PMT: QuickTP thất bại tại " .. name .. " → fallback DieAndRespawn")
                if not DieAndRespawn(pos) or _STOP then break end
            else
                task.wait(0.05)
            end
        end
    end

    _RUN = false
    return not _STOP
end

function PMT_StopFastHop()  _STOP = true end
function PMT_IsFastHopRunning() return _RUN end

function PMT_IsNearIsland(name, range)
    local cf = IslandCF[name]
    if not cf then return true end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return (hrp.Position - cf.Position).Magnitude <= (range or 2500)
end

function PMT_EnsureIsland(name, range, tries)
    range = range or 3000
    tries = tries or 3
    if PMT_IsNearIsland(name, range) then return true end
    for _ = 1, tries do
        if not (_G.AutoFarm_Bone and _G.Bypass) then
            return PMT_IsNearIsland(name, range)
        end
        PMT_StopFastHop()
        if _G.Bypass then
            pcall(function() PMT_FastHopTo(name) end)
        else
            local cf = IslandCF[name]
            if cf and typeof(_tp) == "function" then
                pcall(function() _tp(cf) end)
            end
        end
        task.wait(0.25)
        if PMT_IsNearIsland(name, range) then return true end
    end
    return PMT_IsNearIsland(name, range)
end

function BuildIslandOptions()
    local list = WorldIslands[getWorldKey()] or {}
    local out, seen = {}, {}
    for _, name in ipairs(list) do
        local r = Alias[name] or name
        if IslandCF[r] and not seen[r] then
            seen[r] = true
            out[#out+1] = r
        end
    end
    table.sort(out)
    return out
end

-- Global loop
task.spawn(function()
    while task.wait(0.25) do
        if _G.Tpfast and not _RUN then
            local target = _G.Islandtp
            if target and target ~= "" then
                _STOP = false
                PMT_FastHopTo(target)
                _G.Tpfast = false
            end
        end
    end
end)
