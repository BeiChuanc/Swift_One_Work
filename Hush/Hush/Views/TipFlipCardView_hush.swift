import UIKit
import SnapKit

// MARK: 技巧翻转卡片视图

/// 技巧提示翻转卡片视图
/// 功能：正面显示图标圆圈 + 标题，点击后 3D 翻转展示背面详细内容
/// 设计：每张卡拥有独立色系（8种主题色），正面彩色圆形图标 + 淡底卡片，背面深色渐变
/// 关键方法：configure_Hush(model:index:) — index 决定卡片主题色
class TipFlipCardView_Hush: UIView {

    // MARK: - 私有属性

    /// 当前是否显示背面
    private var isShowingBack_Hush = false

    /// 每张卡的专属色系（圆底色、背面深色、背面次深色）
    private static let cardThemes_Hush: [(accent: String, backStart: String, backEnd: String)] = [
        ("#F9C784", "#7D5A1E", "#4A3510"),   // 金色时刻 — 暖琥珀
        ("#74B9FF", "#1A4A7A", "#0D2B4D"),   // 三分法 — 冷天蓝
        ("#A29BFE", "#3D1F7A", "#22104D"),   // 阴影 — 深靛紫
        ("#55EFC4", "#1A6A50", "#0D3D2E"),   // 隐身 — 翠绿
        ("#FD79A8", "#7A1A44", "#4D0D28"),   // 单镜头 — 玫瑰粉
        ("#81ECEC", "#1A6A6A", "#0D3D3D"),   // 散射光 — 青碧
        ("#FDCB6E", "#7A5A1A", "#4D380D"),   // 1%时刻 — 暖沙橙
        ("#00B894", "#0A4A3A", "#062D23"),   // 跟随能量 — 薄荷绿
    ]

    // MARK: - 正面组件

    private let frontContainer_Hush: UIView = {
        let v_hush = UIView()
        v_hush.layer.cornerRadius = 18
        v_hush.clipsToBounds = true
        return v_hush
    }()

    /// 正面淡色渐变背景
    private var frontBgGradient_Hush: CAGradientLayer?

    /// 图标圆形底
    private let iconCircle_Hush: UIView = {
        let v_hush = UIView()
        v_hush.layer.cornerRadius = 28
        v_hush.clipsToBounds = true
        return v_hush
    }()
    private var iconCircleGradient_Hush: CAGradientLayer?

    /// 正面图标
    private let frontIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.tintColor = .white
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()

