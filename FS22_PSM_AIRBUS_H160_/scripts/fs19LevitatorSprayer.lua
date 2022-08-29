--[[
/*******************************************************************************\
*                                                                               *
* LevitatorSprayer.lua                                                                 *
*                                                                               *
*********************************************************************************
* Licensed under the MIT or X11 License                                         *
*                                                                               *
* Copyright (c) 2016 Eisbearg                                                   *
*                                                                               *
* Permission is hereby granted, free of charge, to any person obtaining a copy  *
* of this software and associated documentation files (the "Software"), to deal *
* in the Software without restriction, including without limitation the rights  *
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     *
* copies of the Software, and to permit persons to whom the Software is         *
* furnished to do so, subject to the following conditions:                      *
*                                                                               *
* The above copyright notice and this permission notice shall be included in    *
* all copies or substantial portions of the Software.                           *
*                                                                               *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, *
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN     *
* THE SOFTWARE.                                                                 *
\*******************************************************************************/
--]]
-- Edit FS17: werik, Silak_68
--28.05.17 network edition by igor29381
--Edit port to FS19: Zippyo v0.99b


LevitatorSprayer = {};

LevitatorSprayer._NAME			= "LevitatorSprayer"
LevitatorSprayer.title = "FS22_AIRBUS_H160_TFSG";
LevitatorSprayer.author = "Lezzy fly script by Zippyo";
LevitatorSprayer.modDirectory  = g_currentModDirectory;

function LevitatorSprayer.prerequisitesPresent(specializations)
	return true;
	end;

function LevitatorSprayer.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "mouseEvent", LevitatorSprayer.mouseEvent)
    SpecializationUtil.registerFunction(vehicleType, "keyEvent", LevitatorSprayer.keyEvent)
    SpecializationUtil.registerFunction(vehicleType, "activateFlightMode", LevitatorSprayer.activateFlightMode)
    SpecializationUtil.registerFunction(vehicleType, "deactivateFlightMode", LevitatorSprayer.deactivateFlightMode)
    SpecializationUtil.registerFunction(vehicleType, "toggleLevitatorSprayer", LevitatorSprayer.toggleLevitatorSprayer)
    SpecializationUtil.registerFunction(vehicleType, "getMorldDirectionDegree", LevitatorSprayer.getMorldDirectionDegree)
    SpecializationUtil.registerFunction(vehicleType, "getMorldDirectionDegree2", LevitatorSprayer.getMorldDirectionDegree2)
    SpecializationUtil.registerFunction(vehicleType, "getMorldDirectionDegree3", LevitatorSprayer.getMorldDirectionDegree3)
    SpecializationUtil.registerFunction(vehicleType, "getAltitude", LevitatorSprayer.getAltitude)
    SpecializationUtil.registerFunction(vehicleType, "getTailForce", LevitatorSprayer.getTailForce)
    SpecializationUtil.registerFunction(vehicleType, "updateMovement", LevitatorSprayer.updateMovement)
  --SpecializationUtil.registerFunction(vehicleType, "saveToXMLFile", LevitatorSprayer.saveToXMLFile)
end;

function LevitatorSprayer.registerEventListeners(vehicleType)
	for _, functionName in pairs( { "onLoad", "onPostLoad", "onUpdate", "onUpdateTick", "onDraw", "saveToXMLFile" } ) do
		SpecializationUtil.registerEventListener(vehicleType, functionName, LevitatorSprayer);
	end;
end;

