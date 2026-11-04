extends SceneTree


func check(condition: bool, message: String) -> void:
	if not condition:
		printerr("FAIL: " + message)
		quit(1)


func run_throw(scene: Node2D) -> void:
	for i in 400:
		scene._process(0.016)
		if scene.state != scene.State.THROWING:
			return


func _initialize() -> void:
	var scene: Node2D = load("res://scenes/title.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.state == scene.State.INTRO, "starts in intro")
	scene.state = scene.State.MENU
	scene._choose(1)
	check(scene.thrown == 0, "options pick throws the start orb")
	run_throw(scene)
	check(scene.state == scene.State.OPTIONS, "options opens after the throw")
	check(scene.options_panel.visible, "options panel shown")
	check(not scene.orbs[0].visible, "thrown orb hidden")
	scene._back()
	check(scene.state == scene.State.POP, "back starts the pop")
	check(not scene.options_panel.visible, "options panel hidden")
	scene.state = scene.State.MENU
	scene._choose(0)
	check(scene.thrown == 1, "start pick throws the options orb")
	run_throw(scene)
	check(scene.state == scene.State.START, "start begins after the throw")
	print("ok")
	quit()
