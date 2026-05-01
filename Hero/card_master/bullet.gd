extends Area2D
class_name Bullet

var damage: int
var move_dir: Vector2
const SPEED = 600
var is_active: bool = false
var attacker: Hero  # 存储发射者

func _ready():
	visible = false
	monitoring = false
	is_active = false
	body_entered.connect(_on_hit)

func shot(damage_val: int, _attacker: Hero, target: Hero):
	if is_active: return

	damage = damage_val
	attacker = _attacker
	is_active = true

	var spawn_pos = attacker.rb.global_position
	var target_pos = target.rb.global_position

	# ✅ 关键：子弹出生位置【往前挪一点】，避免和自己重叠
	move_dir = (target_pos - spawn_pos).normalized()
	global_position = spawn_pos + move_dir * 20  # 向前偏移20像素

	visible = true
	monitoring = true

func _process(delta):
	if is_active:
		global_position += move_dir * SPEED * delta

func _on_hit(body: Node2D):
	
	if not is_active:
		return

	var hit_hero = body.get_parent()
	
	if hit_hero == attacker:
		return

	# 只有碰到敌人，才造成伤害
	if hit_hero is Hero:
		hit_hero.take_damage(damage)
		print("命中敌人！")
	print(body)
	reset_bullet()

func reset_bullet():
	is_active = false
	visible = false
	monitoring = false
	move_dir = Vector2.ZERO
	attacker = null
