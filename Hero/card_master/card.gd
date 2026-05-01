extends Sprite2D

var suit: String
var rank: String

func init_card(_suit: String, _rank: String):
	suit = _suit
	rank = _rank

	name = "Card"
	
	scale = Vector2(0.1, 0.1)
	centered = true
	
	var path = "res://Hero/card_master/img/%s_of_%s.png" % [rank, suit]
	var tex = load(path)
	if tex:
		texture = tex
