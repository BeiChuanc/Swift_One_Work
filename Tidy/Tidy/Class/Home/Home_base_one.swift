import Foundation
import UIKit
import SnapKit
import FSPagerView

// MARK: - 生活整理小技巧数据模型

/// 生活整理技巧数据模型
/// 功能：承载翻转卡片的正面与背面内容及主题色
struct HomeTip_Base_one {
    /// emoji 图标（正面展示）
    let icon_Base_one: String
    /// 卡片正面标题
    let title_Base_one: String
    /// 卡片背面详细内容
    let content_Base_one: String
    /// 主题色（渐变基色）
    let color_Base_one: UIColor
}

// MARK: - Header Cell

/// 首页渐变 Header 单元格（已移除统计数字区，避免遮盖下方内容）
/// 功能：展示问候语、用户名、标语及装饰元素
/// 设计：圆弧底边渐变卡片 + 多层装饰圆
class HomeHeaderCell_Base_one: UICollectionViewCell {

    // MARK: 背景与遮罩
    private var gradientLayer_Base_one: CAGradientLayer?
    private let bottomCurveView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return v
    }()

    // MARK: 装饰圆
    private let decorCircleA_Base_one = makeDecorCircle_s(size: 140, alpha: 0.18)
    private let decorCircleB_Base_one = makeDecorCircle_s(size: 90,  alpha: 0.13)
    private let decorCircleC_Base_one = makeDecorCircle_s(size: 60,  alpha: 0.20)
    private let decorDot1_Base_one    = makeDecorCircle_s(size: 12,  alpha: 0.35)
    private let decorDot2_Base_one    = makeDecorCircle_s(size: 8,   alpha: 0.28)
    private let decorRing_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 45
        return v
    }()
    /// 第二个描边环（左侧，增加层次感）
    private let decorRing2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        v.layer.borderWidth = 1.5
        v.layer.cornerRadius = 30
        return v
    }()

    // MARK: 日期徽章
    /// 今日日期胶囊（如：MON · MAR 24）
    private let dateBadge_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 11
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        v.layer.borderWidth = 1
        return v
    }()
    private let dateBadgeLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = UIColor.white.withAlphaComponent(0.92)
        lb.textAlignment = .center
        return lb
    }()

    // MARK: 头像区域（使用 CurrentUserAvatarView_Base_one 展示当前登录用户头像）
    /// 白色描边环容器，包裹头像视图
    private let avatarRing_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2.5
        v.layer.cornerRadius = 30
        return v
    }()
    /// 当前用户头像视图（自动监听用户状态变化并刷新）
    private let avatarView_Base_one: CurrentUserAvatarView_Base_one = CurrentUserAvatarView_Base_one()

    // MARK: 铃铛
    private let bellButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        btn.setImage(UIImage(systemName: "bell.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.9)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: 文字
    private let greetingLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.8)
        return lb
    }()
    private let userNameLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 23, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let taglineLabel_Base_one: UILabel = {
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
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Base_one?.frame = contentView.bounds
        updateCurveLayer_Base_one()
    }

    // MARK: UI 搭建
    private func setupUI_Base_one() {
        contentView.clipsToBounds = false

        // 渐变背景
        let grad = UIColor.createTidyMintGradientLayer_Base_one(
            frame_Base_one: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180),
            isHorizontal_Base_one: false
        )
        contentView.layer.insertSublayer(grad, at: 0)
        gradientLayer_Base_one = grad

        // 底部圆弧白色覆盖
        contentView.addSubview(bottomCurveView_Base_one)

        // 装饰圆、描边环和第二环
        [decorCircleA_Base_one, decorCircleB_Base_one, decorCircleC_Base_one,
         decorDot1_Base_one, decorDot2_Base_one, decorRing_Base_one,
         decorRing2_Base_one].forEach { contentView.addSubview($0) }

        decorCircleA_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.top.equalToSuperview().offset(-44)
            make.trailing.equalToSuperview().offset(32)
        }
        decorCircleB_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-62)
        }
        decorCircleC_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-26)
            make.leading.equalToSuperview().offset(6)
        }
        decorDot1_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(98)
        }
        decorDot2_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(8)
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(158)
        }
        decorRing_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.top.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(-48)
        }
        decorRing2_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(-26)
        }

        // 铃铛
        contentView.addSubview(bellButton_Base_one)
        bellButton_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(14)
            make.width.height.equalTo(36)
        }

        // 头像（CurrentUserAvatarView 内嵌于白色描边环容器）
        avatarRing_Base_one.addSubview(avatarView_Base_one)
        contentView.addSubview(avatarRing_Base_one)

        avatarView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        avatarRing_Base_one.snp.makeConstraints { make in
            make.trailing.equalTo(bellButton_Base_one.snp.leading).offset(-10)
            make.top.equalTo(bellButton_Base_one)
            make.width.height.equalTo(60)
        }

        // 文字
        contentView.addSubview(greetingLabel_Base_one)
        contentView.addSubview(userNameLabel_Base_one)
        contentView.addSubview(taglineLabel_Base_one)
        greetingLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(16)
        }
        userNameLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(greetingLabel_Base_one.snp.bottom).offset(3)
        }
        taglineLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(userNameLabel_Base_one.snp.bottom).offset(4)
        }

        // 日期徽章（紧贴标语下方左对齐）
        dateBadge_Base_one.addSubview(dateBadgeLabel_Base_one)
        contentView.addSubview(dateBadge_Base_one)
        dateBadgeLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        dateBadge_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(taglineLabel_Base_one.snp.bottom).offset(8)
            make.height.equalTo(22)
        }

        // 底部曲线遮罩视图（叠在最上层）
        bottomCurveView_Base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
            make.bottom.equalToSuperview()
        }
        contentView.bringSubviewToFront(bottomCurveView_Base_one)
    }

    /// 绘制底部圆弧遮罩
    private func updateCurveLayer_Base_one() {
        bottomCurveView_Base_one.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
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
        bottomCurveView_Base_one.layer.mask = mask
    }

    // MARK: 数据填充
    /// 填充 Header 内容（不含统计数据）
    /// - Parameter userName_base_one: 当前用户名
    func configure_Base_one(userName_base_one: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        greetingLabel_Base_one.text = hour < 12 ? "Good morning ☀️" : hour < 18 ? "Good afternoon 🌿" : "Good evening 🌙"
        userNameLabel_Base_one.text = userName_base_one
        // 今日日期徽章文字
        let dateFmt_base_one = DateFormatter()
        dateFmt_base_one.dateFormat = "EEE · MMM d"
        dateBadgeLabel_Base_one.text = dateFmt_base_one.string(from: Date()).uppercased()
    }
}

