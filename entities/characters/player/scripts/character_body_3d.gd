extends CharacterBody3D

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var spritesheets: Dictionary[String, Texture2D] = {
	"walk": preload("res://entities/characters/player/assets/standard/walk.png"),
	"idle": preload("res://entities/characters/player/assets/standard/idle.png")
}

func set_spritesheet(animation_name: String) -> void:
	if animation_name in spritesheets:
		sprite_3d.texture = spritesheets[animation_name]
		
func update_animation() -> void:
	var plane_velocity: Vector2 = Vector2(velocity.x, velocity.z)
	if plane_velocity == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Idle")
	else:
		$AnimationTree.get("parameters/playback").travel("Walk")
		$AnimationTree.set("parameters/Idle/blend_position", plane_velocity)
		$AnimationTree.set("parameters/Walk/blend_position", plane_velocity)

func _ready() -> void:
	anim_player.animation_changed.connect(set_spritesheet)

const SPEED: float = 2.0
const JUMP_VELOCITY: float = 4.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()
		
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	update_animation()

	move_and_slide()
