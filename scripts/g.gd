extends Node

var s_cell = load("res://nodes/Cell.tscn")
var s_food = load("res://nodes/Food.tscn")

var if_wall; var if_food; var if_cell; var if_nothing

var items = ["wall", "food", "cell"]
var actions = ["move", "turn", "chase", "stop"]

var target

func _process(_delta):
	if is_instance_valid(target) == true:
		update_characteristic(target.energy, target.age, target.scale.x, target.speed, target.energy_for_division, target.turn, target.generation, target.behavior)

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	randomize()

func _input(event):
	if event.is_action_pressed("mouse_left") || event.is_action_pressed("mouse_right"):
		hide_characteristic()
		if is_instance_valid(target) == true:
			target.hide_target()
			target = null
	if event.is_action_pressed("space"):
		get_tree().paused = !get_tree().paused

func count_cell():
	return get_parent().get_node("Evolution/Cell").get_child_count()

func count_food():
	return get_parent().get_node("Evolution/Food").get_child_count()

func spawn_cell(energy, positionn, speed, energy_for_division, turn, generation, behavior):
	var cell = s_cell.instance()
	get_parent().get_node("Evolution/Cell").call_deferred("add_child", cell)
	cell.energy = energy
	cell.position = positionn
	cell.speed = speed + rand_range(-5, 5)
	cell.energy_for_division = energy_for_division + int(rand_range(-100, 100))
	cell.generation = generation
	
	var a = int(rand_range(0, 2.999))
	cell.turn[items[a]] = turn[items[a]] + rand_range(-PI / 18, PI  / 18)
	
	if int(rand_range(0, 10)) == 1:
		var action = actions[int(rand_range(0, 3.999))]
		var item = items[int(rand_range(0, 2.999))]
		if item != "wall" || action != "chase":
			behavior[item] = action
	
	cell.behavior = behavior.duplicate()

func spawn_food(pos, mode):
	var food = s_food.instance()
	get_parent().get_node("Evolution/Food").call_deferred("add_child", food)
	food.position = pos
	
	if mode == "grass":
		food.modulate = Color("597824")
	elif mode == "meet":
		food.modulate = Color("BE7E4A")

func apply(time_spawn_food):
	get_parent().get_node("Evolution/TimeSpawnFood").stop()
	get_parent().get_node("Evolution/TimeSpawnFood").wait_time = time_spawn_food
	get_parent().get_node("Evolution/TimeSpawnFood").start()

func choose_target(cell):
	if is_instance_valid(target) == true && target != cell:
		target.hide_target()
	target = cell
	view_characteristic()

func view_characteristic():
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic").visible = true

func hide_characteristic():
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic").visible = false

func update_characteristic(energy, age, scalee, speed, energy_for_division, turn, generation, behavior):
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Energy").text = "Energy: " + str(round(energy))
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Age").text = "Age: " + str(round(age))
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Scale").text = "Size: " + str(stepify(scalee, 0.01))
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Speed").text = "Speed: " + str(stepify(speed, 0.01))
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/EnergyForDivision").text = "Energy for division: " + str(energy_for_division)
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Generation").text = "Generation: " + str(generation)
	
	if behavior.wall != "turn":
		if_wall = "    if wall: " + str(behavior.wall) + "\n"
	else:
		if_wall = "    if wall: " + str(behavior.wall) + " (" + str(stepify(turn.wall, 0.01)) + ") " + "\n"
	
	if behavior.food != "turn":
		if_food = "    if food: " + str(behavior.food) + "\n"
	else:
		if_food = "    if food: " + str(behavior.food) + " (" + str(stepify(turn.food, 0.01)) + ") " + "\n"
	
	if behavior.cell != "turn":
		if_cell = "    if cell: " + str(behavior.cell) + "\n"
	else:
		if_cell = "    if cell: " + str(behavior.cell) + " (" + str(stepify(turn.cell, 0.01)) + ") " + "\n"
	
	if behavior.nothing != "turn":
		if_nothing = "    if nothing: " + str(behavior.nothing) + "\n"
	else:
		if_nothing = "    if nothing: " + str(behavior.nothing) + " (" + str(stepify(turn.nothing, 0.01)) + ") " + "\n"
	
	get_parent().get_node("Evolution/Camera/RightPanel/Characteristic/Behavior").text = "Behavior:\n" + if_wall + if_food + if_cell + if_nothing
