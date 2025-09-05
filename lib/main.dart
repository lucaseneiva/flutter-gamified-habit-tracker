import 'package:firy_streak/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/core/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firy_streak/presentation/core/utils/mobile_frame_wrapper.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false, // Mudei para false para produção
      title: 'Chaminhas',
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (kIsWeb) {
          // 2. Se for web, verificamos o tamanho da tela.
          final screenWidth = MediaQuery.of(context).size.width;
          const desktopBreakpoint = 600.0; // Nosso ponto de corte

          // 3. Aplicamos a moldura SOMENTE se for web E a tela for larga.
          if (screenWidth > desktopBreakpoint) {
            return MobileFrameWrapper(child: child!);
          }
        }
        
        // Para todos os outros casos (app nativo, ou web em tela pequena),
        // retornamos o aplicativo normal, em tela cheia.
        return child!;
      },
    );
  }
}
