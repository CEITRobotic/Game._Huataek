extends PhysicsBody2D

var end_scene = preload("res://EndScene.tscn").instantiate()
var move_speed = 500  # Adjust this value to change movement speed
var use_mouse_control = true  # Toggle between control schemes

func _physics_process(delta):
	if use_mouse_control:
		# Mouse control scheme
		var mouse_pos = get_global_mouse_position()
		var viewport_size = get_viewport_rect().size
		position.x = clamp(mouse_pos.x, 0, viewport_size.x)
		position.y = clamp(mouse_pos.y, 0, viewport_size.y)
	else:
		# WASD keyboard control scheme
		var movement = Vector2.ZERO
		
		if Input.is_action_pressed("ui_right"):
			movement.x += 10
		if Input.is_action_pressed("ui_left"):
			movement.x -= 10
		if Input.is_action_pressed("ui_down"):
			movement.y += 10
		if Input.is_action_pressed("ui_up"):
			movement.y -= 10
			
		movement = movement.normalized() * move_speed * delta
		position += movement
		
		# Clamp position within viewport for keyboard control too
		var viewport_size = get_viewport_rect().size
		position.x = clamp(position.x, 0, viewport_size.x)
		position.y = clamp(position.y, 0, viewport_size.y)
	
	# Check for collision
	if move_and_collide(Vector2.ZERO):  # Using zero movement just to check current position
		get_tree().get_root().add_child(end_scene)

func _input(event):
	# Toggle control scheme with M key
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		use_mouse_control = !use_mouse_control
		print("Switched to ", "mouse" if use_mouse_control else "WASD", " control")
