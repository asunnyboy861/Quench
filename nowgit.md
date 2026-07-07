# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Quench |
| **Git URL** | git@github.com:asunnyboy861/Quench.git |
| **Repo URL** | https://github.com/asunnyboy861/Quench |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Quench/ | ⏳ Pending |
| Support | https://asunnyboy861.github.io/Quench/support.html | ⏳ Pending |
| Privacy Policy | https://asunnyboy861.github.io/Quench/privacy.html | ⏳ Pending |
| Terms of Use | https://asunnyboy861.github.io/Quench/terms.html | ⏳ Pending |

## Repository Structure

```
Quench/
├── Quench/                        # iOS App Source Code
│   ├── Quench.xcodeproj/          # Xcode Project
│   ├── Quench/                    # Swift Source Files
│   │   ├── App/                   # App entry point (QuenchApp.swift)
│   │   ├── Models/                # SwiftData models (Plant, Room, WateringLog, PlantPhoto, CareProfile)
│   │   ├── Services/              # Services (AIService, PurchaseService, NotificationService, etc.)
│   │   ├── ViewModels/            # MVVM ViewModels (@Observable)
│   │   ├── Views/                 # SwiftUI Views (Dashboard, PlantDetail, AIHub, Settings, Paywall)
│   │   ├── Utils/                 # Theme, DateExtensions, Haptics
│   │   ├── Resources/             # SpeciesDatabase.json (50 species)
│   │   └── Quench.entitlements    # App Groups + Keychain
│   └── QuenchWidget/              # Widget Extension source (pending target creation)
├── docs/                          # Policy Pages (GitHub Pages source — deployed in PHASE 7)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md                          # English development guide
├── capabilities.md                # iOS capabilities reference
├── icon.md                        # App icon documentation
├── price.md                       # IAP product definitions
├── improvement_plan_1.md          # Build status + feature tracking
├── nowgit.md                      # This file
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
├── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore — confidential competitor analysis)
└── .gitignore
```

## Build Verification

| Simulator | Build | Run | Notes |
|-----------|-------|-----|-------|
| iPhone 16 (iOS 26.4) | ✅ Succeeded | ✅ Launched (PID 37012) | Onboarding notification permission view shown |
| iPad Pro 13-inch (M5) (iOS 26.4) | ✅ Succeeded | ✅ Launched (PID 39251) | WelcomeView "Get Started" button shown |

## Notes

- App uses SwiftData with default store (not App Group container for primary data)
- Widget Extension target pending creation in Xcode (source code exists in `Quench/Quench/QuenchWidget/`)
- WeatherKit capability pending — WeatherService currently uses placeholder logic with graceful degradation
- StoreKit configuration file pending for sandbox IAP testing
- Species database contains 50 species (spec calls for 178+)
