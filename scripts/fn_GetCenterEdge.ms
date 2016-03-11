-- GetCenterEdge
-- Return the Center of Edge
-- CEdge = [int] Edge
-- Return = [Point] Center of Edge
--*********************************************************************************************
fn GetCenterEdge obj CEdge =
(
	EdgeVerts = polyop.getEdgeVerts obj CEdge
	X1 = polyop.getVert  obj EdgeVerts[1]
	X2 = polyop.getVert  obj EdgeVerts[2]
	CenterEgde = [((X1[1]+X2[1])/2),((X1[2]+X2[2])/2),((X1[3]+X2[3])/2)]
	Return CenterEgde
)

