class Map
	constructor: ->
		this.map
		this.sprite = new Image

	resize: ->
		if this.map != undefined
			canvas.width  = this.map.width  * this.map.tilewidth
			canvas.height = this.map.height * this.map.tileheight

	draw: ->
		for layer in this.map.layers
			do (layer) ->
				if layer.name == 'player'
					for player in players
						do (player) ->
							player.draw()
				else
					this.map.drawLayer layer.name

	# TODO read multiple tilesets
	drawLayer: (layer_name) ->
		tw = this.map.tilesets[0].imagewidth  / this.map.tilesets[0].tilewidth
		th = this.map.tilesets[0].imageheight / this.map.tilesets[0].imageheight

		for layer in this.map.layers when layer.name is layer_name and layer.type is 'tilelayer'
			do (layer) ->
				i =  0
				x =  0
				y = -1

				width  = layer.width
				height = layer.height

				for data in layer.data
					do (data) ->
						tileIndex = data - 1

						if i++ % width is 0
							y++
							x = 0

						if tileIndex >= 0
							px = Math.floor tileIndex % tw
							py = Math.floor (tileIndex - px) / tw

							ctx.drawImage this.map.sprite, px * 32, py * 32, 32, 32, x * 32, y * 32, 32, 32

						x++

	# TODO load sprite.src and map.json simultaneously
	loadMap: ->
		self = this;
		this.sprite.src = 'img/terrain_atlas.png'

		this.sprite.addEventListener 'load', ->
			xhr = new XMLHttpRequest

			xhr.onreadystatechange = ->
				if xhr.readyState is 4 and xhr.status is 200
					self.map = JSON.parse xhr.responseText

			xhr.open 'GET', 'map.json', true
			xhr.send null
