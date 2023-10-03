// ignore: file_names

import 'dart:convert';

class Detail {
  String? title;
  String? uuid;
  String? revisionId;
  String? updated;
  String? type;
  String? id;
  String? downloadUrl;
  String? categoryPath;

  Detail(
      {this.title,
      this.uuid,
      this.revisionId,
      this.updated,
      this.type,
      this.id,
      this.downloadUrl,
      this.categoryPath});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
        title: json['title'],
        uuid: json['uuid'],
        revisionId: json['revisionId'],
        updated: json['updated'],
        type: json['type'],
        id: json['id'],
        downloadUrl: json['download_url'],
        categoryPath: json['category_path']);
  }
}
