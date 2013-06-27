// Generated by CoffeeScript 1.6.2
window.socket.on('register', function(data) {
  var you;

  return you = {
    id: data.id
  };
});

window.socket.on('player', function(data) {
  return players.push(new Player(data));
});

window.socket.on('kick', function(data) {
  var index;

  index = getIndexById(data.id);
  return players.splice(index, 1);
});

window.socket.on('move', function(data) {
  var index, player;

  index = getIndexById(data.id);
  player = players[index];
  player.tPosition = data.position;
  player.direction = data.direction;
  player.busy = true;
  return player.move();
});

window.socket.on('attack', function(data) {
  var index, player;

  index = getIndexById(data.id);
  player = players[index];
  return player.life = data.life;
});

window.socket.on('death', function(data) {
  var index, player;

  index = getIndexById(data.player.id);
  player = players[index];
  player.life = data.player.life;
  return player.position = data.player.position;
});

window.socket.on('message', function(data) {
  return console.log(data.author + ': ' + data.message);
});