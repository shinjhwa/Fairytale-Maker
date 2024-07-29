class Story {
  final String title;
  final String characterName;
  final String characterFeatures;
  final String storyTheme;
  final String storyPlot;
  final String generatedStory;
  final List<String> imageUrls;

  Story({
    required this.title,
    required this.characterName,
    required this.characterFeatures,
    required this.storyTheme,
    required this.storyPlot,
    required this.generatedStory,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'characterName': characterName,
      'characterFeatures': characterFeatures,
      'storyTheme': storyTheme,
      'storyPlot': storyPlot,
      'generatedStory': generatedStory,
      'imageUrls': imageUrls,
    };
  }

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      title: json['title'],
      characterName: json['characterName'],
      characterFeatures: json['characterFeatures'],
      storyTheme: json['storyTheme'],
      storyPlot: json['storyPlot'],
      generatedStory: json['generatedStory'],
      imageUrls: List<String>.from(json['imageUrls']),
    );
  }
}
