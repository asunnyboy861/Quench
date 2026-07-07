import SwiftUI

struct ThemePickerView: View {
    @AppStorage("themePreference") private var themePreference: String = ThemeMode.system.rawValue

    var body: some View {
        Form {
            Section("Theme") {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button {
                        themePreference = mode.rawValue
                    } label: {
                        HStack {
                            Label(mode.rawValue, systemImage: iconFor(mode))
                            Spacer()
                            if themePreference == mode.rawValue {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppTheme.quenchBlue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Theme")
    }

    private func iconFor(_ mode: ThemeMode) -> String {
        switch mode {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}