    /// 正面标题
    private let frontTitle_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = ColorConfig_Hush.textPrimary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lb_hush.textAlignment = .center
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    /// 翻转提示（底部小图标 + 文字）
    private let flipHintView_Hush = UIView()
    private let flipIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.image = UIImage(systemName: "arrow.2.squarepath")
        iv_hush.tintColor = ColorConfig_Hush.textPlaceholder_Hush
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()
    private let flipHintLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "Tap to flip"
        lb_hush.textColor = ColorConfig_Hush.textPlaceholder_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return lb_hush
    }()

    // MARK: - 背面组件

    private let backContainer_Hush: UIView = {
        let v_hush = UIView()
        v_hush.isHidden = true
        v_hush.layer.cornerRadius = 18
        v_hush.clipsToBounds = true
        return v_hush
    }()
    private var backGradient_Hush: CAGradientLayer?

    /// 背面彩色顶部强调条
    private let backAccent_Hush: UIView = {
        let v_hush = UIView()
        return v_hush
    }()
    private var backAccentGradient_Hush: CAGradientLayer?

    /// 背面小图标（半透明）
    private let backIcon_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.tintColor = UIColor.white.withAlphaComponent(0.3)
        iv_hush.contentMode = .scaleAspectFit
        return iv_hush
    }()

    /// 背面详细内容
    private let backContent_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb_hush.numberOfLines = 0
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    private let backFlipHint_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "↩ Flip back"
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.45)
        lb_hush.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Hush()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        frontBgGradient_Hush?.frame = frontContainer_Hush.bounds
        iconCircleGradient_Hush?.frame = iconCircle_Hush.bounds
        backGradient_Hush?.frame = backContainer_Hush.bounds
        backAccentGradient_Hush?.frame = backAccent_Hush.bounds
    }

    // MARK: - 私有方法

    private func setupUI_Hush() {
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 12
        layer.shadowOpacity = 1
        clipsToBounds = false

        // ── 正面 ──
        addSubview(frontContainer_Hush)

        // 正面淡渐变背景
        let frontBg_hush = CAGradientLayer()
        frontBg_hush.startPoint = CGPoint(x: 0, y: 0)
        frontBg_hush.endPoint = CGPoint(x: 1, y: 1)
        frontContainer_Hush.layer.insertSublayer(frontBg_hush, at: 0)
        frontBgGradient_Hush = frontBg_hush

        // 图标圆形底渐变
        let circleGrad_hush = CAGradientLayer()
        circleGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        circleGrad_hush.endPoint = CGPoint(x: 1, y: 1)
        iconCircle_Hush.layer.insertSublayer(circleGrad_hush, at: 0)
        iconCircleGradient_Hush = circleGrad_hush

        frontContainer_Hush.addSubview(iconCircle_Hush)
        iconCircle_Hush.addSubview(frontIcon_Hush)
        frontContainer_Hush.addSubview(frontTitle_Hush)
        frontContainer_Hush.addSubview(flipHintView_Hush)
        flipHintView_Hush.addSubview(flipIcon_Hush)
        flipHintView_Hush.addSubview(flipHintLabel_Hush)

        frontContainer_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        iconCircle_Hush.snp.makeConstraints { make_hush in
            make_hush.centerX.equalToSuperview()
            make_hush.top.equalToSuperview().offset(28)
            make_hush.width.height.equalTo(56)
        }
        frontIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.center.equalToSuperview()
            make_hush.width.height.equalTo(26)
        }
        frontTitle_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(iconCircle_Hush.snp.bottom).offset(14)
            make_hush.left.right.equalToSuperview().inset(14)
        }
        flipHintView_Hush.snp.makeConstraints { make_hush in
            make_hush.bottom.equalToSuperview().offset(-14)
            make_hush.centerX.equalToSuperview()
            make_hush.height.equalTo(16)
        }
        flipIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.left.top.bottom.equalToSuperview()
            make_hush.width.equalTo(14)
        }
        flipHintLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(flipIcon_Hush.snp.right).offset(4)
            make_hush.centerY.right.equalToSuperview()
        }

        // ── 背面 ──
        addSubview(backContainer_Hush)

        let backGrad_hush = CAGradientLayer()
        backGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        backGrad_hush.endPoint = CGPoint(x: 1, y: 1)
        backContainer_Hush.layer.insertSublayer(backGrad_hush, at: 0)
        backGradient_Hush = backGrad_hush

        let backAccentGrad_hush = CAGradientLayer()
        backAccentGrad_hush.startPoint = CGPoint(x: 0, y: 0.5)
        backAccentGrad_hush.endPoint = CGPoint(x: 1, y: 0.5)
        backAccent_Hush.layer.insertSublayer(backAccentGrad_hush, at: 0)
        backAccentGradient_Hush = backAccentGrad_hush

        backContainer_Hush.addSubview(backAccent_Hush)
        backContainer_Hush.addSubview(backIcon_Hush)
        backContainer_Hush.addSubview(backContent_Hush)
        backContainer_Hush.addSubview(backFlipHint_Hush)

        backContainer_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
        backAccent_Hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(5)
        }
        backIcon_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(22)
            make_hush.centerX.equalToSuperview()
            make_hush.width.height.equalTo(28)
        }
        backContent_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(backIcon_Hush.snp.bottom).offset(12)
            make_hush.left.right.equalToSuperview().inset(14)
            make_hush.bottom.lessThanOrEqualTo(backFlipHint_Hush.snp.top).offset(-8)
        }
        backFlipHint_Hush.snp.makeConstraints { make_hush in
            make_hush.bottom.equalToSuperview().offset(-14)
            make_hush.centerX.equalToSuperview()
        }

        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(onFlip_Hush))
        addGestureRecognizer(tap_hush)
        isUserInteractionEnabled = true
    }

    @objc private func onFlip_Hush() {
        let dir_hush: UIView.AnimationOptions = isShowingBack_Hush ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: self, duration: AnimationConfig_Hush.durationSpring_Hush,
                          options: [dir_hush, .curveEaseInOut]) { [weak self] in
            guard let s_hush = self else { return }
            s_hush.isShowingBack_Hush.toggle()
            s_hush.frontContainer_Hush.isHidden = s_hush.isShowingBack_Hush
            s_hush.backContainer_Hush.isHidden = !s_hush.isShowingBack_Hush
        }
    }

    // MARK: - 数据绑定

    /// 绑定技巧提示卡数据
    /// - Parameters:
    ///   - model_hush: 技巧提示卡模型
    ///   - index_hush: 卡片序号（0开始），决定主题色系
    func configure_Hush(model_hush: TipCardModel_Hush, index_hush: Int = 0) {
        let theme_hush = Self.cardThemes_Hush[index_hush % Self.cardThemes_Hush.count]
        let accentColor_hush = UIColor(hexstring_Hush: theme_hush.accent)

        // 正面：极淡彩色背景（accent 色 7% 透明度）
        frontBgGradient_Hush?.colors = [
            accentColor_hush.withAlphaComponent(0.07).cgColor,
            UIColor.white.cgColor,
        ]

        // 图标圆底渐变
        iconCircleGradient_Hush?.colors = [
            accentColor_hush.cgColor,
            UIColor(hexstring_Hush: theme_hush.backStart).cgColor,
        ]

        // 背面深色渐变
        backGradient_Hush?.colors = [
            UIColor(hexstring_Hush: theme_hush.backStart).cgColor,
            UIColor(hexstring_Hush: theme_hush.backEnd).cgColor,
        ]

        // 背面顶部强调条
        backAccentGradient_Hush?.colors = [
            accentColor_hush.cgColor,
            accentColor_hush.withAlphaComponent(0.5).cgColor,
        ]

        // 图标
        let iconCfg_hush = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iconImg_hush = UIImage(systemName: model_hush.frontIcon_Hush, withConfiguration: iconCfg_hush)
        frontIcon_Hush.image = iconImg_hush
        backIcon_Hush.image = iconImg_hush

        frontTitle_Hush.text = model_hush.frontTitle_Hush
        backContent_Hush.text = model_hush.backContent_Hush

        // 重置为正面
        isShowingBack_Hush = false
        frontContainer_Hush.isHidden = false
        backContainer_Hush.isHidden = true
    }
}

// MARK: - 技巧卡 CollectionViewCell

/// 技巧提示翻转卡 CollectionViewCell
class TipFlipCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "TipFlipCell_Hush"

    let cardView_Hush = TipFlipCardView_Hush()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Hush)
        cardView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
