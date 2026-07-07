# Quench — 配置文档

生成时间：2026-07-07

Bundle ID：`com.zzoutuo.Quench`

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**增强功能**。不配置这些项，Quench 仍可正常使用所有核心功能（植物管理、浇水提醒、浇水日志、AI 植物医生、Species 数据库等）。配置后可获得更精准的浇水调度（WeatherKit）、付费转化（IAP）和桌面小组件（Widget）。

---

### 🟡 Capabilities 增强配置

#### 1. WeatherKit（天气智能调度）

**增强功能**：根据当地高温/低温/降雨自动调整浇水间隔（如雨季自动延后、高温提前提醒）。
**不配置的影响**：`ScheduleEngine` 使用基础间隔 + 季节 + 房间湿度调整，App 完全正常运行，仅跳过天气因素。"Why this schedule" 说明文字中不显示天气因素。
**当前状态**：App 已使用基础调度方案作为默认实现，无需配置即可正常使用。

**已自动配置部分**：
- ✅ `WeatherService.swift` 代码已实现（带优雅降级）
- ✅ `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription` 已添加到 pbxproj
- ✅ `ScheduleEngine` 已支持 `WeatherData` 输入（未配置时传入 nil 跳过）

**如需启用增强功能，请手动配置**：
1. 打开 [Apple Developer Portal](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → **Identifiers**
2. 找到 `com.zzoutuo.Quench` → 点击编辑
3. 勾选 **WeatherKit Services** → 保存
4. 打开 Xcode → Quench 项目 → Quench target → **Signing & Capabilities**
5. 点击 **"+ Capability"** → 搜索 **WeatherKit** → 添加
6. 在 `Quench.entitlements` 中确认 `com.apple.developer.weatherkit` 已自动添加
7. ⚠️ 重新 Build 验证 — 启动 App 后 `WeatherService` 会自动获取位置并请求天气数据

---

#### 2. Widget Extension Target（桌面小组件）

**增强功能**：iOS 主屏幕/锁屏小组件显示"今日待浇水植物"列表和"一键浇水"按钮（App Intent）。
**不配置的影响**：App 内功能完全正常，仅无法在主屏幕添加 Widget。
**当前状态**：Widget 源代码已生成在 `Quench/QuenchWidget/` 目录下，但 Xcode 项目中尚未创建 Widget Extension target。

**已自动配置部分**：
- ✅ `QuenchWidget/QuenchWidget.swift` 代码已生成（包含 TimelineProvider、Entry View、Widget Configuration）
- ✅ `QuenchWidget/WidgetSharedStore.swift` 已实现 App Group 数据共享
- ✅ App Groups (`group.com.zzoutuo.Quench`) 已在主 App 的 entitlements 中配置
- ✅ `AppIntent` 一键浇水动作代码已生成

**如需启用增强功能，请手动配置**：
1. 打开 Xcode → Quench 项目 → **File → New → Target**
2. iOS → **Widget Extension** → Next
3. Product Name 填 `QuenchWidget`
4. ⚠️ **取消勾选** "Include Configuration App Intent"（代码已自带）
5. Language 选 Swift → Finish
6. Xcode 会询问 "Activate QuenchWidget scheme?" → 点击 **Activate**
7. 删除 Xcode 自动生成的 `QuenchWidget.swift`（保留我们生成的版本）
8. 将 `Quench/QuenchWidget/` 目录下的 2 个 Swift 文件拖入新的 QuenchWidget target
9. 在 QuenchWidget target 的 **Signing & Capabilities** 中：
   - 添加 **App Groups** → 勾选 `group.com.zzoutuo.Quench`
10. ⚠️ 重新 Build 验证 — 长按主屏幕 → 添加 Widget → 搜索 "Quench"

---

### 🔵 IAP StoreKit 配置（App Store Connect 产品创建）

**影响功能**：不创建 IAP 产品则用户无法完成 Premium 升级和 AI 订阅购买（免费核心功能不受影响）。

**已自动配置部分**：
- ✅ `PurchaseService.swift` 已实现 StoreKit 2 完整代码（购买、恢复、权益查询）
- ✅ 4 个 Product ID 代码中已硬编码：
  - `com.zzoutuo.Quench.lifetime`（Premium 终身 $3.99）
  - `com.zzoutuo.Quench.ai.monthly`（AI 月度订阅 $1.99/月，7 天免费试用）
  - `com.zzoutuo.Quench.ai.yearly`（AI 年度订阅 $9.99/年，7 天免费试用）
  - `com.zzoutuo.Quench.ai.lifetime`（AI 终身 $19.99）
- ✅ `SettingsView` 中已包含 "Restore Purchases" 按钮
- ✅ `Products.storekit` StoreKit Configuration File 已创建（路径：`Quench/Quench/Quench/Products.storekit`），用于 Xcode 模拟器本地测试
- ✅ PaywallView 已实现并在 App 内展示

**如需启用 IAP 正式购买，请手动配置**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com) → 你的 App → **Features** → **In-App Purchases**
2. 点击 **"+"** 创建以下 4 个产品：

