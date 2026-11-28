import 'dart:convert';
import 'dart:io';

import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/performances/data/dto/concert_detail_dto.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';

/// UI·실서버 없이 DTO → 모델 → 저장소 공개 계약을 실행한다.
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    throw ArgumentError('Pass the concert GET response JSON path.');
  }
  final response = jsonDecode(
    await File(args.single).readAsString(),
  ) as Map<String, dynamic>;
  final model = ConcertDetailDto.fromJson(
    response['data'] as Map<String, dynamic>,
  ).toModel();
  if (model.concertId != 12 || model.version != 3) {
    throw StateError('Draft concert ID/version was not preserved.');
  }
  stdout.writeln(
    'DTO PASS concertId=${model.concertId} version=${model.version} '
    'status=${model.status.name} recruitment=${model.recruitment?.recruitPostId}',
  );

  final ConcertRepository repository = FakeConcertRepository();
  final fake = await repository.fetchDetail(12);
  if (fake.myPermissions.isHostLeader || fake.myPermissions.isTeamLeader) {
    throw StateError('Default fake granted leader permissions.');
  }
  stdout.writeln(
    'FAKE PASS concertId=${fake.concertId} permissions=false/false',
  );
  await _expectFailure(repository, 99, 404, 'CONCERT_001');
  await _expectFailure(
    FakeConcertRepository(forbiddenConcertIds: {12}),
    12,
    403,
    'AUTH_005',
  );
  stdout.writeln('CONTRACT PASS (draft/fake; live GET not deployed)');
}

Future<void> _expectFailure(
  ConcertRepository repository,
  int id,
  int status,
  String code,
) async {
  try {
    await repository.fetchDetail(id);
  } on ApiException catch (error) {
    if (error.statusCode == status && error.code == code) {
      stdout.writeln('ERROR PASS $status $code');
      return;
    }
    rethrow;
  }
  throw StateError('Expected $status $code for concert $id.');
}