// MARK: - Banner 容器 Cell（含页码指示点）

/// 首页 FSPagerView 容器单元格
/// 功能：封装 FSPagerView 并在底部展示自定义分页指示点
class HomeBannerContainerCell_Base_one: UICollectionViewCell {

    private let sectionLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Featured Picks"
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()
    private let hotBadge_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "  🔥 HOT  "
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = ColorConfig_Base_one.tidyWarm_Base_one
        lb.backgroundColor = ColorConfig_Base_one.tidyWarm_Base_one.withAlphaComponent(0.12)
        lb.layer.cornerRadius = 8
        lb.clipsToBounds = true
        return lb
    }()

    let pagerView_Base_one: FSPagerView = {
        let pv = FSPagerView()
        pv.transformer = FSPagerViewTransformer(type: .overlap)
        pv.automaticSlidingInterval = 3.5
        pv.isInfinite = true
        return pv
    }()

    private let pageIndicatorStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 5
        sv.alignment = .center
        return sv
    }()

    var currentPage_Base_one: Int = 0 { didSet { updateIndicator_Base_one() } }
    var totalPages_Base_one: Int = 0  { didSet { rebuildIndicator_Base_one() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }

    private func setupUI_Base_one() {
        contentView.addSubview(sectionLabel_Base_one)
        contentView.addSubview(hotBadge_Base_one)
        sectionLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(4)
        }
        hotBadge_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(sectionLabel_Base_one)
            make.leading.equalTo(sectionLabel_Base_one.snp.trailing).offset(8)
            make.height.equalTo(20)
        }
        contentView.addSubview(pagerView_Base_one)
        pagerView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(sectionLabel_Base_one.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
        }
        contentView.addSubview(pageIndicatorStack_Base_one)
        pageIndicatorStack_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
            make.height.equalTo(8)
        }
    }

    private func rebuildIndicator_Base_one() {
        pageIndicatorStack_Base_one.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 0..<totalPages_Base_one {
            let dot = UIView()
            dot.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.4)
            dot.layer.cornerRadius = 4
            pageIndicatorStack_Base_one.addArrangedSubview(dot)
            dot.snp.makeConstraints { make in
                make.width.equalTo(8)
                make.height.equalTo(8)
            }
        }
        updateIndicator_Base_one()
    }

    private func updateIndicator_Base_one() {
        for (idx, dot) in pageIndicatorStack_Base_one.arrangedSubviews.enumerated() {
            let isCurrent = idx == currentPage_Base_one
            UIView.animate(withDuration: 0.25) {
                dot.snp.updateConstraints { make in make.width.equalTo(isCurrent ? 20 : 8) }
                dot.backgroundColor = isCurrent
                    ? ColorConfig_Base_one.tidyMint_Base_one
                    : ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.3)
                dot.layer.cornerRadius = 4
                self.pageIndicatorStack_Base_one.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Section 标题 Cell

/// Section 分区标题单元格
/// 功能：左侧渐变竖条 + 标题 + 右侧"See All"按钮
class HomeSectionTitleCell_Base_one: UICollectionViewCell {

    var onSeeAllTapped_Base_one: (() -> Void)?

    private let accentBar_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()
    /// 强调竖条渐变层
    private var accentBarGrad_Base_one: CAGradientLayer?
    private let titleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()
    private let subtitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()
    private let seeAllButton_Base_one: UIButton = {
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
            a.foregroundColor = ColorConfig_Base_one.tidyMint_Base_one
            return a
        }
        config.baseForegroundColor = ColorConfig_Base_one.tidyMint_Base_one
        btn.configuration = config
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        accentBarGrad_Base_one?.frame = accentBar_Base_one.bounds
    }

    private func setupUI_Base_one() {
        contentView.addSubview(accentBar_Base_one)
        contentView.addSubview(titleLabel_Base_one)
        contentView.addSubview(subtitleLabel_Base_one)
        contentView.addSubview(seeAllButton_Base_one)

        // 强调竖条渐变（薄荷绿 → 深海蓝）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                       UIColor(hexstring_Base_one: "#2D7DD2").cgColor]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        accentBar_Base_one.layer.insertSublayer(grad, at: 0)
        accentBarGrad_Base_one = grad

        accentBar_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        titleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Base_one.snp.trailing).offset(10)
            make.centerY.equalToSuperview().offset(-6)
        }
        subtitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Base_one)
            make.top.equalTo(titleLabel_Base_one.snp.bottom).offset(1)
        }
        seeAllButton_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        seeAllButton_Base_one.addTarget(self, action: #selector(seeAllTapped_Base_one), for: .touchUpInside)
    }

    @objc private func seeAllTapped_Base_one() { onSeeAllTapped_Base_one?() }

    /// 配置标题、副标题及是否显示查看全部按钮
    /// - Parameters:
    ///   - title_base_one: 主标题文字
    ///   - subtitle_base_one: 副标题文字（可选）
    ///   - showSeeAll_base_one: 是否显示查看全部按钮，默认 true
    func configure_Base_one(title_base_one: String, subtitle_base_one: String = "", showSeeAll_base_one: Bool = true) {
        titleLabel_Base_one.text = title_base_one
        subtitleLabel_Base_one.text = subtitle_base_one
        seeAllButton_Base_one.isHidden = !showSeeAll_base_one
    }
}

