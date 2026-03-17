import UIKit
import SnapKit

// MARK: 发现页用户卡片

/// 发现页用户卡片 Cell
/// 核心作用：在发现页用户列表中展示单个用户的头像、名称、简介、粉丝/帖子数及关注按钮
/// 设计理念：白色卡片 + 左侧渐变色条装饰 + 右侧关注按钮，关注态与未关注态用渐变/描边区分
/// 关键属性：onFollowTapped_Pane - 关注/取消关注回调，由外部 VC 调用 UserViewModel
class DiscoverUserCell_Pane: UICollectionViewCell {

    // MARK: - 静态常量
    static let reuseId_Pane = "DiscoverUserCell_Pane"

    // MARK: - UI组件

    /// 卡片主容器（圆角裁切）
    private let containerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 左侧渐变色条装饰
    private let accentBar_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private var accentGradientLayer_Pane: CAGradientLayer?

    /// 卡片内极轻渐变背景（增加层次感）
    private let cardGradientBg_Pane = UIView()
    private var cardBgGradientLayer_Pane: CAGradientLayer?

    /// 用户头像
    private let avatarView_Pane: UserAvatarView_Pane = {
        let v = UserAvatarView_Pane()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    /// 用户名
    private let nameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    /// 简介
    private let introLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 1
        return l
    }()

    /// 统计数据横排容器（粉丝数 + 帖子数）
    private let statsRow_Pane = UIStackView()

    /// 粉丝数
    private let fansStatView_Pane = DiscoverStatChip_Pane()

    /// 帖子数
    private let postsStatView_Pane = DiscoverStatChip_Pane()

