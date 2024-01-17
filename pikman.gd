extends CharacterBody3D

@onready var rootNode = get_tree().get_root().get_child(0)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var Camera = get_viewport().get_camera_3d()

@onready var master = rootNode.get_node("Player")

@export var following = false

func _ready():
	pass

func _process(delta):
	$Area2D/CollisionShape2D.position = Camera.unproject_position(self.position)
	$Area2D/CollisionShape2D.scale = Vector2((1.5 - Camera.fov/100),(1.5 - Camera.fov/100)) #Makes hitboxes scale with camera zoom
	
	if following:
		position.x = move_toward(position.x, master.position.x, 0.1)
		position.z = move_toward(position.z, master.position.z, 0.1)
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
