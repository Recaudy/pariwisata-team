import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

// 1. Definisi Warna Utama
const Color primaryColor = Color(0xFF21899C);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _message = [];
  bool _isloading = false;

  // --- BAGIAN YANG DIPERBARUI (API KEY) ---
  final String apiKey = "sk-qz1-zMuj5405dY1rB2ao-w";
  
  // Pastikan nama model ini didukung oleh server LiteLLM Anda. 
  // Jika server menggunakan default, Anda mungkin tidak perlu mengubah ini, 
  // atau bisa diganti sesuai model yang tersedia di server tersebut.
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
        // --- BAGIAN YANG DIPERBARUI (URL) ---
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
                  "Kamu adalah chatbot wisata Bangka Belitung. Jawabanmu hanya boleh tentang wisata Bangka Belitung. Jika pertanyaan di luar topik, jawab dengan sopan bahwa kamu hanya bisa memberikan informasi wisata Bangka Belitung.",
            },
            ..._message,
          ],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        final apiErrorMessage =
            data['error']?['message'] ?? 'Unknown API Error';
        throw Exception('API Error (${response.statusCode}): $apiErrorMessage');
      }

      if (data["choices"] == null ||
          data["choices"] is! List ||
          data["choices"].isEmpty) {
        throw Exception('Invalid API Response: "choices" not found or empty.');
      }

      final reply = data["choices"][0]["message"]["content"];

      setState(() {
        _message.add({"role": "assistant", "content": reply});
      });
    } catch (e) {
      setState(() {
        _message.add({
          "role": "assistant",
          "content": "Terjadi Error: ${e.toString()}",
        });
      });
    }

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mengubah warna AppBar
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AI Chatbot",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Online",
              style: TextStyle(
                fontSize: 12,
                color: Colors.greenAccent.shade400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Lottie.asset(
                  'assets/lottie/chatbot.json',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  repeat: true,
                ),
                const SizedBox(width: 10),
                const Text(
                  "AI is Ready to Assist You",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: primaryColor, // Mengubah warna teks
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _message.length,
              itemBuilder: (context, index) {
                final msg = _message[index];
                final isUser = msg["role"] == "user";

                return _buildMessage(msg["content"] ?? '', isUser);
              },
            ),
          ),
          if (_isloading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(
                color: primaryColor, // Mengubah warna loading
                backgroundColor: Colors.black12,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Berikan pertanyaan anda?",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: primaryColor, // Mengubah warna tombol kirim
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String content, bool isUser) {
    final textColor = isUser ? Colors.white : Colors.black87;
    final bubbleColor = isUser
        ? primaryColor
        : Colors.grey.shade200; // Mengubah warna bubble user

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
        ),
        color: bubbleColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: primaryColor, // Menggunakan Primary Color
                    radius: 12,
                    child: const Icon(
                      Icons.psychology_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              Flexible(
                child: Text(
                  content,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