| 产品类型 | Reference Name | Product ID | 价格 | 说明 |
|---------|---------------|-----------|------|------|
| Non-Consumable | Quench Premium | `com.zzoutuo.Quench.lifetime` | $3.99 | 高级功能终身解锁 |
| Auto-Renewable Subscription | AI Plant Doctor Monthly | `com.zzoutuo.Quench.ai.monthly` | $1.99/月 | AI 月度订阅（7 天免费试用） |
| Auto-Renewable Subscription | AI Plant Doctor Yearly | `com.zzoutuo.Quench.ai.yearly` | $9.99/年 | AI 年度订阅（7 天免费试用） |
| Non-Consumable | AI Plant Doctor Lifetime | `com.zzoutuo.Quench.ai.lifetime` | $19.99 | AI 功能终身解锁 |

3. ⚠️ 月度与年度订阅必须放在**同一个订阅组**中（如 "AI Plant Doctor"）
4. 为每个产品填写 Display Name 和 Description（从 `price.md` 复制）
5. 为月度/年度订阅添加 **7 天免费试用** Introductory Offer
6. 本地测试：Xcode → Edit Scheme → Run → Options → **StoreKit Configuration** 选择 `Products.storekit`
7. 在模拟器中点击 Paywall 测试购买流程
8. ⚠️ 创建后需要等待 Apple 审核（通常 1-2 小时生效）

---

### 🟢 App Store Connect 审核信息配置

**影响功能**：不配置则 Apple 审核员无法测试 AI 功能和订阅购买，可能导致 Guideline 2.1(a) 或 4.2 拒绝。

**配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com) → 你的 App → **App Review Information**
2. 在 **Notes** 字段中粘贴 `keytext.md` 中 "Review Notes" 部分的全部内容，包括：
   - BYO Key 模式说明（用户自带 OpenAI API Key）
   - China App Store 合规说明（不引用任何 AI 供应商品牌）
   - 4 个订阅产品 ID 列表
   - 测试用 API Key（⚠️ 你需要提供一个可用的 OpenAI API Key 供审核员测试 AI 功能）
3. 在 **Privacy Policy URL** 字段填写：`https://asunnyboy861.github.io/Quench/privacy.html`
4. 在 **Support URL** 字段填写：`https://asunnyboy861.github.io/Quench/support.html`
5. ⚠️ 如果 App Description 或 EULA 字段要求，填写 Terms of Use 链接：`https://asunnyboy861.github.io/Quench/terms.html`

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| App Groups (`group.com.zzoutuo.Quench`) | Widget 与主 App 数据共享所需 | ✅ 已配置 |
| Keychain Access Groups | BYO API Key 安全存储所需 | ✅ 已配置 |
| Outgoing Network Connections | 联系客服 + AI API 请求所需 | ✅ 已配置 |
| UserNotifications（本地） | 浇水提醒 daily digest，无需 APNs capability | ✅ 已配置（框架级） |
| SwiftData | 本地持久化存储（iOS 17+ 内置框架） | ✅ 已配置（框架级） |
| WidgetKit + App Intents | 一键浇水 Widget（框架级，target 需手动创建见上文） | ✅ 框架已就绪 |
| Camera Usage Description | 拍摄植物照片 | ✅ 已配置 |
| Photo Library Usage Description | 选择植物照片 | ✅ 已配置 |
| Photo Library Add Usage Description | 保存植物照片到相册 | ✅ 已配置 |
| Location When In Use Usage Description | WeatherKit 获取位置 | ✅ 已配置 |
| User Tracking Transparency Description | 透明度声明（App 实际不追踪） | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers 部署，地址：`https://feedback-board.iocompile67692.workers.dev` | ✅ 已部署 |
| NSAppTransportSecurity | 允许 HTTPS 出站连接，已在 Info.plist 配置 | ✅ 已配置 |
| GitHub Pages | 政策页面已部署 | ✅ 已配置 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | MVVM 架构，所有功能模块已生成（51 个 Swift 文件） | ✅ 已完成 |
| ContactSupportView | 7 主题选择、API 对接、网络权限 | ✅ 已完成 |
| SettingsView | 政策页面链接、客服入口、恢复购买按钮 | ✅ 已完成 |
| PurchaseService | StoreKit 2 集成（4 个产品 ID） | ✅ 已完成 |
| AI Module | 4 文件模块（AIConfiguration + OpenAIService + AIProfileManager + AISettingsViewModel） | ✅ 已完成 |
| WeatherService | 天气服务（带优雅降级） | ✅ 已完成 |
| ScheduleEngine | 浇水调度引擎（季节+房间+天气） | ✅ 已完成 |
| SpeciesDatabase | 50+ 室内植物物种数据库 | ✅ 已完成 |
| Widget 代码 | QuenchWidget 源代码已生成 | ✅ 已完成（target 需手动创建） |
| StoreKit Configuration File | `Products.storekit` 用于本地 IAP 测试 | ✅ 已完成 |
| QA 迭代 | iPhone 16 + iPad Pro 13-inch M5 构建验证 | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App 内操作即可）

