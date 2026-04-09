import Foundation
import UIKit
import SnapKit
import FSPagerView

// MARK: - 生活整理小技巧数据模型

/// 生活整理技巧数据模型
/// 功能：承载翻转卡片的正面与背面内容及主题色
struct HomeTip_Tidy {
    /// emoji 图标（正面展示）
    let icon_Tidy: String
    /// 卡片正面标题
    let title_Tidy: String
    /// 卡片背面详细内容
    let content_Tidy: String
    /// 主题色（渐变基色）
    let color_Tidy: UIColor
}

// MARK: - Header Cell

/// 首页渐变 Header 单元格（已移除统计数字区，避免遮盖下方内容）
/// 功能：展示问候语、用户名、标语及装饰元素
/// 设计：圆弧底边渐变卡片 + 多层装饰圆
class HomeHeaderCell_Tidy: UICollectionViewCell {

    // MARK: 背景与遮罩
    private var gradientLayer_Tidy: CAGradientLayer?
    private let bottomCurveView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()

    // MARK: 装饰圆
    private let decorCircleA_Tidy = makeDecorCircle_s(size: 140, alpha: 0.18)
    private let decorCircleB_Tidy = makeDecorCircle_s(size: 90,  alpha: 0.13)
    private let decorCircleC_Tidy = makeDecorCircle_s(size: 60,  alpha: 0.20)
    private let decorDot1_Tidy    = makeDecorCircle_s(size: 12,  alpha: 0.35)
    private let decorDot2_Tidy    = makeDecorCircle_s(size: 8,   alpha: 0.28)
    private let decorRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 45
        return v
    }()
    /// 第二个描边环（左侧，增加层次感）
    private let decorRing2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 30
        return v
    }()

    // MARK: 日期徽章
    /// 今日日期胶囊（如：MON · MAR 24）
    private let dateBadge_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 11
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        v.layer.borderWidth = 1
        return v
    }()
    private let dateBadgeLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = UIColor.white.withAlphaComponent(0.92)
        lb.textAlignment = .center
        return lb
    }()

    // MARK: 头像区域（使用 CurrentUserAvatarView_Tidy 展示当前登录用户头像）
    /// 白色描边环容器，包裹头像视图
    private let avatarRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 18
        v.isUserInteractionEnabled = true
        return v
    }()
    /// 当前用户头像视图（自动监听用户状态变化并刷新）
    private let avatarView_Tidy: CurrentUserAvatarView_Tidy = CurrentUserAvatarView_Tidy()

    // MARK: 外部事件回调

    /// 点击铃声按钮的回调（由外部 VC 注入，切换到消息列表 Tab）
    var onBellTapped_Tidy: (() -> Void)?

    /// 点击登录用户头像的回调（由外部 VC 注入，切换到我的 Tab）
    var onAvatarTapped_Tidy: (() -> Void)?

    // MARK: 铃铛
    private let bellButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "bell.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: 文字
    private let greetingLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.8)
        return lb
    }()
    private let userNameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 23, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let taglineLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Tidy · Organize · Inspire ✨"
        lb.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.65)
        return lb
    }()

    // MARK: 工具方法（static，避免在 init 之前调用 self）
    private static func makeDecorCircle_s(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        return v
    }

    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Tidy?.frame = contentView.bounds
        updateCurveLayer_Tidy()
    }

    // MARK: UI 搭建
    private func setupUI_Tidy() {
        contentView.clipsToBounds = false

        // 渐变背景
        let grad = UIColor.createTidyMintGradientLayer_Tidy(
            frame_Tidy: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180),
            isHorizontal_Tidy: false
        )
        contentView.layer.insertSublayer(grad, at: 0)
        gradientLayer_Tidy = grad

        // 底部圆弧白色覆盖
        contentView.addSubview(bottomCurveView_Tidy)

        // 装饰圆、描边环和第二环
        [decorCircleA_Tidy, decorCircleB_Tidy, decorCircleC_Tidy,
         decorDot1_Tidy, decorDot2_Tidy, decorRing_Tidy,
         decorRing2_Tidy].forEach { contentView.addSubview($0) }

        decorCircleA_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-44)
            make.trailing.equalToSuperview().offset(32)
        }
        decorCircleB_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-62)
        }
        decorCircleC_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-26)
            make.leading.equalToSuperview().offset(6)
        }
        decorDot1_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(98)
        }
        decorDot2_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(8)
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(158)
        }
        decorRing_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(-48)
        }
        decorRing2_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(-26)
        }

        // 铃铛
        contentView.addSubview(bellButton_Tidy)
        bellButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(14)
            make.width.height.equalTo(36)
        }

        // 头像（CurrentUserAvatarView 内嵌于白色描边环容器，尺寸缩小至 36×36 与铃铛按钮等高）
        avatarRing_Tidy.addSubview(avatarView_Tidy)
        contentView.addSubview(avatarRing_Tidy)

        avatarView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        avatarRing_Tidy.snp.makeConstraints { make in
            make.trailing.equalTo(bellButton_Tidy.snp.leading).offset(-8)
            make.centerY.equalTo(bellButton_Tidy)
            make.width.height.equalTo(36)
        }

        // 铃铛按钮事件
        bellButton_Tidy.addTarget(self, action: #selector(bellTapped_Tidy), for: .touchUpInside)

        // 头像点击手势
        let avatarTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Tidy))
        avatarRing_Tidy.addGestureRecognizer(avatarTap_Tidy)

        // 文字
        contentView.addSubview(greetingLabel_Tidy)
        contentView.addSubview(userNameLabel_Tidy)
        contentView.addSubview(taglineLabel_Tidy)
        greetingLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
        }
        userNameLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(greetingLabel_Tidy.snp.bottom).offset(3)
        }
        taglineLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(userNameLabel_Tidy.snp.bottom).offset(4)
        }

        // 日期徽章（紧贴标语下方左对齐）
        dateBadge_Tidy.addSubview(dateBadgeLabel_Tidy)
        contentView.addSubview(dateBadge_Tidy)
        dateBadgeLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        dateBadge_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(taglineLabel_Tidy.snp.bottom).offset(8)
            make.height.equalTo(22)
        }

        // 底部曲线遮罩视图（叠在最上层）
        bottomCurveView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview()
        }
        contentView.bringSubviewToFront(bottomCurveView_Tidy)
    }

    /// 绘制底部圆弧遮罩
    private func updateCurveLayer_Tidy() {
        bottomCurveView_Tidy.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let width = contentView.bounds.width
        let h: CGFloat = 28
        let mask = CAShapeLayer()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: h))
        path.addLine(to: CGPoint(x: width, y: h))
        path.addLine(to: CGPoint(x: width, y: h * 0.4))
        path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.4),
                          controlPoint: CGPoint(x: width / 2, y: -h * 0.6))
        path.close()
        mask.path = path.cgPath
        bottomCurveView_Tidy.layer.mask = mask
    }

    // MARK: 数据填充
    /// 填充 Header 内容（不含统计数据）
    /// - Parameter userName_tidy: 当前用户名
    func configure_Tidy(userName_tidy: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        greetingLabel_Tidy.text = hour < 12 ? "Good morning ☀️" : hour < 18 ? "Good afternoon 🌿" : "Good evening 🌙"
        userNameLabel_Tidy.text = userName_tidy
        // 今日日期徽章文字
        let dateFmt_tidy = DateFormatter()
        dateFmt_tidy.dateFormat = "EEE · MMM d"
        dateBadgeLabel_Tidy.text = dateFmt_tidy.string(from: Date()).uppercased()
    }

    // MARK: 按钮响应

    /// 铃声按钮点击 - 触发外部切换到消息列表 Tab 的回调
    @objc private func bellTapped_Tidy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onBellTapped_Tidy?()
    }

    /// 头像点击 - 触发外部切换到我的 Tab 的回调
    @objc private func avatarTapped_Tidy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Tidy?()
    }
}

