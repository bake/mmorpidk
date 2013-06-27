var io  = require('socket.io').listen(61226),
	fs  = require('fs');

io.set('log level', 1);

/**
 * socket.id -> player index
 */
function getIndexById(id) {
	for(var i in players)
		if(players[i].id == id)
			return i;
}

/**
 * get new position
 */
function movePosition(position, direction) {
	     if(direction ==  'left') position.x -= 32;
	else if(direction ==    'up') position.y -= 32;
	else if(direction == 'right') position.x += 32;
	else if(direction ==  'down') position.y += 32;

	return position;
}

/**
 * lame collision-detection
 */
function canIGo(position) {
	/**
	 * check for map
	 */
	if(position.x < 0 || position.y < 0)
		return false;

	/*
	if(position.x > map.x - players[0].size.x || position.y > map.y - players[0].size.y)
		return false;
	*/

	/**
	 * check for collision layer
	 */
	for(var i in collision)
		if(position.x == collision[i].x * 32 && position.y == collision[i].y * 32)
			return false;

	/**
	 * check for player
	 */
	for(var i in players)
		if(position.x == players[i].position.x && position.y == players[i].position.y)
			return false;

	/**
	 * otherwise ... WOOHOO!
	 */
	return true;
}

/**
 * events should get called on walk through
 */
function isThereAnEvent(player, callback) {
	for(var i in events) {
		if(player.position.x == events[i].x && player.position.y == events[i].y) {
			callback(player, events[i]);
			return events[i];
		}
	}

	return false;
}

/**
 * return an object of what's in front of you
 */
function whoIsInFrontOfMe(position) {
	/**
	 * check for player
	 */
	for(var i in players)
		if(position.x == players[i].position.x && position.y == players[i].position.y)
			return players[i];

	/**
	 * check for an event
	 */
	for(var i in events)
		if(position.x == events[i].x && position.y == events[i].y)
			return events[i];

	return false;
}

/**
 * kick 
 */
function kick(id) {
	/**
	 * remove player from array
	 */
	var index = getIndexById(id);
	players.splice(index, 1);

	/**
	 * send a message to the other players
	 */
	io.sockets.emit('kick', { id: id })
}

/**
 * load map
 */
function loadMap() {
	fs = require('fs')
	fs.readFile('map.json', 'utf8', function (err, data) {
		if(err) {
			return err;
		}

		map       = JSON.parse(data);
		events    = parseLayer('events');
		collision = parseLayer('collision');

		loadChat();
	});
}

/**
 * load chat
 */
function loadChat() {
	fs = require('fs')
	fs.readFile('chat.json', 'utf8', function (err, data) {
		if(err) {
			return err;
		}

		chat = JSON.parse(data);

		init();
	});
}

/**
 * parse one layer, return every elements coordinates
 * TODO use layers.tilesets.firstgid
 */
function parseLayer(layer) {
	var x, y, c = [];

	for(var i in map.layers) {
		if(map.layers[i].name == layer) {
			if(map.layers[i].type == 'tilelayer') {
				x =  0;
				y = -1;

				var width  = map.layers[i].width;
				var height = map.layers[i].height;

				for(var j in map.layers[i].data) {
					if(j % width == 0) { y++; x = 0; }

					if(map.layers[i].data[j] > 0)
						c.push({ x: x, y: y });

					x++;
				}
			}
			else if(map.layers[i].type == 'objectgroup') {
				for(var j in map.layers[i].objects) {
					var event = map.layers[i].objects[j];
					event.type = 'event';

					c.push(event);
				}
			}
		}
	}

	return c;
}

function callEvent(player, event) {
	if(event.properties.teleport != null) {
		var position = event.properties.teleport.split(',');
		    position = { x: parseInt(position[0]), y: parseInt(position[1]) };

		player.position = position;
	}
}

function drawMap() {
	for(var y = 0; y < map.layers[0].height; y++) {
		var line = '';
		var player_found = false;

		for(var x = 0; x < map.layers[0].width; x++) {
			line += (canIGo({ x: x * 32, y: y * 32 })) ? ' ' : '#';
		}

		line += ' ' + y;

		console.log(line);
	}
	console.log();
}

