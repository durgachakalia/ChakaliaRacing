extends CharacterBody3D
class_name PlayerVehicle

signal speed_changed(value: float)
signal collision_hit

@export var max_forward_speed := 34.0
@export var max_reverse_speed := 9.0
@export var acceleration := 15.0
@export var service_brake := 27.0
@export var rolling_drag := 2.8
@export var steering_rate := 1.55
@export var lateral_grip := 8.5

var speed := 0.0
var throttle := 0.0
var brake := 0.0
var steer := 0.0
var handbrake := false
var touch_left := false
var touch_right := false
var touch_drive := false
var touch_brake := false
var touch_handbrake := false
var last_collision_time := 0.0

func _physics_process(delta: float) -> void:
    var steer_axis := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
    if touch_left: steer_axis -= 1.0
    if touch_right: steer_axis += 1.0
    steer = clampf(steer_axis, -1.0, 1.0)

    throttle = maxf(Input.get_action_strength("accelerate"), 1.0 if touch_drive else 0.0)
    brake = maxf(Input.get_action_strength("brake"), 1.0 if touch_brake else 0.0)
    handbrake = Input.is_action_pressed("handbrake") or touch_handbrake

    if throttle > 0.0:
        if speed < 0.0:
            speed = move_toward(speed, 0.0, service_brake * delta)
        else:
            speed = move_toward(speed, max_forward_speed, acceleration * delta)
    elif brake > 0.0:
        if speed > 0.0:
            speed = move_toward(speed, 0.0, service_brake * delta)
        else:
            speed = move_toward(speed, -max_reverse_speed, acceleration * 0.5 * delta)
    else:
        speed = move_toward(speed, 0.0, rolling_drag * delta)

    var steer_factor := clampf(absf(speed) / 8.0, 0.12, 1.0)
    var yaw := -steer * steering_rate * steer_factor
    if handbrake:
        yaw *= 1.35
    if absf(speed) > 0.15:
        rotate_y(yaw * delta * signf(speed))

    var forward := -global_transform.basis.z
    var desired := forward * speed
    var grip := lateral_grip * (0.45 if handbrake else 1.0)
    velocity.x = move_toward(velocity.x, desired.x, grip * delta)
    velocity.z = move_toward(velocity.z, desired.z, grip * delta)
    if not is_on_floor():
        velocity.y -= 24.0 * delta
    else:
        velocity.y = -0.15

    var before := get_slide_collision_count()
    move_and_slide()
    if get_slide_collision_count() > 0 and Time.get_ticks_msec() - last_collision_time > 900:
        last_collision_time = Time.get_ticks_msec()
        collision_hit.emit()
        speed *= 0.68
    speed_changed.emit(speed)

func reset_vehicle(at: Vector3) -> void:
    global_position = at
    rotation = Vector3.ZERO
    velocity = Vector3.ZERO
    speed = 0.0
