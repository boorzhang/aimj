import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AimjApp extends StatelessWidget {
  const AimjApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 以 iPhone 14 (390 x 844) 为设计稿基准
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'AI短剧',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
