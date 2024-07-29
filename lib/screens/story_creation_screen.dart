import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dart_openai/dart_openai.dart';
import 'generated_story_screen.dart';
import '../env.dart'; // 환경 변수 파일 import

class StoryCreationScreen extends StatefulWidget {
  @override
  _StoryCreationScreenState createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends State<StoryCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  XFile? _image;
  String _title = ''; // 제목을 위한 변수 추가
  String _characterName = '';
  String _characterFeatures = ''; // 캐릭터 특징을 위한 변수 추가
  String _storyTheme = '';
  String _storyPlot = '';
  TextEditingController _characterFeaturesController = TextEditingController(); // 텍스트 입력 컨트롤러 추가
  TextEditingController _storyThemeController = TextEditingController(); // 스토리 테마 입력 컨트롤러 추가
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    OpenAI.apiKey = Env.apiKey; // OpenAI API 키 설정
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _generateStory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true; // 로딩 표시를 보여줍니다.
      });

      try {
        // OpenAI GPT-3.5로 텍스트 동화 생성
        final userMessage = OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "Create a cute fairy tale using easy and simple words for children. $_characterName shows $_storyTheme in $_storyPlot.",
            ),
          ],
          role: OpenAIChatMessageRole.user,
        );

        final chatCompletion = await OpenAI.instance.chat.create(
          model: 'gpt-3.5-turbo',
          messages: [userMessage],
          maxTokens: 200, // 토큰 수를 200으로 제한
        );

        final generatedStory = chatCompletion.choices.first.message.content?.first.text ?? "No story generated.";

        // 길이를 줄이기 위해 생성된 스토리 잘라내기
        final storyLines = generatedStory.split(RegExp(r'\.\s+'));
        final chunkSize = (storyLines.length / 4).ceil();
        final storyChunks = List.generate(
          4,
              (i) => storyLines.skip(i * chunkSize).take(chunkSize).join('. '),
        );

        // OpenAI DALL-E로 각 텍스트 부분에 해당하는 이미지 생성
        final imageUrls = <String>[];
        for (var chunk in storyChunks) {
          final imageResponse = await OpenAI.instance.image.create(
            prompt: "Create a drawing-style illustration featuring a cute character for children. The character is $_characterName. The character's features are $_characterFeatures. The illustration is about $_storyTheme and $_storyPlot. The illustration should be in the style of a cute, simple drawing. It should be cute, with simple rounded lines, bright colors look. Ensure there are absolutely no words or text anywhere in the illustration. Ensure there is only one character depicted in each scene. The setting is extremely simple and clean.",
            n: 1,
            size: OpenAIImageSize.size1024,
            responseFormat: OpenAIImageResponseFormat.url,
          );
          imageUrls.add(imageResponse.data.first.url!);
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneratedStoryScreen(
              image: _image,
              title: _title, // 제목 전달
              characterName: _characterName,
              characterFeatures: _characterFeatures,
              storyTheme: _storyTheme,
              storyPlot: _storyPlot,
              generatedStory: generatedStory,
              imageUrls: imageUrls, // 생성된 이미지 URL 목록 전달
            ),
          ),
        );
      } catch (e) {
        print('Error generating story or images: $e');
      } finally {
        setState(() {
          _isLoading = false; // 로딩 표시를 숨깁니다.
        });
      }
    }
  }

  Widget _buildFeatureChip(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final feature = label.replaceAll('#', ''); // #을 제거하고 추가
          final currentText = controller.text.isEmpty ? feature : '${controller.text} $feature';
          controller.text = currentText; // 입력 필드에 추가
        });
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.lightGreen[200],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Story'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _image == null
                      ? TextButton(
                    onPressed: _pickImage,
                    child: Text('Upload Drawing'),
                  )
                      : Image.file(File(_image!.path)),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Title'), // 제목 입력 필드 추가
                    validator: (value) => value!.isEmpty ? 'Enter title' : null,
                    onSaved: (value) => _title = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Character Name'),
                    validator: (value) => value!.isEmpty ? 'Enter character name' : null,
                    onSaved: (value) => _characterName = value!,
                  ),
                  TextFormField(
                    controller: _characterFeaturesController, // 컨트롤러 추가
                    decoration: InputDecoration(labelText: 'Character Features (color, looks, etc.)'),
                    validator: (value) => value!.isEmpty ? 'Enter character features' : null,
                    onSaved: (value) => _characterFeatures = value!,
                    maxLines: 2,
                  ),
                  Wrap(
                    spacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureChip('#red', _characterFeaturesController),
                      _buildFeatureChip('#orange', _characterFeaturesController),
                      _buildFeatureChip('#white', _characterFeaturesController),
                      _buildFeatureChip('#big ears', _characterFeaturesController),
                    ],
                  ),
                  TextFormField(
                    controller: _storyThemeController, // 컨트롤러 추가
                    decoration: InputDecoration(labelText: 'Story Theme'),
                    validator: (value) => value!.isEmpty ? 'Enter story theme' : null,
                    onSaved: (value) => _storyTheme = value!,
                  ),
                  Wrap(
                    spacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureChip('#adventure', _storyThemeController),
                      _buildFeatureChip('#courage', _storyThemeController),
                      _buildFeatureChip('#honesty', _storyThemeController),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Story Plot (2 lines)'),
                    validator: (value) => value!.isEmpty ? 'Enter story plot' : null,
                    onSaved: (value) => _storyPlot = value!,
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _generateStory,
                    child: Text('Generate Story'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Generating...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