// MARK: - 打卡记录 Cell

/// 首页打卡记录单元格
/// 功能：展示连续打卡天数、本周七日打卡状态及今日打卡按钮
/// 设计：白色圆角卡片 + 左侧连续天数 + 右侧操作按钮 + 底部本周打点行
class HomeCheckinCell_Base_one: UICollectionViewCell {

    /// 今日打卡按钮点击回调
    var onCheckInTapped_Base_one: (() -> Void)?

    // MARK: 卡片容器
    private let cardView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.20).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        v.clipsToBounds = false
        return v
    }()
    /// 卡片背景极淡薄荷渐变层
    private var cardBgGrad_Base_one: CAGradientLayer?
    /// 左侧渐变强调条
    private let leftStrip_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()
    private var stripGradLayer_Base_one: CAGradientLayer?

    // MARK: 激励文字
    private let motivationLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lb.textColor = ColorConfig_Base_one.tidyMint_Base_one
        return lb
    }()

    // MARK: 火焰与连续天数
    private let flameLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "🔥"
        lb.font = UIFont.systemFont(ofSize: 26)
        return lb
    }()
    private let streakValueLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()
    private let streakUnitLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Day Streak"
        lb.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return lb
    }()

    // MARK: 本周打卡点行
    private let weekStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: 打卡按钮
    private let checkInButton_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return btn
    }()
    private var btnGradLayer_Base_one: CAGradientLayer?

    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        btnGradLayer_Base_one?.frame = checkInButton_Base_one.bounds
        stripGradLayer_Base_one?.frame = leftStrip_Base_one.bounds
        cardBgGrad_Base_one?.frame = cardView_Base_one.bounds
    }

    // MARK: UI 搭建
    private func setupUI_Base_one() {
        backgroundColor = .clear
        contentView.clipsToBounds = false

        contentView.addSubview(cardView_Base_one)
        cardView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 卡片背景极淡薄荷渐变（白 → 极淡薄荷）
        let bgGrad = CAGradientLayer()
        bgGrad.colors = [UIColor.white.cgColor,
                         UIColor(hexstring_Base_one: "#F0FDF9").cgColor]
        bgGrad.startPoint = CGPoint(x: 0, y: 0)
        bgGrad.endPoint   = CGPoint(x: 1, y: 1)
        bgGrad.cornerRadius = 18
        cardView_Base_one.layer.insertSublayer(bgGrad, at: 0)
        cardBgGrad_Base_one = bgGrad

        // 左侧渐变强调条（薄荷绿 → 深青）
        let stripGrad = CAGradientLayer()
        stripGrad.colors = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                            UIColor(hexstring_Base_one: "#2C9E96").cgColor]
        stripGrad.startPoint = CGPoint(x: 0.5, y: 0)
        stripGrad.endPoint   = CGPoint(x: 0.5, y: 1)
        leftStrip_Base_one.layer.insertSublayer(stripGrad, at: 0)
        stripGradLayer_Base_one = stripGrad
        cardView_Base_one.addSubview(leftStrip_Base_one)
        leftStrip_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // 火焰 + 连续天数
        cardView_Base_one.addSubview(flameLabel_Base_one)
        cardView_Base_one.addSubview(streakValueLabel_Base_one)
        cardView_Base_one.addSubview(streakUnitLabel_Base_one)
        cardView_Base_one.addSubview(motivationLabel_Base_one)

        flameLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(16)
        }
        streakValueLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Base_one.snp.trailing).offset(8)
            make.centerY.equalTo(flameLabel_Base_one)
        }
        streakUnitLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Base_one)
            make.top.equalTo(flameLabel_Base_one.snp.bottom).offset(1)
        }
        motivationLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Base_one)
            make.top.equalTo(streakUnitLabel_Base_one.snp.bottom).offset(3)
        }

        // 本周打卡点（leading 留出左侧强调条的 5px 宽度）
        cardView_Base_one.addSubview(weekStack_Base_one)
        weekStack_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-120)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(28)
        }
        buildWeekDots_Base_one()

        // 打卡按钮（渐变背景）
        let grad = CAGradientLayer()
        grad.colors = [ColorConfig_Base_one.tidyMint_Base_one.cgColor,
                       UIColor(hexstring_Base_one: "#2C9E96").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 14
        checkInButton_Base_one.layer.insertSublayer(grad, at: 0)
        btnGradLayer_Base_one = grad

        checkInButton_Base_one.layer.shadowColor = ColorConfig_Base_one.tidyMint_Base_one.withAlphaComponent(0.35).cgColor
        checkInButton_Base_one.layer.shadowOffset = CGSize(width: 0, height: 4)
        checkInButton_Base_one.layer.shadowRadius = 8
        checkInButton_Base_one.layer.shadowOpacity = 1

        cardView_Base_one.addSubview(checkInButton_Base_one)
        checkInButton_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        checkInButton_Base_one.addTarget(self, action: #selector(onCheckInTapped_handler_Base_one), for: .touchUpInside)
    }

    /// 构建本周七日打卡点（M/T/W/T/F/S/S + 圆点）
    private func buildWeekDots_Base_one() {
        weekStack_Base_one.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let days_base_one = ["M", "T", "W", "T", "F", "S", "S"]
        for day in days_base_one {
            let col = UIView()
            let dot = UIView()
            dot.layer.cornerRadius = 5
            dot.backgroundColor = ColorConfig_Base_one.divider_Base_one

            let dayLb = UILabel()
            dayLb.text = day
            dayLb.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            dayLb.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
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
            weekStack_Base_one.addArrangedSubview(col)
        }
    }

    @objc private func onCheckInTapped_handler_Base_one() {
        checkInButton_Base_one.animatePulse_Base_one()
        onCheckInTapped_Base_one?()
    }

    /// 配置打卡单元格数据
    /// - Parameters:
    ///   - streak_base_one: 连续打卡天数
    ///   - isCheckedToday_base_one: 今日是否已打卡
    ///   - weekRecord_base_one: 本周七天打卡状态数组（长度 7，周一起始）
    func configure_Base_one(streak_base_one: Int,
                            isCheckedToday_base_one: Bool,
                            weekRecord_base_one: [Bool]) {
        streakValueLabel_Base_one.text = "\(streak_base_one)"

        // 根据连续天数生成差异化激励文字
        switch streak_base_one {
        case 0:        motivationLabel_Base_one.text = "Start your streak today! 🌟"
        case 1...2:    motivationLabel_Base_one.text = "Great start! Keep going 🌿"
        case 3...6:    motivationLabel_Base_one.text = "You're on a roll! 💪"
        case 7...13:   motivationLabel_Base_one.text = "One week strong! 🔥"
        case 14...29:  motivationLabel_Base_one.text = "Incredible consistency! ⚡️"
        default:       motivationLabel_Base_one.text = "Tidy champion! 🏆"
        }

        // 按钮状态
        if isCheckedToday_base_one {
            checkInButton_Base_one.setTitle("✓ Done", for: .normal)
            checkInButton_Base_one.setTitleColor(.white, for: .normal)
            checkInButton_Base_one.alpha = 0.55
            checkInButton_Base_one.isUserInteractionEnabled = false
        } else {
            checkInButton_Base_one.setTitle("Check In", for: .normal)
            checkInButton_Base_one.setTitleColor(.white, for: .normal)
            checkInButton_Base_one.alpha = 1.0
            checkInButton_Base_one.isUserInteractionEnabled = true
        }

        // 本周打卡点颜色
        for (i, col) in weekStack_Base_one.arrangedSubviews.enumerated() {
            let checked = i < weekRecord_base_one.count && weekRecord_base_one[i]
            if let dot = col.subviews.first {
                dot.backgroundColor = checked
                    ? ColorConfig_Base_one.tidyMint_Base_one
                    : ColorConfig_Base_one.divider_Base_one
            }
        }
    }
}

