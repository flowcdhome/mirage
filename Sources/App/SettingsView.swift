import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: TweakStore

    var body: some View {
        NavigationStack {
            List {
                Section("Display") {
                    VStack(alignment: .leading) {
                        HStack { Text("Stretch X"); Spacer(); Text(String(format: "%.2f", store.stretchX)).monospacedDigit() }
                        Slider(value: $store.stretchX, in: 0.6...1.6)
                    }
                    VStack(alignment: .leading) {
                        HStack { Text("Stretch Y"); Spacer(); Text(String(format: "%.2f", store.stretchY)).monospacedDigit() }
                        Slider(value: $store.stretchY, in: 0.6...1.6)
                    }
                    Button("Snap to 4:3") { store.snapStretch43() }
                    Button("Reset stretch") { store.resetStretch() }
                }

                Section {
                    ForEach(catalog) { t in
                        HStack(spacing: 14) {
                            Image(systemName: t.icon)
                                .font(.title3).frame(width: 30, height: 30)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: store.roundIcons ? 10 : 4))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.name).font(.subheadline).bold()
                                Text(t.summary).font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { store.enabled.contains(t.id) },
                                set: { _ in store.toggle(t) }))
                        }
                    }
                } header: {
                    Text("Tweaks")
                } footer: {
                    Text("Cosmetic only. Everything here changes Mirage's own UI, nothing outside this app and nothing on the real system.")
                }

                Section {
                    Button(role: .destructive) { store.respring() } label: {
                        Label("Respring", systemImage: "arrow.clockwise.circle.fill")
                    }
                }
            }
            .tint(store.accent)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { store.settingsOpen = false }
                }
            }
        }
    }
}
