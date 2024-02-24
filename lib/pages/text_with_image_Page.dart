import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geminitest/config.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class TextWithImagePage extends StatefulWidget {
  const TextWithImagePage({super.key});

  @override
  State<TextWithImagePage> createState() => _TextWithImagePageState();
}

class _TextWithImagePageState extends State<TextWithImagePage> {
   final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();
  final GenerativeModel _model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
  bool _loading = false;
  
  File? imageFile;

  final ImagePicker picker = ImagePicker();


  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  void _getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = image != null ? File(image.path) : null;
    });
  }
List<Map<String, dynamic>> textAndImageChat = [];

  void fromTextAndImage({required String query, required File image}) async {
    setState(() {
      _loading = true;
      textAndImageChat.add({
        "role": "User",
        "text": query,
        "image": image,
      });
    });
    final image1 = await image.readAsBytes(); 
    final response = await _model.generateContent([
    Content.multi([TextPart(query), DataPart('image/jpeg', image1)])
  ]);
    setState(() {
      textAndImageChat.add({
        "role": "Gemini",
        "text": response.text,
      });
    });
    
    // Here you can add your logic to process the message and get a response if needed
      _textController.clear();
      imageFile = null;
    setState(() {
      _loading = false;
    });

    scrollToTheEnd();
  }

  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: textAndImageChat.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                return ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    child: Text(textAndImageChat[index]["role"].substring(0, 1)),
                  ),
                  title: Text(textAndImageChat[index]["role"]),
                  subtitle: textAndImageChat[index]["text"] != null
                      ? Text(textAndImageChat[index]["text"])
                      : null,
                  trailing: textAndImageChat[index]["image"] != null
                      ? Image.file(
                          textAndImageChat[index]["image"],
                          width: 90,
                        )
                      : null,
                );
              },
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Write a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.transparent,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      imageFile = image != null ? File(image.path) : null;
                    });
                  },
                ),
                IconButton(
                  icon: _loading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: () {
                    if (imageFile == null && _textController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please enter a message or select an image"),
                      ));
                    }
                    fromTextAndImage(
                      query: _textController.text,
                      image: imageFile ?? File(""),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: imageFile != null
          ? Container(
              margin: const EdgeInsets.only(bottom: 80),
              height: 150,
              child: Image.file(imageFile ?? File("")),
            )
          : null,
    );
  }
}