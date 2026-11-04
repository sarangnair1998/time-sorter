extends Node2D

enum State { INTRO, MENU, THROWING, OPTIONS, POP, START }

const GRAVITY := 1500.0
const ORB_IN_HAND := Vector2(-42, 33)
const STAMP_PIVOT := Vector2(320, 98)
const STAMP_REST := Vector2(211, -37)
const RELEASE_TIME := 0.47
const POSES := [
	[0.0, 0.0, 0.0], [0.12, -20.0, -15.0], [0.32, 65.0, -45.0], [0.47, 72.0, 35.0],
	[0.6, 80.0, 35.0], [0.7, 80.0, 35.0], [1.1, 0.0, 0.0],
]
const POP_SIZES := [14.0, 30.0, 44.0, 58.0, 54.0]

var state := State.INTRO
var chosen := -1
var thrown := -1
var throw_time := 0.0
var released := false
var orb_velocity := Vector2.ZERO
var orb_age := 0.0
var orb_free := [false, false]

@onready var tentacle_left: AnimatedSprite2D = $TentacleLeft
@onready var tentacle_right: AnimatedSprite2D = $TentacleRight
@onready var head: AnimatedSprite2D = $Head
@onready var thrown_orbs: Node2D = $ThrownOrbs
@onready var arms: Array[CanvasGroup] = [$ArmLeft, $ArmRight]
@onready var orbs: Array[Sprite2D] = [$OrbLeft, $OrbRight]
@onready var ink: Sprite2D = $Ink
@onready var drips: Node2D = $Drips
@onready var stamp: Sprite2D = $Stamp
@onready var dim: ColorRect = $Dim
@onready var fade: ColorRect = $Fade
@onready var wipe: Node2D = $Wipe
@onready var puff: Node2D = $Puff
@onready var options_panel: Control = $UI/Options
@onready var start_card: Control = $UI/StartCard
@onready var volume_slider: HSlider = $UI/Options/Box/Row/Volume
@onready var volume_value: Label = $UI/Options/Box/Row/Value


func _ready() -> void:
	tentacle_left.sprite_frames = _strip("res://assets/art/tentacles_left.png", 160, 360, 24)
	tentacle_right.sprite_frames = _strip("res://assets/art/tentacles_right.png", 160, 360, 24)
	head.sprite_frames = _strip("res://assets/art/head.png", 202, 208, 12)
	for sprite in [tentacle_left, tentacle_right, head]:
		sprite.animation = "loop"
		sprite.stop()
	volume_slider.value_changed.connect(_on_volume_changed)
	$UI/Options/Box/Back.pressed.connect(_back)
	$UI/StartCard/Box/Again.pressed.connect(get_tree().reload_current_scene)
	_on_volume_changed(volume_slider.value)
	_play_intro()


func _strip(path: String, width: int, height: int, count: int) -> SpriteFrames:
	var texture: Texture2D = load(path)
	var frames := SpriteFrames.new()
	frames.add_animation("loop")
	for i in count:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(i * width, 0, width, height)
		frames.add_frame("loop", frame)
	return frames


func _bob(tick: int) -> int:
	return roundi(5.0 * absf(sin(PI * tick / 12.0)))


func _process(delta: float) -> void:
	var tick := int(Time.get_ticks_msec() / 100.0) % 24
	tentacle_left.frame = tick
	tentacle_right.frame = tick
	head.frame = tick % 12
	head.position.y = 83 - _bob(tick)
	for arm in arms:
		arm.position.y = 250 - roundi(0.6 * _bob(tick - 1))
	if state == State.THROWING:
		_update_throw(delta)
	_place_orbs()
	_update_cursor()


func _place_orbs() -> void:
	for side in 2:
		if not orb_free[side]:
			orbs[side].global_position = arms[side].get_node("Upper/Forearm").to_global(ORB_IN_HAND)
	if thrown >= 0:
		puff.global_position = orbs[thrown].global_position


func _update_cursor() -> void:
	var hovering := false
	if state == State.MENU:
		var mouse := get_global_mouse_position()
		for orb in orbs:
			hovering = hovering or mouse.distance_to(orb.global_position) < 30.0
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if hovering else Input.CURSOR_ARROW)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		return
	if state != State.MENU:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse := get_global_mouse_position()
		for side in 2:
			if mouse.distance_to(orbs[side].global_position) < 30.0:
				_choose(side)
				return


func _choose(side: int) -> void:
	chosen = side
	thrown = 1 - side
	throw_time = 0.0
	released = false
	state = State.THROWING


func _pose(time: float) -> Vector2:
	if time >= 1.1:
		return Vector2.ZERO
	var i := 0
	while time >= POSES[i + 1][0]:
		i += 1
	var u: float = (time - POSES[i][0]) / (POSES[i + 1][0] - POSES[i][0])
	var e := _ease(i, u)
	return Vector2(lerpf(POSES[i][1], POSES[i + 1][1], e), lerpf(POSES[i][2], POSES[i + 1][2], e))


