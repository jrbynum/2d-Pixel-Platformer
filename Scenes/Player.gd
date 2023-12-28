extends CharacterBody2D

@onready var screen_size = get_viewport_rect().size
@onready var sprint_flag : bool = false
@onready var crouch_flag : bool = false
@export var SPEED : float = 300.0
@export var air_jumps_total : int = 1
var air_jumps_current : int = air_jumps_total
@export var jump_height : float = 180
@export var jump_time_to_peak : float = .25
@export var jump_time_to_descent : float = 0.5
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


@onready var sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	#Animations
	#check left and right velocity to see if we are running or not
	#check to see if sprint is enabled
	if(velocity.x > 1 || velocity.x < -1):
			if sprint_flag :
				sprite_2d.play("running")
			else:
				sprite_2d.play("walking")
	else:
		sprite_2d.play("idle")
		
	# Check to see if we are on the floor if not add gravity.
	if not is_on_floor():
		velocity.y += get_gravity() * delta
		if velocity.y > 0:
			sprite_2d.play("falling")
	#check for the sprint toggle
	if Input.is_action_just_pressed("sprint"):
		sprint_flag = !sprint_flag
	#change speed based on the sprint flag	
	if sprint_flag :
		SPEED = 400
	else:
		SPEED = 200
	# Handle Jump.
	if Input.is_action_just_pressed("jump"): 
		if is_on_floor():
			jump();
			sprite_2d.play("jumping")
		#velocity.y = jump_velocity
		if air_jumps_current > 0 and not is_on_floor():
			air_jump();
			sprite_2d.play("jumping")
	# Get the input direction and handle the movement/deceleration.
	# Input for the x axis(horizontal) 
	# Keys A, D, and Left and Right Keyboard Arrow. Also left stick on gamepad.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		slow_friction(delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Screenwrap	
	#position.x = wrapf(position.x, 0, screen_size.x)
	#position.y = wrapf(position.y, 0, screen_size.y)
	move_and_slide()
	#check for character direction and flip sprite accordingly
	var isFacing = velocity.x
	if isFacing < 0:
		sprite_2d.flip_h = true
	if isFacing > 0:
		sprite_2d.flip_h = false

func slow_friction(d):
	velocity.x -= .02 * d

func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func jump():
	air_jumps_current = air_jumps_total
	velocity.y = jump_velocity
	
func air_jump():
	air_jumps_current -= 1
	velocity.y = jump_velocity
	