// MARK: - Banner 容器 Cell（含页码指示点）

/// 首页 FSPagerView 容器单元格
/// 功能：封装 FSPagerView 并在底部展示自定义分页指示点
class HomeBannerContainerCell_Tidy: UICollectionViewCell {

    private let sectionLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Featured Picks"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let hotBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "  🔥 HOT  "
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = ColorConfig_Tidy.tidyWarm_Tidy
        lb.backgroundColor = ColorConfig_Tidy.tidyWarm_Tidy.withAlphaComponent(0.12)
        lb.layer.cornerRadius = 8
        lb.clipsToBounds = true
        return lb
    }()

    let pagerView_Tidy: FSPagerView = {
        let pv = FSPagerView()
        pv.transformer = FSPagerViewTransformer(type: .overlap)
        pv.automaticSlidingInterval = 3.5
        pv.isInfinite = true
        return pv
    }()

    private let pageIndicatorStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .center
        return sv
    }()

    var currentPage_Tidy: Int = 0 { didSet { updateIndicator_Tidy() } }
    var totalPages_Tidy: Int = 0  { didSet { rebuildIndicator_Tidy() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }

    private func setupUI_Tidy() {
        contentView.addSubview(sectionLabel_Tidy)
        contentView.addSubview(hotBadge_Tidy)
        sectionLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(4)
        }
        hotBadge_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(sectionLabel_Tidy)
            make.leading.equalTo(sectionLabel_Tidy.snp.trailing).offset(8)
            make.height.equalTo(20)
        }
        contentView.addSubview(pagerView_Tidy)
        pagerView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Tidy.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }
        contentView.addSubview(pageIndicatorStack_Tidy)
        pageIndicatorStack_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(8)
        }
    }

    private func rebuildIndicator_Tidy() {
        pageIndicatorStack_Tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<totalPages_Tidy {
            let dot = UIView()
            dot.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.4)
            dot.layer.cornerRadius = 4
            pageIndicatorStack_Tidy.addArrangedSubview(dot)
            dot.snp.makeConstraints { make in
                make.width.equalTo(8)
                make.height.equalTo(8)
            }
        }
        updateIndicator_Tidy()
    }

    private func updateIndicator_Tidy() {
        for (idx, dot) in pageIndicatorStack_Tidy.arrangedSubviews.enumerated() {
            let isCurrent = idx == currentPage_Tidy
            UIView.animate(withDuration: 0.25) {
                dot.snp.updateConstraints { make in make.width.equalTo(isCurrent ? 20 : 8) }
                dot.backgroundColor = isCurrent
                    ? ColorConfig_Tidy.tidyMint_Tidy
                    : ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.3)
                dot.layer.cornerRadius = 4
                self.pageIndicatorStack_Tidy.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Section 标题 Cell

/// Section 分区标题单元格
/// 功能：左侧渐变竖条 + 标题 + 右侧"See All"按钮
class HomeSectionTitleCell_Tidy: UICollectionViewCell {

    var onSeeAllTapped_Tidy: (() -> Void)?

    private let accentBar_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()
    /// 强调竖条渐变层
    private var accentBarGrad_Tidy: CAGradientLayer?
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()
    private let seeAllButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.title = "See All"
        config.image = UIImage(systemName: "chevron.right",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        config.imagePlacement = .trailing
        config.imagePadding = 3
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            a.foregroundColor = ColorConfig_Tidy.tidyMint_Tidy
            return a
        }
        config.baseForegroundColor = ColorConfig_Tidy.tidyMint_Tidy
        btn.configuration = config
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        accentBarGrad_Tidy?.frame = accentBar_Tidy.bounds
    }

    private func setupUI_Tidy() {
        contentView.addSubview(accentBar_Tidy)
        contentView.addSubview(titleLabel_Tidy)
        contentView.addSubview(subtitleLabel_Tidy)
        contentView.addSubview(seeAllButton_Tidy)

        // 强调竖条渐变（薄荷绿 → 深海蓝）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                       UIColor(hexstring_Tidy: "#2D7DD2").cgColor]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        accentBar_Tidy.layer.insertSublayer(grad, at: 0)
        accentBarGrad_Tidy = grad

        accentBar_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Tidy.snp.trailing).offset(10)
            make.centerY.equalToSuperview().offset(-6)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Tidy)
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(1)
        }
        seeAllButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        seeAllButton_Tidy.addTarget(self, action: #selector(seeAllTapped_Tidy), for: .touchUpInside)
    }

    @objc private func seeAllTapped_Tidy() { onSeeAllTapped_Tidy?() }

    /// 配置标题、副标题及是否显示查看全部按钮
    /// - Parameters:
    ///   - title_tidy: 主标题文字
    ///   - subtitle_tidy: 副标题文字（可选）
    ///   - showSeeAll_tidy: 是否显示查看全部按钮，默认 true
    func configure_Tidy(title_tidy: String, subtitle_tidy: String = "", showSeeAll_tidy: Bool = true) {
        titleLabel_Tidy.text = title_tidy
        subtitleLabel_Tidy.text = subtitle_tidy
        seeAllButton_Tidy.isHidden = !showSeeAll_tidy
    }
}

