extends RigidBody3D
class_name Player

@export_range(750,2500) var thrust := 1000.0
@export var torque_thrust := 100.0

var transitioning := false

@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var main_booster: GPUParticles3D = $MainBooster
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not transitioning:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y * delta * thrust)
			main_booster.emitting = true
			if not rocket_audio.is_playing():
				rocket_audio.play()
				
		else:
			rocket_audio.stop()
			main_booster.emitting = false
			
		if Input.is_action_pressed("rotate_left"):
			apply_torque(Vector3(0.0, 0.0, delta*torque_thrust))
			right_booster.emitting = true
		else:
			right_booster.emitting = false
			
			
		if Input.is_action_pressed("rotate_right"):
			apply_torque(Vector3(0.0, 0.0, -delta*torque_thrust))
			left_booster.emitting = true
		else:
			left_booster.emitting = false
			

func crash_sequence() -> void:
	transitioning = true
	print("Kaboom!")
	rocket_audio.stop()
	main_booster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	explosion_audio.play()
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()
	
func level_complete(next_level_file) -> void:
	transitioning = true
	rocket_audio.stop()
	main_booster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	success_audio.play()
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
	
func _on_body_entered(body: Node) -> void:
	if not transitioning:
		if "Goal" in body.get_groups():
			print('You win!')
			if body.file_path:
				level_complete(body.file_path)
			else:
				print("No next level found!")

		if "Hazard" in body.get_groups():
			crash_sequence()
