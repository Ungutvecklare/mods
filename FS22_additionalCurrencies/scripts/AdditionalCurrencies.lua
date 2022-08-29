--
-- AdditionalCurrencies
--
-- @author Rockstar
-- @date 10/02/2021
--

--
--	@fs22 22/11/2021
--


AdditionalCurrencies = {
	MOD_NAME = g_currentModName,
	MOD_SETTINGS_DIRECTORY = g_currentModSettingsDirectory,
	CONFIG_FILENAME = g_currentModDirectory .. "xml/currencies.xml",
}

local global_i18n = getmetatable(g_i18n).__index

function AdditionalCurrencies:loadMap(filename)
	createFolder(AdditionalCurrencies.MOD_SETTINGS_DIRECTORY)
	copyFile(AdditionalCurrencies.CONFIG_FILENAME, AdditionalCurrencies.MOD_SETTINGS_DIRECTORY .. "currencies.xml", false)

	local gameInfoDisplay = g_currentMission.hud.gameInfoDisplay

	self.defaultMaxDisplayValue = I18N.MONEY_MAX_DISPLAY_VALUE
	self.defaultMoneyBoxWidth = gameInfoDisplay.moneyBox:getWidth()
	self.defaultMoneyTextWidth = getTextWidth(gameInfoDisplay.moneyTextSize, g_i18n:formatNumber(self.defaultMaxDisplayValue))

	local configFilename = AdditionalCurrencies.MOD_SETTINGS_DIRECTORY .. "currencies.xml"

	if not fileExists(configFilename) then
		configFilename = AdditionalCurrencies.CONFIG_FILENAME
	end

	local currencies, texts = self:loadCurrenciesFromXMLFile(configFilename, g_settingsScreen.settingsModel:getMoneyUnitTexts())

	self.currencies = currencies

	local pageSettingsGeneral = g_currentMission.inGameMenu.pageSettingsGeneral
	local moneyUnitElement = pageSettingsGeneral.multiMoneyUnit

	pageSettingsGeneral.optionMapping[moneyUnitElement] = nil
	moneyUnitElement.onClickCallback = self.onClickMoneyUnit

	pageSettingsGeneral.onFrameClose = Utils.appendedFunction(pageSettingsGeneral.onFrameClose, self.onFrameClose_inj)

	FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, self.saveToXMLFile_inj)

	global_i18n.getCurrencySymbol = Utils.overwrittenFunction(global_i18n.getCurrencySymbol, self.getCurrencySymbol_inj)
	global_i18n.formatMoney = Utils.overwrittenFunction(global_i18n.formatMoney, self.formatMoney_inj)

	gameInfoDisplay.drawMoneyText = Utils.overwrittenFunction(gameInfoDisplay.drawMoneyText, self.drawMoneyText_inj)
	gameInfoDisplay.setMoneyUnit = Utils.overwrittenFunction(gameInfoDisplay.setMoneyUnit, self.setMoneyUnit_inj)

	local state, useConverter = self:loadCurrencyStateFromXMLFile(g_gameSettings:getValue(GameSettings.SETTING.MONEY_UNIT), true)

	moneyUnitElement:setState(state)
	moneyUnitElement:setTexts(texts)

	self.checkCurrencyConverter = self:createCurrencyConverterElement(pageSettingsGeneral)
	self.checkCurrencyConverter:setIsChecked(useConverter)

	self.useConverter = useConverter
	self:setMoneyUnit(state)
end

