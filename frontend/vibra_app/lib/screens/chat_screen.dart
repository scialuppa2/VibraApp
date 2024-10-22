import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_app/screens/select_users_screen.dart';
import '../blocs/chat/chat_bloc.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/service_locator.dart';
import '../services/socket_service.dart';
import '../widgets/chat_content.dart';
import '../widgets/chatscreen_app_bar.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final SocketService _socketService;
  String? _selectedFilePath;
  Uint8List? _selectedFileBytes;
  String? _currentUserId;

  String searchQuery = '';
  bool _isSearchVisible = false;

  void _onSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        searchQuery = '';
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _socketService = getIt<SocketService>();
    _socketService.onNewMessage((messageData) {
      final message = Message.fromJson(messageData);
      context.read<ChatBloc>().add(NewMessageReceived(message: message));
    });

    _getUserIdFromPrefs().then((userId) {
      if (userId != null) {
        setState(() {
          _currentUserId = userId;
        });
        joinChatRoom(widget.chat.id);
        context.read<ChatBloc>().add(GetChatByIdRequested(id: widget.chat.id));
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socketService.dispose();
    super.dispose();
  }

  void joinChatRoom(String chatId) {
    _socketService.socket.emit('joinRoom', chatId);
  }

  Future<void> _onAddUserToChat() async {
    final User? selectedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (context) => SelectUserScreen()),
    );

    if (selectedUser != null) {
      context.read<ChatBloc>().add(AddUserToChatRequested(
        chatId: widget.chat.id,
        userId: selectedUser.id,
        username: selectedUser.username,
        phone: selectedUser.phone,
        profilePicture: selectedUser.profilePicture,
      ));
    }
  }

  Future<String?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path;
      if (filePath != null) {
        final file = File(filePath);
        try {
          final fileBytes = await file.readAsBytes();
          print('File selected: $filePath');
          setState(() {
            _selectedFilePath = filePath;
            _selectedFileBytes = fileBytes;
          });
        } catch (e) {
          print('Error reading file bytes: $e');
        }
      } else {
        print('File path is null');
      }
    } else {
      print('No file selected');
    }
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (context) =>
      getIt<ChatBloc>()..add(GetChatByIdRequested(id: widget.chat.id)),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: ChatscreenAppBar(
            chat: widget.chat,
            currentUserId: _currentUserId!,
            onAddUserToChat: _onAddUserToChat,
            onSearchToggle: _toggleSearchVisibility,
          ),
        ),
        backgroundColor: Colors.grey[850],
        body: Column(
          children: [
            if (_isSearchVisible)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white,
                  child: TextField(
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Cerca...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

      Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) =>
                        _scrollToBottom());
                    return ChatContent(
                      chat: state.chat,
                      currentUserId: _currentUserId!,
                      scrollController: _scrollController,
                      searchQuery: searchQuery,
                    );
                  } else if (state is ChatError) {
                    return Center(
                        child: Text('Error loading chat: ${state.message}'));
                  } else {
                    return const Center(child: Text('No chat selected'));
                  }
                },
              ),
            ),
            MessageInput(
              chatId: widget.chat.id,
              currentUserId: _currentUserId!,
              messageController: _messageController,
              selectedFilePath: _selectedFilePath,
              selectedFileBytes: _selectedFileBytes,
              onSelectFile: _selectFile,
              onSendMessage: _onSendMessage,
              onRemoveFile: _removeSelectedFile,
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onSendMessage(String content, String? fileUrl) async {
    if (content.isEmpty && fileUrl == null) {
      print('No message content or file selected');
      return;
    }

    final userId = _currentUserId;
    final username = await SharedPreferences.getInstance().then((prefs) =>
        prefs.getString('username'));

    if (userId == null || username == null) {
      print('User ID or username not found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID or username not found')),
      );
      return;
    }

    final message = SendMessage(
      chatId: widget.chat.id,
      senderId: userId,
      senderUsername: username,
      content: content,
      fileUrl: fileUrl,
    );

    try {
      print('Sending message: $message');

      context.read<ChatBloc>().add(SendMessageRequested(
        chatId: widget.chat.id,
        message: message,
        senderId: userId,
        senderUsername: username,
      ));

      _messageController.clear();
      setState(() {
        _selectedFilePath = null;
        _selectedFileBytes = null;
      });
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message')),
      );
    }
  }
}
