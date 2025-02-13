import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'gemini_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PDFQuestionGenerator(),
    );
  }
}

class PDFQuestionGenerator extends StatefulWidget {
  const PDFQuestionGenerator({super.key});

  @override
  _PDFQuestionGeneratorState createState() => _PDFQuestionGeneratorState();
}

class _PDFQuestionGeneratorState extends State<PDFQuestionGenerator> {
  final GeminiService gemini = GeminiService();
  String extractedText = "Select a PDF to extract text.";
  List<Map<String, String>> questionsAndAnswers = [];

  Future<void> pickAndExtractText() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      print("Selected file path: $filePath"); // Debug log for file path
      File file = File(filePath);

      try {
        final PdfDocument pdfDoc =
            PdfDocument(inputBytes: file.readAsBytesSync());
        String text = "";
        for (int i = 0; i < pdfDoc.pages.count; i++) {
          PdfTextExtractor extractor = PdfTextExtractor(pdfDoc);
          text += "${extractor.extractText()}\n\n";
        }

        print("Extracted text: $text"); // Debug log for extracted text
        print(
            "Is extracted text empty: ${text.isEmpty}"); // Check if text is empty

        setState(() {
          extractedText = text.isNotEmpty ? text : "No text found in PDF.";
        });

        pdfDoc.dispose();

        generateQuestionsFromText(text);
      } catch (e) {
        setState(() {
          extractedText = "Error reading PDF: $e";
        });
      }
    } else {
      setState(() {
        extractedText = "No file selected.";
      });
    }
  }

  Future<void> generateQuestionsFromText(String text) async {
    String prompt =
        "Generate multiple-choice questions and answers from the following text. Format it as a valid Dart list of maps like this: [{ \"question\": \"...\", \"answer\": \"...\" }, ...]. Text: $text";

    String? response = await gemini.sendMessage(prompt);

    print("Raw Response: $response"); // Debugging response from Gemini

    if (response != null) {
      try {
        // Attempt to clean response if it includes markdown/code block formatting
        response = response.trim();
        if (response.startsWith("```json")) {
          response =
              response.replaceAll("```json", "").replaceAll("```", "").trim();
        }
        if (response.startsWith("```dart")) {
          response =
              response.replaceAll("```dart", "").replaceAll("```", "").trim();
        }

        print("Cleaned Response: $response"); // Check cleaned response

        // Attempt to parse as a Dart list of maps
        var decodedData = jsonDecode(response);

        if (decodedData is List) {
          setState(() {
            questionsAndAnswers = List<Map<String, String>>.from(
                decodedData.map((item) => Map<String, String>.from(item)));
          });

          print(
              "Parsed Questions: $questionsAndAnswers"); // Debugging parsed questions
        } else {
          throw Exception("Response is not a List format.");
        }
      } catch (e) {
        print("Parsing Error: $e"); // Debugging error
        setState(() {
          extractedText = "Failed to parse response: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF to Questions")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickAndExtractText,
              child: Text("Pick PDF"),
            ),
            SizedBox(height: 16),
            Text(
              "Extracted Questions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: questionsAndAnswers.isNotEmpty
                  ? ListView.builder(
                      itemCount: questionsAndAnswers.length,
                      itemBuilder: (context, index) {
                        final qa = questionsAndAnswers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Q: ${qa['question']}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text("A: ${qa['answer']}",
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Text("No questions generated."),
            ),
          ],
        ),
      ),
    );
  }
}
