extends Node2D
class_name Hero

@export var attack:int
@export var life:int
@export var attackInterval:float
var enemy:Hero
var is_alive: bool = true              # 存活状态
var is_knocked_back: bool = false      # 击退状态
var knockback_timer: float = 0.0       # 击退计时器
var knockback_duration: float = 0.5    # 击退持续时间（秒）

# ==================== 全局事件信号（统一监听） ====================
signal took_damage(damage: int)  # 受伤事件
signal died()                                       # 死亡事件
signal attacked(target: Hero,damage)                       # 攻击事件
signal knockback_started()                          # 击退开始
signal knockback_ended()                            # 击退结束

func take_damage(_damage: int) -> void:
	if not is_alive:
		return
	
	life -= _damage
	took_damage.emit(_damage)
	
	if life <= 0:
		is_alive = false
		life = 0
		died.emit()

func start_knockback(duration: float = 0.5) -> void:
	if not is_alive:
		return
	
	is_knocked_back = true
	knockback_duration = duration
	knockback_timer = 0.0
	knockback_started.emit()

func update_knockback(delta: float) -> void:
	if not is_knocked_back:
		return
	
	knockback_timer += delta
	if knockback_timer >= knockback_duration:
		end_knockback()

func end_knockback() -> void:
	is_knocked_back = false
	knockback_timer = 0.0
	knockback_ended.emit()

func die() -> void:
	pass

func attack_enemy() -> void:
	pass

func heal(_amount: int) -> void:
	pass
