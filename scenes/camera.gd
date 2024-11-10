extends Node3D

@onready var camera = $Camera3D
var hyperbolic_quad: MeshInstance3D

func _ready():
	setup_effects()
	adjust_effects()

func setup_effects():
	# Set up hyperbolic effect
	hyperbolic_quad = create_effect_quad("res://scenes/hyper.gdshader")
	hyperbolic_quad.name = "HyperbolicQuad"
	add_child(hyperbolic_quad)
	
	# Set up dream effect

func create_effect_quad(shader_path: String) -> MeshInstance3D:
	var plane_mesh = QuadMesh.new()
	plane_mesh.size = Vector2(2.0, 2.0)
	
	var quad = MeshInstance3D.new()
	quad.mesh = plane_mesh
	
	var material = ShaderMaterial.new()
	var shader = load(shader_path)
	material.shader = shader
	quad.material_override = material
	
	return quad

func _process(_delta):
	if !camera:
		return
	
	var cam_pos = camera.global_position
	var cam_forward = -camera.global_transform.basis.z
	
	position_quad(hyperbolic_quad, cam_pos, cam_forward, 0.1)

func position_quad(quad: MeshInstance3D, cam_pos: Vector3, cam_forward: Vector3, distance: float):
	if quad:
		quad.global_position = cam_pos + cam_forward * distance
		quad.look_at(cam_pos, Vector3.UP)
		quad.rotate_object_local(Vector3.UP, PI)

func adjust_effects():
	# Adjust hyperbolic effect
	var hyper_material = hyperbolic_quad.material_override
	hyper_material.set_shader_parameter("hyperbolic_factor", 20)
