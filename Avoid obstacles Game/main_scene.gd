extends Node 

var spawn_timer = 0.0  
var spawn_interval = 1.0  
var countdown_timer = 30.0  
var game_won = false  
var game_lost = false  

var packet_scene = [
	preload("res://Enemy1.tscn"),
	preload("res://Enemy2.tscn"), 
	preload("res://Enemy3.tscn"), 
] 

func _ready():
	randomize()  

func _process(delta):
	if game_won or game_lost:
		return  
	
	spawn_timer += delta  
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0  
		spawn_random_object()
		
	if countdown_timer > 0:
		countdown_timer -= delta
	else:
		game_over()

	if countdown_timer <= 0 and not game_won:
		_gamewin()

func _input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("spacebar"):  
		if game_lost or game_won: 
			restart_game()

func _gamewin():
	game_won = true  
	$Label.text = "You Win! Press Space or Enter to Restart"

func game_over():
	game_lost = true
	$Label.text = "Game Over! Press Space or Enter to Restart"  
	
	for child in get_children():
		if child is CharacterBody2D:  
			child.queue_free()

func is_game_over() -> bool:
	return countdown_timer <= 0  

func restart_game(): 
	get_tree().reload_current_scene()  

func spawn_random_object():
	var x = randi() % packet_scene.size()
	var scene = packet_scene[x].instantiate()
	
	var viewport_size = get_viewport().get_visible_rect().size
	
	var random_position = Vector2(
		randi_range(0, int(viewport_size.x)),
		0  
	) 
	
	scene.position = random_position
	add_child(scene)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		game_over()  
