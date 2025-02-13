import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = 'AIzaSyA1TmyLwnan8pPh5aaQI0ucTqYzZARn91c';

  late GenerativeModel model;
  late ChatSession chat;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 1024,
        responseMimeType: 'text/plain',
      ),
    );
    chat = model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    final content = Content.text(message);
    final response = await chat.sendMessage(content);
    return response.text;
  }
}
// import 'package:flutter/material.dart';

// import 'gemini_service.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ChatScreen(),
//     );
//   }
// }

// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final GeminiService gemini = GeminiService();
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> messages = [];

//   void sendMessage() async {
//     String userMessage = _controller.text.trim();
//     if (userMessage.isEmpty) return;

//     setState(() {
//       messages.add({'sender': 'You', 'text': userMessage});
//     });

//     _controller.clear();

//     String? response = await gemini.sendMessage(userMessage);

//     setState(() {
//       messages.add({'sender': 'Gemini', 'text': response ?? 'No response'});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Gemini AI Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 return Align(
//                   alignment: message['sender'] == 'You'
//                       ? Alignment.centerRight
//                       : Alignment.centerLeft,
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: message['sender'] == 'You'
//                           ? Colors.blue[200]
//                           : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       "${message['sender']}: ${message['text']}",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
