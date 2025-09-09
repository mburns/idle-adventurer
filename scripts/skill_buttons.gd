class_name SkillButtons
extends Control

# Reference to the main game controller
var main_controller: Control

func _ready():
    # Find the main controller
    main_controller = get_node("../")

    # Connect all skill buttons to their respective activities
    connect_skill_buttons()

func connect_skill_buttons():
    # Strength activities
    connect_button("TabContainer/Strength/PushARock", "Push a Rock")
    connect_button("TabContainer/Strength/TipOverAStatue", "Tip Over a Statue")
    connect_button("TabContainer/Strength/Athletics", "Lift Weights")

    # Dexterity activities
    connect_button("TabContainer/Dexterity/DoAKickflip", "Practice Acrobatics")
    connect_button("TabContainer/Dexterity/Acrobatics", "Practice Acrobatics")
    connect_button("TabContainer/Dexterity/SleightOfHand", "Pick Locks")
    connect_button("TabContainer/Dexterity/Stealth", "Stealth Training")
    connect_button("TabContainer/Dexterity/PickALock", "Pick Locks")
    connect_button("TabContainer/Dexterity/PlayStringedInstrument", "Play Instrument")

    # Constitution activities
    connect_button("TabContainer/Constitution/HoldYourBreath", "Hold Your Breath")
    connect_button("TabContainer/Constitution/QuaffAnAle", "Drink Ale")

    # Intelligence activities
    connect_button("TabContainer/Intelligence/Arcana", "Study Arcana")
    connect_button("TabContainer/Intelligence/History", "Research History")
    connect_button("TabContainer/Intelligence/Investigation", "Investigate")
    connect_button("TabContainer/Intelligence/Nature", "Study Nature")
    connect_button("TabContainer/Intelligence/Religion", "Research Religion")
    connect_button("TabContainer/Intelligence/Forge a document", "Forge Document")

    # Wisdom activities
    connect_button("TabContainer/Wisdom/AnimalHandling", "Animal Handling")
    connect_button("TabContainer/Wisdom/Insight", "Practice Insight")
    connect_button("TabContainer/Wisdom/Medicine", "Study Medicine")
    connect_button("TabContainer/Wisdom/Perception", "Practice Perception")
    connect_button("TabContainer/Wisdom/Survival", "Survival Training")
    connect_button("TabContainer/Wisdom/DetermineIfUndead", "Detect Undead")

    # Charisma activities
    connect_button("TabContainer/Charisma/Deception", "Practice Deception")
    connect_button("TabContainer/Charisma/Intimidation", "Practice Intimidation")
    connect_button("TabContainer/Charisma/Performance", "Performance Practice")
    connect_button("TabContainer/Charisma/Persuasion", "Practice Persuasion")
    connect_button("TabContainer/Charisma/Blend into a crowd", "Blend into Crowd")

    # Rest activities
    connect_button("TabContainer/Rest/Short Rest", "Short Rest")
    connect_button("TabContainer/Rest/Long Rest", "Long Rest")

func connect_button(button_path: String, activity_name: String):
    var button = get_node(button_path)
    if button and button is Button:
        button.pressed.connect(_on_skill_button_pressed.bind(activity_name))

func _on_skill_button_pressed(activity_name: String):
    if main_controller and main_controller.has_method("start_activity"):
        main_controller.start_activity(activity_name)
    else:
        print("Error: Main controller not found or doesn't have start_activity method")
