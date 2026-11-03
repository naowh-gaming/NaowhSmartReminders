local file = assert(io.open(arg[1] or "NaowhUI_SmartReminders.lua", "rb"))
local source = file:read("*a"):gsub("\r\n", "\n"); file:close()
local first = assert(source:find("do\n    local bySpell, built", 1, true))
local last = assert(source:find("-- Is this spell castable right now?", first, true))
local block = source:sub(first, last - 1)
local SPELL, OTHER = 900, 901
local cases, failures = 0, 0

local function Fixture()
    local e = { now = 0, sealed = false, start = 0, dur = 0, refreshes = 0, db = {},
        links = { [13] = "trinket:a", [14] = "trinket:passive" },
        spells = { ["trinket:a"] = SPELL, ["trinket:b"] = OTHER } }
    local ns = { CooldownKey = function(sid) return sid end,
        LearnTotal = function(sid, total)
            e.db.learned = e.db.learned or {}
            e.db.learned[tostring(sid)] = total
        end,
        RefreshRuntime = function() e.refreshes = e.refreshes + 1 end }
    local env = { ns = ns, readyAt = {}, INVSLOT_TRINKET1 = 13, INVSLOT_TRINKET2 = 14,
        GetTime = function() return e.now end, TRDB = function() return e.db end,
        IsLoggedIn = function() return true end,
        wipe = function(t) for k in pairs(t) do t[k] = nil end end,
        issecretvalue = function() return e.sealed end,
        GetInventoryItemLink = function(_, slot) return e.links[slot] end,
        GetInventoryItemCooldown = function(_, slot)
            if slot == 13 then return e.start, e.dur, 1 end
            return 0, 0, 1
        end,
        C_Item = {
            GetItemSpell = function(link)
                if e.spells[link] then return "Use", e.spells[link] end
            end,
            GetItemInfo = function(link) return link end,
        },
        CreateFrame = function()
            return { RegisterEvent = function() end,
                SetScript = function(_, _, fn) e.onEvent = fn end }
        end,
    }
    setmetatable(env, { __index = _G })
    local chunk = assert(loadstring(block))
    setfenv(chunk, env)
    chunk()
    e.ns, e.readyAt = ns, env.readyAt
    return e
end
local function Case(name, fn)
    cases = cases + 1
    local ok, err = pcall(fn)
    if ok then print("PASS " .. name)
    else failures = failures + 1; print("FAIL " .. name .. ": " .. tostring(err)) end
end
local function Eq(actual, expected)
    assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

Case("the 30 s equip lockout is not learned as the trinket's cooldown", function()
    local e = Fixture()
    e.now, e.start, e.dur = 100, 100, 30
    Eq(e.ns.ResyncTrinket(SPELL), true)
    Eq(e.db.learned, nil)
    Eq(e.readyAt[SPELL], 130)
    e.now, e.sealed = 200, true
    e.ns.NoteTrinketCast(SPELL)
    Eq(e.ns.TrinketReady(SPELL, 319), false)
    Eq(e.ns.TrinketReady(SPELL, 320), true)
end)
Case("the shared lockout from the other trinket is not learned", function()
    local e = Fixture()
    e.now, e.start, e.dur = 100, 95, 20
    e.ns.ResyncTrinket(SPELL)
    Eq(e.db.learned, nil)
    Eq(e.ns.TrinketReady(SPELL, 100), false)
end)
Case("a readable cooldown tail sets the length of a sealed cast", function()
    local e = Fixture()
    e.now, e.start, e.dur = 100, 50, 90
    e.ns.ResyncTrinket(SPELL)
    Eq(e.db.learned[tostring(SPELL)], 90)
    e.now, e.sealed = 300, true
    e.ns.NoteTrinketCast(SPELL)
    Eq(e.ns.TrinketReady(SPELL, 389), false)
    Eq(e.ns.TrinketReady(SPELL, 390), true)
end)
Case("a readable cast learns its own cooldown", function()
    local e = Fixture()
    e.now, e.start, e.dur = 100, 100, 120
    Eq(e.ns.NoteTrinketCast(SPELL), true)
    Eq(e.db.learned[tostring(SPELL)], 120)
    Eq(e.readyAt[SPELL], 220)
end)
Case("spells that are not worn trinkets fall through", function()
    local e = Fixture()
    Eq(e.ns.TrinketSlot(SPELL), 13)
    Eq(e.ns.TrinketSlot(123), nil)
    Eq(e.ns.TrinketReady(123), nil)
    Eq(e.ns.NoteTrinketCast(123), false)
    Eq(e.ns.ResyncTrinket(123), false)
end)
Case("a trinket swap rebuilds the map and refreshes once", function()
    local e = Fixture()
    Eq(e.ns.TrinketSlot(SPELL), 13)
    e.links[13] = "trinket:b"
    e.onEvent(nil, "PLAYER_EQUIPMENT_CHANGED", 13)
    Eq(e.refreshes, 1)
    Eq(e.ns.TrinketSlot(SPELL), nil)
    Eq(e.ns.TrinketSlot(OTHER), 13)
    e.onEvent(nil, "PLAYER_EQUIPMENT_CHANGED", 16)
    Eq(e.refreshes, 1)
end)
print(cases .. " cases; " .. failures .. " failures")
assert(failures == 0)
