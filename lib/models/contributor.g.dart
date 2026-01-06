// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'contributor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributorInfo _$ContributorInfoFromJson(Map<String, dynamic> json) =>
    ContributorInfo(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      url: json['url'] as String?,
      comment: json['comment'] as String?,
    );
