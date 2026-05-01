extends Node2D
class_name Hero

@export var attack:int
@export var life:int
@export var attackInterval:float
var enemy:Hero
var is_alive: bool = true              # 存活状态

# ==================== 全局事件信号（统一监听） ====================
signal took_damage(damage: int)  # 受伤事件
signal died()                                       # 死亡事件
signal attacked(target: Hero,damage)                       # 攻击事件

func take_damage(_damage: int) -> void:
	if not is_alive:
		return
	
	life -= _damage
	took_damage.emit(_damage)
	
	if life <= 0:
		is_alive = false
		life = 0
		died.emit()
func die() -> void:
	pass
func attack_enemy() -> void:
	pass
func heal(_amount: int) -> void:
	pass
