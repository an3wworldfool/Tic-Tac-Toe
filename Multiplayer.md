# Basics of Multiplayer in Godot 4

From https://www.youtube.com/watch?v=e0JLO_5UgQo

Two modes: *peer-to-peer* or *server-hosted* are possible.

Make a scene `MultiplayerScene` (saved as `MultiplayerScene.tscn`) with a basic control node `Control` and sub three buttons: `Host`, `Join`, `Start Game`. Make a new GD script and call it `MultiplayerController.gd`. Connect the button signals for the 3 buttons `button_down` to MultiplayerController.

**Note:** multiplayer is a property, which is a reference to the MultiplayerAPI instance configured for it by the scene tree. Initially, every node is configured with the same default MultiplayerAPI object.

```python
extends Control
@export var address = "127.0.0.1"
@export var port = 8910
var peer
func _ready():
    multiplayer.peer_connected.connect(peer_connected)
    multiplayer.peer_disconnected.connect(peer_disconnected)
    multiplayer.connected_to_server.connect(connected_to_server)
    multiplayer.connection_failed.connect(connection_failed)
# called on server/client
func peer_connected(id):
    print(id)
# called on server/client
func peer_disconnected(id):
    print(id)
# called from only client
func connection failed():
    print("conn_fail")
func _on_host_button_down():
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, 2)
    if error != OK:
        print("Cannot host: " + error)
        return
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    # set the server as the peer
    multiplayer.set_multiplayer_peer(peer)
    print("Waiting for players")
    SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
func _on_join_button_down():
    peer = ENetMultiplayerPeer.new()
    peer.create_client(address, port)
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    multiplayer.set_multiplayer_peer(peer)
    print("Connected to server")
```

RPC means Remote Procedure Call. `any_peer` means everybody will call that function. `authority` means only the authority will call that function. `call_local` means only the local peer will call it. Add this to MultiplayerController.gd:

```python
@rpc("any_peer", "call_local")
func StartGame():
    var scene = load("res://testScene.tscn").instatiate()
    get_tree().root.add_child(scene)
    self.hide()
func _on_start_game_button_down():
    StartGame.rpc() # use rpc_id(1) to only call it on the host
```

Go to File > New Script > GameManager.gd

```python
extends Node
var Players = {}
```

Make it global by: Project > Project Settings > Autoload > Autoload GameManager.gd

```python
@rpc("any_peer")
func SendPlayerInformation(name, id):
    if !GameManager.Players.has(id):
        GameManager.Players[id] = {
            "name": name,
            "id": id,
            "score": 0
        }
    if multiplayer.is_server():
        for i in GameManager.Players:
            SendPlayerInformation.rpc(GameManager.Players[i].name, i)
```

Add a LineEdit and a Label for the name.

```python
# called from only client
func connected_to_server():
    SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())
    print("conn")
```

Add a `SceneManager.gd`:

```python
extends Node2D
@export var PlayerScene: PackedScene
func _ready():
    var index = 0
    for i in GameManager.Players:
        var currentPlayer = PlayerScene.instantiate()
        var currentPlayer.name = GameManager.Players[i].id
        add_child(currentPlayer)
        for spwan in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
            if spawn.name == str(index):
                currentPlayer.global_position = spawn.global_position
        index += 1
```

## Multiplayer Synchronizer

Add a child node `MultiplayerSynchronizer` to the Player scene. Choose `Add property to sync` and choose `Player:position` and it will synchronize the position.

Set the multiplayer authority to be the correct client.

In `Player.gd`:

```python
func _ready():
    # Set the authority for the ID of the client
    $MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
```

Now, we need to make sure if you are not the authority, don't do anything.

```python
func _physics_process(delta):
    if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
        # move the character or whatever
    else:
        # not current player
```

## Change replication intervals

You can change the Rep Interval to 0.1 and Delta Interval there will be stuttering/lag. You can set up custom variables to use to sync across to get more flexibility to add in lerp.

```python
var syncPos = Vector2(0, 0)

func _physics_process(delta):
    ...
    else:
        # not current player
        global_position = global_position.lerp(syncPos, 0.5)
```

Now you can set up the property to sync to be `Player::syncPos`.

## How to do a server? (Dedicated multiplayer server)

```python
func HostGame():
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, 2)
    if error != OK:
        print("Cannot host: " + error)
        return
    peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
    # set the server as the peer
    multiplayer.set_multiplayer_peer(peer)
    print("Waiting for players")

    # We will comment this out because the --server won't send that info.
    #SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
func _ready():
    ...
    if "--server" in OS.get_cmdline_args():
        HostGame()
```

Now you can export it as a Windows EXE and run it with `whatever.exe --server --headless`.

## Disconnections

```python
func peer_disconnected(id):
    GameManager.Players.erase(id)
    # Remove player from scene
    var players = get_tree().get_nodes_in_group("Player")
    for i in players:
        if i.name == str(id)):
            i.queue_free()
```
