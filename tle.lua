--[[
    tle.lua — Fast Island Hop Module
    Viết từ đầu, tối ưu hoàn toàn
    
    API:
        PMT_FastHopTo(name)         → di chuyển đến đảo
        PMT_StopFastHop()           → dừng
        PMT_IsFastHopRunning()      → đang chạy?
        PMT_IsNearIsland(name, r)   → đang gần đảo?
        PMT_ResetCache()            → reset cache khi đổi world
        BuildIslandOptions()        → danh sách đảo hiện tại
]]

-- ============================================================
-- Services & config
-- ============================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer

local CFG = {
    MAX_STEP    = 12000,  -- khoảng cách tối đa giữa 2 đảo liền kề trong graph
    HOLD_TIME   = 1.0,    -- giây giữ CFrame mỗi bước
    HOLD_STEP   = 0.03,   -- interval update CFrame khi giữ
    RESPAWN_TO  = 8,      -- timeout chờ respawn
    SKIP_NEAR   = 600,    -- bỏ qua nếu đã đủ gần
    VERIFY_DIST = 1500,   -- threshold để confirm QuickTP thành công
}

-- Override từ ngoài nếu cần
getgenv().PMT_CFG = CFG

-- ============================================================
-- Dữ liệu đảo
-- ============================================================
local CF = CFrame.new

local ISLANDS = {
    -- World 1
    ["WindMill"]           = CF(979.799,    16.516,   1429.047),
    ["Marine"]             = CF(-2566.43,    6.856,   2045.256),
    ["Middle Town"]        = CF(-690.331,   15.094,   1582.238),
    ["Jungle"]             = CF(-1612.796,  36.852,    149.128),
    ["Pirate Village"]     = CF(-1181.309,   4.751,   3803.546),
    ["Desert"]             = CF(944.158,    20.92,    4373.3),
    ["Snow Island"]        = CF(1347.807,  104.668,  -1319.737),
    ["MarineFord"]         = CF(-4914.821,  50.964,   4281.028),
    ["Colosseum"]          = CF(-1427.62,    7.288,  -2792.772),
    ["Sky Island 1"]       = CF(-4869.103, 733.461,  -2667.018),
    ["Sky Island 2"]       = CF(-11.311,    29.277,   2771.522),
    ["Sky Island 3"]       = CF(-483.734,  332.038,    595.327),
    ["Prison"]             = CF(4875.33,     5.652,    734.85),
    ["Magma Village"]      = CF(-5247.716,  12.884,   8504.969),
    ["Under Water Island"] = CF(61163.852,  11.68,    1819.784),
    ["Fountain City"]      = CF(5127.128,   59.501,   4105.446),
    -- World 2
    ["The Cafe"]           = CF(-380.479,   77.22,     255.826),
    ["Frist Spot"]         = CF(-9515.372, 164.006,   5786.061),
    ["Dark Area"]          = CF(3780.03,    22.652,  -3498.586),
    ["Flamingo Mansion"]   = CF(-3032.764, 317.897, -10075.373),
    ["Flamingo Room"]      = CF(2284.414,   15.152,    875.725),
    ["Green Zone"]         = CF(-2448.53,   73.016,  -3210.631),
    ["Factory"]            = CF(424.127,   211.162,   -427.54),
    ["Colossuim"]          = CF(-1503.622, 219.796,   1369.31),
    ["Zombie Island"]      = CF(-5622.033, 492.196,   -781.786),
    ["Two Snow Mountain"]  = CF(753.143,   408.236,  -5274.615),
    ["Punk Hazard"]        = CF(-6127.654,  15.952,  -5040.286),
    ["Cursed Ship"]        = CF(923.402,   125.057,  32885.875),
    ["Ice Castle"]         = CF(6148.412,  294.387,  -6741.117),
    ["Forgotten Island"]   = CF(2681.274,  1682.809, -7190.985),
    -- World 3
    ["Sea castle"]         = CF(-5496.452, 313.809,  -2857.703),
    ["Mini Sky Island"]    = CF(-288.741, 49326.316,-35248.594),
    ["Great Tree"]         = CF(2681.274,  1682.809, -7190.985),
    ["Port Town"]          = CF(-226.751,   20.603,   5538.34),
    ["Hydra Island"]       = CF(5291.249,  1005.443,   393.762),
    ["Mansion"]            = CF(-12633.672, 459.521, -7425.463),
    ["Haunted Castle"]     = CF(-9366.803, 141.366,   5443.941),
    ["Ice Cream Island"]   = CF(-902.568,   79.932, -10988.848),
    ["Peanut Island"]      = CF(-2062.748,  50.474, -10232.568),
    ["Cake Island"]        = CF(-1884.775,  19.328, -11666.897),
    ["Cocoa Island"]       = CF(87.943,     73.555, -12319.465),
    ["Candy Island"]       = CF(-1014.424, 149.111, -14555.963),
    ["Tiki Outpost"]       = CF(-16218.683,  9.086,    445.618),
    ["Dragon Dojo"]        = CF(5743.319,  1206.91,    936.011),
}

