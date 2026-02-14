import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;
import 'models.dart';

/// EPUB 解析器
///
/// 用于从 EPUB 文件中提取标题和图片，并按照阅读顺序排序。
class EpubParser {
  /// 特殊图片关键词列表
  ///
  /// 包含这些关键词的图片文件名将保持原始文件名，不进行序号重命名。
  final List<String> specialImageKeywords;

  /// 创建 EPUB 解析器实例
  ///
  /// [specialImageKeywords] 自定义特殊图片关键词列表。
  /// 默认包含：cover, title, end, info, copyright, front, back, intro, preface, postscript, colophon
  EpubParser({
    List<String>? specialImageKeywords,
  }) : specialImageKeywords = specialImageKeywords ??
            [
              'cover',
              'title',
              'end',
              'info',
              'copyright',
              'front',
              'back',
              'intro',
              'preface',
              'postscript',
              'colophon',
            ];

  /// 从 EPUB 文件中提取标题和图片
  ///
  /// [epubFile] EPUB 文件路径或 File 对象
  /// 返回 [EpubExtractionResult] 包含标题和按顺序排列的图片列表
  ///
  /// 示例：
  /// ```dart
  /// final parser = EpubParser();
  /// final result = await parser.extract(File('book.epub'));
  /// print('标题: ${result.title}');
  /// print('图片数量: ${result.images.length}');
  /// ```
  Future<EpubExtractionResult> extract(dynamic epubFile) async {
    final file = epubFile is File ? epubFile : File(epubFile.toString());
    if (!await file.exists()) {
      throw Exception('EPUB 文件不存在: ${file.path}');
    }

    // 读取 EPUB 文件（ZIP 格式）
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 查找 container.xml
    final containerEntry = archive.findFile('META-INF/container.xml');
    if (containerEntry == null) {
      throw Exception('未找到 META-INF/container.xml');
    }

    // 解析 container.xml 获取 OPF 文件路径
    final containerXml = XmlDocument.parse(
      utf8.decode(containerEntry.content as List<int>),
    );
    final rootfile = containerXml.findAllElements('rootfile').first;
    final opfPath = rootfile.getAttribute('full-path');
    if (opfPath == null) {
      throw Exception('未找到 OPF 文件路径');
    }

    // 读取 OPF 文件
    final opfEntry = archive.findFile(opfPath);
    if (opfEntry == null) {
      throw Exception('未找到 OPF 文件: $opfPath');
    }

    final opfXml =
        XmlDocument.parse(utf8.decode(opfEntry.content as List<int>));

    // 提取标题
    var title = _extractTitle(opfXml);
    if (title.isEmpty) {
      // 如果无法从 OPF 提取标题，使用文件名（不含扩展名）
      title = path.basenameWithoutExtension(file.path);
    }

    // 提取图片并获取顺序
    final opfDir = path.dirname(opfPath);
    final orderedImages = await _extractOrderedImages(
      opfXml,
      opfDir,
      archive,
    );

    return EpubExtractionResult(
      title: title,
      images: orderedImages,
      archive: archive,
    );
  }

  /// 获取图片的字节数据
  ///
  /// [result] EPUB 提取结果
  /// [imageInfo] 图片信息
  ///
  /// 返回图片的字节数据（Uint8List），如果图片不存在则返回 null
  ///
  /// 示例（Flutter）：
  /// ```dart
  /// final imageData = parser.getImageData(result, result.images[0]);
  /// if (imageData != null) {
  ///   Image.memory(imageData)
  /// }
  /// ```
  Uint8List? getImageData(
    EpubExtractionResult result,
    ImageInfo imageInfo,
  ) {
    final imageEntry = result.archive.findFile(imageInfo.path);
    if (imageEntry != null) {
      return Uint8List.fromList(imageEntry.content as List<int>);
    }
    return null;
  }

  /// 获取所有图片的字节数据
  ///
  /// [result] EPUB 提取结果
  ///
  /// 返回一个 Map，键为图片路径，值为图片的字节数据
  ///
  /// 示例（Flutter）：
  /// ```dart
  /// final imagesData = parser.getAllImagesData(result);
  /// for (final entry in imagesData.entries) {
  ///   Image.memory(entry.value)
  /// }
  /// ```
  Map<String, Uint8List> getAllImagesData(EpubExtractionResult result) {
    final imagesData = <String, Uint8List>{};
    for (final imageInfo in result.images) {
      final imageData = getImageData(result, imageInfo);
      if (imageData != null) {
        imagesData[imageInfo.path] = imageData;
      }
    }
    return imagesData;
  }