// MARK: - 打卡记录 Cell

/// 首页打卡记录单元格
/// 功能：展示连续打卡天数、本周七日打卡状态及今日打卡按钮
/// 设计：白色圆角卡片 + 左侧连续天数 + 右侧操作按钮 + 底部本周打点行
class HomeCheckinCell_Tidy: UICollectionViewCell {

    /// 今日打卡按钮点击回调
    var onCheckInTapped_Tidy: (() -> Void)?

    // MARK: 卡片容器
    private let cardView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.20).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        v.clipsToBounds = false
        return v
    }()
    /// 卡片背景极淡薄荷渐变层
    private var cardBgGrad_Tidy: CAGradientLayer?
    /// 左侧渐变强调条
    private let leftStrip_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()
    private var stripGradLayer_Tidy: CAGradientLayer?

    // MARK: 激励文字
    private let motivationLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.tidyMint_Tidy
        return lb
    }()

    // MARK: 火焰与连续天数
    private let flameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "🔥"
        lb.font = UIFont.systemFont(ofSize: 26)
        return lb
    }()
    private let streakValueLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let streakUnitLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Day Streak"
        lb.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    // MARK: 本周打卡点行
    private let weekStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: 打卡按钮
    private let checkInButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return btn
    }()
    private var btnGradLayer_Tidy: CAGradientLayer?

    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        btnGradLayer_Tidy?.frame = checkInButton_Tidy.bounds
        stripGradLayer_Tidy?.frame = leftStrip_Tidy.bounds
        cardBgGrad_Tidy?.frame = cardView_Tidy.bounds
    }

    // MARK: UI 搭建
    private func setupUI_Tidy() {
        backgroundColor = .clear
        contentView.clipsToBounds = false

        contentView.addSubview(cardView_Tidy)
        cardView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 卡片背景极淡薄荷渐变（白 → 极淡薄荷）
        let bgGrad = CAGradientLayer()
        bgGrad.colors = [UIColor.white.cgColor,
                         UIColor(hexstring_Tidy: "#F0FDF9").cgColor]
        bgGrad.startPoint = CGPoint(x: 0, y: 0)
        bgGrad.endPoint   = CGPoint(x: 1, y: 1)
        bgGrad.cornerRadius = 18
        cardView_Tidy.layer.insertSublayer(bgGrad, at: 0)
        cardBgGrad_Tidy = bgGrad

        // 左侧渐变强调条（薄荷绿 → 深青）
        let stripGrad = CAGradientLayer()
        stripGrad.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                            UIColor(hexstring_Tidy: "#2C9E96").cgColor]
        stripGrad.startPoint = CGPoint(x: 0.5, y: 0)
        stripGrad.endPoint   = CGPoint(x: 0.5, y: 1)
        leftStrip_Tidy.layer.insertSublayer(stripGrad, at: 0)
        stripGradLayer_Tidy = stripGrad
        cardView_Tidy.addSubview(leftStrip_Tidy)
        leftStrip_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // 火焰 + 连续天数
        cardView_Tidy.addSubview(flameLabel_Tidy)
        cardView_Tidy.addSubview(streakValueLabel_Tidy)
        cardView_Tidy.addSubview(streakUnitLabel_Tidy)
        cardView_Tidy.addSubview(motivationLabel_Tidy)

        flameLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(16)
        }
        streakValueLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy.snp.trailing).offset(8)
            make.centerY.equalTo(flameLabel_Tidy)
        }
        streakUnitLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy)
            make.top.equalTo(flameLabel_Tidy.snp.bottom).offset(1)
        }
        motivationLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy)
            make.top.equalTo(streakUnitLabel_Tidy.snp.bottom).offset(3)
        }

        // 本周打卡点（leading 留出左侧强调条的 5px 宽度）
        cardView_Tidy.addSubview(weekStack_Tidy)
        weekStack_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-120)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(28)
        }
        buildWeekDots_Tidy()

        // 打卡按钮（渐变背景）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                       UIColor(hexstring_Tidy: "#2C9E96").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 14
        checkInButton_Tidy.layer.insertSublayer(grad, at: 0)
        btnGradLayer_Tidy = grad

        checkInButton_Tidy.layer.shadowColor = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.35).cgColor
        checkInButton_Tidy.layer.shadowOffset = CGSize(width: 0, height: 4)
        checkInButton_Tidy.layer.shadowRadius = 8
        checkInButton_Tidy.layer.shadowOpacity = 1

        cardView_Tidy.addSubview(checkInButton_Tidy)
        checkInButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        checkInButton_Tidy.addTarget(self, action: #selector(onCheckInTapped_handler_Tidy), for: .touchUpInside)
    }

    /// 构建本周七日打卡点（M/T/W/T/F/S/S + 圆点）
    private func buildWeekDots_Tidy() {
        weekStack_Tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let days_tidy = ["M", "T", "W", "T", "F", "S", "S"]
        for day in days_tidy {
            let col = UIView()
            let dot = UIView()
            dot.layer.cornerRadius = 5
            dot.backgroundColor = ColorConfig_Tidy.divider_Tidy

            let dayLb = UILabel()
            dayLb.text = day
            dayLb.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            dayLb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
            dayLb.textAlignment = .center

            col.addSubview(dot)
            col.addSubview(dayLb)
            dot.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.height.equalTo(10)
            }
            dayLb.snp.makeConstraints { make in
                make.top.equalTo(dot.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            weekStack_Tidy.addArrangedSubview(col)
        }
    }

    @objc private func onCheckInTapped_handler_Tidy() {
        checkInButton_Tidy.animatePulse_Tidy()
        onCheckInTapped_Tidy?()
    }

    /// 配置打卡单元格数据
    /// - Parameters:
    ///   - streak_tidy: 连续打卡天数
    ///   - isCheckedToday_tidy: 今日是否已打卡
    ///   - weekRecord_tidy: 本周七天打卡状态数组（长度 7，周一起始）
    func configure_Tidy(streak_tidy: Int,
                            isCheckedToday_tidy: Bool,
                            weekRecord_tidy: [Bool]) {
        streakValueLabel_Tidy.text = "\(streak_tidy)"

        // 根据连续天数生成差异化激励文字
        switch streak_tidy {
        case 0:        motivationLabel_Tidy.text = "Start your streak today! 🌟"
        case 1...2:    motivationLabel_Tidy.text = "Great start! Keep going 🌿"
        case 3...6:    motivationLabel_Tidy.text = "You're on a roll! 💪"
        case 7...13:   motivationLabel_Tidy.text = "One week strong! 🔥"
        case 14...29:  motivationLabel_Tidy.text = "Incredible consistency! ⚡️"
        default:       motivationLabel_Tidy.text = "Tidy champion! 🏆"
        }

        // 按钮状态
        if isCheckedToday_tidy {
            checkInButton_Tidy.setTitle("✓ Done", for: .normal)
            checkInButton_Tidy.setTitleColor(.white, for: .normal)
            checkInButton_Tidy.alpha = 0.55
            checkInButton_Tidy.isUserInteractionEnabled = false
        } else {
            checkInButton_Tidy.setTitle("Check In", for: .normal)
            checkInButton_Tidy.setTitleColor(.white, for: .normal)
            checkInButton_Tidy.alpha = 1.0
            checkInButton_Tidy.isUserInteractionEnabled = true
        }

        // 本周打卡点颜色
        for (i, col) in weekStack_Tidy.arrangedSubviews.enumerated() {
            let checked = i < weekRecord_tidy.count && weekRecord_tidy[i]
            if let dot = col.subviews.first {
                dot.backgroundColor = checked
                    ? ColorConfig_Tidy.tidyMint_Tidy
                    : ColorConfig_Tidy.divider_Tidy
            }
        }
    }
}