function LevitatorSprayer:onLoad(savegame)
    self.isSelectable = true;
  --  self.toggleLevitatorSprayer = SpecializationUtil.callSpecializationsFunction("toggleLevitatorSprayer");
	self.LevitatorSprayer = {};

 --   local name = getXMLString(self.xmlFile, "vehicle.storeData.name");
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.en"); end;
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.de"); end;
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.es"); end;
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.fr"); end;
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.pt"); end;
  --  if name == nil then name = getXMLString(self.xmlFile, "vehicle.storeData.name.ru"); end;
    if name == nil then name = "UnknownVehicle"; end;

    self.LevitatorSprayer.id = LevitatorSprayer._NAME;
    self.LevitatorSprayer.name = name;
    self.LevitatorSprayer.move = false;
    self.LevitatorSprayer.active = false;
    self.LevitatorSprayer.downForce = 0;
    self.LevitatorSprayer.yForce = 0;
    self.LevitatorSprayer.pitch = 0;
    self.LevitatorSprayer.sendPitch = 0;
    self.LevitatorSprayer.startTimer = 0;
    self.LevitatorSprayer.levitatorSprayerFlag = self:getNextDirtyFlag();
    self.LevitatorSprayer.lastDigitalSide = 0;
	self.workAreaPositions = {};
	local lworkAreas = self.spec_workArea.workAreas[1]
	for k,c in pairs (self.spec_workArea) do
       local xs,ys,zs = getWorldTranslation(lworkAreas.start);
       local xw,yw,zw = getWorldTranslation(lworkAreas.width);
       local xh,yh,zh = getWorldTranslation(lworkAreas.height);
       local cap = {};
       cap.start = {xs,ys,zs};
       cap.width = {xw,yw,zw};
       cap.height = {xh,yh,zh};
       table.insert(self.workAreaPositions, cap);
   end;

      self.pipeGrainParticleSystem = {};
--    self.pipeGrainParticleSystemindex = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.pipeGrainParticleSystem#index"));
--    Utils.loadParticleSystem(self.xmlFile, self.pipeGrainParticleSystem, "vehicle.pipeGrainParticleSystem", self.pipeGrainParticleSystemindex, false, nil, self.baseDirectory);
--    self.pipeGrainParticleSystem2 = {};
--    self.pipeGrainParticleSystem2index = Utils.indexToObject(self.components, getXMLString(self.xmlFile, "vehicle.pipeGrainParticleSystem2#index"));
--    Utils.loadParticleSystem(self.xmlFile, self.pipeGrainParticleSystem2, "vehicle.pipeGrainParticleSystem2", self.pipeGrainParticleSystem2index, false, nil, self.baseDirectory);
	print("Load mod: '"..LevitatorSprayer.title.."' by: '"..LevitatorSprayer.author.."' loaded sucessfully.");
end;

function LevitatorSprayer:onDelete()
--    Utils.deleteParticleSystem(self.pipeGrainParticleSystem);
--    Utils.deleteParticleSystem(self.pipeGrainParticleSystem2);
end;

function LevitatorSprayer:mouseEvent(posX, posY, isDown, isUp, button)
end;

function LevitatorSprayer:keyEvent(unicode, sym, modifier, isDown)
end;

function LevitatorSprayer:activateFlightMode()
	local component = self.components[1]
    local massresult = self:getTotalMass(true)
		setLinearDamping(component.node, 0.15);
		setAngularDamping(component.node, 0.01);
		self.LevitatorSprayer.downForce = massresult * -9.81; 
        self.massresult = massresult *1000;
		self.yForce = self.LevitatorSprayer.downForce * -5;
--    self.cruiseControl.average = (self.cruiseControl.minSpeed + self.cruiseControl.maxSpeed);
--    self.setCruiseControlMaxSpeed(self, self.cruiseControl.average);
end;

function LevitatorSprayer:deactivateFlightMode()
	local component = self.components[1]
		setLinearDamping(component.node, 0.0); 
		setAngularDamping(component.node, 0.01);
		self.LevitatorSprayer.downForce = self:getTotalMass(true) * -9.81;
		self.yForce = 0;
--    self.cruiseControl.average = (self.cruiseControl.minSpeed + self.cruiseControl.maxSpeed);
--    self.setCruiseControlMaxSpeed(self, self.cruiseControl.average);
end;

function LevitatorSprayer:onPostLoad(savegame)
--[[
]]
end;

function LevitatorSprayer:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local massresult = (self:getTotalMass(false)) * 1000
        self.massresult = massresult

    local component = self.components[1]
    local altAboveGround, altAboveNN = self.getAltitude(component.node); 
	
    if self.getIsMotorStarted and altAboveGround < 4 then
--        Utils.setEmittingState(self.pipeGrainParticleSystem, true);
    else
--        Utils.setEmittingState(self.pipeGrainParticleSystem, false);
    end;
    if self.getIsMotorStarted and altAboveGround < 9 then
--        Utils.setEmittingState(self.pipeGrainParticleSystem2, true);
    else
