import 'package:json_annotation/json_annotation.dart';

import '../../models/lineup.dart';

part 'lineup_dto.g.dart';

@JsonSerializable(createToJson: false)
class LineupDto {
  const LineupDto({required this.teams, required this.emptySlotCount});

  factory LineupDto.fromJson(Map<String, dynamic> json) =>
      _$LineupDtoFromJson(json);

  final List<LineupTeamDto> teams;
  final int emptySlotCount;

  Lineup toModel() => Lineup(
    teams: teams.map((team) => team.toModel()).toList(),
    emptySlotCount: emptySlotCount,
  );
}

@JsonSerializable(createToJson: false)
class LineupTeamDto {
  const LineupTeamDto({
    required this.concertTeamId,
    required this.lineupOrder,
    required this.isHost,
    required this.band,
    required this.setlistPreview,
    required this.setlistTotalCount,
  });

  factory LineupTeamDto.fromJson(Map<String, dynamic> json) =>
      _$LineupTeamDtoFromJson(json);

  final int concertTeamId;
  final int lineupOrder;
  final bool isHost;
  final LineupBandDto band;
  final List<String> setlistPreview;
  final int setlistTotalCount;

  LineupTeam toModel() => LineupTeam(
    concertTeamId: concertTeamId,
    lineupOrder: lineupOrder,
    isHost: isHost,
    band: band.toModel(),
    setlistPreview: setlistPreview,
    setlistTotalCount: setlistTotalCount,
  );
}

@JsonSerializable(createToJson: false)
class LineupBandDto {
  const LineupBandDto({
    required this.bandId,
    required this.name,
    this.profileImageUrl,
    required this.genres,
    required this.memberCount,
  });

  factory LineupBandDto.fromJson(Map<String, dynamic> json) =>
      _$LineupBandDtoFromJson(json);

  final int bandId;
  final String name;
  final String? profileImageUrl;
  final List<String> genres;
  final int memberCount;

  LineupBand toModel() => LineupBand(
    bandId: bandId,
    name: name,
    profileImageUrl: profileImageUrl,
    genres: genres,
    memberCount: memberCount,
  );
}

@JsonSerializable(createToJson: false)
class BandSetlistDto {
  const BandSetlistDto({
    required this.isHost,
    required this.canEdit,
    required this.band,
    required this.songs,
  });

  factory BandSetlistDto.fromJson(Map<String, dynamic> json) =>
      _$BandSetlistDtoFromJson(json);

  final bool isHost;
  final bool canEdit;
  final LineupBandDto band;
  final List<LineupSongDto> songs;

  BandSetlist toModel() => BandSetlist(
    isHost: isHost,
    canEdit: canEdit,
    band: band.toModel(),
    songs: songs.map((song) => song.toModel()).toList(),
  );
}

@JsonSerializable(createToJson: false)
class LineupSongDto {
  const LineupSongDto({
    required this.type,
    required this.songTitle,
    this.trackId,
    this.artist,
    this.durationSeconds,
    this.albumImageUrl,
    this.externalUrl,
  });

  factory LineupSongDto.fromJson(Map<String, dynamic> json) =>
      _$LineupSongDtoFromJson(json);

  final String type;
  final String songTitle;
  final String? trackId;
  final String? artist;
  final int? durationSeconds;
  final String? albumImageUrl;
  final String? externalUrl;

  LineupSong toModel() => LineupSong(
    type: switch (type) {
      'ORIGINAL' => SongType.original,
      'SEARCHED' => SongType.searched,
      _ => throw FormatException('Unknown song type: $type'),
    },
    songTitle: songTitle,
    trackId: trackId,
    artist: artist,
    durationSeconds: durationSeconds,
    albumImageUrl: albumImageUrl,
    externalUrl: externalUrl,
  );
}

@JsonSerializable(createToJson: false)
class SongSearchDto {
  const SongSearchDto({required this.songs});

  factory SongSearchDto.fromJson(Map<String, dynamic> json) =>
      _$SongSearchDtoFromJson(json);

  @JsonKey(fromJson: _searchedSongs)
  final List<LineupSongDto> songs;

  static List<LineupSongDto> _searchedSongs(List<dynamic> songs) => [
    for (final song in songs)
      LineupSongDto.fromJson({
        ...song as Map<String, dynamic>,
        'type': 'SEARCHED',
      }),
  ];
}
