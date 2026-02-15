# 发布到 pub.dev 完整指南

## ✅ 预检查结果

你的包已经通过了验证检查：
- ✅ 包结构正确
- ✅ 所有必需文件存在
- ✅ 无警告或错误
- ✅ 压缩后大小：14 KB

## 发布步骤

### 步骤 1: 注册 pub.dev 账号

1. 访问 https://pub.dev/
2. 点击右上角 "Sign in"
3. 使用 **Google 账号**登录（pub.dev 只支持 Google 账号）
4. 完成账号注册

### 步骤 2: 成为 Publisher（发布者）

**重要：** pub.dev 现在要求先成为 Publisher 才能发布包。

#### 方式 A: 使用个人 Google 账号（推荐新手）

1. 登录 pub.dev 后，访问 https://pub.dev/create-publisher
2. 选择 "Create a verified publisher"
3. 输入 Publisher ID（如 `zoti321` 或 `epub-image-extractor`）
   - 只能包含小写字母、数字、连字符和下划线
   - 不能以连字符开头或结尾
4. 选择验证方式：
   - **使用 Google 账号**（最简单）：直接使用你的 Google 账号验证
   - **使用域名验证**：需要 Google Search Console 验证（见方式 B）

#### 方式 B: 使用 Google Search Console 验证（域名验证）

如果你有自己的域名（如 `yourdomain.com`），可以使用域名验证：

1. **在 Google Search Console 验证域名**
   - 访问 https://search.google.com/search-console
   - 添加你的域名（如 `yourdomain.com`）
   - 选择验证方式（推荐 HTML 文件上传或 DNS 记录）
   - 完成验证

2. **在 pub.dev 创建 Publisher**
   - 访问 https://pub.dev/create-publisher
   - 输入 Publisher ID
   - 选择 "Verify domain ownership"
   - 按照提示完成验证

**注意：** 如果没有自己的域名，使用方式 A（Google 账号验证）即可。

### 步骤 3: 获取访问令牌（Access Token）

成为 Publisher 后：

1. 登录 pub.dev，访问 https://pub.dev/account
2. 找到 "Uploaders" 或 "Access tokens" 部分
3. 点击 "Create token" 或 "Create uploader"
4. 选择你的 Publisher
5. 输入令牌名称（如 "epub_image_extractor"）
6. 复制生成的访问令牌（**只显示一次，请妥善保存**）

### 步骤 4: 配置本地凭据

在项目目录下执行：

```bash
dart pub token add https://pub.dev
```

然后粘贴你的访问令牌。

**验证配置：**
```bash
dart pub token list
```

应该显示 `https://pub.dev` 的令牌。

### 步骤 5: 最终验证

再次运行验证（确保一切就绪）：

```bash
dart pub publish --dry-run
```

确保看到：
- ✅ `Package has 0 warnings.`
- ✅ 所有文件列表正确

### 步骤 6: 发布包

如果验证通过，执行发布：

```bash
dart pub publish
```

**重要提示：**
- 发布前会显示将要上传的文件列表
- 确认无误后输入 `y` 继续
- 发布后**无法删除**，只能发布新版本

### 步骤 7: 确认发布

发布成功后：
1. 访问 https://pub.dev/packages/epub_image_extractor
2. 等待几分钟让索引更新
3. 可以在 pub.dev 上搜索到你的包

## 发布后的操作

### 1. 更新 GitHub 仓库

在 `pubspec.yaml` 中确保仓库链接正确（你已经设置了）：
```yaml
homepage: https://github.com/Zoti321/epub_image_extractor
repository: https://github.com/Zoti321/epub_image_extractor
```

### 2. 添加 pub.dev 徽章到 README

在 `README.md` 顶部添加：

```markdown
[![pub package](https://img.shields.io/pub/v/epub_image_extractor.svg)](https://pub.dev/packages/epub_image_extractor)
[![pub points](https://img.shields.io/pub/points/epub_image_extractor)](https://pub.dev/packages/epub_image_extractor/score)
```

### 3. 提交并推送更改

```bash
git add .
git commit -m "Prepare for pub.dev release"
git push
```

## 常见问题

### Q: 提示 "Package name already taken"

**A:** 包名 `epub_image_extractor` 可能已被占用。解决方案：
1. 检查 https://pub.dev/packages/epub_image_extractor 是否已存在
2. 如果存在，需要修改 `pubspec.yaml` 中的 `name` 字段
3. 建议使用更独特的名称，如 `epub_image_extractor_zoti` 或 `epub_img_extractor`

### Q: 提示 "You don't have permission to publish this package"

**A:** 可能的原因：
1. **未创建 Publisher** - 必须先创建 Publisher（见步骤 2）
2. 访问令牌配置错误 - 重新配置
3. 包名已被其他人占用 - 需要更换包名
4. 账号未完全激活 - 等待几分钟后重试

### Q: 提示需要 Google Search Console 验证

**A:** 
- 如果你选择域名验证，必须先在 Google Search Console 验证域名
- 如果不想验证域名，使用 Google 账号验证方式（更简单）
- 详细步骤请参考 `PUBLISHER_SETUP.md`

### Q: 发布后如何更新版本？

**A:** 
1. 更新 `pubspec.yaml` 中的版本号（如 `1.0.0` → `1.0.1`）
2. 更新 `CHANGELOG.md`
3. 提交更改：
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

### Q: 可以删除已发布的版本吗？

**A:** 不可以。pub.dev 不允许删除已发布的版本，但可以：
- 发布新版本修复问题
- 在 README 中标注已弃用
- 联系 pub.dev 管理员（特殊情况）

## 发布检查清单

发布前确认：

- [x] ✅ `pubspec.yaml` 配置正确
- [x] ✅ `LICENSE` 文件存在
- [x] ✅ `README.md` 完整
- [x] ✅ `CHANGELOG.md` 存在
- [x] ✅ 代码通过 `dart analyze`
- [x] ✅ 代码通过 `dart format`
- [x] ✅ `dart pub publish --dry-run` 无警告
- [ ] ⏳ 已注册 pub.dev 账号
- [ ] ⏳ 已获取访问令牌
- [ ] ⏳ 已配置本地凭据
- [ ] ⏳ GitHub 仓库已创建并推送

## 快速发布命令序列

```bash
# 1. 格式化代码
dart format .

# 2. 分析代码
dart analyze

# 3. 验证包
dart pub publish --dry-run

# 4. 如果验证通过，发布
dart pub publish
```

## 发布后的推广

发布成功后，可以考虑：

1. **在 README 中添加徽章** - 显示包版本和评分
2. **在 GitHub 仓库添加 Topics** - 如 `dart`, `flutter`, `epub`, `package`
3. **分享到社区** - 在相关论坛或社区分享
4. **持续维护** - 及时回复 Issues 和 PR

## 相关文档

- 📖 [Publisher 设置详细指南](PUBLISHER_SETUP.md) - 如何创建和验证 Publisher
- 📖 [集成指南](INTEGRATION.md) - 如何在项目中使用此包
- 📖 [GitHub 设置指南](GITHUB_SETUP.md) - 如何推送到 GitHub

## 参考链接

- [pub.dev 官方发布指南](https://dart.dev/tools/pub/publish)
- [pub.dev Publisher 指南](https://dart.dev/tools/pub/publishing#publishers)
- [Google Search Console](https://search.google.com/search-console)
- [pub.dev 包评分标准](https://pub.dev/help/scoring)
- [语义化版本规范](https://semver.org/lang/zh-CN/)
