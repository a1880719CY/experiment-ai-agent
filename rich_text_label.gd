extends RichTextLabel

var ex_text = "halooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func scroll_text(input_text:String) -> void:
	visible_characters = 0
	text = input_text
	
	
