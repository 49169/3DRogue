extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Tween.interpolate_property(get_node("Sprite3D"), "translation",
		Vector3(0, 0, 0), Vector3(0, 1,0), 0.4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_Tween_tween_completed(object, key):
	queue_free()
	pass # Replace with function body.
