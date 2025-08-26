import 'package:flutter/material.dart';
import 'package:portfolio_frontend/screens/home.dart';
import 'package:portfolio_frontend/screens/blog.dart';
import 'package:portfolio_frontend/screens/profile.dart';
import 'package:portfolio_frontend/screens/new_blog.dart';
import 'package:portfolio_frontend/api_service.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  var activePageTitle = 'Home';
  Function? _refreshHomeCallback;
  Function? _refreshBlogCallback;
  final ApiService apiService = ApiService();

  void _addNewBlog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewBlogScreen(
          onBlogAdded: () {
            _refreshBlogCallback?.call();
          },
        ),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      if (index == 0) {
        activePageTitle = 'Home';
      } else if (index == 1) {
        activePageTitle = 'Blogs';
      } else {
        activePageTitle = 'Settings';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = HomeScreen(
      onEdit: () {
        setState(() {});
        _refreshHomeCallback?.call();
      },
      setRefreshCallback: (Function callback) {
        _refreshHomeCallback = callback;
      },
    );

    if (_selectedPageIndex == 1) {
      activePage = BlogsScreen(
        onBlogAdded: () {
          setState(() {});
          _refreshBlogCallback?.call();
        },
        setRefreshCallback: (Function callback) {
          _refreshBlogCallback = callback;
        },
      );
    } else if (_selectedPageIndex == 2) {
      activePage = ProfileScreen(setRefreshCallback: (Function callback) {});
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activePageTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _selectedPageIndex == 1
            ? [IconButton(onPressed: _addNewBlog, icon: Icon(Icons.add))]
            : null,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Blogs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
