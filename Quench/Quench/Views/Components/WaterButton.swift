import SwiftUI

struct WaterButton: View {
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.mediumImpact()
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                Text("Water")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(AppTheme.quenchBlue)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WaterButton(action: {})
        .padding()
}
