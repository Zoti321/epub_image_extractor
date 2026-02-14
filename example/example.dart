import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

/// 使用示例
void main() async {
  // 创建解析器实例
  final parser = EpubParser();

  // 示例 1: 提取单个 EPUB 文件
  try {
    final epubFile = File('example.epub');
    final result = await parser.extract(epubFile);

    print('标题: ${result.title}');
    print('图片数量: ${result.images.length}');

    // 保存图片到指定目录
    final outputDir = Directory('output');
    final savedCount = await parser.saveImages(
      result,
      outputDir,
      useTitleAsFolder: true,
    );

    print('已保存 $savedCount 张图片');
  } catch (e) {
    print('错误: $e');
  }

  // 示例 2: 获取图片数据（用于 Flutter）
  try {
    final result = await parser.extract(File('example.epub'));

    // 获取第一张图片的数据
    if (result.images.isNotEmpty) {
      final firstImage = result.images[0];
      final imageData = parser.getImageData(result, firstImage);

      if (imageData != null) {
        print('第一张图片大小: ${imageData.length} 字节');
        print('媒体类型: ${firstImage.mediaType}');
        // 在 Flutter 中可以使用: Image.memory(imageData)
      }
    }

    // 获取所有图片数据
    final allImagesData = parser.getAllImagesData(result);
    print('获取到 ${allImagesData.length} 张图片的数据');
  } catch (e) {
    print('错误: $e');
  }

  // 示例 2: 自定义特殊图片关键词
  final customParser = EpubParser(
    specialImageKeywords: [
      'cover',
      'title',
      'custom_keyword', // 自定义关键词
    ],
  );

  // 使用自定义解析器
  try {
    final customResult = await customParser.extract(File('example.epub'));
    print('使用自定义解析器提取: ${customResult.title}');
  } catch (e) {
    print('错误: $e');
  }

  // 示例 3: 只提取信息，不保存文件
  try {
    final result = await parser.extract(File('example.epub'));
    print('标题: ${result.title}');

    for (final image in result.images) {
      print('图片: ${image.path}');
      print('  媒体类型: ${image.mediaType}');
      print('  保持原名: ${image.keepOriginalName}');
    }
  } catch (e) {
    print('错误: $e');
  }
}
