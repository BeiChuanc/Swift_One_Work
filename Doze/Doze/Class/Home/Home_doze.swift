import UIKit
import SnapKit

// MARK: 首页

/// 首页视图控制器
/// 设计：深夜星空背景 + 品牌 Hero Header + 横滑统计芯片 + 睡眠状态卡
///       + 专属睡眠相册（按成长阶段/纪念日归类）+ 睡眠成长曲线（月/季切换）
class Home_Doze: UIViewController {

    // MARK: - 私有属性

    private let logic_Doze = HomeLogic_Doze.shared_Doze
    private var currentStatus_Doze: HomeLogic_Doze.SleepStatus_Doze = .deepSleep_doze
    private var sleepQuality_Doze: CGFloat = 0.8
    private var albumGroups_Doze: [SleepAlbumGroup_Doze] = []
    private var isMonthlyMode_Doze: Bool = true

    // MARK: - 背景 & 滚动

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentContainer_Doze = UIView()

    private let bgGradientLayer_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#12072A").cgColor,
            UIColor(hexstring_Doze: "#0A1628").cgColor,
            UIColor(hexstring_Doze: "#0E1F3D").cgColor
        ]
        gl.locations = [0, 0.5, 1.0]
        gl.startPoint = CGPoint(x: 0.2, y: 0)
        gl.endPoint = CGPoint(x: 0.8, y: 1)
        return gl
    }()

    private let glowLeft_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#7B2FBE").withAlphaComponent(0.18)
        v.isUserInteractionEnabled = false
        return v
    }()

    private let glowRight_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#1A56DB").withAlphaComponent(0.14)
        v.isUserInteractionEnabled = false
        return v
    }()

    private let starsContainer_Doze: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - Hero Header

    private let heroView_Doze = UIView()

    private let appNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Doze"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        lbl.textColor = .white
        return lbl
    }()

    private let appIconView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "moon.stars.fill")
        iv.tintColor = UIColor(hexstring_Doze: "#FFD700")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let greetingLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.65)
        return lbl
    }()

    private let dateLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.9)
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.8
        return lbl
    }()

    private let notifyButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "bell.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(hexstring_Doze: "#FFD700")
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 20
        return btn
    }()

    private let avatarView_Doze: CurrentUserAvatarView_Doze = {
        let v = CurrentUserAvatarView_Doze()
        return v
    }()

    // MARK: - 统计横滑栏（修复溢出）

    private let statsScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return sv
    }()

    private let statsStackView_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()

    // MARK: - 睡眠状态卡

    private let statusCardView_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.clipsToBounds = false
        return v
    }()

    private let statusCardGradient_Doze = CAGradientLayer()

    private let statusDecorCircle_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.isUserInteractionEnabled = false
        return v
    }()

    private let statusDecorDot_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v.isUserInteractionEnabled = false
        return v
    }()

    // 进度环
    private let progressRingContainer_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 60
        return v
    }()

    private let trackLayer_Doze = CAShapeLayer()
    private let progressLayer_Doze = CAShapeLayer()
    private var progressRingDrawn_Doze = false

    private let qualityPercentLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.7
        return lbl
    }()

    private let qualitySubLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Quality"
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.55)
        lbl.textAlignment = .center
        return lbl
    }()

    private let statusBadgeView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v.layer.cornerRadius = 10
        return v
    }()

    private let statusIconView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private let statusBadgeLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    private let statusTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.8
        return lbl
    }()

    private let statusDescLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.72)
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    private let statusDivider_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        return v
    }()

    // 今日时长芯片
    private let durationChipView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 12
        return v
    }()

    private let durationIconView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock.fill")
        iv.tintColor = UIColor(hexstring_Doze: "#FFD700")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let durationLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = UIColor(hexstring_Doze: "#FFD700")
        lbl.numberOfLines = 1
        return lbl
    }()

    private let durationTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Today's Sleep"
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.55)
        return lbl
    }()

    // 活跃宠物芯片
    private let activePetsChipView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 12
        return v
    }()

    private let activePetsIconView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = UIColor(hexstring_Doze: "#90CDF4")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let activePetsLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.textColor = UIColor(hexstring_Doze: "#90CDF4")
        return lbl
    }()

    private let activePetsTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Pet Status"
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.55)
        return lbl
    }()

    // MARK: - 睡眠相册区

    private let albumHeaderView_Doze = UIView()
    private let albumAccentBarGradient_Doze = CAGradientLayer()

    /// 相册区右上角"添加记录"按钮
    private let albumAddBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(hexstring_Doze: "#B794F6")
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    private let albumScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return sv
    }()

    private let albumCardStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 14
        sv.alignment = .center
        return sv
    }()

    // MARK: - 睡眠成长曲线区

    private let timelineHeaderView_Doze = UIView()
    private let timelineAccentBarGradient_Doze = CAGradientLayer()

    /// 月/季切换胶囊
    private let timelineToggleView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 16
        return v
    }()

    private let monthToggleBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Monthly", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.tag = 0
        btn.layer.cornerRadius = 14
        return btn
    }()

    private let seasonToggleBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Seasonal", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        btn.tag = 1
        btn.layer.cornerRadius = 14
        return btn
    }()

    private let toggleIndicator_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.4)
        v.layer.cornerRadius = 14
        return v
    }()

    private var toggleIndicatorLeadConstraint_Doze: Constraint?

    /// 图表卡片容器
    private let chartCardView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        return v
    }()

    private let growthChartView_Doze = SleepGrowthChartView_Doze()

    /// 图表底部数据摘要行（日志数 / 平均时长 / 最佳月份）
    private let chartSummaryStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.distribution = .fillEqually
        return sv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Doze()
        setupScrollView_Doze()
        setupHero_Doze()
        setupStatsBar_Doze()
        setupStatusCard_Doze()
        setupAlbumSection_Doze()
        setupTimelineSection_Doze()
        loadData_Doze()
        observeNotifications_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshStatusCard_Doze()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer_Doze.frame = view.bounds
        glowLeft_Doze.layer.cornerRadius = glowLeft_Doze.bounds.width / 2
        glowRight_Doze.layer.cornerRadius = glowRight_Doze.bounds.width / 2
        updateProgressRing_Doze()
        albumAccentBarGradient_Doze.frame = CGRect(x: 0, y: 0, width: 4, height: 26)
        timelineAccentBarGradient_Doze.frame = CGRect(x: 0, y: 0, width: 4, height: 26)
        statusCardGradient_Doze.frame = statusCardView_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 背景

    private func setupBackground_Doze() {
        view.layer.insertSublayer(bgGradientLayer_Doze, at: 0)

        view.addSubview(glowLeft_Doze)
        glowLeft_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-80)
            make.top.equalToSuperview().offset(-80)
            make.width.height.equalTo(300)
        }

        view.addSubview(glowRight_Doze)
        glowRight_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(200)
            make.width.height.equalTo(280)
        }

        view.addSubview(starsContainer_Doze)
        starsContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addStarParticles_Doze()
    }

    private func addStarParticles_Doze() {
        for _ in 0..<18 {
            let star = UIView()
            let size = CGFloat.random(in: 2.5...4.5)
            star.frame = CGRect(x: CGFloat.random(in: 0...APPSCREEN_Doze.WIDTH_Doze),
                                y: CGFloat.random(in: 0...APPSCREEN_Doze.HEIGHT_Doze * 0.55),
                                width: size, height: size)
            star.backgroundColor = .white
            star.layer.cornerRadius = size / 2
            star.layer.shadowColor = UIColor.white.cgColor
            star.layer.shadowOpacity = 0.8
            star.layer.shadowOffset = .zero
            let glow = CABasicAnimation(keyPath: "shadowRadius")
            glow.fromValue = 0; glow.toValue = 3.0
            glow.duration = Double.random(in: 2.0...4.5)
            glow.autoreverses = true; glow.repeatCount = .infinity
            star.layer.add(glow, forKey: "glow")
            let flicker = CABasicAnimation(keyPath: "opacity")
            flicker.fromValue = CGFloat.random(in: 0.3...0.6)
            flicker.toValue = CGFloat.random(in: 0.85...1.0)
            flicker.duration = Double.random(in: 1.8...4.2)
            flicker.beginTime = CACurrentMediaTime() + Double.random(in: 0...2.5)
            flicker.autoreverses = true; flicker.repeatCount = .infinity
            star.layer.add(flicker, forKey: "flicker")
            starsContainer_Doze.addSubview(star)
        }
        for _ in 0..<55 {
            let star = UIView()
            let size = CGFloat.random(in: 1.0...2.2)
            star.frame = CGRect(x: CGFloat.random(in: 0...APPSCREEN_Doze.WIDTH_Doze),
                                y: CGFloat.random(in: 0...APPSCREEN_Doze.HEIGHT_Doze * 0.6),
                                width: size, height: size)
            star.backgroundColor = UIColor.white.withAlphaComponent(CGFloat.random(in: 0.35...0.75))
            star.layer.cornerRadius = size / 2
            let flicker = CABasicAnimation(keyPath: "opacity")
            flicker.fromValue = CGFloat.random(in: 0.1...0.4)
            flicker.toValue = CGFloat.random(in: 0.6...1.0)
            flicker.duration = Double.random(in: 1.5...5.0)
            flicker.beginTime = CACurrentMediaTime() + Double.random(in: 0...4.0)
            flicker.autoreverses = true; flicker.repeatCount = .infinity
            star.layer.add(flicker, forKey: "flicker")
            starsContainer_Doze.addSubview(star)
        }
    }

    // MARK: - ScrollView

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        scrollView_Doze.addSubview(contentContainer_Doze)
        contentContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - Hero Header

    private func setupHero_Doze() {
        contentContainer_Doze.addSubview(heroView_Doze)
        heroView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }

        heroView_Doze.addSubview(appIconView_Doze)
        appIconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(30)
        }
        addTimeIconAnimation_Doze()

        heroView_Doze.addSubview(appNameLabel_Doze)
        appNameLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(appIconView_Doze.snp.right).offset(8)
            make.centerY.equalTo(appIconView_Doze)
        }

        heroView_Doze.addSubview(notifyButton_Doze)
        notifyButton_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(2)
            make.width.height.equalTo(40)
        }
        notifyButton_Doze.addTarget(self, action: #selector(handleNotifyTap_Doze), for: .touchUpInside)

        heroView_Doze.addSubview(avatarView_Doze)
        avatarView_Doze.snp.makeConstraints { make in
            make.right.equalTo(notifyButton_Doze.snp.left).offset(-10)
            make.centerY.equalTo(notifyButton_Doze)
            make.width.height.equalTo(40)
        }
        avatarView_Doze.onTapped_Doze = { [weak self] in
            guard let self else { return }
            (self.tabBarController as? TabBar_Doze)?.switchToTab_Doze(index_Doze: 4)
        }

        heroView_Doze.addSubview(greetingLabel_Doze)
        greetingLabel_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(appIconView_Doze.snp.bottom).offset(10)
        }

        heroView_Doze.addSubview(dateLabel_Doze)
        dateLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(greetingLabel_Doze.snp.right).offset(6)
            make.centerY.equalTo(greetingLabel_Doze)
            make.right.lessThanOrEqualTo(avatarView_Doze.snp.left).offset(-10)
        }

        greetingLabel_Doze.text = logic_Doze.getGreeting_Doze() + ","
        dateLabel_Doze.text = logic_Doze.getFormattedDate_Doze()
        appIconView_Doze.image = UIImage(systemName: logic_Doze.getTimeIcon_Doze())
    }

    private func addTimeIconAnimation_Doze() {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobble.values = [0, 0.18, -0.12, 0.09, -0.04, 0]
        wobble.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
        wobble.duration = 4.0
        wobble.repeatCount = .infinity
        wobble.beginTime = CACurrentMediaTime() + 0.8
        appIconView_Doze.layer.add(wobble, forKey: "wobble")
    }

    @objc private func handleNotifyTap_Doze() {
        notifyButton_Doze.animatePulse_Doze()
        // 切换底部 Tab 至消息列表（index 3）
        (tabBarController as? TabBar_Doze)?.switchToTab_Doze(index_Doze: 3)
    }

    // MARK: - 统计横滑栏（修复溢出）

    private func setupStatsBar_Doze() {
        contentContainer_Doze.addSubview(statsScrollView_Doze)
        statsScrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(heroView_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        statsScrollView_Doze.addSubview(statsStackView_Doze)
        statsStackView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    private func buildStatsChips_Doze() {
        statsStackView_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 全部从用户模型读取，无自建相册时均展示 0 / 默认值，杜绝随机模拟数据
        let user_doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        let qualityPct_doze = user_doze.avgSleepQualityPct_Doze
        let sleepStr_doze = user_doze.totalSleepDuration_Doze
        let albumCount_doze = user_doze.sleepAlbumCount_Doze
        let statusTitle_doze = logic_Doze.getSleepStatusFromQuality_Doze(
            qualityPct_doze: qualityPct_doze
        ).shortTitle_Doze

        let items_doze: [(String, String, String, String)] = [
            ("moon.zzz.fill",      "\(qualityPct_doze)%", "Quality", "#B794F6"),
            ("clock.fill",         sleepStr_doze,          "Sleep",   "#FFD700"),
            ("photo.on.rectangle", "\(albumCount_doze)",   "Albums",  "#90CDF4"),
            ("star.fill",          statusTitle_doze,        "Status",  "#68D391"),
        ]

        for (icon_doze, value_doze, title_doze, hex_doze) in items_doze {
            let chip = makeStatChip_Doze(
                icon_doze: icon_doze, value_doze: value_doze,
                title_doze: title_doze, color_doze: UIColor(hexstring_Doze: hex_doze)
            )
            statsStackView_Doze.addArrangedSubview(chip)
        }
    }

    /// 统计芯片（已修复溢出：固定宽度 + 截断）
    private func makeStatChip_Doze(
        icon_doze: String, value_doze: String,
        title_doze: String, color_doze: UIColor
    ) -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        chip.layer.cornerRadius = 14
        chip.layer.borderWidth = 1
        chip.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon_doze)
        iconView.tintColor = color_doze
        iconView.contentMode = .scaleAspectFit

        let valLabel = UILabel()
        valLabel.text = value_doze
        valLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        valLabel.textColor = .white
        valLabel.numberOfLines = 1
        valLabel.lineBreakMode = .byTruncatingTail
        valLabel.adjustsFontSizeToFitWidth = true
        valLabel.minimumScaleFactor = 0.75

        let titleLabel = UILabel()
        titleLabel.text = title_doze
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.55)
        titleLabel.numberOfLines = 1

        chip.addSubview(iconView)
        chip.addSubview(valLabel)
        chip.addSubview(titleLabel)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        valLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(6)
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(valLabel)
            make.top.equalTo(valLabel.snp.bottom).offset(1)
            make.bottom.equalToSuperview().offset(-10)
        }
        // 固定宽度避免芯片溢出
        chip.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.width.equalTo(96)
        }
        return chip
    }

    // MARK: - 睡眠状态卡

    private func setupStatusCard_Doze() {
        contentContainer_Doze.addSubview(statusCardView_Doze)
        statusCardView_Doze.snp.makeConstraints { make in
            make.top.equalTo(statsScrollView_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(188)
        }

        statusCardGradient_Doze.startPoint = CGPoint(x: 0, y: 0)
        statusCardGradient_Doze.endPoint = CGPoint(x: 1, y: 1)
        statusCardGradient_Doze.cornerRadius = 28
        statusCardView_Doze.layer.insertSublayer(statusCardGradient_Doze, at: 0)

        // 装饰圆
        statusCardView_Doze.addSubview(statusDecorCircle_Doze)
        statusDecorCircle_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(40)
            make.top.equalToSuperview().offset(-30)
            make.width.height.equalTo(170)
        }
        statusDecorCircle_Doze.layer.cornerRadius = 85

        statusCardView_Doze.addSubview(statusDecorDot_Doze)
        statusDecorDot_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(15)
            make.width.height.equalTo(80)
        }
        statusDecorDot_Doze.layer.cornerRadius = 40

        // 进度环
        statusCardView_Doze.addSubview(progressRingContainer_Doze)
        progressRingContainer_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(116)
        }
        progressRingContainer_Doze.addSubview(qualityPercentLabel_Doze)
        qualityPercentLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-7)
            make.left.right.equalToSuperview().inset(6)
        }
        progressRingContainer_Doze.addSubview(qualitySubLabel_Doze)
        qualitySubLabel_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(qualityPercentLabel_Doze.snp.bottom).offset(2)
        }

        // 状态徽章（限制宽度防溢出）
        statusCardView_Doze.addSubview(statusBadgeView_Doze)
        statusBadgeView_Doze.snp.makeConstraints { make in
            make.left.equalTo(progressRingContainer_Doze.snp.right).offset(14)
            make.top.equalTo(progressRingContainer_Doze)
            make.height.equalTo(22)
            make.right.lessThanOrEqualToSuperview().offset(-14)
        }
        statusBadgeView_Doze.addSubview(statusIconView_Doze)
        statusIconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        statusBadgeView_Doze.addSubview(statusBadgeLabel_Doze)
        statusBadgeLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(statusIconView_Doze.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }

        // 状态主标题（限制右边距防溢出）
        statusCardView_Doze.addSubview(statusTitleLabel_Doze)
        statusTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(statusBadgeView_Doze)
            make.top.equalTo(statusBadgeView_Doze.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-14)
        }

        // 状态描述
        statusCardView_Doze.addSubview(statusDescLabel_Doze)
        statusDescLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(statusBadgeView_Doze)
            make.top.equalTo(statusTitleLabel_Doze.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-14)
        }

        // 分割线
        statusCardView_Doze.addSubview(statusDivider_Doze)
        statusDivider_Doze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(1)
            make.bottom.equalToSuperview().offset(-50)
        }

        // 今日时长芯片
        statusCardView_Doze.addSubview(durationChipView_Doze)
        durationChipView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(30)
        }
        durationChipView_Doze.addSubview(durationIconView_Doze)
        durationIconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        durationChipView_Doze.addSubview(durationTitleLabel_Doze)
        durationTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(durationIconView_Doze.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        durationChipView_Doze.addSubview(durationLabel_Doze)
        durationLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(durationTitleLabel_Doze.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }

        // 活跃宠物芯片
        statusCardView_Doze.addSubview(activePetsChipView_Doze)
        activePetsChipView_Doze.snp.makeConstraints { make in
            make.left.equalTo(durationChipView_Doze.snp.right).offset(8)
            make.bottom.height.equalTo(durationChipView_Doze)
        }
        activePetsChipView_Doze.addSubview(activePetsIconView_Doze)
        activePetsIconView_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        activePetsChipView_Doze.addSubview(activePetsTitleLabel_Doze)
        activePetsTitleLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(activePetsIconView_Doze.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        activePetsChipView_Doze.addSubview(activePetsLabel_Doze)
        activePetsLabel_Doze.snp.makeConstraints { make in
            make.left.equalTo(activePetsTitleLabel_Doze.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
    }

    // MARK: - 睡眠相册区

    private func setupAlbumSection_Doze() {
        // Section header
        contentContainer_Doze.addSubview(albumHeaderView_Doze)
        albumHeaderView_Doze.snp.makeConstraints { make in
            make.top.equalTo(statusCardView_Doze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(26)
        }

        let accentBar = UIView()
        accentBar.layer.cornerRadius = 2
        albumAccentBarGradient_Doze.colors = [
            UIColor(hexstring_Doze: "#B794F6").cgColor,
            UIColor(hexstring_Doze: "#90CDF4").cgColor
        ]
        albumAccentBarGradient_Doze.startPoint = CGPoint(x: 0.5, y: 0)
        albumAccentBarGradient_Doze.endPoint = CGPoint(x: 0.5, y: 1)
        albumAccentBarGradient_Doze.cornerRadius = 2
        accentBar.layer.addSublayer(albumAccentBarGradient_Doze)
        albumHeaderView_Doze.addSubview(accentBar)
        accentBar.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        let titleLbl = UILabel()
        titleLbl.text = "Sleep Album"
        titleLbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLbl.textColor = .white
        albumHeaderView_Doze.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(accentBar.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        // 右侧"添加记录"按钮
        albumHeaderView_Doze.addSubview(albumAddBtn_Doze)
        albumAddBtn_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        albumAddBtn_Doze.addTarget(self, action: #selector(handleNewAlbumTap_Doze), for: .touchUpInside)

        // Horizontal scroll
        contentContainer_Doze.addSubview(albumScrollView_Doze)
        albumScrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(albumHeaderView_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        albumScrollView_Doze.addSubview(albumCardStack_Doze)
        albumCardStack_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    /// 重建相册横滑卡片；无相册时插入空状态占位卡
    private func rebuildAlbumCards_Doze() {
        albumCardStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 仅展示用户自建相册，预置分组不在此区显示
        let customGroups_doze = albumGroups_Doze.filter { $0.isCustom_Doze }
        if customGroups_doze.isEmpty {
            // 无数据：仅显示空状态居中，通过 Header "+" 新增
            albumCardStack_Doze.addArrangedSubview(makeAlbumEmptyCard_Doze())
        } else {
            // 有数据：仅显示相册卡，通过 Header 右侧 "+" 按钮新增
            for group in customGroups_doze {
                let card = makeAlbumCard_Doze(group: group)
                albumCardStack_Doze.addArrangedSubview(card)
            }
        }

        // 右侧留白
        let trail = UIView()
        trail.snp.makeConstraints { make in make.width.equalTo(24) }
        albumCardStack_Doze.addArrangedSubview(trail)
    }

    /// 构建空状态占位卡（无相册数据时展示）
    /// 构建空状态占位视图（无自建相册时展示，宽度占满可视区、内容居中）
    private func makeAlbumEmptyCard_Doze() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor
        // 宽度占满可视区（屏幕宽 - 左右 contentInset 各24）
        let emptyWidth = UIScreen.main.bounds.width - 48

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "photo.on.rectangle.angled")
        iconView.tintColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.4)
        iconView.contentMode = .scaleAspectFit
        card.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
            make.width.height.equalTo(44)
        }

        let titleLbl = UILabel()
        titleLbl.text = "No Albums Yet"
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        titleLbl.textColor = UIColor.white.withAlphaComponent(0.5)
        titleLbl.textAlignment = .center
        card.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        let descLbl = UILabel()
        descLbl.text = "Tap + to create your first sleep album"
        descLbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLbl.textColor = UIColor.white.withAlphaComponent(0.3)
        descLbl.textAlignment = .center
        descLbl.numberOfLines = 2
        card.addSubview(descLbl)
        descLbl.snp.makeConstraints { make in
            make.top.equalTo(titleLbl.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(16)
        }

        card.snp.makeConstraints { make in
            make.width.equalTo(emptyWidth)
            make.height.equalTo(200)
        }

        return card
    }

    /// 构建单张相册卡片
    /// 构建自定义相册卡片
    /// 布局：顶部全宽封面图（110pt） → 底部信息区（图标、标题、描述、时段）
    /// 质量角标叠放在封面图右下角，不遮盖信息区
    private func makeAlbumCard_Doze(group: SleepAlbumGroup_Doze) -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 18
        card.clipsToBounds = true
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.snp.makeConstraints { make in
            make.width.equalTo(155)
            make.height.equalTo(200)
        }

        // 渐变背景（全卡片）
        let gl = CAGradientLayer()
        let accentColor = UIColor(hexstring_Doze: group.accentColor_Doze)
        gl.colors = [
            accentColor.withAlphaComponent(0.35).cgColor,
            UIColor(hexstring_Doze: "#0A1628").withAlphaComponent(0.8).cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 0.5, y: 1)
        gl.cornerRadius = 18
        gl.frame = CGRect(x: 0, y: 0, width: 155, height: 200)
        card.layer.insertSublayer(gl, at: 0)

        // ── 封面图区（顶部全宽，高度 108pt）──
        let coverContainer = UIView()
        coverContainer.clipsToBounds = true
        card.addSubview(coverContainer)
        coverContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(108)
        }

        let coverPaths = group.coverMediaPaths_Doze
        if let firstPath = coverPaths.first {
            let mdv = MediaDisplayView_Doze()
            mdv.contentMode = .scaleAspectFill
            mdv.clipsToBounds = true
            mdv.configure_Doze(mediaPath_Doze: firstPath, isVideo_Doze: false)
            coverContainer.addSubview(mdv)
            mdv.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            // 无封面图时显示占位图标
            let placeholder = UIImageView()
            placeholder.image = UIImage(systemName: group.groupIcon_Doze)
            placeholder.tintColor = accentColor.withAlphaComponent(0.45)
            placeholder.contentMode = .scaleAspectFit
            coverContainer.addSubview(placeholder)
            placeholder.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(40)
            }
        }

        // 封面图渐变遮罩（底部渐淡，与信息区过渡）
        let coverFade = CAGradientLayer()
        coverFade.colors = [UIColor.clear.cgColor,
                            UIColor(hexstring_Doze: "#0A1628").withAlphaComponent(0.55).cgColor]
        coverFade.startPoint = CGPoint(x: 0.5, y: 0.5)
        coverFade.endPoint = CGPoint(x: 0.5, y: 1)
        coverFade.frame = CGRect(x: 0, y: 0, width: 155, height: 108)
        coverContainer.layer.addSublayer(coverFade)

        // 质量角标：叠在封面图右下角
        if group.sleepQualityPct_Doze > 0 {
            let badge = UILabel()
            badge.text = "\(group.sleepQualityPct_Doze)%"
            badge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            badge.textColor = .white
            badge.backgroundColor = accentColor.withAlphaComponent(0.75)
            badge.layer.cornerRadius = 8
            badge.clipsToBounds = true
            badge.textAlignment = .center
            card.addSubview(badge)
            badge.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-8)
                make.bottom.equalTo(coverContainer.snp.bottom).offset(-8)
                make.height.equalTo(18)
                make.width.greaterThanOrEqualTo(36)
            }
        }

        // ── 信息区（封面图下方）──

        // 图标
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: group.groupIcon_Doze)
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit
        card.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(coverContainer.snp.bottom).offset(10)
            make.width.height.equalTo(16)
        }

        // 标题
        let titleLbl = UILabel()
        titleLbl.text = group.groupTitle_Doze
        titleLbl.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLbl.textColor = .white
        titleLbl.numberOfLines = 1
        card.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(6)
            make.centerY.equalTo(iconView)
            make.right.equalToSuperview().offset(-10)
        }

        // 描述（customNote 优先，否则显示 groupSubtitle）
        let noteText = group.isCustom_Doze && !group.customNote_Doze.isEmpty
            ? group.customNote_Doze
            : group.groupSubtitle_Doze
        let noteLbl = UILabel()
        noteLbl.text = noteText
        noteLbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        noteLbl.textColor = UIColor.white.withAlphaComponent(0.55)
        noteLbl.numberOfLines = 2
        card.addSubview(noteLbl)
        noteLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(iconView.snp.bottom).offset(6)
        }

        // 睡眠时段（仅自定义相册有值时显示）
        if group.isCustom_Doze && !group.bedTime_Doze.isEmpty {
            let timeLbl = UILabel()
            timeLbl.text = "\(group.bedTime_Doze) – \(group.wakeTime_Doze)"
            timeLbl.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .medium)
            timeLbl.textColor = accentColor
            timeLbl.numberOfLines = 1
            card.addSubview(timeLbl)
            timeLbl.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-10)
                make.bottom.equalToSuperview().offset(-10)
            }
        }

        // 自定义相册才显示删除按钮（右上角）
        if group.isCustom_Doze {
            let deleteBtn = UIButton(type: .custom)
            let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
            deleteBtn.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
            deleteBtn.tintColor = .white
            deleteBtn.backgroundColor = UIColor.black.withAlphaComponent(0.40)
            deleteBtn.layer.cornerRadius = 13
            deleteBtn.tag = group.id
            deleteBtn.addTarget(self, action: #selector(handleAlbumDeleteTap_Doze(_:)), for: .touchUpInside)
            card.addSubview(deleteBtn)
            deleteBtn.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.right.equalToSuperview().offset(-8)
                make.width.height.equalTo(26)
            }
        }

        // 点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAlbumCardTap_Doze(_:)))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        card.tag = group.id

        return card
    }

    /// 构建"新建相册"卡片
    private func makeNewAlbumCard_Doze() -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 18
        card.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        card.layer.borderWidth = 1.5
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        card.snp.makeConstraints { make in make.width.equalTo(120) }

        // 虚线边框
        let dashed = CAShapeLayer()
        dashed.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        dashed.fillColor = UIColor.clear.cgColor
        dashed.lineWidth = 1.5
        dashed.lineDashPattern = [5, 4]
        dashed.cornerRadius = 18
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 120, height: 200),
                                cornerRadius: 18)
        dashed.path = path.cgPath
        dashed.frame = CGRect(x: 0, y: 0, width: 120, height: 200)
        card.layer.addSublayer(dashed)

        let plusIcon = UIImageView()
        plusIcon.image = UIImage(systemName: "plus.circle.fill")
        plusIcon.tintColor = UIColor(hexstring_Doze: "#B794F6").withAlphaComponent(0.7)
        plusIcon.contentMode = .scaleAspectFit
        card.addSubview(plusIcon)
        plusIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-12)
            make.width.height.equalTo(34)
        }

        let label = UILabel()
        label.text = "New Album"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        card.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(plusIcon.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleNewAlbumTap_Doze))
        card.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true

        // 呼吸动画
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0; pulse.toValue = 1.05
        pulse.duration = 1.8; pulse.autoreverses = true
        pulse.repeatCount = .infinity
        plusIcon.layer.add(pulse, forKey: "pulse")

        return card
    }

    // MARK: - 睡眠成长曲线区

    private func setupTimelineSection_Doze() {
        // Section header
        contentContainer_Doze.addSubview(timelineHeaderView_Doze)
        timelineHeaderView_Doze.snp.makeConstraints { make in
            make.top.equalTo(albumScrollView_Doze.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(26)
        }

        let accentBar = UIView()
        accentBar.layer.cornerRadius = 2
        timelineAccentBarGradient_Doze.colors = [
            UIColor(hexstring_Doze: "#FBB6CE").cgColor,
            UIColor(hexstring_Doze: "#FED7AA").cgColor
        ]
        timelineAccentBarGradient_Doze.startPoint = CGPoint(x: 0.5, y: 0)
        timelineAccentBarGradient_Doze.endPoint = CGPoint(x: 0.5, y: 1)
        timelineAccentBarGradient_Doze.cornerRadius = 2
        accentBar.layer.addSublayer(timelineAccentBarGradient_Doze)
        timelineHeaderView_Doze.addSubview(accentBar)
        accentBar.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }

        let titleLbl = UILabel()
        titleLbl.text = "Sleep Timeline"
        titleLbl.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLbl.textColor = .white
        timelineHeaderView_Doze.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(accentBar.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        // 月/季切换胶囊
        contentContainer_Doze.addSubview(timelineToggleView_Doze)
        timelineToggleView_Doze.snp.makeConstraints { make in
            make.top.equalTo(timelineHeaderView_Doze.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }

        timelineToggleView_Doze.addSubview(toggleIndicator_Doze)
        toggleIndicator_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(90)
            self.toggleIndicatorLeadConstraint_Doze = make.left.equalToSuperview().offset(4).constraint
        }

        [monthToggleBtn_Doze, seasonToggleBtn_Doze].forEach { btn in
            timelineToggleView_Doze.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(4)
                make.width.equalTo(90)
            }
            btn.addTarget(self, action: #selector(timelineToggleTapped_Doze(_:)), for: .touchUpInside)
        }
        monthToggleBtn_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
        }
        seasonToggleBtn_Doze.snp.makeConstraints { make in
            make.left.equalTo(monthToggleBtn_Doze.snp.right)
            make.right.equalToSuperview().offset(-4)
        }

        // 图表卡片
        contentContainer_Doze.addSubview(chartCardView_Doze)
        chartCardView_Doze.snp.makeConstraints { make in
            make.top.equalTo(timelineToggleView_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(220)
        }

        // 图表卡片渐变背景
        let chartBg = CAGradientLayer()
        chartBg.colors = [
            UIColor(hexstring_Doze: "#1E0A3C").withAlphaComponent(0.5).cgColor,
            UIColor(hexstring_Doze: "#0A1628").withAlphaComponent(0.5).cgColor
        ]
        chartBg.cornerRadius = 20
        chartBg.frame = CGRect(x: 0, y: 0,
                               width: APPSCREEN_Doze.WIDTH_Doze - 48, height: 220)
        chartCardView_Doze.layer.insertSublayer(chartBg, at: 0)

        chartCardView_Doze.addSubview(growthChartView_Doze)
        growthChartView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(160)
        }

        // 图表摘要行
        contentContainer_Doze.addSubview(chartSummaryStack_Doze)
        chartSummaryStack_Doze.snp.makeConstraints { make in
            make.top.equalTo(chartCardView_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
            // 不设固定高度，由内容自动撑开
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    /// 重建图表摘要数据行（日志数、平均质量、最佳时段）
    /// 重建图表摘要芯片
    /// 统计来源：当前自建相册真实数据（相册数 / 有数据期间均质量 / 最佳时间段标签）
    private func rebuildChartSummary_Doze(points: [SleepGrowthPoint_Doze]) {
        chartSummaryStack_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !points.isEmpty else { return }

        // 仅统计有实际数据（logCount > 0）的时间段
        let activePoints_doze = points.filter { $0.logCount_Doze > 0 }
        let totalAlbums_doze = activePoints_doze.reduce(0) { $0 + $1.logCount_Doze }

        // 均质量：只取有数据的周期均值，无数据则 0
        let avgQuality_doze: CGFloat
        if activePoints_doze.isEmpty {
            avgQuality_doze = 0
        } else {
            avgQuality_doze = activePoints_doze.reduce(0.0) { $0 + $1.avgQuality_Doze }
                / CGFloat(activePoints_doze.count)
        }

        // 最佳时间段：avgQuality 最高的标签，无数据则 "-"
        let best_doze = activePoints_doze.max(by: { $0.avgQuality_Doze < $1.avgQuality_Doze })

        let items_doze: [(String, String, String, UIColor)] = [
            ("photo.on.rectangle",
             totalAlbums_doze > 0 ? "\(totalAlbums_doze)" : "0",
             "Albums",
             UIColor(hexstring_Doze: "#90CDF4")),
            ("chart.line.uptrend.xyaxis",
             avgQuality_doze > 0 ? "\(Int(avgQuality_doze * 100))%" : "0%",
             "Avg Quality",
             UIColor(hexstring_Doze: "#B794F6")),
            ("star.fill",
             best_doze?.label_Doze ?? "-",
             "Best Period",
             UIColor(hexstring_Doze: "#FFD700")),
        ]

        for (icon_doze, value_doze, subtitle_doze, color_doze) in items_doze {
            let chip = makeChartSummaryChip_Doze(
                icon: icon_doze, value: value_doze,
                subtitle: subtitle_doze, color: color_doze
            )
            chartSummaryStack_Doze.addArrangedSubview(chip)
        }
    }

    /// 图表摘要芯片：图标 + 数值（大）+ 副标题（小）三行独立标签，彻底解决文本溢出
    private func makeChartSummaryChip_Doze(
        icon: String, value: String,
        subtitle: String, color: UIColor
    ) -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        chip.layer.cornerRadius = 14
        chip.layer.borderWidth = 1
        chip.layer.borderColor = UIColor.white.withAlphaComponent(0.10).cgColor

        let iv = UIImageView()
        iv.image = UIImage(systemName: icon)
        iv.tintColor = color
        iv.contentMode = .scaleAspectFit
        chip.addSubview(iv)

        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        valueLbl.textColor = color
        valueLbl.numberOfLines = 1
        valueLbl.textAlignment = .center
        valueLbl.adjustsFontSizeToFitWidth = true
        valueLbl.minimumScaleFactor = 0.7
        chip.addSubview(valueLbl)

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        subtitleLbl.textColor = UIColor.white.withAlphaComponent(0.55)
        subtitleLbl.numberOfLines = 1
        subtitleLbl.textAlignment = .center
        subtitleLbl.adjustsFontSizeToFitWidth = true
        subtitleLbl.minimumScaleFactor = 0.7
        chip.addSubview(subtitleLbl)

        iv.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(16)
        }
        valueLbl.snp.makeConstraints { make in
            make.top.equalTo(iv.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(6)
        }
        subtitleLbl.snp.makeConstraints { make in
            make.top.equalTo(valueLbl.snp.bottom).offset(3)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().offset(-10)
        }
        return chip
    }

    // MARK: - 数据加载

    private func loadData_Doze() {
        albumGroups_Doze = logic_Doze.getAlbumGroups_Doze()

        // 聚合统计写入用户模型 → 再从用户模型派生睡眠状态和质量（不使用随机值）
        syncAlbumStatsToUser_Doze()

        refreshStatusCard_Doze()
        buildStatsChips_Doze()
        rebuildAlbumCards_Doze()
        loadChartData_Doze()
        animateContentEntrance_Doze()
    }

    /// 从当前相册分组计算统计并写入用户模型
    private func syncAlbumStatsToUser_Doze() {
        let stats_doze = logic_Doze.computeAlbumStats_Doze(groups_doze: albumGroups_Doze)
        UserViewModel_Doze.shared_Doze.updateSleepStats_Doze(
            albumCount_doze: stats_doze.albumCount,
            totalLogs_doze: stats_doze.totalLogs,
            avgQualityPct_doze: stats_doze.avgQualityPct,
            totalDuration_doze: stats_doze.totalDuration
        )
    }

    /// 加载曲线数据（月/季切换时也调用）
    /// 数据来源：当前所有相册分组的帖子聚合
    private func loadChartData_Doze() {
        let points_doze = isMonthlyMode_Doze
            ? logic_Doze.getMonthlyDataFromAlbums_Doze(groups_doze: albumGroups_Doze)
            : logic_Doze.getSeasonalDataFromAlbums_Doze(groups_doze: albumGroups_Doze)
        growthChartView_Doze.setData_Doze(points_doze: points_doze)
        rebuildChartSummary_Doze(points: points_doze)
    }

    private func refreshStatusCard_Doze() {
        // 从用户模型读取真实数据，无自建相册时均为 0
        let user_doze = UserViewModel_Doze.shared_Doze.getCurrentUser_Doze()
        let qualityPct_doze = user_doze.avgSleepQualityPct_Doze
        sleepQuality_Doze = CGFloat(qualityPct_doze) / 100.0
        currentStatus_Doze = logic_Doze.getSleepStatusFromQuality_Doze(qualityPct_doze: qualityPct_doze)

        let color1_doze: UIColor
        let color2_doze: UIColor
        switch currentStatus_Doze {
        case .deepSleep_doze:
            color1_doze = UIColor(hexstring_Doze: "#2D1B69"); color2_doze = UIColor(hexstring_Doze: "#1A2B5E")
        case .lightSleep_doze:
            color1_doze = UIColor(hexstring_Doze: "#1A3A5E"); color2_doze = UIColor(hexstring_Doze: "#0D2B4E")
        case .napping_doze:
            color1_doze = UIColor(hexstring_Doze: "#3D1A4E"); color2_doze = UIColor(hexstring_Doze: "#2A1A4E")
        case .awake_doze:
            color1_doze = UIColor(hexstring_Doze: "#3D2B00"); color2_doze = UIColor(hexstring_Doze: "#1A2B3D")
        }
        statusCardGradient_Doze.colors = [color1_doze.cgColor, color2_doze.cgColor]
        statusCardView_Doze.layer.shadowColor = currentStatus_Doze.color_Doze.cgColor

        statusIconView_Doze.image = UIImage(systemName: currentStatus_Doze.iconName_Doze)
        statusIconView_Doze.tintColor = currentStatus_Doze.color_Doze
        statusBadgeLabel_Doze.text = currentStatus_Doze.title_Doze
        statusTitleLabel_Doze.text = currentStatus_Doze.title_Doze
        statusDescLabel_Doze.text = currentStatus_Doze.description_Doze
        // 今日睡眠时长取用户模型累计值，无相册时显示 "0h 0m"
        durationLabel_Doze.text = user_doze.totalSleepDuration_Doze
        // 宠物状态芯片：展示从用户模型质量推导的睡眠状态
        activePetsIconView_Doze.image = UIImage(systemName: currentStatus_Doze.iconName_Doze)
        activePetsIconView_Doze.tintColor = currentStatus_Doze.color_Doze
        activePetsLabel_Doze.text = currentStatus_Doze.shortTitle_Doze
        activePetsLabel_Doze.textColor = currentStatus_Doze.color_Doze
        qualityPercentLabel_Doze.text = "\(qualityPct_doze)%"

        addStatusCardBreathingAnimation_Doze()
    }

    // MARK: - 进度环绘制

    private func updateProgressRing_Doze() {
        guard !progressRingDrawn_Doze else { return }
        progressRingDrawn_Doze = true

        let center = CGPoint(x: 58, y: 58)
        let radius: CGFloat = 48
        let start = -CGFloat.pi / 2
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: start, endAngle: start + 2 * .pi, clockwise: true)

        trackLayer_Doze.path = path.cgPath
        trackLayer_Doze.strokeColor = UIColor.white.withAlphaComponent(0.12).cgColor
        trackLayer_Doze.lineWidth = 9; trackLayer_Doze.fillColor = UIColor.clear.cgColor
        trackLayer_Doze.lineCap = .round
        progressRingContainer_Doze.layer.addSublayer(trackLayer_Doze)

        progressLayer_Doze.path = path.cgPath
        progressLayer_Doze.strokeColor = currentStatus_Doze.color_Doze.cgColor
        progressLayer_Doze.lineWidth = 9; progressLayer_Doze.fillColor = UIColor.clear.cgColor
        progressLayer_Doze.lineCap = .round; progressLayer_Doze.strokeEnd = 0
        progressRingContainer_Doze.layer.addSublayer(progressLayer_Doze)

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0; anim.toValue = sleepQuality_Doze
        anim.duration = 1.4
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.fillMode = .forwards; anim.isRemovedOnCompletion = false
        progressLayer_Doze.add(anim, forKey: "stroke")
        progressLayer_Doze.strokeEnd = sleepQuality_Doze
    }

    // MARK: - 动画

    private func animateContentEntrance_Doze() {
        let views: [UIView] = [
            heroView_Doze, statsScrollView_Doze, statusCardView_Doze,
            albumHeaderView_Doze, albumScrollView_Doze,
            timelineHeaderView_Doze, timelineToggleView_Doze,
            chartCardView_Doze, chartSummaryStack_Doze
        ]
        views.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 28)
        }
        for (i, v) in views.enumerated() {
            UIView.animate(withDuration: 0.55, delay: Double(i) * 0.07,
                           usingSpringWithDamping: 0.82, initialSpringVelocity: 0.4,
                           options: [.curveEaseOut]) {
                v.alpha = 1; v.transform = .identity
            }
        }
    }

    private func addStatusCardBreathingAnimation_Doze() {
        statusCardView_Doze.layer.removeAnimation(forKey: "breathingGlow")
        let glow = CABasicAnimation(keyPath: "shadowRadius")
        glow.fromValue = 6; glow.toValue = 22
        glow.duration = 2.2; glow.autoreverses = true; glow.repeatCount = .infinity
        statusCardView_Doze.layer.shadowOpacity = 0.45
        statusCardView_Doze.layer.shadowOffset = .zero
        statusCardView_Doze.layer.add(glow, forKey: "breathingGlow")
    }

    // MARK: - 通知监听

    private func observeNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleStateChange_Doze),
            name: TitleViewModel_Doze.titleStateDidChangeNotification_Doze, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserStateChange_Doze),
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAlbumUpdate_Doze),
            name: NSNotification.Name("SleepAlbumDidUpdate_Doze"), object: nil
        )
    }

    @objc private func handleTitleStateChange_Doze() {
        buildStatsChips_Doze()
    }

    @objc private func handleUserStateChange_Doze() {
        avatarView_Doze.loadCurrentUserAvatar_Doze()
    }

    @objc private func handleAlbumUpdate_Doze() {
        albumGroups_Doze = logic_Doze.getAlbumGroups_Doze()
        // 同步统计到用户模型，刷新芯片、相册卡片及成长曲线
        syncAlbumStatsToUser_Doze()
        buildStatsChips_Doze()
        rebuildAlbumCards_Doze()
        loadChartData_Doze()
    }

    // MARK: - 用户交互

    @objc private func handleAlbumCardTap_Doze(_ gesture: UITapGestureRecognizer) {
        guard let card = gesture.view else { return }
        card.animatePressDown_Doze { card.animatePressUp_Doze() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // 查找对应相册分组（通过 tag 匹配 group.id）
        let matchedGroup = albumGroups_Doze.first { $0.id == card.tag }
        guard let group = matchedGroup else { return }
        // 跳转到发现页展示同类别日志（复用已有详情流程）
        if let firstPost = group.posts_Doze.first {
            Navigation_Doze.toTitleDetail_Doze(titleModel_doze: firstPost)
        }
    }

    /// 点击相册删除按钮 → 二次确认后删除并刷新
    @objc private func handleAlbumDeleteTap_Doze(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let albumId = sender.tag
        let alert = UIAlertController(
            title: "Delete Album",
            message: "Are you sure you want to delete this album? This action cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            HomeLogic_Doze.shared_Doze.removeCustomAlbum_Doze(id_doze: albumId)
            NotificationCenter.default.post(
                name: NSNotification.Name("SleepAlbumDidUpdate_Doze"), object: nil)
        })
        present(alert, animated: true)
    }

    @objc private func handleNewAlbumTap_Doze() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        Navigation_Doze.toSleepAlbumCreate_Doze()
    }

    @objc private func timelineToggleTapped_Doze(_ sender: UIButton) {
        guard (sender.tag == 0) != isMonthlyMode_Doze else { return }
        isMonthlyMode_Doze = (sender.tag == 0)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let targetOffset: CGFloat = isMonthlyMode_Doze ? 4 : 94
        UIView.animate(withDuration: 0.25, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            self.toggleIndicatorLeadConstraint_Doze?.update(offset: targetOffset)
            self.timelineToggleView_Doze.layoutIfNeeded()
        }
        monthToggleBtn_Doze.setTitleColor(
            isMonthlyMode_Doze ? .white : UIColor.white.withAlphaComponent(0.5), for: .normal)
        seasonToggleBtn_Doze.setTitleColor(
            isMonthlyMode_Doze ? UIColor.white.withAlphaComponent(0.5) : .white, for: .normal)

        // 重置图表动画重绘
        loadChartData_Doze()
    }
}
