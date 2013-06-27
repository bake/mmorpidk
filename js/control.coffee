# set directions
document.addEventListener 'keydown', (event) ->
	if      event.keyCode == 38 then window.controls.up    = true
	else if event.keyCode == 40 then window.controls.down  = true
	else if event.keyCode == 37 then window.controls.left  = true
	else if event.keyCode == 39 then window.controls.right = true
	else if event.keyCode == 32 then window.controls.space = true

	kbPressed = true

	event.preventDefault()

# unset directions
document.addEventListener 'keyup', (event) ->
	if      event.keyCode == 38 then window.controls.up    = false
	else if event.keyCode == 40 then window.controls.down  = false
	else if event.keyCode == 37 then window.controls.left  = false
	else if event.keyCode == 39 then window.controls.right = false
	else if event.keyCode == 32 then window.controls.space = false

	kbPressed = false

	event.preventDefault()

# don't know if this config works for other controllers than the one
# you know from the xbox 360
getGamepad = ->
	if !kbPressed
		gamepad     = navigator.webkitGetGamepads && navigator.webkitGetGamepads()[0] ||
		              navigator.mozGetGamepads    && navigator.mozGetGamepads()[0]
		gamepadIcon = document.querySelector('.icon-gamepad')

		if gamepad isnt undefined
			#          d-pad                  left analog stick         right analog stick
			window.controls.up    = if gamepad.buttons[12] or gamepad.axes[1] <= -.5 or gamepad.axes[3] <= -.5 then true else false
			window.controls.down  = if gamepad.buttons[13] or gamepad.axes[1] >=  .5 or gamepad.axes[3] >=  .5 then true else false
			window.controls.left  = if gamepad.buttons[14] or gamepad.axes[0] <= -.5 or gamepad.axes[2] <= -.5 then true else false
			window.controls.right = if gamepad.buttons[15] or gamepad.axes[0] >=  .5 or gamepad.axes[2] >=  .5 then true else false
			window.controls.space = if gamepad.buttons[0]                                                      then true else false # a

			gamepadIcon.className = 'icon-gamepad'
		else
			gamepadIcon.className = 'icon-gamepad muted'
