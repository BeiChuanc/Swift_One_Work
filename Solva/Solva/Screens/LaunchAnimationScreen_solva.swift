//
//  LaunchAnimationScreen_solva.swift
//  Solva
//
//  App 启动加载动画页面。
//  设计思路：替代冷启动瞬间的纯色/白屏空窗期——用「发牌」为主题的趣味动效：
//  4 张牌从桌面下方飞入并展开成扇形，随后品牌铭牌 SOLVA 带弹性回弹效果登场，
//  副标题与底部「洗牌中」波浪式加载点依次浮现，整体节奏轻快、贴合纸牌游戏气质，
//  比静态背景更有生命力。展示时长固定，结束后由 ContentView 负责淡出切换到正式首页。
//  关键属性：cardsRevealed_solva（4 张牌的入场状态）、logoRevealed_solva/captionRevealed_solva
//  （铭牌/副标题登场状态）
//  关键方法：runSequence_solva（按时间线依次触发各阶段动画）
import SwiftUI

struct LaunchAnimationScreen_solva: View {
    /// 4 张展示牌，覆盖四种花色，视觉上呼应「集齐全部花色」的开场氛围
    private let showcaseCards_solva: [Card_solva] = [
        Card_solva(suit: .spades, rank: .ace, isFaceUp: true),
        Card_solva(suit: .hearts, rank: .king, isFaceUp: true),
        Card_solva(suit: .clubs, rank: .queen, isFaceUp: true),
        Card_solva(suit: .diamonds, rank: .jack, isFaceUp: true)
    ]

    /// 每张牌各自是否已完成入场（用于驱动逐张飞入的交错动画）
    @State private var cardsRevealed_solva: [Bool] = [false, false, false, false]
    /// 品牌铭牌 SOLVA 是否已登场
    @State private var logoRevealed_solva = false
    /// 副标题文案是否已登场
    @State private var captionRevealed_solva = false
    /// 底部加载点的呼吸相位（持续循环，独立于入场时间线）
    @State private var dotsBreathing_solva = false

    var body: some View {
        ZStack {
            CasinoFeltBackground_solva(tint_solva: Palette_solva.gold_solva, intensity_solva: 0.2)
                .ignoresSafeArea()

            VStack(spacing: 26) {
                Spacer()

                cardFan_solva
                    .frame(height: 140)

                VStack(spacing: 6) {
                    Text("SOLVA")
                        .font(.casinoDisplay_solva(38))
                        .casinoTracked_solva(4)
                        .foregroundStyle(Palette_solva.textPrimary_solva)
                        .scaleEffect(logoRevealed_solva ? 1 : 0.5)
                        .opacity(logoRevealed_solva ? 1 : 0)

                    Text("PRIVATE CARD ROOM")
                        .font(.casinoLabel_solva(11))
                        .casinoTracked_solva(3)
                        .foregroundStyle(Palette_solva.gold_solva.alpha_solva(0.85))
                        .opacity(captionRevealed_solva ? 1 : 0)
                        .offset(y: captionRevealed_solva ? 0 : 6)
                }

                Spacer()

                VStack(spacing: 10) {
                    loadingDots_solva
                    Text("SHUFFLING THE DECK…")
                        .font(.casinoLabel_solva(9))
                        .casinoTracked_solva(2)
                        .foregroundStyle(Palette_solva.textSecondary_solva)
                        .opacity(captionRevealed_solva ? 1 : 0)
                }
                .padding(.bottom, 34)
            }
        }
        .onAppear { runSequence_solva() }
    }

    /// 4 张牌从桌面下方交错飞入，最终在中心展开成扇形
    private var cardFan_solva: some View {
        ZStack {
            ForEach(Array(showcaseCards_solva.enumerated()), id: \.offset) { index_solva, card_solva in
                let revealed_solva = cardsRevealed_solva[index_solva]
                let fanOffsetX_solva: CGFloat = CGFloat(index_solva - showcaseCards_solva.count / 2) * 40 + 20
                let fanRotation_solva: Double = Double(index_solva - showcaseCards_solva.count / 2) * 12 + 6

                PlayingCardView_solva(card_solva: card_solva, width_solva: 74)
                    .rotationEffect(.degrees(revealed_solva ? fanRotation_solva : 0))
                    .offset(x: revealed_solva ? fanOffsetX_solva : 0, y: revealed_solva ? 0 : 160)
                    .scaleEffect(revealed_solva ? 1 : 0.5)
                    .opacity(revealed_solva ? 1 : 0)
                    .zIndex(Double(index_solva))
            }
        }
    }

    /// 底部三个加载点，各自以不同延迟做「呼吸」缩放，形成波浪式加载动效
    private var loadingDots_solva: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index_solva in
                Circle()
                    .fill(Palette_solva.gold_solva)
                    .frame(width: 7, height: 7)
                    .scaleEffect(dotsBreathing_solva ? 1.3 : 0.6)
                    .opacity(dotsBreathing_solva ? 1 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index_solva) * 0.18),
                        value: dotsBreathing_solva
                    )
            }
        }
    }

    /// 按时间线依次触发：4 张牌交错飞入 → 品牌铭牌回弹登场 → 副标题与加载点浮现
    private func runSequence_solva() {
        dotsBreathing_solva = true

        for index_solva in showcaseCards_solva.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 + Double(index_solva) * 0.12) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                    cardsRevealed_solva[index_solva] = true
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.62)) {
                logoRevealed_solva = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.4)) {
                captionRevealed_solva = true
            }
        }
    }
}

#Preview {
    LaunchAnimationScreen_solva()
}
