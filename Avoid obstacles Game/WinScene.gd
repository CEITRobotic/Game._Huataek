extends Node


func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_btnreplay_pressed():
	get_tree().change_scene_to_file("res://main_scene.tscn")
