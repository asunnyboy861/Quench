# Pricing Configuration

## Monetization Model: Freemium with Mixed IAP

Quench is free with two IAP categories: (1) a one-time Premium Lifetime unlock for core power features (photo diary, weather, rooms, export, themes), and (2) an AI Plant Doctor subscription (monthly/yearly) or AI Lifetime unlock for AI identification, diagnosis, and coaching features. AI features use a BYO (Bring Your Own) OpenAI API key model — the subscription unlocks the AI Hub UI, not AI usage counts.

## Subscription Group
- **Group Name**: Quench AI Plant Doctor
- **Reference Name**: Quench AI Plant Doctor
- **Products in group**: com.zzoutuo.Quench.ai.monthly, com.zzoutuo.Quench.ai.yearly

## Subscription Tiers

### 1. AI Monthly Subscription
- **Reference Name**: Quench AI Monthly
- **Product ID**: `com.zzoutuo.Quench.ai.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $1.99 USD per month
- **Display Name**: `AI Plant Doctor Monthly` (23 chars, ≤35 ✅)
- **Description**: `AI identification, diagnosis, coaching` (38 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Quench AI Plant Doctor
- **Restore Purchases**: ✅ Required

### 2. AI Yearly Subscription
- **Reference Name**: Quench AI Yearly
- **Product ID**: `com.zzoutuo.Quench.ai.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $9.99 USD per year (50% savings vs monthly)
- **Display Name**: `AI Plant Doctor Yearly` (22 chars, ≤35 ✅)
- **Description**: `Yearly AI identification and diagnosis` (39 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Quench AI Plant Doctor (same group as monthly)
- **Restore Purchases**: ✅ Required

### 3. Premium Lifetime Purchase (Non-consumable)
- **Reference Name**: Quench Premium Lifetime
- **Product ID**: `com.zzoutuo.Quench.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $3.99 USD (one-time)
- **Display Name**: `Quench Premium` (14 chars, ≤35 ✅)
- **Description**: `Photo diary, weather, rooms, themes, export` (43 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Note**: Unlocks core power features (non-AI). No ongoing server costs.

### 4. AI Lifetime Purchase (Non-consumable)
- **Reference Name**: Quench AI Lifetime
- **Product ID**: `com.zzoutuo.Quench.ai.lifetime`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $19.99 USD (one-time)
- **Display Name**: `AI Plant Doctor Lifetime` (24 chars, ≤35 ✅)
- **Description**: `Lifetime AI identification and diagnosis` (40 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required
- **Note**: BYO API Key model means zero ongoing API cost — lifetime unlock is sustainable. Recommended option for subscription-averse users.

## Free Tier

- **Price**: Free
- **Features**:
  - Unlimited plants (no cap, unlike Happy Plant's 3-plant limit)
  - Daily digest watering reminders (the core feature Greg locks behind paywall)
  - One-tap watering with animation + haptic (2-second rule)
  - Home screen widget with one-tap watering
  - 178+ species database with care profiles
  - Adaptive scheduling (season + soil check-in adjustments)
  - Watering history log
  - Streak tracking (light gamification)
  - Basic "why this schedule" explanation (season + soil factors)
  - Dark mode + light mode
- **Conversion hooks**:
  - Photo diary locked → "Unlock with Quench Premium" CTA on plant detail
  - Weather integration locked → "Why this schedule" mentions "(enable Weather for smarter schedules)"
  - AI buttons disabled → "Add your OpenAI API key + subscribe to unlock AI Plant Doctor"
  - Room management locked → "Organize plants by room with Premium"

## Pro Features Unlocked

| Feature | Free | Premium ($3.99) | AI Sub/Lifetime |
|---------|:----:|:---:|:---:|
| Unlimited plants | ✅ | ✅ | ✅ |
| Daily digest reminders | ✅ | ✅ | ✅ |
| One-tap watering + widget | ✅ | ✅ | ✅ |
| 178+ species database | ✅ | ✅ | ✅ |
| Adaptive schedule (season + soil) | ✅ | ✅ | ✅ |
| Watering history + streak | ✅ | ✅ | ✅ |
| Basic "why" explanation (season + soil) | ✅ | ✅ | ✅ |
| Photo diary & growth timeline | ❌ | ✅ | ✅ |
| Weather integration (WeatherKit) | ❌ | ✅ | ✅ |
| Room management (light + humidity) | ❌ | ✅ | ✅ |
| Full "why" explanation (+ weather + room) | ❌ | ✅ | ✅ |
| Custom notification time | ❌ | ✅ | ✅ |
| Data export / backup (JSON) | ❌ | ✅ | ✅ |
| Theme selection (light/dark/system) | ❌ | ✅ | ✅ |
| AI plant identification (BYO Key) | ❌ | ❌ | ✅ |
| AI health diagnosis (BYO Key) | ❌ | ❌ | ✅ |
| AI coach chat (BYO Key) | ❌ | ❌ | ✅ |

## BYO Key Model: AI Features

### Free Tier (with own API key but no AI subscription)
- AI Hub UI: ❌ Locked (buttons disabled with "Subscribe to unlock" message)
- AI generation: N/A (UI is locked, generation cannot be triggered)

### AI Subscription/Lifetime Unlocks
- AI Hub UI: ✅ Accessible
- AI generation: ✅ Unlimited (user's own OpenAI key — no counting, no limits)
- Subscription value: "Unlock AI Plant Doctor Interface" — NOT "Unlimited AI Generations"

### Key Compliance Notes
- `canGenerate` logic: `hasAISubscription && hasAPIKey` — never `canGenerateFree || isPremium`
- NO `freeGenerationsUsed`, `maxFreeGenerations`, `incrementGenerationCount()` in codebase
- AI generation is ALWAYS unlimited for users with their own key + AI subscription
- Paywall leads with "AI Plant Doctor features" — not "unlimited generations"

## Free Trial
- **Duration**: 7 days
- **Type**: Introductory offer (auto-converts to paid subscription after trial)
- **Available for**: AI Monthly and AI Yearly subscriptions
- **Trial behavior**: Full AI Hub access during trial (user must still configure their own OpenAI API key)

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions + API key setup guide)
- Privacy Policy: ✅ (must disclose: API keys in Keychain, photos sent to OpenAI from device, no Quench server)
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms; includes auto-renewal terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page
- [x] Pricing clearly stated in PaywallView
- [x] Free trial terms included (7-day introductory offer for AI subscriptions)
- [x] Restore purchases functionality implemented
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] BYO Key model: subscription unlocks UI features, not AI generation counts
- [x] No dead code for free generation counting
- [x] Paywall includes Privacy Policy + Terms of Use links (Guideline 3.1.2(c))
- [x] Auto-renewal disclosure text present in Paywall
