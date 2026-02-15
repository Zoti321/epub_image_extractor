import 'dart:io';
import 'package:epub_image_extractor/epub_image_extractor.dart';

/// 使用 epub_image_extractor 库提取 EPUB 元数据
void main() async {
  final rawDir = Directory('raw');

  if (!await rawDir.exists()) {
    print('错误: raw 文件夹不存在');
    return;
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
  print('=' * 80);

  final parser = EpubParser();

  for (int i = 0; i < epubFiles.length; i++) {
    final epubFile = epubFiles[i];
    try {
      print('\n[${i + 1}/${epubFiles.length}] ${epubFile.path.split(Platform.pathSeparator).last}');
      print('-' * 80);

      // 只提取元数据（更快）
      final metadata = await parser.extractMetadata(epubFile);

      // 输出元数据
      print('标题: ${metadata.title.isNotEmpty ? metadata.title : "(未设置)"}');
      
      if (metadata.creators.isNotEmpty) {
        print('作者: ${metadata.creators.join(", ")}');
      }
      
      if (metadata.contributors.isNotEmpty) {
        print('贡献者: ${metadata.contributors.join(", ")}');
      }
      
      if (metadata.description.isNotEmpty) {
        print('描述: ${metadata.description}');
      }
      
      if (metadata.publisher.isNotEmpty) {
        print('出版商: ${metadata.publisher}');
      }
      
      if (metadata.date.isNotEmpty) {
        print('发布日期: ${metadata.date}');
      }
      
      if (metadata.language.isNotEmpty) {
        print('语言: ${metadata.language}');
      }
      
      if (metadata.identifier.isNotEmpty) {
        print('标识符: ${metadata.identifier}');
      }
      
      if (metadata.subjects.isNotEmpty) {
        print('主题/标签: ${metadata.subjects.join(", ")}');
      }
      
      if (metadata.rights.isNotEmpty) {
        print('版权: ${metadata.rights}');
      }
      
      if (metadata.source.isNotEmpty) {
        print('来源: ${metadata.source}');
      }
      
      if (metadata.type.isNotEmpty) {
        print('类型: ${metadata.type}');
      }
      
      if (metadata.format.isNotEmpty) {
        print('格式: ${metadata.format}');
      }
      
      if (metadata.relation.isNotEmpty) {
        print('关联: ${metadata.relation}');
      }
      
      if (metadata.coverage.isNotEmpty) {
        print('覆盖范围: ${metadata.coverage}');
      }
      
      if (metadata.customMetadata.isNotEmpty) {
        print('自定义元数据:');
        for (final entry in metadata.customMetadata.entries) {
          print('  ${entry.key}: ${entry.value}');
        }
      }

      print('✓ 完成');
    } catch (e, stackTrace) {
      print('✗ 处理失败: $e');
      if (e.toString().contains('stack trace')) {
        print('堆栈跟踪: $stackTrace');
      }
    }
  }

  print('\n' + '=' * 80);
  print('所有文件处理完成！共处理 ${epubFiles.length} 个 EPUB 文件');
}
