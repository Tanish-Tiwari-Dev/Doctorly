import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:doctorly/providers/connectivity_provider.dart';
import 'package:doctorly/utils/app_colors.dart';

/// Reusable banner widget displaying a warning when device is offline.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline = connectivityAsync.when(
      data: (status) => status == ConnectivityResult.none,
      error: (err, stackTrace) => false,
      loading: () => false,
    );

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: const Icon(
        Icons.wifi_off_rounded,
        color: Colors.white,
        size: 22,
      ),
      content: Text(
        'No Internet Connection',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
      backgroundColor: AppColors.error,
      actions: const [
        SizedBox.shrink(),
      ],
    );
  }
}
