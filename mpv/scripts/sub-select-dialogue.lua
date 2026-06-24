-- sub-select-dialogue.lua
-- On load, pick the best subtitle track for "Japanese audio + English subs".
-- Many dual-audio anime ship two English sub tracks: a "Signs & Songs" track
-- (often flagged default) and a full "Dialogue" track. Plain slang=en grabs the
-- first/default one, which can be signs-only. This scores tracks so the full
-- dialogue track wins.

local function score_sub(t)
    local title = (t.title or ""):lower()
    local lang  = (t.lang  or ""):lower()
    local s = 0
    -- prefer English
    if lang:match("^en") or lang:match("eng") then s = s + 100 end
    -- strongly prefer a full dialogue track
    if title:match("dialog") or title:match("full")
       or title:match("main") or title:match("subtitle") then s = s + 50 end
    -- avoid signs/songs-only tracks
    if title:match("sign") or title:match("song") then s = s - 80 end
    -- avoid forced tracks as the main sub
    if t.forced then s = s - 40 end
    return s
end

mp.register_event("file-loaded", function()
    local tracks = mp.get_property_native("track-list")
    if not tracks then return end

    local best_id, best_score = nil, nil
    for _, t in ipairs(tracks) do
        if t.type == "sub" then
            local sc = score_sub(t)
            if best_score == nil or sc > best_score then
                best_score, best_id = sc, t.id
            end
        end
    end

    if best_id then
        mp.set_property("sid", tostring(best_id))
        mp.set_property_bool("sub-visibility", true)
    end
end)
