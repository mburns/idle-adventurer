class_name CharacterVisualizer3D
extends Node3D

# 3D Character visualization system using Skeleton3D for different races

@onready var skeleton: Skeleton3D
@onready var mesh_instance: MeshInstance3D
@onready var animation_player: AnimationPlayer
@onready var animation_tree: AnimationTree

# Equipment meshes
var equipment_meshes: Dictionary = {}

# Character reference
var character: Character

# Race-specific skeleton configurations
var race_skeletons: Dictionary = {}
var race_meshes: Dictionary = {}

# Animation states
enum VisualState {
	IDLE,
	WORKING,
	COMBAT_READY,
	CASTING,
	RESTING
}

var current_visual_state: VisualState = VisualState.IDLE

# Character appearance modifiers
var character_height: float = 1.0
var character_width: float = 1.0
var character_scale: Vector3 = Vector3.ONE

func _ready():
	setup_3d_character()
	load_race_skeletons()
	connect_to_character_events()

func setup_3d_character():
	# Create the main skeleton
	skeleton = Skeleton3D.new()
	skeleton.name = "CharacterSkeleton"
	add_child(skeleton)

	# Create mesh instance for the character body
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "CharacterMesh"
	skeleton.add_child(mesh_instance)

	# Create equipment mesh instances
	create_equipment_meshes()

	# Setup animation system
	setup_animation_system()

	# Create basic humanoid skeleton structure
	create_basic_skeleton()

	# Create initial human avatar
	create_human_avatar()

func create_basic_skeleton():
	"""Create a basic humanoid skeleton structure using SkeletonProfileHumanoid"""
	# Clear existing bones
	skeleton.clear_bones()

	# Use SkeletonProfileHumanoid for standard bone structure
	var profile = SkeletonProfileHumanoid.new()
	skeleton.skeleton_profile = profile

	# Add root bone
	skeleton.add_bone("Root")
	skeleton.set_bone_pose_position(0, Vector3.ZERO)
	skeleton.set_bone_pose_rotation(0, Quaternion.IDENTITY)
	skeleton.set_bone_pose_scale(0, Vector3.ONE)

	# Add spine bones
	skeleton.add_bone("Spine")
	skeleton.set_bone_parent(1, 0)
	skeleton.set_bone_pose_position(1, Vector3(0, 0.5, 0))

	skeleton.add_bone("Chest")
	skeleton.set_bone_parent(2, 1)
	skeleton.set_bone_pose_position(2, Vector3(0, 0.5, 0))

	skeleton.add_bone("Neck")
	skeleton.set_bone_parent(3, 2)
	skeleton.set_bone_pose_position(3, Vector3(0, 0.3, 0))

	skeleton.add_bone("Head")
	skeleton.set_bone_parent(4, 3)
	skeleton.set_bone_pose_position(4, Vector3(0, 0.2, 0))

	# Add arm bones
	skeleton.add_bone("LeftShoulder")
	skeleton.set_bone_parent(5, 2)
	skeleton.set_bone_pose_position(5, Vector3(-0.3, 0.2, 0))

	skeleton.add_bone("LeftUpperArm")
	skeleton.set_bone_parent(6, 5)
	skeleton.set_bone_pose_position(6, Vector3(-0.2, 0, 0))

	skeleton.add_bone("LeftForearm")
	skeleton.set_bone_parent(7, 6)
	skeleton.set_bone_pose_position(7, Vector3(-0.2, 0, 0))

	skeleton.add_bone("LeftHand")
	skeleton.set_bone_parent(8, 7)
	skeleton.set_bone_pose_position(8, Vector3(-0.1, 0, 0))

	# Right arm bones
	skeleton.add_bone("RightShoulder")
	skeleton.set_bone_parent(9, 2)
	skeleton.set_bone_pose_position(9, Vector3(0.3, 0.2, 0))

	skeleton.add_bone("RightUpperArm")
	skeleton.set_bone_parent(10, 9)
	skeleton.set_bone_pose_position(10, Vector3(0.2, 0, 0))

	skeleton.add_bone("RightForearm")
	skeleton.set_bone_parent(11, 10)
	skeleton.set_bone_pose_position(11, Vector3(0.2, 0, 0))

	skeleton.add_bone("RightHand")
	skeleton.set_bone_parent(12, 11)
	skeleton.set_bone_pose_position(12, Vector3(0.1, 0, 0))

	# Add leg bones
	skeleton.add_bone("LeftHip")
	skeleton.set_bone_parent(13, 0)
	skeleton.set_bone_pose_position(13, Vector3(-0.2, 0, 0))

	skeleton.add_bone("LeftThigh")
	skeleton.set_bone_parent(14, 13)
	skeleton.set_bone_pose_position(14, Vector3(0, -0.3, 0))

	skeleton.add_bone("LeftShin")
	skeleton.set_bone_parent(15, 14)
	skeleton.set_bone_pose_position(15, Vector3(0, -0.3, 0))

	skeleton.add_bone("LeftFoot")
	skeleton.set_bone_parent(16, 15)
	skeleton.set_bone_pose_position(16, Vector3(0, -0.1, 0.1))

	# Right leg bones
	skeleton.add_bone("RightHip")
	skeleton.set_bone_parent(17, 0)
	skeleton.set_bone_pose_position(17, Vector3(0.2, 0, 0))

	skeleton.add_bone("RightThigh")
	skeleton.set_bone_parent(18, 17)
	skeleton.set_bone_pose_position(18, Vector3(0, -0.3, 0))

	skeleton.add_bone("RightShin")
	skeleton.set_bone_parent(19, 18)
	skeleton.set_bone_pose_position(19, Vector3(0, -0.3, 0))

	skeleton.add_bone("RightFoot")
	skeleton.set_bone_parent(20, 19)
	skeleton.set_bone_pose_position(20, Vector3(0, -0.1, 0.1))

