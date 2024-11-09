// ignore_for_file: prefer_const_constructors

import 'package:chat_app/Controller/ChatController.dart';
import 'package:chat_app/utils/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputField extends StatefulWidget {
  final String uid;
  const ChatInputField({super.key, required this.uid});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _showAttachment = false;
  TextEditingController message = TextEditingController();
  final chatController = Get.put(ChatController());

  void _updateAttachmentState() {
    setState(() {
      _showAttachment = !_showAttachment;
    });
  }

  @override
  void initState() {
    super.initState();
    chatController.getAllMessages(widget.uid); // Use widget.uid here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Obx(() {
              // Listen to changes in allMessages
              return ListView.builder(
                shrinkWrap: true,
                itemCount: chatController.allMessages.length,
                itemBuilder: (context, index) {
                  final messageData = chatController.allMessages[index];
                  // Customize your message display here
                  return ListTile(
                    title: Text(messageData['content']), // Example field
                  );
                },
              );
            }),
            Row(
              children: [
                const Icon(Icons.mic, color: Color(0xFF00BF6D)),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 16.0 / 4),
                      Expanded(
                        child: TextField(
                          controller: message,
                          decoration: InputDecoration(
                            hintText: "Type message",
                            suffixIcon: SizedBox(
                              width: 65,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (message.text.isNotEmpty) {
                                        await chatController.sendMessage(
                                          message.text,
                                          current_userId, // Use widget.uid here
                                          widget.uid, // And here
                                        );
                                        message.clear(); // Clear input field
                                      }
                                    },
                                    child: const Icon(Icons.send),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0 / 2),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withOpacity(0.64),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor:
                                const Color(0xFF00BF6D).withOpacity(0.08),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0 * 1.5, vertical: 16.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesScreen extends StatefulWidget {
  final String name;
  final String uid;

  const MessagesScreen({super.key, required this.name, required this.uid});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatController chatController = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    chatController.getAllMessages(widget.uid);
    print("reciever uid ${widget.uid}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF00BF6D),
        leading: BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage("https://i.postimg.cc/cCsYDjvj/user-2.png"),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: TextStyle(fontSize: 16, color: Colors.white)),
                Text("Active 3m ago",
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: chatController.getAllMessages(widget.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading messages"));
                  }
                  final messages = snapshot.data!;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      // print("messages[index] ${messages[index]}");
                      return Message(
                        message: messages[index],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ChatInputField(uid: widget.uid),
        ],
      ),
    );
  }
}

class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.message,
  });

  final message;

  @override
  Widget build(BuildContext context) {
    Widget messageContaint(message) {
      // switch (message.messageType) {
      //   case ChatMessageType.text:
      return TextMessage(message: message);
      //   default:
      //     return const SizedBox();
      // }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: message['isSender']
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message["isSender"]) ...[
            const CircleAvatar(
              radius: 12,
              backgroundImage:
                  NetworkImage("https://i.postimg.cc/cCsYDjvj/user-2.png"),
            ),
            const SizedBox(width: 16.0 / 2),
          ],
          messageContaint(message),
          // if (message.isSender) MessageStatusDot(status: message.messageStatus)
        ],
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    this.message,
  });

  final message;

  @override
  Widget build(BuildContext context) {
    // print(message);
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth:
            screenWidth * 0.5, // Set the maxWidth to 50% of the screen width
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0 * 0.75,
          vertical: 16.0 / 2,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF00BF6D)
              .withOpacity(message["isSender"] ? 1 : 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message["text"],
          style: TextStyle(
            color: message["isSender"]
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({super.key, this.status});
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.notSent:
          return const Color(0xFFF03738);
        case MessageStatus.notView:
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return const Color(0xFF00BF6D);
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 16.0 / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.notSent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

enum ChatMessageType { text, audio, image, video }

enum MessageStatus { notSent, notView, viewed }

class ChatMessage {
  final String text;
  // final ChatMessageType messageType;
  // final MessageStatus messageStatus;
  final bool isSender;

  ChatMessage({
    this.text = '',
    // required this.messageType,
    // required this.messageStatus,
    required this.isSender,
  });
}
