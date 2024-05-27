extends Node2D

func _ready():
	$Music.play()
	$TimeSpawnFood.start()
	randomize()
	
	G.spawn_cell(4000, Vector2(1200, 1200), 80, 8000, {"wall": PI / 2, "food": PI / 2, "cell": PI / 2, "nothing": PI / 2}, 0, {"wall": "turn", "food": "chase", "cell": "turn", "nothing": "move"})

func _on_Timer_timeout():
	if G.count_cell() != 0:
		for _i in range(10):
			G.spawn_food(Vector2(rand_range(50, 2350), rand_range(50, 2350)), "grass")
	else:
		$TimeSpawnFood.stop()

