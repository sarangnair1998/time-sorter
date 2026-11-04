extends Node2D

var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()


func _draw() -> void:
	if progress <= 0.0 or progress >= 0.9:
		return
	var size := 3.0 if progress < 0.5 else 2.0
	for i in 10:
		var angle := i * PI / 5.0
		draw_rect(Rect2(Vector2(cos(angle), sin(angle)) * (12.0 + 34.0 * progress), Vector2(size, size)), Color("#ffe3bd"))
