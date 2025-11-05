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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
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
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No messages yet. Start the conversation!"),
                );
              }

              final messages = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final name = (msg['senderName'] ?? 'Unknown') as String;
                  final text = (msg['text'] ?? '') as String;
                  final isMe = msg['senderId'] == widget.userId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.blue[200]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          Text(text),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: "Type a message...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
