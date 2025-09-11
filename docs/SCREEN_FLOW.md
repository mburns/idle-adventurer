# Screen Flow - Idle Adventurer

## Main Navigation Flow

```
Start Screen
├── New Character → Character Creation → Main Game
├── Load Character → Main Game
└── Settings → Settings Screen

Main Game Screen
├── Character Profile → Character Profile Screen
├── Skills → Skills Screen
├── Equipment → Equipment Screen
├── Journal → Journal Screen
├── Factions → Faction Screen
├── Spellbook → Spellbook Screen (if spellcaster)
├── Quests → Quest Screen
├── Town → Town Screen
├── Profession → Profession Screen
├── Lifestyle → Lifestyle Screen
├── Events → Events Screen
└── Settings → Settings Screen
```

## Screen Descriptions

### 1. Start Screen

- **Purpose**: Entry point to the game
- **Key Elements**:
  - Game title/logo
  - New Character button
  - Load Character button
  - Settings button
  - Quit button

### 2. Character Creation

- **Purpose**: Create a new D&D character
- **Key Elements**:
  - Race selection (Human, Elf, Dwarf, etc.)
  - Class selection (Barbarian, Bard, Cleric, etc.)
  - Background selection
  - Ability score assignment
  - Character name input
  - Appearance customization
  - Confirm creation button

### 3. Main Game Screen

- **Purpose**: Primary gameplay interface
- **Key Elements**:
  - Character info panel (name, level, class, current activity)
  - Resources panel (gold, XP, HP, spell slots)
  - Activity tabs (Skills, Equipment, Journal, etc.)
  - Progress indicators
  - Time display

### 4. Character Profile

- **Purpose**: View detailed character information
- **Key Elements**:
  - Ability scores and modifiers
  - Class features and abilities
  - Equipment slots
  - Inventory
  - Proficiencies
  - Spellbook (if applicable)

### 5. Skills Screen

- **Purpose**: Manage skill activities and progression
- **Key Elements**:
  - Six ability score tabs
  - Skill activities for each ability
  - Progress tracking
  - Activity queue
  - Time estimates
  - Quest integration
  - Professional work options

### 6. Equipment Screen

- **Purpose**: Manage character equipment and inventory
- **Key Elements**:
  - Equipment slots
  - Inventory grid
  - Item details
  - Shop interface
  - Crafting system

### 7. Settings Screen

- **Purpose**: Configure game settings
- **Key Elements**:
  - Game settings (idle speed, notifications)
  - Audio settings
  - Display settings
  - Account settings
  - About section

### 8. Journal Screen

- **Purpose**: Track character activities and achievements
- **Key Elements**:
  - Activity log
  - Achievements
  - Story events
  - Player notes
  - Statistics

### 9. Faction Screen

- **Purpose**: Manage faction relationships
- **Key Elements**:
  - Faction reputation tracking
  - Faction quests
  - Faction rewards
  - Faction history

### 10. Spellbook Screen

- **Purpose**: Manage spells (for spellcasters)
- **Key Elements**:
  - Known spells
  - Spell slots
  - Spell preparation
  - Spell research
  - Ritual casting

### 11. Quest Screen

- **Purpose**: Manage active and available quests
- **Key Elements**:
  - Active quests with progress tracking
  - Available quests from factions and NPCs
  - Quest objectives and rewards
  - Quest history and completion tracking

### 12. Town Screen

- **Purpose**: Navigate town locations and services
- **Key Elements**:
  - Interactive town map
  - Location descriptions and services
  - NPCs found at each location
  - Service costs and requirements
  - Town events and activities

### 13. Profession Screen

- **Purpose**: Manage professional work and income
- **Key Elements**:
  - Available professions
  - Professional reputation tracking
  - Daily work and income
  - Professional benefits and advancement
  - Work quality and skill requirements

### 14. Lifestyle Screen

- **Purpose**: Manage living standards and expenses
- **Key Elements**:
  - Lifestyle level selection
  - Daily expense tracking
  - Lifestyle benefits and penalties
  - Social status and reputation effects
  - Sustainability calculations

### 15. Events Screen

- **Purpose**: View and respond to random events
- **Key Elements**:
  - Active random events
  - Event choices and consequences
  - Event history and outcomes
  - Skill checks and results
  - Event cooldowns and availability

## Navigation Patterns

- **Modal Windows**: Settings, detailed item views
- **Tab Navigation**: Skills screen with ability score tabs
- **Sidebar Navigation**: Main game screen with activity categories
- **Breadcrumb Navigation**: Deep navigation within screens
- **Quick Actions**: Common actions accessible from main screen

## Responsive Design Considerations

- **Mobile**: Stack elements vertically, use collapsible menus
- **Desktop**: Side-by-side layouts, hover tooltips
- **Tablet**: Hybrid approach with touch-friendly controls
