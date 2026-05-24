//
//  ContentView.swift
//  hero-transion
//
//

import SwiftUI

private struct ColorTile: Identifiable, Hashable {
    let id: String
    var hueFraction: Double

    var fill: Color {
        Color(hue: hueFraction, saturation: 0.72, brightness: 0.93)
    }
}

private struct ColorTileFullscreenView: View {
    let tile: ColorTile
    let backgroundSnapshot: UIImage?
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            SnapshotPreviewBackground(snapshot: backgroundSnapshot)

            VStack(spacing: 20) {
                Spacer(minLength: 0)
                // 一覧セルからズームした「同色の大型カード」（PDF の代わり）
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(tile.fill)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.22), radius: 22, y: 14)
                Spacer()
            }
            .padding(24)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onDismiss)
        .navigationTransition(.zoom(sourceID: tile.id, in: namespace))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("選択した色の拡大表示")
        .accessibilityHint("画面をタップして閉じます")
    }
}

struct ContentView: View {
    @Namespace private var cardHeroNamespace

    /// `fullScreenCover(item:)` 用。タップされたセルを保持。
    @State private var selectedTile: ColorTile?
    /// 遷移直前ウィンドウのビットマップ。
    @State private var previewBackgroundSnapshot: UIImage?

    private let tiles: [ColorTile] = (0..<30).map { index in
        ColorTile(id: "tile-\(index)", hueFraction: Double(index) / 30.0)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 76), spacing: 12)]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(tiles) { tile in
                        Button {
                            // math と同順序: 先に同期的にキャプチャ → ボタン状態で遷移 → 非同期で State に反映。
                            let snapshot = WindowSnapshot.captureForPreviewBackground()
                            selectedTile = tile
                            DispatchQueue.main.async {
                                previewBackgroundSnapshot = snapshot
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(tile.fill)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: tile.id, in: cardHeroNamespace)
                        .accessibilityLabel(colorAccessibilityLabel(for: tile))
                        .accessibilityHint("タップして中央に表示")
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(item: $selectedTile) { tile in
            ColorTileFullscreenView(
                tile: tile,
                backgroundSnapshot: previewBackgroundSnapshot,
                namespace: cardHeroNamespace,
                onDismiss: {
                    selectedTile = nil
                    previewBackgroundSnapshot = nil
                }
            )
            .interactiveDismissDisabled(true)
        }
    }

    /// アクセシビリティ用の色相ラベル（簡易）。
    private func colorAccessibilityLabel(for tile: ColorTile) -> String {
        let deg = Int((tile.hueFraction * 360).rounded(.toNearestOrAwayFromZero))
        return "色ブロック \(deg)° 付近の色相"
    }
}

#Preview {
    ContentView()
}
