# epub_image_extractor

一个强大的 Dart package，用于从 EPUB 文件中提取标题和图片，支持按阅读顺序排序和智能重命名。

## 功能特性

- 📖 **提取标题**：从 EPUB 元数据中提取书籍标题
- 🖼️ **提取图片**：提取 EPUB 中的所有图片资源
- 📑 **按顺序排序**：根据 EPUB 的 spine（阅读顺序）和内容文件中的出现顺序对图片进行排序
- 🏷️ **智能重命名**：普通图片按顺序重命名为 `0001.jpg`, `0002.png` 等
- 📎 **保持原名**：封面图和特殊图片（如 `cover.jpg`, `theendinfo.png`）保持原始文件名
- 🔧 **易于使用**：提供简洁的 API 和命令行工具

## 安装

### 从 pub.dev 安装（推荐）

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  epub_image_extractor: ^1.0.0
```

然后运行：

```bash
flutter pub get
# 或
dart pub get
```

### 本地开发使用

如果包在本地开发，可以使用路径依赖：

```yaml
dependencies:
  epub_image_extractor:
    path: ../epub_image_extractor
```

### 从 Git 仓库安装

```yaml
dependencies:
  epub_image_extractor:
    git:
      url: https://github.com/YOUR_USERNAME/epub_image_extractor.git
      ref: main
```

> 📖 更多集成方式请查看 [INTEGRATION.md](INTEGRATION.md)

## 使用方法

### 作为库使用

```dart
import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

void main() async {
  // 创建解析器
  final parser = EpubParser();

  // 提取 EPUB
  final epubFile = File('book.epub');
  final result = await parser.extract(epubFile);

  print('标题: ${result.title}');
  print('图片数量: ${result.images.length}');

  // 保存图片
  final outputDir = Directory('output');
  final savedCount = await parser.saveImages(
    result,
    outputDir,
    useTitleAsFolder: true, // 使用标题作为子文件夹名
  );

  print('已保存 $savedCount 张图片');
}
```

### 在 Flutter 中使用

这个包完全支持 Flutter，可以直接获取图片的字节数据用于 `Image.memory()` 组件：

```dart
import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';
import 'package:flutter/material.dart';

class EpubViewer extends StatefulWidget {
  final String epubPath;

  const EpubViewer({Key? key, required this.epubPath}) : super(key: key);

  @override
  State<EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends State<EpubViewer> {
  final _parser = EpubParser();
  EpubExtractionResult? _result;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    final result = await _parser.extract(File(widget.epubPath));
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _result!.images.length,
      itemBuilder: (context, index) {
        final imageInfo = _result!.images[index];
        final imageData = _parser.getImageData(_result!, imageInfo);

        if (imageData == null) {
          return const SizedBox.shrink();
        }

        // 直接使用 Image.memory 显示图片
        return Image.memory(imageData);
      },
    );
  }
}
```

或者更简单的方式，一次性获取所有图片数据：

```dart
final parser = EpubParser();
final result = await parser.extract(File('book.epub'));

// 获取所有图片数据
final imagesData = parser.getAllImagesData(result);

// 在 Flutter 中使用
for (final entry in imagesData.entries) {
  Image.memory(entry.value)
}
```

### 自定义特殊图片关键词

```dart
final parser = EpubParser(
  specialImageKeywords: [
    'cover',
    'title',
    'end',
    'custom_keyword', // 自定义关键词
  ],
);
```

### 命令行工具

安装后可以使用命令行工具：

```bash
# 处理单个 EPUB 文件
epub_image_extractor book.epub

# 指定输出目录
epub_image_extractor book.epub output/

# 处理目录中的所有 EPUB 文件
epub_image_extractor raw/ output/
```

## API 文档

### EpubParser

主要的解析器类。

#### 方法

- `Future<EpubExtractionResult> extract(dynamic epubFile)`
  
  从 EPUB 文件中提取标题和图片。
  
  **参数：**
  - `epubFile`: EPUB 文件路径（String）或 File 对象
  
  **返回：** `EpubExtractionResult` 包含标题和按顺序排列的图片列表

- `Uint8List? getImageData(EpubExtractionResult result, ImageInfo imageInfo)`
  
  获取单个图片的字节数据，可直接用于 Flutter 的 `Image.memory()`。
  
  **参数：**
  - `result`: EPUB 提取结果
  - `imageInfo`: 图片信息对象
  
  **返回：** 图片的字节数据（Uint8List），如果图片不存在则返回 null

- `Map<String, Uint8List> getAllImagesData(EpubExtractionResult result)`
  
  获取所有图片的字节数据。
  
  **参数：**
  - `result`: EPUB 提取结果
  
  **返回：** 一个 Map，键为图片路径，值为图片的字节数据（Uint8List）

- `Future<int> saveImages(EpubExtractionResult result, Directory outputDir, {bool useTitleAsFolder = true})`
  
  保存提取的图片到指定目录。
  
  **参数：**
  - `result`: EPUB 提取结果
  - `outputDir`: 输出目录
  - `useTitleAsFolder`: 是否使用标题作为子文件夹名（默认 true）
  
  **返回：** 保存的图片数量

#### 构造函数参数

- `specialImageKeywords`: 自定义特殊图片关键词列表。默认包含：cover, title, end, info, copyright, front, back, intro, preface, postscript, colophon

### EpubExtractionResult

EPUB 提取结果。

- `title`: 书籍标题（String）
- `images`: 图片列表（List<ImageInfo>），按阅读顺序排列

### ImageInfo

图片信息模型。

- `path`: 图片在 EPUB 中的路径（String）
- `mediaType`: 图片的媒体类型（String，如 image/jpeg, image/png）
- `keepOriginalName`: 是否保持原始文件名（bool）

## 图片顺序说明

程序会按照以下方式确定图片顺序：

1. 解析 EPUB 的 `spine`（阅读顺序）获取内容文件的顺序
2. 按照 spine 顺序解析每个 HTML/XHTML 内容文件
3. 在每个内容文件中，按照图片标签出现的顺序提取图片
4. 最终按照这个顺序重命名图片文件

## 特殊图片处理

以下类型的图片会保持原始文件名，不进行重命名：

- 封面图（文件名包含 `cover`）
- 标题页（文件名包含 `title`）
- 结束页（文件名包含 `end`）
- 信息页（文件名包含 `info`）
- 版权页（文件名包含 `copyright`）
- 以及其他包含特殊关键词的图片（`front`, `back`, `intro`, `preface`, `postscript`, `colophon` 等）

这些特殊图片会保持原始文件名，而其他图片会按顺序重命名为 `0001.jpg`, `0002.png` 等。序号会跳过这些特殊图片，确保普通图片的序号连续。

## 项目结构

```
epub_image_extractor/
├── lib/
│   ├── epub_image_extractor.dart      # 库导出文件
│   ├── src/
│   │   ├── epub_parser.dart   # 核心解析器
│   │   └── models.dart        # 数据模型
│   └── main.dart              # 示例程序
├── bin/
│   └── epub_image_extractor.dart      # 命令行工具
├── example/
│   └── example.dart           # 使用示例
└── pubspec.yaml
```

## 许可证

MIT License - 查看 [LICENSE](LICENSE) 文件了解详情

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关文档

- [集成指南](INTEGRATION.md) - 如何在项目中使用此包
- [发布指南](PUBLISH.md) - 如何发布到 pub.dev
