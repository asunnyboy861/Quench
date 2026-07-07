# Capabilities Configuration

## Analysis
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

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| App Groups (`group.com.zzoutuo.Quench`) | ✅ Configured | Added to `Quench.entitlements` + `CODE_SIGN_ENTITLEMENTS` in pbxproj |
| Keychain Access Groups | ✅ Configured | Added to `Quench.entitlements` (for BYO API key storage) |
| Camera Usage Description | ✅ Configured | `INFOPLIST_KEY_NSCameraUsageDescription` in pbxproj |
| Photo Library Usage Description | ✅ Configured | `INFOPLIST_KEY_NSPhotoLibraryUsageDescription` in pbxproj |
| Photo Library Add Usage Description | ✅ Configured | `INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription` in pbxproj |
| Location When In Use Usage Description | ✅ Configured | `INFOPLIST_KEY_NSLocationWhenInUseUsageDescription` in pbxproj |
| User Tracking Transparency Description | ✅ Configured | `INFOPLIST_KEY_NSUserTrackingUsageDescription` in pbxproj (transparency only — app does NOT track) |
| UserNotifications (local) | ✅ No capability needed | Framework — runtime permission request only (no APNs capability required for local notifications) |
| WidgetKit + App Intents | ✅ No capability needed | Framework — Widget extension target added during code generation (PHASE 4+5) |
| SwiftData | ✅ No capability needed | Framework — built into iOS 17+ |

## Manual Configuration Required

| Capability | Status | Steps | Graceful Degradation |
|------------|--------|-------|---------------------|
| **WeatherKit** | ⏳ Pending | 1. Open Xcode → Quench target → Signing & Capabilities → "+ Capability" → search "WeatherKit"<br>2. Add `com.apple.developer.weatherkit` entitlement to Quench.entitlements<br>3. Enable WeatherKit service in Apple Developer Portal (requires paid Apple Developer Program)<br>4. App will use `WeatherService.swift` only when entitlement is present | ✅ App works without WeatherKit — `ScheduleEngine` uses base interval + season + room adjustments only (skips weather adjustment). "Why this schedule" text omits weather factors. |
| **In-App Purchase** | ⏳ Pending | 1. Open Xcode → Quench target → Signing & Capabilities → "+ Capability" → "In-App Purchase"<br>2. Create 4 products in App Store Connect:<br>   • `com.quench.lifetime` ($3.99, non-consumable)<br>   • `com.quench.ai.monthly` ($1.99, auto-renewable, 7-day intro trial)<br>   • `com.quench.ai.yearly` ($9.99, auto-renewable, 7-day intro trial)<br>   • `com.quench.ai.lifetime` ($19.99, non-consumable)<br>3. For sandbox testing: create StoreKit configuration file in Xcode (File → New → StoreKit Configuration File) with the 4 product IDs | ✅ App works without IAP — all paid features stay locked, free core (reminders + watering + widget) fully functional. `PurchaseService` returns `purchasedLifetime = false` when StoreKit has no products. |
| **Push Notifications** (optional) | ⏳ Optional | Only needed if remote push is desired in future. Local daily digest notifications work WITHOUT this capability. To enable: Xcode → Signing & Capabilities → "+ Capability" → "Push Notifications". Requires APNs key in Apple Developer Portal. | ✅ Not needed for v1 — local notifications (UNCalendarNotificationTrigger) power the daily digest. |

## No Configuration Needed
- **HealthKit**: App does not track health data
- **iCloud**: App is local-first (SwiftData on-device); iCloud sync not in v1 scope
- **Sign in with Apple**: App has no account system (local-first)
- **Siri**: Not in v1 scope
- **Apple Watch**: Not in v1 scope
- **Family Sharing**: Not in v1 scope
- **Background Modes**: Not needed — daily digest uses scheduled local notifications, no background fetch required

## Verification
- Build succeeded after configuration: ⏳ Pending (will verify at end of PHASE 2)
- All entitlements correct: ✅ (Quench.entitlements created with App Groups + Keychain)
- All Info.plist usage descriptions added: ✅ (5 descriptions added to pbxproj)
- CODE_SIGN_ENTITLEMENTS set in pbxproj: ✅ (Debug + Release for main app target)

## Summary
- **Auto-configured**: 10 capabilities (App Groups, Keychain, 5 Info.plist descriptions, 3 framework-only)
- **Manual configuration needed**: 2 capabilities (WeatherKit, In-App Purchase) — both gracefully degrade
- **App fully functional without manual config**: ✅ (free core features work immediately)
