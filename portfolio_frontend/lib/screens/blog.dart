import 'package:flutter/material.dart';
import 'package:portfolio_frontend/functions/supportive_functions.dart';
import 'package:portfolio_frontend/screens/blog_detail.dart';
import 'package:portfolio_frontend/api_service.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key, this.onBlogAdded, this.setRefreshCallback});

  final VoidCallback? onBlogAdded;
  final Function(Function)? setRefreshCallback;

  @override
  State<BlogsScreen> createState() {
    return _BlogsScreenState();
  }
}

class _BlogsScreenState extends State<BlogsScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _blogsFuture;

  @override
  void initState() {
    super.initState();
    _blogsFuture = apiService.fetchBlogs();
    widget.setRefreshCallback?.call(_refreshBlogs);
  }

  void _refreshBlogs() {
    setState(() {
      _blogsFuture = apiService.fetchBlogs();
    });
  }

  void _deleteBlog(String title) async {
    try {
      await apiService.deleteBlog(title);
      setState(() {
        _blogsFuture = apiService.fetchBlogs();
      });
      widget.onBlogAdded?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete blog: $e')));
    }
  }

  void _selectBlog(BuildContext context, blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => BlogDetailScreen(blog: blog)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _blogsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No blog found.'));
                }
                final blogs = snapshot.data!;
                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index];
                    
                    return InkWell(
                      onTap: () => _selectBlog(context, blog),
                      child: Dismissible(
                        onDismissed: (direction) {
                          _deleteBlog(blog['title']);
                        },
                        key: ValueKey(blog),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Published: ${formatRelativeDate(blog['created_at'])}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        blog['title'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 120,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        blog['image'] ??
                                            'https://www.webnode.com/blog/wp-content/uploads/2019/04/blog2.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
