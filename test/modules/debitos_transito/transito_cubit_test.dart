import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/modules/debitos_transito/models/debito_model.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_cubit.dart';
import 'package:palma_da_mao/modules/debitos_transito/presentational/controllers/transito_state.dart';
import 'package:palma_da_mao/modules/debitos_transito/repositories/transito_repository.dart';

class FakeTransitoRepository extends Fake implements TransitoRepository {
  List<DebitoModel> mockDebitos = [];
  bool consultarDebitosCalled = false;

  @override
  Future<List<DebitoModel>> consultarDebitos(String cpf) async {
    consultarDebitosCalled = true;
    return mockDebitos;
  }
}

void main() {
  group('TransitoCubit CPF Validation', () {
    late FakeTransitoRepository fakeRepository;
    late TransitoCubit cubit;

    setUp(() {
      fakeRepository = FakeTransitoRepository();
      cubit = TransitoCubit(fakeRepository);
    });

    test('deve emitir TransitoError quando o CPF for inválido', () async {
      await cubit.buscarDebitos('00000000000');

      expect(cubit.state, isA<TransitoError>());
      final error = cubit.state as TransitoError;
      expect(error.message, 'Informe um CPF válido.');
      expect(fakeRepository.consultarDebitosCalled, isFalse);
    });

    test('deve chamar o repository quando o CPF for válido', () async {
      // CPF válido de teste: 52998224725
      await cubit.buscarDebitos('52998224725');

      expect(fakeRepository.consultarDebitosCalled, isTrue);
      expect(cubit.state, isA<TransitoSuccess>());
    });
  });
}
