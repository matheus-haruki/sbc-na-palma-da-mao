import 'package:flutter_modular/flutter_modular.dart';
import '../../core/network/http_client.dart';
import '../../core/network/dio_adapter.dart';
import '../../core/network/websocket_client.dart';
import '../../core/network/stomp_websocket_adapter.dart';
import 'package:dio/dio.dart';
import 'data/repositories/chat_repository.dart';
import 'presentational/bloc/chat_cubit.dart';
import 'presentational/bloc/tickets_cubit.dart';
import 'presentational/ui/pages/chat_page.dart';
import 'presentational/ui/pages/tickets_page.dart';

class ChatModule extends Module {
  @override
  void binds(Injector i) {
    i.addSingleton<Dio>(() {
      final dio = Dio();
      dio.options.headers['ngrok-skip-browser-warning'] = 'true';
      return dio;
    });
    
    i.addSingleton<IHttpClient>(() => DioAdapter(i.get<Dio>()));
    i.addSingleton<IWebSocketClient>(() => StompWebSocketAdapter());
    
    i.addSingleton<ChatRepository>(() => ChatRepository(
      i.get<IHttpClient>(),
      i.get<IWebSocketClient>(),
    ));
    
    // Injetando TicketsCubit
    i.add<TicketsCubit>(() => TicketsCubit(i.get<ChatRepository>()));

    // Injetando ChatCubit
    i.add<ChatCubit>(() => ChatCubit(
      i.get<ChatRepository>(),
      ticketId: i.args.data ?? '1',
    ));
  }

  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const TicketsPage());
    r.child('/sala', child: (context) => ChatPage(ticketId: r.args.data ?? '1'));
  }
}
