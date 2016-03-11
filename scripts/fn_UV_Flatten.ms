	-- UV_Flatten
	-- Create a 3D Modell from UV Chucks
	-- obj_UV = Object
	--*********************************************************************************************
	fn _UV_2D3D_Flatten obj_UV epname MapScale Morph_value=
	(
		--Variables 
		Vertexlist = #()

		select obj_UV
		-- Select all Vertices 
		subobjectLevel = 1
		max select all
		VertexCount = polyop.getNumVerts obj_UV
		AllVerticesArray  = (polyop.getVertSelection obj_UV) as array
		Vertexpos  = for x = 1 to VertexCount collect (polyop.getMapVert obj_UV 1 x)

		-- Select all Faces
		subobjectLevel = 4
		max select all
		FaceCount = polyop.getNumFaces obj_UV
		AllFacesArray =(polyop.getFaceSelection obj_UV) as array


		for i = 1 to AllVerticesArray.count do
		(
			Vertexpos = polyop.getMapVert obj_UV 1 AllVerticesArray[i]
			Vertexpos_Scale = [Vertexpos.x * MapScale, Vertexpos.y * MapScale , Vertexpos.z * MapScale]
			appendIfUnique  Vertexlist Vertexpos_Scale
			Progress_update_Retopo ((100 as Double/ AllVerticesArray.count as Double  ) * i as integer) "Create VertexList"
			windows.processPostedMessages()
		)

		-- Create Nullobject
		ep = editable_mesh name:(uniquename epname) --create an empty EMesh
		convertTo ep Editable_Poly --convert to Editable_Poly

		-- Check VertexID with MapID 
		for  i = 1 to AllFacesArray.count do
		(
			FaceVertice = polyop.getFaceVerts obj_UV i as array
			FaceVertice_coor = polyop.getMapFace obj_UV 1 i as array

				for z = 1 to FaceVertice.count do
				(
					if FaceVertice[z] != FaceVertice_coor[z] do
					(
						-- Set MapID of VertexID
						pos = FaceVertice[z]
						Vertexpos = polyop.getMapVert obj_UV 1 FaceVertice_coor[z]
						Vertexpos_Scale = [Vertexpos.x * MapScale, Vertexpos.y * MapScale , Vertexpos.z * MapScale]
						Vertexlist[pos] = Vertexpos_Scale
						Progress_update_Retopo ((100 as Double/ AllFacesArray.count as Double  ) * i as integer) "Check Vertexlist/MapID"
						windows.processPostedMessages()
					)
				)
		)

		-- Creat Vertex
		undo off
			(
			with redraw off
				(
					for i = 1 to vertexList.count do
					(
						polyop.createVert ep vertexList[i]
						windows.processPostedMessages()
						Progress_update_Retopo ((100 as Double/ vertexList.count as Double  ) * i as integer) "Create Vertices"
					)
				)
			)-- Undo and redrawViews on off for faster creat

		-- Create Faces
		undo off
			(
			with redraw off
				(
					for  i = 1 to AllFacesArray.count do
					(
						FaceVertice = polyop.getFaceVerts obj_UV AllFacesArray[i]
						polyop.createPolygon ep FaceVertice
						windows.processPostedMessages()
						Progress_update_Retopo ((100 as Double/ AllFacesArray.count as Double  ) * i as integer) "Create Faces"
					)
				)
			)-- Undo and redrawViews on off for faster creat

		-- Set Morpher
		modi = Morpher Autoload_of_targets:1
		addModifier ep modi
		setCommandPanelTaskMode mode:#modify
		modpanel.setcurrentobject modi
		WM3_MC_BuildFromNode modi 1 obj_UV
		Morp_v = Morph_value as float
		WM3_MC_SetValue modi 1 Morp_v
	)