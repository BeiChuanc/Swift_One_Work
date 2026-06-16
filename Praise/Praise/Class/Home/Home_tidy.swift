import Foundation
import UIKit
import SnapKit

// MARK: - 拍照出片小技巧数据模型

/// 拍照出片技巧数据模型
/// 功能：承载技巧卡片的正面展示内容（图标、标题、详情、主题色）
struct HomeTip_Tidy {
    let icon_Tidy: String
    let title_Tidy: String
    let content_Tidy: String
    let color_Tidy: UIColor
}

// MARK: - Header Cell（现代化重构版）

/// 首页顶部 Header 单元格（现代化设计）
/// 功能：展示当前用户问候语、用户名、标语及摄影主题装饰
/// 设计：深色斜向渐变背景 + 胶片条纹装饰 + 光圈同心环 + 顶栏头像/铃铛 + 底部快速徽章行
/// 关键属性：onBellTapped_Tidy、onAvatarTapped_Tidy 回调由外部 VC 注入
class HomeHeaderCell_Tidy: UICollectionViewCell {

    // MARK: 背景
    private var gradientLayer_Tidy: CAGradientLayer?
    /// 网格噪点纹理层（视觉质感提升）
    private let noiseOverlay_Tidy: CALayer = {
        let l = CALayer()
        l.opacity = 0.03
        l.backgroundColor = UIColor.white.cgColor
        return l
    }()

    // MARK: 胶片条纹装饰（右侧，摄影主题）
    private let filmStripView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: 光圈同心环装饰（右下角）
    private let apertureContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: 头像
    private let avatarRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 18
        v.isUserInteractionEnabled = true
        return v
    }()
    /// 头像外圈光晕（增加层次感）
    private let avatarGlowRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        v.layer.borderWidth = 4
        v.layer.cornerRadius = 22
        v.isUserInteractionEnabled = false
        return v
    }()
    private let avatarView_Tidy = CurrentUserAvatarView_Tidy()

    // MARK: 外部事件回调

    /// 点击用户头像 → 切换到我的 Tab
    var onAvatarTapped_Tidy: (() -> Void)?

    // MARK: 文字标签
    private let greetingLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.68)
        return lb
    }()
    private let userNameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        lb.textColor = .white
        lb.layer.shadowColor  = UIColor.black.withAlphaComponent(0.25).cgColor
        lb.layer.shadowOffset = CGSize(width: 0, height: 1)
        lb.layer.shadowRadius = 3
        return lb
    }()
    private let taglineLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Frame every light · Tell every story ✦"
        lb.font = UIFont(name: "Georgia-Italic", size: 11) ?? UIFont.italicSystemFont(ofSize: 11)
        lb.textColor = UIColor.white.withAlphaComponent(0.55)
        return lb
    }()

    // MARK: 底部徽章行
    private let dateBadge_Tidy: UIView = makeBottomBadge_s()
    private let dateBadgeLabel_Tidy: UILabel = makeBadgeLabel_s()
    private let cameraBadge_Tidy: UIView = makeBottomBadge_s()
    private let cameraBadgeLabel_Tidy: UILabel = makeBadgeLabel_s()

    // MARK: 工具方法
    private static func makeDecorCircle_s(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.isUserInteractionEnabled = false
        return v
    }
    private static func makeBottomBadge_s() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 12
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.28).cgColor
        v.layer.borderWidth  = 1
        return v
    }
    private static func makeBadgeLabel_s() -> UILabel {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = UIColor.white.withAlphaComponent(0.90)
        lb.textAlignment = .center
        return lb
    }

    /// 从 UIWindowScene 获取真实状态栏高度
    private var windowSafeTop_Tidy: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 44
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
        drawApertureRings_Tidy()
        // 胶片条纹已移除，不再调用 drawFilmStrip_Tidy
    }

    // MARK: UI 搭建
    private func setupUI_Tidy() {
        contentView.clipsToBounds = false

        // 渐变背景：深靛蓝 → 钴蓝 → 深紫，斜向 45°，营造专业摄影氛围
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [
            UIColor(hexstring_Tidy: "#1A237E").cgColor,   // 深靛蓝
            UIColor(hexstring_Tidy: "#283593").cgColor,   // 钴蓝
            UIColor(hexstring_Tidy: "#1565C0").cgColor,   // 皇家蓝
        ]
        grad_tidy.locations  = [0, 0.5, 1.0]
        grad_tidy.startPoint = CGPoint(x: 0.0, y: 0.0)
        grad_tidy.endPoint   = CGPoint(x: 1.0, y: 1.0)
        contentView.layer.insertSublayer(grad_tidy, at: 0)
        gradientLayer_Tidy = grad_tidy

        // 胶片条纹已移除，头像移至右侧充当视觉锚点

        // 头像光晕环（右上角，先加保证在光圈层上方）
        contentView.addSubview(avatarGlowRing_Tidy)
        avatarGlowRing_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(windowSafeTop_Tidy + 8)
            make.width.height.equalTo(48)
        }

        // 光圈装饰（叠在头像光晕背后，营造镜头感）
        contentView.addSubview(apertureContainer_Tidy)
        apertureContainer_Tidy.snp.makeConstraints { make in
            make.center.equalTo(avatarGlowRing_Tidy)
            make.width.height.equalTo(82)
        }

        // 头像（右上角，内嵌光晕环）
        avatarRing_Tidy.addSubview(avatarView_Tidy)
        contentView.addSubview(avatarRing_Tidy)
        avatarView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        avatarRing_Tidy.snp.makeConstraints { make in
            make.center.equalTo(avatarGlowRing_Tidy)
            make.width.height.equalTo(38)
        }

        // 透明覆盖按钮（解决 CollectionView 手势拦截）
        let avatarBtn_tidy = UIButton(type: .system)
        avatarBtn_tidy.backgroundColor = .clear
        avatarBtn_tidy.addTarget(self, action: #selector(avatarTapped_Tidy), for: .touchUpInside)
        avatarRing_Tidy.addSubview(avatarBtn_tidy)
        avatarBtn_tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 问候语（左对齐，与头像同行垂直居中）
        contentView.addSubview(greetingLabel_Tidy)
        greetingLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(avatarGlowRing_Tidy)
            make.trailing.lessThanOrEqualTo(avatarGlowRing_Tidy.snp.leading).offset(-12)
        }

        // 用户名（大字，问候语下方，右侧留给头像区域）
        contentView.addSubview(userNameLabel_Tidy)
        userNameLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(avatarGlowRing_Tidy.snp.bottom).offset(10)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(-16)
        }

        // 标语（用户名下方，紧凑间距）
        contentView.addSubview(taglineLabel_Tidy)
        taglineLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(userNameLabel_Tidy.snp.bottom).offset(3)
            make.trailing.lessThanOrEqualTo(contentView.snp.trailing).offset(-16)
        }

        // 底部徽章行（标语下方）
        dateBadge_Tidy.addSubview(dateBadgeLabel_Tidy)
        cameraBadge_Tidy.addSubview(cameraBadgeLabel_Tidy)
        contentView.addSubview(dateBadge_Tidy)
        contentView.addSubview(cameraBadge_Tidy)

        dateBadgeLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-9)
        }
        cameraBadgeLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(9)
            make.trailing.equalToSuperview().offset(-9)
        }
        dateBadge_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(taglineLabel_Tidy.snp.bottom).offset(10)
            make.height.equalTo(22)
        }
        cameraBadge_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(dateBadge_Tidy.snp.trailing).offset(8)
            make.centerY.equalTo(dateBadge_Tidy)
            make.height.equalTo(22)
        }
    }

    // MARK: 光圈同心环绘制
    private func drawApertureRings_Tidy() {
        apertureContainer_Tidy.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard apertureContainer_Tidy.bounds.width > 0 else { return }
        let center_tidy = CGPoint(x: apertureContainer_Tidy.bounds.midX,
                                  y: apertureContainer_Tidy.bounds.midY)
        // 四层描边环：从外到内，透明度渐增
        let rings_tidy: [(CGFloat, CGFloat, CGFloat)] = [
            (42, 0.12, 1.0), (32, 0.18, 1.5), (22, 0.24, 2.0), (12, 0.35, 2.5)
        ]
        for (r_tidy, a_tidy, lw_tidy) in rings_tidy {
            let ring_tidy = CAShapeLayer()
            ring_tidy.path = UIBezierPath(
                arcCenter: center_tidy, radius: r_tidy,
                startAngle: 0, endAngle: .pi * 2, clockwise: true
            ).cgPath
            ring_tidy.fillColor   = UIColor.clear.cgColor
            ring_tidy.strokeColor = UIColor.white.withAlphaComponent(a_tidy).cgColor
            ring_tidy.lineWidth   = lw_tidy
            apertureContainer_Tidy.layer.addSublayer(ring_tidy)
        }
        // 中心圆点
        let dot_tidy = CAShapeLayer()
        dot_tidy.path = UIBezierPath(
            arcCenter: center_tidy, radius: 4,
            startAngle: 0, endAngle: .pi * 2, clockwise: true
        ).cgPath
        dot_tidy.fillColor = UIColor.white.withAlphaComponent(0.60).cgColor
        apertureContainer_Tidy.layer.addSublayer(dot_tidy)
    }

    // MARK: 胶片条纹绘制（模拟相机胶卷边缘）
    private func drawFilmStrip_Tidy() {
        filmStripView_Tidy.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        guard filmStripView_Tidy.bounds.height > 0 else { return }
        let w_tidy: CGFloat = filmStripView_Tidy.bounds.width
        let h_tidy: CGFloat = filmStripView_Tidy.bounds.height
        let holeSize_tidy: CGFloat = 7
        let gap_tidy: CGFloat = 12
        var y_tidy: CGFloat = 10

        // 左右竖线
        let leftLine_tidy = CAShapeLayer()
        let path_tidy = UIBezierPath()
        path_tidy.move(to: CGPoint(x: 4, y: 0))
        path_tidy.addLine(to: CGPoint(x: 4, y: h_tidy))
        path_tidy.move(to: CGPoint(x: w_tidy - 4, y: 0))
        path_tidy.addLine(to: CGPoint(x: w_tidy - 4, y: h_tidy))
        leftLine_tidy.path        = path_tidy.cgPath
        leftLine_tidy.strokeColor = UIColor.white.withAlphaComponent(0.10).cgColor
        leftLine_tidy.lineWidth   = 1
        leftLine_tidy.fillColor   = UIColor.clear.cgColor
        filmStripView_Tidy.layer.addSublayer(leftLine_tidy)

        // 排孔
        while y_tidy + holeSize_tidy < h_tidy - 10 {
            let hole_tidy = CAShapeLayer()
            hole_tidy.path = UIBezierPath(
                roundedRect: CGRect(x: (w_tidy - holeSize_tidy) / 2,
                                    y: y_tidy, width: holeSize_tidy, height: holeSize_tidy),
                cornerRadius: 2
            ).cgPath
            hole_tidy.fillColor   = UIColor.white.withAlphaComponent(0.14).cgColor
            hole_tidy.strokeColor = UIColor.white.withAlphaComponent(0.08).cgColor
            hole_tidy.lineWidth   = 0.5
            filmStripView_Tidy.layer.addSublayer(hole_tidy)
            y_tidy += holeSize_tidy + gap_tidy
        }
    }

    // MARK: 数据填充
    func configure_Tidy(userName_tidy: String) {
        let hour_tidy = Calendar.current.component(.hour, from: Date())
        greetingLabel_Tidy.text = hour_tidy < 12 ? "Good morning ☀️"
            : hour_tidy < 18 ? "Good afternoon 🌿"
            : "Good evening 🌙"
        userNameLabel_Tidy.text = userName_tidy

        let dateFmt_tidy = DateFormatter()
        dateFmt_tidy.dateFormat = "EEE · MMM d"
        dateBadgeLabel_Tidy.text = "  " + dateFmt_tidy.string(from: Date()).uppercased() + "  "

        let streak_tidy = UserViewModel_Tidy.shared_Tidy.getCheckinStreak_Tidy()
        cameraBadgeLabel_Tidy.text = "  🔥 \(streak_tidy) Day Streak  "
    }

    // MARK: 按钮响应
    @objc private func avatarTapped_Tidy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Tidy?()
    }
}

