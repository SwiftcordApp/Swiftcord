# Gateway ⛩️

Here're all the files that implement the Discord Gateway API.
They handle everything from identify and heartbeating to 
reconnection. Currently, identification and heartbeating works
very well, but reconnection/resuming not so well.

Emits gateway events, connection state changes and auth errors
thru a simple listener/emiter event helper in Utils.