// MARK: - 生活技巧翻转卡片 Cell

/// 生活整理小技巧翻转卡片单元格
/// 功能：正面展示图标与标题，背面展示详细技巧内容，点击触发 3D 翻转动画
/// 设计：正面彩色渐变 + 背面白色；UIView.transition 实现翻转效果
class HomeTipCardCell_Tidy: UICollectionViewCell {

    // MARK: 翻转状态
    private var isFlipped_Tidy = false

    // MARK: 正面
    private let frontView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()
    private var frontGradLayer_Tidy: CAGradientLayer?
    /// 正面顶部斜向光泽层（白色→透明对角渐变）
    private let frontShineLayer_Tidy = CAGradientLayer()

    private let frontEmojiLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 38)
        lb.textAlignment = .center
        return lb
    }()
    private let frontTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    /// 正面底部翻转提示图标
    private let frontHintIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.image = UIImage(systemName: "hand.tap.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.65)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: 背面
    private let backView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()
    private let backEmojiLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22)
        lb.textAlignment = .center
        return lb
    }()
    private let backContentLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    private let backHintLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Tap to flip back"
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        lb.textAlignment = .center
        return lb
    }()
    /// 背面顶部颜色条
    private let backAccentBar_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        frontGradLayer_Tidy?.frame = frontView_Tidy.bounds
        // 光泽层覆盖正面左上三角区域
        frontShineLayer_Tidy.frame = frontView_Tidy.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置翻转状态
        isFlipped_Tidy = false
        frontView_Tidy.isHidden = false
        backView_Tidy.isHidden  = true
        frontGradLayer_Tidy?.removeFromSuperlayer()
        frontGradLayer_Tidy = nil
        frontShineLayer_Tidy.removeFromSuperlayer()
    }

    // MARK: UI 搭建
    private func setupUI_Tidy() {
        contentView.layer.shadowColor  = ColorConfig_Tidy.shadowColor_Tidy.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 1
        contentView.clipsToBounds = false

        // 正面
        contentView.addSubview(frontView_Tidy)
        frontView_Tidy.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 配置光泽层（白色→透明对角渐变，叠加在渐变色上形成高光感）
        frontShineLayer_Tidy.colors = [UIColor.white.withAlphaComponent(0.22).cgColor,
                                           UIColor.white.withAlphaComponent(0.04).cgColor,
                                           UIColor.clear.cgColor]
        frontShineLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        frontShineLayer_Tidy.endPoint   = CGPoint(x: 1, y: 1)
        frontShineLayer_Tidy.locations  = [0, 0.45, 1.0]

        frontView_Tidy.addSubview(frontEmojiLabel_Tidy)
        frontView_Tidy.addSubview(frontTitleLabel_Tidy)
        frontView_Tidy.addSubview(frontHintIconView_Tidy)

        frontEmojiLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        frontTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(frontEmojiLabel_Tidy.snp.bottom).offset(8)
        }
        frontHintIconView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(16)
        }

        // 背面
        contentView.addSubview(backView_Tidy)
        backView_Tidy.snp.makeConstraints { $0.edges.equalToSuperview() }

        backView_Tidy.addSubview(backAccentBar_Tidy)
        backView_Tidy.addSubview(backEmojiLabel_Tidy)
        backView_Tidy.addSubview(backContentLabel_Tidy)
        backView_Tidy.addSubview(backHintLabel_Tidy)

        backAccentBar_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        backEmojiLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18)
        }
        backContentLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalTo(backEmojiLabel_Tidy.snp.bottom).offset(8)
        }
        backHintLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }

        // 点击翻转手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Tidy))
        contentView.addGestureRecognizer(tap)
    }

    /// 点击翻转（3D 翻转动画）
    @objc private func handleCardTap_Tidy() {
        isFlipped_Tidy.toggle()
        let fromView = isFlipped_Tidy ? frontView_Tidy : backView_Tidy
        let toView   = isFlipped_Tidy ? backView_Tidy  : frontView_Tidy
        let option: UIView.AnimationOptions = isFlipped_Tidy ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: contentView, duration: 0.5, options: [option], animations: {
            fromView.isHidden = true
            toView.isHidden   = false
        }, completion: nil)
    }

    /// 配置技巧卡片内容
    /// - Parameter tip_tidy: 技巧数据模型
    func configure_Tidy(tip_tidy: HomeTip_Tidy) {
        // 重置状态
        isFlipped_Tidy = false
        frontView_Tidy.isHidden = false
        backView_Tidy.isHidden  = true

        // 更新正面渐变（主色 → 浅色，增强颜色层次）
        frontGradLayer_Tidy?.removeFromSuperlayer()
        frontShineLayer_Tidy.removeFromSuperlayer()
        let grad = CAGradientLayer()
        grad.colors = [tip_tidy.color_Tidy.cgColor,
                       tip_tidy.color_Tidy.withAlphaComponent(0.70).cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 16
        frontView_Tidy.layer.insertSublayer(grad, at: 0)
        frontGradLayer_Tidy = grad
        // 光泽层插在渐变层之上（index 1）
        frontView_Tidy.layer.insertSublayer(frontShineLayer_Tidy, at: 1)

        // 填充内容
        frontEmojiLabel_Tidy.text   = tip_tidy.icon_Tidy
        frontTitleLabel_Tidy.text   = tip_tidy.title_Tidy
        backEmojiLabel_Tidy.text    = tip_tidy.icon_Tidy
        backContentLabel_Tidy.text  = tip_tidy.content_Tidy
        backContentLabel_Tidy.textColor = tip_tidy.color_Tidy
        backAccentBar_Tidy.backgroundColor = tip_tidy.color_Tidy

        // 延迟刷新渐变尺寸（等待布局完成）
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            grad.frame = self.frontView_Tidy.bounds
        }
    }
}

