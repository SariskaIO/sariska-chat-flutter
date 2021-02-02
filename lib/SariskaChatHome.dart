import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'util.dart';
import 'package:intl/intl.dart';

class SariskaChatHome extends StatefulWidget {
  final WebSocketChannel channel;
  SariskaChatHome({@required this.channel});
  @override
  _SariskaChatHomeState createState() => _SariskaChatHomeState();
}

class _SariskaChatHomeState extends State<SariskaChatHome>
    with SingleTickerProviderStateMixin {
  List<ChatMessage> messages = [];
  PhoenixChannel _channel;
  TextEditingController editingController = new TextEditingController();
  TabController _tabController;
  bool showFab = true;
  @override
  void initState() {
    connectSocket();
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
  }

  _say(payload, _ref, _joinRef) {
    setState(() {
      messages.insert(0, ChatMessage(text: payload["message"]));
    });
  }

  _sendMyMessage(message) {
    print("Hi 2");
    this._channel.push(event: "say", payload: {"message": message});
    editingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SARISKA CHAT"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.chat_bubble_outlined)),
            Tab(
              text: "BROWSE",
            ),
            Tab(
              text: "CALL",
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemBuilder: (BuildContext context, int index) {
                final message = messages[index];
                return Card(
                    child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.message),
                        title: Text(message.text),
                        subtitle: Text(message.time)),
                  ],
                ));
              },
              itemCount: messages.length,
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Container(
              child: MessageComposer(
            textController: editingController,
            sendMyMessage: _sendMyMessage,
          ))
        ],
      ),
    );
  }

  void _dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  connectSocket() async {
    var token = await fetchToken();
    print("Hi 1");
    final options = PhoenixSocketOptions(params: {"token": token});
    final socket = PhoenixSocket(
        "wss://api.sariska.io/api/v1/messaging/websocket",
        socketOptions: options);
    await socket.connect();
    socket.onOpen(() {
      print('there was an error with the connection!');
    });
    print("Hi 1");
    this._channel = socket.channel("chat:lobby123");
    this._channel.on("say", _say);
    print(this._channel);
    this._channel.join();
  }
}

class ChatMessage {
  final String text;
  final DateTime received = DateTime.now();
  ChatMessage({this.text});
  get time => DateFormat.Hms().format(received);
}

class MessageComposer extends StatelessWidget {
  final textController;
  final sendMyMessage;

  MessageComposer({this.textController, this.sendMyMessage});
  build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                  controller: textController,
                  onSubmitted: sendMyMessage,
                  decoration:
                      InputDecoration.collapsed(hintText: "Send a message")),
            ),
            Container(
              child: IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () => sendMyMessage(textController.text)),
            )
          ],
        ));
  }
}
