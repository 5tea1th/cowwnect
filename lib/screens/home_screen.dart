import 'package:cowwnect/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import '../services/model_service.dart';
import '../widgets/image_picker_widget.dart';
import '../screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ModelService _modelService = ModelService();
  File? _image;
  String _result = "Select an image";
  String _breedInfo = ""; // Store Gemini's response
  bool _isLoading = false;
  late GenerativeModel _geminiModel;

  @override
  void initState() {
    super.initState();
    _modelService.loadModel().then((message) {
      setState(() => _result = message);
    });
    _initializeGemini();
  }

  void _initializeGemini() {
    String apiKey = ApiKey().apiKey; // Replace with actual key
    _geminiModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  void _setImage(File image) async {
    setState(() {
      _image = image;
      _isLoading = true;
    });

    String prediction = await _modelService.classifyImage(image);

    setState(() {
      _result = prediction;
      _isLoading = false;
    });

    _fetchBreedInfo(prediction);
  }

  Future<void> _fetchBreedInfo(String breed) async {
    try {
      final response = await _geminiModel.generateContent([Content.text("Tell me about the cow breed in 100 words- $breed")]);
      if (response.candidates.isNotEmpty) {
        setState(() {
          _breedInfo = response.candidates.first.content.parts
              .whereType<TextPart>() // Ensures we only process TextPart instances
              .map((part) => part.text) // Extracts the actual text
              .join("\n");
        });
      }
    } catch (e) {
      setState(() {
        _breedInfo = "Error fetching information: $e";
      });
    }
  }

  Widget _buildHomeScreenContent() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                _image == null
                    ? Image.asset('assets/placeholder_cow.png', height: 200)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_image!, height: 200),
                      ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        _result,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  _breedInfo.isNotEmpty ? _breedInfo : "Description About Breed",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Theme(
                  data: Theme.of(context),
                  child: ImagePickerWidget(onImageSelected: _setImage),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    },
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: const Text("Chat With Gemini"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFBC84FF),
        title: const Center(child: Text('Cow Breed Detector')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile/settings navigation
            },
          ),
        ],
      ),
      body: _buildHomeScreenContent(),
    );
  }
}