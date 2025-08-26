import 'package:flutter/material.dart';
import 'package:portfolio_frontend/api_service.dart';
import 'package:portfolio_frontend/functions/supportive_functions.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key, required this.blog});

  final Map<String, dynamic> blog;
  @override
  State<BlogDetailScreen> createState() {
    return _BlogDetailScreenState();
  }
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _commentsFuture;
  late Future<Map<String, dynamic>> _profileFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _profileFuture = apiService.userProfile();
    _commentsFuture = apiService.fetchBlogComments(widget.blog['title']);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_formKey.currentState!.validate()) {
      try {
        await apiService.addBlogComment(
          widget.blog['title'],
          _commentController.text.trim(),
        );
        setState(() {
          _commentsFuture = apiService.fetchBlogComments(widget.blog['title']);
        });
        _commentController.clear();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Post')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.blog['title'],
                child: Image.network(
                  widget.blog['image'] ??
                      'https://www.webnode.com/blog/wp-content/uploads/2019/04/blog2.png',
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${widget.blog['category']} insight',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.blog['title'],
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'By ${widget.blog['author']['fullname'] ?? 'Unknown Author'}. ${formatRelativeDate(widget.blog['created_at'])}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.blog['content'],
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<dynamic>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No comment found.'));
                  }
                  final comments = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  comment['user']['profile_url'] ??
                                      'https://via.placeholder.com/50',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment['user']['fullname'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatRelativeDate(comment['created_at']),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                  ),
                                ],
                              ),
                              Text(
                                comment['content'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading profile: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      final profile = snapshot.data!;
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              profile['profile_url'] ??
                                  'https://www.webnode.com/blog/wp-content/uploads/2019/04/blog2.png',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  labelText: " Add Comment",
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Comment cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _addComment,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text('No profile data available.'),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
