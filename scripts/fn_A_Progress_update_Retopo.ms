	-- Progress_update
	-- Update the Progressbar and Progressmessage
	-- barValue = [int] Value 0 - 100
	-- message = [string] Progress Message
	--*********************************************************************************************
	fn Progress_update_Retopo barValue message=
	(
		UV_Flatten.pb_UVFlatt.value = barValue;

		if UV_Flatten.lbl_progress.text != message do
		UV_Flatten.lbl_progress.text = message;
	)
