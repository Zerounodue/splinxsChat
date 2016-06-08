# SplinxsChat
iOS chat based on SocketIO


node.js server in splinxsChatServer folder
run server: 
```sh
$ node index.js
```
for remote server select "splinxs" in login screen, due to BFH firewall you must be in the BFH network to use the remote server

The system is based on the username. Do not use the same username for different users

###Limitations:

	- The system is based on the username. Do not use the same username for different users
	- Messages are stored only locally
	- Private messages are not stored
	- Due to Socket.io limitations, connection is interrupted in background
	