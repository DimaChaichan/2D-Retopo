-- Creat all Macroscript
--*************************************************************************************************
--*************************************************************************************************
	-- Load all Functions
	--*************************************************************************************************
	scriptsDir = ((pathConfig.GetDir #userScripts) + "\\DC_2D_Retopo\\scripts\\");
	getScripts = getFiles ( scriptsDir + "*.ms")
	for f in getScripts do
	(
		fileIn f
	)
	scriptsDir = ((pathConfig.GetDir #userScripts) + "\\DC_2D_Retopo\\ui\\");
	getScripts = getFiles ( scriptsDir + "*.ms")
	for f in getScripts do
	(
		fileIn f
	)
	--*************************************************************************************************