extends Node2D
class_name BulletHandler

@export var bullet_scene: PackedScene
var bullet: Bullet

func _ready():
	bullet = bullet_scene.instantiate()
	add_child(bullet)

# 传入：攻击者自己、攻击目标
func fire(damage: int, attacker: Hero, target: Hero):
	bullet.shot(damage, attacker, target)
