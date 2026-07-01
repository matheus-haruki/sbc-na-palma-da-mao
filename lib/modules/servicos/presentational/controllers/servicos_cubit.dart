// lib/modules/servicos/presentational/controllers/servicos_cubit.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palma_da_mao/modules/servicos/models/servico_model.dart';
import 'servicos_state.dart';

class ServicosCubit extends Cubit<ServicosState> {
  ServicosCubit() : super(ServicosInitial());

  Future<void> carregarListaDeServicos() async {
    emit(ServicosLoading());
    
    try {
      // 1. Lê o conteúdo do arquivo JSON armazenado no aplicativo
      final String jsonString = await rootBundle.loadString('assets/data/servicos.json');
      
      // 2. Converte a String de texto em uma estrutura dinâmica do Dart (List)
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      // 3. Mapeia a lista dinâmica, transformando cada item em um objeto ServicoModel
      final List<ServicoModel> servicos = jsonList
          .map((item) => ServicoModel.fromJson(item as Map<String, dynamic>))
          .toList();
          
      // 4. Emite o estado de sucesso entregando a lista pronta para a View
      emit(ServicosSuccess(servicos: servicos));
      
    } catch (e) {
      // Caso ocorra erro (ex: esqueceu de registrar o asset no pubspec ou JSON inválido)
      emit(ServicosError(message: 'Não foi possível carregar os serviços.'));
      // Em um app de produção, você também faria um log do erro original 'e' aqui
    }
  }
}