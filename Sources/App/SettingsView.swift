import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: TweakStore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings").font(.title2).bold()
                Spacer()
                Button("Done") { store.closeApp() }
            }
            .padding()
            .background(.ultraThinMaterial)

            List {
                Section {
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
                } header: {
                    Text("Display")
                } footer: {
                    Text("Settings is a real app now, so it stretches too, and every gesture zone follows the stretch.")
                }

                Section {
                    Toggle("Use custom icon color", isOn: $store.useCustomIconColor)
                    if store.useCustomIconColor {
                        ColorPicker("Icon color", selection: $store.iconColor, supportsOpacity: false)
                    }
                } header: {
                    Text("Icons")
                }

                if store.classicHomeButton {
                    Section {
                        VStack(alignment: .leading) {
                            HStack { Text("Home button height"); Spacer(); Text("\(Int(store.homeButtonBarHeight)) pt").monospacedDigit() }
                            Slider(value: $store.homeButtonBarHeight, in: 60...170, step: 1)
                        }
                    } header: {
                        Text("Classic Home Button")
                    } footer: {
                        Text("Raises the button bar if it sits too low to tap comfortably.")
                    }
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
            .listStyle(.insetGrouped)
        }
        .tint(store.accent)
        .background(Color(.systemBackground))
    }
}
