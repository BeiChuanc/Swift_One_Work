import Foundation
import UIKit
import SnapKit

// MARK: - 通用缺省态视图

/// 通用缺省态视图（图标徽标 + 标题 + 描述，白色圆角卡片承载）
/// 核心作用：在帖子/列表等数据为空时，以统一风格的卡片替代单薄的纯文字提示，
///           供"我的"页面等各类列表页复用，避免空白区域显得过于空旷
/// 设计思路：
///   - 图标徽标使用与发现页/发布页横幅一致的紫粉渐变圆形背景，统一强调色视觉基调
///   - 标题 + 描述纵向排列，文案由外部按场景（我的帖子 / 我喜欢的等）动态传入
class EmptyStateView_Orna: UIView {

    private let cardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        return v
    }()

    /// 图标徽标容器：直接以 CAGradientLayer 作为承载层（layerClass 重写），
    /// 由 UIKit 自动同步渐变层的 frame 与容器 bounds 保持一致，
    /// 避免手动在 layoutSubviews 中转发 frame 时可能出现的时序遗漏问题
    private final class GradientBadgeView_Orna: UIView {
        override class var layerClass: AnyClass { CAGradientLayer.self }
        var gradientLayer_Orna: CAGradientLayer { layer as! CAGradientLayer }
    }

    private let iconBadgeView_Orna: GradientBadgeView_Orna = {
        let v = GradientBadgeView_Orna()
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    private let iconView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.textAlignment = .center
        return l
    }()

    private let subtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(cardView_Orna)
        cardView_Orna.addSubview(iconBadgeView_Orna)
        iconBadgeView_Orna.addSubview(iconView_Orna)
        cardView_Orna.addSubview(titleLabel_Orna)
        cardView_Orna.addSubview(subtitleLabel_Orna)
        setupIconBadgeGradient_Orna()

        cardView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconBadgeView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        iconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(iconBadgeView_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        subtitleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.bottom.equalToSuperview().offset(-28)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 图标徽标紫粉渐变背景，呼应发现页/发布页横幅的强调色
    /// （直接配置 GradientBadgeView_Orna 自身的 CAGradientLayer 承载层，
    /// 无需手动同步 frame，从根本上避免渐变层未随布局更新而不可见的问题）
    private func setupIconBadgeGradient_Orna() {
        let gradientLayer_orna = iconBadgeView_Orna.gradientLayer_Orna
        gradientLayer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        gradientLayer_orna.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_orna.endPoint = CGPoint(x: 1, y: 1)
    }

    /// 配置缺省态图标、标题与描述
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - title_orna: 标题文案
    /// - subtitle_orna: 描述文案
    func configure_Orna(icon_orna: String, title_orna: String, subtitle_orna: String) {
        iconView_Orna.image = UIImage(systemName: icon_orna)
        titleLabel_Orna.text = title_orna
        subtitleLabel_Orna.text = subtitle_orna
    }
}
