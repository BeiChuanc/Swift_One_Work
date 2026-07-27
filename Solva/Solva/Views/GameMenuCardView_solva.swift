//
//  GameMenuCardView_solva.swift
//  Solva
//
//  牌桌「座位卡」组件。
//  设计思路：首页不再以列表/网格罗列游戏，而是把 5 款游戏当作围坐在牌桌四周的座位——
//  本组件即单个座位的视觉呈现：圆形勋章图标 + 衬线标题 + 迷你战绩，配合金色滚边营造
//  欧美私人牌室的座位牌质感，供 CasinoTableView_solva 按五角形环绕摆放。
//  关键属性：entry_solva（游戏目录信息）、bestScore_solva/winCount_solva（迷你战绩角标）
//
import SwiftUI

struct GameMenuCardView_solva: View {
    let entry_solva: GameCatalogEntry_solva
    let bestScore_solva: Int
    let winCount_solva: Int
    let onTap_solva: () -> Void

    var body: some View {
        Button(action: onTap_solva) {
            VStack(spacing: 6) {
                IconBadge_solva(icon_solva: entry_solva.seatIcon_solva, tint_solva: entry_solva.accentColor_solva, size_solva: 42)

                Text(entry_solva.title_solva)
                    .font(.casinoTitle_solva(13.5))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(entry_solva.badgeText_solva.uppercased())
                    .casinoTracked_solva(1.1)
                    .font(.casinoLabel_solva(8.5))
                    .foregroundStyle(entry_solva.accentColor_solva)

                HStack(spacing: 10) {
                    miniStat_solva(icon: "star.fill", text: "\(bestScore_solva)")
                    miniStat_solva(icon: "trophy.fill", text: "\(winCount_solva)")
                }
                .padding(.top, 2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(width: 168, height: 118)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Palette_solva.woodBrown_solva.alpha_solva(0.55))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Palette_solva.panel_solva.alpha_solva(0.86))
                        .padding(2)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(entry_solva.accentColor_solva.alpha_solva(0.6), lineWidth: 1.4)
            )
            .overlay(cornerTicks_solva)
            .shadow(color: Color.black.alpha_solva(0.4), radius: 10, y: 6)
        }
        .buttonStyle(GameCardPressStyle_solva())
    }

    /// 四角小刻线，呼应筹码/座位牌的雕刻边饰
    private var cornerTicks_solva: some View {
        GeometryReader { geo_solva in
            let l_solva: CGFloat = 9
            Path { p in
                p.move(to: CGPoint(x: 8, y: 8 + l_solva)); p.addLine(to: CGPoint(x: 8, y: 8)); p.addLine(to: CGPoint(x: 8 + l_solva, y: 8))
                p.move(to: CGPoint(x: geo_solva.size.width - 8, y: 8 + l_solva)); p.addLine(to: CGPoint(x: geo_solva.size.width - 8, y: 8)); p.addLine(to: CGPoint(x: geo_solva.size.width - 8 - l_solva, y: 8))
                p.move(to: CGPoint(x: 8, y: geo_solva.size.height - 8 - l_solva)); p.addLine(to: CGPoint(x: 8, y: geo_solva.size.height - 8)); p.addLine(to: CGPoint(x: 8 + l_solva, y: geo_solva.size.height - 8))
                p.move(to: CGPoint(x: geo_solva.size.width - 8, y: geo_solva.size.height - 8 - l_solva)); p.addLine(to: CGPoint(x: geo_solva.size.width - 8, y: geo_solva.size.height - 8)); p.addLine(to: CGPoint(x: geo_solva.size.width - 8 - l_solva, y: geo_solva.size.height - 8))
            }
            .stroke(entry_solva.accentColor_solva.alpha_solva(0.5), lineWidth: 1.2)
        }
    }

    private func miniStat_solva(icon: String, text: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 8.5))
            Text(text).font(.casinoNumeric_solva(10))
        }
        .foregroundStyle(Palette_solva.textSecondary_solva)
    }
}

/// 卡片按压态样式：轻微缩放反馈
struct GameCardPressStyle_solva: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
