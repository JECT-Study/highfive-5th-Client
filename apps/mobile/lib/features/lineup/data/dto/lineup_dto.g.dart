// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lineup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineupDto _$LineupDtoFromJson(Map<String, dynamic> json) => LineupDto(
  teams: (json['teams'] as List<dynamic>)
      .map((e) => LineupTeamDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  emptySlotCount: (json['emptySlotCount'] as num).toInt(),
);

LineupTeamDto _$LineupTeamDtoFromJson(Map<String, dynamic> json) =>
    LineupTeamDto(
      concertTeamId: (json['concertTeamId'] as num).toInt(),
      lineupOrder: (json['lineupOrder'] as num).toInt(),
      isHost: json['isHost'] as bool,
      band: LineupBandDto.fromJson(json['band'] as Map<String, dynamic>),
      setlistPreview: (json['setlistPreview'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      setlistTotalCount: (json['setlistTotalCount'] as num).toInt(),
    );

LineupBandDto _$LineupBandDtoFromJson(Map<String, dynamic> json) =>
    LineupBandDto(
      bandId: (json['bandId'] as num).toInt(),
      name: json['name'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      genres: (json['genres'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      memberCount: (json['memberCount'] as num).toInt(),
    );

BandSetlistDto _$BandSetlistDtoFromJson(Map<String, dynamic> json) =>
    BandSetlistDto(
      isHost: json['isHost'] as bool,
      canEdit: json['canEdit'] as bool,
      band: LineupBandDto.fromJson(json['band'] as Map<String, dynamic>),
      songs: (json['songs'] as List<dynamic>)
          .map((e) => LineupSongDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

LineupSongDto _$LineupSongDtoFromJson(Map<String, dynamic> json) =>
    LineupSongDto(
      type: json['type'] as String,
      songTitle: json['songTitle'] as String,
      trackId: json['trackId'] as String?,
      artist: json['artist'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      albumImageUrl: json['albumImageUrl'] as String?,
      externalUrl: json['externalUrl'] as String?,
    );

SongSearchDto _$SongSearchDtoFromJson(Map<String, dynamic> json) =>
    SongSearchDto(songs: SongSearchDto._searchedSongs(json['songs'] as List));