function AdditionalCurrencies:loadCurrenciesFromXMLFile(xmlFilename, defaultTexts)
	local currencies = {}
	local texts = defaultTexts

	local currenciesXML = XMLFile.loadIfExists("currenciesXML", xmlFilename, "currencies")

	if currenciesXML == nil then
		return currencies, texts
	end

	currencies[1] = {prefix = false, factor = currenciesXML:getFloat("currencies#euroFactor", 1), maxDisplayValue = self.defaultMaxDisplayValue, isDefaultCurrency = true}
	currencies[2] = {prefix = true, factor = currenciesXML:getFloat("currencies#dolarFactor", 1.34), maxDisplayValue = self.defaultMaxDisplayValue, isDefaultCurrency = true}
	currencies[3] = {prefix = true, factor = currenciesXML:getFloat("currencies#poundFactor", 0.79), maxDisplayValue = self.defaultMaxDisplayValue, isDefaultCurrency = true}

	local i = 0

	while true do
		local key = string.format("currencies.currency(%d)", i)

		if not currenciesXML:hasProperty(key) then
			break
		end

		local unit = currenciesXML:getI18NValue(key .. "#text", "", AdditionalCurrencies.MOD_NAME, true)
		local unitShort = currenciesXML:getI18NValue(key .. "#symbol", "", AdditionalCurrencies.MOD_NAME, true)
		local prefix = currenciesXML:getBool(key .. "#prefixSymbol", true)
		local factor = currenciesXML:getFloat(key .. "#factor", 1)
		local maxDisplayValue = currenciesXML:getString(key .. "#maxDisplayValue", self.defaultMaxDisplayValue)
		local iconScale = currenciesXML:getFloat(key .. "#iconScale")
		local yOffset = currenciesXML:getFloat(key .. "#yOffset")

		if yOffset ~= nil and yOffset ~= 0 then
			yOffset = yOffset * g_gameSettings:getValue("uiScale")
		end

		table.insert(texts, unit)
		table.insert(currencies, {unit = unit, unitShort = unitShort, prefix = prefix, factor = factor, maxDisplayValue = tonumber(maxDisplayValue), iconScale = iconScale, yOffset = yOffset, isDefaultCurrency = false})

		i = i + 1
	end

	currenciesXML:delete()

	return currencies, texts
end

function AdditionalCurrencies:loadCurrencyStateFromXMLFile(state, useConverter)
	local xmlFilename = AdditionalCurrencies.MOD_SETTINGS_DIRECTORY .. "currencyState.xml"
	local currencyXML = XMLFile.loadIfExists("currencyXML", xmlFilename, "currencyState")

	if currencyXML == nil then
		return state, useConverter
	end

	local currency = currencyXML:getInt("currencyState.currency", state)

	if currency <= #self.currencies then
		state = currency
	end

	useConverter = currencyXML:getBool("currencyState.useConverter", useConverter)

	currencyXML:delete()

	return state, useConverter
end

function AdditionalCurrencies:saveCurrencyStateToXMLFile()
	local xmlFilename = AdditionalCurrencies.MOD_SETTINGS_DIRECTORY .. "currencyState.xml"
	local currencyXML = XMLFile.create("currencyXML", xmlFilename, "currencyState")

	if currencyXML == nil then
		return
	end

	currencyXML:setInt("currencyState.currency", self.state)
	currencyXML:setBool("currencyState.useConverter", self.useConverter)
	currencyXML:save()
	currencyXML:delete()

	return true
end

