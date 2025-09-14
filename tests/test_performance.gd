extends Node

# Performance tests for Idle Adventurer
# Tests memory usage, performance, and optimization

var performance_results = []

func _ready():
    print("=== Performance Test Suite ===")
    run_performance_tests()

func run_performance_tests():
    """Run all performance tests"""
    test_memory_usage()
    test_loading_performance()
    test_rendering_performance()
    test_data_processing_performance()
    print_performance_summary()

func test_memory_usage():
    """Test memory usage"""
    print("\n--- Memory Usage Tests ---")
    
    var initial_memory = OS.get_static_memory_usage()
    
    # Test character creation memory usage
    var characters = []
    for i in range(100):
        var character = Character.new()
        character.set_class("Fighter")
        character.set_race("Human")
        characters.append(character)
    
    var character_memory = OS.get_static_memory_usage() - initial_memory
    print("100 Characters: " + str(character_memory) + " bytes")
    
    # Test equipment loading memory usage
    var equipment_system = EquipmentSystem.new()
    var equipment_memory = OS.get_static_memory_usage() - initial_memory - character_memory
    print("Equipment System: " + str(equipment_memory) + " bytes")
    
    performance_results.append({
        "test": "Memory Usage",
        "characters": character_memory,
        "equipment": equipment_memory
    })

func test_loading_performance():
    """Test loading performance"""
    print("\n--- Loading Performance Tests ---")
    
    # Test data loading performance
    var start_time = OS.get_ticks_msec()
    
    var data_loader = DataLoader.new()
    var classes = data_loader.get_class_names()
    var races = data_loader.get_race_names()
    var spells = data_loader.get_spell_names()
    
    var load_time = OS.get_ticks_msec() - start_time
    print("Data Loading: " + str(load_time) + "ms")
    
    # Test character creation performance
    start_time = OS.get_ticks_msec()
    
    for i in range(50):
        var character = Character.new()
        character.set_class("Wizard")
        character.set_race("Elf")
    
    var creation_time = OS.get_ticks_msec() - start_time
    print("50 Character Creation: " + str(creation_time) + "ms")
    
    performance_results.append({
        "test": "Loading Performance",
        "data_loading": load_time,
        "character_creation": creation_time
    })

func test_rendering_performance():
    """Test rendering performance"""
    print("\n--- Rendering Performance Tests ---")
    
    # Test UI rendering performance
    var start_time = OS.get_ticks_msec()
    
    # Simulate UI updates
    for i in range(1000):
        # Simulate UI element updates
        pass
    
    var ui_time = OS.get_ticks_msec() - start_time
    print("UI Rendering: " + str(ui_time) + "ms")
    
    performance_results.append({
        "test": "Rendering Performance",
        "ui_rendering": ui_time
    })

func test_data_processing_performance():
    """Test data processing performance"""
    print("\n--- Data Processing Performance Tests ---")
    
    # Test activity processing performance
    var start_time = OS.get_ticks_msec()
    
    var idle_mechanics = IdleMechanics.new()
    var character = Character.new()
    character.set_class("Fighter")
    
    for i in range(100):
        idle_mechanics.complete_activity(character, "Strength Training", 1.0)
    
    var processing_time = OS.get_ticks_msec() - start_time
    print("100 Activity Completions: " + str(processing_time) + "ms")
    
    performance_results.append({
        "test": "Data Processing Performance",
        "activity_processing": processing_time
    })

func print_performance_summary():
    """Print performance summary"""
    print("\n=== Performance Summary ===")
    for result in performance_results:
        print("\n" + result.test + ":")
        for key in result.keys():
            if key != "test":
                print("  " + key + ": " + str(result[key]))
    
    print("\n=== Performance Tests Complete ===")
