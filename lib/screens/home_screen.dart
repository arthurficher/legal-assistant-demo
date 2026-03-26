import 'package:flutter/material.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/screens/chat_history_screen.dart';
import 'package:flutter_gemini/screens/chat_screen.dart';
import 'package:flutter_gemini/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "homeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //list of screens
  final List<Widget> _screens = [
    const ChatScreen(),
    const ChatHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          body: PageView(
            controller: chatProvider.pageController,
            physics: NeverScrollableScrollPhysics(),
            children: _screens,
            onPageChanged: (index) {
              chatProvider.setCurrentIndex(newIndex: index);
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, 
            currentIndex: chatProvider.currentIndex,
            elevation: 0,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            onTap: (index) {
              chatProvider.setCurrentIndex(newIndex: index);
              chatProvider.pageController.jumpToPage(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial del Chat',
              ),
              
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
