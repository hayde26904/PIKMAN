extends Camera3D

@onready var rootNode = get_tree().get_root().get_child(0)
@onready var screenSize = get_window().size
@onready var x_bounds = rootNode.x_bounds
@onready var z_bounds = rootNode.z_bounds

var mousePos = Vector2()
var mousePos3D = Vector3.ZERO
var mouseVel = Vector2.ZERO
var mousePercentage = Vector2.ZERO

@export var lookSpd = 1
var minFov = 70
var maxFov = 120

@export var zoomAmount = 30

@onready var defaultRot = rotation

@onready var selectorBox = $Control/SelectorBox
@onready var selectorBoxArea = $Control/SelectorBox/Area2D
@onready var selectorBoxCollisionShape = $Control/SelectorBox/Area2D/CollisionShape2D
var selecting = false
var selectorBoxStartPos = Vector2.ZERO

var pman_in_selector_box = []
var controlling = []

func _input(event):
	if event is InputEventMouseMotion:
		var mouseRay = shoot_mouse_ray()
		mousePos = event.position
		if not mouseRay == {}: mousePos3D = mouseRay.position
		mouseVel = event.relative
	if event is InputEventMouseButton:
		pass

func _ready():
	position.y = (x_bounds.y - x_bounds.x)/2

func _process(delta):
	var input_dir = Input.get_vector('left','right','forward','backward')
	var lookingRotation = -input_dir.x
	
	#rotation.y += lookingRotation * lookSpd / 30
	
	screenSize = DisplayServer.screen_get_size()
	mousePercentage = Vector2(mousePos.x/screenSize.x, mousePos.y/screenSize.y).snapped(Vector2(0.01,0.01))
	
	var newCameraX = (x_bounds.y * mousePercentage.x) + x_bounds.x/2
	var newCameraZ = (z_bounds.y * mousePercentage.y)# - z_bounds.x/2
	
	if not selecting:
		position.x = lerpf(position.x, newCameraX, 0.1)
		position.z = lerpf(position.z, newCameraZ, 0.1)
		
	handle_zooming()
	handle_selector()


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
		
		for i in pman_in_selector_box:
			controlling.append(i)
			i.is_selected = true
	
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
	if Input.is_action_just_pressed('zoom_in') and fov >= minFov:
		#fov-=zoomAmount
		fov = lerpf(fov, fov - zoomAmount, 0.1)
	elif Input.is_action_just_pressed('zoom_out') and fov <= maxFov:
		#fov+=zoomAmount
		fov = lerpf(fov, fov + zoomAmount, 0.1)

func shoot_mouse_ray():
	var ray_length = 1000
	var from = project_ray_origin(mousePos)
	var to = from + project_ray_normal(mousePos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	return(raycast_result)



func _on_area_2d_area_entered(area):
	if area.is_in_group('pikman') and selecting:
		var pman = area.get_parent()
		pman_in_selector_box.append(pman)


func _on_area_2d_area_exited(area):
	if area.is_in_group('pikman') and selecting:
		var pman = area.get_parent()
		pman_in_selector_box.erase(pman)
