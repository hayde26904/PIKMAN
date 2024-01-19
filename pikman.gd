extends CharacterBody3D

@onready var rootNode = get_tree().get_root().get_child(0)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var Camera = get_viewport().get_camera_3d()

@onready var master = rootNode.get_node("Player")

@export var selected = false

var walkSpd = randi_range(25, 50)
var walkVector = Vector3.ZERO

var redMaterial = StandardMaterial3D.new()
var greenMaterial = StandardMaterial3D.new()


func _ready():
	redMaterial.albedo_color = Color(1,0,0)
	greenMaterial.albedo_color = Color(0,1,0)

func _process(delta):
	Engine.physics_ticks_per_second = Engine.get_frames_per_second() #makes physics always smooth
	
	$Area2D/CollisionShape2D.position = Camera.unproject_position(self.position)
	$Area2D/CollisionShape2D.scale = Vector2((1.5 - Camera.fov/100),(1.5 - Camera.fov/100)) #Makes hitboxes scale with camera zoom
	
	if selected:
		$MeshInstance3D.set_surface_override_material(0, redMaterial)
	elif not selected:
		$MeshInstance3D.set_surface_override_material(0, greenMaterial)
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if selected:
		walkVector = Vector3(Camera.mousePos3D.x - position.x, 0, Camera.mousePos3D.z - position.z)
		velocity = walkVector.normalized() * walkSpd

	move_and_slide()