// MARK: - 生活技巧翻转卡片 Cell

/// 生活整理小技巧翻转卡片单元格
/// 功能：正面展示图标与标题，背面展示详细技巧内容，点击触发 3D 翻转动画
/// 设计：正面彩色渐变 + 背面白色；UIView.transition 实现翻转效果
class HomeTipCardCell_Base_one: UICollectionViewCell {

    // MARK: 翻转状态
    private var isFlipped_Base_one = false

    // MARK: 正面
    private let frontView_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()
    private var frontGradLayer_Base_one: CAGradientLayer?
    /// 正面顶部斜向光泽层（白色→透明对角渐变）
    private let frontShineLayer_Base_one = CAGradientLayer()

    private let frontEmojiLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 38)
        lb.textAlignment = .center
        return lb
    }()
    private let frontTitleLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    /// 正面底部翻转提示图标
    private let frontHintIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        iv.image = UIImage(systemName: "hand.tap.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.65)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: 背面
    private let backView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()
    private let backEmojiLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 22)
        lb.textAlignment = .center
        return lb
    }()
    private let backContentLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        lb.textAlignment = .center
        lb.numberOfLines = 0
        return lb
    }()
    private let backHintLabel_Base_one: UILabel = {
        let lb = UILabel()
        lb.text = "Tap to flip back"
        lb.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lb.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        lb.textAlignment = .center
        return lb
    }()
    /// 背面顶部颜色条
    private let backAccentBar_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        return v
    }()

    // MARK: 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        frontGradLayer_Base_one?.frame = frontView_Base_one.bounds
        // 光泽层覆盖正面左上三角区域
        frontShineLayer_Base_one.frame = frontView_Base_one.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置翻转状态
        isFlipped_Base_one = false
        frontView_Base_one.isHidden = false
        backView_Base_one.isHidden  = true
        frontGradLayer_Base_one?.removeFromSuperlayer()
        frontGradLayer_Base_one = nil
        frontShineLayer_Base_one.removeFromSuperlayer()
    }

    // MARK: UI 搭建
    private func setupUI_Base_one() {
        contentView.layer.shadowColor  = ColorConfig_Base_one.shadowColor_Base_one.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 1
        contentView.clipsToBounds = false

        // 正面
        contentView.addSubview(frontView_Base_one)
        frontView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 配置光泽层（白色→透明对角渐变，叠加在渐变色上形成高光感）
        frontShineLayer_Base_one.colors = [UIColor.white.withAlphaComponent(0.22).cgColor,
                                           UIColor.white.withAlphaComponent(0.04).cgColor,
                                           UIColor.clear.cgColor]
        frontShineLayer_Base_one.startPoint = CGPoint(x: 0, y: 0)
        frontShineLayer_Base_one.endPoint   = CGPoint(x: 1, y: 1)
        frontShineLayer_Base_one.locations  = [0, 0.45, 1.0]

        frontView_Base_one.addSubview(frontEmojiLabel_Base_one)
        frontView_Base_one.addSubview(frontTitleLabel_Base_one)
        frontView_Base_one.addSubview(frontHintIconView_Base_one)

        frontEmojiLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
        }
        frontTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(frontEmojiLabel_Base_one.snp.bottom).offset(8)
        }
        frontHintIconView_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
            make.width.height.equalTo(16)
        }

        // 背面
        contentView.addSubview(backView_Base_one)
        backView_Base_one.snp.makeConstraints { $0.edges.equalToSuperview() }

        backView_Base_one.addSubview(backAccentBar_Base_one)
        backView_Base_one.addSubview(backEmojiLabel_Base_one)
        backView_Base_one.addSubview(backContentLabel_Base_one)
        backView_Base_one.addSubview(backHintLabel_Base_one)

        backAccentBar_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
        }
        backEmojiLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(18)
        }
        backContentLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalTo(backEmojiLabel_Base_one.snp.bottom).offset(8)
        }
        backHintLabel_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }

        // 点击翻转手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Base_one))
        contentView.addGestureRecognizer(tap)
    }

    /// 点击翻转（3D 翻转动画）
    @objc private func handleCardTap_Base_one() {
        isFlipped_Base_one.toggle()
        let fromView = isFlipped_Base_one ? frontView_Base_one : backView_Base_one
        let toView   = isFlipped_Base_one ? backView_Base_one  : frontView_Base_one
        let option: UIView.AnimationOptions = isFlipped_Base_one ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: contentView, duration: 0.5, options: [option], animations: {
            fromView.isHidden = true
            toView.isHidden   = false
        }, completion: nil)
    }

    /// 配置技巧卡片内容
    /// - Parameter tip_base_one: 技巧数据模型
    func configure_Base_one(tip_base_one: HomeTip_Base_one) {
        // 重置状态
        isFlipped_Base_one = false
        frontView_Base_one.isHidden = false
        backView_Base_one.isHidden  = true

        // 更新正面渐变（主色 → 浅色，增强颜色层次）
        frontGradLayer_Base_one?.removeFromSuperlayer()
        frontShineLayer_Base_one.removeFromSuperlayer()
        let grad = CAGradientLayer()
        grad.colors = [tip_base_one.color_Base_one.cgColor,
                       tip_base_one.color_Base_one.withAlphaComponent(0.70).cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        grad.cornerRadius = 16
        frontView_Base_one.layer.insertSublayer(grad, at: 0)
        frontGradLayer_Base_one = grad
        // 光泽层插在渐变层之上（index 1）
        frontView_Base_one.layer.insertSublayer(frontShineLayer_Base_one, at: 1)

        // 填充内容
        frontEmojiLabel_Base_one.text   = tip_base_one.icon_Base_one
        frontTitleLabel_Base_one.text   = tip_base_one.title_Base_one
        backEmojiLabel_Base_one.text    = tip_base_one.icon_Base_one
        backContentLabel_Base_one.text  = tip_base_one.content_Base_one
        backContentLabel_Base_one.textColor = tip_base_one.color_Base_one
        backAccentBar_Base_one.backgroundColor = tip_base_one.color_Base_one

        // 延迟刷新渐变尺寸（等待布局完成）
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            grad.frame = self.frontView_Base_one.bounds
        }
    }
}

