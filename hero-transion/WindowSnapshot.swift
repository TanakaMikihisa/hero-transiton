//
//  WindowSnapshot.swift
//  hero-transion
//
//

import UIKit

enum WindowSnapshot {
    /// 前面ウィンドウをキャプチャ（透過コンテンツより下のコンテキストを固定する）。
    /// `UIApplication` → `UIWindowScene` → `rootViewController.view.layer.render`。
    static func captureForPreviewBackground() -> UIImage? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let window = windowScene.windows.first(where: {
                $0.rootViewController != nil && $0.windowLevel == .normal
            })
        else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { context in
            window.rootViewController?.view.layer.render(in: context.cgContext)
        }
    }
}
