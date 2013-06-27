MMORPidk
========

Coffeescript MMORPG with no story, one screen and no need to play - but with love.

What?
-----
![Screenshot](https://raw.github.com/BakeRolls/mmorpidk/master/screenshot.png)

Or a live version: [mmorpidk.w8l.org](http://mmorpidk.w8l.org/).

Install
-------
`$ npm install socket.io`
Change `window.socket = io.connect('http://w8l.org:61226/');` to something better in the index.html.

Start
-----
`$ node server.js`

It's running!
-------------
If you're using the default map (build with [Tiled](http://www.mapeditor.org/)), your terminal should show something like this:

	################### ########## 0
	#                            # 1
	#                           ## 2
	#                            # 3
	#                            # 4
	#  #       #                 # 5
	#      #                     # 6
	#                           ## 7
	#                        ##### 8
	#             ######  ######## 9
	#             ################ 10
	#              ############### 11
	#              ### #####     # 12
	#                  ###       # 13
	#                  ###       # 14
	######  ### ##               # 15
	######       #     ###       # 16
	#########  ####    ###  # #  # 17
	#########          ###       # 18
	############################## 19

That's the parsed map with all players and items on the collision layer (I'm the *something* at 4x5).

Control
-------
Hit space to attack. Without any animation. Use arrow keys to move. But there's also ...

Something cool
--------------
You can *play* this with your XBox 360 controller! Just connect it to your computer and watch the icons on the right :)

Chat?
-----
Open the JS console and attack the snag.

What the ... Sailor Moon?!
--------------------------
Yeah, there are actually three characters :)

Todo
----
- Animations?
- A chat would be nice. One without the console.
- It'd be cool to walk as the key goes down. When the server responds "you shall not pass", the players direction could get corrected.

Are you working on it? Will it get better?
------------------------------------------
No :/
