import 'package:archive/archive.dart';

/// EPUB 图片信息模型
class ImageInfo {
  /// 图片在 EPUB 中的路径
  final String path;

  /// 图片的媒体类型（如 image/jpeg, image/png）
  final String mediaType;

  /// 是否保持原始文件名（不进行序号重命名）
  final bool keepOriginalName;

  ImageInfo({
    required this.path,
    required this.mediaType,
    this.keepOriginalName = false,
  });
}

/// EPUB 解析结果
class EpubExtractionResult {
  /// 书籍标题
  final String title;

  /// 提取的图片列表（按顺序）
  final List<ImageInfo> images;

  /// EPUB 文件的 ZIP 归档（用于获取图片数据）
  final Archive archive;

  EpubExtractionResult({
    required this.title,
    required this.images,
    required this.archive,
  });
}
