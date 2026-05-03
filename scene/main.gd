extends Node2D

var processID: int
@export var ai_url:String = "http://localhost:11434/api/generate"
@export var model ="llama3.2"

@export var p_bar_speed = 1

var body_template = {
	"model": model,
	"prompt": "Hello, how are you?"
}

var loadingScreen_thread = Thread.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_tree().set_auto_accept_quit(false)

	var output := []
	processID = OS.create_process("ollama", ["serve"])
	var exit_code = OS.execute("ollama", ["list"], output)
	if exit_code == 0:
		print(output)
		# proces bar setting
		$HTTPRequest.request_completed.connect(_on_http_request_request_completed)
	else:
		print(exit_code)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $Sprite2D/MarginContainer3.visible:
		loading_screen_process(_delta)
	if Input.is_action_just_pressed("confirm reading"):
		if $Sprite2D/MarginContainer4.visible:
			$Sprite2D/MarginContainer4.visible = false
			$Sprite2D/MarginContainer2.visible = true
	pass

#dev define function:
func kill_ollama_server() -> bool:
	if OS.kill(processID) == 0:
		return true
	else:
		return false
		
func loading_screen_process(_delta: float):
	print("doing loading screen stuff")
	$Sprite2D/MarginContainer3/TextureProgressBar.value += ($Sprite2D/MarginContainer3/TextureProgressBar.max_value - $Sprite2D/MarginContainer3/TextureProgressBar.value) * _delta * p_bar_speed
	#if new_value > $Sprite2D/MarginContainer3/TextureProgressBar.max_value:
		#$Sprite2D/MarginContainer3/TextureProgressBar.value = 100
	#else:
		#$Sprite2D/MarginContainer3/TextureProgressBar.value = new_value
		#$Loading_screen_Timer.start()
		#print("added and start")
	pass
		
#signal connect function:	
func _notification(event):
	if event == NOTIFICATION_WM_CLOSE_REQUEST:
		print("quiting")
		kill_ollama_server()
		get_tree().quit() # default behavior

func _on_button_pressed() -> void:
	$Sprite2D/MarginContainer.visible = false
	$Sprite2D/MarginContainer2.visible = true
	pass # Replace with function body.


func _on_line_edit_text_submitted(new_text: String) -> void:
	$Sprite2D/MarginContainer2.visible = false
	$Sprite2D/MarginContainer3.visible = true		#visile control of loading screen
	body_template["prompt"] = new_text
	var body = JSON.stringify(body_template)
	$Sprite2D/MarginContainer2/LineEdit.clear()
	var result = $HTTPRequest.request(ai_url,[],HTTPClient.METHOD_POST, body)
	if result != OK:
		print("Request failed: ", result)
	else:
		print("sending message")
		#$Loading_screen_Timer.start()
	pass # Replace with function body.


func _on_http_request_request_completed(result, response_code, headers, body):
	print("recieved and start doing stuff")
	$Sprite2D/MarginContainer3/TextureProgressBar.value  = $Sprite2D/MarginContainer3/TextureProgressBar.max_value
	var text = body.get_string_from_utf8()
	var lines = text.split("\n", false)
	var full_response = ""
	for line in lines:
		var json = JSON.new()
		var error = json.parse(line)
		if error == OK:
			var data_received = json.data
			if data_received.has("response"):
				full_response += str(data_received["response"])
			else:
				print("Unexpected data")
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", line, " at line ", json.get_error_line())
	$Sprite2D/MarginContainer3.visible = false		#visile control of loading screen
	#$Loading_screen_Timer.stop()
	$Sprite2D/MarginContainer4/ScrollContainer/VBoxContainer/Label.text = full_response
	$Sprite2D/MarginContainer4.visible = true
	$Sprite2D/MarginContainer3/TextureProgressBar.value  = $Sprite2D/MarginContainer3/TextureProgressBar.min_value
	


func _on_loading_screen_timer_timeout() -> void:
	print("Time to add stuff up")
	#loading_screen_process()
	pass # Replace with function body.
