import Foundation
import UIKit
import SnapKit

// MARK: 首页数据模型

/// 热爱日志条目模型
private struct HomeDiaryEntry_Niche: Codable {
    let id_niche: Int
    let text_niche: String
    let date_niche: String
    let userId_niche: Int
}

/// 挑战馆评论模型
fileprivate struct HomeChallengeComment_Niche {
    let id_niche: Int
    let userId_niche: Int
    let userName_niche: String
    let content_niche: String
}

/// 挑战馆话题模型
fileprivate struct ChallengeTopic_Niche {
    let id_niche: Int
    let emoji_niche: String
    let title_niche: String
    let desc_niche: String
}

// MARK: 首页

/// 首页视图控制器
/// 功能：
///   1. 我的热爱星盘 — 将所有用户可视化为星球（大小由帖子数决定），点击进入用户中心
///   2. 专属热爱日志 — 轻量级随手记录小众爱好日常
///   3. 时光亚藏挑战馆 — 3 条讨论话题，评论可举报/删除
class Home_Niche: UIViewController {

    // MARK: - 挑战馆静态话题

    private let _topics_niche: [ChallengeTopic_Niche] = [
        ChallengeTopic_Niche(id_niche: 1, emoji_niche: "🔥",
                             title_niche: "Bonfire Stories",
                             desc_niche: "Share your most magical bonfire memory with the tribe"),
        ChallengeTopic_Niche(id_niche: 2, emoji_niche: "🌙",
                             title_niche: "Night Owls United",
                             desc_niche: "What do you do when the night gets deep and quiet?"),
        ChallengeTopic_Niche(id_niche: 3, emoji_niche: "✨",
                             title_niche: "Hidden Gems",
                             desc_niche: "Drop your most underrated obsession or secret hobby")
    ]

    /// 挑战馆评论内存存储（topicId → comments），fileprivate static 供本文件所有类访问
    fileprivate static var _challengeComments_niche: [Int: [HomeChallengeComment_Niche]] = [:]

    /// 日志条目（UserDefaults 持久化）
    private var _diaryEntries_niche: [HomeDiaryEntry_Niche] = []
    private static let _diaryKey_niche = "HomeDiaryEntries_Niche"

