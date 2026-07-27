//
//  AutoFitBoard_solva.swift
//  Solva
//
//  棋盘内容自适应缩放容器。
//  设计思路：部分棋盘（双金字塔、四季纸牌）内部使用较多固定尺寸元素拼装，
//  在不同机型的横屏可用高度/宽度下容易超出屏幕导致顶部 HUD 或底部内容被裁切。
//  本组件先以内容「自然尺寸」测量一次（通过 fixedSize + 背景 GeometryReader + PreferenceKey），
//  再计算「可用空间 / 自然尺寸」的缩放比例，用 scaleEffect 整体等比缩放，
//  从而保证棋盘内容永远完整可见、不越界，同时在大屏上也能等比放大而不显得局促。
//  关键属性：maxScale_solva（缩放上限，避免在超大屏幕上把卡牌放得过大）
//
import SwiftUI

private struct BoardNaturalSizeKey_solva: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next_solva = nextValue()
        if next_solva != .zero { value = next_solva }
    }
}

struct AutoFitBoard_solva<Content: View>: View {
    var maxScale_solva: CGFloat = 1.25
    @ViewBuilder let content_solva: () -> Content

    @State private var naturalSize_solva: CGSize = .zero

    var body: some View {
        GeometryReader { geo_solva in
            let scale_solva: CGFloat = {
                guard naturalSize_solva.width > 1, naturalSize_solva.height > 1 else { return 1 }
                let fit_solva = min(geo_solva.size.width / naturalSize_solva.width, geo_solva.size.height / naturalSize_solva.height)
                return min(fit_solva, maxScale_solva)
            }()

            content_solva()
                .fixedSize()
                .background(
                    GeometryReader { inner_solva in
                        Color.clear.preference(key: BoardNaturalSizeKey_solva.self, value: inner_solva.size)
                    }
                )
                .scaleEffect(scale_solva)
                .frame(width: geo_solva.size.width, height: geo_solva.size.height)
        }
        .onPreferenceChange(BoardNaturalSizeKey_solva.self) { size_solva in
            naturalSize_solva = size_solva
        }
    }
}
