import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:pennywise/screens/home/home_screen.dart';
import 'package:animations/animations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to sign in. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ).pOnly(bottom: 32),
              Text('Welcome to',
                      style: Theme.of(context).textTheme.headlineMedium)
                  .centered(),
              const SizedBox(height: 8),
              Text(
                'Daily Expense Book',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ).centered(),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label:
                    Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
