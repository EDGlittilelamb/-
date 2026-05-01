extends Hero

@onready var rb: RigidBody2D = $RigidBody2D
@onready var attack_area: Area2D = $AttackArea

const ATTACK_RANGE: float = 120.0
const KNOCKBACK_FORCE: float = 400.0
const BOUNDARY_DAMAGE_MULTIPLIER: float = 0.5

var attack_timer: float = 0.0
var is_ready: bool = false
var enemies_in_range: Array[Hero] = []
var knockback_targets: Dictionary = {}

func _ready():
	attack_area.body_entered.connect(_on_enemy_enter_range)
	attack_area.body_exited.connect(_on_enemy_exit_range)

func unlock_player_movement():
	rb.freeze = false
	is_ready = true

func _physics_process(delta):
	if not is_ready:
		return
	
	attack_timer += delta
	if attack_timer >= attackInterval and enemies_in_range.size() > 0:
		attack_timer = 0.0
		_attack()
	
	_process_knockback(delta)

func _attack():
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
			
			enemy_rb.apply_central_impulse(direction * KNOCKBACK_FORCE)

func _process_knockback(delta):
	var targets_to_remove: Array[Hero] = []
	
	for enemy in knockback_targets:
		var info: Dictionary = knockback_targets[enemy]
		
		if not is_instance_valid(enemy) or not enemy.is_alive:
			targets_to_remove.append(enemy)
			continue
		
		var enemy_rb: RigidBody2D = _get_enemy_rb(enemy)
		if not enemy_rb:
			targets_to_remove.append(enemy)
			continue
		
		var current_speed: float = enemy_rb.linear_velocity.length()
		
		if current_speed < 50.0:
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
