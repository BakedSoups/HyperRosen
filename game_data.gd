extends Node

@onready var player = get_parent().get_child(-1).get_node("Player")
@onready var win_planet = get_parent().get_child(-1).get_node("moon_2")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("the player is :")
	print(player)
	pass
