extends Node

var spawn_timer = 0.0
var spawn_interval = 2.0  # เริ่มต้นที่ 2 วินาที
var countdown_timer = 30.0  # เวลานับถอยหลัง
var game_won = false
var game_lost = false

var packet_scene = [
	preload("res://Enemy1.tscn"),
	preload("res://Enemy2.tscn"),
	preload("res://Enemy3.tscn"),
	preload("res://Enemy4.tscn"),
	preload("res://Enemy5.tscn"),
]

var spawn_count = 1  # เริ่มต้นที่สุ่ม 1 ตัว
var fall_speed = 100  # ความเร็วในการตกเริ่มต้นที่ 100

func _ready():
	randomize()

func _process(delta):
	if game_won or game_lost:
		return
	
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_random_objects(spawn_count)  # สุ่มตามจำนวนที่กำหนด
	
	if countdown_timer > 0:
		countdown_timer -= delta
	else:
		game_over()

	# เพิ่มจำนวนศัตรูที่สุ่มและความเร็วในการสุ่มตามเวลา
	if countdown_timer <= 20 and spawn_count == 2:
		spawn_count = 3  # หลัง 20 วินาที จะสุ่ม 3 ตัว
		spawn_interval = 0.75  # ความเร็วในการสุ่ม 1 วินาที

	elif countdown_timer <= 10 and spawn_count == 1:
		spawn_count = 2  # หลัง 10 วินาที จะสุ่ม 2 ตัว
		spawn_interval = 1  # ความเร็วในการสุ่ม 1.5 วินาที
	
	# ค่อยๆ เพิ่มความเร็วในการตก (fall_speed)
	if countdown_timer <= 20:
		fall_speed = lerp(100, 300, 1 - (countdown_timer / 20.0))  # ค่อยๆ เพิ่มความเร็วในการตก

	if countdown_timer <= 0 and not game_lost:
		game_win()

func game_win():
	game_won = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://WinScene.tscn")

func game_over():
	game_lost = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Endscene.tscn")
	countdown_timer = 30
	
	for child in get_children():
		if child is CharacterBody2D:
			child.queue_free()

func spawn_random_objects(count):
	var viewport_size = get_viewport().get_visible_rect().size
	var used_positions = []  # เก็บตำแหน่ง X ที่ใช้ไปแล้ว
	
	for i in range(count):
		await get_tree().create_timer(randf_range(0.2, 0.5)).timeout  # ให้แต่ละตัวเกิดช้ากว่ากัน

		var x = randi() % packet_scene.size()
		var scene = packet_scene[x].instantiate()
		
		var random_x
		var valid_position = false
		
		while not valid_position:
			random_x = randi_range(50, int(viewport_size.x) - 70)  # คำนวณตำแหน่ง X ให้เหมาะสม
			valid_position = true
		
			# ตรวจสอบว่าตำแหน่งนี้ถูกใช้ไปแล้วหรือไม่
			for pos in used_positions:
				if abs(random_x - pos) < 50:  # ป้องกันการเกิดซ้อนกัน
					valid_position = false
					break
		
		used_positions.append(random_x)  # บันทึกตำแหน่งที่ใช้ไปแล้ว
		
		# กำหนดให้ศัตรูเกิดสูงขึ้น และตั้งค่าตำแหน่ง Y ที่สูง
		scene.position = Vector2(random_x, randi_range(-150, -50))  # ปรับตำแหน่ง Y ให้สูงขึ้น
		add_child(scene)
		
		# ตั้งค่าความเร็วในการตกให้กับแต่ละศัตรู
		if scene is RigidBody2D:
			scene.gravity_scale = fall_speed / 170.0  # ใช้ fall_speed เพื่อคุมความเร็วในการตก

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		game_over()
