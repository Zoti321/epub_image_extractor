# GitHub 仓库设置指南

## 步骤 1: 在 GitHub 上创建仓库

1. 登录 GitHub
2. 点击右上角的 "+" 号，选择 "New repository"
3. 填写仓库信息：
   - **Repository name**: `epub_image_extractor`
   - **Description**: `EPUB 图片提取工具 - 从 EPUB 文件中提取标题和图片，支持按阅读顺序排序和智能重命名`
   - **Visibility**: 选择 Public（公开）或 Private（私有）
   - **不要**勾选 "Initialize this repository with a README"（因为本地已有文件）
4. 点击 "Create repository"

## 步骤 2: 初始化本地 Git 仓库

在项目目录下打开终端，执行以下命令：

```bash
# 1. 初始化 Git 仓库
git init

# 2. 添加所有文件到暂存区
git add .

# 3. 创建初始提交
git commit -m "Initial commit: EPUB image extractor package"
```

## 步骤 3: 连接到 GitHub 仓库

```bash
# 添加远程仓库（将 YOUR_USERNAME 替换为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/epub_image_extractor.git

# 或者使用 SSH（如果你配置了 SSH 密钥）
git remote add origin git@github.com:YOUR_USERNAME/epub_image_extractor.git
```

## 步骤 4: 推送代码到 GitHub

```bash
# 推送代码到 main 分支
git branch -M main
git push -u origin main
```

## 步骤 5: 更新 pubspec.yaml 中的仓库信息

推送成功后，更新 `pubspec.yaml` 中的仓库链接：

```yaml
homepage: https://github.com/YOUR_USERNAME/epub_image_extractor
repository: https://github.com/YOUR_USERNAME/epub_image_extractor
```

然后提交更改：

```bash
git add pubspec.yaml
git commit -m "Update repository URLs in pubspec.yaml"
git push
```

## 完整命令序列（一键执行）

如果你已经创建了 GitHub 仓库，可以一次性执行以下命令：

```bash
# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: EPUB image extractor package"

# 添加远程仓库（替换 YOUR_USERNAME）
git remote add origin https://github.com/YOUR_USERNAME/epub_image_extractor.git

# 设置主分支
git branch -M main

# 推送代码
git push -u origin main
```

## 后续更新代码

当你修改代码后，使用以下命令更新 GitHub：

```bash
# 查看更改
git status

# 添加更改的文件
git add .

# 提交更改
git commit -m "描述你的更改"

# 推送到 GitHub
git push
```

## 创建 Release 标签

发布新版本时，建议创建 Git 标签：

```bash
# 创建标签
git tag v1.0.0

# 推送标签到 GitHub
git push origin v1.0.0
```

在 GitHub 上，你可以：
1. 进入仓库页面
2. 点击右侧 "Releases"
3. 点击 "Create a new release"
4. 选择标签，填写发布说明

## 常见问题

### Q: 如果仓库已经存在文件怎么办？

A: 如果 GitHub 仓库已经初始化了 README，需要先拉取：

```bash
git pull origin main --allow-unrelated-histories
# 解决可能的冲突后
git push -u origin main
```

### Q: 如何验证远程仓库已连接？

A: 使用以下命令查看：

```bash
git remote -v
```

应该显示：
```
origin  https://github.com/YOUR_USERNAME/epub_image_extractor.git (fetch)
origin  https://github.com/YOUR_USERNAME/epub_image_extractor.git (push)
```

### Q: 忘记添加 .gitignore 中的文件怎么办？

A: 如果已经提交了不应该提交的文件（如 `output/`、`raw/`），可以：

```bash
# 从 Git 中移除但保留本地文件
git rm -r --cached output/
git rm -r --cached raw/

# 提交更改
git commit -m "Remove ignored files from repository"
git push
```

### Q: 如何添加 GitHub Actions 自动发布？

A: 可以创建 `.github/workflows/publish.yml` 文件来自动发布到 pub.dev（可选）

## 推荐的仓库设置

在 GitHub 仓库设置中建议：

1. **Topics（标签）**: 添加 `dart`, `flutter`, `epub`, `image-extraction`, `package`
2. **Description**: 填写清晰的描述
3. **Website**: 如果有，填写 pub.dev 的包页面链接
4. **Enable Issues**: 开启 Issues 功能，方便用户反馈
5. **Enable Discussions**: 可选，开启讨论功能

## 下一步

代码推送到 GitHub 后，你可以：

1. 在 README 中添加徽章（badges）
2. 设置 GitHub Pages（如果需要）
3. 配置 GitHub Actions 进行 CI/CD
4. 准备发布到 pub.dev
