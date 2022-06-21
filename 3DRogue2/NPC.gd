extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var health = 10
onready var redMat = preload("res://RedMat.tres")
onready var defaultMat = preload("res://DefaultMat.tres")
onready var loot = preload("res://Loot.tscn")
onready var dmgPopup = preload("res://Bullets/DmgPopup.tscn")

var gravity = 0

var path = []
var path_node = 0

enum state  {
	burn,
	default
}

var currentState = state.default

var knockback = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.npcList = self
	#$StateMachine/Burn.activate()
	pass # Replace with function body.

func _physics_process(delta):
	#path = Global.nav.get_simple_path(global_transform.origin, Global.playerPos)
	#path_node = 0
	if !is_on_floor():
		gravity += 9.8
	else:
		gravity = 0
				
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node +=1
			pass
		else:
			#move_and_slide(direction.normalized()*3.2 + (gravity*Vector3.DOWN), Vector3.UP)
			pass
	else:
		#move_and_slide((gravity*Vector3.DOWN), Vector3.UP)
			#print("moving")
		pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	knockback = knockback.move_toward(Vector3.ZERO,10 * delta)
	if $Timer.time_left >0:
		$MeshInstance.set_material_override(redMat)
		#move_and_slide(knockback)
	else:
		$MeshInstance.set_material_override(defaultMat)
	
	var dir = (Global.playerPos - translation).normalized()
	if knockback != Vector3.ZERO:
		#move_and_slide(knockback)
		pass
	else:
		move_and_slide(dir*3.2 + (gravity*Vector3.DOWN))
		pass
		
	if (Global.playerPos - translation).length() <= 2:
		if $attackTimer.time_left <=0 and Global.player != null:
			$attackTimer.start(1)
			Global.player.hit(10)
			print("attack")
	pass

func hit(amt, type):
	#$StateMachine/Burn.activate()
	if type == "burn":
		$StateMachine/Burn.activate()
	health -= amt
	$Timer.start(0.1)
	var dir = (Global.playerPos - translation).normalized()
	knockback = -dir * 10
	
	var newPopup = dmgPopup.instance()
	add_child(newPopup)
	newPopup.translation = Vector3.UP * 1
	newPopup.get_node("Sprite3D/Viewport/Label").text = str(amt)
	
	
	if health <= 0:
		var newLoot = loot.instance()
		get_parent().add_child(newLoot)
		newLoot.translation = translation
		queue_free()

func burnHit(amt):
	health -= amt
	
	var newPopup = dmgPopup.instance()
	add_child(newPopup)
	newPopup.translation = Vector3.UP * 1
	newPopup.get_node("Sprite3D/Viewport/Label").text = str(amt)
	
	
	if health <= 0:
		var newLoot = loot.instance()
		get_parent().add_child(newLoot)
		newLoot.translation = translation
		queue_free()
	

	
