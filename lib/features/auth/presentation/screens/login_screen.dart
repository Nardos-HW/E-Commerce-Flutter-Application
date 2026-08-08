import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController(text: 'mor_2314');
  final passwordController = TextEditingController(text: '83r5^_');
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              Text(errorText!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => errorText = null);
                      final success = await ref.read(authProvider.notifier).login(
                            usernameController.text.trim(),
                            passwordController.text,
                          );
                      if (!success && mounted) {
                        setState(() => errorText = 'Invalid username or password.');
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test credentials pre-filled (mor_2314 / 83r5^_)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}