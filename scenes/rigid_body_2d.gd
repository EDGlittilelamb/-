extends RigidBody2D

# 节点就绪时连接碰撞信号
func _ready():
	# 连接【刚体碰撞进入】信号（核心碰撞检测）
	body_entered.connect(_on_body_collided)
	# 连接【刚体碰撞退出】信号（可选）
	body_exited.connect(_on_body_exited)

# 碰撞核心函数：当刚体碰到其他物理体时触发
func _on_body_collided(body: Node2D) -> void:
	# 1. 碰撞到 场地(field)
	if body.name == "Field":
		print("玩家碰到场地边界")
		# 这里可以添加自定义逻辑：比如碰撞音效、减速、反弹强化
		# apply_central_force(velocity.bounced() * 10)  # 手动强化反弹

	# 2. 碰撞到 其他玩家
	elif body.is_in_group("players"):
		print("玩家之间发生碰撞！")
		# 自定义逻辑：比如碰撞伤害、击退、特效
		# 示例：给对方一个击退力
		# var push_dir = (body.position - position).normalized()
		# body.apply_central_force(push_dir * 200)

# 可选：碰撞离开时触发
func _on_body_exited(body: Node2D) -> void:
	if body.name == "field":
		print("玩家离开场地")
