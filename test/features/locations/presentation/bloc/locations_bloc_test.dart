import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_pgb_app/features/locations/domain/entities/geofence_location.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/get_locations_usecase.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/save_location_usecase.dart';
import 'package:flutter_pgb_app/features/locations/domain/usecases/delete_location_usecase.dart';
import 'package:flutter_pgb_app/features/locations/presentation/bloc/locations_bloc.dart';
import 'package:flutter_pgb_app/features/locations/presentation/bloc/locations_event.dart';
import 'package:flutter_pgb_app/features/locations/presentation/bloc/locations_state.dart';

class MockGetLocationsUseCase extends Mock implements GetLocationsUseCase {}
class MockSaveLocationUseCase extends Mock implements SaveLocationUseCase {}
class MockDeleteLocationUseCase extends Mock implements DeleteLocationUseCase {}

void main() {
  late MockGetLocationsUseCase mockGetLocationsUseCase;
  late MockSaveLocationUseCase mockSaveLocationUseCase;
  late MockDeleteLocationUseCase mockDeleteLocationUseCase;
  late LocationsBloc locationsBloc;

  setUpAll(() {
    registerFallbackValue(const GeofenceLocation(id: '', name: '', latitude: 0.0, longitude: 0.0, radius: 0.0));
  });

  setUp(() {
    mockGetLocationsUseCase = MockGetLocationsUseCase();
    mockSaveLocationUseCase = MockSaveLocationUseCase();
    mockDeleteLocationUseCase = MockDeleteLocationUseCase();
    locationsBloc = LocationsBloc(
      getLocationsUseCase: mockGetLocationsUseCase,
      saveLocationUseCase: mockSaveLocationUseCase,
      deleteLocationUseCase: mockDeleteLocationUseCase,
    );
  });

  tearDown(() {
    locationsBloc.close();
  });

  const tLocation = GeofenceLocation(
    id: '1',
    name: 'Office',
    latitude: 23.8103,
    longitude: 90.4125,
    radius: 100.0,
  );

  test('initial state should be LocationsInitial', () {
    expect(locationsBloc.state, LocationsInitial());
  });

  group('LoadLocationsEvent', () {
    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsLoaded] when data is loaded successfully',
      build: () {
        when(() => mockGetLocationsUseCase()).thenAnswer((_) async => [tLocation]);
        return locationsBloc;
      },
      act: (bloc) => bloc.add(LoadLocationsEvent()),
      expect: () => [
        LocationsLoading(),
        const LocationsLoaded(locations: [tLocation]),
      ],
      verify: (_) {
        verify(() => mockGetLocationsUseCase()).called(1);
      },
    );

    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsError] when loading data fails',
      build: () {
        when(() => mockGetLocationsUseCase()).thenThrow(Exception('Server failure'));
        return locationsBloc;
      },
      act: (bloc) => bloc.add(LoadLocationsEvent()),
      expect: () => [
        LocationsLoading(),
        const LocationsError(message: 'Exception: Server failure'),
      ],
    );
  });

  group('AddLocationEvent', () {
    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsActionSuccess] when adding location is successful',
      build: () {
        when(() => mockSaveLocationUseCase(any())).thenAnswer((_) async => {});
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const AddLocationEvent(
        name: 'Office',
        latitude: 23.8103,
        longitude: 90.4125,
        radius: 100.0,
      )),
      expect: () => [
        LocationsLoading(),
        const LocationsActionSuccess(message: 'Location added successfully'),
      ],
      verify: (_) {
        verify(() => mockSaveLocationUseCase(any())).called(1);
      },
    );

    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsError] when adding location fails',
      build: () {
        when(() => mockSaveLocationUseCase(any())).thenThrow(Exception('Save failure'));
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const AddLocationEvent(
        name: 'Office',
        latitude: 23.8103,
        longitude: 90.4125,
        radius: 100.0,
      )),
      expect: () => [
        LocationsLoading(),
        const LocationsError(message: 'Exception: Save failure'),
      ],
    );
  });

  group('UpdateLocationEvent', () {
    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsActionSuccess] when updating location is successful',
      build: () {
        when(() => mockSaveLocationUseCase(tLocation)).thenAnswer((_) async => {});
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const UpdateLocationEvent(location: tLocation)),
      expect: () => [
        LocationsLoading(),
        const LocationsActionSuccess(message: 'Location updated successfully'),
      ],
      verify: (_) {
        verify(() => mockSaveLocationUseCase(tLocation)).called(1);
      },
    );

    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsError] when updating location fails',
      build: () {
        when(() => mockSaveLocationUseCase(tLocation)).thenThrow(Exception('Update failure'));
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const UpdateLocationEvent(location: tLocation)),
      expect: () => [
        LocationsLoading(),
        const LocationsError(message: 'Exception: Update failure'),
      ],
    );
  });

  group('DeleteLocationEvent', () {
    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsActionSuccess] when deleting location is successful',
      build: () {
        when(() => mockDeleteLocationUseCase('1')).thenAnswer((_) async => {});
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const DeleteLocationEvent(id: '1')),
      expect: () => [
        LocationsLoading(),
        const LocationsActionSuccess(message: 'Location deleted successfully'),
      ],
      verify: (_) {
        verify(() => mockDeleteLocationUseCase('1')).called(1);
      },
    );

    blocTest<LocationsBloc, LocationsState>(
      'should emit [LocationsLoading, LocationsError] when deleting location fails',
      build: () {
        when(() => mockDeleteLocationUseCase('1')).thenThrow(Exception('Delete failure'));
        return locationsBloc;
      },
      act: (bloc) => bloc.add(const DeleteLocationEvent(id: '1')),
      expect: () => [
        LocationsLoading(),
        const LocationsError(message: 'Exception: Delete failure'),
      ],
    );
  });
}
