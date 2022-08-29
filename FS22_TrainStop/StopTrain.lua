-- Title: TrainStop",
-- Notes: TrainStop",
-- Author: [LSMT]19BlueDragon83",
-- Version: 1.0.0.0",
-- Date: 26.11.2021", 
-- Web: https://forum.ls-mapping-team.de/";;

local stopTrain = {}


function stopTrain:getstartAutomatedTrainTravel(superFunc)
    return false;
end;

Locomotive.startAutomatedTrainTravel = Utils.overwrittenFunction(Locomotive.startAutomatedTrainTravel, stopTrain.getstartAutomatedTrainTravel);



if Locomotive.getstartAutomatedTrainTravel == true then
self:setLocomotiveState(Locomotive.STATE_MANUAL_TRAVEL_ACTIVE)
self:stopMotor() 
end;
