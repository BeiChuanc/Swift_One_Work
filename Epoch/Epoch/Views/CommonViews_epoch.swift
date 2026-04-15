import Foundation
import UIKit
import SnapKit

// MARK: - 页面背景装饰

/// 页面背景装饰视图
/// 核心作用：为页面提供柔和的渐变光斑和层次背景
/// 设计思路：装饰层全部禁用交互，仅负责氛围，不影响按钮点击和滚动
class PageDecorationView_Epoch: UIView {

    /// 顶部光斑
    private let topGlowView_Epoch = UIView()

    /// 右侧光斑
    private let sideGlowView_Epoch = UIView()

    /// 底部光斑
    private let bottomGlowView_Epoch = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 构建背景装饰
    private func setupUI_Epoch() {
        backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        [topGlowView_Epoch, sideGlowView_Epoch, bottomGlowView_Epoch].forEach {
            $0.isUserInteractionEnabled = false
            addSubview($0)
        }

        topGlowView_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.18)
        sideGlowView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientEnd_Epoch.withAlphaComponent(0.16)
        bottomGlowView_Epoch.backgroundColor = ColorConfig_Epoch.accentGold_Epoch.withAlphaComponent(0.10)

        topGlowView_Epoch.layer.cornerRadius = 120
        sideGlowView_Epoch.layer.cornerRadius = 140
        bottomGlowView_Epoch.layer.cornerRadius = 110

        topGlowView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.left.equalToSuperview().offset(-40)
            make.width.height.equalTo(240)
        }

        sideGlowView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.right.equalToSuperview().offset(70)
            make.width.height.equalTo(280)
        }

        bottomGlowView_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(80)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(220)
        }
    }
}

// MARK: - 高级面板

/// 高级面板视图
/// 核心作用：统一提供更有质感的圆角面板容器
/// 设计思路：使用柔和底色、轻边框和双层阴影，让信息块更细腻
class SurfaceCardView_Epoch: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }

    /// 配置面板样式
    private func setupUI_Epoch() {
        backgroundColor = ColorConfig_Epoch.surfaceTint_Epoch
        layer.cornerRadius = 28
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowOpacity = 0.14
        layer.shadowRadius = 28
    }
}

// MARK: - 分组标题

/// 分组标题视图
/// 核心作用：在页面中统一承载小标签、标题和副标题
/// 设计思路：通过细标签和更明确的层级关系增强页面节奏
class SectionHeaderView_Epoch: UIView {

    /// 标签胶囊
    private let badgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.16)
        label_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Epoch.layer.cornerRadius = 12
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 10
        label_Epoch.verticalInset_Epoch = 6
        return label_Epoch
    }()

    /// 标题
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 副标题
    private let subtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView_Epoch = UIStackView(arrangedSubviews: [badgeLabel_Epoch, titleLabel_Epoch, subtitleLabel_Epoch])
        stackView_Epoch.axis = .vertical
        stackView_Epoch.spacing = 10
        stackView_Epoch.alignment = .leading
        addSubview(stackView_Epoch)
        stackView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定标题内容
    /// - Parameters:
    ///   - badge_Epoch: 角标文案
    ///   - title_Epoch: 标题文案
    ///   - subtitle_Epoch: 副标题文案
    func configure_Epoch(badge_Epoch: String, title_Epoch: String, subtitle_Epoch: String) {
        badgeLabel_Epoch.text = badge_Epoch
        titleLabel_Epoch.text = title_Epoch
        subtitleLabel_Epoch.text = subtitle_Epoch
    }
}

// MARK: - 内边距标签

/// 带内边距的标签
class PaddingLabel_Epoch: UILabel {

    /// 水平内边距
    var horizontalInset_Epoch: CGFloat = 0

    /// 垂直内边距
    var verticalInset_Epoch: CGFloat = 0

    override var intrinsicContentSize: CGSize {
        let baseSize_Epoch = super.intrinsicContentSize
        return CGSize(
            width: baseSize_Epoch.width + horizontalInset_Epoch * 2,
            height: baseSize_Epoch.height + verticalInset_Epoch * 2
        )
    }

    override func drawText(in rect: CGRect) {
        super.drawText(
            in: rect.insetBy(dx: horizontalInset_Epoch, dy: verticalInset_Epoch)
        )
    }
}

// MARK: - 通用主按钮

/// 通用主按钮
/// 核心作用：提供全项目统一的主操作按钮样式
/// 设计思路：使用渐变背景、圆角与轻阴影，统一页面中的确认类操作
/// 关键属性 / 方法：
/// - title_Epoch: 按钮标题
/// - isEnabled: 根据可用状态自动切换透明度
class PrimaryActionButton_Epoch: UIButton {

    /// 渐变背景图层
    private let gradientLayer_Epoch = CAGradientLayer()

