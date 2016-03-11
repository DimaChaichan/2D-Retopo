fn SortSelectEdgeLoop Obj EdgeList StartEdge =
(
	VertexList = #()
	SortEdgeList = #(StartEdge)

	for x=1 to EdgeList.count do
	(
		Verts = polyop.getEdgeVerts Obj EdgeList[x]
		appendIfUnique VertexList Verts[1]
		appendIfUnique VertexList Verts[2]
	)

	CheckNext = StartEdge

	FoundVert = findItem EdgeList StartEdge
	deleteItem EdgeList FoundVert

	for i=1 to (EdgeList.count + 1) do
	(
		undo off
			(
				CheckVerts = polyop.getEdgeVerts Obj CheckNext

				SecondVert = true
				For i=1 to VertexList.count do
					(
						if CheckVerts[1] == VertexList[i] do
						(
							SecondVert = false
						)
					)

				if SecondVert == false then
				(
					CheckEdges = polyop.getEdgesUsingVert Obj CheckVerts[1] as array
					FoundVert = findItem VertexList CheckVerts[1]
					if FoundVert != 0 do
						deleteItem VertexList FoundVert
				)
				else
				(
					CheckEdges = polyop.getEdgesUsingVert Obj CheckVerts[2] as array
					FoundVert = findItem VertexList CheckVerts[2]
					if FoundVert != 0 do
						deleteItem VertexList FoundVert
				)
					--print ("Next" + (CheckNext as string))

					FoundEndEdge = true
					for y=1 to EdgeList.count do
					(
							for z=1 to CheckEdges.count do
							(
								if CheckEdges[z] == EdgeList[y] do
								(
									appendIfUnique SortEdgeList CheckEdges[z]
									CheckNext = CheckEdges[z]
									FoundEndEdge = false
										deleteItem EdgeList y
								)
							)
					)

					if FoundEndEdge == True do
					(
						CheckNext = StartEdge
						SortEdgeList = for i = SortEdgeList.count to 1 by -1 collect SortEdgeList[i]
					)
			)
	)

	return SortEdgeList
)

