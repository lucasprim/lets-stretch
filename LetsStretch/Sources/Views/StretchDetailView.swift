import SwiftUI

struct StretchDetailView: View {
    let stretch: Stretch
    var onDone: () -> Void = {}
    var onSkip: () -> Void = {}
    var onStartSession: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            Divider()
            instructionsList
            Spacer()
            actionButtons
        }
        .padding(20)
        .frame(width: 320, height: 420)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                stretchIcon
                Text(stretch.name)
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Text(stretch.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(stretch.targetArea.capitalized, systemImage: "figure.stand")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(
                    "\(stretch.durationSeconds)s",
                    systemImage: "timer"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Label(
                    stretch.category.displayName,
                    systemImage: stretch.category == .deskFriendly
                        ? "chair.fill" : "figure.yoga"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var stretchIcon: some View {
        Image(systemName: iconName(for: stretch.targetArea))
            .font(.title)
            .foregroundStyle(Color.accentColor)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
            )
    }

    private var instructionsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How to do it")
                .font(.headline)
                .fontWeight(.medium)

            ForEach(Array(stretch.instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.accentColor))

                    Text(instruction)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Skip", action: onSkip)
                .buttonStyle(.bordered)

            Button("Start Session", action: onStartSession)
                .buttonStyle(.bordered)

            Button("Done! I stretched", action: onDone)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    // MARK: - Helpers

    private func iconName(for targetArea: String) -> String {
        switch targetArea {
        case "neck": return "person.and.arrow.left.and.arrow.right"
        case "shoulders": return "figure.arms.open"
        case "wrists": return "hand.raised"
        case "back": return "figure.cooldown"
        case "chest": return "figure.arms.open"
        case "hips": return "figure.walk"
        case "legs": return "figure.run"
        default: return "figure.cooldown"
        }
    }
}

#Preview {
    StretchDetailView(
        stretch: Stretch(
            id: "preview-stretch",
            name: "Neck Tilt Stretch",
            description: "Gently stretches the side neck muscles to relieve tension from computer work.",
            instructions: [
                "Sit up straight with shoulders relaxed.",
                "Slowly tilt your head toward your right shoulder.",
                "Use your right hand to gently apply additional pressure.",
                "Hold for 10 seconds, then repeat on the left side."
            ],
            durationSeconds: 20,
            category: .deskFriendly,
            targetArea: "neck"
        )
    )
}
