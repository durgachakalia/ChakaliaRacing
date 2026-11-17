extends Node3D

const VEHICLE_SCRIPT = preload("res://scripts/Vehicle.gd")
const CAMERA_SCRIPT = preload("res://scripts/CameraRig.gd")
const TRAFFIC_SCRIPT = preload("res://scripts/TrafficVehicle.gd")
const COIN_SCRIPT = preload("res://scripts/Coin.gd")

var player: PlayerVehicle
var chase_camera: ChaseCamera
var ui_layer: CanvasLayer
var speed_label: Label
var status_label: Label
var coin_label: Label
var mode_label: Label
var coins := 0
var mode := "CAREER"
var checkpoint_index := 0
var checkpoints: Array[Vector3] = [Vector3(0, 0.1, 5), Vector3(0, 0.1, -32), Vector3(0, 0.1, -67)]
var checkpoint_mesh: MeshInstance3D
var parking_zone: Area3D
var car_choice := 0
var car_colors: Array[Color] = [Color(0.78,0.035,0.025), Color(0.035,0.24,0.78), Color(0.12,0.12,0.14), Color(0.82,0.62,0.06)]

func _ready() -> void:
    randomize()
    _make_environment()
    _make_city()
    _make_player()
    _make_traffic()
    _make_collectibles()
    _make_checkpoint()
    _make_ui()
    _refresh_mission()

func _process(_delta: float) -> void:
    if is_instance_valid(player):
        speed_label.text = "%03d km/h" % int(absf(player.speed) * 3.6)
        coin_label.text = "COINS  %04d" % coins
        if mode == "CAREER" and checkpoint_mesh:
            if player.global_position.distance_to(checkpoints[checkpoint_index]) < 6.0:
                checkpoint_index += 1
                if checkpoint_index >= checkpoints.size():
                    status_label.text = "Mission complete! +100 coins"
                    coins += 100
                    mode = "ENDLESS"
                    mode_label.text = "ENDLESS DRIVE"
                else:
                    _refresh_mission()
                _move_checkpoint()

func _make_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color(0.13,0.28,0.48)
    sky_mat.sky_horizon_color = Color(0.66,0.77,0.87)
    sky_mat.ground_bottom_color = Color(0.12,0.14,0.13)
    sky_mat.ground_horizon_color = Color(0.45,0.49,0.48)
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72,0.78,0.88)
    env.ambient_light_energy = 0.75
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48,-25,0)
    sun.light_energy = 1.15
    sun.shadow_enabled = true
    add_child(sun)

func _make_city() -> void:
    _box("Terrain", Vector3(0,-0.7,0), Vector3(220,1.2,220), Color(0.20,0.34,0.22), true)
    _box("MainRoad", Vector3(0,0.02,0), Vector3(17,0.14,190), Color(0.075,0.085,0.095), true)
    _box("CrossRoad", Vector3(0,0.025,-42), Vector3(105,0.14,13), Color(0.075,0.085,0.095), true)
    for z in range(-88, 92, 9):
        _box("LaneDash", Vector3(0,0.11,z), Vector3(0.20,0.025,4.0), Color(0.94,0.88,0.66), false)
    for side in [-1,1]:
        _box("Kerb", Vector3(side*8.7,0.17,0), Vector3(0.55,0.34,190), Color(0.78,0.77,0.71), true)
        for z in range(-82, 90, 24):
            _box("Walkway", Vector3(side*11.3,0.04,z), Vector3(4.7,0.18,18), Color(0.48,0.49,0.46), true)
            _building(side*randf_range(19,31), z, randf_range(9,15), randf_range(12,30), randf_range(9,16))
            _streetlight(side*9.7, z+9)
    for i in range(9):
        _box("ZebraCrossing", Vector3(-6.2+i*1.55,0.12,-48), Vector3(0.9,0.025,5.4), Color(0.9,0.91,0.87), false)
    # Parking bay
    for x in [-6,-3.6,-1.2,1.2,3.6,6]:
        _box("ParkingMark", Vector3(x,0.13,27), Vector3(0.075,0.025,10), Color(0.92,0.92,0.84), false)
    _box("ParkingStopLine", Vector3(0,0.13,32), Vector3(12,0.025,0.1), Color(1,0.82,0.2), false)

