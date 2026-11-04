extends Node2D

var radius := 0.0:
	set(value):
		radius = value
		queue_redraw()


func _draw() -> void:
	if radius > 0.0:
		draw_circle(Vector2.ZERO, radius, Color("#ffe3bd"))
