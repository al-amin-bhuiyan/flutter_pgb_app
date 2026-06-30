import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pgb_app/main.dart';
import 'package:flutter_pgb_app/core/di/injection_container.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_pgb_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    mockAuthBloc = MockAuthBloc();
    // Register mock AuthBloc to service locator
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    
    await tester.pumpWidget(const MyApp());
    expect(find.byIcon(Icons.radar), findsOneWidget);
  });
}
