	-- Seaech Elements from Obejct
	-- objs = Object
	-- Return: List of Elements [Faces]
	--*********************************************************************************************
	fn SeaechElements obj=
	(
		ElementsList = #()
		if classof obj  == editable_poly do
			(
				facecount = polyop.getNumFaces obj
				while facecount != 0 do
				(
					if facecount < 0 do
						facecount = 0
					obj.EditablePoly.SetSelection #Face #{facecount}
					obj.selectElement()
					ElementSource = polyop.getFaceSelection obj as array
					append ElementsList ElementSource
					facecount = facecount - ElementSource.count
				)
			)
		return ElementsList
	)
	--*********************************************************************************************
