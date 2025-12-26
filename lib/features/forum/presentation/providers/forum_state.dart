import 'package:equatable/equatable.dart';
import '../../domain/entities/forum_post.dart';

abstract class ForumState extends Equatable {
  const ForumState();
  @override
  List<Object?> get props => [];
}

class ForumInitial extends ForumState {
  const ForumInitial();
}

class ForumLoading extends ForumState {
  const ForumLoading();
}

class ForumLoaded extends ForumState {
  final List<ForumPost> posts;
  const ForumLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class ForumEmpty extends ForumState {
  const ForumEmpty();
}

class ForumError extends ForumState {
  final String message;
  const ForumError(this.message);
  @override
  List<Object?> get props => [message];
}
