//
//  FullscreenCoverFailureExampleView.swift
//  hero-transion
//
//  【失敗例】ウィンドウスナップショットを使わず、`fullScreenCover` の `presentationBackground(.clear)`
//  とごく薄い白オーバーレイのみで一覧を見せようとしたバリアント。
//  期待どおり透過できない環境がある・ヒーロー遷移の見え方の比較用として `ContentView`（正解法）とは切り離して置いている。
//

import SwiftUI

private struct FailureExampleColorTile: Identifiable, Hashable {
    let id: String
    var hueFraction: Double

    var fill: Color {
        Color(hue: hueFraction, saturation: 0.72, brightness: 0.93)
    }
}

private struct FailureExampleFullscreenOverlay: View {
    let tile: FailureExampleColorTile
    let namespace: Namespace.ID
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // 一覧を透過で見せる意図。clear でもシステム都合で不透明に見えることがある（失敗例の理由）。
            Color.white.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer(minLength: 0)
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
        .accessibilityLabel("選択した色の拡大表示（失敗例デモ）")
        .accessibilityHint("画面をタップして閉じます")
        .presentationBackground(.clear)
    }
}

/// スナップショット無しでの透過のみを試みる **失敗例** のデモ画面。
struct FullscreenCoverFailureExampleView: View {
    @Namespace private var heroNamespace

    @State private var selectedTile: FailureExampleColorTile?

    private let tiles: [FailureExampleColorTile] = (0 ..< 30).map { index in
        FailureExampleColorTile(id: "failure-fs-cover-tile-\(index)", hueFraction: Double(index) / 30.0)
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
                            selectedTile = tile
                        } label: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(tile.fill)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(id: tile.id, in: heroNamespace)
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
            FailureExampleFullscreenOverlay(
                tile: tile,
                namespace: heroNamespace,
                onDismiss: {
                    selectedTile = nil
                }
            )
            .interactiveDismissDisabled(true)
        }
    }

    private func colorAccessibilityLabel(for tile: FailureExampleColorTile) -> String {
        let deg = Int((tile.hueFraction * 360).rounded(.toNearestOrAwayFromZero))
        return "色ブロック \(deg)° 付近の色相"
    }
}
