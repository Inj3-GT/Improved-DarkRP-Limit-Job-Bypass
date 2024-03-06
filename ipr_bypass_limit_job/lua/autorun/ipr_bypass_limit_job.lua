----------- // SCRIPT BY INJ3
----------- // SCRIPT BY INJ3
----------- // SCRIPT BY INJ3
---- // https://steamcommunity.com/id/Inj3/
local ipr = {} --- Do not touch !

--- Configuration / (Restart your server if you add new groups.)
--- This will add extra places to your jobs!
--- If you have defined a number in your "darkrp jobs" file, they will add up.

--- // Configuration
ipr.tbl_bypass = {
        ["Chef Pizza"] = { --- This is an example. // Add name of your job that will not be affected by the job limit.
            limit_reached = {
                ["superadmin"] = 0, --- '0' has no limit to access a job if it's full.
                ["vip"] = 1, --- Add an extra slot to your job for the specified group.
                ["admin"] = 1,
            }
        },

        ["Marchand Noir"] = { --- This is an example.
            limit_reached = {
                ["superadmin"] = 1,
                ["vip"] = 1,
                ["admin"] = 2,
                ["vip +"] = 2,
            }
        },

        ["Vendeur d'armes"] = { --- This is an example.
            limit_reached = {
                ["superadmin"] = 0,
                ["vip"] = 1,
                ["admin"] = 2,
                ["vip +"] = 2,
            }
        },
}
--- //

------ Do not touch the code below at the risk of breaking the gamemode ! 
ipr_BpLimit = ipr_BpLimit or {}

if (CLIENT) then
    function ipr_BpLimit.Max(t) --- function for the F4 menu, check the description on github to know how it works (if '-1' you have not correctly added the player table RPExtraTeams !)
        return (t and (t.max_bp or t.max)) or -1
    end

    local function ipr_InitFunc()
        local ipr_pl = LocalPlayer()
        if not IsValid(ipr_pl) then
            return
        end

        local ipr_grp = ipr_pl:GetUserGroup()
        if not ipr.grp or (ipr_grp ~= ipr.grp) then
            local ipr_ex = RPExtraTeams

            for _, t in ipairs(ipr_ex) do
                if (t.max_bp) then
                    t.max = t.max_bp
                    t.max_bp = nil
                end

                local ipr_n = ipr.tbl_bypass[t.name]
                if not ipr_n then
                  continue
                end
                local ipr_g = ipr_n.limit_reached[ipr_grp]
                if not ipr_g then
                  continue
                end

                t.max_bp = t.max
                t.max = (ipr_g == 0) and 0 or t.max_bp + ipr_g
            end
            ipr.grp = ipr_grp
        end
    end
        
    if (ipr_BpLimit.Refresh_Lua) then
        ipr_InitFunc()
    end
    net.Receive("iprbp_uptjob", ipr_InitFunc)
    hook.Add("InitPostEntity", "Improved_Limit_Job_Bypass", ipr_InitFunc)
else
    local function ipr_UserCc(n, g)
        for t, f in pairs(ipr.tbl_bypass) do
            if (t == n) then
                for p in pairs(f.limit_reached) do
                    if (p == g) then
                        return true
                    end
                end
                break
            end
        end
        return false
    end

    local function ipr_InitFunc_Override()
        local ipr_meta = FindMetaTable("Player")
        local ipr_overridefunc = "changeteam"

        do
            local function ipr_UpdateCall(p)
                net.Start("iprbp_uptjob")
                net.Send(p)
            end

            local ipr_CacheFunc = ipr_meta.SetUserGroup
            ipr_meta.SetUserGroup = function(s, str)
                if not IsValid(s) then
                    return
                end
                ipr_CacheFunc(s, str)
                ipr_UpdateCall(s)
            end
        end

        for n in pairs(ipr_meta) do
            local ipr_str = string.lower(n)
            if (ipr_str ~= ipr_overridefunc) then
              continue
            end

            local ipr_CacheFunc = ipr_meta[n]
            ipr_meta[n] = function(s, id, f, v, g)
                if not IsValid(s) then
                    return
                end
                if (f or g) then
                    return ipr_CacheFunc(s, id, f, v, g)
                end
                local ipr_ex = RPExtraTeams[id]
                if not ipr_ex then
                    return
                end

                local ipr_g = s:GetUserGroup()
                local ipr_t = ipr_ex.name
                if ipr_UserCc(ipr_t, ipr_g) then
                    local ipr_m = team.NumPlayers(id)
                    local ipr_l = ipr.tbl_bypass[ipr_t].limit_reached[ipr_g]

                    local ipr_c = ipr_l + ipr_ex.max
                    local ipr_n = ipr_m >= ipr_c
                    local ipr_f = ipr_l ~= 0

                    if (ipr_f and ipr_n) then
                        DarkRP.notify(s, 0, 3, "[Ipr_Limit_Job] Vous avez atteint la limite des " ..ipr_l.. " slots supplémentaires pour votre rang défini dans ce job.")
                        return
                    end

                    local ipr_p = not ipr_f and true or not ipr_n and true or false
                    return ipr_CacheFunc(s, id, ipr_p, v, ipr_p)
                end
                ipr_CacheFunc(s, id, f, v, g)
            end
        end
    end

    util.AddNetworkString("iprbp_uptjob")
    hook.Add("InitPostEntity", "Improved_Limit_Job_Bypass", ipr_InitFunc_Override)

    if (ipr_BpLimit.Refresh_Lua) then
        ipr_InitFunc_Override()
    end
    print("Bypass Job limit DarkRP v2.2 by Inj3 loaded !")
end
ipr_BpLimit.Refresh_Lua = ipr_BpLimit.Refresh_Lua or {}
