Citizen.CreateThread(function()
    Wait(15000)
    while true do
        for _, v in pairs(Configi.viestittt) do
            TriggerEvent('chatMessage', Configi.nimi, Configi.vari, " " .. v.teksti)
            Wait(Configi.viive * 1000)
        end
        Wait(0)
    end
end)
