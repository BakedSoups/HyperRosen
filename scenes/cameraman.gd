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
	var distance = position.distance_to(GameData.player.position)
	if distance < 5:
		position = GameData.player.position
	
	if position != GameData.player.position:
		velocity = position.direction_to(GameData.player.position) * 80
	else:
		$Camera3D.current = false
		GameData.player.get_node("Camera3D").current = true
		queue_free()
