import 'package:flutter_test/flutter_test.dart';
import 'package:palma_da_mao/core/utils/uuid_generator.dart';
import 'package:palma_da_mao/modules/zeladoria/models/bairro_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/categoria_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/consulta_solicitacoes_response.dart';
import 'package:palma_da_mao/modules/zeladoria/models/endereco_cep_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/nova_solicitacao_dto.dart';
import 'package:palma_da_mao/modules/zeladoria/models/servico_model.dart';
import 'package:palma_da_mao/modules/zeladoria/models/solicitacao_resumo_model.dart';

void main() {
  group('UuidGenerator', () {
    test('deve gerar UUID v4 válido no formato 8-4-4-4-12', () {
      final uuid = UuidGenerator.generateV4();
      final regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(regex.hasMatch(uuid), isTrue);
    });

    test('deve gerar UUIDs distintos a cada chamada', () {
      final uuid1 = UuidGenerator.generateV4();
      final uuid2 = UuidGenerator.generateV4();
      expect(uuid1, isNot(equals(uuid2)));
    });
  });

  group('EnderecoCepModel', () {
    test('deve deserializar JSON do Swagger corretamente', () {
      final json = {
        'logradouro': 'Praça Samuel Sabatini',
        'bairroId': 10,
        'nomeBairro': 'Centro',
      };

      final model = EnderecoCepModel.fromJson(json);

      expect(model.logradouro, 'Praça Samuel Sabatini');
      expect(model.bairroId, 10);
      expect(model.nomeBairro, 'Centro');
    });
  });

  group('BairroModel', () {
    test('deve deserializar lista de bairros do Swagger', () {
      final json = {
        'bairroId': 19,
        'nomeBairro': 'Independência',
      };

      final model = BairroModel.fromJson(json);

      expect(model.bairroId, 19);
      expect(model.nomeBairro, 'Independência');
    });
  });

  group('CategoriaModel & ServicoModel', () {
    test('deve deserializar CategoriaModel conforme Swagger', () {
      final json = {
        'categoriaId': 11,
        'nomeCategoria': 'Arborização viária',
      };

      final model = CategoriaModel.fromJson(json);

      expect(model.categoriaId, 11);
      expect(model.nomeCategoria, 'Arborização viária');
    });

    test('deve deserializar ServicoModel conforme Swagger', () {
      final json = {
        'servicoId': 3,
        'nomeServico': 'Coleta de grandes objetos (bota-fora)',
      };

      final model = ServicoModel.fromJson(json);

      expect(model.servicoId, 3);
      expect(model.nomeServico, 'Coleta de grandes objetos (bota-fora)');
    });
  });

  group('NovaSolicitacaoDto', () {
    test('deve serializar DTO limpando máscaras de CPF, Celular e CEP', () {
      final dto = NovaSolicitacaoDto(
        bairroId: 10,
        descricaoOcorrencia: 'Buraco grande na pista',
        cepOcorrencia: '09.750-000',
        logradouroOcorrencia: 'Avenida Senador Vergueiro',
        celularMunicipe: '(11) 98765-4321',
        numeroOcorrencia: '1200',
        cpfMunicipe: '529.982.247-25',
        nomeMunicipe: 'Maria da Silva',
        servicoId: 39,
      );

      final json = dto.toJson();

      expect(json['bairroId'], 10);
      expect(json['descricaoOcorrencia'], 'Buraco grande na pista');
      expect(json['cepOcorrencia'], '09750000');
      expect(json['logradouroOcorrencia'], 'Avenida Senador Vergueiro');
      expect(json['celularMunicipe'], '11987654321');
      expect(json['numeroOcorrencia'], '1200');
      expect(json['cpfMunicipe'], '52998224725');
      expect(json['nomeMunicipe'], 'Maria da Silva');
      expect(json['servicoId'], 39);
    });

    test('deve enviar cepOcorrencia como null no JSON quando for nulo ou vazio', () {
      final dto = NovaSolicitacaoDto(
        bairroId: 10,
        descricaoOcorrencia: 'Buraco grande na pista',
        cepOcorrencia: null,
        logradouroOcorrencia: 'Avenida Senador Vergueiro',
        celularMunicipe: '(11) 98765-4321',
        numeroOcorrencia: '1200',
        cpfMunicipe: '529.982.247-25',
        nomeMunicipe: 'Maria da Silva',
        servicoId: 39,
      );

      final json = dto.toJson();

      expect(json.containsKey('cepOcorrencia'), isTrue);
      expect(json['cepOcorrencia'], isNull);
    });
  });

  group('ConsultaSolicitacoesResponse', () {
    test('deve deserializar resposta paginada do Spring Boot', () {
      final json = {
        'content': [
          {
            'protocolo': 'SBC-10112026-V3RK13',
            'nomeServico': 'Tapa-buracos',
            'rotuloStatus': 'Em análise',
            'incluidoEm': '2026-11-10T07:59:24.785501',
          },
          {
            'protocolo': 'SBC-10112026-CG3NQ0',
            'nomeServico': 'Civil (alvenaria)',
            'rotuloStatus': 'Em análise',
            'incluidoEm': '2026-11-10T07:52:12.409068',
          },
        ],
        'page': {
          'size': 10,
          'number': 0,
          'totalElements': 2,
          'totalPages': 1,
        },
      };

      final response = ConsultaSolicitacoesResponse.fromJson(json);

      expect(response.content.length, 2);
      expect(response.pageSize, 10);
      expect(response.pageNumber, 0);
      expect(response.totalElements, 2);
      expect(response.totalPages, 1);

      final first = response.content.first;
      expect(first.protocolo, 'SBC-10112026-V3RK13');
      expect(first.nomeServico, 'Tapa-buracos');
      expect(first.rotuloStatus, 'Em análise');
      expect(first.incluidoEm.year, 2026);
    });
  });
}
