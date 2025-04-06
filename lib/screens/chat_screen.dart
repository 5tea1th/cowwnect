import 'package:cowwnect/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

String apiKey = ApiKey().apiKey; // Replace with your actual API key

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = []; // Store chat history
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  void _initializeGemini() {
    try {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    } catch (e) {
      // Error handling can be improved
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add("You: $message");
      _isLoading = true;
    });

    try {
      final response = await _model.generateContent([Content.text(message)]);

      String botResponse = "No response from Gemini.";
      if (response.candidates.isNotEmpty) {
        botResponse = response.candidates.first.content.parts
            .map((part) => part is TextPart ? part.text : part.toString())
            .join("\n");
      }

      setState(() {
        _messages.add("Gemini: $botResponse");
      });
    } catch (e) {
      setState(() {
        _messages.add("Error: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Chat"), backgroundColor: Color(0xFFBC84FF)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isUserMessage = _messages[index].startsWith("You:");
                  return Align(
                    alignment:
                    isUserMessage ? Alignment.centerRight : Alignment
                        .centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery
                          .of(context)
                          .size
                          .width * 0.75),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Color(0xFFF8BBD0) : Color(
                            0xFFE1BEE7),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUserMessage ? 16 : 0),
                          bottomRight: Radius.circular(isUserMessage ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        _messages[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        filled: true,
                        fillColor: Color(0xFFFCE4EC), // softer pink fill
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _sendMessage(value);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Theme
                        .of(context)
                        .floatingActionButtonTheme
                        .backgroundColor,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}