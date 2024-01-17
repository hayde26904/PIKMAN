extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var rootNode = get_tree().get_root().get_child(0)

@onready var Camera = $Camera3D
var cameraMinFov = 70
var cameraMaxFov = 110

var cameraLookPos = Vector3.ZERO
@onready var cameraDefaultRot = Camera.rotation

var mousePos = Vector2()
var mousePos3D = Vector3.ZERO
var mouseVel = Vector2.ZERO

@export var lookSpd = 1
@export var walkSpd = 5

@onready var selectorBox = $Control/SelectorBox
@onready var selectorBoxArea = $Control/SelectorBox/Area2D
@onready var selectorBoxCollisionShape = $Control/SelectorBox/Area2D/CollisionShape2D
var selecting = false
var selectorBoxStartPos = Vector2.ZERO

var party = []


func _input(event):
	if event is InputEventMouseMotion:
		var mouseRay = shoot_mouse_ray()
		mousePos = event.position
		if not mouseRay == {}: mousePos3D = mouseRay.position
		mouseVel = event.relative
	if event is InputEventMouseButton:
		pass

func _ready():
	pass

func _process(delta):
	
	print(party)
	
	handle_selector()
	handle_zooming()
	
func _physics_process(delta):
	var input_dir = Input.get_vector('left','right','forward','backward')
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	velocity.x = direction.x * walkSpd
	velocity.z = direction.z * walkSpd
	
	var lookingRotation = -input_dir.x
	rotation.y += lookingRotation * lookSpd / 30
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	
	

func handle_selector():
	if Input.is_action_just_pressed('select'):
		selecting = true
		selectorBoxStartPos = mousePos
		
		selectorBox.size.x = 0
		selectorBox.size.y = 0
		selectorBoxCollisionShape.scale = Vector2.ZERO
		
		selectorBox.position.x = selectorBoxStartPos.x
		selectorBox.position.y = selectorBoxStartPos.y
		
		selectorBox.show()
	
	if Input.is_action_just_released('select'):
		selecting = false
		selectorBox.hide()
		
	
	if selecting and not mouseVel == Vector2.ZERO:
		
		var sizeX = mousePos.x - selectorBoxStartPos.x
		var sizeY = mousePos.y - selectorBoxStartPos.y
		
		if sign(sizeX) == 1 and sign(sizeY) == 1:
			selectorBox.size.x = sizeX
			selectorBox.size.y = sizeY
		
			selectorBoxArea.position.x = sizeX/2
			selectorBoxArea.position.y = sizeY/2
		
			selectorBoxCollisionShape.scale.x = sizeX/45
			selectorBoxCollisionShape.scale.y = sizeY/45

func handle_zooming():
	if Input.is_action_just_pressed('zoom_in') and Camera.fov >= cameraMinFov:
		Camera.fov-=10
	elif Input.is_action_just_pressed('zoom_out') and Camera.fov <= cameraMaxFov:
		Camera.fov+=10

func shoot_mouse_ray():
	var ray_length = 1000
	var from = Camera.project_ray_origin(mousePos)
	var to = from + Camera.project_ray_normal(mousePos) * ray_length
	var space = Camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	return(raycast_result)


func _on_area_2d_area_entered(area):
	if area.is_in_group('pikman') and selecting:
		var pman = area.get_parent()
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = Color(1,0,0)
		pman.get_node("MeshInstance3D").set_surface_override_material(0, new_material)
		
		party.append(pman)
		pman.following = true
