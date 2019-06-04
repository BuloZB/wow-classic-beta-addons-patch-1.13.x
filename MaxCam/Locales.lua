local _, S = ...

local L = {
	enUS = {
		CURRENT_DISTANCE = "Current Distance",
		ZOOM_INCREMENT = "Zoom Increment",
		ZOOM_SPEED = "Zoom "..SPEED,
	},
	deDE = {
		--CURRENT_DISTANCE = "Entfernung",
		ZOOM_INCREMENT = "Zoomschritt",
		ZOOM_SPEED = "Zoomgeschwindigkeit",
	},
	esES = {
		ZOOM_INCREMENT = "Incremento Zoom",
		ZOOM_SPEED = "Velocidad Zoom",
	},
	--esMX = {},
	frFR = {
	},
	itIT = {
	},
	koKR = {
		--CURRENT_DISTANCE = "거리",
		ZOOM_INCREMENT = "줌 증가량",
		ZOOM_SPEED = "줌 속도",
	},
	ptBR = {
		ZOOM_INCREMENT = "Zoom Aumento",
		ZOOM_SPEED = "Zoom Velocidade",
	},
	ruRU = {
		--CURRENT_DISTANCE = "Дистанция",
		ZOOM_INCREMENT = "Шаг увеличения",
		ZOOM_SPEED = "Скорость увеличения",
	},
	zhCN = {
		--CURRENT_DISTANCE = "距离",
		ZOOM_INCREMENT = "缩放增量",
		ZOOM_SPEED = "缩放速度",
	},
	zhTW = {
		--CURRENT_DISTANCE = "距離",
		ZOOM_INCREMENT = "縮放增量",
		ZOOM_SPEED = "縮放速度",
	},
}

L.esMX = L.esES -- esMX is empty

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
