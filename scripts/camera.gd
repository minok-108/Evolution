extends Camera2D

const SPEED = 10

var k_position = Vector2(1200, 1200)

var k_zoom = Vector2(1, 1)

func _process(_delta):
	
	$Options/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
	$Options/Cell.text = "Cell: " + str(G.count_cell())
	$Options/Food.text = "Food: " + str(G.count_food())
	
	if Input.is_action_pressed("up"):
		k_position.y -= SPEED
	if Input.is_action_pressed("down"):
		k_position.y += SPEED
	if Input.is_action_pressed("left"):
		k_position.x -= SPEED
	if Input.is_action_pressed("right"):
		k_position.x += SPEED
	
	position.x += (k_position.x - position.x) * 0.1
	position.y += (k_position.y - position.y) * 0.1
	
	zoom.x += (k_zoom.x - zoom.x) * 0.1
	zoom.y = zoom.x
	scale.x = zoom.x
	scale.y = zoom.x
	
	
func _on_Apply_pressed():
	G.apply(float($RightPanel/SettingsEvolution/FoodSpawnInterval.text))

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
		if k_zoom.x > 0.5:
			k_zoom.x -= 0.1
	
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		if k_zoom.x < 8:
			k_zoom.x += 0.1
	
	if event is InputEventMouseButton and event.button_index == 9 and event.pressed == true:
		k_position = get_global_mouse_position()


##########
#Настройки
##########


func _on_Music_pressed():
	get_parent().get_node("Music").playing = !get_parent().get_node("Music").playing

func _on_Reset_pressed():
	for i in range(len(get_parent().get_node("Cell").get_children())):
		get_parent().get_node("Cell").get_child(i).queue_free()
	for i in range(len(get_parent().get_node("Food").get_children())):
		get_parent().get_node("Food").get_child(i).queue_free()
	get_parent().get_parent().get_node("G").spawn_cell(4000, Vector2(1200, 1200), 80, 8000, {"wall": PI / 2, "food": PI / 2, "cell": PI / 2, "nothing": PI / 2}, 0, {"wall": "turn", "food": "chase", "cell": "turn", "nothing": "move"})
