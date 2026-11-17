extends Area3D
class_name RoadCoin

signal collected

var spin_rate := 2.2

func _ready() -> void:
    var collision := CollisionShape3D.new()
    var sphere := SphereShape3D.new()
    sphere.radius = 1.15
    collision.shape = sphere
    add_child(collision)
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    rotate_y(spin_rate * delta)

func _on_body_entered(body: Node3D) -> void:
    if body is PlayerVehicle:
        collected.emit()
        queue_free()
