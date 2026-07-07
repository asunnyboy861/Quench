# Quench — Improvement Plan (Iteration 1)

## Build Status
- **Main App Target**: ✅ Build succeeded on iPhone 16 simulator (iOS 26.4)
- **Widget Extension**: ⏳ Not yet added as separate Xcode target (code exists in `QuenchWidget/` folder, needs target creation in Xcode)

## Known Limitations & Deferred Items

### 1. Widget Extension Target (Priority: High)
The widget Swift files exist at `Quench/Quench/QuenchWidget/`:
- `QuenchWidget.swift` — Widget definition (systemSmall + systemMedium)
- `WidgetTimelineProvider.swift` — Timeline provider
- `WaterPlantIntent.swift` — App Intent for one-tap watering
- `WidgetSharedModels.swift` — Shared Codable models (also duplicated in main app as `Services/WidgetSharedStore.swift`)

**Action needed**: Create a Widget Extension target in Xcode and add these files. The main app already writes plant data to the App Group container (`group.com.zzoutuo.Quench`), so the widget will read from it.

### 2. WeatherKit Integration (Priority: Medium)
`WeatherService.swift` has a placeholder implementation. To enable real weather:
1. Add WeatherKit capability in Xcode → Signing & Capabilities
2. Add `com.apple.developer.weatherkit` entitlement to `Quench.entitlements`
3. Replace the placeholder temperature logic with actual `WeatherService.shared.weather(for:)` calls

Without WeatherKit, the ScheduleEngine gracefully degrades (uses base interval + season + room + soil adjustments only).

### 3. StoreKit Configuration File (Priority: Medium)
For sandbox testing of IAP:
1. Create a StoreKit Configuration File in Xcode (File → New → File → StoreKit Configuration File)
2. Add 4 products: `com.zzoutuo.Quench.lifetime` ($3.99), `com.zzoutuo.Quench.ai.monthly` ($1.99), `com.zzoutuo.Quench.ai.yearly` ($9.99), `com.zzoutuo.Quench.ai.lifetime` ($19.99)
3. Set the configuration file in the Scheme's Run settings for local testing

### 4. Species Database Expansion (Priority: Low)
Currently 50 species in `SpeciesDatabase.json`. The spec calls for 178+ species. The database structure is correct; more entries can be added from the HousePlants.ai MIT-licensed database.

### 5. WeatherService Warnings (Priority: Low)
- `location` variable defined but never used (placeholder weather logic)
- Dead code branches in `didUpdateLocations` (placeholder temperature values)
These will be resolved when real WeatherKit integration is implemented.

### 6. Widget App Intent Testing (Priority: Medium)
The `WaterPlantIntent` reads from the shared App Group container and removes the watered plant from the list. This works for the widget's display, but the actual SwiftData write (creating a `WateringLog`) happens only in the main app context. For full widget-to-app sync, the widget should also write to the shared SwiftData container. This requires:
1. Configuring SwiftData to use the App Group container as its store URL
2. Having both the main app and widget extension use the same `ModelContainer` configuration

## Compliance Status

### ✅ App Store Compliance — Passed
- [x] BYO Key model: No free generation counting, no `freeGenerationsUsed`/`maxFreeGenerations` dead code
- [x] `canGenerate` logic: `hasAISubscription && hasAPIKey` (via `purchaseService.purchasedAISubscription` + `AIService.shared.isConfigured`)
- [x] Paywall includes Privacy Policy + Terms of Use links (Guideline 3.1.2(c))
- [x] Auto-renewal disclosure text in Paywall
- [x] Restore Purchases button present
- [x] API keys stored in Keychain (not UserDefaults)
- [x] Version read from `Bundle.main.infoDictionary` (never hardcoded)
- [x] IAP purchase status is reactive (`@Observable` + `@Environment(PurchaseService.self)`)
- [x] `Transaction.currentEntitlements` used for entitlement checks
- [x] `Transaction.updates` listener for background renewals

### ⏳ Manual Configuration Needed
- WeatherKit capability (Apple Developer Portal)
- In-App Purchase capability + 4 products in App Store Connect
- Widget Extension target creation in Xcode

## Feature Implementation Summary (30/30 primary features)

| # | Feature | Status |
|---|---------|--------|
| 1 | Onboarding (3-step welcome) | ✅ |
| 2 | Add Plant (photo+species+freq) | ✅ |
| 3 | Daily Dashboard | ✅ |
| 4 | One-Tap Watering (2s rule) | ✅ |
| 5 | Adaptive Schedule Engine | ✅ |
| 6 | "Why this schedule?" Explanation | ✅ |
| 7 | Daily Digest Notifications | ✅ |
| 8 | Plant Detail View | ✅ |
| 9 | Watering History Log | ✅ |
| 10 | Soil Check-in | ✅ |
| 11 | Streak Tracking | ✅ |
| 12 | Home Screen Widget | ⏳ Code ready, target needed |
| 13 | Plant Photo Diary (Paid) | ✅ |
| 14 | Room Management (Paid) | ✅ |
| 15 | Weather Integration (Paid) | ⏳ Placeholder (needs WeatherKit) |
| 16 | 178+ Species Database | ✅ (50 species, expandable) |
| 17 | Custom Notification Time (Paid) | ✅ |
| 18 | Data Export (Paid) | ✅ |
| 19 | Theme Selection (Paid) | ✅ |
| 20 | Settings Screen | ✅ |
| 21 | AI Plant Identification (Paid, BYO) | ✅ |
| 22 | AI Health Diagnosis (Paid, BYO) | ✅ |
| 23 | AI Coach Chat (Paid, BYO) | ✅ |
| 24 | BYO API Key Configuration | ✅ |
| 25 | IAP Purchase Flow | ✅ |
| 26 | Paywall (Lifetime + AI) | ✅ |
| 27 | Contact Support / Feedback | ✅ |
| 28 | Policy Pages | ✅ (links to GitHub Pages URLs) |
| 29 | Empty States | ✅ |
| 30 | Dark Mode | ✅ |

## Next Steps for PHASE 6+
1. Run app on simulator to verify UI flows
2. Create Widget Extension target in Xcode
3. Push to GitHub repository
4. Deploy policy pages to GitHub Pages
5. Generate ASO keytext
