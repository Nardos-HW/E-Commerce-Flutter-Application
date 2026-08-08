import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: 'Could not load profile.',
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  profile.name.firstname[0].toUpperCase() + profile.name.lastname[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${profile.name.firstname} ${profile.name.lastname}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Center(child: Text('@${profile.username}', style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(leading: const Icon(Icons.email_outlined), title: Text(profile.email)),
              ListTile(leading: const Icon(Icons.phone_outlined), title: Text(profile.phone)),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text('${profile.address.street} ${profile.address.number}'),
                subtitle: Text('${profile.address.city}, ${profile.address.zipcode}'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}