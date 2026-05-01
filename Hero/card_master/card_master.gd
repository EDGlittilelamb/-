extends Hero
@onready var bullet_handler: Node = $BulletHandler
@onready var rb: RigidBody2D = $RigidBody2D
@export var card_scene: PackedScene
const CARD_SPACING = 70
const CARD_COUNT = 5
const SPAWN_INTERVAL = 3.0
const CARD_DOWN_OFFSET = 80
var max_speed: float
var spawn_timer = 0.0
var all_cards := []
var hand = []
var damage:int
var is_ready := false
const SUITS = ["clubs", "spades", "hearts", "diamonds"]
const RANKS = ["ace","2","3","4","5","6","7","8","9","10","jack","queen","king"]

func _ready():
	# 记录角色初始速度大小
	max_speed = rb.linear_velocity.length()
	# 生成牌库
	for suit in SUITS:
		for rank in RANKS:
			all_cards.append({"suit": suit, "rank": rank})
func unlock_player_movement():
	rb.freeze = false  # 解除冻结
	is_ready = true    # 标记系统就绪
func _physics_process(delta):
	update_knockback(delta)
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		spawn_cards()
		damage = calculate_damage(hand)
		await get_tree().create_timer(1.0).timeout
		_fire_bullet()
	limit_velocity()
	
func _fire_bullet():
	if bullet_handler && enemy:
		bullet_handler.fire(attack, self, enemy)
func limit_velocity():
	if is_knocked_back:
		return
	
	var current_vel = rb.linear_velocity
	# 如果有速度，保持方向，强制设置为初始速度大小
	if current_vel.length() > 0:
		rb.linear_velocity = current_vel.normalized() * max_speed
func spawn_cards():
	clear_cards()
	var deck = all_cards.duplicate()
	deck.shuffle()

	for i in range(CARD_COUNT):
		var card = card_scene.instantiate()
		card.init_card(deck[i].suit, deck[i].rank)
		card.position.x = (i - CARD_COUNT/2.0) * CARD_SPACING
		card.position.y = CARD_DOWN_OFFSET
		rb.add_child(card)
		hand.append(card)
	
func clear_cards():
	for child in rb.get_children().duplicate():
		if child.name == "Card":
			child.queue_free()
	hand.clear()
func attack_enemy() -> void:
	pass
func calculate_damage(cards):
	var ranks = []
	var suits = []

	for c in cards:
		ranks.append(rank_to_value(c.rank))
		suits.append(c.suit)

	ranks.sort()

	var is_flush = is_all_same(suits)
	var is_straight = is_consecutive(ranks)

	var rank_count = get_rank_count(ranks)
	var counts = rank_count.values()
	counts.sort()
	counts.reverse()

	# ===== 判断牌型 =====
	if is_flush and ranks == [10,11,12,13,14]:
		return 1000 # 皇家同花顺

	if is_flush and is_straight:
		return 900 # 同花顺

	if 4 in counts:
		return 800 # 四条

	if 3 in counts and 2 in counts:
		return 700 # 葫芦

	if is_flush:
		return 600 # 同花

	if is_straight:
		return 500 # 顺子

	if 3 in counts:
		return 300 # 三条

	if counts.count(2) == 2:
		return 200 # 两对

	if 2 in counts:
		return 100 # 一对

	# 高牌
	return ranks.max() * 5
func rank_to_value(r):
	match r:
		"A":
			return 14
		"K":
			return 13
		"Q":
			return 12
		"J":
			return 11
		_:
			return int(r)
func is_all_same(arr):
	for i in arr:
		if i != arr[0]:
			return false
	return true
	
func is_consecutive(arr):
	# 处理 A2345 顺子
	if arr == [2,3,4,5,14]:
		return true

	for i in range(arr.size() - 1):
		if arr[i+1] != arr[i] + 1:
			return false
	return true
func get_rank_count(ranks):
	var dict = {}
	for r in ranks:
		if dict.has(r):
			dict[r] += 1
		else:
			dict[r] = 1
	return dict
