import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/constants.dart';
import 'package:flutter_gemini/hive/boxes.dart';
import 'package:flutter_gemini/hive/chat_history.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/hive/user_model.dart';
import 'package:flutter_gemini/models/message.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer';

import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  //list of messages
  final List<Message> _inChatMessage = [];

  //page controller
  final PageController _pageController = PageController();

  //images file list
  List<XFile>? _imagesFileList = [];

  //inde of the current screen
  int _currentIndex = 0;

  // current chat id
  String _currentChatId = '';

  //initialize generative model
  GenerativeModel? _model;

  //initialize text model
  GenerativeModel? _textModel;

  //initialize vision model
  GenerativeModel? _visionModel;

  //current model
  String _modelType = 'gemini-pro';

  //loading bool
  bool _isLoading = false;

  //getters
  List<Message> get inChatMessages => _inChatMessage;

  PageController get pageController => _pageController;

  List<XFile>? get imageFileList => _imagesFileList;

  int get currentIndex => _currentIndex;

  String get currentChatId => _currentChatId;

  GenerativeModel? get model => _model;

  GenerativeModel? get textModel => _textModel;

  GenerativeModel? get visionModel => _visionModel;

  String get modelType => _modelType;

  bool get isLoading => _isLoading;

  //setters

  //set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    //get messages from hive database
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessage.contains(message)) {
        log('message already exists');
        continue;
      }

      _inChatMessage.add(message);
    }

    notifyListeners();
  }

  //load the messages from db
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // open the vox of this chatID
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));

      return messageData;
    }).toList();

    notifyListeners();
    return newData;
  }

  //set file list
  void setImageFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  //set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  //function to set the model based on bool - isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    // Instrucción para el modelo de IA
    final systemInstruction = Content.system(
      'Eres un asistente legal virtual especializado en el sistema judicial de Paraguay. '
      'Tu propósito es proporcionar información precisa y confiable sobre leyes, '
      'procedimientos y terminología legal paraguaya. '
      'Si un usuario te saluda, responde amablemente. '
      'Si la pregunta del usuario no está relacionada con el ámbito legal, '
      'debes declinar cortésmente la respuesta, indicando que solo puedes '
      'ayudar con asuntos legales. No respondas preguntas que estén fuera de este dominio.'
    );

    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-flash'),
            apiKey: getApiKey(),
            systemInstruction: systemInstruction,
            generationConfig: GenerationConfig(
              temperature: 0.4,
              topK: 32,
              topP: 1,
              maxOutputTokens: 4096
            ),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ]
          );
    } else {
      _model = _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-2.5-flash'),
            apiKey: getApiKey(),
            systemInstruction: systemInstruction,
            generationConfig: GenerationConfig(
              temperature: 0.4,
              topK: 32,
              topP: 1,
              maxOutputTokens: 4096
            ),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ]
          );
    }

    // Registrar el estado del modelo después de la inicialización
    log('Model set: $_model');
    notifyListeners();
  }

  String getApiKey(){
    // Si estamos en modo mock, retornar una key fake
    if (Constants.useMockChat) {
      return 'mock-api-key';
    }
    // Retornar la API key real del archivo .env
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'null') {
      log('WARNING: GEMINI_API_KEY no encontrada en .env');
      return 'mock-api-key';  // Fallback a mock
    }
    return apiKey;
  }

  //set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  //set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  //set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }
  //delete chat
  Future<void> deleteChatMessages({required String chatId}) async{
    //1. check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      //open the box
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
      
      //delete all messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      //close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    //get current chatId, its not empty
    //we check if its the same as the chatId
    //if its the same we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        _inChatMessage.clear();
        notifyListeners();
      }
    }
  }

  //prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    if (!isNewChat) {
      //1. load the chat messages from the db
      final chatHistory = await loadMessagesFromDB(chatId: chatID);

      //2. clear the inChatMessages
      _inChatMessage.clear();

      for (var message in chatHistory) {
        _inChatMessage.add(message);
      }

      //3. set the current chat id
      setCurrentChatId(newChatId: chatID);
    } else {
      //1. clear the inChatMessage
      _inChatMessage.clear();

      //2. set the current chat id
      setCurrentChatId(newChatId: chatID);
    }
  }

  //send message to gemini and get the streamed response
  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    //set the model
    await setModel(isTextOnly: isTextOnly);

    //set loading
    setLoading(value: true);

    //get the chatId
    String chatId = getChatId();

    //list of history messages
    List<Content> history = [];

    //get the chat history
    history = await getHistory(chatId: chatId);

    //get the imagesUrls
    List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);

    //open the messages box
    final messagesBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');

        log('messageLength: ${messagesBox.keys.length}');

    //get the last user message id
    final userMessageId = messagesBox.keys.length;

    //assistant messeageId
    final assistantMessageId = messagesBox.keys.length + 1;

    log('userMessageId: $userMessageId');

    log('model: $assistantMessageId');

    //user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    //add this message to the list on inchatMessages
    _inChatMessage.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    //send the message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messagesBox: messagesBox,
    );
  }

  //send message to the model and wait for the response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId, 
    required Box messagesBox,
  }) async {
    //assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    //add this message to the list on inChatMessages
    _inChatMessage.add(assistantMessage);
    notifyListeners();

    // Si estamos en modo mock, generar respuesta mock
    if (Constants.useMockChat) {
      log('Usando respuesta MOCK para el chat');
      await _sendMockResponse(
        message: message,
        chatId: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        messagesBox: messagesBox,
      );
      return;
    }

    // Código original para Gemini real
    try {
      // Comprobar si _model es nulo antes de usarlo
      if (_model == null) {
        throw Exception('Model is not initialized');
      }

      // Registrar el estado del modelo antes de iniciar la sesión de chat
      log('_model: ${_model.toString()}');
      log('history: ${history.toString()}');

      //start the chat session -  only send history is its text-only
      final chatSession = _model!.startChat(
        history: history.isEmpty || !isTextOnly ? null : history,
      );

      //get content
      final content = await getContent(
        message: message,
        isTextOnly: isTextOnly,
      );

      //wait for stream response
      chatSession.sendMessageStream(content).asyncMap((event) {
        return event;
      }).listen(
        (event) {
          _inChatMessage
              .firstWhere((element) =>
                  element.messageId == assistantMessage.messageId &&
                  element.role.name == Role.assistant.name)
              .message
              .write(event.text);
          notifyListeners();
        },
        onDone: () async {
          //save message to hive database
          await saveMessagesToDB(
              chatID: chatId,
              userMessage: userMessage,
              assistantMessage: assistantMessage,
              messagesBox: messagesBox,
            );
              
          //set loading to false
          setLoading(value: false);
        },
      ).onError((error, stacktrace) {
        log('Error en Gemini: $error');
        //set loading
        setLoading(value: false);
      });
    } catch (e) {
      log('Error al enviar mensaje a Gemini: $e');
      // En caso de error, enviar respuesta mock
      await _sendMockResponse(
        message: message,
        chatId: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        messagesBox: messagesBox,
      );
    }
  }

  // Método privado para enviar respuesta mock
  Future<void> _sendMockResponse({
    required String message,
    required String chatId,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    // Generar respuesta mock basada en el mensaje del usuario
    String mockResponse = _generateMockResponse(message);
    
    // Simular streaming escribiendo la respuesta por partes
    List<String> words = mockResponse.split(' ');
    
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(Duration(milliseconds: 50));
      
      _inChatMessage
          .firstWhere((element) =>
              element.messageId == assistantMessage.messageId &&
              element.role.name == Role.assistant.name)
          .message
          .write(words[i]);
      
      // Agregar espacio excepto en la última palabra
      if (i < words.length - 1) {
        _inChatMessage
            .firstWhere((element) =>
                element.messageId == assistantMessage.messageId &&
                element.role.name == Role.assistant.name)
            .message
            .write(' ');
      }
      
      notifyListeners();
    }

    // Guardar mensajes en la base de datos
    await saveMessagesToDB(
      chatID: chatId,
      userMessage: userMessage,
      assistantMessage: assistantMessage,
      messagesBox: messagesBox,
    );
    
    // Desactivar loading
    setLoading(value: false);
  }

  // Generar respuesta mock inteligente basada en el mensaje
  String _generateMockResponse(String userMessage) {
    final messageLower = userMessage.toLowerCase();
    
    // Respuestas contextuales según el contenido del mensaje
    if (messageLower.contains('hola') || messageLower.contains('hi')) {
      return '¡Hola! Soy un asistente de prueba. Esta es una respuesta simulada porque estás en modo MOCK. Para usar Gemini real, configura tu API key en el archivo .env y desactiva useMockChat en constants.dart.';
    } else if (messageLower.contains('ayuda') || messageLower.contains('help')) {
      return 'Estoy aquí para ayudarte. Actualmente estoy funcionando en modo de prueba (mock). Puedes hacerme cualquier pregunta y te daré respuestas simuladas.';
    } else if (messageLower.contains('qué') || messageLower.contains('que') || messageLower.contains('what')) {
      return 'Esa es una buena pregunta. En modo mock, simulo respuestas inteligentes para que puedas probar la aplicación sin necesidad de una API key de Gemini.';
    } else if (messageLower.contains('cómo') || messageLower.contains('como') || messageLower.contains('how')) {
      return 'Para responder a tu pregunta sobre "cómo": Esta es una respuesta de ejemplo. Recuerda que estás usando el modo de prueba. Configura Constants.useMockChat = false para usar Gemini real.';
    } else {
      return 'Gracias por tu mensaje: "$userMessage". Esta es una respuesta simulada del sistema mock. La aplicación está funcionando correctamente en modo de prueba. Para obtener respuestas reales de Gemini AI, necesitas configurar tu API key.';
    }
  }

  //save messages to hive db
  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage, 
    required Box messagesBox,
  }) async {
    //save the user messages
    await messagesBox.add(userMessage.toMap());

    //save the assistant messages
    await messagesBox.add(assistantMessage.toMap());

    //save chat history with te same chatId
    //if its allready there update it only with meaningful messages
    //if not create a new one
    final chatHistoryBox = Boxes.getChatHistory();
    
    // Verificar si el mensaje es solo un saludo simple
    final isSimpleGreeting = _isSimpleGreeting(userMessage.message.toString());
    
    // Obtener el historial existente si lo hay
    final existingHistory = chatHistoryBox.get(chatID);
    
    // Solo actualizar el historial si:
    // 1. No existe aún, O
    // 2. Existe pero el nuevo mensaje no es un saludo simple
    if (existingHistory == null || !isSimpleGreeting) {
      final chatHistory = ChatHistory(
          chatId: chatID,
          prompt: userMessage.message.toString(),
          response: assistantMessage.message.toString(),
          imagesUrls: userMessage.imagesUrls,
          timestamp: DateTime.now());
      await chatHistoryBox.put(chatID, chatHistory);
    }

    //close de box
    await messagesBox.close();
  }

  // Helper para detectar saludos simples
  bool _isSimpleGreeting(String message) {
    final lowerMessage = message.toLowerCase().trim();
    final greetings = [
      'hola',
      'hello',
      'hi',
      'hey',
      'buenos días',
      'buenas tardes',
      'buenas noches',
      'buen día',
      'saludos',
      'qué tal',
      'que tal',
      'cómo estás',
      'como estas',
      'cómo está',
      'como esta'
    ];
    
    return greetings.any((greeting) => 
      lowerMessage == greeting || 
      lowerMessage == '$greeting!' || 
      lowerMessage == '$greeting?'
    );
  }

  Future<Content> getContent({
    required String message,
    required bool isTextOnly,
  }) async {
    if (isTextOnly) {
      //generate text from text-only input
      return Content.text(message);
    } else {
      //generate image form text and image input
      final imageFutures = _imagesFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // get y=the imagesUrls
  List<String> getImagesUrls({
    required bool isTextOnly,
  }) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imageFileList != null) {
      for (var image in imageFileList!) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (var message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  //init Hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();

    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    //register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());

      // open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.deleteBoxFromDisk(Constants.userBox);
await Hive.openBox<UserModel>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