// MARK: - 首页 ViewController

/// 首页页面
/// 功能：欢迎 Header + 精选 Banner + 打卡记录区 + 生活整理技巧翻转卡片
/// 设计思路：CompositionalLayout 六区段，NotificationCenter 驱动 ViewModel 更新
class Home_Tidy: UIViewController {

    // MARK: Section 枚举
    private enum Section_Tidy: Int, CaseIterable {
        case header_tidy       = 0
        case banner_tidy       = 1
        case checkinTitle_tidy = 2
        case checkin_tidy      = 3
        case tipsTitle_tidy    = 4
        case tips_tidy         = 5
    }

    // MARK: Cell ID
    private let idHeader_Tidy    = "HomeHeaderCell"
    private let idBanner_Tidy    = "HomeBannerContainer"
    private let idSecTitle_Tidy  = "HomeSectionTitle"
    private let idCheckin_Tidy   = "HomeCheckinCell"
    private let idTip_Tidy       = "HomeTipCardCell"

    // MARK: 生活整理技巧数据（预置 8 条）
    private let tipsList_Tidy: [HomeTip_Tidy] = [
        HomeTip_Tidy(
            icon_Tidy: "🧺",
            title_Tidy: "One-Minute Rule",
            content_Tidy: "If a task takes less than 60 seconds, do it right now. Put items back immediately after use.",
            color_Tidy: ColorConfig_Tidy.categoryKitchen_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "🗂️",
            title_Tidy: "Zone Your Space",
            content_Tidy: "Assign specific areas for activities. Items used together should live in the same zone.",
            color_Tidy: ColorConfig_Tidy.categoryStudy_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "✨",
            title_Tidy: "5S Method",
            content_Tidy: "Sort · Set in Order · Shine · Standardize · Sustain — a proven system for lasting order.",
            color_Tidy: ColorConfig_Tidy.tidyMint_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "📦",
            title_Tidy: "One In, One Out",
            content_Tidy: "When a new item arrives, one old item leaves. Prevents gradual clutter accumulation.",
            color_Tidy: ColorConfig_Tidy.categoryBedroom_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "🌿",
            title_Tidy: "Sunday Reset",
            content_Tidy: "Spend 30 minutes every Sunday tidying common areas. Small effort, lasting difference.",
            color_Tidy: ColorConfig_Tidy.categoryGarden_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "🎯",
            title_Tidy: "Everything Has a Home",
            content_Tidy: "Assign a specific spot for every item. If something has no place, find one or let it go.",
            color_Tidy: ColorConfig_Tidy.categoryLivingRoom_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "🚿",
            title_Tidy: "Clean As You Go",
            content_Tidy: "Wipe surfaces right after use. Prevents buildup and saves major cleaning time later.",
            color_Tidy: ColorConfig_Tidy.categoryBathroom_Tidy
        ),
        HomeTip_Tidy(
            icon_Tidy: "🏷️",
            title_Tidy: "Label Everything",
            content_Tidy: "Labels help you find things fast and remind everyone where items truly belong.",
            color_Tidy: ColorConfig_Tidy.categoryStorage_Tidy
        ),
    ]

