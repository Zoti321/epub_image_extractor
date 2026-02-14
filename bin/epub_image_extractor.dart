#!/usr/bin/env dart

import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

/// EPUB 提取命令行工具
void main(List<String> args) async {
  if (args.isEmpty) {
    print('用法: epub_image_extractor <epub文件或目录> [输出目录]');
    print('');
    print('示例:');
    print('  epub_image_extractor book.epub');
    print('  epub_image_extractor book.epub output/');
    print('  epub_image_extractor raw/ output/');
    exit(1);
  }

  final inputPath = args[0];
  final outputPath = args.length > 1 ? args[1] : 'output';

  final inputEntity = FileSystemEntity.typeSync(inputPath);
  final outputDir = Directory(outputPath);

  // 确保输出目录存在
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final parser = EpubParser();
  List<File> epubFiles = [];

  if (inputEntity == FileSystemEntityType.directory) {
    // 如果是目录，查找所有 EPUB 文件
    final dir = Directory(inputPath);
    epubFiles = dir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.epub'))
        .toList();
  } else if (inputEntity == FileSystemEntityType.file) {
    final file = File(inputPath);
    if (file.path.toLowerCase().endsWith('.epub')) {
      epubFiles = [file];
    } else {
      print('错误: 输入文件不是 EPUB 文件');
      exit(1);
    }
  } else {
    print('错误: 输入路径不存在: $inputPath');
    exit(1);
  }

  if (epubFiles.isEmpty) {
    print('未找到 EPUB 文件');
    exit(1);
  }

  print('找到 ${epubFiles.length} 个 EPUB 文件\n');

  for (final epubFile in epubFiles) {
    try {
      print('正在处理: ${epubFile.path}');

      // 提取 EPUB
      final result = await parser.extract(epubFile);
      print('  标题: ${result.title}');
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
      if (args.contains('--verbose')) {
        print('堆栈跟踪: $stackTrace\n');
      } else {
        print('');
      }
    }
  }

  print('所有文件处理完成！');
}