// MARK: - 首页 ViewController

/// 首页页面
/// 功能：欢迎 Header + 精选 Banner + 打卡记录区 + 生活整理技巧翻转卡片
/// 设计思路：CompositionalLayout 六区段，NotificationCenter 驱动 ViewModel 更新
class Home_Base_one: UIViewController {

    // MARK: Section 枚举
    private enum Section_Base_one: Int, CaseIterable {
        case header_base_one       = 0
        case banner_base_one       = 1
        case checkinTitle_base_one = 2
        case checkin_base_one      = 3
        case tipsTitle_base_one    = 4
        case tips_base_one         = 5
    }

    // MARK: Cell ID
    private let idHeader_Base_one    = "HomeHeaderCell"
    private let idBanner_Base_one    = "HomeBannerContainer"
    private let idSecTitle_Base_one  = "HomeSectionTitle"
    private let idCheckin_Base_one   = "HomeCheckinCell"
    private let idTip_Base_one       = "HomeTipCardCell"

    // MARK: 生活整理技巧数据（预置 8 条）
    private let tipsList_Base_one: [HomeTip_Base_one] = [
        HomeTip_Base_one(
            icon_Base_one: "🧺",
            title_Base_one: "One-Minute Rule",
            content_Base_one: "If a task takes less than 60 seconds, do it right now. Put items back immediately after use.",
            color_Base_one: ColorConfig_Base_one.categoryKitchen_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "🗂️",
            title_Base_one: "Zone Your Space",
            content_Base_one: "Assign specific areas for activities. Items used together should live in the same zone.",
            color_Base_one: ColorConfig_Base_one.categoryStudy_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "✨",
            title_Base_one: "5S Method",
            content_Base_one: "Sort · Set in Order · Shine · Standardize · Sustain — a proven system for lasting order.",
            color_Base_one: ColorConfig_Base_one.tidyMint_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "📦",
            title_Base_one: "One In, One Out",
            content_Base_one: "When a new item arrives, one old item leaves. Prevents gradual clutter accumulation.",
            color_Base_one: ColorConfig_Base_one.categoryBedroom_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "🌿",
            title_Base_one: "Sunday Reset",
            content_Base_one: "Spend 30 minutes every Sunday tidying common areas. Small effort, lasting difference.",
            color_Base_one: ColorConfig_Base_one.categoryGarden_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "🎯",
            title_Base_one: "Everything Has a Home",
            content_Base_one: "Assign a specific spot for every item. If something has no place, find one or let it go.",
            color_Base_one: ColorConfig_Base_one.categoryLivingRoom_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "🚿",
            title_Base_one: "Clean As You Go",
            content_Base_one: "Wipe surfaces right after use. Prevents buildup and saves major cleaning time later.",
            color_Base_one: ColorConfig_Base_one.categoryBathroom_Base_one
        ),
        HomeTip_Base_one(
            icon_Base_one: "🏷️",
            title_Base_one: "Label Everything",
            content_Base_one: "Labels help you find things fast and remind everyone where items truly belong.",
            color_Base_one: ColorConfig_Base_one.categoryStorage_Base_one
        ),
    ]

