import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/api/account_api.dart';
import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/hive/boxes.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/models/user.dart';
import 'package:flutter_gemini/providers/dart_provider.dart';
import 'package:flutter_gemini/screens/login.dart';
import 'package:flutter_gemini/widgets/build_display_image.dart';
import 'package:flutter_gemini/widgets/settings_tile.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../hive/user_model.dart';

// MODO DEMO: Esta pantalla usa datos mock para demostración
// Para usar el API real, ver el método _loadUser() más abajo
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authenticationClient = GetIt.instance<AuthenticationClient>();
  final _accountAPI = GetIt.instance<AccountApi>();
  Logger _logger = Logger();
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usando datos mock para la demo
      _loadMockUser();
      
      // Código de consulta real al endpoint (comentado para demo)
      // Descomentar la siguiente línea para usar el API real:
      // _loadUser();
    });
  }

  Future<void> _signOut() async {
    // Lógica para cerrar sesión
    await _authenticationClient.singOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Login.routeName,
      (_) => false,
    );
  }

  File? file;
  String userImage = '';
  String userName = 'User';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  // pick an image
  void pickImage(ImageSource source) async {
    try {
      final pickedImage = await _picker.pickImage(
        source: source,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        if (mounted) {
          setState(() {
            file = File(pickedImage.path);
            userImage = file!.path;
          });
        }
      }
    } catch (e) {
      log('error : $e');
    }
  }

  // ================== CONSULTA REAL AL ENDPOINT ==================
  // Este método consulta el API real para obtener datos del usuario
  // Actualmente está comentado en initState() para usar datos mock en la demo
  // Para usar el API real, descomentar _loadUser() y comentar _loadMockUser() en initState()
  Future<void> _loadUser() async {
    _accountAPI.getUserInfo();
    final response = await _accountAPI.getUserInfo();
    if (response.data != null) {
      if (mounted) {
        setState(() {
          _user = response.data!;
        });
      }
    }
  }

  // ================== DATOS MOCK PARA DEMO ==================
  // Método para cargar datos mock (demo)
  Future<void> _loadMockUser() async {
    // Simular delay de red
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        // Crear usuario mock para demostración
        _user = User(
          id: '1',
          username: 'Demo User',
          email: 'demo@legalassistant.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecciona la fuente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _signOut,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: BuildDisplayImage(
                      file: file,
                      userImage: userImage,
                      onPressed: showImageSourceDialog),
                ),

                const SizedBox(height: 20.0),

                // user name
                // Editable user name
                // Editable user name with edit icon
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            _user == null
                                ? CircularProgressIndicator() 
                                : Column(
                                    children: [
                                      Text(
                                        _user!.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        _user!.email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40.0),

                ValueListenableBuilder<Box<Settings>>(
                    valueListenable: Boxes.getSettings().listenable(),
                    builder: (context, box, child) {
                      if (box.isEmpty) {
                        return Column(
                          children: [
                            // ai voice
                            SettingsTile(
                                icon: Icons.mic,
                                title: 'Activar voz de la IA',
                                value: false,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleSpeak(
                                    value: value,
                                  );
                                }),

                            const SizedBox(height: 10.0),

                            // theme
                            SettingsTile(
                                icon: Icons.light_mode,
                                title: 'Tema',
                                value: false,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleDarkMode(
                                    value: value,
                                  );
                                }),
                          ],
                        );
                      } else {
                        final settings = box.getAt(0);
                        return Column(
                          children: [
                            // ai voice
                            SettingsTile(
                                icon: Icons.mic,
                                title: 'Activar voz de la IA',
                                value: settings!.shouldSpeak,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleSpeak(
                                    value: value,
                                  );
                                }),

                            const SizedBox(height: 10.0),

                            // theme
                            SettingsTile(
                                icon: settings.isDarkTheme
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                title: 'Tema',
                                value: settings.isDarkTheme,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleDarkMode(
                                    value: value,
                                  );
                                }),
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ));
  }
}