    // MARK: 数据
    private var featuredPosts_Tidy: [TitleModel_Tidy] = []

    // MARK: UI
    private var collectionView_Tidy: UICollectionView!
    private weak var bannerCell_Tidy: HomeBannerContainerCell_Tidy?

    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupCollectionView_Tidy()
        loadData_Tidy()
        setupNotifications_Tidy()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 统一管理，避免与子页面 setNavigationBarHidden(false) 状态冲突
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 刷新打卡区（今日打卡状态可能已变）
        collectionView_Tidy.reloadSections(
            IndexSet(integer: Section_Tidy.checkin_tidy.rawValue)
        )
    }

    // MARK: 数据加载
    private func loadData_Tidy() {
        Task { @MainActor in
            featuredPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getFeaturedPosts_Tidy()
            collectionView_Tidy.reloadData()
            runEntranceAnimation_Tidy()
        }
    }

    // MARK: 通知
    private func setupNotifications_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleChanged_Tidy),
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserChanged_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy, object: nil
        )
    }
    @objc private func onTitleChanged_Tidy() {
        featuredPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getFeaturedPosts_Tidy()
        collectionView_Tidy.reloadSections(IndexSet(integer: Section_Tidy.banner_tidy.rawValue))
    }
    @objc private func onUserChanged_Tidy() {
        // 用户状态变化时刷新 Header 和打卡区
        collectionView_Tidy.reloadSections(
            IndexSet([Section_Tidy.header_tidy.rawValue,
                      Section_Tidy.checkin_tidy.rawValue])
        )
    }

    // MARK: CollectionView 搭建
    private func setupCollectionView_Tidy() {
        collectionView_Tidy = UICollectionView(frame: .zero,
                                                   collectionViewLayout: makeLayout_Tidy())
        collectionView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        collectionView_Tidy.showsVerticalScrollIndicator = false
        collectionView_Tidy.contentInsetAdjustmentBehavior = .never
        collectionView_Tidy.delegate   = self
        collectionView_Tidy.dataSource = self

        collectionView_Tidy.register(HomeHeaderCell_Tidy.self,          forCellWithReuseIdentifier: idHeader_Tidy)
        collectionView_Tidy.register(HomeBannerContainerCell_Tidy.self, forCellWithReuseIdentifier: idBanner_Tidy)
        collectionView_Tidy.register(HomeSectionTitleCell_Tidy.self,    forCellWithReuseIdentifier: idSecTitle_Tidy)
        collectionView_Tidy.register(HomeCheckinCell_Tidy.self,         forCellWithReuseIdentifier: idCheckin_Tidy)
        collectionView_Tidy.register(HomeTipCardCell_Tidy.self,         forCellWithReuseIdentifier: idTip_Tidy)

        let refresh = UIRefreshControl()
        refresh.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        refresh.addTarget(self, action: #selector(onRefresh_Tidy(_:)), for: .valueChanged)
        collectionView_Tidy.refreshControl = refresh
        collectionView_Tidy.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        view.addSubview(collectionView_Tidy)
        collectionView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    @objc private func onRefresh_Tidy(_ sender: UIRefreshControl) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            featuredPosts_Tidy = TitleViewModel_Tidy.shared_Tidy.getFeaturedPosts_Tidy()
            collectionView_Tidy.reloadData()
            sender.endRefreshing()
            collectionView_Tidy.animateFadeIn_Tidy(duration_Tidy: 0.3)
        }
    }

    // MARK: CompositionalLayout
    private func makeLayout_Tidy() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] idx, _ in
            guard let self, let sec = Section_Tidy(rawValue: idx) else { return nil }
            switch sec {
            case .header_tidy:       return self.layoutHeader_Tidy()
            case .banner_tidy:       return self.layoutBanner_Tidy()
            case .checkinTitle_tidy: return self.layoutSingleRow_Tidy(height: 52)
            case .checkin_tidy:      return self.layoutCheckin_Tidy()
            case .tipsTitle_tidy:    return self.layoutSingleRow_Tidy(height: 52)
            case .tips_tidy:         return self.layoutTips_Tidy()
            }
        }
    }

    private func layoutHeader_Tidy() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)), subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    private func layoutBanner_Tidy() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(244)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(244)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 6, leading: 0, bottom: 0, trailing: 0)
        return sec
    }
    private func layoutSingleRow_Tidy(height: CGFloat) -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 12, leading: 0, bottom: 0, trailing: 0)
        return sec
    }
    private func layoutCheckin_Tidy() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 6, leading: 16, bottom: 4, trailing: 16)
        return sec
    }
    private func layoutTips_Tidy() -> NSCollectionLayoutSection {
        let w     = (UIScreen.main.bounds.width - 16 * 2 - 14) / 2
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(w), heightDimension: .absolute(190)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(190)), subitems: [item, item])
        group.interItemSpacing = .fixed(14)
        let sec = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 4, leading: 16, bottom: 40, trailing: 16)
        sec.interGroupSpacing = 14
        return sec
    }

    // MARK: 入场动画
    private func runEntranceAnimation_Tidy() {
        Section_Tidy.allCases.enumerated().forEach { idx, sec in
            let ip = IndexPath(item: 0, section: sec.rawValue)
            collectionView_Tidy.cellForItem(at: ip)?
                .animateSlideInFromBottom_Tidy(offset_Tidy: 40,
                                                   delay_Tidy: Double(idx) * 0.07)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDataSource

extension Home_Tidy: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section_Tidy.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let sec = Section_Tidy(rawValue: section) else { return 0 }
        switch sec {
        case .header_tidy:       return 1
        case .banner_tidy:       return featuredPosts_Tidy.isEmpty ? 0 : 1
        case .checkinTitle_tidy: return 1
        case .checkin_tidy:      return 1
        case .tipsTitle_tidy:    return 1
        case .tips_tidy:         return tipsList_Tidy.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sec = Section_Tidy(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch sec {

        // Header（仅用户名，无统计）
        case .header_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idHeader_Tidy, for: indexPath) as! HomeHeaderCell_Tidy
            let user = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
            cell.configure_Tidy(userName_tidy: user.userName_Tidy ?? "Welcome")
            /// 铃声按钮 → 切换到消息列表 Tab（index 3）
            cell.onBellTapped_Tidy = { [weak self] in
                (self?.tabBarController as? TabBar_Tidy)?.switchTab_Tidy(to: 3)
            }
            /// 用户头像 → 切换到我的 Tab（index 4）
            cell.onAvatarTapped_Tidy = { [weak self] in
                (self?.tabBarController as? TabBar_Tidy)?.switchTab_Tidy(to: 4)
            }
            return cell

        // Banner 轮播
        case .banner_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idBanner_Tidy, for: indexPath) as! HomeBannerContainerCell_Tidy
            bannerCell_Tidy = cell
            cell.totalPages_Tidy = featuredPosts_Tidy.count
            cell.pagerView_Tidy.dataSource = self
            cell.pagerView_Tidy.delegate   = self
            cell.pagerView_Tidy.register(HomeBannerCell_Tidy.self, forCellWithReuseIdentifier: "BannerPage")
            cell.pagerView_Tidy.itemSize = CGSize(width: UIScreen.main.bounds.width - 56, height: 190)
            cell.pagerView_Tidy.reloadData()
            return cell

        // 打卡区标题
        case .checkinTitle_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Tidy, for: indexPath) as! HomeSectionTitleCell_Tidy
            cell.configure_Tidy(title_tidy: "Check-In", subtitle_tidy: "Daily tidy habit tracker", showSeeAll_tidy: true)
            cell.onSeeAllTapped_Tidy = { [weak self] in
                guard let self else { return }
                let historyVC = CheckinHistory_Tidy()
                Navigation_Tidy.push_Tidy(to: historyVC, from: self)
            }
            return cell

        // 打卡记录卡片
        case .checkin_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCheckin_Tidy, for: indexPath) as! HomeCheckinCell_Tidy
            let vm = UserViewModel_Tidy.shared_Tidy
            cell.configure_Tidy(
                streak_tidy: vm.getCheckinStreak_Tidy(),
                isCheckedToday_tidy: vm.hasCheckedInToday_Tidy(),
                weekRecord_tidy: vm.getWeekCheckinRecord_Tidy()
            )
            cell.onCheckInTapped_Tidy = { [weak self] in
                UserViewModel_Tidy.shared_Tidy.checkIn_Tidy()
                // 打卡后刷新本区域
                self?.collectionView_Tidy.reloadSections(
                    IndexSet(integer: Section_Tidy.checkin_tidy.rawValue)
                )
            }
            return cell

        // 技巧区标题（不显示查看全部）
        case .tipsTitle_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Tidy, for: indexPath) as! HomeSectionTitleCell_Tidy
            cell.configure_Tidy(title_tidy: "Life Tips", subtitle_tidy: "Tap a card to reveal the tip", showSeeAll_tidy: false)
            cell.onSeeAllTapped_Tidy = nil
            return cell

        // 技巧翻转卡片
        case .tips_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idTip_Tidy, for: indexPath) as! HomeTipCardCell_Tidy
            cell.configure_Tidy(tip_tidy: tipsList_Tidy[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Tidy: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard Section_Tidy(rawValue: indexPath.section) == .tips_tidy else { return }
        cell.animateSlideInFromBottom_Tidy(
            offset_Tidy: 24,
            delay_Tidy: Double(indexPath.item % 4) * AnimationConfig_Tidy.delayShort_Tidy
        )
    }
}

// MARK: - FSPagerView DataSource & Delegate

extension Home_Tidy: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        featuredPosts_Tidy.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "BannerPage", at: index) as! HomeBannerCell_Tidy
        cell.configure_Tidy(post_tidy: featuredPosts_Tidy[index])
        // 举报/删除完成后重新拉取数据，刷新 Banner
        cell.onMoreTapped_Tidy = { [weak self] post_tidy in
            guard let self = self else { return }
            let isMyPost_tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
                userId_tidy: post_tidy.titleUserId_Tidy
            )
            if isMyPost_tidy {
                ReportDeleteHelper_Tidy.delete_Tidy(post_Tidy: post_tidy, from: self) { [weak self] in
                    self?.loadData_Tidy()
                }
            } else {
                ReportDeleteHelper_Tidy.report_Tidy(post_Tidy: post_tidy, from: self) { [weak self] in
                    self?.loadData_Tidy()
                }
            }
        }
        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        Navigation_Tidy.toTitleDetail_Tidy(titleModel_tidy: featuredPosts_Tidy[index])
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        bannerCell_Tidy?.currentPage_Tidy = pagerView.currentIndex
    }
}
