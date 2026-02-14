# 集成指南

## 在项目中使用 epub_image_extractor

### 方式 1: 从 pub.dev 安装（推荐）

如果包已发布到 pub.dev：

1. 在项目的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  epub_image_extractor: ^1.0.0
```

2. 运行安装命令：

```bash
flutter pub get
# 或
dart pub get
```

3. 在代码中使用：

```dart
import 'package:epub_image_extractor/epub_image_extractor.dart';
```

### 方式 2: 使用本地路径（开发时）

如果包在本地开发，可以使用路径依赖：

1. 在项目的 `pubspec.yaml` 中：

```yaml
dependencies:
  epub_image_extractor:
    path: ../epub_image_extractor  # 相对于项目根目录的路径
```

2. 运行安装：

```bash
flutter pub get
```

### 方式 3: 使用 Git 仓库

如果代码在 Git 仓库中：

```yaml
dependencies:
  epub_image_extractor:
    git:
      url: https://github.com/YOUR_USERNAME/epub_image_extractor.git
      ref: main  # 或 tag: v1.0.0
```

### 方式 4: 直接复制代码

将 `lib` 目录下的所有文件复制到你的项目中：

```
your_project/
  lib/
    epub_image_extractor/
      epub_image_extractor.dart
      src/
        epub_parser.dart
        models.dart
```

然后在代码中导入：

```dart
import 'package:your_project/epub_image_extractor/epub_image_extractor.dart';
```

## Flutter 项目集成示例

### 1. 添加依赖

在 `pubspec.yaml` 中：

```yaml
dependencies:
  flutter:
    sdk: flutter
  epub_image_extractor: ^1.0.0
```

### 2. 完整使用示例

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:epub_image_extractor/epub_image_extractor.dart';

class EpubReaderPage extends StatefulWidget {
  final String epubPath;

  const EpubReaderPage({Key? key, required this.epubPath}) : super(key: key);

  @override
  State<EpubReaderPage> createState() => _EpubReaderPageState();
}

class _EpubReaderPageState extends State<EpubReaderPage> {
  final _parser = EpubParser();
  EpubExtractionResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final result = await _parser.extract(File(widget.epubPath));
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(child: Text('错误: $_error')),
      );
    }

    if (_result == null) {
      return const Scaffold(
        body: Center(child: Text('未找到数据')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_result!.title),
      ),
      body: ListView.builder(
        itemCount: _result!.images.length,
        itemBuilder: (context, index) {
          final imageInfo = _result!.images[index];
          final imageData = _parser.getImageData(_result!, imageInfo);

          if (imageData == null) {
            return const SizedBox.shrink();
          }

          return Image.memory(imageData);
        },
      ),
    );
  }
}
```

## Dart 命令行项目集成

### 1. 添加依赖

在 `pubspec.yaml` 中：

```yaml
dependencies:
  epub_image_extractor: ^1.0.0
```

### 2. 使用示例

```dart
import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

void main() async {
  final parser = EpubParser();
  final result = await parser.extract(File('book.epub'));
  
  print('标题: ${result.title}');
  print('图片数量: ${result.images.length}');
  
  // 获取图片数据
  for (final imageInfo in result.images) {
    final imageData = parser.getImageData(result, imageInfo);
    if (imageData != null) {
      print('图片: ${imageInfo.path}, 大小: ${imageData.length} 字节');
    }
  }
}
```

## 权限要求

### Flutter (Android)

如果需要在 Android 上读取 EPUB 文件，在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Flutter (iOS)

iOS 通常不需要额外权限，但如果是访问用户选择的文件，可能需要配置 Info.plist。

## 常见问题

### Q: 如何获取 EPUB 文件路径？

**A:** 可以使用文件选择器：

```dart
import 'package:file_picker/file_picker.dart';

// 选择文件
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['epub'],
);

if (result != null) {
  final filePath = result.files.single.path;
  // 使用 filePath
}
```

### Q: 如何处理大文件？

**A:** 对于大 EPUB 文件，建议：

1. 异步加载
2. 使用分页加载图片
3. 缓存已加载的图片数据

```dart
// 分页加载示例
final pageSize = 20;
final startIndex = page * pageSize;
final endIndex = (startIndex + pageSize).clamp(0, result.images.length);

for (int i = startIndex; i < endIndex; i++) {
  final imageData = parser.getImageData(result, result.images[i]);
  // 处理图片
}
```

### Q: 如何保存图片到设备？

**A:** 使用 `path_provider` 和 `saveImages` 方法：

```dart
import 'package:path_provider/path_provider.dart';

final appDir = await getApplicationDocumentsDirectory();
final outputDir = Directory('${appDir.path}/epub_images');

await parser.saveImages(result, outputDir);
```

## 性能优化建议

1. **缓存解析结果**：解析 EPUB 文件后，可以缓存 `EpubExtractionResult`
2. **延迟加载图片**：只在需要时加载图片数据
3. **使用图片缓存**：在 Flutter 中使用 `CachedNetworkImage` 或类似的缓存机制
