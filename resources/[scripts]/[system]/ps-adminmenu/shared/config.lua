Config = Config or {}

Config.Core = "qbx_core"        -- "qb-core" or "qbx_core"
Config.Fuel = "cdn-fuel"        -- "ps-fuel", "LegacyFuel", "ox_fuel"
Config.ResourcePerms = 'admin' -- permission to control resource(start stop restart)
Config.ShowCommandsPerms = 'staffcommands' -- permission to show all commands
Config.RenewedPhone = false    -- if you use qb-phone from renewed. (multijob)

-- Key Bindings
Config.Keybindings = true
Config.AdminKey = "PageDown"
Config.NoclipKey = "PageUp"

-- Give Car
Config.DefaultGarage = "Alta Garage"

Config.Actions = {
    ["admin_car"] = {
        label = "Admin Car",
        type = "client",
        event = "ps-adminmenu:client:Admincar",
        perms = "admin",
    },

    ["ban_player"] = {
        label = "Ban Player",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Reason", option = "text" },
            {
                label = "Duration",
                option = "dropdown",
                data = {
                    { label = "Permanent",  value = "2147483647" },
                    { label = "10 Minutes", value = "600" },
                    { label = "30 Minutes", value = "1800" },
                    { label = "1 Hour",     value = "3600" },
                    { label = "6 Hours",    value = "21600" },
                    { label = "12 Hours",   value = "43200" },
                    { label = "1 Day",      value = "86400" },
                    { label = "3 Days",     value = "259200" },
                    { label = "1 Week",     value = "604800" },
                    { label = "3 Week",     value = "1814400" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "ps-adminmenu:server:BanPlayer" },
        },
    },

    ["bring_player"] = {
        label = "Bring Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:BringPlayer" },
        },
    },

    ["change_weather"] = {
        label = "Change Weather",
        perms = "staff",
        dropdown = {
            {
                label = "Weather",
                option = "dropdown",
                data = {
                    { label = "Extrasunny", value = "Extrasunny" },
                    { label = "Clear",      value = "Clear" },
                    { label = "Neutral",    value = "Neutral" },
                    { label = "Smog",       value = "Smog" },
                    { label = "Foggy",      value = "Foggy" },
                    { label = "Overcast",   value = "Overcast" },
                    { label = "Clouds",     value = "Clouds" },
                    { label = "Clearing",   value = "Clearing" },
                    { label = "Rain",       value = "Rain" },
                    { label = "Thunder",    value = "Thunder" },
                    { label = "Snow",       value = "Snow" },
                    { label = "Blizzard",   value = "Blizzard" },
                    { label = "Snowlight",  value = "Snowlight" },
                    { label = "Xmas",       value = "Xmas" },
                    { label = "Halloween",  value = "Halloween" },
                },
            },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:ChangeWeather" },
        },
    },

    ["change_time"] = {
        label = "Change Time",
        perms = "staff",
        dropdown = {
            {
                label = "Time Events",
                option = "dropdown",
                data = {
                    { label = "Sunrise", value = "06" },
                    { label = "Morning", value = "09" },
                    { label = "Noon",    value = "12" },
                    { label = "Sunset",  value = "21" },
                    { label = "Evening", value = "22" },
                    { label = "Night",   value = "24" },
                },
            },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:ChangeTime" },
        },
    },

    ["change_plate"] = {
        label = "Change Plate",
        perms = "staff",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:ChangePlate" },
        },
    },

    ["clear_inventory"] = {
        label = "Clear Inventory",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:ClearInventory" },
        },
    },

    ["clear_inventory_offline"] = {
        label = "Clear Inventory Offline",
        perms = "admin",
        dropdown = {
            { label = "Citizen ID", option = "text",   data = "players" },
            { label = "Confirm",    option = "button", type = "server", event = "ps-adminmenu:server:ClearInventoryOffline" },
        },
    },

    ["clothing_menu"] = {
        label = "Give Clothing Menu",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:ClothingMenu" },
        },
    },

    ["set_ped"] = {
        label = "Set Ped",
        perms = "admin",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            { label = "Ped Models", option = "dropdown", data = "pedlist" },
            { label = "Confirm",    option = "button",   type = "server", event = "ps-adminmenu:server:setPed" },
        },
    },

    ["copy_coords"] = {
        label = "Copy Coords",
        perms = "admin",
        dropdown = {
            {
                label = "Copy Coords",
                option = "dropdown",
                data = {
                    { label = "Copy Vector2", value = "vector2" },
                    { label = "Copy Vector3", value = "vector3" },
                    { label = "Copy Vector4",    value = "vector4" },
                    { label = "Copy Heading",  value = "heading" },
                },
            },
            { label = "Copy to Clipboard", option = "button", type = "client", event = "ps-adminmenu:client:copyToClipboard"},
        },
    },

    ["delete_vehicle"] = {
        label = "Delete Vehicle",
        type = "command",
        event = "dv",
        perms = "staff",
    },

    ["freeze_player"] = {
        label = "Freeze Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:FreezePlayer" },
        },
    },

    ["drunk_player"] = {
        label = "Make Player Drunk",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:DrunkPlayer" },
        },
    },

    ["remove_stress"] = {
        label = "Remove Stress",
        perms = "admin",
        dropdown = {
            { label = "Player (Optional)", option = "dropdown", data = "players" },
            { label = "Confirm",           option = "button",   type = "server", event = "ps-adminmenu:server:RemoveStress" },
        },
    },

    ["set_ammo"] = {
        label = "Set Ammo",
        perms = "admin",
        dropdown = {
            { label = "Ammo Amount", option = "text" },
            { label = "Confirm",      option = "button", type = "client", event = "ps-adminmenu:client:SetAmmo" },
        },
    },

    ["nui_focus"] = {
        label = "Give NUI Focus",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "client", event = "" },
        },
    },

    ["god_mode"] = {
        label = "God Mode",
        type = "client",
        event = "ps-adminmenu:client:ToggleGodmode",
        perms = "admin",
    },

    ["give_car"] = {
        label = "Give Car",
        perms = "admin",
        dropdown = {
            { label = "Vehicle",           option = "dropdown", data = "vehicles" },
            { label = "Player",            option = "dropdown", data = "players" },
            { label = "Plate (Optional)",  option = "text" },
            { label = "Garage (Optional)", option = "text" },
            { label = "Confirm",           option = "button",   type = "server",  event = "ps-adminmenu:server:givecar" },
        }
    },

    ["invisible"] = {
        label = "Invisible",
        type = "client",
        event = "ps-adminmenu:client:ToggleInvisible",
        perms = "admin",
    },

    ["blackout"] = {
        label = "Toggle Blackout",
        type = "server",
        event = "ps-adminmenu:server:ToggleBlackout",
        perms = "admin",
    },

    ["toggle_duty"] = {
        label = "Toggle Duty",
        type = "server",
        event = "QBCore:ToggleDuty",
        perms = "staff",
    },

    ["toggle_laser"] = {
        label = "Toggle Laser",
        type = "client",
        event = "ps-adminmenu:client:ToggleLaser",
        perms = "admin",
    },

    ["set_perms"] = {
        label = "Set Perms",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            {
                label = "Permissions",
                option = "dropdown",
                data = {
                    { label = "Staff",   value = "staff" },
                    { label = "Admin", value = "admin" },
                },
            },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:SetPerms" },
        },
    },

    ["set_bucket"] = {
        label = "Set Routing Bucket",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Bucket",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:SetBucket" },
        },
    },

    ["get_bucket"] = {
        label = "Get Routing Bucket",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:GetBucket" },
        },
    },

    ["mute_player"] = {
        label = "Mute Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "client", event = "ps-adminmenu:client:MutePlayer" },
        },
    },

    ["noclip"] = {
        label = "Noclip",
        type = "client",
        event = "ps-adminmenu:client:ToggleNoClip",
        perms = "staff",
    },

    ["open_inventory"] = {
        label = "Open Inventory",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "client", event = "ps-adminmenu:client:openInventory" },
        },
    },

    ["open_stash"] = {
        label = "Open Stash",
        perms = "staff",
        dropdown = {
            { label = "Stash",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:openStash" },
        },
    },

    ["open_trunk"] = {
        label = "Open Trunk",
        perms = "staff",
        dropdown = {
            { label = "Plate",   option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:openTrunk" },
        },
    },

    ["change_vehicle_state"] = {
        label = "Set Vehicle Garage State",
        perms = "staff",
        dropdown = {
            { label = "Plate",   option = "text" },
            {
                label = "State",
                option = "dropdown",
                data = {
                    { label = "In",  value = "1" },
                    { label = "Out", value = "0" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "ps-adminmenu:server:SetVehicleState" },
        },
    },

    ["revive_all"] = {
        label = "Revive All",
        type = "server",
        event = "ps-adminmenu:server:ReviveAll",
        perms = "staff",
    },

    ["revive_player"] = {
        label = "Revive Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:Revive" },
        },
    },

    ["revive_radius"] = {
        label = "Revive Radius",
        type = "server",
        event = "ps-adminmenu:server:ReviveRadius",
        perms = "staff",
    },

    ["refuel_vehicle"] = {
        label = "Refuel Vehicle",
        type = "client",
        event = "ps-adminmenu:client:RefuelVehicle",
        perms = "staff",
    },

    ["set_job"] = {
        label = "Set Job",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Job",     option = "dropdown", data = "jobs" },
            { label = "Grade",   option = "text",     data = "grades" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:SetJob" },
        },
    },

    ["set_gang"] = {
        label = "Set Gang",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Gang",    option = "dropdown", data = "gangs" },
            { label = "Grade",   option = "text",     data = "grades" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:SetGang" },
        },
    },

    ["give_money"] = {
        label = "Give Money",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash",   value = "cash" },
                    { label = "Bank",   value = "bank" },
                    { label = "Crypto", value = "crypto" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoney" },
        },
    },

    ["give_money_all"] = {
        label = "Give Money to All",
        perms = "admin",
        dropdown = {
            { label = "Amount",  option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash",   value = "cash" },
                    { label = "Bank",   value = "bank" },
                    { label = "Crypto", value = "crypto" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "ps-adminmenu:server:GiveMoneyAll" },
        },
    },

    ["remove_money"] = {
        label = "Remove Money",
        perms = "admin",
        dropdown = {
            { label = "Player", option = "dropdown", data = "players" },
            { label = "Amount", option = "text" },
            {
                label = "Type",
                option = "dropdown",
                data = {
                    { label = "Cash", value = "cash" },
                    { label = "Bank", value = "bank" },
                },
            },
            { label = "Confirm", option = "button", type = "server", event = "ps-adminmenu:server:TakeMoney" },
        },
    },

    ["give_item"] = {
        label = "Give Item",
        perms = "admin",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItem" },
        },
    },

    ["give_item_all"] = {
        label = "Give Item to All",
        perms = "admin",
        dropdown = {
            { label = "Item",    option = "dropdown", data = "items" },
            { label = "Amount",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:GiveItemAll" },
        },
    },

    ["spawn_vehicle"] = {
        label = "Spawn Vehicle",
        perms = "staff",
        dropdown = {
            { label = "Vehicle", option = "dropdown", data = "vehicles" },
            { label = "Confirm", option = "button",   type = "client",  event = "ps-adminmenu:client:SpawnVehicle" },
        },
    },

    ["fix_vehicle"] = {
        label = "Fix Vehicle",
        type = "command",
        event = "fix",
        perms = "staff",
    },

    ["fix_vehicle_for"] = {
        label = "Fix Vehicle for player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:FixVehFor" },
        },
    },

    ["spectate_player"] = {
        label = "Spectate Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:SpectateTarget" },
        },
    },

    ["telport_to_player"] = {
        label = "Teleport to Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:TeleportToPlayer" },
        },
    },

    ["telport_to_coords"] = {
        label = "Teleport to Coords",
        perms = "admin",
        dropdown = {
            { label = "Coords",  option = "text" },
            { label = "Confirm", option = "button", type = "client", event = "ps-adminmenu:client:TeleportToCoords" },
        },
    },

    ["teleport_to_location"] = {
        label = "Teleport to Location",
        perms = "admin",
        dropdown = {
            { label = "Location", option = "dropdown", data = "locations" },
            { label = "Confirm",  option = "button",   type = "client",   event = "ps-adminmenu:client:TeleportToLocation" },
        },
    },

    ["teleport_to_marker"] = {
        label = "Teleport to Marker",
        type = "command",
        event = "tpm",
        perms = "staff",
    },

    ["teleport_back"] = {
        label = "Teleport Back",
        type = "client",
        event = "ps-adminmenu:client:TeleportBack",
        perms = "staff",
    },

    ["vehicle_dev"] = {
        label = "Vehicle Dev Menu",
        type = "client",
        event = "ps-adminmenu:client:ToggleVehDevMenu",
        perms = "admin",
    },

    ["toggle_coords"] = {
        label = "Toggle Coords",
        type = "client",
        event = "ps-adminmenu:client:ToggleCoords",
        perms = "admin",
    },

    ["toggle_blips"] = {
        label = "Toggle Blips",
        type = "client",
        event = "ps-adminmenu:client:toggleBlips",
        perms = "admin",
    },

    ["toggle_names"] = {
        label = "Toggle Names",
        type = "client",
        event = "ps-adminmenu:client:toggleNames",
        perms = "admin",
    },

    ["toggle_cuffs"] = {
        label = "Toggle Cuffs",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:CuffPlayer" },
        },
    },

    ["max_mods"] = {
        label = "Max Vehicle Mods",
        type = "client",
        event = "ps-adminmenu:client:maxmodVehicle",
        perms = "admin",
    },

    ["warn_player"] = {
        label = "Warn Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:WarnPlayer" },
        },
    },

    ["infinite_ammo"] = {
        label = "Infinite Ammo",
        type = "client",
        event = "ps-adminmenu:client:setInfiniteAmmo",
        perms = "admin",
    },

    ["kick_player"] = {
        label = "Kick Player",
        perms = "staff",
        dropdown = {
            { label = "Player",  option = "dropdown", data = "players" },
            { label = "Reason",  option = "text" },
            { label = "Confirm", option = "button",   type = "server", event = "ps-adminmenu:server:KickPlayer" },
        },
    },


    ["play_sound"] = {
        label = "Play Sound",
        perms = "admin",
        dropdown = {
            { label = "Player",     option = "dropdown", data = "players" },
            {
                label = "Sound",
                option = "dropdown",
                data = {
                    { label = "Alert",      value = "alert" },
                    { label = "Cuff",       value = "cuff" },
                    { label = "Air Wrench", value = "airwrench" },
                },
            },
            { label = "Play Sound", option = "button",   type = "client", event = "ps-adminmenu:client:PlaySound" },
        },
    },
 }

