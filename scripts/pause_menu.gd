extends Control
@onready var pause_menu = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	#$AnimationPlayer.play("RESET")
	pause_menu.hide()

func resume():
	get_tree().paused = false
	pause_menu.visible = false
	print("Resume")
	

func pause():
	get_tree().paused = true
	print("paused")
	#pause_menu.show()
	pause_menu.visible = true
	#$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	testEsc()

func _on_resume_button_pressed():
	resume()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func _on_pause_quit_button_pressed():
	get_tree().quit()
