extends Node2D
@onready var quit: Button = $Quit
@onready var start: Button = $Start

# 按钮点击绑定
func _ready():
	start.pressed.connect(_on_start_game)
	quit.pressed.connect(_on_exit_game)

# 开始游戏 → 跳转到 main 场景
func _on_start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# 退出游戏 → 直接关闭
func _on_exit_game():
	get_tree().quit()
