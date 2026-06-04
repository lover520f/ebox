import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../config/theme.dart';
import '../../providers/server_provider.dart';
import '../../models/emby_server.dart';

class ServerAddPage extends StatefulWidget {
  const ServerAddPage({super.key});

  @override
  State<ServerAddPage> createState() => _ServerAddPageState();
}

class _ServerAddPageState extends State<ServerAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showAdvanced = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加服务器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 服务器地址
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: 'http://192.168.1.100:8096',
                  prefixIcon: Icon(Icons.dns),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器地址';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return '地址必须以 http:// 或 https:// 开头';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // 服务器名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '服务器名称',
                  hintText: '我家里的 Emby',
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // 高级选项
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAdvanced = !_showAdvanced;
                  });
                },
                child: Text(_showAdvanced ? '隐藏高级选项' : '显示高级选项'),
              ),
              
              if (_showAdvanced) ...[
                // 用户名
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // 密码
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],
              
              // 错误信息
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.errorColor),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],
              
              const SizedBox(height: AppTheme.spacingL),
              
              // 测试连接按钮
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: const Icon(Icons.wifi),
                label: const Text('测试连接'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // 保存按钮
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveServer,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? '保存中...' : '保存'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await context.read<ServerProvider>().testConnection(url);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('连接成功！'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = '无法连接到服务器，请检查地址是否正确';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '连接失败：$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final server = EmbyServer(
        id: const Uuid().v4(),
        name: _nameController.text.trim().isEmpty ? 'Emby 服务器' : _nameController.text.trim(),
        url: _urlController.text.trim(),
        username: _usernameController.text.trim().isEmpty 
            ? null 
            : _usernameController.text.trim(),
        password: _passwordController.text.trim().isEmpty 
            ? null 
            : _passwordController.text.trim(),
        isActive: false,
      );

      await context.read<ServerProvider>().addServer(server);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('服务器已保存'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.goNamed('servers');
      }
    } catch (e) {
      setState(() {
        _errorMessage = '保存失败：$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
