extends CharacterBody3D

@onready var rootNode = get_tree().get_root().get_child(0)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var Camera = get_viewport().get_camera_3d()

@onready var outline_shader = %MeshInstance3D.mesh.material.next_pass

@export var is_selected = false

var walkSpd = 35
var walkVector = Vector3.ZERO


func _ready():
	pass

func _process(delta):
	
	$Area2D/CollisionShape2D.position = Camera.unproject_position(self.position)
	$Area2D/CollisionShape2D.scale = Vector2((1.5 - Camera.fov/100),(1.5 - Camera.fov/100)) #Makes hitboxes scale with camera zoom
	
	if is_selected:
		outline_shader.set_shader_parameter("outline_enabled", true)
	elif not is_selected:
		outline_shader.set_shader_parameter("outline_enabled", false)
	
func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_selected:
		walkVector = Vector3(Camera.mousePos3D.x - position.x, velocity.y, Camera.mousePos3D.z - position.z)
		velocity = walkVector.normalized() * walkSpd

	move_and_slide()