--        Utils.setEmittingState(self.pipeGrainParticleSystem2, false);
    end;

    if self.spec_motorized.isMotorStarted and self.spec_enterable.isEntered then
        if not self.LevitatorSprayer.active then
            self.LevitatorSprayer.startTimer = self.LevitatorSprayer.startTimer + dt;
            if self.LevitatorSprayer.startTimer > 9000 then
                LevitatorSprayer.activateFlightMode(self);
                self.LevitatorSprayer.active = true;
                self.wiper = true;
                self.LevitatorSprayer.startTimer = 0;
            end;
        end;
    elseif self.LevitatorSprayer.active then
        LevitatorSprayer.deactivateFlightMode(self);
        self.LevitatorSprayer.active = false;
        self.wiper = false;
    end;
    if not self.LevitatorSprayer.active then return end; 
local collectiveup = getInputAxis(10, 0);
local collectivedown = getInputAxis(11, 0);
local gamepads = getNumOfGamepads();
self.normalizedCollectiveUp = (collectiveup - (-1)) / (1 - (-1));
self.normalizedCollectiveDown = (collectivedown - (-1)) / (1 - (-1));
LevitatorSprayer.updateMovement(self, dt);
    if self.isActive and isActiveForInput then
		if gamepads>0 then
			if collectiveup <= 1 or collectivedown <= 1 then
            if collectiveup < 1 then
                self.LevitatorSprayer.pitch = math.min(self.LevitatorSprayer.pitch + 1/self.normalizedCollectiveUp/3, self.LevitatorSprayer.downForce * -0.85);
            end;
            if collectivedown < 1 then
                self.LevitatorSprayer.pitch = math.max(self.LevitatorSprayer.pitch - 1/self.normalizedCollectiveDown/5, -25.02);
            end;
			end;
		end;
------CHECK MOUSE----------------------
if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT) or Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT)then
            if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_LEFT)then
                self.LevitatorSprayer.pitch = math.min(self.LevitatorSprayer.pitch + 3, 15);
            end;
            if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT)then
                self.LevitatorSprayer.pitch = math.max(self.LevitatorSprayer.pitch - 3, -20); 
            end;
       elseif self.LevitatorSprayer.pitch ~= 0 then
