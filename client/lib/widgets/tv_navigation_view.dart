import 'package:flutter/material.dart';
import '../config/theme.dart';

class TvNavigationView extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onNavigationSelected;

  const TvNavigationView({
    Key? key,
    required this.selectedIndex,
    required this.onNavigationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7),
                        const Color(0xFF00CEC9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Text(
                  'E 宝盒 TV',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return _buildNavItem(_navItems[index], index, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  final List<_NavItem> _navItems = [
    _NavItem('首页', Icons.home_rounded),
    _NavItem('电影', Icons.movie_rounded),
    _NavItem('剧集', Icons.tv_rounded),
    _NavItem('搜索', Icons.search_rounded),
    _NavItem('设置', Icons.settings_rounded),
  ];

  Widget _buildNavItem(_NavItem item, int index, bool isSelected) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && !isSelected) {
          // 可以自动选中
        }
      },
      child: Builder(
        builder: (context) => ListTile(
          leading: Icon(
            item.icon,
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[400],
            size: 32,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedTileColor: const Color(0xFF6C5CE7).withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          onTap: () => onNavigationSelected(index),
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;

  _NavItem(this.title, this.icon);
}
