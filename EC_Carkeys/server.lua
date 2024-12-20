ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('doorlock:checkOwnership', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchScalar('SELECT 1 FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function(result)
        cb(result ~= nil)
    end)
end)