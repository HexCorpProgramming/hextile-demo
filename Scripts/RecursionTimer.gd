extends Timer

var recursion_id = 0

func _ready():
	connect("timeout",self,"timeout_recursion")
	
func timeout_recursion():
	TileManager.forget_recursion(recursion_id)
	queue_free()