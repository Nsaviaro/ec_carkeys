ESX = exports["es_extended"]:getSharedObject()

local function isEmergencyJob(job)
    return job == 'police' or job == 'ambulance'
end

local function getVehicleInFront()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local forward = GetEntityForwardVector(player)
    local coords = coords + (forward * 2.0)
    
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
    if DoesEntityExist(vehicle) then
        return vehicle
    end
    return nil
end


local function playKeyfobAnimation()
    local ped = PlayerPedId()

    local dict = "anim@mp_player_intmenu@key_fob@"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    
    TaskPlayAnim(ped, dict, "fob_click", 8.0, 8.0, -1, 48, 1, false, false, false)
    Wait(500) 
    RemoveAnimDict(dict)
end



local function playLockAnimation(vehicle, locked)
    local count = locked and 2 or 1  
    
    CreateThread(function()

        playKeyfobAnimation()
        

        
        for i = 1, count do
            SetVehicleLights(vehicle, 2)
            Wait(200)
            SetVehicleLights(vehicle, 0)

            if count == 2 and i == 1 then
                StartVehicleHorn(vehicle, 100, "HELDDOWN", false) --Comment if you dont want horn sound when locking
                Wait(200)
            end
        end
    end)
end

local function handleVehicleLock()
    local vehicle = getVehicleInFront()
    if not vehicle then
        lib.notify({
            title = 'Keskuslukitus',
            description = 'Avain ei yhdistä ajoneuvoon',
            type = 'error'
        })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local playerJob = ESX.GetPlayerData().job


    local vehicleClass = GetVehicleClass(vehicle)
    if (vehicleClass == 18 or vehicleClass == 15) and isEmergencyJob(playerJob.name) then
        local lock = GetVehicleDoorLockStatus(vehicle)
        if lock == 1 then
            SetVehicleDoorsLocked(vehicle, 2)
            playLockAnimation(vehicle, true)  
            lib.notify({
                title = 'Keskuslukitus',
                description = 'Lukittu',
                type = 'warning'
            })
        else
            SetVehicleDoorsLocked(vehicle, 1)
            playLockAnimation(vehicle, false)  
            lib.notify({
                title = 'Keskuslukitus',
                description = 'Avattu',
                type = 'success'
            })
        end
        return
    end


    ESX.TriggerServerCallback('doorlock:checkOwnership', function(isOwner)
        if isOwner then
            local lock = GetVehicleDoorLockStatus(vehicle)
            if lock == 1 then
                SetVehicleDoorsLocked(vehicle, 2)
                playLockAnimation(vehicle, true)  
                lib.notify({
                    title = 'Keskuslukitus',
                    description = 'Lukittu',
                    type = 'warning'
                })
            else
                SetVehicleDoorsLocked(vehicle, 1)
                playLockAnimation(vehicle, false) 
                lib.notify({
                    title = 'Keskuslukitus',
                    description = 'Avattu',
                    type = 'success'
                })
            end
        else
            lib.notify({
                title = 'Keskuslukitus',
                description = 'Ei ole sinun ajoneuvo',
                type = 'error'
            })
        end
    end, plate)
end


lib.addKeybind({
    name = 'toggleVehicleLock',
    description = 'Auton Lukitus',
    defaultKey = 'L',
    onPressed = function()
        handleVehicleLock()
    end
})