func _building(x: float, z: float, w: float, h: float, d: float) -> void:
    var palette := [Color(0.56,0.59,0.63),Color(0.68,0.62,0.52),Color(0.43,0.52,0.58),Color(0.73,0.72,0.67)]
    _box("Building", Vector3(x,h/2,z), Vector3(w,h,d), palette[randi_range(0,palette.size()-1)], true)
    var face_z := z - signf(x) * (d/2 + 0.055)
    for yy in range(3, int(h)-1, 4):
        for xx in range(-int(w/2)+1, int(w/2), 3):
            var window_color := Color(0.10,0.20,0.28) if randf() > 0.15 else Color(0.78,0.65,0.36)
            _box("Window", Vector3(x+xx,yy,face_z), Vector3(1.25,1.65,0.08), window_color, false)

func _streetlight(x: float, z: float) -> void:
    _box("LampPost", Vector3(x,2.5,z), Vector3(0.13,5.0,0.13), Color(0.12,0.13,0.14), false)
    _box("LampArm", Vector3(x-signf(x)*0.8,4.85,z), Vector3(1.7,0.12,0.12), Color(0.12,0.13,0.14), false)
    _box("LampHead", Vector3(x-signf(x)*1.48,4.73,z), Vector3(0.62,0.18,0.5), Color(1.0,0.86,0.55), false)

func _box(n: String, pos: Vector3, size: Vector3, color: Color, collision: bool) -> Node3D:
    var holder: Node3D
    if collision:
        holder = StaticBody3D.new()
        var cs := CollisionShape3D.new()
        var bs := BoxShape3D.new()
        bs.size = size
        cs.shape = bs
        holder.add_child(cs)
    else:
        holder = Node3D.new()
    holder.name = n
    holder.position = pos
    var mesh := MeshInstance3D.new()
    var bm := BoxMesh.new()
    bm.size = size
    mesh.mesh = bm
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.82
    mesh.material_override = mat
    holder.add_child(mesh)
    add_child(holder)
    return holder

func _make_car_visual(parent: Node3D, paint: Color) -> void:
    var body_mat := StandardMaterial3D.new()
    body_mat.albedo_color = paint
    body_mat.metallic = 0.5
    body_mat.roughness = 0.27
    _child_box(parent, Vector3(0,0.82,0), Vector3(1.92,0.62,4.15), body_mat)
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.055,0.13,0.19)
    glass.metallic = 0.25
    glass.roughness = 0.12
    _child_box(parent, Vector3(0,1.43,-0.24), Vector3(1.53,0.72,2.05), glass)
    var black := StandardMaterial3D.new()
    black.albedo_color = Color(0.025,0.028,0.032)
    for xx in [-1.0,1.0]:
        for zz in [-1.35,1.35]:
            var wheel := MeshInstance3D.new()
            var cyl := CylinderMesh.new()
            cyl.top_radius = 0.39
            cyl.bottom_radius = 0.39
            cyl.height = 0.25
            wheel.mesh = cyl
            wheel.rotation.z = PI/2
            wheel.position = Vector3(xx,0.48,zz)
            wheel.material_override = black
            parent.add_child(wheel)
    var lamp := StandardMaterial3D.new()
    lamp.albedo_color = Color(1.0,0.88,0.62)
    var tail := StandardMaterial3D.new()
    tail.albedo_color = Color(0.8,0.025,0.02)
    for xx in [-0.63,0.63]:
        _child_box(parent, Vector3(xx,0.89,-2.09), Vector3(0.34,0.17,0.06), lamp)
        _child_box(parent, Vector3(xx,0.89,2.09), Vector3(0.34,0.17,0.06), tail)

