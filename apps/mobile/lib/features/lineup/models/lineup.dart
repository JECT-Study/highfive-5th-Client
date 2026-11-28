import 'package:freezed_annotation/freezed_annotation.dart';

part 'lineup.freezed.dart';

enum SongType { original, searched }

@freezed
abstract class Lineup with _$Lineup {
  const factory Lineup({
    required List<LineupTeam> teams,
    required int emptySlotCount,
  }) = _Lineup;
}

@freezed
abstract class LineupTeam with _$LineupTeam {
  const factory LineupTeam({
    required int concertTeamId,
    required int lineupOrder,
    required bool isHost,
    required LineupBand band,
    required List<String> setlistPreview,
    required int setlistTotalCount,
  }) = _LineupTeam;
}

@freezed
abstract class LineupBand with _$LineupBand {
  const factory LineupBand({
    required int bandId,
    required String name,
    String? profileImageUrl,
    required List<String> genres,
    required int memberCount,
  }) = _LineupBand;
}

@freezed
abstract class BandSetlist with _$BandSetlist {
  const factory BandSetlist({
    required bool isHost,
    required bool canEdit,
    required LineupBand band,
    required List<LineupSong> songs,
  }) = _BandSetlist;
}

@freezed
abstract class LineupSong with _$LineupSong {
  const factory LineupSong({
    required SongType type,
    required String songTitle,
    String? trackId,
    String? artist,
    int? durationSeconds,
    String? albumImageUrl,
    String? externalUrl,
  }) = _LineupSong;
}
