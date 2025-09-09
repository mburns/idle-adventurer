extends Node

# Performance optimization utilities for the game

# Performance monitoring
var frame_times: Array[float] = []
var memory_usage: Array[int] = []
var max_samples = 60 # Keep last 60 frames of data

# Performance settings
var target_fps = 60
var low_fps_threshold = 45
var high_memory_threshold = 100 * 1024 * 1024 # 100MB

func _ready():
    # Set up performance monitoring
    Engine.max_fps = target_fps

    # Connect to frame timing
    process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
    # Monitor frame time
    frame_times.append(delta)
    if frame_times.size() > max_samples:
        frame_times.pop_front()

    # Monitor memory usage
    var memory = OS.get_static_memory_usage()
    memory_usage.append(memory)
    if memory_usage.size() > max_samples:
        memory_usage.pop_front()

    # Check for performance issues
    check_performance_issues()

func check_performance_issues():
    var avg_fps = 1.0 / get_average_frame_time()
    var current_memory = OS.get_static_memory_usage()

    # Low FPS warning
    if avg_fps < low_fps_threshold:
        print("WARNING: Low FPS detected: " + str(avg_fps) + " FPS")
        optimize_for_performance()

    # High memory warning
    if current_memory > high_memory_threshold:
        print("WARNING: High memory usage: " + str(current_memory / 1024 / 1024) + " MB")
        optimize_memory_usage()

func get_average_frame_time() -> float:
    if frame_times.is_empty():
        return 0.0

    var total = 0.0
    for time in frame_times:
        total += time

    return total / frame_times.size()

func get_average_fps() -> float:
    var avg_frame_time = get_average_frame_time()
    if avg_frame_time == 0.0:
        return 0.0
    return 1.0 / avg_frame_time()

func get_memory_usage() -> int:
    return OS.get_static_memory_usage()

func optimize_for_performance():
    print("Applying performance optimizations...")

    # Reduce visual quality
    optimize_rendering()

    # Optimize physics
    optimize_physics()

    # Optimize UI
    optimize_ui()

func optimize_rendering():
    # Reduce shadow quality
    RenderingServer.directional_shadow_atlas_set_size(1024)

    # Reduce texture quality
    RenderingServer.texture_2d_set_force_redraw_if_visible(false)

    # Disable unnecessary effects
    RenderingServer.camera_set_use_environment(false)

func optimize_physics():
    # Reduce physics iterations
    PhysicsServer2D.set_iterations(4)

    # Optimize collision detection
    PhysicsServer2D.set_collision_iterations(4)

func optimize_ui():
    # Disable unnecessary UI updates
    # This would be implemented based on specific UI needs

    # Reduce animation complexity
    # This would be implemented based on specific animations

func optimize_memory_usage():
    print("Applying memory optimizations...")

    # Force garbage collection
    call_deferred("force_garbage_collection")

    # Unload unused resources
    unload_unused_resources()

func force_garbage_collection():
    # Force garbage collection
    # This is a placeholder - actual implementation would depend on Godot version
    print("Forcing garbage collection...")

func unload_unused_resources():
    # Unload unused resources
    # This would scan for and unload resources that are no longer needed
    print("Unloading unused resources...")

# Object pooling for frequently created/destroyed objects
var object_pools: Dictionary = {}

func get_pooled_object(object_type: String) -> Node:
    if not object_pools.has(object_type):
        object_pools[object_type] = []

    var pool = object_pools[object_type]
    if pool.size() > 0:
        return pool.pop_back()
    else:
        return create_new_object(object_type)

func return_pooled_object(object: Node, object_type: String):
    if not object_pools.has(object_type):
        object_pools[object_type] = []

    # Reset object state
    object.queue_free()
    object_pools[object_type].append(object)

func create_new_object(object_type: String) -> Node:
    # This would create new objects based on type
    # Implementation depends on what objects need pooling
    return Node.new()

# Texture atlasing for character sprites
func create_texture_atlas(textures: Array[Texture2D]) -> AtlasTexture:
    var atlas = AtlasTexture.new()
    # This would combine multiple textures into a single atlas
    # Implementation would depend on specific texture requirements
    return atlas

# Lazy loading for large datasets
var loaded_data: Dictionary = {}

func load_data_lazy(data_key: String, loader_func: Callable) -> Variant:
    if loaded_data.has(data_key):
        return loaded_data[data_key]

    var data = loader_func.call()
    loaded_data[data_key] = data
    return data

func unload_data(data_key: String):
    if loaded_data.has(data_key):
        loaded_data.erase(data_key)

# Performance profiling
func start_profiling():
    # Start performance profiling
    # This would enable detailed profiling if available
    print("Starting performance profiling...")

func stop_profiling():
    # Stop performance profiling
    # This would stop profiling and generate report
    print("Stopping performance profiling...")

# Get performance report
func get_performance_report() -> Dictionary:
    return {
        "average_fps": get_average_fps(),
        "memory_usage": get_memory_usage(),
        "frame_times": frame_times.duplicate(),
        "memory_history": memory_usage.duplicate()
    }
