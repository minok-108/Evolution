extends KinematicBody2D

var energy = 4000
var age = 0

#Гены
var speed = 80
var energy_for_division = 8000

#покаление
var generation = 0

#Долгие действия
var move = false
var chase = false #Смотреть на цель 

#Быстрые действия
var turn = {
	"wall": PI / 2,
	"food": PI / 2,
	"cell": PI / 2,
	
	"nothing": PI / 2,
}


var behavior = {
	"wall": "turn",
	"food": "chase",
	"cell": "turn",
	
	"nothing": "move",
}

var run = Vector2(0, 0)

var visible_items = []
var target = null

func _ready():
	randomize()
	rotation = rand_range(-PI, PI)
	
	$Sprite.modulate = Color("e4c49b")
	
	if behavior.cell == "chase":
		$Sprite.modulate = Color("d7a380")

func _process(delta):
	if get_tree().paused == false:
		age += 100 * delta
		
		if age > 10000:
			death_1(1)
		
		action()
		
		if move == true:
			
			run.x = cos(rotation) * speed * delta
			run.y = sin(rotation) * speed * delta
			
			var c = move_and_collide(run)
			energy -= speed * delta
			
			if c != null:
				if c.get_collider().name.begins_with("Food") || c.get_collider().name.begins_with("@Food"):
					c.get_collider().queue_free()
					energy += 1000
				if c.get_collider().name.begins_with("Cell") || c.get_collider().name.begins_with("@Cell"):
					if behavior.cell == "chase":
						c.get_collider().sting()
		
		if chase == true:
			if is_instance_valid(target) == true:
				look_at(target.position)
				energy -= speed * delta
			else:
				chase = false
		
		if energy <= 1000:
			death_1(1)
		
		elif energy >= energy_for_division:
			G.spawn_cell(int(energy / 2), position + Vector2(20 * cos(rotation), 20 * sin(rotation)), speed, energy_for_division, turn, generation + 1, behavior)
			G.spawn_cell(int(energy / 2), position - Vector2(20 * cos(rotation), 20 * sin(rotation)), speed, energy_for_division, turn, generation + 1, behavior)
			death_2()
		
		scale.x = 1 + energy / 10000
		scale.y = scale.x


############################################################
#Функции, которые отвечают за предметы, которые видит клетка
############################################################


func _on_RadiusSearchFood_body_entered(body):
	visible_items.append(body)

func _on_RadiusSearchFood_body_exited(body):
	for i in range(len(visible_items)):
		if visible_items[i] == body:
			visible_items.remove(i)
			break


#######################################################
#Функции, показывающие, какие действия выполняет клетка
#######################################################


func action():
	chase = false
	
	if len(visible_items) > 0:
		var item = ""
		
		for i in range(len(visible_items)):
			if visible_items[i].name.begins_with("Wall"):
				item = "wall"
			elif visible_items[i].name.begins_with("Food") || visible_items[i].name.begins_with("@Food"):
				item = "food"
			elif visible_items[i].name.begins_with("Cell") || visible_items[i].name.begins_with("@Cell"):
				item = "cell"
			
			match behavior[item]:
				"move":
					move = true
					chase = false
				"chase":
					move = true
					chase = true
					if is_instance_valid(target) == false:
						target = visible_items[i]
				"turn":
					if is_instance_valid(target) == false:
						rotation += turn[item]
						energy -= 100
				"stop":
					move = false
					chase = false
	
	else:
		match behavior["nothing"]:
			"move":
				move = true
				chase = false
			"turn":
				if is_instance_valid(target) == false:
					rotation += turn["nothing"]
					energy -= 100
			"stop":
					move = false
					chase = false

func sting():
	death_1(int(energy / 1000))


#########################
#Функция выделения клетки
#########################


func _on_Cell_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("mouse_left"):
		$Target.visible = true
		G.choose_target(self)

func hide_target():
	$Target.visible = false


######################
#Функции смерти клетки
######################


func death_1(quantity_meet): #Если умер и оставил мясо
	if G.target == self:
		G.hide_characteristic()
	
	var side = int(pow(quantity_meet, 0.5))
	for x in range(side):
		for y in range(side):
			G.spawn_food(position + Vector2(x * 8, y * 8), "meet")
	queue_free()

func death_2(): #Если умер
	if G.target == self:
		G.hide_characteristic()
	queue_free()
