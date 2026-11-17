extends Camera3D
class_name ChaseCamera

var target: Node3D
var cockpit_mode := false
var chase_offset := Vector3(0, 4.0, 8.5)
var cockpit_offset := Vector3(0, 1.55, -0.35)
@export var smoothing := 6.5

func _process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    var local_offset := cockpit_offset if cockpit_mode else chase_offset
    var desired := target.global_transform * Transform3D(Basis.IDENTITY, local_offset)
    global_position = global_position.lerp(desired.origin, 1.0 - exp(-smoothing * delta))
    var look_point := target.global_position + Vector3.UP * (1.15 if cockpit_mode else 1.0) + (-target.global_transform.basis.z * 5.0 if cockpit_mode else Vector3.ZERO)
    look_at(look_point, Vector3.UP)
    fov = lerpf(fov, 82.0 if absf(target.get("speed")) > 20.0 else 72.0, delta * 2.0)
