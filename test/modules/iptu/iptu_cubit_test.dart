import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/modules/iptu/models/debito_model.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_cubit.dart';
import 'package:palma_da_mao/modules/iptu/presentational/controllers/iptu_state.dart';
import 'package:palma_da_mao/modules/iptu/repositories/iptu_repository.dart';

class FakeIptuRepository extends Fake implements IptuRepository {
  List<DebitoModel> mockDebitos = [];
  bool consultarDebitosCalled = false;

  @override
  Future<List<DebitoModel>> consultarDebitos(String cpf) async {
    consultarDebitosCalled = true;
    return mockDebitos;
  }
}

void main() {
  group('IptuCubit CPF Validation', () {
    late FakeIptuRepository fakeRepository;
    late IptuCubit cubit;

    setUp(() {
      fakeRepository = FakeIptuRepository();
      cubit = IptuCubit(fakeRepository);
    });

    test('deve emitir IptuError quando o CPF for inválido', () async {
      await cubit.buscarDebitos('11111111111');

      expect(cubit.state, isA<IptuError>());
      final error = cubit.state as IptuError;
      expect(error.message, 'Informe um CPF válido.');
      expect(fakeRepository.consultarDebitosCalled, isFalse);
    });

    test('deve chamar o repository quando o CPF for válido', () async {
      // CPF válido de teste: 08269577146
      await cubit.buscarDebitos('08269577146');

      expect(fakeRepository.consultarDebitosCalled, isTrue);
      expect(cubit.state, isA<IptuSuccess>());
    });
  });
}