**AI 功能**：App 已内置 AI 配置界面，用户下载后在 **Settings → AI Configuration** 中输入自己的 API Key 即可使用。支持 OpenAI / Google Gemini / DeepSeek / Anthropic (Claude) / 自定义端点。API Key 存储在 Keychain 中，不会上传服务器。这不是开发者配置步骤，用户按需在 App 内操作即可。

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | `https://github.com/asunnyboy861/Quench` 代码已推送 | ✅ 已完成 |
| GitHub Pages | `https://asunnyboy861.github.io/Quench/` 政策页面已部署 | ✅ 已完成 |
| Landing Page | 已部署（App Store ID 为占位符，发布后替换） | ✅ 已完成 |
| App Store 元数据 | `keytext.md` 已生成并验证（13 项检查全部通过） | ✅ 已完成 |
| 定价配置 | `price.md` 已生成（4 个 IAP 产品） | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。"Auto-Configured Capabilities" 和 "Manual Configuration Required" 的内容已重组到上方 Section 一 和 Section 二 中。

### Analysis

Based on operation guide and us.md analysis, Quench requires the following capabilities:

| Detected Requirement | Source Keyword | Capability |
|---------------------|----------------|------------|
| 拍照 / camera / 植物照片 | Guide §5.2, §7.5, us.md F#2, F#13, F#21 | Camera + Photo Library |
| 定位 / location / 天气 / WeatherKit | Guide §7.3, us.md F#15 | Location Services + WeatherKit |
| 通知 / notification / 提醒 / daily digest | Guide §7.4, us.md F#7 | UserNotifications (local) |
| 购买 / 订阅 / 会员 / premium / IAP | Guide §7.8, §8.2, us.md F#25, F#26 | In-App Purchase (StoreKit 2) |
| Widget / App Intent / 一键浇水 | Guide §7.6, us.md F#12 | App Groups (shared container) |
| API Key / OpenAI / BYO Key | Guide §7.7, us.md F#24 | Keychain (no capability needed) |
| SwiftData / 持久化 | Guide §7.2, us.md Architecture | None (framework, no capability) |

### No Configuration Needed

- **HealthKit**: App does not track health data
- **iCloud**: App is local-first (SwiftData on-device); iCloud sync not in v1 scope
- **Sign in with Apple**: App has no account system (local-first)
- **Siri**: Not in v1 scope
- **Apple Watch**: Not in v1 scope
- **Family Sharing**: Not in v1 scope
- **Background Modes**: Not needed — daily digest uses scheduled local notifications (`UNCalendarNotificationTrigger`), no background fetch required
- **Push Notifications (remote)**: Not needed for v1 — local notifications power the daily digest. Only required if remote push is desired in future.

### Verification

- **Build succeeded**: ✅ Verified at end of PHASE 6
  - iPhone 16 (iOS 26.4): Build successful, App launched (PID 37012), notification permission dialog displayed as expected
  - iPad Pro 13-inch M5 (iOS 26.4): Build successful, App launched (PID 39251), WelcomeView with "Get Started" button displayed as expected
- **All entitlements correct**: ✅ `Quench.entitlements` created with App Groups (`group.com.zzoutuo.Quench`) + Keychain Access Groups
- **All Info.plist usage descriptions added**: ✅ 5 descriptions added to pbxproj (Camera, Photo Library, Photo Library Add, Location When In Use, User Tracking)
- **CODE_SIGN_ENTITLEMENTS set in pbxproj**: ✅ Debug + Release configurations for main app target
- **WeatherKit entitlement**: ⏳ NOT in entitlements (manual config required — see Section 一)
- **In-App Purchase entitlement**: ⏳ NOT in entitlements (manual config required — see Section 一)
- **StoreKit Configuration File**: ✅ `Products.storekit` created with 4 products for local testing
