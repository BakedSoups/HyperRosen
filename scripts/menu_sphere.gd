extends CSGSphere3D

@export var speed:float = 0.2 / radius

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(speed * delta)

# rotation speed = 1/scale.y
#rotate_y(speed*delta)