func _child_box(parent: Node3D, pos: Vector3, size: Vector3, material: Material) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = pos
    mesh.material_override = material
    parent.add_child(mesh)

func _make_player() -> void:
    player = PlayerVehicle.new()
    player.name = "PlayerCar"
    player.position = Vector3(0,0.15,53)
    player.set_script(VEHICLE_SCRIPT)
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.9,1.35,4.0)
    collider.shape = shape
    collider.position.y = 0.8
    player.add_child(collider)
    add_child(player)
    _make_car_visual(player, car_colors[car_choice])
    player.collision_hit.connect(_on_player_collision)

    chase_camera = Camera3D.new()
    chase_camera.set_script(CAMERA_SCRIPT)
    chase_camera.target = player
    chase_camera.current = true
    add_child(chase_camera)

func _make_traffic() -> void:
    var paints := [Color(0.04,0.28,0.76),Color(0.78,0.72,0.61),Color(0.12,0.13,0.15),Color(0.72,0.13,0.08)]
    for i in range(8):
        var traffic := TrafficVehicle.new()
        traffic.set_script(TRAFFIC_SCRIPT)
        traffic.position = Vector3(-4.7 if i%2 == 0 else 4.7,0.15,-78+i*19)
        traffic.travel_speed = 5.0 + float(i%3)*1.6
        traffic.lane_direction = 1.0 if i%2 == 0 else -1.0
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = Vector3(1.8,1.25,3.8)
        collision.shape = shape
        collision.position.y = 0.8
        traffic.add_child(collision)
        add_child(traffic)
        _make_car_visual(traffic, paints[i%paints.size()])

func _make_collectibles() -> void:
    for i in range(16):
        var coin := Area3D.new()
        coin.set_script(COIN_SCRIPT)
        coin.position = Vector3(-4.0 if i%2 == 0 else 4.0,1.15,44-i*8)
        var mesh := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.42
        cylinder.bottom_radius = 0.42
        cylinder.height = 0.13
        mesh.mesh = cylinder
        mesh.rotation.x = PI/2
        var gold := StandardMaterial3D.new()
        gold.albedo_color = Color(1.0,0.69,0.04)
        gold.metallic = 0.78
        mesh.material_override = gold
        coin.add_child(mesh)
        coin.collected.connect(_on_coin_collected)
        add_child(coin)

func _make_checkpoint() -> void:
    checkpoint_mesh = MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 2.5
    torus.outer_radius = 2.8
    checkpoint_mesh.mesh = torus
    checkpoint_mesh.position = checkpoints[0] + Vector3(0,1.5,0)
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.1,0.9,0.5,0.8)
    mat.emission_enabled = true
    mat.emission = Color(0.05,0.55,0.22)
    checkpoint_mesh.material_override = mat
    add_child(checkpoint_mesh)

func _move_checkpoint() -> void:
    if checkpoint_index < checkpoints.size():
        checkpoint_mesh.position = checkpoints[checkpoint_index] + Vector3(0,1.5,0)
    else:
        checkpoint_mesh.visible = false

func _refresh_mission() -> void:
    status_label.text = "CAREER • Checkpoint %d/%d" % [checkpoint_index+1,checkpoints.size()]