local ALIAS = {
    ["MiniSky"]   = "Mini Sky Island",
    ["Colosseum"] = "Colosseum",
    ["Colossuim"] = "Colossuim",
}

-- Đảo cô lập: không có neighbor → DieTP thẳng, bỏ qua Dijkstra
local ISOLATED = {
    ["Under Water Island"] = true,
}

-- Đảo cao hoặc đặc biệt: QuickTP bị server reject → luôn dùng DieTP
local FORCE_DIE = {
    ["Sky Island 1"]    = true,
    ["Sky Island 3"]    = true,
    ["Mini Sky Island"] = true,
    ["Forgotten Island"]= true,
    ["Hydra Island"]    = true,
}

local WORLDS = {
    World1 = {"WindMill","Marine","Middle Town","Jungle","Pirate Village","Desert",
              "Snow Island","MarineFord","Colosseum","Sky Island 1","Sky Island 2",
              "Sky Island 3","Prison","Magma Village","Under Water Island","Fountain City"},
    World2 = {"The Cafe","Frist Spot","Dark Area","Flamingo Mansion","Flamingo Room",
              "Green Zone","Factory","Colossuim","Zombie Island","Two Snow Mountain",
              "Punk Hazard","Cursed Ship","Ice Castle","Forgotten Island"},
    World3 = {"Sea castle","Mini Sky Island","Great Tree","Port Town","Hydra Island",
              "Mansion","Haunted Castle","Ice Cream Island","Peanut Island","Cake Island",
              "Cocoa Island","Candy Island","Tiki Outpost","Dragon Dojo"},
}

-- ============================================================
-- Cache layer — tính 1 lần, dùng mãi
-- ============================================================
local Cache = {}

local function worldKey()
    if Cache.wk then return Cache.wk end
    Cache.wk = (_G.CurrentWorld == 2 and "World2")
            or (_G.CurrentWorld == 3 and "World3")
            or "World1"
    return Cache.wk
end

