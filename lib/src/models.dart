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

/// EPUB 元数据
class EpubMetadata {
  /// 标题
  final String title;

  /// 作者列表
  final List<String> creators;

  /// 贡献者列表
  final List<String> contributors;

  /// 描述
  final String description;

  /// 出版商
  final String publisher;

  /// 发布日期
  final String date;

  /// 语言
  final String language;

  /// 标识符（如 ISBN）
  final String identifier;

  /// 主题/标签列表
  final List<String> subjects;

  /// 版权信息
  final String rights;

  /// 来源
  final String source;

  /// 类型
  final String type;

  /// 格式
  final String format;

  /// 关联资源
  final String relation;

  /// 覆盖范围
  final String coverage;

  /// 其他自定义元数据（键值对）
  final Map<String, String> customMetadata;

  EpubMetadata({
    this.title = '',
    this.creators = const [],
    this.contributors = const [],
    this.description = '',
    this.publisher = '',
    this.date = '',
    this.language = '',
    this.identifier = '',
    this.subjects = const [],
    this.rights = '',
    this.source = '',
    this.type = '',
    this.format = '',
    this.relation = '',
    this.coverage = '',
    this.customMetadata = const {},
  });

  /// 获取主要作者（第一个作者）
  String get primaryCreator => creators.isNotEmpty ? creators.first : '';

  /// 是否有作者信息
  bool get hasCreator => creators.isNotEmpty;
}

/// EPUB 解析结果
class EpubExtractionResult {
  /// EPUB 元数据
  final EpubMetadata metadata;

  /// 提取的图片列表（按顺序）
  final List<ImageInfo> images;

  /// EPUB 文件的 ZIP 归档（用于获取图片数据）
  final Archive archive;

  EpubExtractionResult({
    required this.metadata,
    required this.images,
    required this.archive,
  });

  /// 获取标题（向后兼容）
  @Deprecated('使用 metadata.title 代替')
  String get title => metadata.title;
}
