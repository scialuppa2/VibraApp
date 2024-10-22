import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_app/models/chat.dart';
import 'package:vibra_app/models/message.dart';
import 'package:vibra_app/repositories/chat_repository.dart';
import 'package:vibra_app/repositories/message_repository.dart';
import 'package:vibra_app/repositories/user_repository.dart';
import 'package:vibra_app/services/socket_service.dart';
import '../../models/participant.dart';
import '../../models/user.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final UserRepository userRepository;
  final MessageRepository messageRepository;
  final SocketService socketService;

  ChatBloc({
    required this.chatRepository,
    required this.userRepository,
    required this.messageRepository,
    required this.socketService,
  }) : super(ChatLoading()) {
    on<CreateChatRequested>(_onCreateChatRequested);
    on<DeleteChatRequested>(_onDeleteChatRequested);
    on<UndoDeleteChatRequested>(_onUndoDeleteChatRequested);
    on<GetChatByIdRequested>(_onGetChatByIdRequested);
    on<FetchUserChats>(_onFetchUserChats);
    on<SelectParticipants>(_onSelectParticipants);
    on<SendMessageRequested>(_onSendMessageRequested);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<AddUserToChatRequested>(_onAddUserToChatRequested);
    on<LeaveGroupChatRequested>(_onLeaveGroupChatRequested);
    on<UndoLeaveGroupChatRequested>(_onUndoLeaveGroupChatRequested);
    on<SearchChats>(_onSearchChats);


    socketService.onNewMessage((message) {
      add(NewMessageReceived(message: Message.fromJson(message)));
    });
  }

  Future<void> _onFetchUserChats(FetchUserChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await chatRepository.getChatsByUserId(event.userId);
      emit(ChatsLoaded(chats: chats));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }

  Future<void> _onGetChatByIdRequested(GetChatByIdRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chat = await chatRepository.getChatById(event.id);
      emit(ChatLoaded(chat: chat));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }

  Future<void> _onCreateChatRequested(CreateChatRequested event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedInUserId = prefs.getString('userId');
      final loggedInUsername = prefs.getString('username');
      final loggedInPhone = prefs.getString('phone');
      final loggedInProfilePicture = prefs.getString('profilePicture');

      if (loggedInUserId == null || loggedInUsername == null || loggedInPhone == null || loggedInProfilePicture == null) {
        emit(ChatError(message: 'Logged in user data not found'));
        return;
      }

      final loggedInParticipant = Participant(
        userId: loggedInUserId,
        username: loggedInUsername,
        phone: loggedInPhone,
        profilePicture: loggedInProfilePicture,
        id: loggedInUserId,
      );

      final participants = {
        loggedInParticipant,
        ...event.chatData.participants,
      }.toList();

      final chatData = event.chatData.copyWith(participants: participants);

      final chat = await chatRepository.createChat(chatData);
      emit(ChatCreated(chat: chat));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }

  Future<void> _onDeleteChatRequested(DeleteChatRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.deleteChat(event.chatId);
      _updateChatsAfterDeletion(event.chatId, emit);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUndoDeleteChatRequested(UndoDeleteChatRequested event, Emitter<ChatState> emit) async {
    try {
      final restoredChat = await chatRepository.createChat(event.chat);
      _addChatToCurrentState(restoredChat, emit);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onSelectParticipants(SelectParticipants event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final selectedUsers = await userRepository.getUsersByIds(event.userIds);
      emit(UsersSelected(selectedUsers: selectedUsers));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }

  Future<void> _onSendMessageRequested(SendMessageRequested event, Emitter<ChatState> emit) async {
    try {
      await messageRepository.createMessage(
        event.message.content,
        event.chatId,
        event.senderId,
        event.senderUsername,
        filePath: event.message.fileUrl,
      );


    } catch (error) {
      print('Error sending message: $error');
      emit(ChatError(message: error.toString()));
    }
  }


  Future<void> _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final updatedChat = currentState.chat.copyWith(
        messages: List.from(currentState.chat.messages)..add(event.message),
      );
      emit(ChatLoaded(chat: updatedChat));
    }
  }

  Future<void> _onAddUserToChatRequested(AddUserToChatRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.addUserToChat(event.chatId, event.userId, event.username, event.phone, event.profilePicture);
      _refreshUserChats(event.userId, emit);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onLeaveGroupChatRequested(LeaveGroupChatRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.leaveGroupChat(event.chatId, event.userId, event.username, event.phone, event.profilePicture);
      _updateChatsAfterDeletion(event.chatId, emit);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  Future<void> _onUndoLeaveGroupChatRequested(UndoLeaveGroupChatRequested event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.addUserToChat(event.chat.id, event.userId, event.username, event.phone, event.profilePicture);
      _addChatToCurrentState(event.chat, emit);
    } catch (e) {
      emit(ChatError(message: e.toString()));
    }
  }

  void _updateChatsAfterDeletion(String chatId, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final updatedChats = currentState.chats.where((chat) => chat.id != chatId).toList();
      emit(ChatsLoaded(chats: updatedChats));
    }
  }

  void _addChatToCurrentState(Chat chat, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded) {
      final updatedChats = List<Chat>.from(currentState.chats)..add(chat);
      emit(ChatsLoaded(chats: updatedChats));
    } else {
      emit(ChatsLoaded(chats: [chat]));
    }
  }


  Future<void> _refreshUserChats(String userId, Emitter<ChatState> emit) async {
    try {
      final updatedChats = await chatRepository.getChatsByUserId(userId);
      emit(ChatsLoaded(chats: updatedChats));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }

  Future<void> _onSearchChats(SearchChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await chatRepository.searchChats(event.query, event.userId);
      emit(ChatSearchResult(chats: chats));
    } catch (error) {
      emit(ChatError(message: error.toString()));
    }
  }
}
