import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/server_provider.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> _loadData() async {
    final sp = context.read<ServerProvider>();
    try {
      final resp = await http.get(
        Uri.parse('${sp.serverUrl}/Users/${sp.userId}/Items/Resume?Limit=20'),
        headers: {'X-Emby-Token': sp.apiKey},
      );
      if (resp.statusCode == 200) {
        setState(() {
          _items = (jsonDecode(resp.body)['Items'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('E 宝盒'), backgroundColor: const Color(0xFF1A1A1A)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('暂无内容', style: TextStyle(color: Colors.white70)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, childAspectRatio: 2/3, crossAxisSpacing: 16, mainAxisSpacing: 16,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: '${sp.serverUrl}/Items/${item['Id']}/Images/Primary?api_key=${sp.apiKey}',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(item['Name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
