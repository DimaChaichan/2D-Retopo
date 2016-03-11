fn UpdateLine pointA pointB Spline ID=
(
	setKnotPoint Spline ID 1 pointA
	setKnotPoint Spline ID 2 pointB
	updateShape Spline
	Spline
)
