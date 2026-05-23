import UIKit
import SnapKit

// MARK: 季节挑战卡片视图

/// 季节挑战卡片视图
/// 功能：展示单个季节限定挑战，顶部彩色 Banner + 季节大 Emoji 装饰，底部白色内容区
/// 设计：卡片分为顶部 Banner 区（季节色渐变 + 季节 Emoji）+ 底部白色信息区
/// 关键属性：tapAction_Hush（点击回调，进入评论详情）
class SeasonChallengeCardView_Hush: UIView {

    // MARK: - 回调

    /// 卡片点击回调
    var tapAction_Hush: (() -> Void)?

    // MARK: - UI 组件 - 顶部 Banner

    /// 顶部彩色 Banner 容器
    private let bannerView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.clipsToBounds = true
        return v_hush
    }()
    private var bannerGradient_Hush: CAGradientLayer?

    /// Banner 背景大 Emoji（半透明装饰）
    private let emojiDecor_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.font = UIFont.systemFont(ofSize: 52)
        lb_hush.alpha = 0.18
        return lb_hush
    }()

    /// 季节名 + 小图标徽章
    private let seasonChip_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_hush.layer.cornerRadius = 11
        return v_hush
    }()
    private let seasonEmojiLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.font = UIFont.systemFont(ofSize: 12)
        return lb_hush
    }()
    private let seasonNameLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        return lb_hush
    }()

    /// Banner 内主题标题（白色大字）
    private let bannerTitle_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    // MARK: - UI 组件 - 底部信息区

    /// 白色内容区容器
    private let bodyView_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = .white
        return v_hush
    }()

    /// 挑战描述
    private let descLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = ColorConfig_Hush.textSecondary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb_hush.numberOfLines = 1
        return lb_hush
    }()

    /// 参与人数（带头像点）
    private let participantLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = ColorConfig_Hush.textSecondary_Hush
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return lb_hush
    }()

    /// Discuss 按钮（渐变背景）
    private let discussButton_Hush: UIButton = {
        let bt_hush = UIButton(type: .custom)
        bt_hush.setTitle("Discuss  →", for: .normal)
        bt_hush.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        bt_hush.setTitleColor(.white, for: .normal)
        bt_hush.layer.cornerRadius = 13
        bt_hush.clipsToBounds = true
        return bt_hush
    }()
    private var discussGradient_Hush: CAGradientLayer?

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
        bannerGradient_Hush?.frame = bannerView_Hush.bounds
        discussGradient_Hush?.frame = discussButton_Hush.bounds
    }

    // MARK: - 私有方法

    private func setupUI_Hush() {
        backgroundColor = .white
        layer.cornerRadius = 18
        clipsToBounds = true
        layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 1

        // Banner 渐变占位
        let grad_hush = CAGradientLayer()
        grad_hush.startPoint = CGPoint(x: 0, y: 0)
        grad_hush.endPoint = CGPoint(x: 1, y: 1)
        bannerView_Hush.layer.insertSublayer(grad_hush, at: 0)
        bannerGradient_Hush = grad_hush

        // Discuss 按钮渐变
        let btGrad_hush = CAGradientLayer()
        btGrad_hush.colors = [
            ColorConfig_Hush.primaryGradientStart_Hush.cgColor,
            ColorConfig_Hush.primaryGradientEnd_Hush.cgColor,
        ]
        btGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        btGrad_hush.endPoint = CGPoint(x: 1, y: 0)
        discussButton_Hush.layer.insertSublayer(btGrad_hush, at: 0)
        discussGradient_Hush = btGrad_hush

        // 层级
        addSubview(bannerView_Hush)
        bannerView_Hush.addSubview(emojiDecor_Hush)
        bannerView_Hush.addSubview(seasonChip_Hush)
        seasonChip_Hush.addSubview(seasonEmojiLabel_Hush)
        seasonChip_Hush.addSubview(seasonNameLabel_Hush)
        bannerView_Hush.addSubview(bannerTitle_Hush)

        addSubview(bodyView_Hush)
        bodyView_Hush.addSubview(descLabel_Hush)
        bodyView_Hush.addSubview(participantLabel_Hush)
        bodyView_Hush.addSubview(discussButton_Hush)

        // Banner 区（上半部分，60pt 高）
        bannerView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.left.right.equalToSuperview()
            make_hush.height.equalTo(68)
        }
        emojiDecor_Hush.snp.makeConstraints { make_hush in
            make_hush.right.equalToSuperview().offset(4)
            make_hush.centerY.equalToSuperview().offset(4)
        }
        seasonChip_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(12)
            make_hush.left.equalToSuperview().offset(14)
            make_hush.height.equalTo(22)
        }
        seasonEmojiLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(7)
            make_hush.centerY.equalToSuperview()
        }
        seasonNameLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalTo(seasonEmojiLabel_Hush.snp.right).offset(3)
            make_hush.centerY.equalToSuperview()
            make_hush.right.equalToSuperview().offset(-8)
        }
        bannerTitle_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.equalToSuperview().inset(14)
            make_hush.bottom.equalToSuperview().offset(-10)
        }

        // Body 区（白色内容，余下高度）
        bodyView_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(bannerView_Hush.snp.bottom)
            make_hush.left.right.bottom.equalToSuperview()
        }
        descLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(10)
            make_hush.left.equalToSuperview().offset(14)
            make_hush.right.equalToSuperview().offset(-14)
        }
        participantLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalTo(descLabel_Hush.snp.bottom).offset(6)
            make_hush.left.equalToSuperview().offset(14)
            make_hush.bottom.equalToSuperview().offset(-12)
        }
        discussButton_Hush.snp.makeConstraints { make_hush in
            make_hush.centerY.equalTo(participantLabel_Hush)
            make_hush.right.equalToSuperview().offset(-14)
            make_hush.height.equalTo(28)
            make_hush.width.equalTo(90)
        }

        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(onCardTap_Hush))
        addGestureRecognizer(tap_hush)
        discussButton_Hush.addTarget(self, action: #selector(onCardTap_Hush), for: .touchUpInside)
    }

    @objc private func onCardTap_Hush() {
        springScaleAnimate_Hush()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.tapAction_Hush?()
        }
    }

    // MARK: - 数据绑定

    /// 绑定季节挑战数据
    /// - Parameter model_hush: 季节挑战模型
    func configure_Hush(model_hush: SeasonChallengeModel_Hush) {
        let themeColor_hush = UIColor(hexstring_Hush: model_hush.coverColorHex_Hush)
        let darkColor_hush = themeColor_hush.withAlphaComponent(0.72)
        bannerGradient_Hush?.colors = [themeColor_hush.cgColor, darkColor_hush.cgColor]

        // 背景装饰 Emoji 和 Chip Emoji 均取该主题独立 Emoji，不与其他卡重复
        let themeEmoji_hush = themeEmoji_Hush(theme_hush: model_hush.theme_Hush,
                                               season_hush: model_hush.season_Hush)
        emojiDecor_Hush.text = themeEmoji_hush
        seasonEmojiLabel_Hush.text = themeEmoji_hush
        seasonNameLabel_Hush.text = model_hush.season_Hush
        bannerTitle_Hush.text = model_hush.theme_Hush
        descLabel_Hush.text = model_hush.challengeDescription_Hush
        participantLabel_Hush.text = "👥 \(model_hush.participantCount_Hush) joined"
    }

    /// 根据挑战主题关键词匹配独立 Emoji，使每张卡视觉上不重复
    /// - Parameters:
    ///   - theme_hush: 挑战主题文字
    ///   - season_hush: 所属季节（兜底用）
    private func themeEmoji_Hush(theme_hush: String, season_hush: String) -> String {
        let lower_hush = theme_hush.lowercased()
        // 按关键词优先匹配
        if lower_hush.contains("ray") || lower_hush.contains("light") || lower_hush.contains("dawn") || lower_hush.contains("sunrise") { return "🌅" }
        if lower_hush.contains("rain") || lower_hush.contains("reflection") || lower_hush.contains("puddle") { return "🌧️" }
        if lower_hush.contains("bloom") || lower_hush.contains("flower") || lower_hush.contains("blossom") || lower_hush.contains("corner") { return "🌺" }
        if lower_hush.contains("dusk") || lower_hush.contains("wind") || lower_hush.contains("breeze") { return "🌬️" }
        if lower_hush.contains("ice") || lower_hush.contains("cold") && lower_hush.contains("afternoon") { return "🧊" }
        if lower_hush.contains("barefoot") || lower_hush.contains("asphalt") { return "👣" }
        if lower_hush.contains("fallen") || lower_hush.contains("first") && lower_hush.contains("leaf") { return "🍂" }
        if lower_hush.contains("golden") || lower_hush.contains("alley") { return "🍁" }
        if lower_hush.contains("market") { return "🎑" }
        if lower_hush.contains("warm") || lower_hush.contains("lamp") || lower_hush.contains("candle") { return "🕯️" }
        if lower_hush.contains("breath") || lower_hush.contains("steam") { return "💨" }
        if lower_hush.contains("empty") || (lower_hush.contains("street") && lower_hush.contains("winter")) { return "🌨️" }
        // 兜底返回季节 Emoji
        switch season_hush {
        case "Spring": return "🌸"
        case "Summer": return "☀️"
        case "Autumn": return "🍂"
        default:       return "❄️"
        }
    }
}
