class Player
	constructor: (data) ->
		this.busy       = false
		this.direction  = data.direction
		this.frame      = 0
		this.id         = data.id
		this.life       = data.life
		this.position   = data.position
		this.power      = data.power
		this.size       = data.size
		this.speed      = data.speed # walk a tile in seconds
		this.sprite     = new Image()
		this.sprite.src = data.sprite
		this.text       = ''
		this.tPosition  = this.position

	draw: ->
		# check for gamepad :3
		getGamepad()

		this.keyPressed()
		this.move()

		# x = direction
		startX = 2 if this.direction ==    'up'
		startX = 0 if this.direction ==  'down'
		startX = 1 if this.direction ==  'left'
		startX = 3 if this.direction == 'right'
		startX = startX * this.size.x

		# y = anomation frame
		# sice the fps isn't the same on every device, this is a pretty
		# ugly solution (change sprite every 10th frame).
		this.frame += 1 if this.busy and frame % 10 is 0
		this.frame  = 0 if this.frame > 3 or !this.busy

		startY = this.frame * this.size.y

		# reset animation on stop
		this.frame 

		# draw frame
		ctx.drawImage this.sprite, startX, startY, this.size.x, this.size.y, this.position.x, this.position.y - (this.size.y - map.map.tileheight), this.size.x, this.size.y

	drawHealthBar: ->
		if map.map isnt undefined
			ctx.fillStyle = '#000'
			ctx.fillRect this.position.x + 4, this.position.y - (this.size.y - map.map.tileheight) - 6, 24, 1

			ctx.fillStyle = '#f00'
			ctx.fillRect this.position.x + 4, this.position.y - (this.size.y - map.map.tileheight) - 6, (24 / 100 * this.life), 1

	die: ->
		console.log 'you\'re dead'

	# send keypress events to server
	keyPressed: ->
		if !this.busy and (window.controls.up or window.controls.down or window.controls.left or window.controls.right or window.controls.space)
			socket.emit 'move',    'up' if window.controls.up
			socket.emit 'move',  'down' if window.controls.down
			socket.emit 'move',  'left' if window.controls.left
			socket.emit 'move', 'right' if window.controls.right
			socket.emit 'attack'        if window.controls.space

			# TODO move to new position
			#      will automaticly be overwritten by server,
			#      should looks like there's no lag
			#this.move()

	# move character
	# TODO this looks ugly
	move: ->
		if this.busy
			pxPerFrame = 32 / (fps * this.speed)

			switch this.direction
				when 'up'
					if this.tPosition.y < this.position.y
						moved = true
						this.position.y -= pxPerFrame
					else
						this.position.y = this.tPosition.y
						this.busy = false

				when 'down'
					if this.tPosition.y > this.position.y
						moved = true
						this.position.y += pxPerFrame
					else
						this.position.y = this.tPosition.y
						this.busy = false

				when 'left'
					if this.tPosition.x < this.position.x
						moved = true
						this.position.x -= pxPerFrame
					else
						this.position.x = this.tPosition.x
						this.busy = false

				when 'right'
					if this.tPosition.x > this.position.x
						moved = true
						this.position.x += pxPerFrame
					else
						this.position.x = this.tPosition.x
						this.busy = false