// MARK: - Section 标题 Cell（现代简约版）

/// Section 分区标题单元格（现代简约版）
/// 功能：主标题 + 副标题 + 右侧"See All"按钮
/// 设计：移除竖条，改为底部渐变下划线 + 较大标题字号，整体扁平现代
class HomeSectionTitleCell_Tidy: UICollectionViewCell {

    var onSeeAllTapped_Tidy: (() -> Void)?

    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()
    /// 标题下方渐变下划线（取代竖条）
    private let underlineView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 1.5
        return v
    }()
    private var underlineGrad_Tidy: CAGradientLayer?

    private let seeAllButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        var cfg = UIButton.Configuration.plain()
        cfg.title = "See All"
        cfg.image = UIImage(systemName: "arrow.right",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        cfg.imagePlacement = .trailing
        cfg.imagePadding   = 4
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            a.foregroundColor = ColorConfig_Tidy.tidyMint_Tidy
            return a
        }
        cfg.baseForegroundColor = ColorConfig_Tidy.tidyMint_Tidy
        btn.configuration = cfg
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
        underlineGrad_Tidy?.frame = underlineView_Tidy.bounds
    }

    private func setupUI_Tidy() {
        contentView.addSubview(titleLabel_Tidy)
        contentView.addSubview(subtitleLabel_Tidy)
        contentView.addSubview(underlineView_Tidy)
        contentView.addSubview(seeAllButton_Tidy)

        // 渐变下划线（薄荷蓝 → 透明）
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor, UIColor.clear.cgColor]
        grad_tidy.startPoint = CGPoint(x: 0, y: 0.5)
        grad_tidy.endPoint   = CGPoint(x: 1, y: 0.5)
        underlineView_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        underlineGrad_Tidy = grad_tidy

        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        underlineView_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Tidy)
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(3)
            make.width.equalTo(36)
            make.height.equalTo(3)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Tidy)
            make.top.equalTo(underlineView_Tidy.snp.bottom).offset(3)
        }
        seeAllButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        seeAllButton_Tidy.addTarget(self, action: #selector(seeAllTapped_Tidy), for: .touchUpInside)
    }

    @objc private func seeAllTapped_Tidy() { onSeeAllTapped_Tidy?() }

    /// 配置标题区内容
    func configure_Tidy(title_tidy: String, subtitle_tidy: String = "", showSeeAll_tidy: Bool = true) {
        titleLabel_Tidy.text    = title_tidy
        subtitleLabel_Tidy.text = subtitle_tidy
        seeAllButton_Tidy.isHidden = !showSeeAll_tidy
    }
}