func create_human_avatar():
	"""Create a basic human avatar that's always visible"""
	# Create a more detailed human-like mesh
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.height = 2.0
	capsule_mesh.top_radius = 0.3
	capsule_mesh.bottom_radius = 0.3

	# Create a skin-tone material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.6, 0.5) # Skin tone
	material.metallic = 0.0
	material.roughness = 0.8

	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = material
	mesh_instance.visible = true
	mesh_instance.position = Vector3(0, 1, 0)

	# Add some basic clothing/equipment to make it more visible
	create_basic_clothing()

func create_basic_clothing():
	"""Create basic clothing to make the avatar more visible"""
	# Create basic shirt
	var shirt_mesh = MeshInstance3D.new()
	shirt_mesh.name = "basic_shirt"
	var shirt_box = BoxMesh.new()
	shirt_box.size = Vector3(0.6, 0.8, 0.3)
	shirt_mesh.mesh = shirt_box

	var shirt_material = StandardMaterial3D.new()
	shirt_material.albedo_color = Color(0.2, 0.4, 0.8) # Blue shirt
	shirt_material.roughness = 0.9
	shirt_mesh.material_override = shirt_material
	shirt_mesh.position = Vector3(0, 0.2, 0)
	skeleton.add_child(shirt_mesh)

	# Create basic pants
	var pants_mesh = MeshInstance3D.new()
	pants_mesh.name = "basic_pants"
	var pants_box = BoxMesh.new()
	pants_box.size = Vector3(0.4, 1.0, 0.25)
	pants_mesh.mesh = pants_box

	var pants_material = StandardMaterial3D.new()
	pants_material.albedo_color = Color(0.3, 0.2, 0.1) # Brown pants
	pants_material.roughness = 0.9
	pants_mesh.material_override = pants_material
	pants_mesh.position = Vector3(0, -0.5, 0)
	skeleton.add_child(pants_mesh)

