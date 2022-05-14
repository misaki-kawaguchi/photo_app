import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoapp/photo_list_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // メールアドレス用のTextEditingController
  final TextEditingController _emailController = TextEditingController();
  // パスワード用のTextEditingController
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Photo App',
                  style: Theme.of(context).textTheme.headline4,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'メールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (String? value) {
                    if (value?.isEmpty == true) {
                      return 'パスワードを入力して下さい';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSignIn,
                    child: const Text('ログイン'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSignUp,
                    child: const Text('新規登録'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PhotoListScreen(),
      ),
    );
  }

  // 新規登録
  Future<void> _onSignUp() async {
    try {
      if (_formKey.currentState?.validate() != true) {
        return;
      }

      final String email = _emailController.text;
      final String password = _passwordController.text;
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const PhotoListScreen(),
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }
}
