# Publisher 设置详细指南

## 什么是 Publisher？

Publisher（发布者）是 pub.dev 用来标识包所有者的身份。每个包都必须关联一个 Publisher。

## 创建 Publisher 的两种方式

### 方式 1: 使用 Google 账号验证（推荐）

**适合：** 个人开发者，没有自己的域名

**步骤：**

1. 访问 https://pub.dev/create-publisher
2. 输入 Publisher ID（例如：`zoti321` 或 `epub-image-extractor`）
   - 只能包含：小写字母、数字、连字符（-）、下划线（_）
   - 不能以连字符开头或结尾
   - 长度：3-64 个字符
3. 选择 "Verify with Google account"
4. 使用你的 Google 账号完成验证
5. 完成！现在你是 Publisher 了

**优点：**
- ✅ 简单快速
- ✅ 无需域名
- ✅ 适合个人项目

### 方式 2: 使用 Google Search Console 验证（域名验证）

**适合：** 有自己域名的开发者或组织

**步骤：**

#### 2.1 在 Google Search Console 验证域名

1. **访问 Google Search Console**
   - 打开 https://search.google.com/search-console
   - 使用你的 Google 账号登录

2. **添加属性（Property）**
   - 点击 "添加属性"
   - 选择 "域名" 类型（不是 URL 前缀）
   - 输入你的域名（如 `yourdomain.com`）
   - 点击 "继续"

3. **验证域名所有权**
   
   推荐方法：**DNS 记录验证**
   - 选择 "DNS 记录" 验证方式
   - 复制 Google 提供的 TXT 记录
   - 在你的域名 DNS 设置中添加该 TXT 记录
   - 等待 DNS 传播（通常几分钟到几小时）
   - 在 Google Search Console 中点击 "验证"

   或者使用 **HTML 文件验证**：
   - 下载 Google 提供的 HTML 验证文件
   - 将文件上传到你的网站根目录
   - 确保可以通过 `https://yourdomain.com/googlexxxxx.html` 访问
   - 在 Google Search Console 中点击 "验证"

4. **验证成功**
   - 看到 "验证成功" 提示
   - 现在你拥有该域名的验证权限

#### 2.2 在 pub.dev 创建 Publisher

1. 访问 https://pub.dev/create-publisher
2. 输入 Publisher ID
3. 选择 "Verify domain ownership"
4. 输入你的域名（如 `yourdomain.com`）
5. pub.dev 会检查 Google Search Console 中的验证状态
6. 如果域名已验证，Publisher 创建成功

**优点：**
- ✅ 更专业
- ✅ 适合组织或公司
- ✅ 可以多人管理

## Publisher ID 命名建议

好的 Publisher ID 示例：
- ✅ `zoti321` - 使用 GitHub 用户名
- ✅ `epub-image-extractor` - 使用项目相关名称
- ✅ `my-company` - 公司名称
- ✅ `dart-dev` - 描述性名称

不好的 Publisher ID 示例：
- ❌ `-zoti321` - 不能以连字符开头
- ❌ `zoti321-` - 不能以连字符结尾
- ❌ `Zoti321` - 不能包含大写字母
- ❌ `zoti 321` - 不能包含空格

## 常见问题

### Q: 我没有域名，可以发布包吗？

**A:** 可以！使用方式 1（Google 账号验证）即可，无需域名。

### Q: Publisher ID 可以修改吗？

**A:** 不可以。Publisher ID 一旦创建就无法修改，请谨慎选择。

### Q: 一个 Google 账号可以创建多个 Publisher 吗？

**A:** 可以，但每个 Publisher 需要不同的 ID。

### Q: 创建 Publisher 后多久可以发布包？

**A:** 创建成功后立即可用，无需等待。

### Q: Google Search Console 验证需要多长时间？

**A:** 
- DNS 记录验证：几分钟到几小时（取决于 DNS 传播速度）
- HTML 文件验证：通常几分钟内完成

### Q: 如果域名验证失败怎么办？

**A:** 
1. 检查 DNS 记录是否正确添加
2. 等待 DNS 传播完成（最多 48 小时）
3. 确认域名可以正常访问
4. 重新尝试验证

## 下一步

创建 Publisher 成功后：

1. 获取访问令牌（Access Token）
2. 配置本地凭据
3. 发布你的包

详细步骤请参考 `PUBLISH_TO_PUBDEV.md`。