func create_equipment_meshes():
	"""Create mesh instances for equipment slots"""
	var equipment_slots = [
		"head", "chest", "legs", "feet", "hands",
		"main_hand", "off_hand", "back", "waist"
	]

	for slot in equipment_slots:
		var equipment_mesh = MeshInstance3D.new()
		equipment_mesh.name = slot + "_equipment"
		equipment_mesh.visible = false
		skeleton.add_child(equipment_mesh)
		equipment_meshes[slot] = equipment_mesh

func load_race_skeletons():
	"""Load race-specific skeleton configurations"""
	# Human - default proportions
	race_skeletons["Human"] = {
		"height_scale": 1.0,
		"width_scale": 1.0,
		"bone_modifiers": {}
	}

	# Dwarf - shorter, stockier
	race_skeletons["Dwarf"] = {
		"height_scale": 0.8,
		"width_scale": 1.2,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(1.0, 0.8, 1.2)},
			"Chest": {"scale": Vector3(1.2, 0.9, 1.3)},
			"LeftThigh": {"scale": Vector3(1.1, 0.8, 1.1)},
			"RightThigh": {"scale": Vector3(1.1, 0.8, 1.1)}
		}
	}

	# Elf - taller, slender
	race_skeletons["Elf"] = {
		"height_scale": 1.1,
		"width_scale": 0.9,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(0.9, 1.1, 0.9)},
			"Chest": {"scale": Vector3(0.9, 1.1, 0.9)},
			"Neck": {"scale": Vector3(0.9, 1.1, 0.9)},
			"Head": {"scale": Vector3(0.9, 1.0, 0.9)}
		}
	}

	# Halfling - very short
	race_skeletons["Halfling"] = {
		"height_scale": 0.6,
		"width_scale": 1.0,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(1.0, 0.6, 1.0)},
			"Chest": {"scale": Vector3(1.0, 0.6, 1.0)},
			"LeftThigh": {"scale": Vector3(1.0, 0.6, 1.0)},
			"RightThigh": {"scale": Vector3(1.0, 0.6, 1.0)},
			"LeftShin": {"scale": Vector3(1.0, 0.6, 1.0)},
			"RightShin": {"scale": Vector3(1.0, 0.6, 1.0)}
		}
	}

	# Dragonborn - taller, broader
	race_skeletons["Dragonborn"] = {
		"height_scale": 1.2,
		"width_scale": 1.3,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(1.2, 1.1, 1.2)},
			"Chest": {"scale": Vector3(1.3, 1.1, 1.3)},
			"Head": {"scale": Vector3(1.2, 1.1, 1.3)},
			"LeftThigh": {"scale": Vector3(1.2, 1.1, 1.2)},
			"RightThigh": {"scale": Vector3(1.2, 1.1, 1.2)}
		}
	}

	# Gnome - very short, compact
	race_skeletons["Gnome"] = {
		"height_scale": 0.7,
		"width_scale": 1.1,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(1.1, 0.7, 1.1)},
			"Chest": {"scale": Vector3(1.1, 0.7, 1.1)},
			"Head": {"scale": Vector3(1.1, 0.9, 1.1)}
		}
	}

	# Half-Orc - tall, muscular
	race_skeletons["Half-orc"] = {
		"height_scale": 1.15,
		"width_scale": 1.25,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(1.2, 1.1, 1.2)},
			"Chest": {"scale": Vector3(1.25, 1.1, 1.25)},
			"LeftThigh": {"scale": Vector3(1.2, 1.1, 1.2)},
			"RightThigh": {"scale": Vector3(1.2, 1.1, 1.2)},
			"LeftUpperArm": {"scale": Vector3(1.2, 1.1, 1.2)},
			"RightUpperArm": {"scale": Vector3(1.2, 1.1, 1.2)}
		}
	}

	# Half-Elf - slightly taller than human
	race_skeletons["Half-elf"] = {
		"height_scale": 1.05,
		"width_scale": 0.95,
		"bone_modifiers": {
			"Spine": {"scale": Vector3(0.95, 1.05, 0.95)},
			"Chest": {"scale": Vector3(0.95, 1.05, 0.95)}
		}
	}

	# Tiefling - human-like with slight modifications
	race_skeletons["Tiefling"] = {
		"height_scale": 1.0,
		"width_scale": 1.0,
		"bone_modifiers": {
			"Head": {"scale": Vector3(1.0, 1.0, 1.1)} # Slightly longer face
		}
	}