  /// 保存提取的图片到指定目录
  ///
  /// [result] EPUB 提取结果
  /// [outputDir] 输出目录
  /// [useTitleAsFolder] 是否使用标题作为子文件夹名（默认 true）
  ///
  /// 返回保存的图片数量
  Future<int> saveImages(
    EpubExtractionResult result,
    Directory outputDir, {
    bool useTitleAsFolder = true,
  }) async {
    Directory bookOutputDir;

    if (useTitleAsFolder) {
      // 创建输出文件夹（使用标题作为文件夹名）
      final safeTitle = _sanitizeFileName(result.title);
      bookOutputDir = Directory(path.join(outputDir.path, safeTitle));
    } else {
      bookOutputDir = outputDir;
    }

    if (!await bookOutputDir.exists()) {
      await bookOutputDir.create(recursive: true);
    }

    // 按顺序保存图片并重命名
    int savedCount = 0;
    int sequenceNumber = 0; // 用于序号重命名的计数器

    for (final imageInfo in result.images) {
      try {
        final imageEntry = result.archive.findFile(imageInfo.path);
        if (imageEntry != null) {
          String outputFileName;

          // 判断是否需要保持原始文件名
          if (imageInfo.keepOriginalName) {
            // 保持原始文件名
            final originalName = path.basename(imageInfo.path);
            outputFileName = _sanitizeFileName(originalName);
          } else {
            // 使用序号重命名
            sequenceNumber++;
            final originalExt = path.extension(imageInfo.path);
            final paddedIndex = sequenceNumber.toString().padLeft(4, '0');
            outputFileName = '$paddedIndex$originalExt';
          }

          final outputPath = path.join(bookOutputDir.path, outputFileName);

          // 如果文件已存在，添加序号（仅对保持原始文件名的图片）
          var finalPath = outputPath;
          if (imageInfo.keepOriginalName && await File(finalPath).exists()) {
            var counter = 1;
            final ext = path.extension(outputFileName);
            final nameWithoutExt =
                path.basenameWithoutExtension(outputFileName);
            while (await File(finalPath).exists()) {
              finalPath = path.join(
                bookOutputDir.path,
                '${nameWithoutExt}_$counter$ext',
              );
              counter++;
            }
          }

          await File(finalPath).writeAsBytes(imageEntry.content as List<int>);
          savedCount++;
        }
      } catch (e) {
        // 静默处理错误，继续处理下一张图片
      }
    }

    return savedCount;
  }

  String _extractTitle(XmlDocument opfXml) {
    // 尝试从 metadata 中提取标题
    final metadata = opfXml.findAllElements('metadata').firstOrNull;
    if (metadata != null) {
      // 查找 dc:title
      final titleElements = metadata.findAllElements('title');
      for (final titleElement in titleElements) {
        final title = titleElement.text.trim();
        if (title.isNotEmpty) {
          return title;
        }
      }

      // 尝试查找带命名空间的 title
      final dcTitleElements = metadata.findAllElements('dc:title');
      for (final dcTitleElement in dcTitleElements) {
        final title = dcTitleElement.text.trim();
        if (title.isNotEmpty) {
          return title;
        }
      }
    }

    return '';
  }

  Future<List<ImageInfo>> _extractOrderedImages(
    XmlDocument opfXml,
    String opfDir,
    Archive archive,
  ) async {
    // 1. 构建 manifest 映射 (id -> item)
    final manifest = opfXml.findAllElements('manifest').firstOrNull;
    if (manifest == null) {
      return [];
    }

    final manifestMap = <String, Map<String, String>>{};
    final items = manifest.findAllElements('item');
    for (final item in items) {
      final id = item.getAttribute('id') ?? '';
      final href = item.getAttribute('href') ?? '';
      final mediaType = item.getAttribute('media-type') ?? '';
      if (id.isNotEmpty && href.isNotEmpty) {
        final itemPath = path.isAbsolute(href)
            ? href
            : path.normalize(path.join(opfDir, href));
        manifestMap[id] = {
          'href': itemPath.replaceAll('\\', '/'),
          'media-type': mediaType,
        };
      }
    }

    // 2. 获取 spine 顺序（阅读顺序）
    final spine = opfXml.findAllElements('spine').firstOrNull;
    if (spine == null) {
      // 如果没有 spine，回退到按 manifest 顺序提取所有图片
      return _extractImagesFromManifest(manifestMap);
    }

    final itemrefs = spine.findAllElements('itemref');
    final orderedImages = <ImageInfo>[];
    final processedImages = <String>{}; // 避免重复

    // 3. 按照 spine 顺序处理每个内容文件
    for (final itemref in itemrefs) {
      final idref = itemref.getAttribute('idref');
      if (idref == null || !manifestMap.containsKey(idref)) {
        continue;
      }

      final item = manifestMap[idref]!;
      final mediaType = item['media-type'] ?? '';

      // 只处理 HTML/XHTML 内容文件
      if (mediaType == 'application/xhtml+xml' ||
          mediaType == 'text/html' ||
          mediaType.contains('html')) {
        final contentPath = item['href']!;
        final imagesInContent = await _extractImagesFromContentFile(
          archive,
          contentPath,
          opfDir,
          processedImages,
          manifestMap,
        );
        orderedImages.addAll(imagesInContent);
      }
    }

    // 4. 如果 spine 中没有找到图片，回退到从 manifest 提取所有图片
    if (orderedImages.isEmpty) {
      return _extractImagesFromManifest(manifestMap);
    }

    return orderedImages;
  }