if collectiveup == 1 and collectivedown == 1 then 
              self.LevitatorSprayer.pitch = 0; 
           end; 
        end;
	end;
        if self.LevitatorSprayer.pitch ~= self.LevitatorSprayer.sendPitch then
            if not g_server then
                self:raiseDirtyFlags(self.levitatorSprayerFlag);
            end;
            self.LevitatorSprayer.sendPitch = self.LevitatorSprayer.pitch;
        end;
        if self.LevitatorSprayer.pitch ~= self.LevitatorSprayer.sendPitch then
            if not g_server then
                self:raiseDirtyFlags(self.levitatorSprayerFlag);
            end;
            self.LevitatorSprayer.sendPitch = self.LevitatorSprayer.pitch;
        end;
    if self.isServer then
        local dX,dY,dZ = localDirectionToWorld(component.node, 1, 0, 0);
        local sinDir = dX / 15;
        local cosDir = dZ / -15;
        self.sd = 307;
        if self.spec_motorized.getIsMotorStarted then
            self.sd = 400; --controls air speed
        end;
        local zSteer = self.sd * self.spec_drivable.axisForward;
        local xForce = zSteer * cosDir;
        local zForce = zSteer * sinDir;
        if self.spec_drivable.axisForward == 1 or self.spec_drivable.axisForward == -1 or self.spec_drivable.lastDigitalForward == 1 or self.spec_drivable.lastDigitalForward == -1  then
            dg = 1.35; --controls pitch (set close to mod's center of mass
        else
            dg = 3; 
        end;
        local component = self.components[1]
                self.LevitatorSprayer.yForce = (self.LevitatorSprayer.pitch + self.LevitatorSprayer.downForce * -0.84222);
                addForce(component.node, xForce, self.LevitatorSprayer.yForce,  zForce, 0, dg, 0, true); 
        local yTurnSpeed = 0;
        if self.spec_drivable.axisSide > 0.01 or self.spec_drivable.axisSide < -0.01 or self.spec_drivable.lastDigitalSide > 0.01 or self.spec_drivable.lastDigitalSide < -0.01  then
            if InputBinding.getIsAnalogInput then
                yTurnSpeed = self.spec_drivable.axisSide * -1.0;
            else
                yTurnSpeed = self.spec_drivable.lastDigitalSide * -1.0;
            end;
        end;

        local AVx, AVy, AVz = getAngularVelocity(component.node);
        if yTurnSpeed == 0 then
           yTurnSpeed = AVy * 0.85;
        end;
        setAngularVelocity(component.node, AVx * 0.75, yTurnSpeed, AVz * 0.75);
        self.yLV = getLinearVelocity(component.node);
        if self.getIsActive and self.getIsTurnedOn then
            local altAboveGround = self.getAltitude(component.node);
            local addw = altAboveGround*6.5;
            local addh = altAboveGround/5;
            local addz = (altAboveGround/2) + (self.lastSpeed * 3850/50);
            local lworkAreas = self.spec_workArea.workAreas[1]
            for c=1, table.getn(lworkAreas) do
                local cp = self.workAreaPositions[c];
                local ca = lworkAreas[c];
                setTranslation(ca.start ,  cp.start[1]+ (cp.start[1] *addw/100) , cp.start[2]  , cp.start[3]- addz);
                setTranslation(ca.width ,  cp.width[1]+ (cp.width[1] *addw/100) , cp.width[2]  , cp.width[3]- addz);
                if altAboveGround > 50 then
                    setTranslation(ca.height , cp.start[1]+(cp.start[1]*addw/100) , cp.start[2] , cp.start[3] - addz);
                else
                    setTranslation(ca.height , cp.height[1]+(cp.height[1]*addw/100) , cp.height[2] , cp.height[3]-addz-addh);
                end;
            end;
        end;
    end;
end;

function LevitatorSprayer:onUpdateTick(dt)
end;

function LevitatorSprayer:saveToXMLFile(xmlFile, key)
--[[ key includes the name of the script
]]
end;

function LevitatorSprayer:onDraw()
    local component = self.components[1]
    local text = g_i18n.modEnvironments.FS22_AIRBUS_H160_TFSG.texts.move --just digging...should b fetched from XML as :getText("move")
	local text1 = g_i18n.modEnvironments.FS22_AIRBUS_H160_TFSG.texts.move1 --just digging...should b fetched from XML as :getText("move")
    local LVx, LVy, LVz = getLinearVelocity(component.node);
    if self.spec_enterable.getIsEntered then

        setTextAlignment(RenderText.ALIGN_CENTER);
        setTextColor(1,1,1,1);
        if self.LevitatorSprayer.active then
		    renderText(0.17, 0.29, 0.016, text);
			renderText(0.17, 0.27, 0.016, text1);
		    renderText(0.17, 0.31, 0.016, string.format(g_i18n:getText("VSI") .. " %4.2f m/s", LVy));
			local altAboveGround, altAboveNN = self.getAltitude(component.node);
            renderText(0.17, 0.33, 0.016, string.format(g_i18n.modEnvironments.FS22_AIRBUS_H160_TFSG.texts.ground .. " %4.2f m", altAboveGround));
            --renderText(0.17, 0.33, 0.025, string.format("A G L=" .. " %4.2f m", altAboveGround));
            --renderText(0.17, 0.26, 0.016, string.format("BLADE PITCH" .. " %3.4f ", self.LevitatorSprayer.pitch));
            --renderText(0.17, 0.24, 0.016, string.format("pretend G Downforce" .. " %4.2f m/s", self.LevitatorSprayer.downForce));
            --renderText(0.17, 0.22, 0.016, string.format("LevitatorFORCE" .. " %4.2f m/s", self.LevitatorSprayer.yForce));
            --renderText(0.17, 0.20, 0.016, string.format("MASS" .. " %4.2f kg", self.massresult));
            setTextBold(false);
        end;

        setTextAlignment(RenderText.ALIGN_LEFT);
        setTextColor(1,1,1,1);
    end;
--            local altAboveGround = self.getAltitude(component.node);
--        if self.isActive and altAboveGround > 50 then
--        g_currentMission:showBlinkingWarning(g_i18n.modEnvironments.FS22_AIRBUS_H160_TFSG.texts.helpGrid, 600);
--    end;
end;
function LevitatorSprayer:toggleLevitatorSprayer(state, nes)
end;

function LevitatorSprayer:readStream(streamId, connection)
end;

function LevitatorSprayer:writeStream(streamId, connection)
end;

function LevitatorSprayer:getMorldDirectionDegree(rootNode)
    local dX,dY,dZ = localDirectionToWorld(rootNode, 0, 0, 1);
    local sinus = dX / 1;
    local cosinus = dZ / 1;
    local direction = math.deg(math.atan2(sinus, cosinus));
    return direction, sinus, cosinus;
end;

function LevitatorSprayer:getMorldDirectionDegree2(rootNode)
    local dX,dY,dZ = localDirectionToWorld(rootNode, 0, 0, 1);
    local sinus = dX / 1;
    local cosinus = dZ / 1;
    local direction = math.deg(math.atan2(cosinus, sinus));
    return direction, sinus, cosinus;
end;

function LevitatorSprayer:getMorldDirectionDegree3(rootNode)
    local dX,dY,dZ = localDirectionToWorld(rootNode, 0, 0, -1);
    local sinus = dX / 1;
    local cosinus = dZ / 1;
    local direction = math.deg(math.atan2(cosinus, sinus));
    return direction, sinus, cosinus;
end;

function LevitatorSprayer:getAltitude(rootNode)
    local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, getWorldTranslation(self));
    local x, altAboveNN = getWorldTranslation(self);
    local altAboveGround = altAboveNN - terrainHeight;
    if altAboveGround < 0 then altAboveGround = 0.0 end; 
    return altAboveGround, altAboveNN, terrainHeight;
