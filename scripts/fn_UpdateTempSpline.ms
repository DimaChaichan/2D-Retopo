	fn UpdateTempSpline Obj Spline EdgeList =
	(
		for i=1 to EdgeList.count do
		(
			CenterEgde1 = GetCenterEdge Obj EdgeList[i][1]
			CenterEgde2 = GetCenterEdge Obj EdgeList[i][2]
			UpdateLine CenterEgde1 CenterEgde2 Spline i
		)
	)