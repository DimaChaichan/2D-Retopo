--***************************************************--
--**					2D Retopo						 	**--
--***************************************************--
--**	Date: 18.0562013									**--
--**	Version: 0.1										**--
--**	Create by Demeter Chaichan						**--
--***************************************************-
--**				Installer								**--
--***************************************************--

rollout install "2D Retopo" width:261 height:256
(
	--Global Variablen
	--**********************************************************
	global Toolname = "DC_2D_Retopo"
	global Macroname = "DC 2D Retopo"
	global Iconname = "2D_Retopo"
	global Toolversion = "0_1"
	global UIfile = "2D_Retopo_UI.ms"
	global Startupfile = "2D_Retopo_Starter.ms"
	--**********************************************************

	-- Rollout Elements
	--**********************************************************
	button btn_install "Install" pos:[5,160] width:120 height:30
	button btn_uninstall "Uninstall" pos:[135,160] width:120 height:30 enabled:false
	GroupBox grp_picture "" pos:[5,1] width:250 height:102
	bitmap bmp_Logo "Bitmap" pos:[8,10] width:244 height:90 fileName:"Logo.jpg" bitmap:"Logo.jpg"
	progressBar pb_progress "" pos:[5,105] width:250 height:15
	label lbl_progress "Progress:" pos:[5,123] width:250 height:34
	GroupBox grp_info "Info" pos:[5,196] width:250 height:53
	label lbl_created "Created by Demeter Chaichan © 2013 ver." pos:[15,211] width:231 height:17
	HyperLink portfolio "For more tools visit my portfolio" pos:[60,227] width:200 height:15 color:(color 0 10 144) hovercolor:(color 144 0 0) address:"http://www.demeterchaichan.com"
	--**********************************************************

	--SUBFUNCTIONS
	--*********************************************************************************************
	--*********************************************************************************************

	-- Progress_update
	-- Update the Progressbar and Progressmessage
	-- barValue = [int] Value 0 - 100
	-- message = [string] Progress Message
	--*********************************************************************************************
	fn Progress_update barValue message=
	(
		install.pb_progress.value = barValue;
		install.lbl_progress.text = message;
	)

	-- Find_mzp_url
	-- Find the Mzp Url
	-- program = [string] Toolname
	-- version = [string] Toolversion (Format "0_1")
	-- return = Dir from mzp is forder dont´t found return False
	--*********************************************************************************************
	fn Find_mzp_url program version Switch_temp =
	(
	tempurl = sysInfo.tempdir as string;
	mzpfolders = getDirectories (tempurl+"mzptmp*");

	for i in mzpfolders do
	(
		checkforder = i + program + "_" + version
		print checkforder
		if doesFileExist checkforder do
		(
			if (Switch_temp == true) then
			(
				return i
			)
			else
			(
				return checkforder
			)
		)
	)
	return false
	)

	-- copy_installFiles
	-- Copy Installfiles to new Forder
	-- sourceUrl = [string] SourceUrl
	-- installUrl = [string] installUrl
	-- Foldername = [string] Foldername
	-- switch_icon = [bool] for icons copy
	-- retrun = Ok when found the InstallFiles, false when don´t found the InstallFiles
	--*********************************************************************************************
	fn copy_installFiles sourceUrl installUrl Foldername switch_icon =
	(
		if ( switch_icon == false) then
		(
			InstallFiles = getFiles (sourceUrl + "\\InstallFiles\\"+ Foldername +"\\*.ms");
		)else
		(
			InstallFiles = getFiles (sourceUrl + "\\InstallFiles\\"+ Foldername +"\\*.bmp");
		)

		if (InstallFiles.count != 0) then
		(
			if ( switch_icon == false) then
			(
			makeDir (installUrl + "\\" + Foldername +"\\");
			)
			x = 1;
			for file in InstallFiles do
				(
					Filename = filenameFromPath file;
					Progress_update ((100/InstallFiles.count) *  x) ("Copy " + Filename);

					if ( switch_icon == false) then
					(
						copyFile file (installUrl + "\\" + Foldername + "\\" + Filename);
					)
					else
					(
						copyFile file (installUrl + "\\" + Filename);
					)

					x +=1;
				)
			return ok;
		)
		else
		(
			return false;
		)
	)

	-- deleteInstallFiles
	-- Delete Intstall Files
	-- Delete_Toolname = [string] Toolname
	-- switch_icon = [bool] delete icons
	-- retrun = Ok when found the InstallFiles, false when don´t found the InstallFiles
	--*********************************************************************************************
	fn deleteFiles Delete_Toolname switch_icon=
	(
		if (switch_icon == 1) do
		(
			deletelFiles = getFiles (pathConfig.GetDir #usermacros + "\\" + Delete_Toolname + "*.mcr");
		)
		if (switch_icon == 2) do
		(
			deletelFiles = getFiles (pathConfig.GetDir #usericons + "\\" + Delete_Toolname + "*.bmp");
		)
		if (switch_icon == 3) do
		(
			deletelFiles = getFiles (pathConfig.GetDir #userScripts + "\\Startup\\" + Delete_Toolname);
		)

		if (deletelFiles.count != 0) then
		(
			x = 1;
			for file in deletelFiles do
				(
					Filename = filenameFromPath file;
					Progress_update ((100/deletelFiles.count) *  x) ("Delete " + Filename);
					deleteFile file;
					x += 1;
				)
			return ok;
		)
		else
		(
			return false;
		)
	)
	-- Delete Folder
	-- Delete a Folder
	-- folderPath: = [string] Forderpath (folderPath:"TEST\\TEST")
	--*********************************************************************************************
	fn deleteFolder folderPath: =
	(
		local sioDir = dotNetClass "System.IO.Directory"
		if (SIODir.Exists folderPath) do SIODir.Delete (folderPath) true
	)

	--*********************************************************************************************
	--*********************************************************************************************

	-- UI FUNCTIONS
	--*********************************************************************************************
	--*********************************************************************************************

	-- Close install
	--*********************************************************************************************
	on install close do
	(
		local url = Find_mzp_url Toolname Toolversion true;
		deleteFolder folderPath:url
	)

	-- Button Install
	--*********************************************************************************************
	on btn_install pressed do
	(
		installdir = pathConfig.GetDir #userScripts+"\\" +Toolname;
		icondir = pathConfig.GetDir #usericons;
		startupDir = pathConfig.GetDir #userScripts

		Progress_update 0 "Create Tools directory";
		local Installdir_check = makeDir installdir; -- create dir

		if (Installdir_check == true) then
		(
			local url = Find_mzp_url Toolname Toolversion false -- found mzpurl

			if (url != false) then
			(
				-- Copy Files
				--******************************************************************************
				copy_installFiles url installdir "ui" false; -- UI
				copy_installFiles url installdir "scripts" false; -- script
				copy_installFiles url icondir "usericons" true; -- icons
				copy_installFiles url startupDir "Startup" false -- startup
				--******************************************************************************

				install.btn_install.enabled = false;
				install.btn_uninstall.enabled = true;

				Progress_update 100 "Install complete! Is located under the Customize -> DC Tools -> DC 2D Retopo";

				colorman.reInitIcons() --relaod MacxUI
				fileIn (installdir + "\\ui\\" + UIfile)
				fileIn (startupDir + "\\Startup\\" + Startupfile)
			)
			else
			(
				Progress_update 0 "Can´t copy the Tools!";
			)
		)
		else
		(
			Progress_update 0 "Can´t create the Tool directory: ";
		)

	)

	-- Button Uninstall
	--*********************************************************************************************
	on btn_uninstall pressed do
	(
		uninstalldir = pathConfig.GetDir #userScripts +"\\" + Toolname;
		deleteFolder folderPath:uninstalldir
		Progress_update 100 ("Delete " + Toolname + " directory");
		deleteFiles Macroname 1
		deleteFiles Iconname 2
		deleteFiles Startupfile 3
		Progress_update 100 ("Delete complete!");
		install.btn_install.enabled = true;
		install.btn_uninstall.enabled = false;
	)
)

--  Creat Dialog "install"
--*****************************************
CreateDialog install modal:false escapeEnable:false style:#(#style_SysMenu, #style_ToolWindow);

-- Set Version
install.lbl_created.text = ("Created by Demeter Chaichan © 2013 ver." + Toolversion);

-- Check if installed
checkdir = pathConfig.GetDir #userScripts+"\\" + Toolname;
if doesFileExist checkdir do
(
	install.btn_install.enabled = false;
	install.btn_uninstall.enabled = true;
)