Config.PlayerActions = {
    ["teleportToPlayer"] = {
        label = "Teleport to Player",
        type = "server",
        event = "ps-adminmenu:server:TeleportToPlayer",
        perms = "staff",
    },
    ["bringPlayer"] = {
        label = "Bring Player",
        type = "server",
        event = "ps-adminmenu:server:BringPlayer",
        perms = "staff",
    },
    ["revivePlayer"] = {
        label = "Revive Player",
        event = "ps-adminmenu:server:Revive",
        perms = "staff",
        type = "server"
    },
    ["spawnPersonalVehicle"] = {
        label = "Spawn Personal Vehicle",
        event = "ps-adminmenu:client:SpawnPersonalVehicle",
        perms = "staff",
        type = "client"
    },
    ["banPlayer"] = {
        label = "Ban Player",
        event = "ps-adminmenu:server:BanPlayer",
        perms = "staff",
        type = "server"
    },
    ["kickPlayer"] = {
        label = "Kick Player",
        event = "ps-adminmenu:server:KickPlayer",
        perms = "staff",
        type = "server"
    }
}

Config.OtherActions = {
    ["toggleDevmode"] = {
        type = "client",
        event = "ps-adminmenu:client:ToggleDev",
        perms = "admin",
        label = "Toggle Devmode"
    }
}

if GetResourceState('ox_inventory') == 'started' then
    Config.Inventory = 'ox_inventory'
elseif GetResourceState('ps-inventory') == 'started' then
    Config.Inventory = 'ps-inventory'
elseif GetResourceState('lj-inventory') == 'started' then
    Config.Inventory = 'lj-inventory'
elseif GetResourceState('qb-inventory') == 'started' then
    Config.Inventory = 'qb-inventory'
end
