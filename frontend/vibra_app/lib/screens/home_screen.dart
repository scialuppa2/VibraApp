import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:vibra_app/screens/create_group_chat_screen.dart';
import '../widgets/auth_section.dart';
import '../widgets/home_app_bar.dart';
import 'chat_list_section.dart';
import 'create_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _debounce;

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: 'Vibra',
        actions: [AuthSection()],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cerca...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          Expanded(
            child: ChatListSection(searchQuery: _searchQuery),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      backgroundColor: Colors.grey[850],
      floatingActionButton: ExpandableFab(
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: _toggleSearch,
            backgroundColor: Colors.lightBlue[100],
            tooltip: 'Search',
            child: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.grey[850],
            ),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateChatScreen(),
                ),
              );
            },
            backgroundColor: Colors.lightBlue[100],
            tooltip: 'Create New Chat',
            child: Icon(Icons.person, color: Colors.grey[850]),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupChatScreen(),
                ),
              );
            },
            backgroundColor: Colors.lightBlue[100],
            tooltip: 'Create New Group Chat',
            child: Icon(Icons.group, color: Colors.grey[850]),
          ),
        ],
      ),
    );
  }
}