    // MARK: - UI 组件 / 头部

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.contentInsetAdjustmentBehavior = .never
        return sv_niche
    }()
    private let _contentView_niche = UIView()
    private let _headerView_niche = UIView()
    private let _avatarView_niche = CurrentUserAvatarView_Niche()

    private let _greetingLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Good day,"
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.8)
        return l_niche
    }()

    private let _usernameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Explorer"
        l_niche.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        l_niche.textColor = .white
        return l_niche
    }()

    private let _taglineLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "Find your niche, ignite your spark ✦"
        l_niche.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.72)
        return l_niche
    }()

    // MARK: - UI 组件 / 星盘区域

    private let _starChartCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 22
        v_niche.clipsToBounds = true
        return v_niche
    }()

    /// 星球容器（在 viewDidLayoutSubviews 后创建星球）
    private let _planetCanvas_niche = UIView()

    // MARK: - UI 组件 / 日志区域

    private let _diaryCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 20
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.12).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_niche.layer.shadowRadius = 12
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    private let _diaryField_niche: UITextView = {
        let tv_niche = UITextView()
        tv_niche.font = UIFont.systemFont(ofSize: 14)
        tv_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tv_niche.backgroundColor = UIColor(hexstring_Niche: "#F8F6FF")
        tv_niche.layer.cornerRadius = 12
        tv_niche.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv_niche.textContainer.lineFragmentPadding = 0
        return tv_niche
    }()

    private let _diaryPlaceholder_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "What's on your mind today... 🌿"
        l_niche.font = UIFont.systemFont(ofSize: 14)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        l_niche.numberOfLines = 0
        return l_niche
    }()

    private let _diaryCharCount_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "0/100"
        l_niche.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        l_niche.textAlignment = .right
        return l_niche
    }()

    private let _diarySaveBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.setTitle("Save Vibe ✦", for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        btn_niche.setTitleColor(.white, for: .normal)
        btn_niche.layer.cornerRadius = 16
        btn_niche.clipsToBounds = true
        return btn_niche
    }()
    private var _diarySaveBtnGrad_niche: CAGradientLayer?

    private let _diaryListContainer_niche = UIStackView()

    // MARK: - UI 组件 / 挑战馆

    private let _challengeContainer_niche = UIStackView()

    // 挑战馆各话题评论输入框/列表容器已移至 ChallengeDetailPage_Niche，Home 只缓存话题引用

    /// 当前轨道旋转角度（拖拽手势更新）
    private var _orbitAngle_niche: CGFloat = 0
    /// 存储星球视图和对应用户（用于拖拽时直接更新坐标，无需重建）
    private var _planetViews_niche: [(view: UIView, diameter: CGFloat)] = []
    /// 标志位：星盘是否已构建

    private var _starChartBuilt_niche = false

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDiaryEntries_Niche()
        seedDefaultChallengeComments_Niche()
        setupUI_Niche()
        setupObservers_Niche()
        refreshUserInfo_Niche()
        buildChallengeSection_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshUserInfo_Niche()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Niche()
        refreshDiarySaveBtnGrad_Niche()
        // 星盘星球布局需要在有真实尺寸后执行一次
        if !_starChartBuilt_niche && _planetCanvas_niche.bounds.width > 10 {
            _starChartBuilt_niche = true
            buildPlanets_Niche()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }
        // contentInsetAdjustmentBehavior = .never 时需手动添加底部 inset，确保内容可滚出 Tab 栏遮挡区域
        _scrollView_niche.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildHeader_Niche()
        buildStarChartSection_Niche()
        buildDiarySection_Niche()
    }

    // MARK: - 头部

    private func buildHeader_Niche() {
        _contentView_niche.addSubview(_headerView_niche)
        _headerView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(170)
        }

        // 头像（右上）
        _headerView_niche.addSubview(_avatarView_niche)
        _avatarView_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(40)
        }
        _avatarView_niche.onTapped_Niche = { [weak self] in
            // 直接切换 TabBar 到「我的」页面（index 4）
            if let tabBar_niche = self?.tabBarController {
                tabBar_niche.selectedIndex = 4
            }
        }

        _headerView_niche.addSubview(_greetingLabel_niche)
        _greetingLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(64)
        }

        _headerView_niche.addSubview(_usernameLabel_niche)
        _usernameLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(_greetingLabel_niche.snp.bottom).offset(2)
        }

        _headerView_niche.addSubview(_taglineLabel_niche)
        _taglineLabel_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(_usernameLabel_niche.snp.bottom).offset(6)
            make.trailing.lessThanOrEqualTo(_avatarView_niche.snp.leading).offset(-10)
        }
    }

    // MARK: - 星盘区域

    private func buildStarChartSection_Niche() {
        let sectionHeader_niche = buildSectionHeader_Niche(
            title: "My Love Star Chart",
            subtitle: "Each planet is a tribe member · Tap to connect",
            emoji: "🪐"
        )
        _contentView_niche.addSubview(sectionHeader_niche)
        sectionHeader_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerView_niche.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        _contentView_niche.addSubview(_starChartCard_niche)
        _starChartCard_niche.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_niche.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }

        _starChartCard_niche.addSubview(_planetCanvas_niche)
        _planetCanvas_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        _planetCanvas_niche.backgroundColor = .clear

        // 拖拽手势：滑动旋转轨道
        let pan_niche = UIPanGestureRecognizer(target: self, action: #selector(handleOrbitPan_Niche(_:)))
        _planetCanvas_niche.isUserInteractionEnabled = true
        _planetCanvas_niche.addGestureRecognizer(pan_niche)
    }

    /// 在星盘内构建所有用户星球（需要在有布局尺寸后调用）
    /// 星球沿圆周等间距排布，拖拽轨道旋转由 updatePlanetPositions_Niche 更新坐标
    private func buildPlanets_Niche() {
        _planetCanvas_niche.subviews.forEach { $0.removeFromSuperview() }
        _planetViews_niche.removeAll()

        let users_niche = LocalData_Niche.shared_Niche.userList_Niche
        let posts_niche  = TitleViewModel_Niche.shared_Niche.getPosts_Niche()
        let canvasW_niche = _planetCanvas_niche.bounds.width
        let canvasH_niche = _planetCanvas_niche.bounds.height
        guard canvasW_niche > 0 && canvasH_niche > 0 else { return }

        // 中心装饰（发光核心，缩小比例）
        let core_niche = UIView()
        core_niche.backgroundColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.20)
        core_niche.layer.cornerRadius = 18
        core_niche.layer.shadowColor  = UIColor(hexstring_Niche: "#B794F6").cgColor
        core_niche.layer.shadowOffset = .zero
        core_niche.layer.shadowRadius = 12
        core_niche.layer.shadowOpacity = 0.6
        _planetCanvas_niche.addSubview(core_niche)
        core_niche.frame = CGRect(x: canvasW_niche/2 - 18, y: canvasH_niche/2 - 18, width: 36, height: 36)

        let coreLbl_niche = UILabel()
        coreLbl_niche.text = "✦"
        coreLbl_niche.font = UIFont.systemFont(ofSize: 20)
        coreLbl_niche.textAlignment = .center
        core_niche.addSubview(coreLbl_niche)
        coreLbl_niche.frame = core_niche.bounds

        let palette_niche: [UIColor] = [
            UIColor(hexstring_Niche: "#B794F6"),
            UIColor(hexstring_Niche: "#FF6B9D"),
            UIColor(hexstring_Niche: "#4ECDC4"),
            UIColor(hexstring_Niche: "#FDCB6E"),
            UIColor(hexstring_Niche: "#74B9FF"),
            UIColor(hexstring_Niche: "#55EFC4"),
            UIColor(hexstring_Niche: "#FD79A8")
        ]

        for (i_niche, user_niche) in users_niche.enumerated() {
            let userId_niche    = user_niche.userId_Niche ?? 0
            let postCount_niche = posts_niche.filter { $0.titleUserId_Niche == userId_niche }.count

            // 星球直径：36-46pt（比之前小），由帖子数决定
            let diameter_niche: CGFloat = min(CGFloat(36 + postCount_niche * 2), 46)
            let color_niche = palette_niche[i_niche % palette_niche.count]

            let planet_niche = buildPlanetView_Niche(
                user: user_niche, diameter: diameter_niche, color: color_niche
            )
            _planetCanvas_niche.addSubview(planet_niche)
            _planetViews_niche.append((view: planet_niche, diameter: diameter_niche))
        }

        // 初始布局星球位置
        updatePlanetPositions_Niche()
    }

    /// 根据当前 _orbitAngle_niche 更新所有星球坐标（不重建视图）
    private func updatePlanetPositions_Niche() {
        let canvasW_niche = _planetCanvas_niche.bounds.width
        let canvasH_niche = _planetCanvas_niche.bounds.height
        let cx_niche = canvasW_niche / 2
        let cy_niche = canvasH_niche / 2
        let count_niche = _planetViews_niche.count
        guard count_niche > 0 else { return }

        for (i_niche, entry_niche) in _planetViews_niche.enumerated() {
            let diameter_niche = entry_niche.diameter
            // 轨道半径：容器半径 - 星球半径 - 4pt 内边距，让星球刚好贴在圆周上
            let orbitR_niche = canvasW_niche / 2 - diameter_niche / 2 - 4
            let angle_niche  = (2 * CGFloat.pi / CGFloat(count_niche)) * CGFloat(i_niche) + _orbitAngle_niche
            let x_niche = cx_niche + cos(angle_niche) * orbitR_niche
            let y_niche = cy_niche + sin(angle_niche) * orbitR_niche
            entry_niche.view.frame = CGRect(
                x: x_niche - diameter_niche / 2,
                y: y_niche - diameter_niche / 2,
                width: diameter_niche,
                height: diameter_niche
            )
        }
    }

    /// 拖拽手势：将水平/竖直偏移量转化为轨道旋转角增量
    @objc private func handleOrbitPan_Niche(_ gesture: UIPanGestureRecognizer) {
        guard !_planetViews_niche.isEmpty else { return }
        let translation_niche = gesture.translation(in: _planetCanvas_niche)
        let orbitR_niche = _planetCanvas_niche.bounds.width / 2 - 26

        // 用移动距离除以轨道半径得到弧度增量（一次滑过整个周长 = 旋转一圈）
        let deltaAngle_niche = translation_niche.x / orbitR_niche
        _orbitAngle_niche += deltaAngle_niche
        gesture.setTranslation(.zero, in: _planetCanvas_niche)
        updatePlanetPositions_Niche()
    }

    private func buildPlanetView_Niche(user: PrewUserModel_Niche, diameter: CGFloat, color: UIColor) -> UIView {
        let planet_niche = UIView()
        planet_niche.layer.cornerRadius = diameter / 2
        planet_niche.layer.shadowColor  = color.cgColor
        planet_niche.layer.shadowOffset = .zero
        planet_niche.layer.shadowRadius = diameter * 0.25
        planet_niche.layer.shadowOpacity = 0.55
        planet_niche.isUserInteractionEnabled = true

        // 渐变背景
        let grad_niche = CAGradientLayer()
        grad_niche.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        grad_niche.cornerRadius = diameter / 2
        grad_niche.colors = [color.cgColor, color.withValues(alpha: 0.6).cgColor]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint   = CGPoint(x: 1, y: 1)
        planet_niche.layer.insertSublayer(grad_niche, at: 0)

        // 用户头像
        let avatar_niche = UserAvatarView_Niche()
        avatar_niche.configure_Niche(userId_Niche: user.userId_Niche ?? 0)
        avatar_niche.layer.cornerRadius = (diameter - 6) / 2
        avatar_niche.clipsToBounds = true
        planet_niche.addSubview(avatar_niche)
        avatar_niche.frame = CGRect(x: 3, y: 3, width: diameter - 6, height: diameter - 6)

        // 点击导航
        let tap_niche = PlanetTapGesture_Niche(user: user)
        tap_niche.addTarget(self, action: #selector(handlePlanetTap_Niche(_:)))
        planet_niche.addGestureRecognizer(tap_niche)

        return planet_niche
    }

    // MARK: - 日志区域

    private func buildDiarySection_Niche() {
        let sectionHeader_niche = buildSectionHeader_Niche(
            title: "My Vibe Journal",
            subtitle: "Record your niche moments · Keep it brief",
            emoji: "📓"
        )
        _contentView_niche.addSubview(sectionHeader_niche)
        sectionHeader_niche.snp.makeConstraints { make in
            make.top.equalTo(_starChartCard_niche.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        _contentView_niche.addSubview(_diaryCard_niche)
        _diaryCard_niche.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 输入区
        _diaryCard_niche.addSubview(_diaryField_niche)
        _diaryField_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.trailing.equalToSuperview().inset(14)
            make.height.equalTo(80)
        }
        _diaryField_niche.addSubview(_diaryPlaceholder_niche)
        _diaryPlaceholder_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        // 字符计数 + 保存按钮行
        _diaryCard_niche.addSubview(_diaryCharCount_niche)
        _diaryCard_niche.addSubview(_diarySaveBtn_niche)

        _diarySaveBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(_diaryField_niche.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(34)
            make.width.equalTo(110)
        }
        _diaryCharCount_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalTo(_diarySaveBtn_niche)
        }

        // 已有日志列表
        _diaryListContainer_niche.axis = .vertical
        _diaryListContainer_niche.spacing = 0
        _diaryCard_niche.addSubview(_diaryListContainer_niche)
        _diaryListContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(_diarySaveBtn_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }

        _diaryField_niche.delegate = self
        _diarySaveBtn_niche.addTarget(self, action: #selector(handleSaveDiary_Niche), for: .touchUpInside)

        refreshDiaryList_Niche()

        // ── 挑战馆在日志下方 ──
        let challengeHeader_niche = buildSectionHeader_Niche(
            title: "Niche Challenge Hall",
            subtitle: "Join the discussion · Share your vibe",
            emoji: "🎯"
        )
        _contentView_niche.addSubview(challengeHeader_niche)
        challengeHeader_niche.snp.makeConstraints { make in
            make.top.equalTo(_diaryCard_niche.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        _challengeContainer_niche.axis = .vertical
        _challengeContainer_niche.spacing = 14
        _contentView_niche.addSubview(_challengeContainer_niche)
        _challengeContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(challengeHeader_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 挑战馆区域

    private func buildChallengeSection_Niche() {
        _challengeContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for topic_niche in _topics_niche {
            let topicCard_niche = buildTopicPreviewCard_Niche(topic: topic_niche)
            _challengeContainer_niche.addArrangedSubview(topicCard_niche)
        }
    }

    /// 轻量预览卡：仅展示话题信息 + 评论数 + 进入箭头，点击跳转详情页
    private func buildTopicPreviewCard_Niche(topic: ChallengeTopic_Niche) -> UIView {
        let card_niche = UIView()
        card_niche.backgroundColor = .white
        card_niche.layer.cornerRadius = 18
        card_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.10).cgColor
        card_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_niche.layer.shadowRadius = 10
        card_niche.layer.shadowOpacity = 1
        card_niche.isUserInteractionEnabled = true

        let emojiLbl_niche = UILabel()
        emojiLbl_niche.text = topic.emoji_niche
        emojiLbl_niche.font = UIFont.systemFont(ofSize: 26)

        let titleLbl_niche = UILabel()
        titleLbl_niche.text = topic.title_niche
        titleLbl_niche.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche

        let descLbl_niche = UILabel()
        descLbl_niche.text = topic.desc_niche
        descLbl_niche.font = UIFont.systemFont(ofSize: 12)
        descLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        descLbl_niche.numberOfLines = 2

        // 评论数胶囊
        let count_niche = Home_Niche._challengeComments_niche[topic.id_niche]?.count ?? 0
        let countPill_niche = UIView()
        countPill_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.10)
        countPill_niche.layer.cornerRadius = 11
        let countLbl_niche = UILabel()
        countLbl_niche.text = "💬 \(count_niche) comments"
        countLbl_niche.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        countLbl_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        countPill_niche.addSubview(countLbl_niche)
        countLbl_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview().inset(4)
        }

        // 右侧箭头
        let arrowIV_niche = UIImageView()
        let aCfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        arrowIV_niche.image = UIImage(systemName: "chevron.right.circle.fill", withConfiguration: aCfg_niche)
        arrowIV_niche.tintColor = ColorConfig_Niche.primaryGradientStart_Niche
        arrowIV_niche.contentMode = .scaleAspectFit

        card_niche.addSubview(emojiLbl_niche)
        card_niche.addSubview(titleLbl_niche)
        card_niche.addSubview(descLbl_niche)
        card_niche.addSubview(countPill_niche)
        card_niche.addSubview(arrowIV_niche)

        emojiLbl_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
        }
        arrowIV_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(emojiLbl_niche)
            make.width.height.equalTo(24)
        }
        titleLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(emojiLbl_niche.snp.trailing).offset(8)
            make.centerY.equalTo(emojiLbl_niche)
            make.trailing.lessThanOrEqualTo(arrowIV_niche.snp.leading).offset(-8)
        }
        descLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(emojiLbl_niche.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        countPill_niche.snp.makeConstraints { make in
            make.top.equalTo(descLbl_niche.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 点击进入挑战详情页
        let tap_niche = TopicTapGesture_Niche(topic: topic)
        tap_niche.addTarget(self, action: #selector(handleTopicTap_Niche(_:)))
        card_niche.addGestureRecognizer(tap_niche)
        return card_niche
    }

    @objc private func handleTopicTap_Niche(_ gesture: TopicTapGesture_Niche) {
        gesture.view?.animatePressDown_Niche { gesture.view?.animatePressUp_Niche() }
        let detailVC_niche = ChallengeDetailPage_Niche(topic: gesture.topic_niche)
        detailVC_niche.onCommentsUpdated_Niche = { [weak self] in
            self?.buildChallengeSection_Niche()
        }
        Navigation_Niche.push_Niche(to: detailVC_niche)
    }

    // MARK: - 通用区域标题构建

    private func buildSectionHeader_Niche(title: String, subtitle: String, emoji: String) -> UIView {
        let v_niche = UIView()

        let emojiLbl_niche = UILabel()
        emojiLbl_niche.text = emoji
        emojiLbl_niche.font = UIFont.systemFont(ofSize: 20)
        v_niche.addSubview(emojiLbl_niche)
        emojiLbl_niche.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }

        let titleLbl_niche = UILabel()
        titleLbl_niche.text = title
        titleLbl_niche.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        titleLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        v_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(emojiLbl_niche.snp.trailing).offset(6)
            make.centerY.equalTo(emojiLbl_niche)
        }

        let subLbl_niche = UILabel()
        subLbl_niche.text = subtitle
        subLbl_niche.font = UIFont.systemFont(ofSize: 12)
        subLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        v_niche.addSubview(subLbl_niche)
        subLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(emojiLbl_niche.snp.bottom).offset(2)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        return v_niche
    }

    // MARK: - 渐变刷新

    private func refreshHeaderGradient_Niche() {
        _headerView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_headerView_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerView_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#6B21A8").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#93C5FD").cgColor
        ]
        grad_niche.locations = [0, 0.6, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        grad_niche.cornerRadius = 30
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _headerView_niche.layer.insertSublayer(grad_niche, at: 0)

        // 星盘正圆 cornerRadius（需在有 bounds 后设置）
        if !_starChartCard_niche.bounds.isEmpty {
            _starChartCard_niche.layer.cornerRadius = _starChartCard_niche.bounds.width / 2
        }

        // 星盘背景渐变
        _starChartCard_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_starChartCard_niche.bounds.isEmpty else { return }
        let starGrad_niche = CAGradientLayer()
        starGrad_niche.frame = _starChartCard_niche.bounds
        starGrad_niche.colors = [
            UIColor(hexstring_Niche: "#0F0A2E").cgColor,
            UIColor(hexstring_Niche: "#1A1050").cgColor,
            UIColor(hexstring_Niche: "#2D1B69").cgColor
        ]
        starGrad_niche.locations = [0, 0.5, 1.0]
        starGrad_niche.startPoint = CGPoint(x: 0, y: 0)
        starGrad_niche.endPoint = CGPoint(x: 1, y: 1)
        _starChartCard_niche.layer.insertSublayer(starGrad_niche, at: 0)
    }

    private func refreshDiarySaveBtnGrad_Niche() {
        guard !_diarySaveBtn_niche.bounds.isEmpty else { return }
        if _diarySaveBtnGrad_niche == nil {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _diarySaveBtn_niche.bounds)
            grad_niche.cornerRadius = 16
            _diarySaveBtn_niche.layer.insertSublayer(grad_niche, at: 0)
            _diarySaveBtnGrad_niche = grad_niche
        }
        _diarySaveBtnGrad_niche?.frame = _diarySaveBtn_niche.bounds
    }

    // MARK: - 数据

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Niche),
            name: UserViewModel_Niche.userStateDidChangeNotification_Niche, object: nil
        )
    }

    @objc private func handleStateChange_Niche() {
        refreshUserInfo_Niche()
        _starChartBuilt_niche = false
        _planetViews_niche.removeAll()
        view.setNeedsLayout()
    }

    private func refreshUserInfo_Niche() {
        let user_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        if let name_niche = user_niche.userName_Niche, user_niche.userId_Niche != 0 {
            _usernameLabel_niche.text = name_niche
            _greetingLabel_niche.text = "Welcome back,"
        } else {
            _usernameLabel_niche.text = "Explorer"
            _greetingLabel_niche.text = "Good day,"
        }
        _avatarView_niche.loadCurrentUserAvatar_Niche()
    }

    // MARK: - 日志持久化

    private func loadDiaryEntries_Niche() {
        guard let data_niche = UserDefaults.standard.data(forKey: Home_Niche._diaryKey_niche),
              let entries_niche = try? JSONDecoder().decode([HomeDiaryEntry_Niche].self, from: data_niche) else { return }
        _diaryEntries_niche = entries_niche
    }

    private func saveDiaryEntries_Niche() {
        if let data_niche = try? JSONEncoder().encode(_diaryEntries_niche) {
            UserDefaults.standard.set(data_niche, forKey: Home_Niche._diaryKey_niche)
        }
    }

    /// 为挑战馆每个话题预制 2-3 条默认评论，仅在首次（数据为空时）执行
    private func seedDefaultChallengeComments_Niche() {
        guard Home_Niche._challengeComments_niche.isEmpty else { return }

        /// 从本地用户列表取前5个用于预制评论，避免硬编码不存在的用户ID
        let seedUsers_niche = Array(LocalData_Niche.shared_Niche.userList_Niche.prefix(5))
        guard seedUsers_niche.count >= 2 else { return }

        /// 取用户信息的快捷方法（下标越界时复用最后一个）
        func user_niche(_ idx: Int) -> PrewUserModel_Niche {
            seedUsers_niche[min(idx, seedUsers_niche.count - 1)]
        }

        var nextId_niche = 9000

        /// 话题1：Bonfire Stories
        Home_Niche._challengeComments_niche[1] = [
            HomeChallengeComment_Niche(
                id_niche: nextId_niche,
                userId_niche: user_niche(0).userId_Niche ?? 1,
                userName_niche: user_niche(0).userName_Niche ?? "User",
                content_niche: "The night we made a bonfire at the beach in Maine... played guitar until 3am and nobody wanted to leave. Pure magic. 🎸🔥"
            ),
            HomeChallengeComment_Niche(
                id_niche: nextId_niche + 1,
                userId_niche: user_niche(1).userId_Niche ?? 2,
                userName_niche: user_niche(1).userName_Niche ?? "User",
                content_niche: "Camping in the Rockies last summer. Roasted marshmallows and told ghost stories. The smell of pine and smoke still brings me right back. 🌲"
            ),
            HomeChallengeComment_Niche(
                id_niche: nextId_niche + 2,
                userId_niche: user_niche(2).userId_Niche ?? 3,
                userName_niche: user_niche(2).userName_Niche ?? "User",
                content_niche: "Our annual backyard bonfire every October — hot cocoa, old friends, new stories. Some traditions just hit different. ❤️"
            )
        ]
        nextId_niche += 10

        /// 话题2：Night Owls United
        Home_Niche._challengeComments_niche[2] = [
            HomeChallengeComment_Niche(
                id_niche: nextId_niche,
                userId_niche: user_niche(1).userId_Niche ?? 2,
                userName_niche: user_niche(1).userName_Niche ?? "User",
                content_niche: "Reading by lamplight with rain on the window. That's my 2am vibe. Everyone else asleep, feels like the whole world belongs to me. 🌧️"
            ),
            HomeChallengeComment_Niche(
                id_niche: nextId_niche + 1,
                userId_niche: user_niche(3).userId_Niche ?? 4,
                userName_niche: user_niche(3).userName_Niche ?? "User",
                content_niche: "I sketch fashion designs and listen to film scores when it gets late. The quiet just unlocks a totally different part of my brain. ✏️🎵"
            )
        ]
        nextId_niche += 10

        /// 话题3：Hidden Gems
        Home_Niche._challengeComments_niche[3] = [
            HomeChallengeComment_Niche(
                id_niche: nextId_niche,
                userId_niche: user_niche(0).userId_Niche ?? 1,
                userName_niche: user_niche(0).userName_Niche ?? "User",
                content_niche: "Competitive jigsaw puzzling. Yes, that's a thing. Done a 5000-piece in under a week and I'm absolutely not ashamed. 🧩"
            ),
            HomeChallengeComment_Niche(
                id_niche: nextId_niche + 1,
                userId_niche: user_niche(2).userId_Niche ?? 3,
                userName_niche: user_niche(2).userName_Niche ?? "User",
                content_niche: "Miniature bottle cap collecting. Each one tells a story from a different era or country. My room is basically a tiny museum. 🏺"
            ),
            HomeChallengeComment_Niche(
                id_niche: nextId_niche + 2,
                userId_niche: user_niche(4).userId_Niche ?? 5,
                userName_niche: user_niche(4).userName_Niche ?? "User",
                content_niche: "Old radio dramas from the 40s and 50s. The storytelling is incredible and nobody my age even knows they exist. 📻"
            )
        ]
    }

    private func refreshDiaryList_Niche() {
        _diaryListContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currentUserId_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche().userId_Niche ?? 0
        let myEntries_niche = _diaryEntries_niche.filter { $0.userId_niche == currentUserId_niche }.suffix(3)

        if myEntries_niche.isEmpty { return }

        let divider_niche = UIView()
        divider_niche.backgroundColor = ColorConfig_Niche.divider_Niche
        _diaryListContainer_niche.addArrangedSubview(divider_niche)
        divider_niche.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        for entry_niche in myEntries_niche {
            let row_niche = buildDiaryEntryRow_Niche(entry: entry_niche)
            _diaryListContainer_niche.addArrangedSubview(row_niche)
        }
    }

    private func buildDiaryEntryRow_Niche(entry: HomeDiaryEntry_Niche) -> UIView {
        let row_niche = UIView()

        let dot_niche = UIView()
        dot_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.5)
        dot_niche.layer.cornerRadius = 3

        let dateLbl_niche = UILabel()
        dateLbl_niche.text = entry.date_niche
        dateLbl_niche.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        dateLbl_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche

        let textLbl_niche = UILabel()
        textLbl_niche.text = entry.text_niche
        textLbl_niche.font = UIFont.systemFont(ofSize: 13)
        textLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        textLbl_niche.numberOfLines = 2

        /// 删除按钮（垃圾桶图标，右侧对齐）
        let deleteBtn_niche = UIButton(type: .custom)
        let delCfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        deleteBtn_niche.setImage(
            UIImage(systemName: "trash", withConfiguration: delCfg_niche),
            for: .normal
        )
        deleteBtn_niche.tintColor = ColorConfig_Niche.textPlaceholder_Niche

        row_niche.addSubview(dot_niche)
        row_niche.addSubview(dateLbl_niche)
        row_niche.addSubview(deleteBtn_niche)
        row_niche.addSubview(textLbl_niche)

        dot_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(6)
        }
        dateLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(dot_niche.snp.trailing).offset(8)
            make.centerY.equalTo(dot_niche)
        }
        /// 删除按钮固定在右侧，与日期行垂直居中
        deleteBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(dot_niche)
            make.width.height.equalTo(24)
        }
        textLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(dot_niche.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(deleteBtn_niche.snp.leading).offset(-8)
            make.bottom.equalToSuperview().offset(-10)
        }

        let entryId_niche = entry.id_niche
        deleteBtn_niche.addAction(UIAction { [weak self] _ in
            self?.confirmDeleteEntry_Niche(entryId: entryId_niche)
        }, for: .touchUpInside)

        return row_niche
    }

    /// 弹出确认框后删除指定日志条目
    /// - Parameter entryId: 要删除条目的唯一 ID
    private func confirmDeleteEntry_Niche(entryId: Int) {
        let alert_niche = UIAlertController(
            title: "Delete Entry",
            message: "Are you sure you want to delete this vibe entry?",
            preferredStyle: .alert
        )
        alert_niche.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_niche.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self._diaryEntries_niche.removeAll { $0.id_niche == entryId }
            self.saveDiaryEntries_Niche()
            self.refreshDiaryList_Niche()
            Utils_Niche.showSuccess_Niche(message_Niche: "Entry deleted.")
        })
        present(alert_niche, animated: true)
    }

    // MARK: - 事件处理

    @objc private func handlePlanetTap_Niche(_ gesture: PlanetTapGesture_Niche) {
        gesture.view?.animatePulse_Niche()
        Navigation_Niche.toUserInfo_Niche(with: gesture.user_niche)
    }

    @objc private func handleSaveDiary_Niche() {
        guard UserViewModel_Niche.shared_Niche.isLoggedIn_Niche else {
            Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
            return
        }
        let text_niche = _diaryField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_niche.isEmpty else {
            _diaryField_niche.animateShake_Niche()
            return
        }

        let formatter_niche = DateFormatter()
        formatter_niche.dateFormat = "MMM d, HH:mm"
        let entry_niche = HomeDiaryEntry_Niche(
            id_niche: Int(Date().timeIntervalSince1970 * 1000),
            text_niche: text_niche,
            date_niche: formatter_niche.string(from: Date()),
            userId_niche: UserViewModel_Niche.shared_Niche.getCurrentUser_Niche().userId_Niche ?? 0
        )
        _diaryEntries_niche.insert(entry_niche, at: 0)
        saveDiaryEntries_Niche()
        _diaryField_niche.text = nil
        _diaryPlaceholder_niche.isHidden = false
        _diaryCharCount_niche.text = "0/100"
        view.endEditing(true)
        _diarySaveBtn_niche.animatePulse_Niche()
        refreshDiaryList_Niche()
        Utils_Niche.showSuccess_Niche(message_Niche: "Vibe saved! ✦")
    }

}

