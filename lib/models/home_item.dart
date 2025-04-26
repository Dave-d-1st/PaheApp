import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';
part 'home_item.g.dart';
@HiveType(typeId: 0)
class HomeItem {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String subtitle;
  @HiveField(2)
  final Map summary;
  @HiveField(3)
  final int? id;
  @HiveField(4)
  final String imageUrl;
  @HiveField(5)
  final String imagePath;
  @HiveField(6)
  final int homeId;
  @HiveField(7)
  final List episodes;
  @HiveField(8)
  final double height;
  @HiveField(9)
  final String session;
  final Uint8List image;
  HomeItem({
    required this.title,
    required this.homeId,
    required this.session,
    required this.subtitle,
    required this.summary,
    required this.id,
    required this.imageUrl,
    required this.imagePath,
    required this.episodes,
    required this.height,
    }):
    image = File(imagePath).readAsBytesSync();

}