// MARK: - 打卡记录 Cell（暗黑现代版）

/// 首页打卡记录单元格（暗黑现代版）
/// 功能：展示连续打卡天数、本周进度环、打卡按钮
/// 设计：深海军蓝背景 + 薄荷光晕 + 白色文字 + 渐变进度环 + 胶囊打卡按钮
/// 关键属性：onCheckInTapped_Tidy 由外部注入
class HomeCheckinCell_Tidy: UICollectionViewCell {

    var onCheckInTapped_Tidy: (() -> Void)?

    // MARK: 阴影外壳（clipsToBounds=false 保留投影）
    private let cardShadow_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor   = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.20).cgColor
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        v.layer.shadowRadius  = 16
        v.layer.shadowOpacity = 1
        v.clipsToBounds = false
        return v
    }()

    // MARK: 内容卡（clipsToBounds=true 保证圆角裁切）
    private let cardView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    private var cardBgGrad_Tidy: CAGradientLayer?

    // MARK: 左侧渐变强调条
    private let leftStrip_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private var stripGrad_Tidy: CAGradientLayer?

    // MARK: 标题区
    private let missionBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "DAILY MISSION"
        lb.font = UIFont.systemFont(ofSize: 9.5, weight: .bold)
        lb.textColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        lb.textAlignment = .center
        lb.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.10)
        lb.layer.cornerRadius = 9
        lb.layer.borderWidth  = 1
        lb.layer.borderColor  = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.22).cgColor
        lb.clipsToBounds = true
        return lb
    }()
    private let logTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Shot Log"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let logSubtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Keep your camera eye active today"
        lb.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()

    // MARK: 火焰 + 连续天数
    private let flameLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "🔥"
        lb.font = UIFont.systemFont(ofSize: 30)
        return lb
    }()
    private let streakValueLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let streakUnitLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "DAY STREAK"
        lb.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        lb.textColor = ColorConfig_Tidy.tidyMint_Tidy
        return lb
    }()
    private let motivationLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.tidyMint_Tidy
        lb.numberOfLines = 1
        lb.adjustsFontSizeToFitWidth = true
        lb.minimumScaleFactor = 0.85
        return lb
    }()

    // MARK: 周进度环
    private let ringTrackLayer_Tidy = CAShapeLayer()
    private let ringFillLayer_Tidy  = CAShapeLayer()
    private let ringGradLayer_Tidy  = CAGradientLayer()
    private let ringContainer_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    private let ringHeaderLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "THIS WEEK"
        lb.font = UIFont.systemFont(ofSize: 7.5, weight: .bold)
        lb.textColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        lb.textAlignment = .center
        return lb
    }()
    private let ringDaysLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb.textAlignment = .center
        return lb
    }()
    private let ringSubLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "/ 7"
        lb.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        lb.textAlignment = .center
        return lb
    }()

    // MARK: 本周打卡格点
    private let weekStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: 打卡按钮（全宽胶囊）
    private let checkInButton_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return btn
    }()
    private var btnGradLayer_Tidy: CAGradientLayer?

    // MARK: 进度数据
    private var weekProgress_Tidy: CGFloat = 0

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
        btnGradLayer_Tidy?.frame  = checkInButton_Tidy.bounds
        cardBgGrad_Tidy?.frame    = cardView_Tidy.bounds
        stripGrad_Tidy?.frame     = leftStrip_Tidy.bounds
        // 阴影路径与圆角同步，提升渲染性能
        cardShadow_Tidy.layer.shadowPath = UIBezierPath(
            roundedRect: cardShadow_Tidy.bounds, cornerRadius: 20
        ).cgPath
        updateRingPath_Tidy()
    }

    // MARK: UI 搭建（重设计版）
    /// 布局分三区：头部信息区 / 内容区（左侧连续天数 + 右侧进度环） / 底部行（周格点 + 打卡按钮）
    private func setupUI_Tidy() {
        backgroundColor = .clear
        contentView.clipsToBounds = false

        // 阴影外壳 + 内容卡（双层模式）
        contentView.addSubview(cardShadow_Tidy)
        cardShadow_Tidy.addSubview(cardView_Tidy)
        cardShadow_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        cardView_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 白色背景
        cardView_Tidy.backgroundColor = .white
        let cardW_tidy = UIScreen.main.bounds.width - 32
        let bgGrad_tidy = CAGradientLayer()
        bgGrad_tidy.colors = [UIColor.white.cgColor,
                               UIColor(hexstring_Tidy: "#F2F6FF").cgColor]
        bgGrad_tidy.startPoint = CGPoint(x: 0, y: 0)
        bgGrad_tidy.endPoint   = CGPoint(x: 1, y: 1)
        bgGrad_tidy.frame      = CGRect(x: 0, y: 0, width: cardW_tidy, height: 158)
        cardView_Tidy.layer.insertSublayer(bgGrad_tidy, at: 0)
        cardBgGrad_Tidy = bgGrad_tidy

        // 左侧渐变强调条
        let stripG_tidy = CAGradientLayer()
        stripG_tidy.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                               ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor]
        stripG_tidy.startPoint = CGPoint(x: 0.5, y: 0)
        stripG_tidy.endPoint   = CGPoint(x: 0.5, y: 1)
        stripG_tidy.frame      = CGRect(x: 0, y: 0, width: 5, height: 158)
        leftStrip_Tidy.layer.insertSublayer(stripG_tidy, at: 0)
        leftStrip_Tidy.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        leftStrip_Tidy.layer.cornerRadius  = 3
        stripGrad_Tidy = stripG_tidy
        cardView_Tidy.addSubview(leftStrip_Tidy)
        leftStrip_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(5)
        }

        // ─── 头部区（标题 + 徽章 + 副标题）────────────────────────────

        cardView_Tidy.addSubview(missionBadge_Tidy)
        missionBadge_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(20)
            make.width.equalTo(108)
        }
        cardView_Tidy.addSubview(logTitleLabel_Tidy)
        logTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualTo(missionBadge_Tidy.snp.leading).offset(-8)
        }
        cardView_Tidy.addSubview(logSubtitleLabel_Tidy)
        logSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(logTitleLabel_Tidy)
            make.top.equalTo(logTitleLabel_Tidy.snp.bottom).offset(2)
        }

        // 细分隔线
        let divider_tidy = UIView()
        divider_tidy.backgroundColor = UIColor(hexstring_Tidy: "#E8EDF5")
        divider_tidy.isUserInteractionEnabled = false
        cardView_Tidy.addSubview(divider_tidy)
        divider_tidy.snp.makeConstraints { make in
            make.top.equalTo(logSubtitleLabel_Tidy.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(1)
        }

        // ─── 右侧进度环（先加，供左侧 trailing 引用）──────────────────

        cardView_Tidy.addSubview(ringContainer_Tidy)
        ringContainer_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalTo(divider_tidy.snp.bottom).offset(6)
            make.width.height.equalTo(62)
        }

        // 轨道层
        ringTrackLayer_Tidy.fillColor   = UIColor.clear.cgColor
        ringTrackLayer_Tidy.strokeColor = UIColor(hexstring_Tidy: "#E2E8F0").cgColor
        ringTrackLayer_Tidy.lineWidth   = 7
        ringTrackLayer_Tidy.lineCap     = .round
        ringContainer_Tidy.layer.addSublayer(ringTrackLayer_Tidy)

        // 进度层（渐变 mask）
        ringGradLayer_Tidy.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                                     ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor]
        ringGradLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        ringGradLayer_Tidy.endPoint   = CGPoint(x: 1, y: 1)
        ringGradLayer_Tidy.mask       = ringFillLayer_Tidy
        ringFillLayer_Tidy.fillColor   = UIColor.clear.cgColor
        ringFillLayer_Tidy.strokeColor = UIColor.white.cgColor
        ringFillLayer_Tidy.lineWidth   = 7
        ringFillLayer_Tidy.lineCap     = .round
        ringFillLayer_Tidy.strokeStart = 0
        ringFillLayer_Tidy.strokeEnd   = 0
        ringContainer_Tidy.layer.addSublayer(ringGradLayer_Tidy)

        // 环内文字（堆叠居中）
        ringContainer_Tidy.addSubview(ringHeaderLabel_Tidy)
        ringContainer_Tidy.addSubview(ringDaysLabel_Tidy)
        ringContainer_Tidy.addSubview(ringSubLabel_Tidy)
        ringHeaderLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        ringDaysLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-3)
        }
        ringSubLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(ringDaysLabel_Tidy.snp.bottom).offset(1)
        }

        // ─── 左侧连续打卡区────────────────────────────────────────────

        cardView_Tidy.addSubview(flameLabel_Tidy)
        cardView_Tidy.addSubview(streakValueLabel_Tidy)
        cardView_Tidy.addSubview(streakUnitLabel_Tidy)
        cardView_Tidy.addSubview(motivationLabel_Tidy)

        flameLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(divider_tidy.snp.bottom).offset(10)
        }
        streakValueLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy.snp.trailing).offset(5)
            make.centerY.equalTo(flameLabel_Tidy).offset(-3)
        }
        streakUnitLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy)
            make.top.equalTo(flameLabel_Tidy.snp.bottom).offset(2)
        }
        motivationLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(flameLabel_Tidy)
            make.top.equalTo(streakUnitLabel_Tidy.snp.bottom).offset(3)
            make.trailing.lessThanOrEqualTo(ringContainer_Tidy.snp.leading).offset(-8)
            // 使用 cardView 固定偏移（weekStack 此时尚未入视图层级，不能直接引用）
            // 卡片 158pt，weekStack.top ≈ 158-10-30=118，此处限制在 112pt 以内
            make.bottom.lessThanOrEqualTo(cardView_Tidy.snp.bottom).offset(-46)
        }

        // ─── 底部行：周格点（左）+ 打卡按钮（右）────────────────────────
        // 两者在同一行，避免按钮与进度环产生约束冲突

        // 打卡按钮渐变
        let btnGrad_tidy = CAGradientLayer()
        btnGrad_tidy.colors = [ColorConfig_Tidy.tidyMint_Tidy.cgColor,
                                ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor]
        btnGrad_tidy.startPoint  = CGPoint(x: 0, y: 0.5)
        btnGrad_tidy.endPoint    = CGPoint(x: 1, y: 0.5)
        btnGrad_tidy.cornerRadius = 15
        checkInButton_Tidy.layer.insertSublayer(btnGrad_tidy, at: 0)
        btnGradLayer_Tidy = btnGrad_tidy
        checkInButton_Tidy.layer.shadowColor   = ColorConfig_Tidy.tidyMint_Tidy.withAlphaComponent(0.35).cgColor
        checkInButton_Tidy.layer.shadowOffset  = CGSize(width: 0, height: 3)
        checkInButton_Tidy.layer.shadowRadius  = 8
        checkInButton_Tidy.layer.shadowOpacity = 1

        cardView_Tidy.addSubview(weekStack_Tidy)
        cardView_Tidy.addSubview(checkInButton_Tidy)
        buildWeekDots_Tidy()

        // 按钮：固定在右下角
        checkInButton_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(90)
            make.height.equalTo(30)
        }
        // 周格点：左侧，与按钮同行
        weekStack_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(checkInButton_Tidy.snp.leading).offset(-8)
            make.centerY.equalTo(checkInButton_Tidy)
            make.height.equalTo(30)
        }
        checkInButton_Tidy.addTarget(self, action: #selector(onCheckInTapped_handler_Tidy), for: .touchUpInside)
    }

    /// 构建本周七日格点（底部行横向排列，圆点 + 字母上下叠放）
    private func buildWeekDots_Tidy() {
        weekStack_Tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let days_tidy = ["M", "T", "W", "T", "F", "S", "S"]
        for day_tidy in days_tidy {
            let col_tidy = UIView()
            let dot_tidy = UIView()
            dot_tidy.layer.cornerRadius = 5
            dot_tidy.backgroundColor = ColorConfig_Tidy.divider_Tidy

            let dayLb_tidy = UILabel()
            dayLb_tidy.text = day_tidy
            dayLb_tidy.font = UIFont.systemFont(ofSize: 8, weight: .semibold)
            dayLb_tidy.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
            dayLb_tidy.textAlignment = .center

            col_tidy.addSubview(dot_tidy)
            col_tidy.addSubview(dayLb_tidy)
            dot_tidy.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(2)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(10)
            }
            dayLb_tidy.snp.makeConstraints { make in
                make.top.equalTo(dot_tidy.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-2)
            }
            weekStack_Tidy.addArrangedSubview(col_tidy)
        }
    }

    /// 更新进度环路径
    private func updateRingPath_Tidy() {
        let b_tidy = ringContainer_Tidy.bounds
        guard b_tidy.width > 0 else { return }
        let center_tidy = CGPoint(x: b_tidy.midX, y: b_tidy.midY)
        let radius_tidy: CGFloat = b_tidy.width / 2 - 6
        let start_tidy: CGFloat  = -.pi / 2
        let end_tidy: CGFloat    = start_tidy + .pi * 2
        let trackPath_tidy = UIBezierPath(
            arcCenter: center_tidy, radius: radius_tidy,
            startAngle: start_tidy, endAngle: end_tidy, clockwise: true
        ).cgPath
        ringTrackLayer_Tidy.path = trackPath_tidy
        ringFillLayer_Tidy.path  = trackPath_tidy
        ringGradLayer_Tidy.frame = b_tidy
        ringFillLayer_Tidy.strokeEnd = weekProgress_Tidy
    }

    @objc private func onCheckInTapped_handler_Tidy() {
        checkInButton_Tidy.animatePulse_Tidy()
        onCheckInTapped_Tidy?()
    }

    // MARK: 数据填充
    func configure_Tidy(streak_tidy: Int,
                        isCheckedToday_tidy: Bool,
                        weekRecord_tidy: [Bool]) {
        streakValueLabel_Tidy.text = "\(streak_tidy)"

        switch streak_tidy {
        case 0:        motivationLabel_Tidy.text = "Start your shot streak today! 🌟"
        case 1...2:    motivationLabel_Tidy.text = "Nice start! Keep shooting 📷"
        case 3...6:    motivationLabel_Tidy.text = "Your eye is getting sharper 👀"
        case 7...13:   motivationLabel_Tidy.text = "One week of practice! 🔥"
        case 14...29:  motivationLabel_Tidy.text = "Strong rhythm, strong results ⚡️"
        default:       motivationLabel_Tidy.text = "Photo streak master! 🏆"
        }

        if isCheckedToday_tidy {
            checkInButton_Tidy.setTitle("✓  Logged", for: .normal)
            checkInButton_Tidy.setTitleColor(.white, for: .normal)
            checkInButton_Tidy.alpha = 0.50
            checkInButton_Tidy.isUserInteractionEnabled = false
        } else {
            checkInButton_Tidy.setTitle("Log Today", for: .normal)
            checkInButton_Tidy.setTitleColor(.white, for: .normal)
            checkInButton_Tidy.alpha = 1.0
            checkInButton_Tidy.isUserInteractionEnabled = true
        }

        let checkedCount_tidy = weekRecord_tidy.filter { $0 }.count
        for (i, col) in weekStack_Tidy.arrangedSubviews.enumerated() {
            let isChecked_tidy = i < weekRecord_tidy.count && weekRecord_tidy[i]
            if let dot = col.subviews.first {
                dot.backgroundColor = isChecked_tidy
                    ? ColorConfig_Tidy.tidyMint_Tidy
                    : ColorConfig_Tidy.divider_Tidy
            }
            if col.subviews.count > 1, let dayLb = col.subviews[1] as? UILabel {
                dayLb.textColor = isChecked_tidy
                    ? ColorConfig_Tidy.primaryGradientStart_Tidy
                    : ColorConfig_Tidy.textPlaceholder_Tidy
            }
        }

        ringDaysLabel_Tidy.text = "\(checkedCount_tidy)"
        weekProgress_Tidy = checkedCount_tidy > 0 ? CGFloat(checkedCount_tidy) / 7.0 : 0

        let anim_tidy = CABasicAnimation(keyPath: "strokeEnd")
        anim_tidy.fromValue = 0
        anim_tidy.toValue   = weekProgress_Tidy
        anim_tidy.duration  = 0.9
        anim_tidy.timingFunction = CAMediaTimingFunction(name: .easeOut)
        ringFillLayer_Tidy.strokeEnd = weekProgress_Tidy
        ringFillLayer_Tidy.add(anim_tidy, forKey: "ringProgress")
    }
}