// MARK: - UITextViewDelegate（日志字符计数）

extension Home_Niche: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count_niche = textView.text?.count ?? 0
        _diaryPlaceholder_niche.isHidden = count_niche > 0
        _diaryCharCount_niche.text = "\(min(count_niche, 100))/100"
        _diaryCharCount_niche.textColor = count_niche > 90
            ? UIColor(hexstring_Niche: "#FC5252")
            : ColorConfig_Niche.textPlaceholder_Niche
        if count_niche > 100 {
            textView.text = String(textView.text.prefix(100))
        }
    }
}

// MARK: - 星球点击手势辅助类

private class PlanetTapGesture_Niche: UITapGestureRecognizer {
    let user_niche: PrewUserModel_Niche
    init(user: PrewUserModel_Niche) {
        self.user_niche = user
        super.init(target: nil, action: nil)
    }
}

// MARK: - 话题点击手势辅助类

private class TopicTapGesture_Niche: UITapGestureRecognizer {
    let topic_niche: ChallengeTopic_Niche
    init(topic: ChallengeTopic_Niche) {
        self.topic_niche = topic
        super.init(target: nil, action: nil)
    }
}

// MARK: - 挑战馆详情页

/// 挑战详情页
/// 功能：展示挑战主题 + 讨论区评论列表 + 底部输入框发送评论
/// 评论支持举报/删除，数据共享自 Home_Niche._challengeComments_niche
class ChallengeDetailPage_Niche: UIViewController {

