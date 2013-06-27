# on lauch, you'll get called by this method
window.socket.on 'register', (data) ->
	you = { id: data.id }

# oh look, a new player!
window.socket.on 'player', (data) ->
	players.push new Player data

# don't worry, he/she's not realy dead
window.socket.on 'kick', (data) ->
	index = getIndexById data.id
	players.splice index, 1

# someone's movin', do something!
window.socket.on 'move', (data) ->
	index  = getIndexById data.id
	player = players[index]

	player.tPosition = data.position
	player.direction = data.direction

	player.busy = true
	player.move()

# someone got hit!
window.socket.on 'attack', (data) ->
	index  = getIndexById data.id
	player = players[index]

	player.life = data.life

# someone's dead
window.socket.on 'death', (data) ->
	index  = getIndexById data.player.id
	player = players[index]

	player.life     = data.player.life
	player.position = data.player.position

# chat
window.socket.on 'message', (data) ->
	console.log data.author + ': ' + data.message