// MARK: - 摄影技巧卡片 Cell（现代艺术版）

/// 摄影技巧卡片单元格（现代艺术版）
/// 功能：展示技巧图标与标题，点击弹出底部详情 Sheet
/// 设计：全屏渐变 + 底部磨砂玻璃条（展示标题）+ 大号 emoji + 书本图标提示
class HomeTipCardCell_Tidy: UICollectionViewCell {

    var onCardTapped_Tidy: ((HomeTip_Tidy) -> Void)?
    private var currentTip_Tidy: HomeTip_Tidy?

    // MARK: 渐变背景
    private let cardView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    private var gradLayer_Tidy: CAGradientLayer?
    private let shineLayer_Tidy = CAGradientLayer()

    // MARK: 内容区
    private let emojiLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 30)
        lb.textAlignment = .center
        return lb
    }()

    // MARK: 底部磨砂标题条
    private let frostedBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        return v
    }()
    private let barTitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "Georgia-Bold", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let barIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "book.open.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.60)
        iv.contentMode = .scaleAspectFit
        return iv
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
        gradLayer_Tidy?.frame   = cardView_Tidy.bounds
        shineLayer_Tidy.frame   = cardView_Tidy.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        gradLayer_Tidy?.removeFromSuperlayer()
        gradLayer_Tidy = nil
        shineLayer_Tidy.removeFromSuperlayer()
    }

    // MARK: UI 搭建
    private func setupUI_Tidy() {
        contentView.layer.shadowColor   = UIColor.black.withAlphaComponent(0.18).cgColor
        contentView.layer.shadowOffset  = CGSize(width: 0, height: 6)
        contentView.layer.shadowRadius  = 14
        contentView.layer.shadowOpacity = 1
        contentView.clipsToBounds = false

        contentView.addSubview(cardView_Tidy)
        cardView_Tidy.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 光泽层
        shineLayer_Tidy.colors   = [UIColor.white.withAlphaComponent(0.22).cgColor,
                                     UIColor.white.withAlphaComponent(0.04).cgColor,
                                     UIColor.clear.cgColor]
        shineLayer_Tidy.startPoint = CGPoint(x: 0, y: 0)
        shineLayer_Tidy.endPoint   = CGPoint(x: 1, y: 1)
        shineLayer_Tidy.locations  = [0, 0.45, 1.0]

        // emoji（居中偏上，为底部标题条留空）
        cardView_Tidy.addSubview(emojiLabel_Tidy)
        emojiLabel_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
        }

        // 底部磨砂标题条
        cardView_Tidy.addSubview(frostedBar_Tidy)
        frostedBar_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(44)
        }

        frostedBar_Tidy.addSubview(barTitleLabel_Tidy)
        frostedBar_Tidy.addSubview(barIconView_Tidy)
        barTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
            make.top.equalToSuperview().offset(6)
        }
        barIconView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7)
            make.width.height.equalTo(11)
        }

        let tap_tidy = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Tidy))
        contentView.addGestureRecognizer(tap_tidy)
    }

    @objc private func handleCardTap_Tidy() {
        guard let tip = currentTip_Tidy else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.10) {
            self.contentView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        } completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0,
                           usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                self.contentView.transform = .identity
            }
        }
        onCardTapped_Tidy?(tip)
    }

    // MARK: 数据填充
    func configure_Tidy(tip_tidy: HomeTip_Tidy) {
        currentTip_Tidy = tip_tidy

        gradLayer_Tidy?.removeFromSuperlayer()
        shineLayer_Tidy.removeFromSuperlayer()

        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [tip_tidy.color_Tidy.cgColor,
                             tip_tidy.color_Tidy.withAlphaComponent(0.65).cgColor]
        grad_tidy.startPoint  = CGPoint(x: 0.1, y: 0)
        grad_tidy.endPoint    = CGPoint(x: 0.9, y: 1)
        grad_tidy.cornerRadius = 20
        cardView_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        gradLayer_Tidy = grad_tidy
        cardView_Tidy.layer.insertSublayer(shineLayer_Tidy, at: 1)

        emojiLabel_Tidy.text    = tip_tidy.icon_Tidy
        barTitleLabel_Tidy.text = tip_tidy.title_Tidy

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            grad_tidy.frame             = self.cardView_Tidy.bounds
            self.shineLayer_Tidy.frame  = self.cardView_Tidy.bounds
        }
    }
}