    /// 回调：评论更新后通知 Home 页刷新预览
    var onCommentsUpdated_Niche: (() -> Void)?

    private let _topic_niche: ChallengeTopic_Niche

    // MARK: - UI 组件

    private let _headerView_niche = UIView()
    private let _backBtn_niche = BackButton_Niche()

    private let _topicEmojiLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 36)
        l_niche.textAlignment = .center
        return l_niche
    }()

    private let _topicTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()

    private let _topicDescLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.78)
        l_niche.textAlignment = .center
        l_niche.numberOfLines = 2
        return l_niche
    }()

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        return sv_niche
    }()
    private let _contentView_niche = UIView()
    private let _commentsContainer_niche = UIStackView()

    private let _inputBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.07).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: -2)
        v_niche.layer.shadowRadius = 8
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    private let _inputField_niche: UITextField = {
        let tf_niche = UITextField()
        tf_niche.placeholder = "Share your thoughts..."
        tf_niche.font = UIFont.systemFont(ofSize: 14)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = UIColor(hexstring_Niche: "#F8F6FF")
        tf_niche.layer.cornerRadius = 20
        return tf_niche
    }()

    private let _sendBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_niche.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        return btn_niche
    }()
    private var _sendBtnGrad_niche: CAGradientLayer?

    // MARK: - 初始化

    fileprivate init(topic: ChallengeTopic_Niche) {
        self._topic_niche = topic
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGrad_Niche()
        refreshSendBtnGrad_Niche()
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // 固定底部输入栏
        view.addSubview(_inputBar_niche)
        _inputBar_niche.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(66)
        }
        _inputField_niche.addLeftPadding_Niche(16)
        _inputField_niche.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)
        _inputBar_niche.addSubview(_inputField_niche)
        _inputBar_niche.addSubview(_sendBtn_niche)
        _sendBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        _inputField_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.trailing.equalTo(_sendBtn_niche.snp.leading).offset(-10)
        }
        _sendBtn_niche.addTarget(self, action: #selector(handleSend_Niche), for: .touchUpInside)

        // 渐变头部
        view.addSubview(_headerView_niche)
        _headerView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(185)
        }
        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { [weak self] in
            Navigation_Niche.pop_Niche()
            self?.onCommentsUpdated_Niche?()
        }

        _headerView_niche.addSubview(_topicEmojiLabel_niche)
        _headerView_niche.addSubview(_topicTitleLabel_niche)
        _headerView_niche.addSubview(_topicDescLabel_niche)

        _topicEmojiLabel_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
        }
        _topicTitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_topicEmojiLabel_niche.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        _topicDescLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_topicTitleLabel_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        _topicEmojiLabel_niche.text  = _topic_niche.emoji_niche
        _topicTitleLabel_niche.text  = _topic_niche.title_niche
        _topicDescLabel_niche.text   = _topic_niche.desc_niche

        // 评论滚动区
        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in
            make.top.equalTo(_headerView_niche.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_inputBar_niche.snp.top)
        }
        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        _commentsContainer_niche.axis = .vertical
        _commentsContainer_niche.spacing = 0
        _contentView_niche.addSubview(_commentsContainer_niche)
        _commentsContainer_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        refreshComments_Niche()
    }

    private func refreshHeaderGrad_Niche() {
        _headerView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_headerView_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _headerView_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#6B21A8").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#93C5FD").cgColor
        ]
        grad_niche.locations = [0, 0.6, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        grad_niche.cornerRadius = 28
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _headerView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshSendBtnGrad_Niche() {
        guard !_sendBtn_niche.bounds.isEmpty else { return }
        if _sendBtnGrad_niche == nil {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _sendBtn_niche.bounds)
            grad_niche.cornerRadius = 20
            _sendBtn_niche.layer.insertSublayer(grad_niche, at: 0)
            _sendBtnGrad_niche = grad_niche
        }
        _sendBtnGrad_niche?.frame = _sendBtn_niche.bounds
    }

    // MARK: - 评论列表刷新

    private func refreshComments_Niche() {
        _commentsContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let topicId_niche = _topic_niche.id_niche
        let comments_niche = Home_Niche._challengeComments_niche[topicId_niche] ?? []

        if comments_niche.isEmpty {
            let emptyV_niche = buildEmptyComments_Niche()
            _commentsContainer_niche.addArrangedSubview(emptyV_niche)
            return
        }
        for comment_niche in comments_niche {
            let row_niche = buildCommentRow_Niche(comment: comment_niche)
            _commentsContainer_niche.addArrangedSubview(row_niche)
        }
    }

    private func buildEmptyComments_Niche() -> UIView {
        let v_niche = UIView()
        let lbl_niche = UILabel()
        lbl_niche.text = "No comments yet. Be the first to share! 💬"
        lbl_niche.font = UIFont.systemFont(ofSize: 14)
        lbl_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        lbl_niche.textAlignment = .center
        lbl_niche.numberOfLines = 2
        v_niche.addSubview(lbl_niche)
        lbl_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20))
        }
        return v_niche
    }

    private func buildCommentRow_Niche(comment: HomeChallengeComment_Niche) -> UIView {
        let row_niche = UIView()
        row_niche.backgroundColor = .white

        let div_niche = UIView()
        div_niche.backgroundColor = ColorConfig_Niche.divider_Niche
        let avatar_niche = UserAvatarView_Niche()
        avatar_niche.configure_Niche(userId_Niche: comment.userId_niche)
        let nameLbl_niche = UILabel()
        nameLbl_niche.text = comment.userName_niche
        nameLbl_niche.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche

        let isMine_niche = UserViewModel_Niche.shared_Niche.isCurrentUser_Niche(userId_niche: comment.userId_niche)
        let actionBtn_niche = UIButton(type: .custom)
        let aCfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        actionBtn_niche.setImage(
            UIImage(systemName: isMine_niche ? "trash" : "ellipsis", withConfiguration: aCfg_niche), for: .normal
        )
        actionBtn_niche.tintColor = ColorConfig_Niche.textSecondary_Niche

        let contentBubble_niche = UIView()
        contentBubble_niche.backgroundColor = UIColor(hexstring_Niche: "#F8F6FF")
        contentBubble_niche.layer.cornerRadius = 10
        let contentLbl_niche = UILabel()
        contentLbl_niche.text = comment.content_niche
        contentLbl_niche.font = UIFont.systemFont(ofSize: 13)
        contentLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        contentLbl_niche.numberOfLines = 0

        row_niche.addSubview(div_niche)
        row_niche.addSubview(avatar_niche)
        row_niche.addSubview(nameLbl_niche)
        row_niche.addSubview(actionBtn_niche)
        row_niche.addSubview(contentBubble_niche)
        contentBubble_niche.addSubview(contentLbl_niche)

        div_niche.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        avatar_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }
        nameLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(avatar_niche.snp.trailing).offset(8)
            make.centerY.equalTo(avatar_niche)
        }
        actionBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(avatar_niche)
            make.width.height.equalTo(24)
        }
        contentBubble_niche.snp.makeConstraints { make in
            make.top.equalTo(avatar_niche.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }
        contentLbl_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        }

        let commentRef_niche = comment
        let topicId_niche = _topic_niche.id_niche
        actionBtn_niche.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if isMine_niche {
                Home_Niche._challengeComments_niche[topicId_niche]?.removeAll { $0.id_niche == commentRef_niche.id_niche }
                self.refreshComments_Niche()
                Utils_Niche.showSuccess_Niche(message_Niche: "Deleted successfully.")
            } else {
                UIAlertController.report_Niche(with: false) {
                    Home_Niche._challengeComments_niche[topicId_niche]?.removeAll { $0.id_niche == commentRef_niche.id_niche }
                    self.refreshComments_Niche()
                    Utils_Niche.showSuccess_Niche(message_Niche: "This comment will no longer appear.")
                }
            }
        }, for: .touchUpInside)

        return row_niche
    }

    // MARK: - 发送评论

    @objc private func handleSend_Niche() {
        let text_niche = _inputField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_niche.isEmpty else { return }

        guard UserViewModel_Niche.shared_Niche.isLoggedIn_Niche else {
            Navigation_Niche.toLogin_Niche(style_niche: .present_niche)
            return
        }

        let user_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
        let comment_niche = HomeChallengeComment_Niche(
            id_niche: Int(Date().timeIntervalSince1970 * 1000),
            userId_niche: user_niche.userId_Niche ?? 0,
            userName_niche: user_niche.userName_Niche ?? "User",
            content_niche: text_niche
        )

        let topicId_niche = _topic_niche.id_niche
        if Home_Niche._challengeComments_niche[topicId_niche] == nil {
            Home_Niche._challengeComments_niche[topicId_niche] = []
        }
        Home_Niche._challengeComments_niche[topicId_niche]?.append(comment_niche)

        _inputField_niche.text = nil
        view.endEditing(true)
        _sendBtn_niche.animatePulse_Niche()
        refreshComments_Niche()

        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let sv_niche = self?._scrollView_niche else { return }
            let bottom_niche = CGPoint(x: 0, y: max(0, sv_niche.contentSize.height - sv_niche.bounds.height))
            sv_niche.setContentOffset(bottom_niche, animated: true)
        }
    }
}
