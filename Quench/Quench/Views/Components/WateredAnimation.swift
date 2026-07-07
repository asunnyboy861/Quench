import SwiftUI

struct WateredAnimation: View {
    @Binding var isShown: Bool
    var onUndo: (() -> Void)? = nil

    @State private var droplets: [Droplet] = []
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showToast = false

    struct Droplet: Identifiable {
        let id = UUID()
        let angle: Double
        let distance: CGFloat
    }

    var body: some View {
        ZStack {
            if isShown {
                Color.clear
                    .overlay(alignment: .center) {
                        ZStack {
                            ForEach(droplets) { drop in
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.quenchBlue)
                                    .offset(
                                        x: cos(drop.angle) * drop.distance,
                                        y: sin(drop.angle) * drop.distance
                                    )
                                    .opacity(opacity)
                            }

                            Text("Quenched!")
                                .font(.headline)
                                .foregroundStyle(AppTheme.quenchBlue)
                                .scaleEffect(scale)
                        }
                    }

                if showToast, onUndo != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Text("Plant quenched 🌱")
                                .font(.subheadline)
                            Spacer()
                            Button("Undo") {
                                onUndo?()
                                withAnimation {
                                    isShown = false
                                }
                            }
                            .font(.subheadline.bold())
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onChange(of: isShown) { _, newValue in
            if newValue {
                trigger()
            }
        }
    }

    private func trigger() {
        droplets = (0..<8).map { i in
            Droplet(angle: Double(i) * .pi / 4, distance: 0)
        }
        scale = 0.5
        opacity = 1
        showToast = true

        withAnimation(.spring(duration: 0.6, bounce: 0.5)) {
            scale = 1.2
        }

        withAnimation(.easeOut(duration: 0.8)) {
            droplets = droplets.map { Droplet(angle: $0.angle, distance: 36) }
            opacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                scale = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                showToast = false
                isShown = false
            }
        }
    }
}
