// ignore: unused_import
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constant.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SecondRoute(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//firstpage
class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,

          // ignore: prefer_const_literals_to_create_immutables
          children: [
            SizedBox(
              height: 500,
              width: 500,
              child: Lottie.asset("assets/chatbot.json"),
            ),
            SizedBox(height: 20, width: 20),
            Text(
              " Hey Hi I'm Smart AI-Chatbot   Developed By MSD Group Members of Future-X Technology \n\n1)Mahesh Deokar  2)Kunal Dhorde\n \t\t\t3) Saurabh Kasar \t\t4) Omkar Kankrale 5)Pratik Ahire",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RobotoMono'),
            ),
            Expanded(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 61, 233, 107),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatPage()));
                },
                child: const Text("Let's Start"),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

const backgroundColor = Color(0xff343541);
const botBackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late bool isLoading;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponce(String prompt) async {
    // ignore: prefer_const_declarations
    final apiKey = apiSectretKey;
    var url = Uri.https("api.openai.com", "/v1/completions");
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': prompt,
          'temperature': 0,
          'max_tokens': 2000,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));
    //decode responce
    Map<String, dynamic> newresponce = jsonDecode(response.body);
    return newresponce['choices'][0]['text'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "   Future-X Technology",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          backgroundColor: botBackgroundColor,
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  //input feild
                  _buildInput(),
                  // //submit button
                  _buildSubmit(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
        child: TextField(
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: Colors.white),
      controller: _textController,
      decoration: InputDecoration(
        fillColor: botBackgroundColor,
        filled: true,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
    ));
  }

  Widget _buildSubmit() {
    return Visibility(
        visible: !isLoading,
        child: Container(
          color: botBackgroundColor,
          child: IconButton(
            icon: Icon(
              Icons.send,
              color: Color.fromRGBO(142, 142, 160, 1),
            ),
            onPressed: () {
              setState(() {
                _messages.add(ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user));
                isLoading = true;
              });
              var input = _textController.text;
              _textController.clear();
              Future.delayed(Duration(milliseconds: 50))
                  .then((value) => _scrollDown());
              //display user input
              //call chatbot api
              generateResponce(input).then((value) {
                setState(() {
                  isLoading = false;
                  //display chatbot responce
                  _messages.add(ChatMessage(
                      text: value, chatMessageType: ChatMessageType.bot));
                });
              });
              _textController.clear();
              Future.delayed(Duration(milliseconds: 50))
                  .then((value) => _scrollDown());
            },
          ),
        ));
  }

  void _scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  ListView _buildList() {
    return ListView.builder(
        itemCount: _messages.length,
        controller: _scrollController,
        itemBuilder: ((context, index) {
          var message = _messages[index];
          return ChatMessageWidget(
            text: message.text,
            chatMessageType: message.chatMessageType,
          );
        }));
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? botBackgroundColor
          : backgroundColor,
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: Color.fromRGBO(248, 254, 252, 1),
                    child: Image.asset(
                      'assets/bot.png',
                      //color: Color.fromARGB(255, 189, 99, 99),
                      scale: 0.1,
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                      child: Image.asset(
                    'assets/man.png',
                    scale: 0.1,
                  )),
                ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Text(
                  text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
