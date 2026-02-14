# 发布指南

## 发布到 pub.dev 的步骤

### 1. 准备工作

#### 1.1 更新 pubspec.yaml

在发布前，请更新 `pubspec.yaml` 中的以下字段：

```yaml
homepage: https://github.com/YOUR_USERNAME/epub_image_extractor
repository: https://github.com/YOUR_USERNAME/epub_image_extractor
```

将 `YOUR_USERNAME` 替换为你的 GitHub 用户名。

#### 1.2 创建 GitHub 仓库（可选但推荐）

1. 在 GitHub 上创建一个新仓库
2. 将代码推送到仓库：
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/epub_image_extractor.git
git push -u origin main
```

#### 1.3 检查代码质量

运行以下命令检查代码：

```bash
# 格式化代码
dart format .

# 分析代码
dart analyze

# 运行测试（如果有）
dart test
```

### 2. 发布到 pub.dev

#### 2.1 登录 pub.dev

首先需要注册 pub.dev 账号并获取访问令牌：

1. 访问 https://pub.dev/
2. 使用 Google 账号登录
3. 进入账户设置，创建访问令牌（Access Token）

#### 2.2 配置发布凭据

```bash
# 配置 pub.dev 凭据
dart pub token add https://pub.dev
# 输入你的访问令牌
```

#### 2.3 验证包

在发布前，验证包是否符合要求：

```bash
# 检查包
dart pub publish --dry-run
```

这会检查：
- pubspec.yaml 格式
- 文件结构
- 依赖关系
- 许可证文件

#### 2.4 发布包

如果验证通过，执行发布：

```bash
dart pub publish
```

### 3. 发布后的维护

#### 3.1 更新版本

每次更新时，需要：

1. 更新 `pubspec.yaml` 中的版本号（遵循语义化版本）
2. 更新 `CHANGELOG.md`
3. 提交更改并创建 Git 标签：
```bash
git add .
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main --tags
```
4. 发布新版本：
```bash
dart pub publish
```

#### 3.2 版本号规则

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

例如：`1.0.0` → `1.0.1`（修复）→ `1.1.0`（新功能）→ `2.0.0`（重大变更）

## 本地使用（未发布时）

如果还没有发布到 pub.dev，可以通过以下方式在项目中使用：

### 方式 1: 使用路径依赖

在项目的 `pubspec.yaml` 中：

```yaml
dependencies:
  epub_image_extractor:
    path: ../epub_image_extractor  # 相对路径
    # 或
    path: /absolute/path/to/epub_image_extractor  # 绝对路径
```

### 方式 2: 使用 Git 依赖

如果代码在 Git 仓库中：

```yaml
dependencies:
  epub_image_extractor:
    git:
      url: https://github.com/YOUR_USERNAME/epub_image_extractor.git
      ref: main  # 或特定的 tag/commit
```

### 方式 3: 直接复制代码

将 `lib` 目录下的代码直接复制到你的项目中。

## 常见问题

### Q: 发布时提示 "Package name already taken"

A: 包名已被占用，需要修改 `pubspec.yaml` 中的 `name` 字段。

### Q: 如何撤销已发布的版本？

A: pub.dev 不允许删除已发布的版本，但可以发布新版本修复问题。

### Q: 发布后多久可以在 pub.dev 上搜索到？

A: 通常几分钟内就可以搜索到，但可能需要等待索引更新。

## 参考资源

- [pub.dev 发布指南](https://dart.dev/tools/pub/publish)
- [语义化版本](https://semver.org/lang/zh-CN/)
- [pub.dev 包评分标准](https://pub.dev/help/scoring)
