extends Node2D

const DRIPS := [
	[240, 98, 10], [268, 98, 16], [300, 98, 7], [331, 98, 13], [372, 98, 9],
	[401, 98, 18], [262, 77, 9], [346, 77, 12], [396, 77, 8],
]
const SPLATTER := [
	[212, 52, 2], [208, 72, 1], [430, 46, 2], [433, 82, 1],
	[296, 110, 1], [352, 108, 2], [226, 104, 1], [414, 102, 1],
]
const INK := Color("#d6452f")
const INK_DARK := Color("#a8321f")
const INK_SHINE := Color("#ef7a5a")

var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()

var splattered := false:
	set(value):
		splattered = value
		queue_redraw()


func _draw() -> void:
	if not splattered:
		return
	for d in DRIPS:
		var length := roundi(d[2] * pow(progress, 0.7))
		if length < 1:
			continue
		draw_rect(Rect2(d[0], d[1], 2, length), INK)
		draw_rect(Rect2(d[0] + 1, d[1], 1, length), INK_DARK)
		draw_rect(Rect2(d[0] - 1, d[1] + length, 4, 2), INK)
		draw_rect(Rect2(d[0], d[1] + length, 1, 1), INK_SHINE)
	for s in SPLATTER:
		draw_rect(Rect2(s[0], s[1], s[2], s[2]), INK)
