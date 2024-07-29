import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 추가
import 'package:path_provider/path_provider.dart';
import 'saved_stories_screen.dart';

class GeneratedStoryScreen extends StatelessWidget {
  final XFile? image;
  final String title;
  final String characterName;
  final String characterFeatures;
  final String storyTheme;
  final String storyPlot;
  final String generatedStory;
  final List<String> imageUrls;

  GeneratedStoryScreen({
    this.image,
    required this.title,
    required this.characterName,
    required this.characterFeatures,
    required this.storyTheme,
    required this.storyPlot,
    required this.generatedStory,
    required this.imageUrls,
  });

  Future<void> _saveStory() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/story_${DateTime.now().millisecondsSinceEpoch}.json');

    String storyContent = jsonEncode({
      'title': title,
      'characterName': characterName,
      'characterFeatures': characterFeatures,
      'storyTheme': storyTheme,
      'storyPlot': storyPlot,
      'generatedStory': generatedStory,
      'imageUrls': imageUrls,
    });

    await file.writeAsString(storyContent);
  }

  void _saveStoryAndNavigate(BuildContext context) async {
    await _saveStory();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SavedStoriesScreen(),
      ),
    );
  }

  void _discardStory(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SavedStoriesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storyLines = generatedStory.split(RegExp(r'\.\s+'));
    final chunkSize = (storyLines.length / 4).ceil();
    final storyChunks = List.generate(
      4,
          (i) => storyLines.skip(i * chunkSize).take(chunkSize).join('. '),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Story'),
      ),
      body: Scrollbar(
        child: PageView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemCount: imageUrls.length + 1,
          itemBuilder: (context, index) {
            if (index < imageUrls.length) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(imageUrls[index]),
                    SizedBox(height: 20),
                    if (index < storyChunks.length)
                      Text(
                        storyChunks[index],
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _saveStoryAndNavigate(context),
                      child: Text('Save Story'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _discardStory(context),
                      child: Text('Discard Story'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
