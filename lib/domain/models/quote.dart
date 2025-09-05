import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String text;
  final String? author;

  const Quote({required this.text, this.author});
  
  @override
  List<Object?> get props => [text, author];
}