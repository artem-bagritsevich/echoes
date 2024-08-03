import 'package:avatar_glow/avatar_glow.dart';
import 'package:echoes/chat_view_model.dart';
import 'package:echoes/mvvm/view_state_observer.dart';
import 'package:echoes/view/error_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

const String defaultErrorText = "An Error occured";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echoes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin
    implements ViewStateObserver {
  final ChatViewModel _viewModel = ChatViewModel();
  late final AnimationController _controller;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    _viewModel.subscribe(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.unsubscribe(this);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Aristotle',
                style: GoogleFonts.gfsNeohellenic(
                    fontSize: 50.0,
                    color: const Color.fromARGB(221, 23, 23, 23))),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: _isListening,
          glowColor: Theme.of(context).primaryColor,
          duration: const Duration(milliseconds: 1500),
          repeat: true,
          child: FloatingActionButton.large(
            onPressed: () => _isThinking ? null : _viewModel.onMicButtonClick(),
            shape: const CircleBorder(),
            child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
              child: Center(
                child: AvatarGlow(
                    animate: _isSpeaking,
                    glowRadiusFactor: 0.4,
                    glowColor: Theme.of(context).primaryColor,
                    duration: const Duration(milliseconds: 1500),
                    repeat: true,
                    child: const CircleAvatar(
                        radius: 180,
                        foregroundImage:
                            AssetImage('assets/aristotle_avatar.png'))),
              ),
            ), // main screen
            Padding(
              padding: const EdgeInsets.fromLTRB(300, 0, 0, 475),
              child: Center(
                child: Visibility(
                    visible: _isThinking,
                    child: SizedBox(
                        width: 115,
                        height: 115,
                        child: Lottie.asset('assets/sandwatch_animation.json',
                            controller: _controller, onLoaded: (c) {
                          _controller.repeat();
                        }))),
              ),
            )
          ],
        ));
  }

  @override
  void notify(ViewState state) {
    print(state.toString());
    switch (state) {
      case IdleState _:
        setIdleState();
      case ErrorState state:
        setErrorState(state.errorText);
      case AskingState _:
        setAskingState();
      case ThingkingState _:
        setThinkingState();
      case AnsweringState _:
        setAnsweringState();
    }
  }

  void _showErrorCard(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ErrorCard(errorMessage: errorMessage),
        backgroundColor: Colors.transparent, 
        elevation: 0.0,
        duration: const Duration(hours: 1),
        dismissDirection: DismissDirection.none,
      ),
    );
  }

  void setIdleState() {
    setState(() {
      _isListening = false;
      _isSpeaking = false;
      _isThinking = false;
      ScaffoldMessenger.of(context).clearSnackBars();
    });
  }

  void setErrorState(String errorMessage) {
    setState(() {
      _isListening = false;
      _isSpeaking = false;
      _isThinking = false;
    });
    _showErrorCard(context, errorMessage);
  }

  void setAskingState() {
    setState(() {
      _isListening = true;
      _isSpeaking = false;
      _isThinking = false;
    });
  }

  void setThinkingState() {
    setState(() {
      _isListening = false;
      _isSpeaking = false;
      _isThinking = true;
    });
  }

  void setAnsweringState() {
    setState(() {
      _isListening = false;
      _isSpeaking = true;
      _isThinking = false;
    });
  }
}
