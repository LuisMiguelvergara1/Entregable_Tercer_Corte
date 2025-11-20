import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:mi_app/models/user_storage.dart';
import 'package:mi_app/models/user_model.dart';
import '../models/chat_message.dart';

final List<ChatMessage> _simulatedMessages = [
  ChatMessage(
    sender: 'SISTEMA',
    text: 'Bienvenido al chat de rutas. Mantén el respeto.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
];

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  String _currentUser = 'Cargando...';
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  void _loadUserInfo() async {
    final UserModel? session = await UserStorage.getActiveSession();
    if (mounted) {
      setState(() {
        if (session != null) {
          final String roleName = session.role.name.toUpperCase();
          final String name = session.email.split('@')[0];
          _currentUser = '$roleName ($name)';
        } else {
          _currentUser = 'Anonimo';
        }
      });
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _simulatedMessages.add(ChatMessage(
        sender: _currentUser,
        text: _textController.text.trim(),
        timestamp: DateTime.now(),
      ));
    });
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
  }

  // --- MÉTODOS DE EMOJI (Compatible con v4.3.0) ---
  void _onEmojiSelected(Category? category, Emoji emoji) {
    _textController.text = _textController.text + emoji.emoji;
  }

  void _onBackspacePressed() {
    _textController
      ..text = _textController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showEmojiPicker,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() => _showEmojiPicker = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFE7DE), // Fondo Beige WhatsApp
        appBar: AppBar(
          leadingWidth: 70,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, size: 24),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.groups, color: Color(0xFF075E54), size: 28),
                ),
              ],
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rutas Uniguajira', style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold)),
              Text('toca para info del grupo', style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
          backgroundColor: const Color(0xFF075E54),
          actions: [
            IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
            IconButton(icon: const Icon(Icons.call), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            // 1. LISTA DE MENSAJES
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _simulatedMessages.length,
                itemBuilder: (context, index) {
                  final msg = _simulatedMessages[index];
                  final isMe = msg.sender == _currentUser;
                  final isSystem = msg.sender == 'SISTEMA';

                  if (isSystem) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFCD8),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 1)],
                        ),
                        child: Text(msg.text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                    );
                  }

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2, offset: const Offset(0, 1))
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15, right: 10, top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    msg.sender,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.primaries[msg.sender.length % Colors.primaries.length],
                                    ),
                                  ),
                                Text(msg.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              children: [
                                Text(_formatTime(msg.timestamp), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                if (isMe) ...[
                                  const SizedBox(width: 3),
                                  const Icon(Icons.done_all, size: 16, color: Color(0xFF53BDEB)),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. BARRA DE INPUT
            Container(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(_showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined, color: Colors.grey[600]),
                            onPressed: () {
                              setState(() => _showEmojiPicker = !_showEmojiPicker);
                              if (_showEmojiPicker) _focusNode.unfocus();
                              else _focusNode.requestFocus();
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Mensaje',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          IconButton(icon: Icon(Icons.camera_alt, color: Colors.grey[600]), onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF00A884),
                      child: Icon(Icons.send, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // 3. SELECTOR DE EMOJIS (Configuración corregida para v4.3.0)
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: _onEmojiSelected,
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    
                    // Aquí es donde estaba el error. En v4.3.0 se usa 'emojiViewConfig'
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 28 * (kIsWeb ? 1.0 : (Platform.isIOS ? 1.30 : 1.0)),
                      backgroundColor: const Color(0xFFF2F2F2),
                      recentsLimit: 28,
                      noRecents: const Text('No Recents', style: TextStyle(fontSize: 20, color: Colors.black26), textAlign: TextAlign.center),
                      buttonMode: ButtonMode.MATERIAL,
                    ),

                    // Y aquí 'categoryViewConfig'
                    categoryViewConfig: const CategoryViewConfig(
                      initCategory: Category.RECENT,
                      backgroundColor: Color(0xFFF2F2F2),
                      indicatorColor: Color(0xFF00A884),
                      iconColor: Colors.grey,
                      iconColorSelected: Color(0xFF00A884),
                      backspaceColor: Color(0xFF00A884),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: CategoryIcons(),
                    ),

                    bottomActionBarConfig: const BottomActionBarConfig(
                      backgroundColor: Color(0xFFF2F2F2),
                      buttonColor: Color(0xFFF2F2F2),
                      buttonIconColor: Colors.grey,
                    ),

                    searchViewConfig: const SearchViewConfig(
                      backgroundColor: Color(0xFFF2F2F2),
                      buttonIconColor: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}