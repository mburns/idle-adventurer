# Bug Fixes and Logic Improvements

This document tracks the bug fixes and logic improvements made to the Idle Adventurer project.

## Lambda Capture Issues

### Problem

Multiple scripts were experiencing "Lambda capture at index 0 was freed. Passed 'null' instead" errors due to improper lambda function usage.

### Root Cause

- Using `.bind()` to capture object references in lambda functions
- Lambda functions holding references to freed objects
- Unsafe property access in tween callbacks

### Files Fixed

- `scripts/start_screen.gd` - Button hover effects
- `scripts/skill_buttons.gd` - Button connections
- `scripts/animation_manager.gd` - Tween callbacks

### Solution

Replaced `.bind()` usage with `WeakRef` approach:

```gdscript
# Before (problematic)
button.pressed.connect(_on_button_pressed.bind(button))

# After (safe)
var button_ref = weakref(button)
button.pressed.connect(func(): _on_button_pressed(button_ref))
```

## Missing Function Errors

### Problem

Several scripts were calling non-existent functions, causing runtime errors.

### Functions Added

1. **ThemeManager.apply_theme_to_children()**

   - Added missing function that multiple UI scripts were calling
   - Acts as alias to existing `apply_theme_to_node()` function

2. **DataLoader.load_json_data()**
   - Added generic function to load JSON files by name
   - Used by character creation for loading names data

### Files Fixed

- `scripts/theme_manager.gd` - Added missing function
- `scripts/data_loader.gd` - Added generic JSON loader
- Multiple UI scripts - Now work with correct function names

## Property Access Issues

### Problem

Character manager was using generic `.get()` and `.set()` methods on Character objects, causing "Invalid call. Nonexistent function 'get' in base 'String'" errors.

### Root Cause

```gdscript
# Problematic code
character.set(ability, character.get(ability) + increase)
```

### Solution

Replaced with explicit property access:

```gdscript
# Fixed code
match ability:
    "strength":
        character.strength += increase
    "dexterity":
        character.dexterity += increase
    # ... etc
```

### Files Fixed

- `scripts/character_manager.gd` - Race bonus application
- `scripts/character_sheet.gd` - Spell slots and buffs access
- `scripts/leveling_screen.gd` - Spell slots access

## Division by Zero Prevention

### Problem

Experience bar calculation could cause division by zero when `xp_needed` was 0.

### Solution

Added null check before division:

```gdscript
var progress_percent = 0.0
if xp_needed > 0:
    progress_percent = (xp_progress / xp_needed) * 100.0
```

### Files Fixed

- `scripts/leveling_screen.gd` - Experience bar calculation

## Node Reference Issues

### Problem

Character creation script was referencing non-existent node `%NameLineEdit`.

### Solution

Corrected node reference to actual node name `%CharacterNameInput`.

### Files Fixed

- `scripts/character_creation.gd` - Node reference correction

## Testing Improvements

### New Test Suite

Created comprehensive test suite `tests/unit/test_bug_fixes.gd` covering:

- Lambda capture fixes
- Theme manager functions
- Data loader functions
- Character creation node references
- Character manager property access
- Division by zero prevention
- Null checks in character sheet
- File operation error handling
- Array bounds safety
- Signal connection safety

## Best Practices Implemented

1. **Safe Lambda Usage**: Always use WeakRef for object references in lambdas
2. **Explicit Property Access**: Use direct property access instead of generic get/set
3. **Null Safety**: Check for null values before operations
4. **Division Safety**: Prevent division by zero
5. **Error Handling**: Proper error handling for file operations
6. **Bounds Checking**: Safe array access with size checks

## Future Prevention

To prevent similar issues:

1. Use static analysis tools to catch lambda capture issues
2. Implement proper error handling patterns
3. Add comprehensive unit tests for critical functions
4. Use type hints and explicit property access
5. Regular code reviews focusing on memory management
