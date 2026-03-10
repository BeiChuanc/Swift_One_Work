import Foundation
import UIKit
import SnapKit

// MARK: - 首页

/// 首页视图控制器
/// 功能：展示情绪便签动态流，支持按情绪类型筛选、下拉刷新、快速发布
/// 设计思路：沉浸式渐变 Header + 情绪打卡卡片 + 情绪筛选横向滚动 + 卡片流
/// 数据来源：TitleViewModel_Moode 单例管理的帖子列表
class Home_Moode: UIViewController {

    // MARK: - 常量

    private let headerHeight_Moode: CGFloat = 200

    // MARK: - UI 组件

    /// 主滚动视图
    private let scrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsVerticalScrollIndicator = false
        sv_Moode.backgroundColor = UIColor(hexstring_Moode: "#F5F6FA")
        return sv_Moode
    }()

    private let contentView_Moode = UIView()

    // MARK: Header 区域

    private let headerView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    /// Header 三色渐变（紫→浅紫→天蓝）
    private var headerGradient_Moode: CAGradientLayer?

    /// Header 底部波浪遮罩
    private let headerWaveLayer_Moode = CAShapeLayer()

    /// 大装饰圆 1（右上）
    private let bubble1_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        v_Moode.layer.cornerRadius = 70
        return v_Moode
    }()

    /// 大装饰圆 2（左下）
    private let bubble2_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v_Moode.layer.cornerRadius = 50
        return v_Moode
    }()

    /// 小装饰圆 3（右中）
    private let bubble3_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        v_Moode.layer.cornerRadius = 28
        return v_Moode
    }()

    /// 装饰圆 4（左上，点缀层次）
    private let bubble4_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_Moode.layer.cornerRadius = 38
        return v_Moode
    }()

    /// 浮动 Emoji 标签（装饰）
    private let floatEmoji1_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "✨"
        l_Moode.font = .systemFont(ofSize: 22)
        l_Moode.alpha = 0.7
        return l_Moode
    }()

    private let floatEmoji2_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🌸"
        l_Moode.font = .systemFont(ofSize: 18)
        l_Moode.alpha = 0.6
        return l_Moode
    }()

    private let floatEmoji3_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "🎵"
        l_Moode.font = .systemFont(ofSize: 16)
        l_Moode.alpha = 0.5
        return l_Moode
    }()

    /// "Today" 小标签胶囊
    private let todayPill_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_Moode.layer.cornerRadius = 10
        return v_Moode
    }()

    private let todayPillLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .semibold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    /// 问候大标题
    private let greetingLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        l_Moode.textColor = .white
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    /// 情绪状态副标题
    private let moodSubtitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 13, weight: .medium)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.8)
        return l_Moode
    }()

    /// 右侧用户头像（Header 内）
    private let headerAvatarView_Moode: UserAvatarView_Moode = {
        let v_Moode = UserAvatarView_Moode()
        v_Moode.layer.borderWidth = 2.5
        v_Moode.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        v_Moode.layer.cornerRadius = 24
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    /// 记录数 Badge（Header 右下角）
    private let statsBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        v_Moode.layer.cornerRadius = 16
        v_Moode.layer.borderWidth = 1
        v_Moode.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return v_Moode
    }()

    private let statsIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.image = UIImage(systemName: "sparkles")
        iv_Moode.tintColor = .white
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let statsLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 12, weight: .semibold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    // MARK: 情绪打卡卡片

    /// 情绪打卡卡片容器（浮在 Header 底部悬停）
    private let checkInCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 24
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#B794F6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Moode.layer.shadowRadius = 20
        v_Moode.layer.shadowOpacity = 0.18
        return v_Moode
    }()

    private let checkInTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "How are you feeling?"
        l_Moode.font = .systemFont(ofSize: 16, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return l_Moode
    }()

    private let checkInSubLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Tap a mood to filter your feed"
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()

    /// 快速记录按钮（点击以 pageSheet 弹起发布页）
    private let quickNoteBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        // 图标 + 文字组合
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "pencil.and.sparkles", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.setTitle("  Note", for: .normal)
        btn_Moode.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn_Moode.setTitleColor(.white, for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.layer.cornerRadius = 14
        btn_Moode.clipsToBounds = true
        return btn_Moode
    }()

    private var quickNoteBtnGradient_Moode: CAGradientLayer?

    /// 情绪选择横向滚动
    private let moodScrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsHorizontalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        return sv_Moode
    }()

    private let moodStackView_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .horizontal
        sv_Moode.spacing = 8
        sv_Moode.alignment = .center
        return sv_Moode
    }()

    // MARK: 周情绪追踪卡片

    /// 周情绪追踪卡片容器（位于打卡卡片与帖子列表之间）
    private let weeklyCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#B794F6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 12
        v_Moode.layer.shadowOpacity = 0.10
        return v_Moode
    }()

    /// 周卡标题
    private let weeklyCardTitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Mood This Week"
        l_Moode.font = .systemFont(ofSize: 13, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return l_Moode
    }()

    /// 周卡副标题（情绪统计）
    private let weeklyCardSubtitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = ColorConfig_Moode.textPlaceholder_Moode
        return l_Moode
    }()

    /// 7 个情绪圆点容器
    private let weekDotStack_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .horizontal
        sv_Moode.spacing = 8
        sv_Moode.alignment = .center
        sv_Moode.distribution = .fill
        return sv_Moode
    }()

    // MARK: 帖子列表区域

    /// Section 标题容器（带左侧渐变色条 + 右侧 Badge）
    private let sectionHeaderView_Moode = UIView()

    private let sectionAccentBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.layer.cornerRadius = 2
        v_Moode.clipsToBounds = true
        return v_Moode
    }()

    private var sectionAccentGradient_Moode: CAGradientLayer?

    private let listTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Recent Moods"
        l_Moode.font = .systemFont(ofSize: 19, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.textPrimary_Moode
        return l_Moode
    }()

    private let listCountBadge_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#EEE9FF")
        v_Moode.layer.cornerRadius = 11
        return v_Moode
    }()

    private let listCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.font = .systemFont(ofSize: 11, weight: .bold)
        l_Moode.textColor = ColorConfig_Moode.primaryGradientStart_Moode
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    /// 帖子卡片集合视图
    private lazy var collectionView_Moode: UICollectionView = {
        let layout_Moode = UICollectionViewFlowLayout()
        layout_Moode.minimumLineSpacing = 0
        layout_Moode.minimumInteritemSpacing = 0
        let cv_Moode = UICollectionView(frame: .zero, collectionViewLayout: layout_Moode)
        cv_Moode.backgroundColor = .clear
        cv_Moode.showsVerticalScrollIndicator = false
        cv_Moode.isScrollEnabled = false
        cv_Moode.register(MoodNoteCard_Moode.self, forCellWithReuseIdentifier: MoodNoteCard_Moode.reuseIdentifier_Moode)
        return cv_Moode
    }()

    // MARK: 下拉刷新

    private let refreshControl_Moode = UIRefreshControl()

    // MARK: - 数据

    private var displayPosts_Moode: [TitleModel_Moode] = []
    private var selectedMood_Moode: MoodType_Moode? = nil
    private var moodTagButtons_Moode: [UIView] = []

    // MARK: - 约束引用

    private var collectionHeightConstraint_Moode: Constraint?
    private var headerHeightConstraint_Moode: Constraint?
    private var greetingTopConstraint_Moode: Constraint?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadData_Moode()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F5F6FA")
        setupScrollView_Moode()
        setupHeader_Moode()
        setupCheckInCard_Moode()
        setupWeeklyCard_Moode()
        setupPostList_Moode()
        setupRefresh_Moode()
        observeNotifications_Moode()
        reloadData_Moode()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset_Moode = view.safeAreaInsets.top
        if topInset_Moode > 0 {
            headerHeightConstraint_Moode?.update(offset: headerHeight_Moode + topInset_Moode)
            greetingTopConstraint_Moode?.update(offset: topInset_Moode + 14)
        }
        updateGradients_Moode()
        updateHeaderWave_Moode()
    }

    // MARK: - 布局搭建

    private func setupScrollView_Moode() {
        view.addSubview(scrollView_Moode)
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 禁止系统自动添加安全区偏移，防止 Header 顶部出现白色留白
        scrollView_Moode.contentInsetAdjustmentBehavior = .never
        scrollView_Moode.addSubview(contentView_Moode)
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }
        scrollView_Moode.refreshControl = refreshControl_Moode
    }

    /// 构建沉浸式 Header
    private func setupHeader_Moode() {
        contentView_Moode.addSubview(headerView_Moode)
        headerView_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            headerHeightConstraint_Moode = make.height.equalTo(headerHeight_Moode).constraint
        }

        // 装饰气泡
        headerView_Moode.addSubview(bubble1_Moode)
        bubble1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(35)
            make.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(140)
        }

        headerView_Moode.addSubview(bubble2_Moode)
        bubble2_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(10)
            make.width.height.equalTo(100)
        }

        headerView_Moode.addSubview(bubble3_Moode)
        bubble3_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.width.height.equalTo(56)
        }

        headerView_Moode.addSubview(bubble4_Moode)
        bubble4_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(80)
            make.top.equalToSuperview().offset(-14)
            make.width.height.equalTo(76)
        }

        // 浮动装饰 Emoji
        headerView_Moode.addSubview(floatEmoji1_Moode)
        floatEmoji1_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-60)
            make.top.equalToSuperview().offset(70)
        }

        headerView_Moode.addSubview(floatEmoji2_Moode)
        floatEmoji2_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-70)
        }

        headerView_Moode.addSubview(floatEmoji3_Moode)
        floatEmoji3_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(110)
            make.top.equalToSuperview().offset(30)
        }

        // "Today" 胶囊小标签
        headerView_Moode.addSubview(todayPill_Moode)
        todayPill_Moode.addSubview(todayPillLabel_Moode)
        todayPill_Moode.snp.makeConstraints { make in
            greetingTopConstraint_Moode = make.top.equalToSuperview().offset(54).constraint
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(20)
        }
        todayPillLabel_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }

        // 用户头像（右上角）
        headerView_Moode.addSubview(headerAvatarView_Moode)
        headerAvatarView_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(todayPill_Moode)
            make.width.height.equalTo(48)
        }

        // 问候语
        headerView_Moode.addSubview(greetingLabel_Moode)
        greetingLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(headerAvatarView_Moode.snp.left).offset(-12)
            make.top.equalTo(todayPill_Moode.snp.bottom).offset(10)
        }

        // 情绪副标题
        headerView_Moode.addSubview(moodSubtitleLabel_Moode)
        moodSubtitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(greetingLabel_Moode.snp.bottom).offset(6)
        }

        // Stats Badge（左下角）
        headerView_Moode.addSubview(statsBadge_Moode)
        statsBadge_Moode.addSubview(statsIconView_Moode)
        statsBadge_Moode.addSubview(statsLabel_Moode)
        statsBadge_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }
        statsIconView_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        statsLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(statsIconView_Moode.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        // 头像点击 → 个人主页
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped_Moode))
        headerAvatarView_Moode.addGestureRecognizer(tap_Moode)
        headerAvatarView_Moode.isUserInteractionEnabled = true

        // 启动浮动 Emoji 动画
        startFloatAnimation_Moode()
    }

    /// 构建情绪打卡卡片（Header 下方悬停卡片）
    private func setupCheckInCard_Moode() {
        contentView_Moode.addSubview(checkInCard_Moode)
        checkInCard_Moode.snp.makeConstraints { make in
            // 紧贴 Header 下方，留 12pt 间距，不与渐变区域重叠
            make.top.equalTo(headerView_Moode.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // 卡片标题行
        checkInCard_Moode.addSubview(checkInTitleLabel_Moode)
        checkInTitleLabel_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
        }

        checkInCard_Moode.addSubview(quickNoteBtn_Moode)
        quickNoteBtn_Moode.snp.makeConstraints { make in
            make.centerY.equalTo(checkInTitleLabel_Moode)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(28)
            make.width.equalTo(70)
        }
        quickNoteBtn_Moode.addTarget(self, action: #selector(handleQuickNote_Moode), for: .touchUpInside)

        checkInCard_Moode.addSubview(checkInSubLabel_Moode)
        checkInSubLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(checkInTitleLabel_Moode.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(18)
        }

        // 情绪筛选横向滚动
        checkInCard_Moode.addSubview(moodScrollView_Moode)
        moodScrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(checkInSubLabel_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-16)
        }

        moodScrollView_Moode.addSubview(moodStackView_Moode)
        moodStackView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18))
            make.height.equalToSuperview()
        }

        buildMoodTagButtons_Moode()
    }

    /// 构建周情绪追踪卡片
    private func setupWeeklyCard_Moode() {
        contentView_Moode.addSubview(weeklyCard_Moode)
        weeklyCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(checkInCard_Moode.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(70)
        }

        weeklyCard_Moode.addSubview(weeklyCardTitle_Moode)
        weeklyCardTitle_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }

        weeklyCard_Moode.addSubview(weeklyCardSubtitle_Moode)
        weeklyCardSubtitle_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(weeklyCardTitle_Moode.snp.bottom).offset(2)
        }

        weeklyCard_Moode.addSubview(weekDotStack_Moode)
        weekDotStack_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    /// 构建帖子列表区域
    private func setupPostList_Moode() {
        contentView_Moode.addSubview(sectionHeaderView_Moode)
        sectionHeaderView_Moode.snp.makeConstraints { make in
            make.top.equalTo(weeklyCard_Moode.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(32)
        }

        // 左侧渐变色条
        sectionHeaderView_Moode.addSubview(sectionAccentBar_Moode)
        sectionAccentBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(22)
        }

        // Section 标题
        sectionHeaderView_Moode.addSubview(listTitleLabel_Moode)
        listTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalTo(sectionAccentBar_Moode.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        // 右侧 Count Badge
        sectionHeaderView_Moode.addSubview(listCountBadge_Moode)
        listCountBadge_Moode.addSubview(listCountLabel_Moode)
        listCountBadge_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(32)
        }
        listCountLabel_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8))
        }

        contentView_Moode.addSubview(collectionView_Moode)
        collectionView_Moode.snp.makeConstraints { make in
            make.top.equalTo(sectionHeaderView_Moode.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-130)
            collectionHeightConstraint_Moode = make.height.equalTo(600).constraint
        }

        collectionView_Moode.delegate = self
        collectionView_Moode.dataSource = self
    }

    private func setupRefresh_Moode() {
        refreshControl_Moode.tintColor = ColorConfig_Moode.primaryGradientStart_Moode
        refreshControl_Moode.addTarget(self, action: #selector(handleRefresh_Moode), for: .valueChanged)
    }

    // MARK: - 渐变与波浪更新

    /// 在 layoutSubviews 后创建/更新所有渐变图层
    private func updateGradients_Moode() {
        // Header 三色渐变
        if headerGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#B794F6").cgColor,
                UIColor(hexstring_Moode: "#9BB5F0").cgColor,
                UIColor(hexstring_Moode: "#87CEF5").cgColor
            ]
            grad_Moode.locations = [0.0, 0.6, 1.0]
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 1, y: 1)
            headerView_Moode.layer.insertSublayer(grad_Moode, at: 0)
            headerGradient_Moode = grad_Moode
        }
        headerGradient_Moode?.frame = headerView_Moode.bounds

        // + Note 按钮渐变
        if quickNoteBtnGradient_Moode == nil {
            let grad_Moode = UIColor.createSecondaryGradientLayer_Moode(frame_Moode: quickNoteBtn_Moode.bounds)
            quickNoteBtn_Moode.layer.insertSublayer(grad_Moode, at: 0)
            quickNoteBtnGradient_Moode = grad_Moode
        }
        quickNoteBtnGradient_Moode?.frame = quickNoteBtn_Moode.bounds

        // Section 色条渐变
        if sectionAccentGradient_Moode == nil {
            let grad_Moode = UIColor.createPrimaryGradientLayer_Moode(frame_Moode: sectionAccentBar_Moode.bounds)
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 0, y: 1)
            sectionAccentBar_Moode.layer.insertSublayer(grad_Moode, at: 0)
            sectionAccentGradient_Moode = grad_Moode
        }
        sectionAccentGradient_Moode?.frame = sectionAccentBar_Moode.bounds

    }

    /// 在 Header 底部绘制波浪形遮罩，增加层次感
    private func updateHeaderWave_Moode() {
        let w_Moode = headerView_Moode.bounds.width
        let h_Moode = headerView_Moode.bounds.height
        guard w_Moode > 0, h_Moode > 0 else { return }

        let path_Moode = UIBezierPath()
        path_Moode.move(to: CGPoint(x: 0, y: 0))
        path_Moode.addLine(to: CGPoint(x: 0, y: h_Moode - 24))
        // 波浪曲线
        path_Moode.addCurve(
            to: CGPoint(x: w_Moode, y: h_Moode - 10),
            controlPoint1: CGPoint(x: w_Moode * 0.3, y: h_Moode + 16),
            controlPoint2: CGPoint(x: w_Moode * 0.7, y: h_Moode - 36)
        )
        path_Moode.addLine(to: CGPoint(x: w_Moode, y: 0))
        path_Moode.close()

        headerWaveLayer_Moode.path = path_Moode.cgPath
        headerWaveLayer_Moode.fillColor = UIColor.clear.cgColor
        if headerWaveLayer_Moode.superlayer == nil {
            headerView_Moode.layer.addSublayer(headerWaveLayer_Moode)
        }
    }

    // MARK: - 动态创建情绪标签

    private func buildMoodTagButtons_Moode() {
        moodStackView_Moode.arrangedSubviews.forEach { $0.removeFromSuperview() }
        moodTagButtons_Moode.removeAll()

        let allBtn_Moode = makeMoodChip_Moode(emoji_Moode: "✨", name_Moode: "All", index_Moode: 0)
        moodStackView_Moode.addArrangedSubview(allBtn_Moode)
        moodTagButtons_Moode.append(allBtn_Moode)

        for mood_Moode in MoodType_Moode.allCases {
            let chip_Moode = makeMoodChip_Moode(
                emoji_Moode: mood_Moode.emoji_Moode,
                name_Moode: mood_Moode.displayName_Moode,
                index_Moode: (MoodType_Moode.allCases.firstIndex(of: mood_Moode) ?? 0) + 1
            )
            moodStackView_Moode.addArrangedSubview(chip_Moode)
            moodTagButtons_Moode.append(chip_Moode)
        }

        updateMoodTagSelection_Moode(selectedIndex_Moode: 0)
    }

    /// 创建单个情绪芯片（Emoji 上方 + 名称下方的竖排布局）
    private func makeMoodChip_Moode(emoji_Moode: String, name_Moode: String, index_Moode: Int) -> UIView {
        let container_Moode = UIView()
        container_Moode.backgroundColor = UIColor(hexstring_Moode: "#F0EEFF")
        container_Moode.layer.cornerRadius = 14
        container_Moode.clipsToBounds = true
        container_Moode.tag = index_Moode

        let emojiLabel_Moode = UILabel()
        emojiLabel_Moode.text = emoji_Moode
        emojiLabel_Moode.font = .systemFont(ofSize: 20)
        emojiLabel_Moode.textAlignment = .center

        let nameLabel_Moode = UILabel()
        nameLabel_Moode.text = name_Moode
        nameLabel_Moode.font = .systemFont(ofSize: 10, weight: .semibold)
        nameLabel_Moode.textColor = ColorConfig_Moode.textSecondary_Moode
        nameLabel_Moode.textAlignment = .center
        nameLabel_Moode.tag = 999
        // 防止长文本截断：允许字号自动缩小至最小 8pt
        nameLabel_Moode.adjustsFontSizeToFitWidth = true
        nameLabel_Moode.minimumScaleFactor = 0.8
        nameLabel_Moode.numberOfLines = 1

        let stack_Moode = UIStackView(arrangedSubviews: [emojiLabel_Moode, nameLabel_Moode])
        stack_Moode.axis = .vertical
        stack_Moode.spacing = 2
        stack_Moode.alignment = .center

        container_Moode.addSubview(stack_Moode)
        stack_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(6)
        }
        container_Moode.snp.makeConstraints { make in
            // 宽度增大至 68pt，确保 "Anxious"/"Grateful"/"Surprised" 等长名称完整显示
            make.width.equalTo(68)
            make.height.equalTo(52)
        }

        if index_Moode == 0 {
            let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleAllTagTapped_Moode))
            container_Moode.addGestureRecognizer(tap_Moode)
        } else {
            let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleMoodTagTapped_Moode(_:)))
            container_Moode.addGestureRecognizer(tap_Moode)
        }
        container_Moode.isUserInteractionEnabled = true
        return container_Moode
    }

    // MARK: - 情绪标签选中状态

    private func updateMoodTagSelection_Moode(selectedIndex_Moode: Int) {
        for (i_Moode, tagView_Moode) in moodTagButtons_Moode.enumerated() {
            let isSelected_Moode = (i_Moode == selectedIndex_Moode)
            let nameLabel_Moode = tagView_Moode.viewWithTag(999) as? UILabel

            if i_Moode == 0 {
                UIView.animate(
                    withDuration: AnimationConfig_Moode.durationSpring_Moode,
                    delay: 0,
                    usingSpringWithDamping: AnimationConfig_Moode.springDampingLight_Moode,
                    initialSpringVelocity: AnimationConfig_Moode.springVelocity_Moode,
                    options: .curveEaseOut,
                    animations: {
                        tagView_Moode.backgroundColor = isSelected_Moode
                            ? ColorConfig_Moode.primaryGradientStart_Moode
                            : UIColor(hexstring_Moode: "#F0EEFF")
                        tagView_Moode.transform = isSelected_Moode
                            ? CGAffineTransform(scaleX: 1.08, y: 1.08)
                            : .identity
                    }
                )
                nameLabel_Moode?.textColor = isSelected_Moode ? .white : ColorConfig_Moode.textSecondary_Moode
            } else {
                let moodIdx_Moode = i_Moode - 1
                guard moodIdx_Moode < MoodType_Moode.allCases.count else { continue }
                let mood_Moode = MoodType_Moode.allCases[moodIdx_Moode]

                UIView.animate(
                    withDuration: AnimationConfig_Moode.durationSpring_Moode,
                    delay: 0,
                    usingSpringWithDamping: AnimationConfig_Moode.springDampingLight_Moode,
                    initialSpringVelocity: AnimationConfig_Moode.springVelocity_Moode,
                    options: .curveEaseOut,
                    animations: {
                        tagView_Moode.backgroundColor = isSelected_Moode
                            ? mood_Moode.gradientStart_Moode
                            : UIColor(hexstring_Moode: "#F0EEFF")
                        tagView_Moode.transform = isSelected_Moode
                            ? CGAffineTransform(scaleX: 1.08, y: 1.08)
                            : .identity
                    }
                )
                nameLabel_Moode?.textColor = isSelected_Moode ? .white : ColorConfig_Moode.textSecondary_Moode
            }

            // 选中时添加阴影光晕
            if isSelected_Moode {
                tagView_Moode.layer.shadowColor = (i_Moode == 0
                    ? ColorConfig_Moode.primaryGradientStart_Moode
                    : MoodType_Moode.allCases[safe: i_Moode - 1]?.gradientStart_Moode ?? .clear
                ).cgColor
                tagView_Moode.layer.shadowOffset = CGSize(width: 0, height: 3)
                tagView_Moode.layer.shadowRadius = 6
                tagView_Moode.layer.shadowOpacity = 0.3
                tagView_Moode.layer.masksToBounds = false
            } else {
                tagView_Moode.layer.shadowOpacity = 0
            }
        }
    }

    // MARK: - 浮动 Emoji 动画

    /// 让三个装饰 Emoji 做呼吸式上下浮动（各自错开延迟）
    private func startFloatAnimation_Moode() {
        animateFloat_Moode(view_moode: floatEmoji1_Moode, delay_moode: 0,   offset_moode: -8)
        animateFloat_Moode(view_moode: floatEmoji2_Moode, delay_moode: 0.5, offset_moode: -6)
        animateFloat_Moode(view_moode: floatEmoji3_Moode, delay_moode: 1.0, offset_moode: -5)
    }

    private func animateFloat_Moode(view_moode: UIView, delay_moode: TimeInterval, offset_moode: CGFloat) {
        UIView.animate(
            withDuration: 2.2,
            delay: delay_moode,
            options: [.autoreverse, .repeat, .curveEaseInOut],
            animations: {
                view_moode.transform = CGAffineTransform(translationX: 0, y: offset_moode)
            }
        )
    }

    // MARK: - 数据刷新

    private func reloadData_Moode() {
        Task { @MainActor in
            displayPosts_Moode = TitleViewModel_Moode.shared_Moode.getFilteredPosts_Moode(moodType_moode: selectedMood_Moode)

            updateHeaderContent_Moode()
            updateWeeklyCard_Moode()

            // 更新 Section count badge
            listCountLabel_Moode.text = "\(displayPosts_Moode.count)"

            // 卡片增加媒体图后高度调整为 168
            let cardHeight_Moode: CGFloat = 168
            let totalHeight_Moode = CGFloat(max(displayPosts_Moode.count, 1)) * cardHeight_Moode
            collectionHeightConstraint_Moode?.update(offset: totalHeight_Moode)

            collectionView_Moode.reloadData()
            animateCardsIn_Moode()
            contentView_Moode.layoutIfNeeded()
        }
    }

    /// 更新周情绪追踪卡片（取最近7条情绪帖子的情绪颜色点）
    private func updateWeeklyCard_Moode() {
        // 仅使用情绪帖子，确保圆点颜色与情绪类型对应
        let allPosts_moode = TitleViewModel_Moode.shared_Moode.getMoodPosts_Moode()
        // 取最近7条（或不足7条时全取）
        let recent7_moode = Array(allPosts_moode.prefix(7))

        // 更新副标题
        let moodCount_moode = Set(recent7_moode.map { $0.moodType_Moode }).count
        weeklyCardSubtitle_Moode.text = "\(recent7_moode.count) entries · \(moodCount_moode) emotions"

        // 清除旧圆点
        weekDotStack_Moode.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 如果不足7条，用灰色圆点补足
        let targetCount_moode = 7
        for idx_moode in 0..<targetCount_moode {
            let dot_moode = UIView()
            dot_moode.layer.cornerRadius = 9
            dot_moode.snp.makeConstraints { make in
                make.width.height.equalTo(18)
            }
            if idx_moode < recent7_moode.count {
                let mood_moode = recent7_moode[idx_moode].moodType_Moode
                dot_moode.backgroundColor = mood_moode.gradientStart_Moode
                // 加文字 emoji 提示
                let emoji_moode = UILabel()
                emoji_moode.text = mood_moode.emoji_Moode
                emoji_moode.font = .systemFont(ofSize: 10)
                emoji_moode.textAlignment = .center
                dot_moode.addSubview(emoji_moode)
                emoji_moode.snp.makeConstraints { make in make.edges.equalToSuperview() }
            } else {
                dot_moode.backgroundColor = UIColor(hexstring_Moode: "#E8E8F0")
            }
            weekDotStack_Moode.addArrangedSubview(dot_moode)
        }
    }

    /// 更新 Header 文案内容
    private func updateHeaderContent_Moode() {
        let hour_Moode = Calendar.current.component(.hour, from: Date())
        let greeting_Moode: String
        let subtitle_Moode: String
        switch hour_Moode {
        case 5..<12:
            greeting_Moode = "Good Morning ☀️\nCapture your mood"
            subtitle_Moode = "Start your day with intention"
        case 12..<18:
            greeting_Moode = "Good Afternoon 🌤\nHow's your mood?"
            subtitle_Moode = "Midday check-in awaits you"
        case 18..<22:
            greeting_Moode = "Good Evening 🌙\nReflect on today"
            subtitle_Moode = "Wind down and journal"
        default:
            greeting_Moode = "Still Awake? 🌟\nShare your thoughts"
            subtitle_Moode = "Night owls have feelings too"
        }
        greetingLabel_Moode.text = greeting_Moode
        moodSubtitleLabel_Moode.text = subtitle_Moode

        let formatter_Moode = DateFormatter()
        formatter_Moode.dateFormat = "EEE, MMM d"
        todayPillLabel_Moode.text = "📅  \(formatter_Moode.string(from: Date()))"

        // 只统计情绪帖子数量
        let count_Moode = TitleViewModel_Moode.shared_Moode.getMoodPosts_Moode().count
        statsLabel_Moode.text = "\(count_Moode) moods recorded"

        // 配置当前用户头像
        let currentUser_Moode = UserViewModel_Moode.shared_Moode.getCurrentUser_Moode()
        if let userId_Moode = currentUser_Moode.userId_Moode {
            headerAvatarView_Moode.configure_Moode(userId_Moode: userId_Moode)
        }
    }

    // MARK: - 动画

    private func animateCardsIn_Moode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            for (i_Moode, cell_Moode) in self.collectionView_Moode.visibleCells.enumerated() {
                let delay_Moode = TimeInterval(i_Moode) * AnimationConfig_Moode.delayShort_Moode
                cell_Moode.animateSlideInFromBottom_Moode(offset_Moode: 40, delay_Moode: delay_Moode)
            }
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsChanged_Moode),
            name: TitleViewModel_Moode.titleStateDidChangeNotification_Moode,
            object: nil
        )
    }

    // MARK: - 事件处理

    @objc private func handleAllTagTapped_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedMood_Moode = nil
        updateMoodTagSelection_Moode(selectedIndex_Moode: 0)
        reloadData_Moode()
    }

    @objc private func handleMoodTagTapped_Moode(_ gesture_moode: UITapGestureRecognizer) {
        guard let tagView_Moode = gesture_moode.view else { return }
        let moodIndex_Moode = tagView_Moode.tag - 1
        guard moodIndex_Moode >= 0 && moodIndex_Moode < MoodType_Moode.allCases.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedMood_Moode = MoodType_Moode.allCases[moodIndex_Moode]
        updateMoodTagSelection_Moode(selectedIndex_Moode: tagView_Moode.tag)
        reloadData_Moode()
    }

    @objc private func handleQuickNote_Moode() {
        quickNoteBtn_Moode.animatePressDown_Moode { self.quickNoteBtn_Moode.animatePressUp_Moode() }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 以 pageSheet 方式从底部弹起发布页，情绪帖子模式
        let releaseVC_moode = Release_Moode()
        releaseVC_moode.isMoodPost_Moode = true
        let nav_moode = UINavigationController(rootViewController: releaseVC_moode)
        nav_moode.modalPresentationStyle = .pageSheet
        if let sheet_moode = nav_moode.sheetPresentationController {
            sheet_moode.detents = [.large()]
            sheet_moode.prefersGrabberVisible = true
            // 顶部左右圆角加大
            sheet_moode.preferredCornerRadius = 32
        }
        present(nav_moode, animated: true)
    }

    @objc private func handleRefresh_Moode() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.reloadData_Moode()
            self?.refreshControl_Moode.endRefreshing()
        }
    }

    @objc private func handlePostsChanged_Moode() {
        reloadData_Moode()
    }

    @objc private func handleAvatarTapped_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // 直接切换底部 Tabbar 到"我的"页面（索引 4），不产生导航栈跳转
        Navigation_Moode.switchToTab_Moode(index_moode: 4)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    /// 安全访问数组，越界时返回 nil
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension Home_Moode: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayPosts_Moode.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Moode = collectionView.dequeueReusableCell(
            withReuseIdentifier: MoodNoteCard_Moode.reuseIdentifier_Moode,
            for: indexPath
        ) as? MoodNoteCard_Moode else {
            return UICollectionViewCell()
        }

        let post_Moode = displayPosts_Moode[indexPath.item]
        let isLiked_Moode = TitleViewModel_Moode.shared_Moode.isLikedPost_Moode(post_moode: post_Moode)
        cell_Moode.configure_Moode(post_moode: post_Moode, isLiked_moode: isLiked_Moode)

        cell_Moode.onLikeTapped_Moode = { [weak self] post_moode in
            Task { @MainActor in
                TitleViewModel_Moode.shared_Moode.likePost_Moode(post_moode: post_moode)
                self?.reloadData_Moode()
            }
        }

        cell_Moode.onCardTapped_Moode = { post_moode in
            Navigation_Moode.toTitleDetail_Moode(titleModel_moode: post_moode)
        }

        // 头像点击：非登录用户才跳转用户中心
        cell_Moode.onAvatarTapped_Moode = { userId_moode in
            guard !UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(userId_moode: userId_moode) else { return }
            let userModel_moode = UserViewModel_Moode.shared_Moode.getUserById_Moode(userId_moode: userId_moode)
            Navigation_Moode.toUserInfo_Moode(with: userModel_moode)
        }

        // 举报/删除回调：自己的帖子走删除，他人帖子走举报
        cell_Moode.onReportTapped_Moode = { [weak self] post_moode in
            guard let self = self else { return }
            let isMyPost_moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
                userId_moode: post_moode.titleUserId_Moode
            )
            if isMyPost_moode {
                ReportDeleteHelper_Moode.delete_Moode(post_Moode: post_moode, from: self) {
                    self.reloadData_Moode()
                }
            } else {
                ReportDeleteHelper_Moode.report_Moode(post_Moode: post_moode, from: self) {
                    self.reloadData_Moode()
                }
            }
        }

        return cell_Moode
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 增加媒体缩略图后卡片高度调整为 168
        return CGSize(width: collectionView.bounds.width, height: 168)
    }
}