    // MARK: 数据
    private var featuredPosts_Base_one: [TitleModel_Base_one] = []

    // MARK: UI
    private var collectionView_Base_one: UICollectionView!
    private weak var bannerCell_Base_one: HomeBannerContainerCell_Base_one?

    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupCollectionView_Base_one()
        loadData_Base_one()
        setupNotifications_Base_one()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 使用 setNavigationBarHidden 统一管理，避免与子页面 setNavigationBarHidden(false) 状态冲突
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // 刷新打卡区（今日打卡状态可能已变）
        collectionView_Base_one.reloadSections(
            IndexSet(integer: Section_Base_one.checkin_base_one.rawValue)
        )
    }

    // MARK: 数据加载
    private func loadData_Base_one() {
        Task { @MainActor in
            featuredPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getFeaturedPosts_Base_one()
            collectionView_Base_one.reloadData()
            runEntranceAnimation_Base_one()
        }
    }

    // MARK: 通知
    private func setupNotifications_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onTitleChanged_Base_one),
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserChanged_Base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one, object: nil
        )
    }
    @objc private func onTitleChanged_Base_one() {
        featuredPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getFeaturedPosts_Base_one()
        collectionView_Base_one.reloadSections(IndexSet(integer: Section_Base_one.banner_base_one.rawValue))
    }
    @objc private func onUserChanged_Base_one() {
        // 用户状态变化时刷新 Header 和打卡区
        collectionView_Base_one.reloadSections(
            IndexSet([Section_Base_one.header_base_one.rawValue,
                      Section_Base_one.checkin_base_one.rawValue])
        )
    }

    // MARK: CollectionView 搭建
    private func setupCollectionView_Base_one() {
        collectionView_Base_one = UICollectionView(frame: .zero,
                                                   collectionViewLayout: makeLayout_Base_one())
        collectionView_Base_one.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        collectionView_Base_one.showsVerticalScrollIndicator = false
        collectionView_Base_one.contentInsetAdjustmentBehavior = .never
        collectionView_Base_one.delegate   = self
        collectionView_Base_one.dataSource = self

        collectionView_Base_one.register(HomeHeaderCell_Base_one.self,          forCellWithReuseIdentifier: idHeader_Base_one)
        collectionView_Base_one.register(HomeBannerContainerCell_Base_one.self, forCellWithReuseIdentifier: idBanner_Base_one)
        collectionView_Base_one.register(HomeSectionTitleCell_Base_one.self,    forCellWithReuseIdentifier: idSecTitle_Base_one)
        collectionView_Base_one.register(HomeCheckinCell_Base_one.self,         forCellWithReuseIdentifier: idCheckin_Base_one)
        collectionView_Base_one.register(HomeTipCardCell_Base_one.self,         forCellWithReuseIdentifier: idTip_Base_one)

        let refresh = UIRefreshControl()
        refresh.tintColor = ColorConfig_Base_one.tidyMint_Base_one
        refresh.addTarget(self, action: #selector(onRefresh_Base_one(_:)), for: .valueChanged)
        collectionView_Base_one.refreshControl = refresh
        collectionView_Base_one.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        view.addSubview(collectionView_Base_one)
        collectionView_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    @objc private func onRefresh_Base_one(_ sender: UIRefreshControl) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            featuredPosts_Base_one = TitleViewModel_Base_one.shared_Base_one.getFeaturedPosts_Base_one()
            collectionView_Base_one.reloadData()
            sender.endRefreshing()
            collectionView_Base_one.animateFadeIn_Base_one(duration_Base_one: 0.3)
        }
    }

    // MARK: CompositionalLayout
    private func makeLayout_Base_one() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] idx, _ in
            guard let self, let sec = Section_Base_one(rawValue: idx) else { return nil }
            switch sec {
            case .header_base_one:       return self.layoutHeader_Base_one()
            case .banner_base_one:       return self.layoutBanner_Base_one()
            case .checkinTitle_base_one: return self.layoutSingleRow_Base_one(height: 52)
            case .checkin_base_one:      return self.layoutCheckin_Base_one()
            case .tipsTitle_base_one:    return self.layoutSingleRow_Base_one(height: 52)
            case .tips_base_one:         return self.layoutTips_Base_one()
            }
        }
    }

    private func layoutHeader_Base_one() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180)), subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    private func layoutBanner_Base_one() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(244)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(244)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 6, leading: 0, bottom: 0, trailing: 0)
        return sec
    }
    private func layoutSingleRow_Base_one(height: CGFloat) -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 12, leading: 0, bottom: 0, trailing: 0)
        return sec
    }
    private func layoutCheckin_Base_one() -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 6, leading: 16, bottom: 4, trailing: 16)
        return sec
    }
    private func layoutTips_Base_one() -> NSCollectionLayoutSection {
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
    private func runEntranceAnimation_Base_one() {
        Section_Base_one.allCases.enumerated().forEach { idx, sec in
            let ip = IndexPath(item: 0, section: sec.rawValue)
            collectionView_Base_one.cellForItem(at: ip)?
                .animateSlideInFromBottom_Base_one(offset_Base_one: 40,
                                                   delay_Base_one: Double(idx) * 0.07)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UICollectionViewDataSource

extension Home_Base_one: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section_Base_one.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let sec = Section_Base_one(rawValue: section) else { return 0 }
        switch sec {
        case .header_base_one:       return 1
        case .banner_base_one:       return featuredPosts_Base_one.isEmpty ? 0 : 1
        case .checkinTitle_base_one: return 1
        case .checkin_base_one:      return 1
        case .tipsTitle_base_one:    return 1
        case .tips_base_one:         return tipsList_Base_one.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sec = Section_Base_one(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch sec {

        // Header（仅用户名，无统计）
        case .header_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idHeader_Base_one, for: indexPath) as! HomeHeaderCell_Base_one
            let user = UserViewModel_Base_one.shared_Base_one.getCurrentUser_Base_one()
            cell.configure_Base_one(userName_base_one: user.userName_Base_one ?? "Welcome")
            return cell

        // Banner 轮播
        case .banner_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idBanner_Base_one, for: indexPath) as! HomeBannerContainerCell_Base_one
            bannerCell_Base_one = cell
            cell.totalPages_Base_one = featuredPosts_Base_one.count
            cell.pagerView_Base_one.dataSource = self
            cell.pagerView_Base_one.delegate   = self
            cell.pagerView_Base_one.register(HomeBannerCell_Base_one.self, forCellWithReuseIdentifier: "BannerPage")
            cell.pagerView_Base_one.itemSize = CGSize(width: UIScreen.main.bounds.width - 56, height: 190)
            cell.pagerView_Base_one.reloadData()
            return cell

        // 打卡区标题
        case .checkinTitle_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Base_one, for: indexPath) as! HomeSectionTitleCell_Base_one
            cell.configure_Base_one(title_base_one: "Check-In", subtitle_base_one: "Daily tidy habit tracker", showSeeAll_base_one: true)
            cell.onSeeAllTapped_Base_one = { [weak self] in
                guard let self else { return }
                let historyVC = CheckinHistory_Base_one()
                Navigation_Base_one.push_Base_one(to: historyVC, from: self)
            }
            return cell

        // 打卡记录卡片
        case .checkin_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCheckin_Base_one, for: indexPath) as! HomeCheckinCell_Base_one
            let vm = UserViewModel_Base_one.shared_Base_one
            cell.configure_Base_one(
                streak_base_one: vm.getCheckinStreak_Base_one(),
                isCheckedToday_base_one: vm.hasCheckedInToday_Base_one(),
                weekRecord_base_one: vm.getWeekCheckinRecord_Base_one()
            )
            cell.onCheckInTapped_Base_one = { [weak self] in
                UserViewModel_Base_one.shared_Base_one.checkIn_Base_one()
                // 打卡后刷新本区域
                self?.collectionView_Base_one.reloadSections(
                    IndexSet(integer: Section_Base_one.checkin_base_one.rawValue)
                )
            }
            return cell

        // 技巧区标题（不显示查看全部）
        case .tipsTitle_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Base_one, for: indexPath) as! HomeSectionTitleCell_Base_one
            cell.configure_Base_one(title_base_one: "Life Tips", subtitle_base_one: "Tap a card to reveal the tip", showSeeAll_base_one: false)
            cell.onSeeAllTapped_Base_one = nil
            return cell

        // 技巧翻转卡片
        case .tips_base_one:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idTip_Base_one, for: indexPath) as! HomeTipCardCell_Base_one
            cell.configure_Base_one(tip_base_one: tipsList_Base_one[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Base_one: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard Section_Base_one(rawValue: indexPath.section) == .tips_base_one else { return }
        cell.animateSlideInFromBottom_Base_one(
            offset_Base_one: 24,
            delay_Base_one: Double(indexPath.item % 4) * AnimationConfig_Base_one.delayShort_Base_one
        )
    }
}

// MARK: - FSPagerView DataSource & Delegate

extension Home_Base_one: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        featuredPosts_Base_one.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "BannerPage", at: index) as! HomeBannerCell_Base_one
        cell.configure_Base_one(post_base_one: featuredPosts_Base_one[index])
        // 举报/删除完成后重新拉取数据，刷新 Banner
        cell.onMoreTapped_Base_one = { [weak self] post_base_one in
            guard let self = self else { return }
            let isMyPost_base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
                userId_base_one: post_base_one.titleUserId_Base_one
            )
            if isMyPost_base_one {
                ReportDeleteHelper_Base_one.delete_Base_one(post_Base_one: post_base_one, from: self) { [weak self] in
                    self?.loadData_Base_one()
                }
            } else {
                ReportDeleteHelper_Base_one.report_Base_one(post_Base_one: post_base_one, from: self) { [weak self] in
                    self?.loadData_Base_one()
                }
            }
        }
        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        Navigation_Base_one.toTitleDetail_Base_one(titleModel_base_one: featuredPosts_Base_one[index])
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        bannerCell_Base_one?.currentPage_Base_one = pagerView.currentIndex
    }
}
