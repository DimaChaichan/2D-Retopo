macroscript DC_2DRetopo_UI
	category:"DC 2D Retopo"
	buttonText:"2D Retopo"
	toolTip:"DC 2D Retopo"
	icon:#("2D_Retopo", 1)
(	

	-- Dialog "UV_Flatten" 
	--****************************************************************************************************
	global UV_Flatten
	rollout UV_Flatten "UV Flatten" width:185 height:250
	(
	
	-- Rollout Elements
	--*********************************************************************************************	
		button btn_FlattUV "UV Flatten" width:120 height:40 enabled:true
		progressBar pb_UVFlatt "ProgressBar" pos:[13,52] width:120 height:15
		label lbl_progress "" width:120 height:15
		radiobuttons rdb_FlattUV "UV Flatten Method:" width:112 height:46 enabled:false labels:#("without Pelt Shell", "with Pelt Shell") columns:1
		edittext edt_epname "Name:" width:120 height:20 text:"Epoly"
		spinner spn_mapscale "MapScale" width:105 height:20 type:#integer scale:1 range:[1,10000,100]
	--*********************************************************************************************
	
	-- Button Flatten UV
	--*********************************************************************************************´
		on btn_FlattUV pressed do
		(
			undo on
			(
				with redraw off
				(
		
					if selection.count == 1 and  classOf selection[1] == Editable_Poly then
					(
					-- Global Variablen
					base_obj = $
					-- reset Progress	
					Progress_update_Retopo 0 ""
						
					-- UV Flatten Method = without UVW Shell
					--***********************************************************************************
						if rdb_FlattUV.state == 1 do
						(
							-- Start Timer
							gc()
							local startTime = timeStamp()
				
							-- convert to Editable_Poly
							convertTo base_obj Editable_Poly
							select base_obj
							
							Progress_update_Retopo 0 "Split UV Chucks"
							objUnwrapMod=Unwrap_UVW()
							addModifier base_obj objUnwrapMod
							breakPolyByUvShells()
							deleteModifier base_obj 1
							
							try
							(
							--UVFlatten
							_UV_2D3D_Flatten base_obj edt_epname.text spn_mapscale.value animation.spn_mophtarget.value
								
							-- Set Progress
							local stopTime = timeStamp()
							stop = ((stopTime - startTime) / 1000.0) as String
							Progress_update_Retopo 0 ("Finish in " + stop + " seconds\n")
							)
							catch
							(
								messageBox "Check the UVW Unwrap"
								Progress_update_Retopo 0 "Error!"
							)
						)
					--***********************************************************************************
					--***********************************************************************************
					)
					else
					(
						messageBox "Please Select a EditablePoly"
					)
				)
			)
		)
	)
	
	
	-- Dialog "animation" 
--****************************************************************************************************
	global  animation
	rollout animation "Animation" width:185 height:250
	(
		-- Rollout Elements
		--*********************************************************************************************	
		spinner spn_mophtarget "Morpher Value:" pos:[30,10] width:105 height:16 range:[0,100,0] type:#float scale:1
		button btn_bakeAni "Bake Animation" width:120 height:33
		spinner spn_frame_start "Frame Start"  width:105 height:16 range:[1,10000,1] type:#integer scale:1
		spinner spn_frame_end "Frame End"  width:100 height:16 range:[1,10000,100] type:#integer scale:1
		--*********************************************************************************************	
		
		on spn_mophtarget changed val do
		(
			SelectedMod_Morpher = modPanel.getCurrentObject()
			if classOf SelectedMod_Morpher == morpher do
			(
				WM3_MC_SetValue SelectedMod_Morpher 1 spn_mophtarget.value
				--spn_mophtarget.controller = SelectedMod_Morpher[1].controller
			)
		)
		
		on btn_bakeAni pressed  do
		(
			SelectedMod_Morpher = modPanel.getCurrentObject()
			if classOf SelectedMod_Morpher == morpher then
			(
				with animate on
				(
				  at time spn_frame_start.value WM3_MC_SetValue SelectedMod_Morpher 1 0.0
				  at time spn_frame_end.value WM3_MC_SetValue SelectedMod_Morpher 1 100.0
				)
			)
			else
			(
				messageBox "Please Select a EditablePoly with a Morpher"
			)
		)
	)

	-- Dialog "Tools" 
	--****************************************************************************************************
	rollout Tools "Tools" width:185 height:250
	(
	
	-- Rollout Elements
	--*********************************************************************************************
		group "Quick SkinWrap"
		(
		button btn_AddSkin_obj "Source Object" pos:[13,25] width:80 height:20 
		button btn_delSkin_obj "Del" pos:[95,25] width:38 height:20 enabled:false
		label lbl_ObjSkinName "not selected object" width:120 height:14
		button btn_AddSkinwrap "Add Skinwrap" width:120 height:20 enabled:false
		)
		group "Mirror Faces"
		(
		button btn_MirrorFace "Mirror" width:120 height:20
		radioButtons rdo_axis "" width:80 height:50 labels:#("X","Y","Z","XY","YX","ZX") columns:2
		checkbox ch_Copy "Copy" pos:[50,195] width:50 height:20  checked:true
		)
	--*********************************************************************************************
		
	-- Open Dialog
	--*********************************************************************************************´
		on Tools open do
		(
			-- Global Variablen
			global SourceSkin 
		)
		
	-- Button Source Object Object
	--*********************************************************************************************´
		on btn_AddSkin_obj pressed do
		(
			SelectedMod_Morpher = modPanel.getCurrentObject()
			if classOf SelectedMod_Morpher == morpher then
			(
				SourceSkin = $
				lbl_ObjSkinName.Text = SourceSkin.name
				
				--set UI
				btn_AddSkin_obj.enabled = false
				btn_delSkin_obj.enabled = True
				btn_AddSkinwrap.enabled = True
			)			
			else
			(
				messageBox "Please Select a EditablePoly with a Morpher"
			)
		)
	
	-- Button Del Source Object Object
	--*********************************************************************************************´
		on btn_delSkin_obj pressed do
		(
			SourceSkin = false
			
			--set UI
			btn_AddSkin_obj.enabled = true
			btn_delSkin_obj.enabled = false
			btn_AddSkinwrap.enabled = false
		)
		
	-- Button Add Skin Wrap 
	--*********************************************************************************************´
		on btn_AddSkinwrap pressed do
		(
			if selection.count == 1 and  classOf selection[1].baseObject == Editable_Poly then
			(
				if  selection[1].baseObject != SourceSkin then
				(
				Skinwarp=Skin_Wrap() 
				addModifier $ Skinwarp
				modpanel.setcurrentobject Skinwarp
				Skinwarp.meshList = #(SourceSkin)
				)
				else
				(
					messageBox "You have chosen the source object"
				)
			)
			else
			(
				messageBox "Please Select a EditablePoly"
			)
		)
		
		-- Button Mirror Faces
		--*********************************************************************************************´
		on btn_MirrorFace pressed do
		(
			
			if selection.count == 1 and  classOf selection[1].baseObject == Editable_Poly then
			(
				MirrorObj = $
				--CenterSec = selection.center
				CenterSec = [0,0,0]
				print rdo_axis.state
				ObjFaceselection = polyop.getFaceSelection MirrorObj as array
				if ObjFaceselection.count >= 1 Then
				(
					MMirror=mirror() 
					addModifier $ MMirror
					modpanel.setcurrentobject MirrorObj
					subobjectLevel = 4
					modpanel.setcurrentobject MMirror
					
					MMirror.mirror_center.position = CenterSec
					MMirror.mirror_axis = (rdo_axis.state - 1)
					
					if ch_Copy.checked == true then
						MMirror.copy = true
					
					convertTo MirrorObj Editable_Poly
				)
				else
				(
				messageBox "Please Select Faces"
				)
			)
			else
			(
				messageBox "Please Select a EditablePoly"
			)
		)
			
	)
	
-- Dialog "Weld Edges" 
--****************************************************************************************************
	global UpdateTempSpline_AT 
	fn UpdateTempSpline_AT=
	(
		UpdateTempSpline WeldObject TempSpline WeldEdgeList
		redrawViews()
	)
	
	rollout Weld_Edges "Weld Edges" width:185 height:150
	(
		-- Rollout Elements
		--*********************************************************************************************	
		group ""
		(
		button btn_Add_obj "Add Object" pos:[13,20] width:80 height:20 
		button btn_del_obj "Del" pos:[95,20] width:38 height:20 enabled:false
		label lbl_ObjName "not selected object" width:120 height:20
		)
		button btn_weld "Weld Edges" width:120 height:20 enabled:false
		button btn_Undo "Weld Edges Undo" width:120 height:15 enabled:false
		group ""
		(
		button btn_Add_egdes "Add Edges" pos:[13,135]   width:80 height:20 enabled:false
		button btn_Del_egdes "Del" pos:[95,135] width:38 height:20 enabled:false
		button btn_Add_Loop_Start_egdes "Loop Start" pos:[13,165]  width:60 height:20 enabled:false
		button btn_Add_Loop_End_egdes "Loop End" pos:[73,165]  width:60 height:20 enabled:false
		checkbox ch_RevertsLoop "Reverse Loop" width:120 height:15 enabled:false checked:false
		button btn_LoopOK "OK Loop" width:120 height:20 enabled:false
		listbox lbx_Weld_edges ""  width:120 height:10
		button btn_Update "Update Helpersplines" width:120 height:20 enabled:false
		checkbox ch_Update "Automatic" width:120 height:20 enabled:false checked:true
		)
		group "Settings"
		(
			spinner spn_Size "Size" width:80 height:20 type:#float scale:0.1 range:[0.1,10000,1]
			checkbox ch_CreateUV "Create UV" pos:[50,470] width:120 height:20 checked:true
		)
		--*********************************************************************************************	
	
		-- Button Update Helpersplines 
		--*********************************************************************************************´
		on btn_Update pressed do
		(
			UpdateTempSpline WeldObject TempSpline WeldEdgeList
		)
		
		-- Open Dialog
		--*********************************************************************************************´
		on Weld_Edges open do
		(
			-- Global Variablen
			global WeldObject 
			global WeldEdgeListTx = #()
			global WeldEdgeList = #()
			global SplineCounter = 1
			global TempUndoObj
			global TempName
			global TempSplineObj
			global MultiStart = false
			global MultiStartList = #()
			global LoopStart = false
			global LoopStartList = #()
			global LoopEndList = #()
			global SplineLoopCounter = 1
			
			-- set Temp Material
			MatTemp = StandardMaterial()
			MatTemp.name = "MATTemp"
			MatTemp.diffuse = Blue
			
			MatTempAC = StandardMaterial()
			MatTempAC.name = "MATTempAC"
			MatTempAC.diffuse = Red	
			
			MatTempLoop = StandardMaterial()
			MatTempLoop.name = "MATTempLoop"
			MatTempLoop.diffuse = Green
			
			Global TempMulti =  MultiSubMaterial  numsubs:2
			TempMulti[1] = MatTemp
			TempMulti[2] = MatTempAC
			
			-- set Temp Spline
			global TempSpline = SplineShape ()
			TempSpline.name = "Temp"
			TempSpline.material = TempMulti
			TempSpline.render_renderable = true
			TempSpline.render_displayRenderMesh = true
			TempSpline.render_rectangular = true
			TempSpline.render_width = 1.0
			TempSpline.render_length = 1.0
			
			-- set TempLoop Spline
			global TempLoopSpline = SplineShape ()
			TempLoopSpline.name = "TempLoop"
			TempLoopSpline.material = MatTempLoop
			TempLoopSpline.render_renderable = true
			TempLoopSpline.render_displayRenderMesh = true
			TempLoopSpline.render_rectangular = true
			TempLoopSpline.render_width = 0.5
			TempLoopSpline.render_length = 0.5
			
			-- unregister Callback
			unregisterRedrawViewsCallback UpdateTempSpline_AT
		)
		
		-- Close Dialog
		--*********************************************************************************************´		
		on Weld_Edges close  do
		(
			undo off
			(
				if isvalidnode $Temp then
				(
					-- Delete Spline
					select TempSpline
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				)
				if isvalidnode $TempLoop then
				(
					-- Delete Spline
					select TempLoopSpline
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				)
				if isvalidnode $TempObj then
				(
					-- Delete Spline
					select TempUndoObj
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				)
				if isvalidnode $TempSpline then
				(
					-- Delete Spline
					select TempSplineObj
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				)
				
				-- unregister Callback
				unregisterRedrawViewsCallback UpdateTempSpline_AT
			)
		)
		
		-- Checkbox ch_Update
		--*********************************************************************************************´
		on ch_Update changed state do
		(
				if ch_Update.checked == true then
					registerRedrawViewsCallback UpdateTempSpline_AT 
				else
					unregisterRedrawViewsCallback UpdateTempSpline_AT
		)
		
		-- Checkbox ch_Update
		--*********************************************************************************************´
		on ch_RevertsLoop changed state do
		(
				Drawlist = #()
				LoopEndList = for i = LoopEndList.count to 1 by -1 collect LoopEndList[i]
					
				appendIfUnique Drawlist #(LoopStartList[1], LoopEndList[1])
				appendIfUnique Drawlist #(LoopStartList[LoopStartList.count], LoopEndList[LoopEndList.count])
				
				UpdateTempSpline WeldObject TempLoopSpline Drawlist
		)
		
		-- Button Add Object
		--*********************************************************************************************´
		on btn_Add_obj pressed do
		(
			UpdateTempSpline_AT
			undo off
			(
				if selection.count == 1 and  classOf selection[1].baseObject == Editable_Poly then
				(
					-- set Global WeldObject
					WeldObject = $
					WeldEdgeListTx = #()
					WeldEdgeList = #()
					SplineCounter = 1				
					
					-- set UI
					lbl_ObjName.text = WeldObject.name
					btn_Add_obj.enabled = false
					btn_del_obj.enabled = true
					btn_Add_egdes.enabled = true
					btn_Undo.enabled = false
					btn_Add_Loop_Start_egdes.enabled = true
					
					if isvalidnode $TempObj then
					(
					-- Delete Spline
					select TempUndoObj
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
					)
					if isvalidnode $TempSpline then
					(
					-- Delete Spline
					select TempSplineObj
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
						
					-- set Temp Spline
						TempSpline = SplineShape ()
						TempSpline.name = "Temp"
						TempSpline.material = TempMulti
						TempSpline.render_renderable = true
						TempSpline.render_displayRenderMesh = true
						TempSpline.render_rectangular = true
						TempSpline.render_width = 1.0
						TempSpline.render_length = 1.0
					)
				
				)
				else
				(
					messageBox "Please Select a EditablePoly"
				)
			)
		)

	-- Button Del Object
	--*********************************************************************************************´
		on btn_del_obj pressed do
		(
			undo off
			(
			-- Delete Spline
			select TempSpline
			actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				
			-- Delete Spline
			select TempLoopSpline
			actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
				
			-- Reset Global Variablen
			 WeldObject = false
			 WeldEdgeListTx = #()
			 WeldEdgeList = #()
			 SplineCounter = 1
			
			-- set Temp Spline
			TempSpline = SplineShape ()
			TempSpline.name = "Temp"
			TempSpline.material = TempMulti
			TempSpline.render_renderable = true
			TempSpline.render_displayRenderMesh = true
			TempSpline.render_rectangular = true
			TempSpline.render_width = 1.0
			TempSpline.render_length = 1.0	
			
			-- set TempLoop Spline
			TempLoopSpline = SplineShape ()
			TempLoopSpline.name = "TempLoop"
			TempLoopSpline.material = MatTempLoop
			TempLoopSpline.render_renderable = true
			TempLoopSpline.render_displayRenderMesh = true
			TempLoopSpline.render_rectangular = true
			TempLoopSpline.render_width = 0.5
			TempLoopSpline.render_length = 0.5
			
			-- set UI
			lbl_ObjName.text = "not selected object" 
			btn_Add_obj.enabled = True
			btn_del_obj.enabled = false
			btn_Del_egdes.enabled = false
			btn_Add_egdes.enabled = false
			btn_weld.enabled = false
			lbx_Weld_edges.items = WeldEdgeListTx
			btn_Update.enabled = false
			ch_Update.enabled = false
			btn_Add_Loop_Start_egdes.enabled = false
			btn_Add_Loop_End_egdes.enabled = false
			
			-- unregister Callback
			unregisterRedrawViewsCallback UpdateTempSpline_AT
			)
		)
		
	-- Button Weld Object
	--*********************************************************************************************´		
		on btn_weld pressed do
		(

			undo off
			(	
				with redraw off
				(
					

					-- Copy Object for Undo
					maxOps.cloneNodes WeldObject cloneType:#copy newNodes:&nnl
					nnl.name = "TempObj"
					TempUndoObj = nnl
					hide TempUndoObj
					TempName = WeldObject.name
				
					-- Copy Welspline for Undo
					maxOps.cloneNodes TempSpline cloneType:#copy newNodes:&nnl
					nnl.name = "TempSpline"
					TempSplineObj = nnl
					hide TempSplineObj
				
					convertTo WeldObject Editable_Poly

					-- List vor Unwrap
					UVEdgeList = SeaechElements WeldObject
					print "UV"
						
					CollapseList = #()
					CountEdgesSource = polyop.getNumEdges WeldObject
					
					WeldObject.bridgeSegments = 1
					WeldObject.bridgeAdjacentAngle = 180
					-- Bridge Edges
					for i = 1 to WeldEdgeList.count do
						(
						polyop.setEdgeSelection WeldObject WeldEdgeList[i]
						WeldObject.bridge selLevel: #Edge
						)
					
					-- Search new Edges
					CountEdges = ((polyop.getNumEdges WeldObject) - CountEdgesSource)
					for x=1 to CountEdges do
						(
							appendIfUnique CollapseList (CountEdgesSource + x) 
						)
					
					
					-- Collepse new Edges
					polyop.collapseEdges WeldObject CollapseList
					
					--Create UV
					--***********************************************************************
					if ch_CreateUV.checked == true do
					(	
						-- Planar Unwrap for Patterns
						for i = 1 to UVEdgeList.count do
						(
							polyop.setfaceSelection WeldObject  UVEdgeList[i] 
							MUnwrap = UVWUnwrap() 
							addModifier $ MUnwrap
							modpanel.setcurrentobject $
							subobjectLevel = 4
							modpanel.setcurrentobject MUnwrap
							subobjectLevel = 3
							MUnwrap.mappingMode 1
							MUnwrap.mappingMode 0
							MUnwrap.relaxByFaceAngle 1000 0.0 0.1 false
							convertTo WeldObject Editable_Poly
						)
						-- Pack UVchucks
						MUnwrap = UVWUnwrap() 
						addModifier $ MUnwrap
						subobjectLevel = 3
						actionMan.executeAction 0 "40021"  -- Selection: Select All
						MUnwrap.pack 0 0.02 true true true 
						convertTo WeldObject Editable_Poly
					)
					--***********************************************************************
					
					-- Delete Spline
					select TempSpline
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
					
					-- Delete Spline
					select TempLoopSpline
					actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
					
					-- set TempLoop Spline
					TempLoopSpline = SplineShape ()
					TempLoopSpline.name = "TempLoop"
					TempLoopSpline.material = MatTempLoop
					TempLoopSpline.render_renderable = true
					TempLoopSpline.render_displayRenderMesh = true
					TempLoopSpline.render_rectangular = true
					TempLoopSpline.render_width = 0.5
					TempLoopSpline.render_length =  0.5
					SplineLoopCounter =1
					
					-- set UI
						lbl_ObjName.text = "not selected object" 
						btn_Add_obj.enabled = True
						btn_del_obj.enabled = false
						btn_Del_egdes.enabled = false
						btn_Add_egdes.enabled = false
						btn_Del_egdes.enabled = false
						btn_weld.enabled = false
						lbx_Weld_edges.items = #()
						btn_Undo.enabled = true
						btn_Update.enabled = false
						ch_Update.enabled = false
						btn_Add_Loop_Start_egdes.enabled = false
						btn_Add_Loop_End_egdes.enabled = false
					
					-- unregister Callback
					unregisterRedrawViewsCallback UpdateTempSpline_AT
			
					Select WeldObject
			)	
		)
	)
		
		-- Button Undo
	--*********************************************************************************************´		
		on btn_Undo pressed do
		(
			undo off
			(
			--Delete Source Obj
			select WeldObject
			actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
			unhide TempUndoObj
			
			select TempUndoObj
			WeldObject = $
			WeldObject.name = TempName
			
			unhide TempSplineObj
			select TempSplineObj
			TempSpline  = $
			TempSpline.name = "Temp"
			
			-- set UI
				lbl_ObjName.text = TempName
				btn_Add_obj.enabled = false
				btn_del_obj.enabled = true
				btn_del_obj.enabled = true
				btn_Add_egdes.enabled = true
				btn_Del_egdes.enabled = true
				btn_weld.enabled = true
				lbx_Weld_edges.items = WeldEdgeListTx
				btn_Undo.enabled = false
				btn_Update.enabled = True
				ch_Update.enabled = true
				btn_Add_Loop_Start_egdes.enabled = True
				btn_Add_Loop_End_egdes.enabled = false	
				
			-- register Callback
			registerRedrawViewsCallback UpdateTempSpline_AT 
			
			Select WeldObject
			)
		)
				
	-- Button Add Edge
	--*********************************************************************************************´	
		on btn_Add_egdes pressed do
		(
			if selection.count == 1 and  selection[1] == WeldObject then
				(
					ObjEdgeselection = polyop.getEdgeSelection WeldObject as array
					
					if ObjEdgeselection.count == 2 then
						(
							-- Check: If Edge in the Weldlist
							--************************************************************
							doubleEdge = false
							for i=1 to WeldEdgeList.count do
							(
								If WeldEdgeList[i][1] == ObjEdgeselection[1] do
									doubleEdge = True
								If WeldEdgeList[i][1] == ObjEdgeselection[2] do
									doubleEdge = True
								If WeldEdgeList[i][2] == ObjEdgeselection[1] do
									doubleEdge = True
								If WeldEdgeList[i][2] == ObjEdgeselection[2] do
									doubleEdge = True
							)
							--************************************************************
							
							-- Check: Can Bridge the Edges
							--************************************************************
							WeldObject.bridgeSegments = 1
							WeldObject.bridgeAdjacentAngle = 180
							CheckWeld = WeldObject.bridge selLevel: #Edge
							--************************************************************
							
							if CheckWeld == True then
							(
								undo off
								(
									polyop.deleteFaces WeldObject #((polyop.getNumFaces WeldObject))
									If doubleEdge == false then
									(
										-- App  to WeldList
										--******************************************************************************************************************************
										appendIfUnique WeldEdgeListTx (ObjEdgeselection[1] as String + " <-> "  + ObjEdgeselection[2] as String) -- for the ListBoxControlox
										appendIfUnique WeldEdgeList ObjEdgeselection																					-- for the weld
										--******************************************************************************************************************************
										
										-- Draw Tempspline
										-- ***********************************************************************
										CenterEgde1 = GetCenterEdge WeldObject ObjEdgeselection[1]
										CenterEgde2 = GetCenterEdge WeldObject ObjEdgeselection[2]
										drawLine CenterEgde1 CenterEgde2 TempSpline SplineCounter
										SplineCounter +=1
										-- ***********************************************************************
										
										--set UI
										lbx_Weld_edges.items = WeldEdgeListTx
										btn_weld.enabled = true
										btn_Del_egdes.enabled = true
										btn_Update.enabled = True
										ch_Update.enabled = true
										
										if ch_Update.checked == true then
											registerRedrawViewsCallback UpdateTempSpline_AT 
									)
									else
									(
										messageBox "You have selected an existing edge"
									)
								)
							)
							else
							(
								messageBox "The selected Edges can not be welded"
							)
						)
						else
						(
							messageBox "Please Select two Edges"
						)
						
				)
				else
					(
						messageBox ("Please Select Object " + WeldObject.name) 
					)
		)
		
		-- Button Add Loop Start Edge 
		--*********************************************************************************************´	
		on btn_Add_Loop_Start_egdes pressed do
		(
			if selection.count == 1 and  selection[1] == WeldObject then
			(
				LoopStartList = #()
				ObjEdgeselection = polyop.getEdgeSelection WeldObject as array
				CheckStartEdge = ObjEdgeselection
				
				if ObjEdgeselection.count == 1 then
				(
					WeldObject.EditablePoly.SelectEdgeLoop ()
					ObjEdgeselection = polyop.getEdgeSelection WeldObject as array
					
					--Sort Edgelist
					--***************************************************************************************
					LoopStartList = ObjEdgeselection
					LoopStartList = SortSelectEdgeLoop WeldObject LoopStartList CheckStartEdge[1]
					--***************************************************************************************
					
					-- Set UI
					btn_Add_Loop_Start_egdes.enabled = False
					btn_Add_Loop_End_egdes.enabled = True
				)
				else
				(
					messageBox "Please select one edge"
				)
			)
			else
			(
				messageBox ("Please Select Object " + WeldObject.name) 
			)	
		)
		
		-- Button Add Loop End Edge 
		--*********************************************************************************************´	
		on btn_Add_Loop_End_egdes pressed do
		(
			if selection.count == 1 and  selection[1] == WeldObject then
			(
				ObjEdgeselection = polyop.getEdgeSelection WeldObject as array
				CheckStartEdge = ObjEdgeselection
				
				if ObjEdgeselection.count == 1 then
				(
					WeldObject.EditablePoly.SelectEdgeLoop ()
					ObjEdgeselection = polyop.getEdgeSelection WeldObject as array
					
					--Sort Edgelist
					--***************************************************************************************
					LoopEndList = ObjEdgeselection
					LoopEndList = SortSelectEdgeLoop WeldObject LoopEndList CheckStartEdge[1]
					--***************************************************************************************
					
					if LoopStartList.count == LoopEndList.count then
						(
							CheckdoubleEdges = false
							
							-- Check Double Edges
							--*************************************************************
							for X=1 to LoopStartList.count do
							(
								for Y= 1 to LoopEndList.count do
								(
									if LoopStartList[X] == LoopEndList[Y] then
										CheckdoubleEdges = True
								)
							)
							--*************************************************************
								
							if CheckdoubleEdges == false then
							(
								-- Revert 
								LoopEndList = for i = LoopEndList.count to 1 by -1 collect LoopEndList[i]
										
								-- Check: Can Bridge the Edges
								--************************************************************
								CheckWeldSW = True
								for X=1 to LoopStartList.count do
								(
								ObjEdgeselection = polyop.setEdgeSelection WeldObject #(LoopStartList[X], LoopEndList[X])
								WeldObject.bridgeSegments = 1
								WeldObject.bridgeAdjacentAngle = 180
								CheckWeld = WeldObject.bridge selLevel: #Edge
									if CheckWeld == false then
									(
										CheckWeldSW = false
									)
									else
									(
										polyop.deleteFaces WeldObject #((polyop.getNumFaces WeldObject))
									)				
								)
								--************************************************************
							
								if CheckWeldSW == True then
								(
								
										
									-- Draw Tempspline First
									-- ***********************************************************************
									CenterEgde1 = GetCenterEdge WeldObject LoopStartList[1]
									CenterEgde2 = GetCenterEdge WeldObject LoopEndList[1]
									drawLine CenterEgde1 CenterEgde2 TempLoopSpline SplineLoopCounter
									SplineLoopCounter +=1
									-- ***********************************************************************
									-- Draw Tempspline Last
									-- ***********************************************************************
									CenterEgde1 = GetCenterEdge WeldObject LoopStartList[LoopStartList.count]
									CenterEgde2 = GetCenterEdge WeldObject LoopEndList[LoopEndList.count]
									drawLine CenterEgde1 CenterEgde2 TempLoopSpline SplineLoopCounter
									SplineLoopCounter +=1
									-- ***********************************************************************
								
									--set UI
									btn_Add_Loop_Start_egdes.enabled = false
									btn_Add_Loop_End_egdes.enabled = false
									ch_RevertsLoop.enabled = True
									btn_LoopOK.enabled = True
									
								)
								else
								(
								messageBox "The selected Edges can not be welded"
								--set UI
								btn_Add_Loop_Start_egdes.enabled = true
								btn_Add_Loop_End_egdes.enabled = false
								)
								
							)
							else
							(
								messageBox "There are duplicate Edges have been found"
							)
						)
						else
						(
							messageBox "Corresponds to the number of the selected Edges does not match the number of start correspond"
						)
				)
				else
				(
					messageBox "Please select one edge"
				)
			)
			else
			(
				messageBox ("Please Select Object " + WeldObject.name) 
			)
		)
		
		-- Button Loop OK
		--*********************************************************************************************´	
		on btn_LoopOK pressed do
		(
			NewLines = WeldEdgeList.count
			
			-- App  to WeldList
			--******************************************************************************************************************************
			for i = 1 to LoopStartList.count do
			(
				appendIfUnique WeldEdgeListTx (LoopStartList[i] as String + " <-> "  + LoopEndList[i] as String) -- for the ListBoxControlox
				appendIfUnique WeldEdgeList #(LoopStartList[i], LoopEndList[i])
			)
			--******************************************************************************************************************************
			
			-- Draw Tempspline
			-- ***********************************************************************
			for i = 1 to LoopStartList.count do
			(
			CenterEgde1 = GetCenterEdge WeldObject WeldEdgeList[NewLines + i][1]
			CenterEgde2 = GetCenterEdge WeldObject WeldEdgeList[NewLines + i][2]
			drawLine CenterEgde1 CenterEgde2 TempSpline SplineCounter
			SplineCounter +=1
			)
			-- ***********************************************************************
			
			-- Delete Spline
			select TempLoopSpline
			actionMan.executeAction 0 "40020"  -- Edit: Delete Objects
					
			-- set TempLoop Spline
			TempLoopSpline = SplineShape ()
			TempLoopSpline.name = "TempLoop"
			TempLoopSpline.material = MatTempLoop
			TempLoopSpline.render_renderable = true
			TempLoopSpline.render_displayRenderMesh = true
			TempLoopSpline.render_rectangular = true
			TempLoopSpline.render_width = 0.5
			TempLoopSpline.render_length =  0.5
			SplineLoopCounter =1
			
			--set UI
			lbx_Weld_edges.items = WeldEdgeListTx
			btn_weld.enabled = true
			btn_Del_egdes.enabled = true
			btn_Update.enabled = True
			ch_Update.enabled = true
			btn_Add_Loop_Start_egdes.enabled = true
			btn_LoopOK.enabled = false
			ch_RevertsLoop.enabled = false
			
			if ch_Update.checked == true then
				registerRedrawViewsCallback UpdateTempSpline_AT 
			
		)
			
		-- Button Del Edge Object
		--*********************************************************************************************´	
		on btn_Del_egdes pressed do
		(
			undo off
			(
			Sec = lbx_Weld_edges.selection
			deleteItem WeldEdgeList Sec
			deleteItem WeldEdgeListTx Sec
			
			--select TempSpline
			deleteSpline TempSpline 1
			updateShape TempSpline
			SplineCounter -= 1
			
			lbx_Weld_edges.items = WeldEdgeListTx
			if (WeldEdgeList.count == 0) do
				(
					btn_weld.enabled = false
					btn_Del_egdes.enabled = false
					btn_Update.enabled = false
					ch_Update.enabled = false
					-- unregister Callback
					unregisterRedrawViewsCallback UpdateTempSpline_AT
				)
			)
		)
		
		-- Listbox Weld Edge Selected
		--*********************************************************************************************´	
		on lbx_Weld_edges selected sel do
		(
			undo off
			(
			-- Switch Select Spline to Active
			SegCount = numSplines  TempSpline
			for i=1 to SegCount do
				(
					setMaterialID TempSpline i 1 1
				)
			setMaterialID TempSpline sel 1 2
			updateShape TempSpline
			)
		)
		
		on spn_Size changed val do
		(
			TempSpline.render_width = val
			TempSpline.render_length = val
		)
	)
	
	-- Rollout About
	--*********************************************************************************************	
	rollout Info_About "About" 
	(
		group "Info"
		(
			label Creat "Created by"
			label Author "Demeter Chaichan" 
			label Version "Version: 0.1 alpha"
			HyperLink portfolio "Online portfolio" pos:[40,80] color:(color 0 10 144) hovercolor:(color 144 0 0) address:"http://www.demeterchaichan.com"
		)
	)

	--  Creat Dialog "2D Retopo"
--*****************************************
	if (UV_Flatten.isDisplayed == false) do
	(
		FR_2DRetopo = newRolloutFloater "2D Retopo" 160 500
		addRollout UV_Flatten  FR_2DRetopo
		addRollout Animation  FR_2DRetopo rolledUp:true
		addRollout Tools  FR_2DRetopo rolledUp:true
		addRollout Weld_Edges  FR_2DRetopo rolledUp:true
		addRollout Info_About  FR_2DRetopo 
		cui.RegisterDialogBar FR_2DRetopo minSize:[165,150] maxSize:[165,600] style:#(#cui_floatable, #cui_handles, #cui_max_sized, #cui_dock_vert)
	)
	
)