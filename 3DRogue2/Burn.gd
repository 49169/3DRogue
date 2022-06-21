extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var active = false

# Called when the node enters the scene tree for the first time.

func activate():
	active = true
	get_parent().get_parent().get_node("CPUParticles").emitting = true
	$BurnTimer.start(3)
	
func update():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active and $dmgTimer.time_left<=0:
		get_parent().get_parent().burnHit(1)
		$dmgTimer.start(1)
	pass


func _on_BurnTimer_timeout():
	get_parent().get_parent().get_node("CPUParticles").emitting = false
	active = false
	pass # Replace with function body.
