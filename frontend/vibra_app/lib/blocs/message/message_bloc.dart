import 'package:bloc/bloc.dart';
import 'package:vibra_app/repositories/message_repository.dart';
import 'message_event.dart';
import 'message_state.dart';


class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository messageRepository;

  MessageBloc({required this.messageRepository}) : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<CreateMessage>(_onCreateMessage);
    on<SearchMessages>(_onSearchMessages);
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final messages = await messageRepository.getMessagesByChatId(event.chatId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }

  Future<void> _onCreateMessage(CreateMessage event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final message = await messageRepository.createMessage(
        event.content,
        event.chatId,
        event.senderId,
        event.senderUsername,
        filePath: event.filePath,
      );
      final messages = await messageRepository.getMessagesByChatId(event.chatId);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }

  Future<void> _onSearchMessages(SearchMessages event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final messages = await messageRepository.searchMessages(event.chatId, event.query);
      emit(MessagesLoaded(messages: messages));
    } catch (e) {
      emit(MessageError(message: e.toString()));
    }
  }
}
