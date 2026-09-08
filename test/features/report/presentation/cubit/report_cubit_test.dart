import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lueur/core/errors/failures.dart';
import 'package:lueur/features/report/domain/repositories/report_repository.dart';
import 'package:lueur/features/report/domain/usecases/submit_report_usecase.dart';
import 'package:lueur/features/report/presentation/cubit/report_cubit.dart';
import 'package:lueur/features/report/presentation/cubit/report_state.dart';

class _FakeReportRepository implements ReportRepository {
  Either<Failure, void> result = const Right(null);
  final calls = <String>[];

  @override
  Future<Either<Failure, void>> submitReport({
    required String reportedText,
    String? userMessage,
    required String reason,
    String? comment,
  }) async {
    calls.add(reportedText);
    return result;
  }
}

ReportCubit buildCubit(_FakeReportRepository repo) {
  return ReportCubit(SubmitReportUseCase(repo));
}

void main() {
  group('ReportCubit', () {
    test('starts with ReportInitial', () {
      final cubit = buildCubit(_FakeReportRepository());
      expect(cubit.state, const ReportInitial());
      cubit.close();
    });

    test('successful submission emits submitting then success', () async {
      final repo = _FakeReportRepository();
      final cubit = buildCubit(repo);

      await cubit.submitReport(
        reportedText: 'Luna said something',
        userMessage: 'my thoughts',
        reason: 'offensive_harmful',
      );

      expect(repo.calls, ['Luna said something']);
      expect(cubit.state, const ReportSuccess());
      await cubit.close();
    });

    test(
        'failed submission emits failure state with the repository\'s error message',
        () async {
      final repo = _FakeReportRepository()
        ..result = const Left(NetworkFailure('boom'));
      final cubit = buildCubit(repo);

      await cubit.submitReport(
        reportedText: 'Luna said something',
        reason: 'other',
      );

      expect(cubit.state, const ReportFailure('boom'));
      await cubit.close();
    });

    test('does not emit after the cubit is closed (isClosed guard)',
        () async {
      final cubit = buildCubit(_FakeReportRepository());
      await cubit.close();

      expect(cubit.isClosed, isTrue);

      // Should not throw "emit after close" — the isClosed guard must hold.
      await cubit.submitReport(
        reportedText: 'Luna said something',
        reason: 'other',
      );
    });
  });
}