func setup_animation_system():
	"""Setup animation player and tree for character animations"""
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)

	# Create basic animations
	create_idle_animation()
	create_working_animation()
	create_combat_animation()

	# Setup animation tree
	animation_tree = AnimationTree.new()
	animation_tree.name = "AnimationTree"
	animation_tree.animation_player = animation_player
	add_child(animation_tree)

func create_idle_animation():
	"""Create idle breathing animation"""
	var animation = Animation.new()
	animation.length = 3.0
	animation.loop_mode = Animation.LOOP_LINEAR

	# Add breathing motion to chest bone
	var chest_track = animation.add_track(Animation.TYPE_POSITION_3D)
	animation.track_set_path(chest_track, NodePath("CharacterSkeleton:Chest"))
	animation.track_insert_key(chest_track, 0.0, Vector3(0, 0.5, 0))
	animation.track_insert_key(chest_track, 1.5, Vector3(0, 0.52, 0))
	animation.track_insert_key(chest_track, 3.0, Vector3(0, 0.5, 0))

	animation_player.add_animation("idle", animation)

func create_working_animation():
	"""Create working animation with arm movement"""
	var animation = Animation.new()
	animation.length = 2.0
	animation.loop_mode = Animation.LOOP_LINEAR

	# Add arm movement for working
	var left_arm_track = animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(left_arm_track, NodePath("CharacterSkeleton:LeftUpperArm"))
	animation.track_insert_key(left_arm_track, 0.0, Quaternion.from_euler(Vector3(0, 0, 0)))
	animation.track_insert_key(left_arm_track, 1.0, Quaternion.from_euler(Vector3(0, 0, 0.3)))
	animation.track_insert_key(left_arm_track, 2.0, Quaternion.from_euler(Vector3(0, 0, 0)))

	animation_player.add_animation("working", animation)

func create_combat_animation():
	"""Create combat ready pose"""
	var animation = Animation.new()
	animation.length = 1.0

	# Combat stance with raised arms
	var left_arm_track = animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(left_arm_track, NodePath("CharacterSkeleton:LeftUpperArm"))
	animation.track_insert_key(left_arm_track, 0.0, Quaternion.from_euler(Vector3(0, 0, -0.5)))

	var right_arm_track = animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(right_arm_track, NodePath("CharacterSkeleton:RightUpperArm"))
	animation.track_insert_key(right_arm_track, 0.0, Quaternion.from_euler(Vector3(0, 0, 0.5)))

	animation_player.add_animation("combat_ready", animation)

func update_character_visualization(new_character: Character):
	"""Update the 3D character visualization based on character data"""
	character = new_character
	if character == null:
		return

	# Apply race-specific skeleton modifications
	apply_race_modifications()

	# Update character scale based on stats
	update_character_scale()

	# Update character pose based on current activity
	update_character_pose()

	# Update character materials/colors
	update_character_appearance()

	# Update equipment display
	update_equipment_display()

func apply_race_modifications():
	"""Apply race-specific skeleton modifications"""
	if character == null or not race_skeletons.has(character.race):
		return

	var race_config = race_skeletons[character.race]

	# Apply overall scale
	character_height = race_config.height_scale
	character_width = race_config.width_scale

	# Apply bone-specific modifications
	for bone_name in race_config.bone_modifiers.keys():
		var bone_id = skeleton.find_bone(bone_name)
		if bone_id != -1:
			var modifiers = race_config.bone_modifiers[bone_name]

			if modifiers.has("scale"):
				skeleton.set_bone_pose_scale(bone_id, modifiers.scale)

			if modifiers.has("position"):
				skeleton.set_bone_pose_position(bone_id, modifiers.position)

			if modifiers.has("rotation"):
				skeleton.set_bone_pose_rotation(bone_id, modifiers.rotation)

