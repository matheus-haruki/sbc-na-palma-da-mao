import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://jlpsxevapiuamutiqsdh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpscHN4ZXZhcGl1YW11dGlxc2RoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwMTIxMzYsImV4cCI6MjEwNTU4ODEzNn0.CiHrLazsznqbtqFt3rdGA_gvdIdf3gY40eBLEB8-fs4',
  );

  final client = Supabase.instance.client;
  
  try {
    final response = await client.from('categorias').select();
    print('SUCESSO CATEGORIAS: $response');
  } catch (e) {
    print('ERRO CATEGORIAS: $e');
  }
  
  try {
    final response2 = await client.from('solicitacoes').select().limit(1);
    print('SUCESSO SOLICITACOES: $response2');
  } catch (e) {
    print('ERRO SOLICITACOES: $e');
  }
}