func _make_ui() -> void:
    ui_layer = CanvasLayer.new()
    add_child(ui_layer)

    var panel := PanelContainer.new()
    panel.position = Vector2(18,16)
    panel.custom_minimum_size = Vector2(250,118)
    ui_layer.add_child(panel)
    var column := VBoxContainer.new()
    panel.add_child(column)
    speed_label = Label.new()
    speed_label.text = "000 km/h"
    speed_label.add_theme_font_size_override("font_size",28)
    column.add_child(speed_label)
    status_label = Label.new()
    status_label.text = "CAREER"
    column.add_child(status_label)
    coin_label = Label.new()
    coin_label.text = "COINS  0000"
    column.add_child(coin_label)

    var brand := Label.new()
    brand.text = "CHAKALIA RACING  |  CHAKALIA SYSTEMS"
    brand.position = Vector2(18,145)
    brand.add_theme_font_size_override("font_size",15)
    ui_layer.add_child(brand)

    mode_label = Label.new()
    mode_label.text = "CAREER MODE"
    mode_label.position = Vector2(18,174)
    ui_layer.add_child(mode_label)

    _touch_button("◀",Vector2(24,570),Vector2(90,90),"left")
    _touch_button("▶",Vector2(122,570),Vector2(90,90),"right")
    _touch_button("BRAKE / REV",Vector2(1000,570),Vector2(118,88),"brake")
    _touch_button("ACCEL",Vector2(1128,570),Vector2(128,88),"drive")
    _touch_button("HANDBRAKE",Vector2(1000,475),Vector2(130,65),"handbrake")
    _touch_button("CAMERA",Vector2(1138,475),Vector2(118,65),"camera")
    _touch_button("MODE",Vector2(1120,18),Vector2(125,52),"mode")
    _touch_button("RESET",Vector2(980,18),Vector2(125,52),"reset")
    _touch_button("CAR",Vector2(840,18),Vector2(125,52),"car")

func _touch_button(text_value: String, pos: Vector2, size: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = text_value
    button.position = pos
    button.size = size
    button.add_theme_font_size_override("font_size",17)
    ui_layer.add_child(button)
    match action:
        "left":
            button.button_down.connect(_set_touch.bind("left",true))
            button.button_up.connect(_set_touch.bind("left",false))
        "right":
            button.button_down.connect(_set_touch.bind("right",true))
            button.button_up.connect(_set_touch.bind("right",false))
        "drive":
            button.button_down.connect(_set_touch.bind("drive",true))
            button.button_up.connect(_set_touch.bind("drive",false))
        "brake":
            button.button_down.connect(_set_touch.bind("brake",true))
            button.button_up.connect(_set_touch.bind("brake",false))
        "handbrake":
            button.button_down.connect(_set_touch.bind("handbrake",true))
            button.button_up.connect(_set_touch.bind("handbrake",false))
        "camera": button.pressed.connect(_toggle_camera)
        "mode": button.pressed.connect(_toggle_mode)
        "reset": button.pressed.connect(_reset_car)
        "car": button.pressed.connect(_change_car)

func _set_touch(which: String, pressed: bool) -> void:
    match which:
        "left": player.touch_left = pressed
        "right": player.touch_right = pressed
        "drive": player.touch_drive = pressed
        "brake": player.touch_brake = pressed
        "handbrake": player.touch_handbrake = pressed

func _toggle_camera() -> void:
    chase_camera.cockpit_mode = not chase_camera.cockpit_mode

func _toggle_mode() -> void:
    if mode == "CAREER":
        mode = "ENDLESS"
        checkpoint_mesh.visible = false
        mode_label.text = "ENDLESS MODE"
        status_label.text = "Drive freely and collect coins"
    else:
        mode = "CAREER"
        checkpoint_index = 0
        checkpoint_mesh.visible = true
        _move_checkpoint()
        mode_label.text = "CAREER MODE"
        _refresh_mission()

func _reset_car() -> void:
    player.reset_vehicle(Vector3(0,0.15,53))

func _change_car() -> void:
    car_choice = (car_choice + 1) % car_colors.size()
    for child in player.get_children():
        if child is MeshInstance3D:
            child.queue_free()
    _make_car_visual(player,car_colors[car_choice])
    coins = max(0,coins-10)
    status_label.text = "Garage: selected car %d (-10 coins)" % (car_choice+1)

func _on_coin_collected() -> void:
    coins += 5

func _on_player_collision() -> void:
    status_label.text = "Collision! Slow down and steer carefully."
