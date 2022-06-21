extends KinematicBody

var direction = Vector3.BACK
var velocity = Vector3.ZERO
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var aim_turn = 0

var vertical_velocity = 0
var gravity = 20

var movement_speed = 0
var walk_speed = 4
var run_speed = 7
var acceleration = 6
var angular_acceleration = 7

var roll_magnitude = 17

var health = 50

onready var pierceBullet = preload("res://Bullets/PiercingBullet.tscn")
onready var bulletTrail = preload("res://Bullets/BulletTrail.tscn")
onready var grenade = preload("res://Bullets/Grenade.tscn")

func _ready():
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
	Global.player = self
	# Sometimes in the level design you might need to rotate the Player object itself
	# So changing the direction at the beginning
func hit(amt):
	health -= amt
	if health <= 0:
		Global.player = null
		queue_free()
	pass

func _input(event):
	
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015 #animates player with mouse movement while aiming (used in line 104)
	
	if event is InputEventKey: #checking which buttons are being pressed
		if event.as_text() == "W" || event.as_text() == "A" || event.as_text() == "S" || event.as_text() == "D" || event.as_text() == "Space":
			if event.pressed:
				get_node("Status/" + event.as_text()).color = Color("ff6666")
			else:
				get_node("Status/" + event.as_text()).color = Color("ffffff")
	if !$AnimationTree.get("parameters/roll/active"): # The "Tap To Roll" system
		if event.is_action_pressed("sprint"):
			if $roll_window.is_stopped():
				$roll_window.start()
				
		if event.is_action_released("sprint"):
			if !$roll_window.is_stopped():
				velocity = direction * roll_magnitude
				$roll_window.stop()
				$AnimationTree.set("parameters/roll/active", true)
				$AnimationTree.set("parameters/aim_transition/current", 1)
				$roll_timer.start()

func _physics_process(delta):
	shootInput()
	if !$roll_timer.is_stopped():
		acceleration = 3.5
	else:
		acceleration = 5
	
	if Input.is_action_pressed("aim"):
		$Status/Aim.color = Color("ff6666")
		if !$AnimationTree.get("parameters/roll/active"):
			$AnimationTree.set("parameters/aim_transition/current", 0)
	else:
		$Status/Aim.color = Color("ffffff")
		$AnimationTree.set("parameters/aim_transition/current", 1)
	
	
	var h_rot = $Camroot/h.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right"):
		
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
					0,
					Input.get_action_strength("forward") - Input.get_action_strength("backward"))

		strafe_dir = direction
		
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		if $shootCooldown.time_left>0:
			movement_speed = 3
			$Camroot/h/v/Camera.translation = $Camroot/h/v/Camera.translation.move_toward($Camroot/h/v/DefaultPos.translation, 1.5*delta)
		elif Input.is_action_pressed("sprint") && $AnimationTree.get("parameters/aim_transition/current") == 1:
			$Camroot/h/v/Camera.translation = $Camroot/h/v/Camera.translation.move_toward($Camroot/h/v/SprintPos.translation, 1.5*delta)
			movement_speed = run_speed
#			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1, delta * acceleration))
		else:
			#movement_speed = walk_speed
			movement_speed = run_speed
			$Camroot/h/v/Camera.translation = $Camroot/h/v/Camera.translation.move_toward($Camroot/h/v/SprintPos.translation, 1.5*delta)
#			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0, delta * acceleration))
		
	else:
		$Camroot/h/v/Camera.translation = $Camroot/h/v/Camera.translation.move_toward($Camroot/h/v/DefaultPos.translation, 1.5*delta)
#		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), -1, delta * acceleration))
		movement_speed = 0
		strafe_dir = Vector3.ZERO
		
		if $AnimationTree.get("parameters/aim_transition/current") == 0:
			direction = $Camroot/h.global_transform.basis.z
	
	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)

	move_and_slide(velocity + Vector3.DOWN * vertical_velocity, Vector3.UP)
	
	Global.playerPos = translation
	
	if !is_on_floor():
		vertical_velocity += gravity * delta
	elif Input.is_action_pressed("jump"):
		vertical_velocity = -10
	else:
		vertical_velocity = 0
	
	
	if $AnimationTree.get("parameters/aim_transition/current") == 1:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
		# Sometimes in the level design you might need to rotate the Player object itself
		# - rotation.y in case you need to rotate the Player object
	else:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)
		# lerping towards $Camroot/h.rotation.y while aiming, h_rot(as in the video) doesn't work if you rotate Player object
		
	
	strafe = lerp(strafe, strafe_dir + Vector3.RIGHT * aim_turn, delta * acceleration)
	
	$AnimationTree.set("parameters/strafe/blend_position", Vector2(-strafe.x, strafe.z))
	
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)

	#find the graph here: https://www.desmos.com/calculator/4z9devx1ky

	if velocity.length() <= walk_speed:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , iw_blend)
	else:
		$AnimationTree.set("parameters/iwr_blend/blend_amount" , wr_blend)
	
	aim_turn = 0
	
	$hitmarker.modulate.a = move_toward($hitmarker.modulate.a, 0, 2000*delta)
func _process(delta):
	pass

func shootInput():
	if Input.is_action_pressed("fire") and $shootCooldown.time_left <=0:
		#print("fire")
		
		var camera = $Camroot/h/v/Camera
		var origin = $ColorRect.rect_position
		var from = camera.project_ray_origin(origin)
		var to = from + camera.project_ray_normal(origin) * 1000
		
		var col = get_world().direct_space_state.intersect_ray(from, to,[self])
		
		var hit 
				
		if col.empty():
			pass
		else:
			if col.collider.is_in_group("enemy"):
				if rand_range(0,1) > 0.8:
					col.collider.hit(1, "burn")
				else:
					col.collider.hit(1, "default")
				$hitmarker.modulate.a = 255
				hit = true
			else:
				pass
		
		var newTrail = bulletTrail.instance()
		get_parent().add_child(newTrail)
		newTrail.translation = translation + Vector3.UP*1
		newTrail.dir = (to - newTrail.translation).normalized()
		if hit == true:
			newTrail.destination = col.position
		newTrail.look_at(newTrail.translation + newTrail.dir, Vector3.UP)
		$shootCooldown.start(0.2)	
		
	elif Input.is_action_pressed("aim") and $abilityCooldown.time_left<=0:
		var camera = $Camroot/h/v/Camera
		var origin = $ColorRect.rect_position
		
		var from = camera.project_ray_origin(origin)
		var to = from + camera.project_ray_normal(origin)*500
		#var dir =  camera.project_ray_normal(origin)
		var col = get_world().direct_space_state.intersect_ray(from, to,[self])
		var des 
		if col.empty():
			pass
		else:
			des = col.position
			#to = col.position
			pass
		
		#var newBullet = pierceBullet.instance()
		var newBullet = grenade.instance()
		get_parent().add_child(newBullet)
		newBullet.translation = from + camera.project_ray_normal(origin)*5
		#newBullet.dir = (to - newBullet.translation).normalized()
		newBullet.destination = des
		$abilityCooldown.start(1)	
		
#	$Status/Label.text = "direction : " + String(direction)
#	$Status/Label2.text = "direction.length() : " + String(direction.length())
#	$Status/Label3.text = "velocity : " + String(velocity)
#	$Status/Label4.text = "velocity.length() : " + String(velocity.length())




func _on_Area_body_entered(body):
	if body.is_in_group("loot"):
		body.queue_free()
	pass # Replace with function body.