// MARK: - 技巧详情底部弹窗

/// 拍照技巧详情底部弹窗
/// 功能：以艺术感排版展示技巧图标、标题及详细内容
/// 设计：拖动条 + 大号 emoji + Georgia 衬线字体标题 + 斜体内容，主题色强调
class TipDetailSheet_Tidy: UIViewController {

    private let tip_Tidy: HomeTip_Tidy

    private let dragBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()
    private let categoryBadge_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb.textAlignment = .center
        lb.layer.cornerRadius = 12
        lb.clipsToBounds = true
        return lb
    }()
    private let emojiLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 68)
        lb.textAlignment = .center
        return lb
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "Georgia-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let divider_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#E2E8F0")
        return v
    }()
    private let contentLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont(name: "Georgia-Italic", size: 17) ?? UIFont.italicSystemFont(ofSize: 17)
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()
    private let hintLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Tap outside to close"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = UIColor(hexstring_Tidy: "#A0AEC0")
        lb.textAlignment = .center
        return lb
    }()

    init(tip_tidy: HomeTip_Tidy) {
        self.tip_Tidy = tip_tidy
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("不支持 Storyboard 初始化") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        configureTip_Tidy()
    }

    private func setupUI_Tidy() {
        view.backgroundColor = .white
        view.addSubview(dragBar_Tidy)
        dragBar_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        view.addSubview(categoryBadge_Tidy)
        categoryBadge_Tidy.snp.makeConstraints { make in
            make.top.equalTo(dragBar_Tidy.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(120)
        }
        view.addSubview(emojiLabel_Tidy)
        emojiLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(categoryBadge_Tidy.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        view.addSubview(titleLabel_Tidy)
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(emojiLabel_Tidy.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-28)
        }
        view.addSubview(divider_Tidy)
        divider_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(44)
            make.trailing.equalToSuperview().offset(-44)
            make.height.equalTo(1)
        }
        view.addSubview(contentLabel_Tidy)
        contentLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(divider_Tidy.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }
        view.addSubview(hintLabel_Tidy)
        hintLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Tidy.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
    }

    private func configureTip_Tidy() {
        let color_tidy = tip_Tidy.color_Tidy
        emojiLabel_Tidy.text    = tip_Tidy.icon_Tidy
        titleLabel_Tidy.text    = tip_Tidy.title_Tidy
        titleLabel_Tidy.textColor = color_tidy
        contentLabel_Tidy.text  = tip_Tidy.content_Tidy
        contentLabel_Tidy.textColor = color_tidy.withAlphaComponent(0.75)
        categoryBadge_Tidy.text            = "  Photo Glow Tips  "
        categoryBadge_Tidy.textColor       = color_tidy
        categoryBadge_Tidy.backgroundColor = color_tidy.withAlphaComponent(0.10)
        categoryBadge_Tidy.layer.borderWidth = 1
        categoryBadge_Tidy.layer.borderColor = color_tidy.withAlphaComponent(0.25).cgColor
    }
}

