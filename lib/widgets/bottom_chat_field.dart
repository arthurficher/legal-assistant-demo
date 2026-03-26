import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/utility/utilites.dart';
import 'package:flutter_gemini/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  //controller for the input field
  final TextEditingController textController = TextEditingController();

  //focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  //initialize image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sentMessage(
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImageFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  //pick an image
  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImageFileList(listValue: pickedImages);
    } catch (e) {
      log('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    bool hasImages = widget.chatProvider.imageFileList !=null &&
      widget.chatProvider.imageFileList!.isNotEmpty;


    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if(hasImages) const PreviewImagesWidget(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (hasImages) {
                    //show the delete dialog
                    showMyAnimatedDialog(
                      context: context, 
                      title: 'Eliminado de Imagen', 
                      content: '¿Seguro que quiere eliminar la imagen?', 
                      actionText: 'Eliminar', 
                      onActionPressed: (value){
                        widget.chatProvider
                        .setImageFileList(listValue: []);
                      });
                  } else {
                    pickImage();
                  }
                },
                icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 5,
                  minLines: 1,
                  onSubmitted: widget.chatProvider.isLoading ? null : (String value) {
                    if (value.isNotEmpty) {
                      //send the message
                      sendChatMessage(
                          message: textController.text,
                          chatProvider: widget.chatProvider,
                          isTextOnly: hasImages ? false : true,);
                    }
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Ingrese su mensaje',
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.chatProvider.isLoading ? null: () {
                  if (textController.text.isNotEmpty) {
                    //send the message
                    sendChatMessage(
                        message: textController.text,
                        chatProvider: widget.chatProvider,
                        isTextOnly: hasImages ? false : true,
                      );
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: const EdgeInsets.all(5.0),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
