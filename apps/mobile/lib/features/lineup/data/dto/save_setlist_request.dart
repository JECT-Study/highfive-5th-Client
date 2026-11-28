import '../../models/lineup.dart';

/// 저장 API에는 재생 링크와 자작곡의 검색 전용 필드를 보내지 않는다.
Map<String, Object?> setlistRequest(List<LineupSong> songs) => {
  'songs': [
    for (final song in songs)
      {
        'type': switch (song.type) {
          SongType.original => 'ORIGINAL',
          SongType.searched => 'SEARCHED',
        },
        'songTitle': song.songTitle,
        if (song.durationSeconds != null)
          'durationSeconds': song.durationSeconds,
        if (song.type == SongType.searched) ...{
          'trackId': song.trackId,
          'artist': song.artist,
          if (song.albumImageUrl != null) 'albumImageUrl': song.albumImageUrl,
        },
      },
  ],
};
