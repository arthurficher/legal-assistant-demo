import 'package:flutter/material.dart';
import 'package:flutter_gemini/hive/chat_history.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/utility/utilites.dart';
import 'package:provider/provider.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
        leading: const CircleAvatar(
          radius: 30,
          child: Icon(Icons.chat),),
        title: Text(chat.prompt, maxLines: 1,),
        subtitle: Text(chat.response, maxLines: 2,),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: ()async{
          //navigate to chat screen
          final chatProvider = context.read<ChatProvider>();
          //prepare chat room
          await chatProvider.prepareChatRoom(isNewChat: false, chatID: chat.chatId);
          chatProvider.setCurrentIndex(newIndex: 0);
          chatProvider.pageController.jumpToPage(0);
        },
        onLongPress: (){
          //show my animated dialog to delete the chat
          showMyAnimatedDialog( 
            context: context, 
            title: 'Eliminar chat', 
            content: '¿Esta seguro que desea eliminar este chat?', 
            actionText: 'Eliminar', 
            onActionPressed: (value)async{
              if (value) {
                //eliminar chat
                await context.read<ChatProvider>().deleteChatMessages(chatId: chat.chatId);

                //delete the chat history
                await chat.delete();
              }
            }
          );
        },
      ),
    );
  }
}