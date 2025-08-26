import 'package:flutter/material.dart';
import 'package:portfolio_frontend/api_service.dart';
import 'package:portfolio_frontend/screens/new_project.dart';
import 'package:portfolio_frontend/screens/project_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onEdit, this.setRefreshCallback});

  final VoidCallback? onEdit;
  final Function(Function)? setRefreshCallback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> _homePageFuture;

  String profileImage =
      'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png';

  @override
  void initState() {
    super.initState();
    _homePageFuture = apiService.fetchHomePage();
    widget.setRefreshCallback?.call(_refreshHomePage);
  }

  void _refreshHomePage() {
    setState(() {
      _homePageFuture = apiService.fetchHomePage();
    });
  }

  void _addNewProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewProjectScreen(onProjectAdded: _refreshHomePage),
      ),
    );
  }

  void _selectProject(BuildContext context, project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProjectDetailScreen(project: project),
      ),
    );
  }

  void aboutMeForm(BuildContext context, String currentData) {
    final TextEditingController aboutController = TextEditingController(
      text: currentData,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update About Me'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: aboutController,
                  decoration: const InputDecoration(labelText: 'About Me'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'About Me cannot be empty';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (aboutController.text.trim().isNotEmpty) {
                  try {
                    await apiService.aboutMeUpdate(aboutController.text.trim());
                    widget.onEdit?.call();
                    _refreshHomePage();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void profileForm(
    BuildContext context,
    String currentCareer,
    String currentCity,
    String currentCountry,
  ) {
    final TextEditingController careerController = TextEditingController(
      text: currentCareer,
    );
    final TextEditingController cityController = TextEditingController(
      text: currentCity,
    );
    final TextEditingController countryController = TextEditingController(
      text: currentCountry,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: careerController,
                  decoration: const InputDecoration(labelText: 'Career'),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Career cannot be empty'
                      : null,
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'City cannot be empty'
                      : null,
                ),
                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Country cannot be empty'
                      : null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (careerController.text.trim().isNotEmpty &&
                    cityController.text.trim().isNotEmpty &&
                    countryController.text.trim().isNotEmpty) {
                  try {
                    await apiService.profileUpdate(
                      careerController.text.trim(),
                      cityController.text.trim(),
                      countryController.text.trim(),
                    );
                    widget.onEdit?.call();
                    _refreshHomePage();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void skillForm(
    BuildContext context,
    List<dynamic> currentSkills,
    int length,
  ) {
    final TextEditingController skillsController = TextEditingController();
    final List<String> skills = currentSkills
        .map((s) => s['name'] as String)
        .toList();
    final List<String> newSkills = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void _addSkill(String skill) {
              if (skill.isNotEmpty && !skills.contains(skill)) {
                setState(() {
                  skills.add(skill);
                  newSkills.add(skill); // Track new skills separately
                });
                skillsController.clear();
              }
            }

            void _removeSkill(String skill) {
              setState(() {
                skills.remove(skill);
                newSkills.remove(
                  skill,
                ); // Remove from newSkills if added in this session
              });
            }

            return AlertDialog(
              title: const Text('Update Skills'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeSkill(skill),
                        );
                      }).toList(),
                    ),
                    TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(labelText: 'Add Skill'),
                      onFieldSubmitted: _addSkill,
                      validator: (value) => value?.trim().isEmpty ?? true
                          ? 'Skill cannot be empty'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (newSkills.isNotEmpty) {
                      try {
                        await apiService.skillsUpdate(newSkills);
                        widget.onEdit?.call();
                        _refreshHomePage();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update skills: $e'),
                          ),
                        );
                      }
                    } else {
                      Navigator.of(
                        context,
                      ).pop(); // Close dialog if no new skills
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _homePageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found.'));
          }
          final result = snapshot.data!;
          final profile = result['profile'] ?? {};
          final skills = result['skills'] ?? [];
          final projects = result['projects'] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          result['profile_url'] ?? profileImage,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        result['fullname'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                            child: Text(
                              profile['career'] ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              profileForm(
                                context,
                                profile['career'] ?? '',
                                profile['city'] ?? '',
                                profile['country'] ?? '',
                              );
                              widget.onEdit?.call();
                            },
                            icon: const Icon(Icons.mode_edit_outline_outlined),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${profile['city'] ?? ''}, ',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontSize: 14,
                                ),
                          ),
                          Text(
                            profile['country'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'About Me',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          aboutMeForm(context, profile['about_me'] ?? '');
                          widget.onEdit?.call();
                        },
                        icon: const Icon(Icons.mode_edit_outline_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    profile['about_me'] ?? 'Nothing About Me',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        skillForm(context, skills, skills.length);
                        widget.onEdit?.call();
                      },
                      icon: const Icon(Icons.mode_edit_outline_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map<Widget>((skill) {
                    return Chip(label: Text(skill['name']));
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Featured Projects',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: _addNewProject,
                      icon: const Icon(Icons.add_circle_outline_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: projects.length,
                    itemBuilder: (BuildContext context, int index) {
                      final project = projects[index];
                      return InkWell(
                        onTap: () => _selectProject(context, project),
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              Container(
                                width: 180,
                                height: 150,
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      project['image'] ??
                                          'https://via.placeholder.com/100',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Text(
                                project['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