    /// 初始化
    /// - Parameter title_Epoch: 按钮标题
    init(title_Epoch: String) {
        super.init(frame: .zero)
        setTitle(title_Epoch, for: .normal)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Epoch.frame = bounds
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.45
            isUserInteractionEnabled = isEnabled
        }
    }

    /// 配置按钮样式
    private func setupUI_Epoch() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 16
        clipsToBounds = false
        layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        gradientLayer_Epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.secondaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentPink_Epoch.cgColor
        ]
        gradientLayer_Epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Epoch.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_Epoch.cornerRadius = 16
        layer.insertSublayer(gradientLayer_Epoch, at: 0)
    }
}

// MARK: - 通用空状态

/// 通用空状态视图
/// 核心作用：在列表、消息、登录拦截等场景展示统一的空状态说明
/// 设计思路：使用系统图标、简洁标题和副标题，支持附带一个主操作按钮
/// 关键属性 / 方法：
/// - actionHandler_Epoch: 点击主按钮后的回调
/// - configure_Epoch: 刷新图标、标题、副标题和按钮文案
class EmptyStateView_Epoch: UIView {

    /// 空状态图标
    private let iconView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.tintColor = ColorConfig_Epoch.textPlaceholder_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.textAlignment = .center
        return label_Epoch
    }()

    /// 副标题标签
    private let subtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        label_Epoch.textAlignment = .center
        return label_Epoch
    }()

    /// 操作按钮
    private let actionButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Continue")

    /// 按钮回调
    var actionHandler_Epoch: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置空状态内容
    /// - Parameters:
    ///   - iconName_Epoch: 系统图标名
    ///   - title_Epoch: 标题
    ///   - subtitle_Epoch: 副标题
    ///   - buttonTitle_Epoch: 按钮标题，传 nil 时隐藏按钮
    func configure_Epoch(
        iconName_Epoch: String,
        title_Epoch: String,
        subtitle_Epoch: String,
        buttonTitle_Epoch: String? = nil
    ) {
        iconView_Epoch.image = UIImage(systemName: iconName_Epoch)
        titleLabel_Epoch.text = title_Epoch
        subtitleLabel_Epoch.text = subtitle_Epoch
        if let buttonTitle_Epoch = buttonTitle_Epoch {
            actionButton_Epoch.isHidden = false
            actionButton_Epoch.setTitle(buttonTitle_Epoch, for: .normal)
        } else {
            actionButton_Epoch.isHidden = true
        }
    }

    /// 构建视图
    private func setupUI_Epoch() {
        backgroundColor = UIColor.white.withAlphaComponent(0.76)
        layer.cornerRadius = 28
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        let stackView_Epoch = UIStackView(arrangedSubviews: [
            iconView_Epoch,
            titleLabel_Epoch,
            subtitleLabel_Epoch,
            actionButton_Epoch
        ])
        stackView_Epoch.axis = .vertical
        stackView_Epoch.alignment = .fill
        stackView_Epoch.spacing = 14
        addSubview(stackView_Epoch)

        iconView_Epoch.snp.makeConstraints { make in
            make.height.width.equalTo(54)
        }

        actionButton_Epoch.snp.makeConstraints { make in
            make.height.equalTo(54)
        }

        stackView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }

        actionButton_Epoch.addTarget(self, action: #selector(actionTapped_Epoch), for: .touchUpInside)
    }

    /// 处理按钮点击
    @objc private func actionTapped_Epoch() {
        actionButton_Epoch.animatePressDown_Epoch { [weak self] in
            self?.actionButton_Epoch.animatePressUp_Epoch()
        }
        actionHandler_Epoch?()
    }
}

// MARK: - 统计标签

/// 统计标签视图
/// 核心作用：展示发布数、收藏数、粉丝数等简要统计
/// 设计思路：使用统一的圆角胶囊卡片样式，适合在个人页和用户中心复用
class StatBadgeView_Epoch: UIView {

    /// 数值标签
    private let valueLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.textAlignment = .center
        return label_Epoch
    }()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.textAlignment = .center
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.92)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 10)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 18
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置统计内容
    /// - Parameters:
    ///   - value_Epoch: 数值文本
    ///   - title_Epoch: 标题文本
    func configure_Epoch(value_Epoch: String, title_Epoch: String) {
        valueLabel_Epoch.text = value_Epoch
        titleLabel_Epoch.text = title_Epoch
    }

    /// 构建布局
    private func setupUI_Epoch() {
        let stackView_Epoch = UIStackView(arrangedSubviews: [valueLabel_Epoch, titleLabel_Epoch])
        stackView_Epoch.axis = .vertical
        stackView_Epoch.alignment = .fill
        stackView_Epoch.spacing = 4
        addSubview(stackView_Epoch)

        stackView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}