end;

function LevitatorSprayer:getTailForce(rootNode, xSteer)
        local dX,dY,dZ = localDirectionToWorld(self, 0, 0, -1);
        local sinDir = dX / 1;
        local cosDir = dZ / 1;
        local xBackward = 10 * sinDir;
        local zBackward = 10 * cosDir;

        dX,dY,dZ = localDirectionToWorld(rootNode, 1, 0, 0);
        sinDir = dX / 1;
        cosDir = dZ / 1;
        local xTurnForce = xSteer * sinDir;
        local zTurnForce = xSteer * cosDir;

    return xTurnForce, 0, zTurnForce, xBackward, 0.6, zBackward
end;

function LevitatorSprayer:updateMovement(dt)
self.axisSideIsAnalog = InputBinding.getIsAnalogInput
self.axisForwardIsAnalog = InputBinding.getIsAnalogInput
		if not self.getIsEntered then return; end
		local axisAccelerate = self.spec_drivable.lastInputValues.axisAccelerate                 
		local axisBrake = self.spec_drivable.lastInputValues.axisBrake
		local axisForward = MathUtil.clamp((axisAccelerate - axisBrake)*0.5, -1, 1);
		
		if InputBinding.isAxisZero(axisForward) then
			axisAccelerate = self.spec_drivable.lastInputValues.axisAccelerate
			axisBrake = self.spec_drivable.lastInputValues.axisBrake
			self.axisForward = MathUtil.clamp((axisAccelerate - axisBrake)*0.5, -1, 1);
fetch = self.axisForward
        if not InputBinding.isAxisZero(self.axisForward) then
            self.axisForwardIsAnalog = true;
        end
        self.lastDigitalForward = 0;
    end
    self.axisSide = self.spec_drivable.lastInputValues.axisSide
    if InputBinding.isAxisZero(self.axisSide) then
        self.axisSide = self.spec_drivable.lastInputValues.axisSide
        if not InputBinding.isAxisZero(self.axisSide) then
            self.axisSideIsAnalog = true;
        end
        self.lastDigitalSide = 0;
    else
        self.axisSide = MathUtil.clamp(self.lastDigitalSide + dt/self.axisSmoothTime*self.axisSide, -1, 1);
        self.axisSideIsAnalog = false;
        self.lastDigitalSide = self.axisSide;
    end;

     if not self.getIsActiveForInput then
        if not self.axisSideIsAnalog then
            self.axisSide = 0;
        end
        if not self.axisForwardIsAnalog then
            self.axisForward = 0;
        end
    end;
    if not g_server then
        self:raiseDirtyFlags(self.levitatorSprayerFlag);
    end;
end;