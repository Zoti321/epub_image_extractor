import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

/// 使用 epub_image_extractor 库的示例程序
void main() async {
  final rawDir = Directory('raw');
  final outputDir = Directory('output');

  if (!await rawDir.exists()) {
    print('错误: raw 文件夹不存在');
    return;
  }

  // 确保 output 目录存在
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  // 获取所有 epub 文件
  final epubFiles = rawDir
      .listSync()
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.epub'))
      .toList();

  if (epubFiles.isEmpty) {
    print('未找到 EPUB 文件');
    return;
  }

  print('找到 ${epubFiles.length} 个 EPUB 文件\n');

  final parser = EpubParser();

  for (final epubFile in epubFiles) {
    try {
      print('正在处理: ${epubFile.path}');

      // 提取 EPUB
      final result = await parser.extract(epubFile);
      print('  标题: ${result.metadata.title}');
      print('  作者: ${result.metadata.creators.join(", ")}');
      print('  找到 ${result.images.length} 张图片');

      // 保存图片
      final savedCount = await parser.saveImages(
        result,
        outputDir,
        useTitleAsFolder: true,
      );

      print('  已保存 $savedCount 张图片');
      print('✓ 完成\n');
    } catch (e, stackTrace) {
      print('✗ 处理失败: $e');
      print('堆栈跟踪: $stackTrace\n');
    }
  }

  print('所有文件处理完成！');
}
