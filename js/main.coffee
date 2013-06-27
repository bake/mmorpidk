# yeah!
canvas    = document.querySelector 'canvas'
ctx       = canvas.getContext '2d'
frame     = 0
kbPressed = false # if any key on keyboard is pressed, do not listen to the controller
players   = []
map       = {}
mlCalled  = new Date().getTime()
fps       = 0
fpsHolder = document.querySelector '.fps'

# (pressed) keys
window.controls = {
	up:    false
	down:  false
	left:  false
	right: false
	space: false
}

# init
document.addEventListener 'DOMContentLoaded', ->
	map = new Map
	map.loadMap()

	# requestAnimationFrame
	requestAnimationFrame = ->
		window.requestAnimationFrame       ||
		window.oRequestAnimationFrame      ||
		window.msRequestAnimationFrame     ||
		window.mozRequestAnimationFrame    ||
		window.webkitRequestAnimationFrame ||
		(callback) ->
			window.setTimeout callback, 1000 / 60

	mainLoop()

# main-loop
mainLoop = ->
	delta = (new Date().getTime() - mlCalled) / 1000
	mlCalled = new Date().getTime()
	fps = 1 / delta

	fpsHolder.innerHTML = Math.floor(fps)

	frame++
	ctx.clearRect 0, 0, canvas.width, canvas.height
	map.resize()

	# draw layers
	# layer.property "player" = player-layer ... you know
	if map.map isnt undefined then map.draw()

	# draw health bars on top of the map
	for player in players
		do ->
			player.drawHealthBar()

	requestAnimationFrame mainLoop

# socket.id -> player index
getIndexById = (id) ->
	i = 0

	i++ while id != players[i].id

	return i
