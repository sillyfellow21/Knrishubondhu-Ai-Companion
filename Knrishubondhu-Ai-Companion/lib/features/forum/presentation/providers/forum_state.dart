import 'package:equatable/equatable.dart';
import '../../domain/entities/forum_comment.dart';
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
  final String? currentUserId;

  const ForumLoaded(this.posts, {this.currentUserId});

  @override
  List<Object?> get props => [posts, currentUserId];
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

// States for post detail with comments
abstract class PostDetailState extends Equatable {
  const PostDetailState();
  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {
  const PostDetailInitial();
}

class PostDetailLoading extends PostDetailState {
  const PostDetailLoading();
}

class PostDetailLoaded extends PostDetailState {
  final ForumPost post;
  final List<ForumComment> comments;
  final String? currentUserId;

  const PostDetailLoaded({
    required this.post,
    required this.comments,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [post, comments, currentUserId];
}

class PostDetailError extends PostDetailState {
  final String message;
  const PostDetailError(this.message);
  @override
  List<Object?> get props => [message];
}
