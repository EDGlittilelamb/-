extends CanvasLayer
var is_paused := false
# 预加载主菜单场景
@onready var menu_scene = preload("res://scenes/start_scene.tscn")
# 获取暂停UI
@onready var pause_ui: Control = $PauseUI
func _ready() -> void:
	$PauseUI/btn_resume.pressed.connect(_on_resume)
	$PauseUI/btn_menu.pressed.connect(_on_back_to_menu)
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_ui.visible = is_paused


func _on_resume():
	print("resume")
	toggle_pause()

func _on_back_to_menu():
	print("back")
	get_tree().paused = false
	get_tree().change_scene_to_packed(menu_scene)
