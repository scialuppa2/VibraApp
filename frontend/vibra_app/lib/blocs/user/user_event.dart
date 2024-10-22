import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {}

class GetUsers extends UserEvent {}

class GetUserById extends UserEvent {
  final String id;

  const GetUserById(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateUser extends UserEvent {
  final String id;
  final User user;

  const UpdateUser(this.id, this.user);

  @override
  List<Object> get props => [id, user];
}

class DeleteUser extends UserEvent {
  final String id;

  const DeleteUser(this.id);

  @override
  List<Object> get props => [id];
}

class UserSelected extends UserEvent {
  final List<String> userIds;

  const UserSelected(this.userIds);

  @override
  List<Object> get props => [userIds];
}

class UploadProfilePicture extends UserEvent {
  final String id;
  final String filePath;

  const UploadProfilePicture(this.id, this.filePath);

  @override
  List<Object> get props => [id, filePath];
}
