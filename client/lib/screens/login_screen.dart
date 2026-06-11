import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/server_provider.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final url = _urlController.text.endsWith('/') ? _urlController.text.substring(0, _urlController.text.length - 1) : _urlController.text;
      final authResponse = await http.post(
        Uri.parse('$url/Users/AuthenticateWithName'),
        headers: {'Content-Type': 'application/json', 'X-Emby-Authorization': 'MediaBrowser Client="EBox", Version="1.0.0"'},
        body: jsonEncode({'Username': _usernameController.text, 'Pw': _passwordController.text}),
      );
      if (authResponse.statusCode == 200) {
        final data = jsonDecode(authResponse.body);
        context.read<ServerProvider>().setServer(url, data['AccessToken'], data['User']['Id']);
        if (mounted) context.go('/home');
      } else {
        setState(() => _error = '登录失败');
      }
    } catch (e) {
      setState(() => _error = '无法连接到服务器');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_outlined, size: 80, color: Colors.white),
                    const SizedBox(height: 24),
                    const Text('E 宝盒', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 48),
                    Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextFormField(controller: _urlController, decoration: const InputDecoration(labelText: '服务器地址', hintText: 'http://192.168.1.100:8096', prefixIcon: Icon(Icons.dns)), validator: (v) => v == null || v.isEmpty ? '请输入服务器地址' : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: '用户名', prefixIcon: Icon(Icons.person)), validator: (v) => v == null || v.isEmpty ? '请输入用户名' : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码', prefixIcon: Icon(Icons.lock)), validator: (v) => v == null || v.isEmpty ? '请输入密码' : null),
                            const SizedBox(height: 24),
                            if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('登录', style: TextStyle(fontSize: 18, color: Colors.white)))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
