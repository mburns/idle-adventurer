extends TestBase

# Test suite for Character Visualizer system

var character_visualizer: CharacterVisualizer
var character: Character

func before_each():
    # Create a test character
    character = Character.new()
    character.name = "Test Character"
    character.race = "Human"
    character.character_class = "Fighter"
    character.strength = 16
    character.dexterity = 14
    character.constitution = 15
    character.intelligence = 12
    character.wisdom = 13
    character.charisma = 10
    character.equipment = {
        "head": "Leather Cap",
        "chest": "Chain Mail",
        "main_hand": "Longsword"
    }
    character.update_derived_stats()

    # Create character visualizer instance
    character_visualizer = CharacterVisualizer.new()

func test_character_appearance_calculation():
    # Test character appearance based on stats
    character_visualizer.update_character_appearance()

    # Character should be scaled based on Constitution
    var con_modifier = character.get_constitution_modifier()
    var expected_height = 1.0 + (con_modifier * 0.05)
    var expected_width = 1.0 + (con_modifier * 0.03)

    assert_almost_eq(character_visualizer.character_height, expected_height, 0.01)
    assert_almost_eq(character_visualizer.character_width, expected_width, 0.01)

func test_equipment_display():
    # Test equipment display
    character_visualizer.update_equipment_display()

    # Check that equipment sprites are created
    assert_true(character_visualizer.equipment_sprites.has("head"))
    assert_true(character_visualizer.equipment_sprites.has("chest"))
    assert_true(character_visualizer.equipment_sprites.has("main_hand"))
    assert_true(character_visualizer.equipment_sprites.has("off_hand"))

func test_character_pose_updates():
    # Test character pose based on activity
    character.current_activity = "Training"
    character_visualizer.update_character_pose()

    assert_eq(character_visualizer.character_pose, "working")

    character.current_activity = ""
    character_visualizer.update_character_pose()

    assert_eq(character_visualizer.character_pose, "standing")

func test_character_expression():
    # Test character expression based on charisma
    character_visualizer.update_character_expression()

    # Low charisma should result in neutral expression
    assert_eq(character_visualizer.character_expression, "neutral")

    # High charisma should result in confident expression
    character.charisma = 18
    character_visualizer.update_character_expression()

    assert_eq(character_visualizer.character_expression, "confident")

func test_visual_state_changes():
    # Test visual state changes
    character_visualizer.set_visual_state(CharacterVisualizer.VisualState.WORKING)
    assert_eq(character_visualizer.current_visual_state, CharacterVisualizer.VisualState.WORKING)

    character_visualizer.set_visual_state(CharacterVisualizer.VisualState.COMBAT_READY)
    assert_eq(character_visualizer.current_visual_state, CharacterVisualizer.VisualState.COMBAT_READY)

func test_equipment_z_index():
    # Test equipment z-index ordering
    var head_z = character_visualizer.get_equipment_z_index("head")
    var chest_z = character_visualizer.get_equipment_z_index("chest")
    var main_hand_z = character_visualizer.get_equipment_z_index("main_hand")

    # Head should be in front of chest
    assert_true(head_z > chest_z)
    # Main hand should be in front of head
    assert_true(main_hand_z > head_z)

func test_character_bounds():
    # Test character bounds calculation
    var bounds = character_visualizer.get_character_bounds()

    # Bounds should be a valid Rect2
    assert_true(bounds is Rect2)
    assert_true(bounds.size.x > 0)
    assert_true(bounds.size.y > 0)

func test_equipment_highlighting():
    # Test equipment highlighting
    character_visualizer.highlight_equipment("head", true)
    # This should not crash and equipment should be highlighted

    character_visualizer.unhighlight_equipment("head")
    # This should not crash and equipment should be unhighlighted

func test_equipment_at_position():
    # Test equipment detection at position
    var equipment_slot = character_visualizer.get_equipment_at_position(Vector2(0, 0))

    # Should return empty string if no equipment at position
    assert_eq(equipment_slot, "")

func test_character_visualization_update():
    # Test full character visualization update
    character_visualizer.update_character_visualization(character)

    # Character should be set
    assert_eq(character_visualizer.character, character)

    # Appearance should be updated
    assert_true(character_visualizer.character_height > 0)
    assert_true(character_visualizer.character_width > 0)
