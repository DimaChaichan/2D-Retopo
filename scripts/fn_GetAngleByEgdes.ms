-- GetAngleByEgdes
-- Return Angle by Two Edges
-- EdgeVertList1 = [Array] Array of Vertices from first Edge
-- EdgeVertList2 = [Array] Array of Vertices from second Edge
--*********************************************************************************************	
fn GetAngleByEgdes EdgeVertList1 EdgeVertList2=
(
	-- search for double Points
	--***************************************************
	if EdgeVertList1[1] == EdgeVertList2[1] do
		(
			P1 = polyop.getVert $ VertsList[1][2]
			P2 = polyop.getVert $ VertsList[1][1]
			P3 = polyop.getVert $ VertsList[2][2]
		)

	if EdgeVertList1[1] == EdgeVertList2[2] do
		(
			P1 = polyop.getVert $ VertsList[1][2]
			P2 = polyop.getVert $ VertsList[1][1]
			P3 = polyop.getVert $ VertsList[2][1]
		)
	if EdgeVertList1[2] == EdgeVertList2[1] do
		(
			P1 = polyop.getVert $ VertsList[1][1]
			P2 = polyop.getVert $ VertsList[1][2]
			P3 = polyop.getVert $ VertsList[2][2]
		)

	if EdgeVertList1[2] == EdgeVertList2[2] do
		(
			P1 = polyop.getVert $ VertsList[1][1]
			P2 = polyop.getVert $ VertsList[1][2]
			P3 = polyop.getVert $ VertsList[2][1]
		)
	--***************************************************

	-- calculate Angle
	V1 = P3 - P2
	V2 = P1 - P2
	EdgeAngle = acos(dot (normalize V1) (normalize V2))

	-- Return Angle
	Return EdgeAngle
)

/* Snippets
	SecEdge = polyop.getEdgeSelection $
	VertsList = #()
	for p in SecEdge do
	(
		A = polyop.getEdgeVerts $ p
		append VertsList A
	)
	TAngle = GetAngleByEgdes VertsList[1] VertsList[2]
*/