local function nodes()
    if Cache.nodes then return Cache.nodes end
    local t = {}
    for _, n in ipairs(WORLDS[worldKey()] or {}) do
        if ISLANDS[n] then t[#t+1] = n end
    end
    Cache.nodes = t
    return t
end

-- Pre-build adjacency graph
local function adj()
    if Cache.adj then return Cache.adj end
    local ns  = nodes()
    local max = CFG.MAX_STEP
    local g   = {}
    for _, a in ipairs(ns) do g[a] = {} end
    for i = 1, #ns do
        local ai, ap = ns[i], ISLANDS[ns[i]].Position
        for j = i+1, #ns do
            local bj, bp = ns[j], ISLANDS[ns[j]].Position
            local d = (ap - bp).Magnitude
            if d <= max then
                g[ai][bj] = d
                g[bj][ai] = d
            end
        end
    end
    Cache.adj = g
    return g
end

function PMT_ResetCache()
    Cache = {}
end

-- ============================================================
-- Helpers
-- ============================================================
local function norm(name)
    if type(name) ~= "string" then return nil end
    name = name:match("^%s*(.-)%s*$") -- trim
    return ALIAS[name] or name
end

local function d(a, b) return (a - b).Magnitude end

-- Trả về hrp nếu alive
local function hrp()
    local c = LP.Character
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local m = c:FindFirstChildOfClass("Humanoid")
    if h and m and m.Health > 0 then return h, m end
    return nil
end

-- Đặt CFrame an toàn
local function setCF(h, cf)
    pcall(function()
        h.CFrame = cf
        h.AssemblyLinearVelocity  = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- Đảo gần nhất với vị trí pos
local function nearest(pos)
    local best, bestD
    for _, n in ipairs(nodes()) do
        local dd = d(pos, ISLANDS[n].Position)
        if not bestD or dd < bestD then bestD, best = dd, n end
    end
    return best
end

-- ============================================================
-- Pathfinding — Dijkstra với pre-built graph
-- ============================================================
local function findPath(from, to)
    local ns    = nodes()
    local graph = adj()

    -- Early exit nếu cùng đảo
    if from == to then return {from} end

    local dist, prev, done = {}, {}, {}
    for _, n in ipairs(ns) do dist[n] = math.huge end
    dist[from] = 0

    for _ = 1, #ns do
        -- Tìm node chưa xử lý có dist nhỏ nhất
        local u, uDist = nil, math.huge
        for _, n in ipairs(ns) do
            if not done[n] and dist[n] < uDist then
                uDist, u = dist[n], n
            end
        end
        if not u or u == to then break end
        done[u] = true

        for v, w in pairs(graph[u]) do
            if not done[v] then
                local nd = dist[u] + w
                if nd < dist[v] then
                    dist[v], prev[v] = nd, u
                end
            end
        end
    end

    if dist[to] == math.huge then return nil end

    -- Reconstruct path
    local path, cur = {}, to
    while cur do
        table.insert(path, 1, cur)
        cur = prev[cur]
    end
    return path
end

-- ============================================================
-- Chờ respawn
-- ============================================================
local function waitAlive(timeout)
    local t0 = os.clock()
    while os.clock() - t0 < (timeout or CFG.RESPAWN_TO) do
        local h = hrp()
        if h then return true end
        task.wait(0.1)
    end
    return false
end

-- ============================================================
-- 2 chế độ di chuyển
-- ============================================================
local _stop = false

-- QuickTP: giữ CFrame không die, verify sau
-- Trả về: true nếu server accept, false nếu bị reject
local function quickTP(pos)
    local cf = CFrame.new(pos)
    local t0 = os.clock()

    while os.clock() - t0 < CFG.HOLD_TIME do
        if _stop then return false end
        local h, m = hrp()
        if not h then return false end
        setCF(h, cf)
        task.wait(CFG.HOLD_STEP)
    end

    -- Verify: check vị trí thực tế sau khi giữ
    local h = hrp()
    if not h then return false end
    local accepted = d(h.Position, pos) <= CFG.VERIFY_DIST
    return accepted
end

-- DieTP: set CFrame → die → đợi respawn → giữ CFrame liên tục sau respawn
-- Dùng cho đảo cao (Sky Island) hoặc đích cuối
local function dieTP(pos)
    local cf = CFrame.new(pos)

    local h, m = hrp()
    if not h then
        if not waitAlive() then return false end
        h, m = hrp()
        if not h then return false end
    end

    -- Giữ vị trí rồi die
    local t0 = os.clock()
    while os.clock() - t0 < CFG.HOLD_TIME do
        if _stop then return false end
        h, m = hrp()
        if not (h and m and m.Health > 0) then break end
        setCF(h, cf)
        task.wait(CFG.HOLD_STEP)
    end

    if _stop then return false end

    -- Die tại vị trí đó
    local _, hum = hrp()
    if hum then pcall(function() hum.Health = 0 end) end

    -- Đợi respawn
    if not waitAlive() then return false end

    -- Sau respawn: liên tục set CFrame trong 1.5s
    -- Quan trọng với Sky Island vì game spawn dưới đất trước
    local t1 = os.clock()
    while os.clock() - t1 < 1.5 do
        if _stop then break end
        local nh = hrp()
        if nh then setCF(nh, cf) end
        task.wait(CFG.HOLD_STEP)
    end

    -- Verify cuối: có đến nơi chưa?
    local nh = hrp()
    if not nh then return false end
    local arrived = d(nh.Position, pos) <= CFG.VERIFY_DIST

    -- Nếu vẫn chưa đến (Sky Island quá khó) → thử thêm 1 lần nữa
    if not arrived then
        task.wait(0.2)
        local nh2 = hrp()
        if nh2 then
            setCF(nh2, cf)
            task.wait(0.5)
            local nh3 = hrp()
            arrived = nh3 and d(nh3.Position, pos) <= CFG.VERIFY_DIST
        end
    end

    return arrived ~= false
end

-- ============================================================
-- Core: di chuyển 1 bước
-- Thử QuickTP trước, fallback DieTP nếu fail
-- ============================================================
local function moveToIsland(name, isLast)
    local pos = ISLANDS[name].Position
    local h   = hrp()

    -- Đã đủ gần → bỏ qua
    if h and d(h.Position, pos) <= CFG.SKIP_NEAR then
        return true
    end

    -- Đích cuối, hoặc đảo cao/đặc biệt → DieTP luôn
    if isLast or FORCE_DIE[name] then
        return dieTP(pos)
    end

    -- Trung gian → thử QuickTP, fallback DieTP
    local ok = quickTP(pos)
    if _stop then return false end
    if ok then return true end
    return dieTP(pos)
end

-- ============================================================
-- Public API
-- ============================================================
local _running = false

function PMT_FastHopTo(target)
    target = norm(target)
    if not target or not ISLANDS[target] then
        warn("[PMT] Đảo không hợp lệ: " .. tostring(target))
        return false
    end

    if not hrp() then
        if not waitAlive() then return false end
    end

    local h = hrp()
    if not h then return false end

    _running, _stop = true, false
    local success = false

    -- Đảo cô lập → DieTP thẳng, không cần Dijkstra
    if ISOLATED[target] then
        success = dieTP(ISLANDS[target].Position)
        _running = false
        return success
    end

    -- Tìm đường bình thường
    local start = nearest(h.Position)
    local path  = findPath(start, target)

    if not path then
        warn("[PMT] Không tìm được đường đến: " .. target)
        _running = false
        return false
    end

    success = true
    local total = #path

    for i, name in ipairs(path) do
        if _stop then success = false; break end
        local ok = moveToIsland(name, i == total)
        if not ok or _stop then
            success = false
            break
        end
    end

    _running = false
    return success and not _stop
end

function PMT_StopFastHop()
    _stop = true
end

function PMT_IsFastHopRunning()
    return _running
end

function PMT_IsNearIsland(name, range)
    local island = ISLANDS[norm(name) or ""]
    if not island then return true end
    local h = hrp()
    if not h then return false end
    return d(h.Position, island.Position) <= (range or 2500)
end

function BuildIslandOptions()
    local out, seen = {}, {}
    for _, name in ipairs(WORLDS[worldKey()] or {}) do
        local r = ALIAS[name] or name
        if ISLANDS[r] and not seen[r] then
            seen[r] = true
            out[#out+1] = r
        end
    end
    table.sort(out)
    return out
end

-- ============================================================
-- Global trigger loop (tương thích với _G.Tpfast)
-- ============================================================
task.spawn(function()
    while task.wait(0.25) do
        if _G.Tpfast and not _running then
            local t = _G.Islandtp
            if t and t ~= "" then
                _stop = false
                PMT_FastHopTo(t)
                _G.Tpfast  = false
                _G.Islandtp = ""
            end
        end
    end
end)
