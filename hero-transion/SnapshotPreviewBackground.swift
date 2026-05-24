//
//  SnapshotPreviewBackground.swift
//  hero-transion
//
//

import SwiftUI

struct SnapshotPreviewBackground: View {
    let snapshot: UIImage?

    var body: some View {
        ZStack {
            if let snapshot {
                Image(uiImage: snapshot)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        Color.white.opacity(0.3)
                    }
            } else {
                Color(.systemGroupedBackground)
            }
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Color.white.opacity(0.06)
                }
                .opacity(snapshot == nil ? 0.5 : 0.0)
                .animation(.easeInOut(duration: 0.2), value: snapshot != nil)
        }
        .ignoresSafeArea()
    }
}
