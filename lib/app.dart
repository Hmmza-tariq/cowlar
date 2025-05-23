import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/mqtt_service.dart';
import 'core/theme/app_theme.dart';
import 'features/data_download/data/services/data_download_service.dart';
import 'features/data_download/data/services/isar_service.dart';
import 'features/data_download/presentation/bloc/download_cubit.dart';
import 'features/mqtt_client/presentation/bloc/mqtt_cubit.dart';
import 'features/mqtt_client/presentation/pages/mqtt_page.dart';
import 'flavors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MqttCubit>(
          create: (context) => MqttCubit(mqttService: MqttService()),
        ),
        BlocProvider<DownloadCubit>(
          create: (context) => DownloadCubit(
            downloadService: DataDownloadService(),
            isarService: IsarService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: F.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: _flavorBanner(child: const MqttPage(), show: kDebugMode),
      ),
    );
  }

  Widget _flavorBanner({required Widget child, bool show = true}) => show
      ? Banner(
          location: BannerLocation.topStart,
          message: F.name,
          color: Colors.green.withAlpha(150),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
            letterSpacing: 1.0,
          ),
          textDirection: TextDirection.ltr,
          child: child,
        )
      : Container(child: child);
}
