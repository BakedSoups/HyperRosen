extends CharacterBody3D


@onready var stay: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !stay:
		move_toward_pwen()
		move_and_slide()


func move_toward_pwen():
	var distance = get_global_position().distance_to(GameData.player.get_node("Camera3D").get_global_position())
	if distance < 30:
		$Camera3D/AnimationPlayer.play("turn_around")
		#position = GameData.player.get_node("Camera3D").get_global_position()
	
	if distance < 3:
		position = GameData.player.get_node("Camera3D").get_global_position()
	
	if position != GameData.player.get_node("Camera3D").get_global_position():
		velocity = get_global_position().direction_to(GameData.player.get_node("Camera3D").get_global_position()) * 20


func _on_animation_player_animation_finished(anim_name):
	$Camera3D.current = false
	GameData.player.get_node("Camera3D").current = true
	queue_free()