// MARK: - 打卡历史底部弹窗

/// 打卡历史记录底部弹窗
/// 功能：以弹窗形式展示统计数据及当月日历
/// 设计：拖动条 + 三栏统计卡片 + 月历网格
class CheckinHistorySheet_Tidy: UIViewController {

    private let dragBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Shot Log History"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Your daily practice record"
        lb.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb
    }()
    private let scrollView_Tidy = UIScrollView()
    private let contentStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        setupUI_Tidy()
        loadCheckinData_Tidy()
    }

    private func setupUI_Tidy() {
        view.addSubview(dragBar_Tidy)
        dragBar_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        view.addSubview(titleLabel_Tidy)
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(dragBar_Tidy.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }
        view.addSubview(subtitleLabel_Tidy)
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(3)
            make.leading.equalToSuperview().offset(20)
        }
        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.showsVerticalScrollIndicator = false
        scrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel_Tidy.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView_Tidy.addSubview(contentStack_Tidy)
        contentStack_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.width.equalTo(scrollView_Tidy).offset(-40)
        }
    }

    private func loadCheckinData_Tidy() {
        let vm_tidy = UserViewModel_Tidy.shared_Tidy
        let streak_tidy   = vm_tidy.getCheckinStreak_Tidy()
        let allDates_tidy = vm_tidy.getAllCheckinDates_Tidy()
        let total_tidy    = allDates_tidy.count
        let checkedSet_tidy = Set(allDates_tidy)

        let cal_tidy    = Calendar.current
        let now_tidy    = Date()
        let year_tidy   = cal_tidy.component(.year,  from: now_tidy)
        let month_tidy  = cal_tidy.component(.month, from: now_tidy)
        let dayNow_tidy = cal_tidy.component(.day,   from: now_tidy)
        let prefix_tidy = String(format: "%04d-%02d-", year_tidy, month_tidy)
        let monthCnt_tidy = allDates_tidy.filter { $0.hasPrefix(prefix_tidy) }.count
        let rate_tidy   = dayNow_tidy > 0 ? Int(Double(monthCnt_tidy) / Double(dayNow_tidy) * 100) : 0

        buildStatsRow_Tidy(streak: streak_tidy, total: total_tidy, rate: rate_tidy)
        buildCalendar_Tidy(year: year_tidy, month: month_tidy, checkedSet: checkedSet_tidy)
    }

    private func buildStatsRow_Tidy(streak: Int, total: Int, rate: Int) {
        let row_tidy = UIStackView()
        row_tidy.axis = .horizontal
        row_tidy.distribution = .fillEqually
        row_tidy.spacing = 10
        let items_tidy: [(String, String, String, UIColor)] = [
            ("🔥", "\(streak)", "Day Streak", ColorConfig_Tidy.categoryKitchen_Tidy),
            ("📅", "\(total)",  "Total Days",  ColorConfig_Tidy.tidyMint_Tidy),
            ("📈", "\(rate)%", "This Month",  ColorConfig_Tidy.primaryGradientStart_Tidy)
        ]
        for (icon_tidy, val_tidy, sub_tidy, color_tidy) in items_tidy {
            row_tidy.addArrangedSubview(makeStatCard_Tidy(icon: icon_tidy, value: val_tidy,
                                                          subtitle: sub_tidy, color: color_tidy))
        }
        contentStack_Tidy.addArrangedSubview(row_tidy)
        row_tidy.snp.makeConstraints { make in make.height.equalTo(90) }
    }

    private func makeStatCard_Tidy(icon: String, value: String, subtitle: String, color: UIColor) -> UIView {
        let card_tidy = UIView()
        card_tidy.backgroundColor = color.withAlphaComponent(0.08)
        card_tidy.layer.cornerRadius = 14
        card_tidy.layer.borderWidth  = 1
        card_tidy.layer.borderColor  = color.withAlphaComponent(0.20).cgColor

        let iconLb_tidy = UILabel()
        iconLb_tidy.text = icon
        iconLb_tidy.font = UIFont.systemFont(ofSize: 22)
        iconLb_tidy.textAlignment = .center

        let valLb_tidy = UILabel()
        valLb_tidy.text = value
        valLb_tidy.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        valLb_tidy.textColor = color
        valLb_tidy.textAlignment = .center

        let subLb_tidy = UILabel()
        subLb_tidy.text = subtitle
        subLb_tidy.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subLb_tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        subLb_tidy.textAlignment = .center

        [iconLb_tidy, valLb_tidy, subLb_tidy].forEach { card_tidy.addSubview($0) }
        iconLb_tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        valLb_tidy.snp.makeConstraints { make in
            make.top.equalTo(iconLb_tidy.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        subLb_tidy.snp.makeConstraints { make in
            make.top.equalTo(valLb_tidy.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        return card_tidy
    }

    private func buildCalendar_Tidy(year: Int, month: Int, checkedSet: Set<String>) {
        var comps_tidy = DateComponents()
        comps_tidy.year = year; comps_tidy.month = month; comps_tidy.day = 1
        guard let firstDay_tidy = Calendar.current.date(from: comps_tidy) else { return }

        let fmt_tidy = DateFormatter()
        fmt_tidy.dateFormat = "MMMM yyyy"
        let sLb_tidy = UILabel()
        sLb_tidy.text = fmt_tidy.string(from: firstDay_tidy)
        sLb_tidy.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        sLb_tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
        contentStack_Tidy.addArrangedSubview(sLb_tidy)
        contentStack_Tidy.addArrangedSubview(makeWeekHeaderRow_Tidy())

        var isoCal_tidy = Calendar(identifier: .iso8601)
        isoCal_tidy.firstWeekday = 2
        let weekday_tidy = isoCal_tidy.component(.weekday, from: firstDay_tidy)
        let offset_tidy  = (weekday_tidy == 1) ? 6 : (weekday_tidy - 2)
        let daysCount_tidy = isoCal_tidy.range(of: .day, in: .month, for: firstDay_tidy)!.count

        let nowCal_tidy = Calendar.current
        let today_tidy  = nowCal_tidy.component(.day, from: Date())
        let isCurrent_tidy = (nowCal_tidy.component(.year,  from: Date()) == year &&
                              nowCal_tidy.component(.month, from: Date()) == month)

        var cells_tidy: [UIView] = Array(repeating: makeEmptyCell_Tidy(), count: offset_tidy)
        for d_tidy in 1...daysCount_tidy {
            let str_tidy = String(format: "%04d-%02d-%02d", year, month, d_tidy)
            cells_tidy.append(makeDayCell_Tidy(
                day: d_tidy,
                isChecked: checkedSet.contains(str_tidy),
                isFuture: isCurrent_tidy && d_tidy > today_tidy,
                isToday:  isCurrent_tidy && d_tidy == today_tidy
            ))
        }
        while cells_tidy.count % 7 != 0 { cells_tidy.append(makeEmptyCell_Tidy()) }

        var idx_tidy = 0
        while idx_tidy < cells_tidy.count {
            let rowCells_tidy = Array(cells_tidy[idx_tidy..<min(idx_tidy + 7, cells_tidy.count)])
            contentStack_Tidy.addArrangedSubview(makeWeekRow_Tidy(cells: rowCells_tidy))
            idx_tidy += 7
        }
    }

    private func makeWeekHeaderRow_Tidy() -> UIStackView {
        let sv_tidy = UIStackView()
        sv_tidy.axis = .horizontal
        sv_tidy.distribution = .fillEqually
        ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"].forEach { d_tidy in
            let lb_tidy = UILabel()
            lb_tidy.text = d_tidy
            lb_tidy.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            lb_tidy.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
            lb_tidy.textAlignment = .center
            sv_tidy.addArrangedSubview(lb_tidy)
        }
        sv_tidy.snp.makeConstraints { make in make.height.equalTo(24) }
        return sv_tidy
    }

    private func makeWeekRow_Tidy(cells: [UIView]) -> UIStackView {
        let sv_tidy = UIStackView(arrangedSubviews: cells)
        sv_tidy.axis = .horizontal
        sv_tidy.distribution = .fillEqually
        sv_tidy.spacing = 4
        sv_tidy.snp.makeConstraints { make in make.height.equalTo(44) }
        return sv_tidy
    }

    private func makeDayCell_Tidy(day: Int, isChecked: Bool, isFuture: Bool, isToday: Bool) -> UIView {
        let container_tidy = UIView()
        let circle_tidy = UIView()
        circle_tidy.layer.cornerRadius = 17
        if isChecked {
            circle_tidy.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        } else if isToday {
            circle_tidy.backgroundColor = .clear
            circle_tidy.layer.borderWidth = 1.5
            circle_tidy.layer.borderColor = ColorConfig_Tidy.tidyMint_Tidy.cgColor
        } else {
            circle_tidy.backgroundColor = isFuture ? .clear : UIColor(hexstring_Tidy: "#F0F4F8")
        }
        let lb_tidy = UILabel()
        lb_tidy.text = "\(day)"
        lb_tidy.font = UIFont.systemFont(ofSize: 13, weight: isChecked ? .bold : .regular)
        lb_tidy.textColor = isChecked ? .white : (isFuture ? ColorConfig_Tidy.textPlaceholder_Tidy : ColorConfig_Tidy.textPrimary_Tidy)
        lb_tidy.textAlignment = .center
        container_tidy.addSubview(circle_tidy)
        circle_tidy.addSubview(lb_tidy)
        circle_tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(34)
        }
        lb_tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        return container_tidy
    }

    private func makeEmptyCell_Tidy() -> UIView { UIView() }
}

// MARK: - 首页 ViewController

/// 首页页面（现代化重构版）
/// 功能：Header + 打卡区 + 摄影技巧卡片
/// 设计：CompositionalLayout 五区段，通知驱动刷新；技巧卡点击底部 Sheet
class Home_Tidy: UIViewController {

    private enum Section_Tidy: Int, CaseIterable {
        case header_tidy       = 0
        case checkinTitle_tidy = 1
        case checkin_tidy      = 2
        case tipsTitle_tidy    = 3
        case tips_tidy         = 4
    }

    private let idHeader_Tidy   = "HomeHeaderCell"
    private let idSecTitle_Tidy = "HomeSectionTitle"
    private let idCheckin_Tidy  = "HomeCheckinCell"
    private let idTip_Tidy      = "HomeTipCardCell"

    private let tipsList_Tidy: [HomeTip_Tidy] = [
        HomeTip_Tidy(icon_Tidy: "🌤️", title_Tidy: "Face the Light",
                     content_Tidy: "Turn your subject toward the brightest soft light source and keep the nose slightly angled for cleaner skin tones.",
                     color_Tidy: ColorConfig_Tidy.categoryKitchen_Tidy),
        HomeTip_Tidy(icon_Tidy: "🙌", title_Tidy: "Relax the Hands",
                     content_Tidy: "Ask for one small action like touching hair, holding a strap, or adjusting a sleeve to avoid stiff poses.",
                     color_Tidy: ColorConfig_Tidy.categoryStudy_Tidy),
        HomeTip_Tidy(icon_Tidy: "📐", title_Tidy: "Use Leading Lines",
                     content_Tidy: "Stairs, rails, and sidewalks naturally guide the viewer to the face and make simple frames feel intentional.",
                     color_Tidy: ColorConfig_Tidy.tidyMint_Tidy),
        HomeTip_Tidy(icon_Tidy: "🧥", title_Tidy: "Pick One Accent Color",
                     content_Tidy: "Keep outfits to one hero color plus a neutral so the subject stands out even in busy locations.",
                     color_Tidy: ColorConfig_Tidy.categoryBedroom_Tidy),
        HomeTip_Tidy(icon_Tidy: "📍", title_Tidy: "Arrive Early",
                     content_Tidy: "Reach the location a few minutes before shooting so you can test angles, light direction, and clean backgrounds.",
                     color_Tidy: ColorConfig_Tidy.categoryGarden_Tidy),
        HomeTip_Tidy(icon_Tidy: "📱", title_Tidy: "Lift the Camera Slightly",
                     content_Tidy: "A camera angle just above eye level often gives a cleaner jawline and keeps proportions flattering.",
                     color_Tidy: ColorConfig_Tidy.categoryLivingRoom_Tidy),
        HomeTip_Tidy(icon_Tidy: "🌙", title_Tidy: "Protect the Highlights",
                     content_Tidy: "Lower exposure a little in bright scenes so clouds, neon, or windows keep their color and detail.",
                     color_Tidy: ColorConfig_Tidy.categoryBathroom_Tidy),
        HomeTip_Tidy(icon_Tidy: "🎚️", title_Tidy: "Edit in Small Steps",
                     content_Tidy: "Adjust brightness, highlights, and warmth gently before touching saturation to keep the photo natural.",
                     color_Tidy: ColorConfig_Tidy.categoryStorage_Tidy),
    ]

    private var collectionView_Tidy: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupCollectionView_Tidy()
        setupNotifications_Tidy()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        collectionView_Tidy.reloadSections(IndexSet(integer: Section_Tidy.checkin_tidy.rawValue))
    }

    private func setupNotifications_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onUserChanged_Tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy, object: nil
        )
    }
    @objc private func onUserChanged_Tidy() {
        collectionView_Tidy.reloadSections(
            IndexSet([Section_Tidy.header_tidy.rawValue,
                      Section_Tidy.checkin_tidy.rawValue])
        )
    }

    private func setupCollectionView_Tidy() {
        collectionView_Tidy = UICollectionView(frame: .zero, collectionViewLayout: makeLayout_Tidy())
        collectionView_Tidy.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        collectionView_Tidy.showsVerticalScrollIndicator = false
        collectionView_Tidy.contentInsetAdjustmentBehavior = .never
        collectionView_Tidy.delegate   = self
        collectionView_Tidy.dataSource = self

        collectionView_Tidy.register(HomeHeaderCell_Tidy.self,       forCellWithReuseIdentifier: idHeader_Tidy)
        collectionView_Tidy.register(HomeSectionTitleCell_Tidy.self, forCellWithReuseIdentifier: idSecTitle_Tidy)
        collectionView_Tidy.register(HomeCheckinCell_Tidy.self,      forCellWithReuseIdentifier: idCheckin_Tidy)
        collectionView_Tidy.register(HomeTipCardCell_Tidy.self,      forCellWithReuseIdentifier: idTip_Tidy)

        let refresh_tidy = UIRefreshControl()
        refresh_tidy.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        refresh_tidy.addTarget(self, action: #selector(onRefresh_Tidy(_:)), for: .valueChanged)
        collectionView_Tidy.refreshControl = refresh_tidy
        collectionView_Tidy.contentInset   = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        view.addSubview(collectionView_Tidy)
        collectionView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func onRefresh_Tidy(_ sender: UIRefreshControl) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
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
            case .checkinTitle_tidy: return self.layoutSingleRow_Tidy(height: 56)
            case .checkin_tidy:      return self.layoutCheckin_Tidy()
            case .tipsTitle_tidy:    return self.layoutSingleRow_Tidy(height: 56)
            case .tips_tidy:         return self.layoutTips_Tidy()
            }
        }
    }

    private func layoutHeader_Tidy() -> NSCollectionLayoutSection {
        // 动态叠加 safeArea：
        // 头像光晕环 top(8) + 高(48) + 用户名间距(10) + 用户名(30) + 标语(3+14) + 徽章(10+22) + 底部(18) ≈ 163pt
        let safeTop_tidy = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 44
        let h_tidy: CGFloat = safeTop_tidy + 163
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(h_tidy)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(h_tidy)), subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }
    private func layoutSingleRow_Tidy(height: CGFloat) -> NSCollectionLayoutSection {
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
        return sec
    }
    private func layoutCheckin_Tidy() -> NSCollectionLayoutSection {
        // 打卡卡片：三区布局（头部 + 内容 + 底部行）= 158pt
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(158)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(158)), subitems: [item])
        let sec   = NSCollectionLayoutSection(group: group)
        sec.contentInsets = .init(top: 4, leading: 16, bottom: 10, trailing: 16)
        return sec
    }
    private func layoutTips_Tidy() -> NSCollectionLayoutSection {
        // 技巧卡片：宽 110pt，高 138pt，行内可展示约 3 张
        let item  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(110), heightDimension: .absolute(138)),
            subitems: [item]
        )
        let sec = NSCollectionLayoutSection(group: group)
        sec.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        sec.contentInsets    = .init(top: 4, leading: 16, bottom: 20, trailing: 16)
        sec.interGroupSpacing = 10
        return sec
    }

    // MARK: 弹窗展示
    private func showTipDetail_Tidy(tip_tidy: HomeTip_Tidy) {
        let sheet_tidy = TipDetailSheet_Tidy(tip_tidy: tip_tidy)
        if let sheetPC_tidy = sheet_tidy.sheetPresentationController {
            sheetPC_tidy.detents = [.medium()]
            sheetPC_tidy.prefersGrabberVisible = false
            sheetPC_tidy.preferredCornerRadius = 24
        }
        Navigation_Tidy.present_Tidy(viewController: sheet_tidy, from: self)
    }

    private func showCheckinHistory_Tidy() {
        let sheet_tidy = CheckinHistorySheet_Tidy()
        if let sheetPC_tidy = sheet_tidy.sheetPresentationController {
            sheetPC_tidy.detents = [.medium(), .large()]
            sheetPC_tidy.prefersGrabberVisible = false
            sheetPC_tidy.preferredCornerRadius = 24
        }
        Navigation_Tidy.present_Tidy(viewController: sheet_tidy, from: self)
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
        case .header_tidy, .checkinTitle_tidy, .checkin_tidy, .tipsTitle_tidy: return 1
        case .tips_tidy: return tipsList_Tidy.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sec = Section_Tidy(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        switch sec {

        case .header_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idHeader_Tidy, for: indexPath) as! HomeHeaderCell_Tidy
            let user_tidy = UserViewModel_Tidy.shared_Tidy.getCurrentUser_Tidy()
            cell.configure_Tidy(userName_tidy: user_tidy.userName_Tidy ?? "Welcome")
            cell.onAvatarTapped_Tidy = { [weak self] in
                (self?.tabBarController as? TabBar_Tidy)?.switchTab_Tidy(to: 4)
            }
            return cell

        case .checkinTitle_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Tidy, for: indexPath) as! HomeSectionTitleCell_Tidy
            cell.configure_Tidy(title_tidy: "Shot Log",
                                 subtitle_tidy: "Daily practice should stay in sight",
                                 showSeeAll_tidy: true)
            cell.onSeeAllTapped_Tidy = { [weak self] in self?.showCheckinHistory_Tidy() }
            return cell

        case .checkin_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCheckin_Tidy, for: indexPath) as! HomeCheckinCell_Tidy
            let vm_tidy = UserViewModel_Tidy.shared_Tidy
            cell.configure_Tidy(
                streak_tidy: vm_tidy.getCheckinStreak_Tidy(),
                isCheckedToday_tidy: vm_tidy.hasCheckedInToday_Tidy(),
                weekRecord_tidy: vm_tidy.getWeekCheckinRecord_Tidy()
            )
            cell.onCheckInTapped_Tidy = { [weak self] in
                UserViewModel_Tidy.shared_Tidy.checkIn_Tidy()
                self?.collectionView_Tidy.reloadSections(
                    IndexSet(integer: Section_Tidy.checkin_tidy.rawValue)
                )
            }
            return cell

        case .tipsTitle_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idSecTitle_Tidy, for: indexPath) as! HomeSectionTitleCell_Tidy
            cell.configure_Tidy(title_tidy: "Photo Glow Tips",
                                 subtitle_tidy: "Tap any card for the full tip",
                                 showSeeAll_tidy: false)
            cell.onSeeAllTapped_Tidy = nil
            return cell

        case .tips_tidy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idTip_Tidy, for: indexPath) as! HomeTipCardCell_Tidy
            cell.configure_Tidy(tip_tidy: tipsList_Tidy[indexPath.item])
            cell.onCardTapped_Tidy = { [weak self] tip_tidy in
                self?.showTipDetail_Tidy(tip_tidy: tip_tidy)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Tidy: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard Section_Tidy(rawValue: indexPath.section) == .tips_tidy else { return }
        cell.animateSlideInFromBottom_Tidy(
            offset_Tidy: 28,
            delay_Tidy: Double(indexPath.item % 4) * AnimationConfig_Tidy.delayShort_Tidy
        )
    }
}