function AdditionalCurrencies:createCurrencyConverterElement(pageSettingsGeneral)
	local checkUseMiles = pageSettingsGeneral.checkUseMiles
	local parent = checkUseMiles.parent
	local checkCurrencyConverter = checkUseMiles:clone(pageSettingsGeneral)

	checkCurrencyConverter.id = "checkCurrencyConverter"
	checkCurrencyConverter.focusId = nil

	checkCurrencyConverter.elements[4]:setText(g_i18n:getText("setting_currencyConverter"))
	checkCurrencyConverter.elements[6]:setText(g_i18n:getText("toolTip_currencyConverter"))

	checkCurrencyConverter.onClickCallback = function (target, state)
		self.useConverter = state == CheckedOptionElement.STATE_CHECKED
		self:updateTextsAndMoneyBoxWidth()
	end

	local currentGui = FocusManager.currentGui

	FocusManager:setGui("ingameMenuGameSettingsGeneral")
	FocusManager:loadElementFromCustomValues(checkCurrencyConverter)
	FocusManager:setGui(currentGui)

	checkCurrencyConverter.parent:removeElement(checkCurrencyConverter)
	table.insert(parent.elements, table.findListElementFirstIndex(parent.elements, pageSettingsGeneral.multiMoneyUnit, #parent.elements) + 1, checkCurrencyConverter)
	checkCurrencyConverter.parent = parent

	pageSettingsGeneral.checkCurrencyConverter = checkCurrencyConverter

	return checkCurrencyConverter
end

function AdditionalCurrencies:getCurrentCurrency()
	return self.currencies[self.state]
end

function AdditionalCurrencies:updateTextsAndMoneyBoxWidth()
	for _, name in pairs({"button_borrow5000", "button_repay5000", "helpLine_basicEconomy_makingMoney_finances", "hint_17"}) do
		global_i18n:setText(name, string.format(g_i18n:getText("additionalCurrencies_global_" .. name), g_i18n:formatMoney(5000)))
	end

	local maxDisplayValue = self.defaultMaxDisplayValue

	if self.useConverter then
		maxDisplayValue = self:getCurrentCurrency().maxDisplayValue
	end

	if maxDisplayValue ~= nil and maxDisplayValue ~= I18N.MONEY_MAX_DISPLAY_VALUE then
		I18N.MONEY_MAX_DISPLAY_VALUE, I18N.MONEY_MIN_DISPLAY_VALUE = maxDisplayValue, -maxDisplayValue

		local gameInfoDisplay = g_currentMission.hud.gameInfoDisplay
		local maxMoneyTextWidth = getTextWidth(gameInfoDisplay.moneyTextSize, g_i18n:formatNumber(maxDisplayValue))
		local extraWidth = maxMoneyTextWidth - self.defaultMoneyTextWidth

		gameInfoDisplay.moneyBox.overlay.width = self.defaultMoneyBoxWidth + extraWidth
		gameInfoDisplay:storeScaledValues()
		gameInfoDisplay:updateSizeAndPositions()
	end
end

function AdditionalCurrencies:setMoneyUnit(state)
	self.state = state

	global_i18n:setMoneyUnit(state)
	g_currentMission:setMoneyUnit(state)

	self:updateTextsAndMoneyBoxWidth()
	self.checkCurrencyConverter:setDisabled(self:getCurrentCurrency().factor == 1)
end

function AdditionalCurrencies.getCurrencySymbol_inj(i18n, superFunc, useShort)
	local currency = AdditionalCurrencies:getCurrentCurrency()

	if currency.isDefaultCurrency then
		return superFunc(i18n, useShort)
	else
		local text = currency.unit

		if useShort then
			text = currency.unitShort
		end

		return text
	end
end

function AdditionalCurrencies.formatMoney_inj(i18n, superFunc, number, precision, addCurrency, prefixCurrencySymbol)
	local currency = AdditionalCurrencies:getCurrentCurrency()

	if addCurrency == nil or addCurrency then
		prefixCurrencySymbol = currency.prefix
	end

	if AdditionalCurrencies.useConverter and currency.factor ~= 1 then
		number = number * currency.factor
	end

	return superFunc(i18n, number, precision, addCurrency, prefixCurrencySymbol)
end

function AdditionalCurrencies.onFrameClose_inj(pageSettingsGeneral)
	AdditionalCurrencies:saveCurrencyStateToXMLFile()
end

function AdditionalCurrencies.saveToXMLFile_inj(careerMissionInfo)
	AdditionalCurrencies:saveCurrencyStateToXMLFile()
end

function AdditionalCurrencies.drawMoneyText_inj(gameInfoDisplay, superFunc)
	setTextBold(false)
	setTextAlignment(RenderText.ALIGN_RIGHT)
	setTextColor(unpack(GameInfoDisplay.COLOR.TEXT))

	if g_currentMission.player ~= nil then
		local farm = g_farmManager:getFarmById(g_currentMission.player.farmId)
		local moneyText = g_i18n:formatMoney(farm.money, 0, false, true)

		renderText(gameInfoDisplay.moneyTextPositionX, gameInfoDisplay.moneyTextPositionY, gameInfoDisplay.moneyTextSize, moneyText)
	end

	local currency = AdditionalCurrencies:getCurrentCurrency()
	local currencyIconSize = gameInfoDisplay.moneyTextSize
	local currencyPositionY = gameInfoDisplay.moneyCurrencyPositionY

	if currency.iconScale ~= nil and currency.iconScale ~= 1 then
		currencyIconSize = currencyIconSize * currency.iconScale
	end

	if currency.yOffset ~= nil and currency.yOffset ~= 0 then
		currencyPositionY = currencyPositionY + currency.yOffset
	end

	setTextAlignment(RenderText.ALIGN_CENTER)
	setTextColor(unpack(GameInfoDisplay.COLOR.ICON))
	renderText(gameInfoDisplay.moneyCurrencyPositionX, currencyPositionY, currencyIconSize, gameInfoDisplay.moneyCurrencyText)
end

function AdditionalCurrencies.setMoneyUnit_inj(gameInfoDisplay, superFunc, moneyUnit)
	gameInfoDisplay.moneyUnit = moneyUnit
	gameInfoDisplay.moneyCurrencyText = g_i18n:getCurrencySymbol(true)
end

function AdditionalCurrencies.onClickMoneyUnit(moneyUnitElement, state, optionElement)
	AdditionalCurrencies:setMoneyUnit(state)
end

addModEventListener(AdditionalCurrencies)