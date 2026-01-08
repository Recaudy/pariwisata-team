import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _message = [];
  bool _isloading = false;

  final String apiKey = "sk-qz1-zMuj5405dY1rB2ao-w";
  final String modelName = "openai/gpt-3.5-turbo";

  void _clearChat() {
    setState(() {
      _message.clear();
      _isloading = false;
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      _message.add({"role": "user", "content": text});
      _isloading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse("https://litellm.koboi2026.biz.id/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": modelName,
          "messages": [
            {
              "role": "system",
              "content":
                  "Kamu adalah chatbot wisata Bangka Belitung. Jawabanmu hanya boleh tentang wisata Bangka Belitung seperti Pantai, bukit dan wisata religi. Jika pertanyaan di luar topik, jawab dengan sopan bahwa kamu hanya bisa memberikan informasi wisata Bangka Belitung.",
            },
            ..._message,
          ],
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final reply = data["choices"][0]["message"]["content"];
        setState(() => _message.add({"role": "assistant", "content": reply}));
      }
    } catch (e) {
      setState(
        () => _message.add({
          "role": "assistant",
          "content": "Maaf, silakan coba lagi nanti.",
        }),
      );
    }
    setState(() => _isloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Assistant AI Wisata Bangka Belitung",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.highlight),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 95,
                  width: 75,

                  child: Lottie.asset('assets/lottie/chatbot.json'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Anda bisa bertanya seputar destinasi wisata",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _message.length,
              itemBuilder: (context, index) {
                final msg = _message[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isUser ? 15 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 15),
                      ),
                      border: isUser
                          ? null
                          : Border.all(
                              color: AppColors.secondary.withOpacity(0.3),
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      msg["content"] ?? '',
                      style: GoogleFonts.inter(
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isloading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: LinearProgressIndicator(
                color: AppColors.accent,
                backgroundColor: Color(0xFFE0E0E0),
              ),
            ),

          Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Tanyakan pantai Babel...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
