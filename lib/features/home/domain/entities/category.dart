import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? iconUrl;
  final int displayOrder;

  const Category({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.displayOrder,
  });

  @override
  List<Object?> get props => [id, name, iconUrl, displayOrder];
}
