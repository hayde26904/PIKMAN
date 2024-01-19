extends Node3D

@export var x_bounds = Vector2()
@export var z_bounds = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('quit'):
		get_tree().quit()
