extends Node

@export var coin_scene : PackedScene
@export var powerup_scene : PackedScene
@export var playtime = 30

var level = 1
var score = 0
var time_left = 0
var screenSize = Vector2.ZERO
var playing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
	$Player.screenSize = screenSize
	$Player.hide()

func _process(_delta: float) -> void:
	if playing and get_tree().get_nodes_in_group("coins").size() == 0:
		level += 1
		time_left += 5
		spawn_coins()

func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start()
	$Player.show()
	$GameTimer.start()
	spawn_coins()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	
func spawn_coins():
	for i in level + 4:
		var c = coin_scene.instantiate()
		add_child(c)
		c.screenSize = screenSize
		c.position = Vector2(randi_range(0, screenSize.x), randi_range(0, screenSize.y))
	$LevelSound.play()

func _on_game_timer_timeout() -> void:
	time_left -=1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()

func _on_player_hurt() -> void:
	game_over()

func _on_player_pickup(type :String) -> void:
	match type:
		"coin":
			$CoinSound.play()
			score += 1
			$HUD.update_score(score)
		"powerup":
			$PowerupSound.play()
			time_left += 5
			$HUD.update_timer(time_left)
	

func game_over():
	playing = false
	$GameTimer.stop()
	get_tree().call_group("coins", "queue_free")
	$HUD.show_game_over()
	$Player.die()
	$EndSound.play()

func _on_hud_start_game() -> void:
	new_game()


func _on_powerup_timer_timeout() -> void:
	var p = powerup_scene.instantiate()
	add_child(p)
	p.screenSize = screenSize
	p.position = Vector2(randi_range(0,screenSize.x),randi_range(0,screenSize.y))