    /// 关注按钮
    private let followButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        btn.layer.cornerRadius = 17
        btn.clipsToBounds = true
        return btn
    }()
    private var followGradientLayer_Pane: CAGradientLayer?

    // MARK: - 属性

    var onFollowTapped_Pane: (() -> Void)?
    private var isFollowing_Pane: Bool = false

    // MARK: - 高亮响应

    override var isHighlighted: Bool {
        didSet {
            containerView_Pane.animatePressDown_Pane(completion_Pane: isHighlighted ? nil : { [weak self] in
                self?.containerView_Pane.animatePressUp_Pane()
            })
            if !isHighlighted { containerView_Pane.animatePressUp_Pane() }
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        setupShadow_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        accentGradientLayer_Pane?.frame  = accentBar_Pane.bounds
        cardBgGradientLayer_Pane?.frame  = cardGradientBg_Pane.bounds
        followGradientLayer_Pane?.frame  = followButton_Pane.bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 18).cgPath
    }

    // MARK: - UI布局

    private func setupUI_Pane() {
        contentView.addSubview(containerView_Pane)
        containerView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 极轻渐变背景（主色极低透明度，从左淡入）
        containerView_Pane.addSubview(cardGradientBg_Pane)
        cardGradientBg_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        let bgGL = CAGradientLayer()
        bgGL.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.06).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        bgGL.startPoint = CGPoint(x: 0, y: 0.5)
        bgGL.endPoint   = CGPoint(x: 1, y: 0.5)
        cardGradientBg_Pane.layer.addSublayer(bgGL)
        cardBgGradientLayer_Pane = bgGL

        // 左侧渐变色条（宽 4pt）
        containerView_Pane.addSubview(accentBar_Pane)
        accentBar_Pane.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(4)
        }
        let acGL = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: .zero)
        accentBar_Pane.layer.addSublayer(acGL)
        accentGradientLayer_Pane = acGL

        // 头像
        containerView_Pane.addSubview(avatarView_Pane)
        avatarView_Pane.snp.makeConstraints {
            $0.leading.equalTo(accentBar_Pane.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(52)
        }

        // 关注按钮（右侧固定宽度）
        containerView_Pane.addSubview(followButton_Pane)
        followButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(88)
            $0.height.equalTo(34)
        }
        followButton_Pane.addTarget(self, action: #selector(handleFollowTap_Pane), for: .touchUpInside)

        // 用户名
        containerView_Pane.addSubview(nameLabel_Pane)
        nameLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(avatarView_Pane.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(followButton_Pane.snp.leading).offset(-8)
            $0.top.equalTo(avatarView_Pane).offset(4)
        }

        // 简介
        containerView_Pane.addSubview(introLabel_Pane)
        introLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Pane)
            $0.trailing.lessThanOrEqualTo(followButton_Pane.snp.leading).offset(-8)
            $0.top.equalTo(nameLabel_Pane.snp.bottom).offset(3)
        }

        // 统计数据行（粉丝 + 帖子）
        statsRow_Pane.axis      = .horizontal
        statsRow_Pane.spacing   = 8
        statsRow_Pane.alignment = .center
        statsRow_Pane.addArrangedSubview(fansStatView_Pane)
        statsRow_Pane.addArrangedSubview(postsStatView_Pane)
        containerView_Pane.addSubview(statsRow_Pane)
        statsRow_Pane.snp.makeConstraints {
            $0.leading.equalTo(nameLabel_Pane)
            $0.top.equalTo(introLabel_Pane.snp.bottom).offset(5)
            $0.trailing.lessThanOrEqualTo(followButton_Pane.snp.leading).offset(-8)
        }
    }

    private func setupShadow_Pane() {
        layer.shadowColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.12).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 12
        layer.masksToBounds = false
        containerView_Pane.layer.masksToBounds = true
    }

    // MARK: - 数据配置

    /// 配置用户卡片内容
    /// - Parameters:
    ///   - user_pane:        用户数据模型
    ///   - isFollowing_pane: 当前用户是否已关注该用户
    func configure_Pane(user_pane: PrewUserModel_Pane, isFollowing_pane: Bool) {
        guard let userId_pane = user_pane.userId_Pane else { return }
        avatarView_Pane.configure_Pane(userId_Pane: userId_pane)
        nameLabel_Pane.text  = user_pane.userName_Pane ?? "User"
        introLabel_Pane.text = user_pane.userIntroduce_Pane?.isEmpty == false
            ? user_pane.userIntroduce_Pane
            : "No introduction yet"
        fansStatView_Pane.configure_Pane(
            icon_pane: "person.2.fill",
            value_pane: "\(user_pane.userFans_Pane ?? 0)",
            label_pane: "Fans"
        )
        let postCount_pane = TitleViewModel_Pane.shared_Pane.getUserPosts_Pane(user_pane: user_pane).count
        postsStatView_Pane.configure_Pane(
            icon_pane: "photo.on.rectangle",
            value_pane: "\(postCount_pane)",
            label_pane: "Posts"
        )
        refreshFollowState_Pane(isFollowing_pane: isFollowing_pane, animated_pane: false)
    }

    /// 刷新关注按钮样式
    private func refreshFollowState_Pane(isFollowing_pane: Bool, animated_pane: Bool) {
        isFollowing_Pane = isFollowing_pane
        followGradientLayer_Pane?.removeFromSuperlayer()
        followGradientLayer_Pane = nil

        if isFollowing_pane {
            followButton_Pane.setTitle("Following", for: .normal)
            followButton_Pane.setTitleColor(ColorConfig_Pane.textSecondary_Pane, for: .normal)
            followButton_Pane.backgroundColor = UIColor(hexstring_Pane: "#EDF2F7")
            followButton_Pane.layer.borderWidth = 0
            followButton_Pane.layer.shadowOpacity = 0
        } else {
            followButton_Pane.setTitle("Follow", for: .normal)
            followButton_Pane.setTitleColor(.white, for: .normal)
            followButton_Pane.backgroundColor = .clear
            followButton_Pane.layer.borderWidth = 0

            let gl = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: followButton_Pane.bounds)
            gl.cornerRadius = 17
            followButton_Pane.layer.insertSublayer(gl, at: 0)
            followGradientLayer_Pane = gl

            // 未关注：给按钮加光晕
            followButton_Pane.layer.masksToBounds = false
            followButton_Pane.layer.shadowColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.5).cgColor
            followButton_Pane.layer.shadowOpacity = 1.0
            followButton_Pane.layer.shadowOffset  = CGSize(width: 0, height: 4)
            followButton_Pane.layer.shadowRadius  = 8
        }

        if animated_pane { followButton_Pane.animateSpringScaleIn_Pane() }
    }

    // MARK: - 事件处理

    @objc private func handleFollowTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        refreshFollowState_Pane(isFollowing_pane: !isFollowing_Pane, animated_pane: true)
        onFollowTapped_Pane?()
    }
}

// MARK: - 统计数据小组件（私有，仅供 DiscoverUserCell_Pane 使用）

/// 用户统计数据小标签（图标 + 数值 + 标签）
private class DiscoverStatChip_Pane: UIView {

    private let iconView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let valueLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        return l
    }()

    private let textLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .regular)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Pane() {
        backgroundColor = UIColor(hexstring_Pane: "#F0F4FF")
        layer.cornerRadius = 8
        clipsToBounds = true

        addSubview(iconView_Pane)
        addSubview(valueLabel_Pane)
        addSubview(textLabel_Pane)

        iconView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(11)
        }

        valueLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(iconView_Pane.snp.trailing).offset(3)
            $0.centerY.equalToSuperview()
        }

        textLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(valueLabel_Pane.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().offset(-6)
            $0.centerY.equalToSuperview()
        }

        snp.makeConstraints { $0.height.equalTo(20) }
    }

    /// 配置统计数据小标签
    func configure_Pane(icon_pane: String, value_pane: String, label_pane: String) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        iconView_Pane.image = UIImage(systemName: icon_pane, withConfiguration: cfg)
        valueLabel_Pane.text = value_pane
        textLabel_Pane.text  = label_pane
    }
}
