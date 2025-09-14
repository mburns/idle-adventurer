class_name SocialEvent
extends Resource

# Social events that can occur in the game

# Use global SocialEventType enum from social_event_type.gd

# Use global InteractionType enum from interaction_type.gd

@export var event_id: String = ""
@export var event_name: String = ""
@export var event_type: SocialEventType.Type = SocialEventType.Type.CONVERSATION
@export var description: String = ""
@export var location: String = ""
@export var participants: Array[String] = []  # NPC IDs involved
@export var requirements: Dictionary = {}
@export var outcomes: Dictionary = {}
@export var duration: int = 1  # Duration in game hours
@export var frequency: String = "once"  # once, daily, weekly, monthly, random
@export var triggers: Array[String] = []  # What triggers this event
@export var consequences: Dictionary = {}  # Long-term effects

func get_event_type_string() -> String:
	"""Get event type as string"""
	match event_type:
		SocialEventType.Type.CONVERSATION:
			return "Conversation"
		SocialEventType.Type.TRADE:
			return "Trade"
		SocialEventType.Type.TRAINING:
			return "Training"
		SocialEventType.Type.QUEST_OFFER:
			return "Quest Offer"
		SocialEventType.Type.INFORMATION_EXCHANGE:
			return "Information Exchange"
		SocialEventType.Type.CONFLICT:
			return "Conflict"
		SocialEventType.Type.COOPERATION:
			return "Cooperation"
		SocialEventType.Type.ROMANCE:
			return "Romance"
		SocialEventType.Type.FRIENDSHIP:
			return "Friendship"
		SocialEventType.Type.RIVALRY:
			return "Rivalry"
		SocialEventType.Type.BETRAYAL:
			return "Betrayal"
		SocialEventType.Type.RECONCILIATION:
			return "Reconciliation"
		SocialEventType.Type.CELEBRATION:
			return "Celebration"
		SocialEventType.Type.MOURNING:
			return "Mourning"
		SocialEventType.Type.COMPETITION:
			return "Competition"
		SocialEventType.Type.COLLABORATION:
			return "Collaboration"
		_:
			return "Unknown"

func can_trigger(character: Character) -> bool:
	"""Check if this event can trigger for the given character"""
	if requirements.is_empty():
		return true

	for req_type in requirements.keys():
		var required_value = requirements[req_type]

		match req_type:
			"level":
				if character.level < required_value:
					return false
			"gold":
				if character.gold < required_value:
					return false
			"reputation":
				# Check faction reputation
				if character.faction_reputation.has(required_value):
					var current_reputation = character.faction_reputation[required_value]
					if current_reputation < required_value:
						return false
			"location":
				if character.current_location != required_value:
					return false
			"time":
				# Check time requirements
				pass  # Would integrate with time system

	return true

func get_outcome(outcome_type: String) -> Dictionary:
	"""Get outcome data for a specific type"""
	return outcomes.get(outcome_type, {})

func apply_consequences(character: Character, outcome_type: String = "default"):
	"""Apply the consequences of this event to the character"""
	var consequence_data = consequences.get(outcome_type, {})

	for effect_type in consequence_data.keys():
		var effect_value = consequence_data[effect_type]

		match effect_type:
			"reputation_change":
				# Apply reputation changes
				for faction in effect_value.keys():
					var change = effect_value[faction]
					if character.faction_reputation.has(faction):
						character.faction_reputation[faction] += change
					else:
						character.faction_reputation[faction] = change
			"gold_change":
				character.gold += effect_value
			"experience_gain":
				character.add_experience(effect_value)
			"item_gain":
				# Add items to inventory
				pass  # Would integrate with inventory system
			"relationship_change":
				# Change relationship with NPCs
				pass  # Would integrate with relationship system