  List<ImageInfo> _extractImagesFromManifest(
    Map<String, Map<String, String>> manifestMap,
  ) {
    final images = <ImageInfo>[];
    for (final item in manifestMap.values) {
      final mediaType = item['media-type'] ?? '';
      if (mediaType.startsWith('image/')) {
        final imagePath = item['href']!;
        final keepOriginalName = _isSpecialImage(imagePath);
        images.add(
          ImageInfo(
            path: imagePath,
            mediaType: mediaType,
            keepOriginalName: keepOriginalName,
          ),
        );
      }
    }
    return images;
  }

  Future<List<ImageInfo>> _extractImagesFromContentFile(
    Archive archive,
    String contentPath,
    String opfDir,
    Set<String> processedImages,
    Map<String, Map<String, String>> manifestMap,
  ) async {
    final images = <ImageInfo>[];

    try {
      final contentEntry = archive.findFile(contentPath);
      if (contentEntry == null) {
        return images;
      }

      final content = utf8.decode(contentEntry.content as List<int>);
      final contentXml = XmlDocument.parse(content);

      // 查找所有 img 标签
      final imgElements = contentXml.findAllElements('img');
      for (final img in imgElements) {
        var src = img.getAttribute('src') ?? '';
        if (src.isEmpty) {
          // 尝试查找其他可能的属性
          src = img.getAttribute('xlink:href') ?? '';
        }

        if (src.isNotEmpty) {
          // 解析相对路径
          final imagePath = _resolveImagePath(src, contentPath, opfDir);
          final normalizedPath = imagePath.replaceAll('\\', '/');

          // 避免重复添加同一张图片
          if (!processedImages.contains(normalizedPath)) {
            processedImages.add(normalizedPath);

            // 从 manifest 中查找图片的媒体类型
            String mediaType = 'image/*';
            for (final item in manifestMap.values) {
              if (item['href'] == normalizedPath) {
                mediaType = item['media-type'] ?? 'image/*';
                break;
              }
            }

            // 判断是否是封面或特殊图片
            final keepOriginalName = _isSpecialImage(normalizedPath);

            images.add(
              ImageInfo(
                path: normalizedPath,
                mediaType: mediaType,
                keepOriginalName: keepOriginalName,
              ),
            );
          }
        }
      }
    } catch (e) {
      // 如果解析失败，跳过这个文件
    }

    return images;
  }

  String _resolveImagePath(String src, String contentPath, String opfDir) {
    // 移除 URL 片段（#anchor）
    var cleanSrc = src.split('#').first;

    // 移除查询参数
    cleanSrc = cleanSrc.split('?').first;

    // 处理 URL 编码
    try {
      cleanSrc = Uri.decodeComponent(cleanSrc);
    } catch (e) {
      // 如果解码失败，使用原始值
    }

    if (path.isAbsolute(cleanSrc)) {
      return cleanSrc;
    }

    // 相对于内容文件解析路径
    final contentDir = path.dirname(contentPath);
    final resolvedPath = path.normalize(path.join(contentDir, cleanSrc));
    return resolvedPath;
  }

  bool _isSpecialImage(String imagePath) {
    // 获取文件名（不包含路径）
    final fileName = path.basename(imagePath).toLowerCase();

    // 检查文件名是否包含特殊关键词
    for (final keyword in specialImageKeywords) {
      if (fileName.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  String _sanitizeFileName(String fileName) {
    // 移除或替换 Windows 文件名中的非法字符
    final illegalChars = RegExp(r'[<>:"/\\|?*]');
    var sanitized = fileName.replaceAll(illegalChars, '_');

    // 移除前后空格和点
    sanitized = sanitized.trim();
    while (sanitized.endsWith('.')) {
      sanitized = sanitized.substring(0, sanitized.length - 1);
    }

    // 限制长度（Windows 路径限制）
    if (sanitized.length > 200) {
      sanitized = sanitized.substring(0, 200);
    }

    return sanitized.isEmpty ? 'untitled' : sanitized;
  }
}