/**
 * ...
 */
function init() {
	for(var i in events) {
		if(events[i].name == 'spawn') {
			spawn.x = events[i].x;
			spawn.y = events[i].y;
		}
	}
}

var map       = {};
var spawn     = {};
var chat      = {};
var players   = [];
var events    = [];
var collision = [];
var models    = [{
	power:     15,
	size:      { x: 32, y: 48 },
	speed:     0.6,
	sprite:    'img/sailor-moon.png' // http://untamed.wild-refuge.net/rmxpresources.php?characters
}, {
	power:     12,
	size:      { x: 32, y: 48 },
	speed:     0.6,
	sprite:    'img/pirate_m2.png' // http://untamed.wild-refuge.net/rmxpresources.php?characters
}, {
	power:     10,
	size:      { x: 32, y: 32 },
	speed:     0.4,
	sprite:    'img/george.png' // http://opengameart.org/content/alternate-lpc-character-sprites-george
}];

loadMap();

io.sockets.on('connection', function (socket) {
	/**
	 * default char
	 */
	var model = Math.floor(Math.random() * models.length);
	var player = {
		busy:       false,
		direction: 'down',
		id:         socket.id,
		life:       100,
		position:   spawn,
		power:      models[model].power,
		size:       models[model].size,
		speed:      models[model].speed,
		sprite:     models[model].sprite,
		type:       'player'
	}

	players.push(player);

	socket.emit('register', { map: map, id: socket.id });
	socket.broadcast.emit('player', players[players.length - 1]);

	/**
	 * initial populate players on new connection
	 */
	for(var i in players)
		socket.emit('player', players[i]);

	//drawMap();

	socket.on('attack', function () {
		var index     = getIndexById(socket.id);
		var player    = players[index];

		if(player != undefined && !player.busy) {
			var direction = player.direction;
			var position  = { x: player.position.x, y: player.position.y };
			var position  = movePosition(position, direction);
			var infront   = whoIsInFrontOfMe(position);

			/**
			 * found someone in front of you! go, hit him!
			 */
			if(infront) {
				if(infront.type == 'player') {
					infront.life -= player.power;

					if(infront.life <= 0) {
						/**
						 * he's dead
						 */
						infront.life     = 100;
						infront.position = spawn;
						io.sockets.emit('death', { player: { id: infront.id, life: infront.life, position: infront.position } });
					}
					else {
						io.sockets.emit('attack', { id: infront.id, life: infront.life });
					}
				}
				else if(infront.type == 'event' && infront.properties != null && infront.properties.text != null) {
					var index = infront.properties.text;
					socket.emit('message', { author: chat[index].author, message: chat[index].message });
				}

				player.busy = true;
				setTimeout(function() {
					player.busy = false;
				}, player.speed * 1000);
			}
		}
	});

	socket.on('move', function (data) {
		var index  = getIndexById(socket.id);
		var player = players[index];

		/**
		 * check if player is allowed to go there
		 */
		if(player != undefined && !player.busy && ['up', 'down', 'left', 'right'].indexOf(data) >= 0) {
			player.direction = data;
			var position = { x: player.position.x, y: player.position.y };

			if(canIGo(movePosition(position, data))) {
				player.position = position;

				var event = isThereAnEvent(player, callEvent);

				var action = (event.properties != null && event.properties.teleport != null) ? 'teleport' : 'move';
				io.sockets.emit(action, { id: player.id, position: player.position, direction: player.direction });

				//drawMap();

				/**
				 * plz wait .5s with next move
				 */
				player.busy = true;
				setTimeout(function() {
					player.busy = false;
					io.sockets.emit('move', player);
				}, player.speed * 1000);
			}
			else {
				/**
				 * change your chars' direction should be enough
				 */
				io.sockets.emit('move', player);
			}
		}
	});

	/**
	 * emit messages
	 * TODO strip html tags
	 */
	socket.on('message', function (data) {
		var index  = getIndexById(socket.id);
		var player = players[index];
		player.text = data.text;

		io.sockets.emit('message', { id: socket.id, text: player.text });
	});

	socket.on('disconnect', function () {
		kick(socket.id);
		//drawMap();
	});
});