func update_character_scale():
	"""Update character scale based on Constitution modifier"""
	if character == null:
		return

	var con_modifier = character.get_constitution_modifier()
	var size_modifier = 1.0 + (con_modifier * 0.05)

	character_scale = Vector3(
		character_width * size_modifier,
		character_height * size_modifier,
		character_width * size_modifier
	)

	scale = character_scale

func update_character_pose():
	"""Update character pose based on current activity"""
	if character == null:
		return

	match character.current_activity:
		"":
			set_visual_state(VisualState.IDLE)
		"Push a Rock", "Tip Over a Statue", "Lift Weights":
			set_visual_state(VisualState.WORKING)
		_:
			set_visual_state(VisualState.IDLE)

func update_character_appearance():
	"""Update character appearance based on class and stats"""
	if character == null:
		return

	# Apply class-based color tinting to materials
	var class_color = get_class_color(character.character_class)

	# Create a simple material for the character
	var material = StandardMaterial3D.new()
	material.albedo_color = class_color
	material.metallic = 0.1
	material.roughness = 0.8

	# Create a more detailed human-like mesh
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.height = 2.0
	capsule_mesh.top_radius = 0.3
	capsule_mesh.bottom_radius = 0.3

	mesh_instance.mesh = capsule_mesh
	mesh_instance.material_override = material

	# Make sure the mesh is visible
	mesh_instance.visible = true

	# Position the character properly
	mesh_instance.position = Vector3(0, 1, 0) # Center and raise above ground

func update_equipment_display():
	"""Update equipment display based on character's equipped items"""
	if character == null:
		return

	# Clear all equipment first
	for equipment_mesh in equipment_meshes.values():
		equipment_mesh.visible = false
		equipment_mesh.mesh = null

	# Display equipped items
	if character.equipment and not character.equipment.is_empty():
		for slot in character.equipment.keys():
			var item_name = character.equipment[slot]
			if item_name != "" and equipment_meshes.has(slot):
				display_equipment_item(slot, item_name)

func display_equipment_item(slot: String, item_name: String):
	"""Display a specific equipment item"""
	if not equipment_meshes.has(slot):
		return

	var equipment_mesh = equipment_meshes[slot]

	# Create a simple mesh for the equipment based on slot
	var mesh = create_equipment_mesh(slot, item_name)
	if mesh:
		equipment_mesh.mesh = mesh
		equipment_mesh.visible = true

		# Apply equipment material
		var material = create_equipment_material(item_name)
		if material:
			equipment_mesh.material_override = material

func create_equipment_mesh(slot: String, item_name: String) -> Mesh:
	"""Create a mesh for equipment based on slot type"""
	match slot:
		"head":
			# Helmet or hat
			var helmet_mesh = SphereMesh.new()
			helmet_mesh.height = 0.3
			helmet_mesh.top_radius = 0.25
			helmet_mesh.bottom_radius = 0.2
			return helmet_mesh
		"chest":
			# Armor or clothing
			var chest_mesh = BoxMesh.new()
			chest_mesh.size = Vector3(0.8, 1.0, 0.4)
			return chest_mesh
		"legs":
			# Pants or leg armor
			var legs_mesh = BoxMesh.new()
			legs_mesh.size = Vector3(0.4, 1.2, 0.3)
			return legs_mesh
		"feet":
			# Boots or shoes
			var feet_mesh = BoxMesh.new()
			feet_mesh.size = Vector3(0.3, 0.2, 0.4)
			return feet_mesh
		"hands":
			# Gloves or gauntlets
			var hands_mesh = SphereMesh.new()
			hands_mesh.height = 0.2
			hands_mesh.top_radius = 0.15
			hands_mesh.bottom_radius = 0.15
			return hands_mesh
		"main_hand", "off_hand":
			# Weapons or shields
			var weapon_mesh = BoxMesh.new()
			weapon_mesh.size = Vector3(0.1, 0.1, 1.0)
			return weapon_mesh
		"back":
			# Cloak or cape
			var cloak_mesh = BoxMesh.new()
			cloak_mesh.size = Vector3(0.6, 1.2, 0.1)
			return cloak_mesh
		"waist":
			# Belt or sash
			var belt_mesh = CylinderMesh.new()
			belt_mesh.height = 0.1
			belt_mesh.top_radius = 0.4
			belt_mesh.bottom_radius = 0.4
			return belt_mesh
		_:
			return null

