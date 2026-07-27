//
//  CommonComponents_solva.swift
//  Solva
//
//  通用小型 UI 组件集合。
//  设计思路：将首页/记录页/统计页/成就页共用、但又过于精简不值得单独拆文件的
//  小组件集中放置——区块标题、数值徽标、空状态提示、二级页面顶部导航条，
//  避免样式碎片化；本次统一收紧各组件的内外边距，并将图标替换为 IconBadge_solva
//  渲染的分层徽标，解决「顶部/区块空隙过大」与「图标单调」的问题。
//
import SwiftUI

/// 区块标题，用于各页面顶部分区（如「个人记录」页的「总览」「各游戏详情」）
struct SectionHeaderView_solva: View {
    let title_solva: String
    var subtitle_solva: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title_solva.uppercased())
                .casinoTracked_solva(1.4)
                .font(.casinoTitle_solva(16))
                .foregroundStyle(Palette_solva.textPrimary_solva)
            if let subtitle_solva {
                Text(subtitle_solva)
                    .font(.casinoBody_solva(11.5))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 数值徽标卡片，用于统计页展示单项指标（如总局数/胜率/总时长）
struct StatChipView_solva: View {
    let icon_solva: String
    let value_solva: String
    let label_solva: String
    var tint_solva: Color = Palette_solva.gold_solva

    var body: some View {
        HStack(spacing: 10) {
            IconBadge_solva(icon_solva: icon_solva, tint_solva: tint_solva, size_solva: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(value_solva)
                    .font(.casinoNumeric_solva(18))
                    .foregroundStyle(Palette_solva.textPrimary_solva)
                Text(label_solva.uppercased())
                    .casinoTracked_solva(0.6)
                    .font(.casinoLabel_solva(9.5))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 128, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette_solva.panel_solva.alpha_solva(0.9)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(tint_solva.alpha_solva(0.25), lineWidth: 1))
    }
}

/// 空状态提示，用于「暂无对局记录」等场景
struct EmptyStateView_solva: View {
    let icon_solva: String
    let text_solva: String

    var body: some View {
        VStack(spacing: 8) {
            IconBadge_solva(icon_solva: icon_solva, tint_solva: Palette_solva.textSecondary_solva, size_solva: 46, ringStyle_solva: false)
            Text(text_solva)
                .font(.casinoBody_solva(12.5))
                .foregroundStyle(Palette_solva.textSecondary_solva)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }
}

/// 通用返回顶部导航条，用于记录/统计/成就三个二级页面
/// 设计思路：本次收紧上下内边距（原 12pt → 8pt），并将「Back」按钮包装成
/// 带描边的票据式小胶囊，标题采用衬线招牌字体，呼应整体欧美牌室视觉基调。
struct SubPageTopBar_solva: View {
    let title_solva: String
    let onBack_solva: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack_solva) {
                HStack(spacing: 5) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                    Text("Back")
                        .font(.casinoLabel_solva(13))
                }
                .foregroundStyle(Palette_solva.textPrimary_solva)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Palette_solva.panel_solva.alpha_solva(0.85)))
                .overlay(Capsule().stroke(Palette_solva.gold_solva.alpha_solva(0.3), lineWidth: 1))
            }
            Spacer()
            Text(title_solva.uppercased())
                .casinoTracked_solva(1.8)
                .font(.casinoTitle_solva(16))
                .foregroundStyle(Palette_solva.textPrimary_solva)
            Spacer()
            // 注意：Color.clear 若只指定 width 不指定 height，会在纵向上变成「贪婪扩展」
            // （无固定高度、尽可能撑满父级提议的可用高度），导致整条 HStack 被异常撑高，
            // 其余内容（返回按钮/标题）在被撑高的行内垂直居中，从而在上下各留出一块空白——
            // 这正是「记录/统计/成就/玩法」页面顶部出现红框空隙的根因。显式给定 height 修复。
            Color.clear.frame(width: 56, height: 1)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
    }
}
