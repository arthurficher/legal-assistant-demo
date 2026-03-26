import 'package:flutter/material.dart';
import 'package:flutter_gemini/models/message.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/widgets/assistance_message_widget.dart';
import 'package:flutter_gemini/widgets/my_message_widget.dart';

class ChatsMessages extends StatelessWidget {
  const ChatsMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: chatProvider.inChatMessages.length,
        itemBuilder: (context, index) {
          //compare with timeSent before showing the list
          final message =
              chatProvider.inChatMessages[index];
          return message.role.name == Role.user.name
              ? MyMessageWidget(message: message)
              : AssistanceMessageWidget(
                  message: message.message.toString());
        },
      );
  }
}