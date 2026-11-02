import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khachsan_di_dong/features/audit/providers/audit_provider.dart';
import 'package:khachsan_di_dong/features/audit/screens/audit_screen.dart';
import 'package:khachsan_di_dong/features/auth/providers/auth_provider.dart';
import 'package:khachsan_di_dong/features/auth/screens/login_screen.dart';
import 'package:khachsan_di_dong/features/housekeeping/providers/housekeeping_provider.dart';
import 'package:khachsan_di_dong/features/housekeeping/screens/housekeeping_screen.dart';
import 'package:khachsan_di_dong/features/users/providers/users_provider.dart';
import 'package:khachsan_di_dong/features/users/screens/users_screen.dart';
import 'package:khachsan_di_dong/models/housekeeping_task.dart';
import 'package:khachsan_di_dong/models/user.dart';
import 'package:khachsan_di_dong/shared/widgets/loading_skeleton.dart';

import '../helpers/fakes.dart';

HousekeepingTask _task({bool overdue = true}) => HousekeepingTask(
      id: 'h1',
      room: const HousekeepingRoomRef(id: 'room-305', number: '305', floor: 3),
      assignee: const HousekeepingAssigneeRef(id: 'u1', fullName: 'Nguyễn Văn An'),
      status: HousekeepingStatus.assigned,
      isOverdue: overdue,
      dueAt: DateTime.now().subtract(const Duration(minutes: 20)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      version: 1,
    );

void main() {
  group('Đăng nhập', () {
    Future<FakeAuth> pumpLogin(WidgetTester tester) async {
      setScreen(tester, const Size(360, 760));
      final auth = FakeAuth(const AuthState(initialized: true));
      await pumpScreen(tester, const LoginScreen(), overrides: [
        ...fakeOverrides(),
        authProvider.overrideWith((ref) => auth),
      ]);
      return auth;
    }

    testWidgets('ô nhập có gợi ý tự điền cho số điện thoại và mật khẩu',
        (tester) async {
      await pumpLogin(tester);
      final fields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[0].autofillHints, [AutofillHints.telephoneNumber]);
      expect(fields[1].autofillHints, [AutofillHints.password]);
      expect(find.byType(AutofillGroup), findsOneWidget);
    });

    testWidgets('nhấn Enter ở ô mật khẩu thì đăng nhập', (tester) async {
      final auth = await pumpLogin(tester);
      await tester.enterText(find.byType(TextField).at(0), '0901234567');
      await tester.enterText(find.byType(TextField).at(1), 'matkhau123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(auth.logins, 1);
    });

    testWidgets('bàn phím mở ở màn 360px vẫn cuộn được, không tràn',
        (tester) async {
      setScreen(tester, const Size(360, 400)); // chiều cao còn lại khi có bàn phím
      await pumpScreen(tester, const LoginScreen(),
          overrides: [
            ...fakeOverrides(),
            authProvider.overrideWith(
                (ref) => FakeAuth(const AuthState(initialized: true))),
          ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bấm chip demo thì tự điền số điện thoại và mật khẩu mẫu',
        (tester) async {
      await pumpLogin(tester);
      expect(find.text('Quản lý'), findsOneWidget);
      expect(find.text('Lễ tân'), findsOneWidget);
      expect(find.text('Nhân viên'), findsOneWidget);

      await tester.tap(find.text('Lễ tân'));
      await tester.pump();

      final fields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields[0].controller?.text, '0900000002');
      expect(fields[1].controller?.text, 'Demo@12345');
    });
  });

  group('Dọn phòng (nhân viên)', () {
    testWidgets('thẻ việc đọc liền số phòng, quá hạn và hạn', (tester) async {
      final handle = tester.ensureSemantics();
      setScreen(tester, const Size(360, 800));
      await pumpScreen(tester, const HousekeepingScreen(),
          overrides: fakeOverrides(
              role: UserRole.staff,
              housekeeping: HousekeepingState(tasks: [_task()])));
      expect(
        find.bySemanticsLabel(
            RegExp(r'Phòng 305.*Quá hạn.*Tầng 3.*trễ \d+ phút', dotAll: true)),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('cỡ chữ 200% ở màn 360px không tràn, nút vẫn ≥ 48',
        (tester) async {
      setScreen(tester, const Size(360, 800), textScale: 2);
      await pumpScreen(tester, const HousekeepingScreen(),
          overrides: fakeOverrides(
              role: UserRole.staff,
              housekeeping: HousekeepingState(tasks: [_task()])));
      expect(tester.takeException(), isNull);
      final accept = find.widgetWithText(ElevatedButton, 'Nhận việc');
      expect(tester.getSize(accept).height, greaterThanOrEqualTo(48));
    });

    testWidgets('lần tải đầu hiện khung xương', (tester) async {
      setScreen(tester, const Size(360, 800));
      await pumpScreen(tester, const HousekeepingScreen(),
          overrides: fakeOverrides(
              role: UserRole.staff,
              housekeeping: const HousekeepingState(isLoading: true)));
      expect(find.byType(SkeletonList), findsOneWidget);
    });
  });

  testWidgets('Tài khoản: lần tải đầu hiện khung xương', (tester) async {
    setScreen(tester, const Size(400, 800));
    await pumpScreen(tester, const UsersScreen(),
        overrides: fakeOverrides(users: const UsersState(isLoading: true)));
    expect(find.byType(SkeletonList), findsOneWidget);
  });

  testWidgets('Nhật ký: lần tải đầu hiện khung xương', (tester) async {
    setScreen(tester, const Size(1280, 800));
    await pumpScreen(tester, const AuditScreen(),
        overrides: <Override>[
          ...fakeOverrides(audit: const AuditState(isLoading: true)),
        ]);
    expect(find.byType(SkeletonList), findsOneWidget);
  });
}
