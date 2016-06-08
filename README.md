# splinxsChat
iOS chat based on SocketIO


node.js server in splinxsChatServer folder
run server: node index.js
<br />
for remote server select "splinxs" in login screen, due to BFH firewall you must be in the BFH network to use the remote server
<br />
The system is based on the username. Do not use the same username for different users
<br />
Limitations:<br />
	-The system is based on the username. Do not use the same username for different users<br />
	-Messages are stored only locally<br />
	-Private messages are not stored<br />
	-Due to Socket.io limitations, connection is interrupted in background<br />
	