class_name Kare
extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const SPIN_TIME := 0.18
const DASH_SPEED := 700.0
const DASH_TIME := 0.15

# 0 = alt kırmızı, 1 = sağ mavi, 2 = üst yeşil, 3 = sol sarı
const POWER_COLORS := [
	Color(1.0, 0.30, 0.30),
	Color(0.30, 0.62, 1.0),
	Color(0.30, 1.0, 0.53),
	Color(1.0, 0.85, 0.30),
]

@onready var sprite: Sprite2D = $Sprite2D

var power_index := 0
var spin_target := 0.0
var spin_tween: Tween

var air_jumps := 0
var can_dash := true
var dash_timer := 0.0
var dash_dir := 1.0
var facing := 1.0
var was_on_floor := false


func _ready() -> void:
	_ensure_material()
	_apply_power_color()


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		facing = signf(direction)

	# Dash girişi (sadece sarı kenar aktifken)
	if power_index == 3 and can_dash and Input.is_action_just_pressed("dash"):
		dash_dir = facing
		dash_timer = DASH_TIME
		can_dash = false

	# Yerçekimi + süzülme
	if dash_timer <= 0.0 and not is_on_floor():
		var gravity_mult := 1.0
		if power_index == 2 and velocity.y > 0.0:
			gravity_mult = 0.35
		velocity += get_gravity() * gravity_mult * delta
		if power_index == 2 and velocity.y > 0.0:
			velocity.y = minf(velocity.y, 110.0)

	# Zıplama + çift zıplama
	if Input.is_action_just_pressed("ui_accept"):
		var first_jump := is_on_floor()
		var double_jump := (not first_jump) and power_index == 1 and air_jumps < 1
		if first_jump or double_jump:
			if not first_jump:
				air_jumps += 1
			velocity.y = JUMP_VELOCITY
			_spin()

	# Yatay hareket / dash
	if dash_timer > 0.0:
		dash_timer -= delta
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0.0
	else:
		var speed_mult := 1.6 if power_index == 0 else 1.0
		if direction != 0.0:
			velocity.x = direction * SPEED * speed_mult
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)

	move_and_slide()

	# İniş: aşağı bakan kenarın gücünü aktif et
	if is_on_floor() and not was_on_floor:
		_on_landed()
	was_on_floor = is_on_floor()


func _spin() -> void:
	spin_target += PI * 0.5
	if spin_tween and spin_tween.is_running():
		spin_tween.kill()
	spin_tween = create_tween()
	var tweener := spin_tween.tween_property(sprite, "rotation", spin_target, SPIN_TIME)
	tweener.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_landed() -> void:
	air_jumps = 0
	can_dash = true

	# Havada yarım kaldıysa dönüşü tamamla
	if spin_tween and spin_tween.is_running():
		spin_tween.kill()
		sprite.rotation = spin_target

	power_index = posmod(int(round(spin_target / (PI * 0.5))), 4)
	_apply_power_color()


func _apply_power_color() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("tint", POWER_COLORS[power_index])


func _ensure_material() -> void:
	var mat := sprite.material as ShaderMaterial
	if mat and mat.shader:
		return

	if mat == null:
		mat = ShaderMaterial.new()
		sprite.material = mat

	mat.shader = load("res://shaders/character_power.gdshader")


func reset_state() -> void:
	if spin_tween and spin_tween.is_running():
		spin_tween.kill()

	sprite.rotation = 0.0
	spin_target = 0.0
	power_index = 0
	air_jumps = 0
	can_dash = true
	dash_timer = 0.0
	dash_dir = 1.0
	facing = 1.0
	was_on_floor = false
	velocity = Vector2.ZERO
	_apply_power_color()
