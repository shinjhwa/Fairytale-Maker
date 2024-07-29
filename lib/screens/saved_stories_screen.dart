import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'generated_story_screen.dart';
import '../models/story_model.dart';
import 'story_creation_screen.dart'; // 스토리 생성 스크린 추가

class SavedStoriesScreen extends StatefulWidget {
  @override
  _SavedStoriesScreenState createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends State<SavedStoriesScreen> {
  Future<List<Story>> _loadSavedStories() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((item) => item.path.endsWith('.json')).toList();

    List<Story> stories = [];
    for (var file in files) {
      final content = await File(file.path).readAsString();
      stories.add(Story.fromJson(jsonDecode(content)));
    }
    return stories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Stories'),
      ),
      body: FutureBuilder<List<Story>>(
        future: _loadSavedStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No stories saved.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final story = snapshot.data![index];
                return ListTile(
                  title: Text(story.title),
                  subtitle: Text(story.generatedStory.split('. ')[0]), // 첫 줄을 제목으로 사용
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneratedStoryScreen(
                          image: null,
                          title: story.title,
                          characterName: story.characterName,
                          characterFeatures: story.characterFeatures,
                          storyTheme: story.storyTheme,
                          storyPlot: story.storyPlot,
                          generatedStory: story.generatedStory,
                          imageUrls: story.imageUrls,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryCreationScreen(), // 스토리 생성 스크린으로 이동
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