func create_equipment_material(item_name: String) -> StandardMaterial3D:
	"""Create material for equipment based on item type"""
	var material = StandardMaterial3D.new()

	# Determine material properties based on item name
	if "leather" in item_name.to_lower():
		material.albedo_color = Color(0.6, 0.4, 0.2) # Brown leather
		material.roughness = 0.8
	elif "metal" in item_name.to_lower() or "steel" in item_name.to_lower():
		material.albedo_color = Color(0.7, 0.7, 0.8) # Steel gray
		material.metallic = 0.9
		material.roughness = 0.3
	elif "gold" in item_name.to_lower():
		material.albedo_color = Color(1.0, 0.8, 0.2) # Gold
		material.metallic = 0.8
		material.roughness = 0.2
	elif "cloth" in item_name.to_lower() or "robe" in item_name.to_lower():
		material.albedo_color = Color(0.3, 0.3, 0.8) # Blue cloth
		material.roughness = 0.9
	else:
		# Default equipment color
		material.albedo_color = Color(0.5, 0.5, 0.5) # Gray
		material.roughness = 0.7

	return material

func get_class_color(class_type: String) -> Color:
	"""Get color associated with character class"""
	match class_type.to_lower():
		"barbarian":
			return Color(0.8, 0.2, 0.2) # Red
		"bard":
			return Color(0.8, 0.2, 0.8) # Purple
		"cleric":
			return Color(1.0, 1.0, 0.2) # Yellow
		"druid":
			return Color(0.2, 0.8, 0.2) # Green
		"fighter":
			return Color(0.5, 0.5, 0.5) # Gray
		"monk":
			return Color(0.8, 0.6, 0.2) # Orange
		"paladin":
			return Color(0.2, 0.2, 0.8) # Blue
		"ranger":
			return Color(0.2, 0.6, 0.2) # Dark Green
		"rogue":
			return Color(0.3, 0.3, 0.3) # Dark Gray
		"sorcerer":
			return Color(0.8, 0.4, 0.8) # Magenta
		"warlock":
			return Color(0.4, 0.2, 0.8) # Dark Purple
		"wizard":
			return Color(0.2, 0.4, 0.8) # Light Blue
		_:
			return Color(0.7, 0.7, 0.7) # Default gray

func set_visual_state(state: VisualState):
	"""Set the visual state and play appropriate animation"""
	current_visual_state = state

	match state:
		VisualState.IDLE:
			play_animation("idle")
		VisualState.WORKING:
			play_animation("working")
		VisualState.COMBAT_READY:
			play_animation("combat_ready")
		VisualState.CASTING:
			play_animation("idle") # Fallback to idle
		VisualState.RESTING:
			play_animation("idle") # Fallback to idle

func play_animation(animation_name: String):
	"""Play the specified animation"""
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)

func connect_to_character_events():
	"""Connect to character manager events"""
	if has_node("/root/CharacterManager"):
		var character_manager = get_node("/root/CharacterManager")
		character_manager.character_changed.connect(_on_character_changed)

func _on_character_changed(new_character: Character):
	"""Handle character change events"""
	update_character_visualization(new_character)

# Public methods for external control
func get_character_bounds() -> AABB:
	"""Get the bounding box of the character"""
	var bounds = AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 2, 1))
	return bounds

func highlight_equipment(slot: String, highlight: bool = true):
	"""Highlight equipment slot (placeholder for future equipment system)"""
	# TODO: Implement equipment highlighting in 3D
	pass

func get_equipment_at_position(pos: Vector3) -> String:
	"""Get equipment at 3D position (placeholder)"""
	# TODO: Implement 3D equipment interaction
	return ""
