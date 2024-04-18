import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lg_ai_controller/widget/widgets.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../connection/SSH.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/connection_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  ChatScreen();

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

enum TtsState { playing, stopped, paused, continued }

class _ChatScreenState extends ConsumerState<ChatScreen> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final safety1 = SafetySetting(HarmCategory.unspecified, HarmBlockThreshold.none);
  final GenerativeModel _geminiModel = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyD_DXVZclhJJMJu3x_PqH7dk8AUbEu4dY0',
  );
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 2;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  String? _prompotedText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;

  bool get isStopped => ttsState == TtsState.stopped;

  bool get isPaused => ttsState == TtsState.paused;

  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWindows => !kIsWeb && Platform.isWindows;

  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  dynamic _initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
        ref.read(isSpeaking.notifier).state = false;
        ref.read(isVoiceStopped.notifier).state = true;
        print("$ttsState Complete");
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _textController.text = result.recognizedWords;
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        ref.read(isSpeaking.notifier).state = true;
        ref.read(isVoiceStopped.notifier).state = false;
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
    print("stopped");
    /*ref.read(isSpeaking.notifier).state = false;*/
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  void _clearChatHistory() {
    setState(() {
      _messages.clear();
    });
    ref.read(isNewChat.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(isVoiceStopped) ? _stop() : _speak();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.watch(isNewChat)) {
        if (_messages.isNotEmpty) {
           showAlertDialog(context, 1);
        } else {
          ref.read(isNewChat.notifier).state = false;
          CustomWidgets().showSnackBar(context: context, message: "No chat history to clear", );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff222222), Color(0xff000000)],
          ),
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (_, int index) => _messages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade700, width: 1.0),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                style: GoogleFonts.spaceGrotesk(
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                decoration: InputDecoration(
                  hintText: 'Send a message',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  // Set hint text color to white
                  border: InputBorder.none,
                  // Remove the border
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),
          _buildMicButton(),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: Icon(
            Icons.send,
            color: Colors.grey,
          ),
          onPressed: () => _handleSubmitted(_textController.text),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          color: Colors.grey,
          onPressed: () {
            if (_speechToText.isNotListening) {
              _startListening();
              _lastWords = "";
              _textController.text = _lastWords;
            } else {
              _stopListening();
            }
          },
        ),
      ),
    );
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isBot: false,
    );
    setState(() {
      _messages.insert(0, message);
    });

    final content = [Content.text(text)];
    final response = await _geminiModel.generateContent(content,generationConfig: GenerationConfig(temperature: 0.7, topP: 0.9, topK: 40));
    String? botResponse = response.text;

    message = ChatMessage(
      text: botResponse!,
      isBot: true,
    );

    setState(() {
      _messages.insert(0, message);
    });

    getLastMessage();
  }

  void _handleSecondInstance(String text) async {
    _prompotedText = "";
    if (text.isNotEmpty) {
      _prompotedText = "Please analyze this $text and extract both the name and the location of each place. Arrange the extracted names and locations in a formatted Dart array, where each entry consists of the place name followed by its location, separated by a comma and space, and enclosed within single quotes.";
     // _prompotedText = "Analyze the text \"$text\" and extract the name of the location from the given string. Arrange the extracted locations in a formatted Dart array.";
      final content = [Content.text(_prompotedText!)];
      final response = await _geminiModel.generateContent(content);

      /*List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");*/
      final List<String> places = parseLocations(response.text!);

      for(int i = 0; i < places.length; i++){
        if(i==0){
          Future.delayed(Duration(seconds: 2 * (i + 1)), () {
            _navigate(places[i]);
          });
        }else{
          Future.delayed(Duration(seconds: 8 * (i + 1)), () {
            _navigate(places[i]);
          });
        }

      }

    } else {
      return; // Return null if the list is empty
    }
  }
  List<String> parseLocations(String locationsString) {
    // Split the string into lines
    final lines = locationsString.split('\n');

    // Extract location names from lines
    final List<String> places = [];
    for (final line in lines) {
      // Remove leading and trailing whitespace
      final trimmedLine = line.trim();

      // Check if the line is a location definition
      if (trimmedLine.startsWith("'") && trimmedLine.endsWith("',")) {
        // Extract the location name between single quotes
        final place = trimmedLine.substring(1, trimmedLine.length - 2);
        places.add(place);
      }
    }

    return places;
  }


  void getLastMessage() {
    if (_messages.isNotEmpty) {
      final ChatMessage lastMessage = _messages.first;
      _loadChatResponse(lastMessage.text);
      _newVoiceText = lastMessage.text;
      _handleSecondInstance(lastMessage.text);
      _speak();
    } else {
      return; // Return null if the list is empty
    }
  }



  Future<void> _loadChatResponse(String response) async {
    await SSH(ref: ref).cleanSlaves(context);
    await SSH(ref: ref).cleanBalloon(context);
    await SSH(ref: ref).ChatResponseBalloon(response);
    await SSH(ref:ref).stopOrbit(context);
  }

  showAlertDialog(
    BuildContext context,
    int ind,
  ) {
    ref.read(isNewChat.notifier).state = false;
    Widget cancelButton = TextButton(
      child: Text("Cancel",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
      onPressed: () {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          )),
      onPressed: () {
        Navigator.of(context).pop();
        if (ind == 1) {

          Future.microtask(() => _clearChatHistory());
        } else if (ind == 2) {

        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.grey.shade900,
      title: Text("Confirmation",
          style: GoogleFonts.spaceGrotesk(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )),
      content: Text(
        (ind == 1)
            ? "Are you sure you want to clear chat history?"
            : "Are you sure you want to disconnect from LG?",
        style: GoogleFonts.spaceGrotesk(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  Future<void> _navigate(String location) async {
    SSHSession? session = await SSH(ref: ref)
        .search("$location");
    if (session != null) {
      print(session.stdout);
    }
  }
}

class ChatMessage extends ConsumerStatefulWidget {
  final String text;
  final bool isBot;

  ChatMessage({required this.text, required this.isBot});

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends ConsumerState<ChatMessage> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20, top: 10, bottom: 10),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment:
              widget.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.isBot) // Display avatar only for bot messages
              Container(
                margin: EdgeInsets.only(right: 16.0, left: 16.0),
                child: Image.asset(
                  'assets/images/astronaut.png',
                  height: 50,
                  width: 50, // You can customize the bot avatar here
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment:
                      widget.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      widget.isBot ? 'Galaxy Guider' : 'User',
                      style: GoogleFonts.spaceGrotesk(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2.0),
                      child: Text(
                        widget.text,
                        style: GoogleFonts.spaceGrotesk(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.isBot)
              SizedBox(
                height: 50,
                child: Container(
                  margin: EdgeInsets.only(right: 16.0, left: 16.0),
                  child: CircleAvatar(
                    child: Image.asset(
                      'assets/images/user3.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                    // You can customize the user avatar here
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}
class GeoFeature {
  final String name;
  final List<double> coordinates;

  GeoFeature({required this.name, required this.coordinates});
}