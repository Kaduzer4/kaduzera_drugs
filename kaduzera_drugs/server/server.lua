local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Kaduzera = {}
Tunnel.bindInterface("kaduzera_drugs",Kaduzera)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÃO DRUGS QUE PODERÁ SER VENDIDA
-----------------------------------------------------------------------------------------------------------------------------------------

local DrugsList = {
    ["lean"] = {
        ["price"] = { 1500, 1500 },
        ["rand"] = { 4, 8 }
    },
    ["meth"] = {
        ["price"] = { 1500, 1500 },
        ["rand"] = { 4, 8 }
    },
    ["cocaine"] = {
        ["price"] = { 1500, 1500 },
        ["rand"] = { 4, 8 }
    },
}

function Kaduzera.reward()
    local source = source
    local Passport = vRP.Passport(source)
    if Passport then
        for k,v in pairs(DrugsList) do
            local random = math.random(v.rand[1],v.rand[2])
            local consultItem = vRP.InventoryItemAmount(Passport,k)
            if consultItem[1] >= parseInt(random) then
                vRPC.CreateObjects(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422,0.0,-0.05,0.05,180.0,0.0,0.0)
                TriggerClientEvent("Progress",source,"Vendendo",5000)
                Citizen.Wait(5000)
                if vRP.TakeItem(Passport,k,random,true) then
                    TriggerClientEvent("sounds:source",source,"cash",0.05)
                    local randomPlusPrice = math.random(v.price[1], v.price[2]) * random
                    vRP.GenerateItem(Passport,"dollarsroll",randomPlusPrice,true)
                    
                    vRP.UpgradeStress(Passport,2)
                    vRPC.Destroy(source)

                    if math.random(100) <= 95 then -- Changed from >= 75 to <= 95
                        local ped = GetPlayerPed(source)
                        local coords = GetEntityCoords(ped)
                    
                        local policeResult = vRP.NumPermission("Police")
                        for k,v in pairs(policeResult) do
                            async(function()
                                TriggerClientEvent("NotifyPush",v,{ code = "QRU", title = "Venda de Drogas", x = coords["x"], y = coords["y"], z = coords["z"], time = "Recebido às "..os.date("%H:%M"), blipColor = 5 })
                            end)
                        end
                    end

                    return true
                end
            end
        end
    end
    return false
end