func _ease(segment: int, u: float) -> float:
	match segment:
		0, 3:
			return 1.0 - (1.0 - u) * (1.0 - u)
		1:
			return u * u * (3.0 - 2.0 * u)
		5:
			return 2.0 * u * u if u < 0.5 else 1.0 - 2.0 * (1.0 - u) * (1.0 - u)
	return u


func _set_arm_pose(side: int, upper: float, forearm: float) -> void:
	arms[side].get_node("Upper").rotation_degrees = upper
	arms[side].get_node("Upper/Forearm").rotation_degrees = forearm


func _update_throw(delta: float) -> void:
	throw_time += delta
	var pose := _pose(throw_time)
	_set_arm_pose(thrown, pose.x, pose.y)
	var orb := orbs[thrown]
	if not released and throw_time >= RELEASE_TIME:
		released = true
		orb_free[thrown] = true
		orb.reparent(thrown_orbs)
		orb_velocity = Vector2(-55.0 if thrown == 1 else 55.0, -390.0)
		orb_age = 0.0
	if released:
		orb_velocity.y += GRAVITY * delta
		orb.global_position += orb_velocity * delta
		orb_age += delta
		var shrink := 1.0 if orb_age < 0.12 else 0.85 if orb_age < 0.24 else 0.7 if orb_age < 0.36 else 0.55
		orb.scale = Vector2(shrink, shrink)
		if orb.global_position.y > 420.0:
			_after_throw()


func _after_throw() -> void:
	orbs[thrown].visible = false
	_set_arm_pose(thrown, 0.0, 0.0)
	if chosen == 0:
		_start_game()
	else:
		state = State.OPTIONS
		options_panel.visible = true
		volume_slider.grab_focus()


func _back() -> void:
	if state != State.OPTIONS:
		return
	options_panel.visible = false
	state = State.POP
	var orb := orbs[thrown]
	orb.reparent(self)
	move_child(orb, head.get_index() + 1)
	orb_free[thrown] = false
	orb.visible = true
	var tween := create_tween()
	tween.tween_method(_pop, 0.0, 1.0, 0.45)
	tween.tween_callback(_pop_done)


func _pop(progress: float) -> void:
	var index := mini(int(progress * 5.0), 4)
	var size: float = POP_SIZES[index]
	orbs[thrown].scale = Vector2.ONE * (size / 54.0)
	puff.progress = progress


func _pop_done() -> void:
	orbs[thrown].scale = Vector2.ONE
	puff.progress = 0.0
	thrown = -1
	chosen = -1
	state = State.MENU


func _start_game() -> void:
	state = State.START
	wipe.global_position = orbs[0].global_position
	var tween := create_tween()
	tween.tween_property(wipe, "radius", 720.0, 0.54).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(fade, "color:a", 1.0, 0.36)
	tween.tween_callback(func() -> void:
		start_card.visible = true
		$UI/StartCard/Box/Again.grab_focus())


func _on_volume_changed(value: float) -> void:
	volume_value.text = str(int(value))
	AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))


func _play_intro() -> void:
	var tween := create_tween()
	tween.tween_interval(0.35)
	tween.tween_callback(func() -> void: stamp.visible = true)
	tween.tween_method(_stamp_arrives, 0.0, 1.0, 0.21)
	tween.tween_callback(_stamp_lands)
	tween.tween_interval(0.2)
	tween.tween_method(_stamp_leaves, 0.0, 1.0, 0.4)
	tween.tween_callback(_intro_done)


func _place_stamp(stamp_scale: float, drop: float = 0.0) -> void:
	stamp.scale = Vector2.ONE * stamp_scale
	stamp.position = STAMP_PIVOT + (STAMP_REST + Vector2(0, drop) - STAMP_PIVOT) * stamp_scale
	dim.color.a = minf(0.5, (stamp_scale - 1.0) * 0.12)


func _stamp_arrives(progress: float) -> void:
	_place_stamp(roundf(1.0 + 3.0 * (1.0 - progress * progress)))


func _stamp_leaves(progress: float) -> void:
	_place_stamp(roundf(1.0 + 4.0 * progress * progress))


func _stamp_lands() -> void:
	_place_stamp(1.0, 2.0)
	ink.visible = true
	drips.splattered = true
	var shake := create_tween()
	for i in 4:
		shake.tween_property(self, "position:x", 2.0 if i % 2 else -2.0, 0.035)
	shake.tween_property(self, "position:x", 0.0, 0.035)
	var settle := create_tween()
	settle.tween_interval(0.06)
	settle.tween_callback(func() -> void: _place_stamp(1.0))
	var run := create_tween()
	run.tween_interval(0.22)
	run.tween_property(drips, "progress", 1.0, 1.8)


func _intro_done() -> void:
	stamp.visible = false
	dim.color.a = 0.0
	state = State.MENU
