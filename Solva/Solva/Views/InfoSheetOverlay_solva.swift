//
//  InfoSheetOverlay_solva.swift
//  Solva
//
//  信息说明浮层组件。
//  设计思路：首页顶部提供「技术支持」「隐私政策」两个入口，点击后需要弹窗展示对应静态说明文案，
//  两者结构完全一致（标题图标 + 分段说明文字 + 关闭按钮），因此用同一枚举 InfoSheetKind_solva
//  区分内容与强调色，配合单一 InfoSheetOverlay_solva 组件渲染，避免重复编写两套弹窗视图。
//  视觉上与 GameResultOverlay_solva 保持一致的「半透明遮罩 + 居中票据式面板」风格。
//
import SwiftUI

/// 信息弹窗类型：技术支持 / 隐私政策
/// 关键属性：title_solva（弹窗标题）/ icon_solva（标题图标）/ accent_solva（强调色）
/// / sections_solva（分段说明内容，每段为「小标题, 正文」元组）
enum InfoSheetKind_solva: String, Identifiable {
    case support
    case privacy

    var id: String { rawValue }

    var title_solva: String {
        switch self {
        case .support: return "Technical Support"
        case .privacy: return "Privacy Policy"
        }
    }

    var icon_solva: String {
        switch self {
        case .support: return "lifepreserver.fill"
        case .privacy: return "hand.raised.fill"
        }
    }

    var accent_solva: Color {
        switch self {
        case .support: return Palette_solva.success_solva
        case .privacy: return Palette_solva.gold_solva
        }
    }

    var sections_solva: [(String, String)] {
        switch self {
        case .support:
            return [
                ("Contact Us", "Have a question or found an issue? Reach us at support@solva-cards.app — we usually reply within 1-2 business days."),
                ("Stuck Mid-Game?", "Use the Undo button to step back a move, tap the lightbulb for a hint, or use Restart to deal a fresh table."),
                ("Data & Records", "All match records, personal statistics and achievement progress are saved locally on this device. Reinstalling the app will reset them.")
            ]
        case .privacy:
            return [
                ("Fully Offline", "Solva is a self-contained solitaire collection. It does not require an account, network access, or any sign-in to play."),
                ("Local Data Only", "Match history, personal statistics and achievement progress are stored solely in this device's local storage."),
                ("No Tracking", "We do not collect, transmit or share any personal data, analytics, or advertising identifiers."),
                ("Your Control", "Uninstalling the app permanently removes all locally stored gameplay data.")
            ]
        }
    }
}

/// 信息说明浮层：用于展示「技术支持」「隐私政策」等静态说明内容
/// 关键属性：kind_solva（弹窗类型，决定标题/图标/正文）；onClose_solva（关闭回调）
/// 设计思路：点击遮罩或关闭按钮均可退出；正文区域可滚动以容纳较长文案。
struct InfoSheetOverlay_solva: View {
    let kind_solva: InfoSheetKind_solva
    let onClose_solva: () -> Void

    var body: some View {
        ZStack {
            Color.black.alpha_solva(0.55)
                .ignoresSafeArea()
                .onTapGesture { onClose_solva() }

            VStack(spacing: 0) {
                header_solva
                Divider().background(Color.white.alpha_solva(0.08))
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(kind_solva.sections_solva, id: \.0) { section_solva in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(section_solva.0.uppercased())
                                    .casinoTracked_solva(1)
                                    .font(.casinoLabel_solva(11))
                                    .foregroundStyle(kind_solva.accent_solva)
                                Text(section_solva.1)
                                    .font(.casinoBody_solva(12.5))
                                    .foregroundStyle(Palette_solva.textPrimary_solva.alpha_solva(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(18)
                }
            }
            .frame(maxWidth: 460, maxHeight: 360)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette_solva.panel_solva))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(kind_solva.accent_solva.alpha_solva(0.4), lineWidth: 1.4))
            .shadow(color: .black.alpha_solva(0.5), radius: 24, y: 12)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private var header_solva: some View {
        HStack(spacing: 10) {
            IconBadge_solva(icon_solva: kind_solva.icon_solva, tint_solva: kind_solva.accent_solva, size_solva: 34)
            Text(kind_solva.title_solva.uppercased())
                .casinoTracked_solva(1.2)
                .font(.casinoTitle_solva(15))
                .foregroundStyle(Palette_solva.textPrimary_solva)
            Spacer()
            Button(action: onClose_solva) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette_solva.textSecondary_solva)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.white.alpha_solva(0.06)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
