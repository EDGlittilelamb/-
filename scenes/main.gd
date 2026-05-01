extends Node2D

@export var player_scene: PackedScene
@export var field: StaticBody2D
var p1:Hero
var p2:Hero
# 配置
const INIT_SPEED = 300  # 初始速度大小
const PLAYER_OFFSET = 150 # 中心两侧偏移量

func _ready():
	spawn_players()
	await get_tree().physics_frame
	p1.unlock_player_movement()
	p2.unlock_player_movement()


func spawn_players():
	var cx = 604.0  # Field中心X
	var cy = 328.0  # Field中心Y

	# ========== 生成左侧玩家 ==========
	p1 = player_scene.instantiate()
	p1.position = Vector2(cx - PLAYER_OFFSET, cy) # 设置根节点位置
	# 获取子节点刚体
	var rigid1 = p1.get_node("RigidBody2D")
	var random_radian = randf_range(0, PI * 2)
	var random_dir = Vector2.from_angle(random_radian)
	rigid1.linear_velocity = random_dir * INIT_SPEED
	add_child(p1)
	
	# ========== 生成右侧玩家 ==========
	p2 = player_scene.instantiate()
	p2.position = Vector2(cx + PLAYER_OFFSET, cy) # 设置根节点位置
	# 获取子节点刚体
	var rigid2 = p2.get_node("RigidBody2D")
	random_radian = randf_range(0, PI * 2)
	random_dir = Vector2.from_angle(random_radian)
	rigid2.linear_velocity = random_dir * INIT_SPEED
	add_child(p2)
	p1.enemy = p2
	p2.enemy = p1
	p1.died.connect(_on_any_hero_died.bind(p1))
	p2.died.connect(_on_any_hero_died.bind(p2))

func _on_any_hero_died(dead_hero: Hero):
	print("一个角色死亡了：", dead_hero.name)
	get_tree().paused = true
