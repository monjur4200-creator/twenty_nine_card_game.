// lib/widgets/chat_widget.dart
import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatWidget extends StatefulWidget {
  final ChatService chatService;
  final String channelType; // "global" | "team1" | "team2" | "friends"
  final String? roomId;     // required for room channels
  final String userId;
  final String userName;
  final String? friendId;   // required for friends channel

  const ChatWidget({
    super.key,
    required this.chatService,
    required this.channelType,
    required this.userId,
    required this.userName,
    this.roomId,
    this.friendId,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.channelType == 'friends') {
      if (widget.friendId == null) return;
      await widget.chatService.sendFriendMessage(
        userId: widget.userId,
        friendId: widget.friendId!,
        senderName: widget.userName,
        text: text,
      );
    } else {
      if (widget.roomId == null) return;
      await widget.chatService.sendRoomMessage(
        roomId: widget.roomId!,
        channel: widget.channelType,
        senderId: widget.userId,
        senderName: widget.userName,
        text: text,
      );
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<List<Map<String, dynamic>>> stream =
        widget.channelType == 'friends'
            ? widget.chatService.listenToFriendMessages(
                userId: widget.userId,
                friendId: widget.friendId!,
              )
            : widget.chatService.listenToRoomMessages(
                roomId: widget.roomId!,
                channel: widget.channelType,
              );

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data!;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final name = (msg['senderName'] ?? 'Unknown') as String;
                  final text = (msg['text'] ?? '') as String;

                  return ListTile(
                    dense: true,
                    title: Text(name, style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    )),
                    subtitle: Text(text),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    );
  }
}