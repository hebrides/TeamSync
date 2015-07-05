THIS IS IN DEVELOPMENT

INSTALLATION:
=============
You should be sure that "register_argc_argv = On" in your server php.ini.
Copy the files from this package to the folder on your server.


API
===
`api.php` - for get and send requests from(to) mobile-side application (to synchronization of playlists, control playing songs etc.).
Also, it automaticaly run the WebSocket server script, when application starts on master device.


PHP WebSockets
==============
PHP WebSockets is a PHP library that implements the latest version of
the WebSockets protocol. The [WebSockets protocol](http://www.rfc-editor.org/rfc/rfc6455.txt) (RFC6455) is currently being
standardized by the IETF. With WebSockets, a client (e.g.: a iphone device or it can be a browser) and
a server can set up a two-way communication channel with little overhead
compared to a XMLHttpRequest or long polling.

Usage
-----
The server can be started by starting the `StartSync.php` file from the command-
line. You might need to edit the file to change the servers IP and/or port.



