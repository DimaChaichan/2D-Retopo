fn drawLine pointA pointB Spline ID=
(
  addNewSpline Spline
  addKnot Spline ID #corner #line PointA
  addKnot Spline ID #corner #line PointB
  updateShape Spline
  Spline
)
