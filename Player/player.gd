extends RigidBody3D
class_name Player

@export_range(750,2500) var thrust := 1000.0
@export var torque_thrust := 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, delta*torque_thrust))
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -delta*torque_thrust))

	# rotate right

func crash_sequence() -> void:
	print("Kaboom!")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()
	
func level_complete(next_level_file) -> void:
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
	
func _on_body_entered(body: Node) -> void:
	if "Goal" in body.get_groups():
		print('You win!')
		if body.file_path:
			level_complete(body.file_path)
		else:
			print("No next level found!")

	if "Hazard" in body.get_groups():
		crash_sequence()
