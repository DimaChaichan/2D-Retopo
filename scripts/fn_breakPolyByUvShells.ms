-- breakPolyByUvShell
-- Author: PolyTools3D
-- http://forums.cgsociety.org/showthread.php?f=98&t=1114936
--*********************************************************************************************
   	fn breakPolyByUvShells = (

   		uvmod = modPanel.getCurrentObject()
   		print "ok"
   		if (classof uvmod == Unwrap_UVW) and (classof $.baseobject == Editable_Poly) do (
   			subobjectlevel = 3

   			cSelectFaces = uvmod.selectFaces
   			cGetSelectedPolygons = uvmod.getSelectedPolygons
   			cSelectElement = uvmod.selectElement
   			cDetachFaces = polyop.detachFaces

   			polys = #{1..$.numfaces}
   			elements = #()
			polyscount = polys.count as double

   			for p in polys do (
   				cSelectFaces #{p}
   				cSelectElement()
   				element = cGetSelectedPolygons()
   				cDetachFaces $ element
   				append elements element
   				for e in element do deleteItem polys e
				Progress_update_Retopo (((100 as double / polyscount) * p as double) as integer) "Split UV Chucks"
   			)
   		)

   		--return elements
   	)

