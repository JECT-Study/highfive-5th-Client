enum ConcertManagementFailure implements Exception {
  concertNotFound,
  forbidden,
  bandNotParticipating,
  hostBand,
  sellingStarted,
  unknownStatus,
  network,
  unknown,
}
