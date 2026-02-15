# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2025-01-XX

### Added
- ✨ 提取完整 EPUB 元数据：标题、作者、描述、日期、语言、出版商等
- 🖼️ 新增 `getCoverImage()` 方法：获取封面图片信息
- 🖼️ 新增 `getCoverImageData()` 方法：直接获取封面图片字节数据
- ⚡ 新增 `extractMetadata()` 方法：只提取元数据，不加载图片，性能更快
- 📊 完整的 `EpubMetadata` 模型，包含所有 EPUB 元数据字段

### Changed
- 🔄 `EpubExtractionResult` 现在包含完整的 `EpubMetadata` 对象
- 📝 更新了所有示例代码和文档

### Features
- 📖 提取完整 EPUB 元数据（标题、作者、描述、日期、语言等）
- 🖼️ 提取所有图片资源
- 📑 按 spine 和内容顺序排序
- 🏷️ 智能重命名系统
- 📎 保持封面和特殊图片原名
- 🎯 便捷的封面图片获取方法

## [1.0.0] - 2024-01-01

### Added
- 初始版本发布
- 从 EPUB 文件中提取标题和图片
- 按阅读顺序对图片进行排序
- 智能重命名：普通图片按序号重命名，封面和特殊图片保持原名
- 支持自定义特殊图片关键词
- 提供命令行工具
- 完整的 API 文档和示例

### Features
- 📖 提取 EPUB 标题
- 🖼️ 提取所有图片资源
- 📑 按 spine 和内容顺序排序
- 🏷️ 智能重命名系统
- 📎 保持封面和特殊图片原名
