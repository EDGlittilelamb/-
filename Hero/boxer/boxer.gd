extends Hero

@onready var rb: RigidBody2D = $RigidBody2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_range_indicator: Line2D = $AttackRangeIndicator

const ATTACK_RANGE: float = 120.0
const KNOCKBACK_FORCE: float = 400.0
const BOUNDARY_DAMAGE_MULTIPLIER: float = 0.5
const ATTACK_INDICATOR_DURATION: float = 0.3
const INDICATOR_SEGMENTS: int = 32

var attack_timer: float = 0.0
var is_ready: bool = false
var enemies_in_range: Array[Hero] = []
var knockback_targets: Dictionary = {}
var attack_indicator_timer: float = 0.0
var show_attack_indicator: bool = false
var max_speed: float

func _ready():
	max_speed = rb.linear_velocity.length()
	attack_area.body_entered.connect(_on_enemy_enter_range)
	attack_area.body_exited.connect(_on_enemy_exit_range)
	_init_attack_indicator()
	if attack_range_indicator:
		attack_range_indicator.visible = false

func _init_attack_indicator():
	if not attack_range_indicator:
		return
	
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(INDICATOR_SEGMENTS + 1):
		var angle: float = (float(i) / INDICATOR_SEGMENTS) * TAU
		var point: Vector2 = Vector2(
			cos(angle) * ATTACK_RANGE,
			sin(angle) * ATTACK_RANGE
		)
		points.append(point)
	
	attack_range_indicator.points = points
	attack_range_indicator.closed = true
	attack_range_indicator.width = 4.0
	attack_range_indicator.default_color = Color(1, 0.5, 0, 0.8)

func unlock_player_movement():
	rb.freeze = false
	is_ready = true

func _physics_process(delta):
	if not is_ready:
		return
	
	update_knockback(delta)
	_update_attack_position()
	_update_attack_indicator(delta)
	
	attack_timer += delta
	if attack_timer >= attackInterval and enemies_in_range.size() > 0:
		attack_timer = 0.0
		_attack()
	
	_process_knockback(delta)
	_limit_velocity()

func _update_attack_position():
	if attack_area:
		attack_area.global_position = rb.global_position
	if attack_range_indicator:
		attack_range_indicator.global_position = rb.global_position

func _update_attack_indicator(delta):
	if not attack_range_indicator:
		return
	
	if show_attack_indicator:
		attack_indicator_timer -= delta
		if attack_indicator_timer <= 0:
			show_attack_indicator = false
			attack_range_indicator.visible = false

func _limit_velocity():
	if is_knocked_back:
		return
	
	var current_vel = rb.linear_velocity
	var current_speed = current_vel.length()
	
	if current_speed > 0:
		rb.linear_velocity = current_vel.normalized() * max_speed
	else:
		var random_radian = randf_range(0, PI * 2)
		var random_dir = Vector2.from_angle(random_radian)
		rb.linear_velocity = random_dir * max_speed

func _show_attack_indicator():
	if not attack_range_indicator:
		return
	
	show_attack_indicator = true
	attack_indicator_timer = ATTACK_INDICATOR_DURATION
	attack_range_indicator.visible = true

func _attack():
	_show_attack_indicator()
	
	for enemy in enemies_in_range:
		if enemy.is_alive and enemy != self:
			var enemy_rb: RigidBody2D = _get_enemy_rb(enemy)
			if not enemy_rb:
				continue
			
			var direction: Vector2 = (enemy_rb.global_position - rb.global_position).normalized()
			var damage: int = attack
			
			enemy.take_damage(damage)
			attacked.emit(enemy, damage)
			
			var knockback_info: Dictionary = {
				direction = direction,
				force = KNOCKBACK_FORCE,
				has_hit_boundary = false,
				damage = damage
			}
			knockback_targets[enemy] = knockback_info
			
			enemy.start_knockback(0.5)
			
			enemy_rb.apply_central_impulse(direction * KNOCKBACK_FORCE)

func _process_knockback(delta):
	var targets_to_remove: Array[Hero] = []
	
	for enemy in knockback_targets:
		var info: Dictionary = knockback_targets[enemy]
		
		if not is_instance_valid(enemy) or not enemy.is_alive:
			targets_to_remove.append(enemy)
			continue
		
		if not enemy.is_knocked_back:
			targets_to_remove.append(enemy)
			continue
		
		var enemy_rb: RigidBody2D = _get_enemy_rb(enemy)
		if not enemy_rb:
			targets_to_remove.append(enemy)
			continue
		
		_check_boundary_collision(enemy, enemy_rb, info)
	
	for enemy in targets_to_remove:
		knockback_targets.erase(enemy)

func _check_boundary_collision(enemy: Hero, enemy_rb: RigidBody2D, info: Dictionary):
	var field: Node2D = get_tree().current_scene.get_node_or_null("Field")
	
	if not field:
		return
	
	var field_center: Vector2 = field.global_position
	var half_size: float = 300.0
	var margin: float = 60.0
	
	var enemy_pos: Vector2 = enemy_rb.global_position
	var rel_pos: Vector2 = enemy_pos - field_center
	
	var hit_boundary: bool = false
	
	if abs(rel_pos.x) > half_size - margin or abs(rel_pos.y) > half_size - margin:
		hit_boundary = true
	
	if hit_boundary and not info.has_hit_boundary:
		info.has_hit_boundary = true
		var boundary_damage: int = int(info.damage * BOUNDARY_DAMAGE_MULTIPLIER)
		enemy.take_damage(boundary_damage)
		print("敌人撞到边界，造成二次伤害: ", boundary_damage)

func _get_enemy_rb(enemy: Hero) -> RigidBody2D:
	if enemy.has_node("RigidBody2D"):
		return enemy.get_node("RigidBody2D")
	return null

func _on_enemy_enter_range(body: Node2D):
	var hero: Hero = body.get_parent()
	if hero is Hero and hero != self and not enemies_in_range.has(hero):
		enemies_in_range.append(hero)

func _on_enemy_exit_range(body: Node2D):
	var hero: Hero = body.get_parent()
	if hero is Hero and enemies_in_range.has(hero):
		enemies_in_range.erase(hero)

func attack_enemy() -> void:
	pass
