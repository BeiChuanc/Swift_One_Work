import Foundation
import UIKit
import SnapKit

// MARK: 首页 - 重构版

/// 首页控制器
/// 核心作用：固定顶部栏 + 可滚动内容（横幅/日历打卡/Trending/主题打卡活动/淘机小课堂/CCD技巧库）
/// 设计思路：顶部栏固定在安全区，内容区全面滚动，modular section 化布局便于维护
class Home_Retrs: UIViewController {

    // MARK: - 属性

    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs
    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs

    /// 固定顶部栏
    private let topBarView_Retrs      = UIView()
    private let appTitleLabel_Retrs   = UILabel()
    private let topSubLabel_Retrs     = UILabel()   // 顶部滚动描述（在 contentView 内）
    private let avatarView_Retrs      = CurrentUserAvatarView_Retrs()

    /// 主滚动视图
    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 横幅
    private let bannerCard_Retrs         = UIView()
    private let bannerGradLayer_Retrs    = CAGradientLayer()
    private let bannerTitleLabel_Retrs   = UILabel()
    private let bannerSubLabel_Retrs     = UILabel()
    private let bannerIconView_Retrs     = UIImageView()

    /// 日历打卡区
    private let checkinCard_Retrs        = UIView()
    private let checkinIconView_Retrs    = UIImageView()
    private let checkinTitleLabel_Retrs  = UILabel()
    private let checkinSubLabel_Retrs    = UILabel()
    private let checkinBtn_Retrs         = UIButton(type: .system)
    private let calendarWrap_Retrs       = UIView()
    private var calendarCollectionView_Retrs: UICollectionView!
    private var isCalendarExpanded_Retrs = false
    private var hasCheckedIn_Retrs       = false
    private var checkedInDays_Retrs: Set<Int> = []

    /// 热门帖子（Trending）
    private let hotTitleLabel_Retrs = UILabel()
    private let hotCollectionView_Retrs: UICollectionView = {
        let layout_Retrs = UICollectionViewFlowLayout()
        layout_Retrs.scrollDirection = .horizontal
        layout_Retrs.minimumLineSpacing = 14
        layout_Retrs.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Retrs)
    }()
    private var hotPosts_Retrs: [TitleModel_Retrs] = []

    /// 主题打卡活动
    private let themeTitleLabel_Retrs = UILabel()
    private let themeCollectionView_Retrs: UICollectionView = {
        let layout_Retrs = UICollectionViewFlowLayout()
        layout_Retrs.scrollDirection = .horizontal
        layout_Retrs.minimumLineSpacing = 14
        layout_Retrs.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Retrs)
    }()

    /// 淘机小课堂
    private let tipsTitleLabel_Retrs = UILabel()
    private let tipsCollectionView_Retrs: UICollectionView = {
        let layout_Retrs = UICollectionViewFlowLayout()
        layout_Retrs.scrollDirection = .horizontal
        layout_Retrs.minimumLineSpacing = 12
        layout_Retrs.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Retrs)
    }()

    /// 我的CCD技巧库
    private let diaryTitleLabel_Retrs = UILabel()
    private let diaryAddBtn_Retrs     = UIButton(type: .system)
    private let diaryCollectionView_Retrs: UICollectionView = {
        let layout_Retrs = UICollectionViewFlowLayout()
        layout_Retrs.scrollDirection = .horizontal
        layout_Retrs.minimumLineSpacing = 12
        layout_Retrs.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return UICollectionView(frame: .zero, collectionViewLayout: layout_Retrs)
    }()
    private var diaryPosts_Retrs: [TitleModel_Retrs] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData_Retrs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupTopBar_Retrs()
        setupScrollView_Retrs()
        setupBannerCard_Retrs()
        setupCheckinSection_Retrs()
        setupCalendarView_Retrs()
        setupHotSection_Retrs()
        setupThemeSection_Retrs()
        setupTipsSection_Retrs()
        setupDiarySection_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        reloadData_Retrs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bannerGradLayer_Retrs.frame = bannerCard_Retrs.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 固定顶部栏

    private func setupTopBar_Retrs() {
        view.addSubview(topBarView_Retrs)
        topBarView_Retrs.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs

        appTitleLabel_Retrs.text = "Moche"
        appTitleLabel_Retrs.font = UIFont(name: "Georgia-BoldItalic", size: 26)
            ?? UIFont.systemFont(ofSize: 26, weight: .black)
        appTitleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        topBarView_Retrs.addSubview(appTitleLabel_Retrs)

        avatarView_Retrs.onTapped_Retrs = { [weak self] in
            guard let self else { return }
            if userVM_Retrs.isLoggedIn_Retrs {
                // 切换到我的 Tab（index=4），不 push 新页面
                if let tabbar_Retrs = tabBarController as? TabBar_Retrs {
                    tabbar_Retrs.switchToIndex_Retrs(4)
                }
            } else {
                Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs)
            }
        }
        topBarView_Retrs.addSubview(avatarView_Retrs)
    }

    // MARK: - 主滚动视图

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        // 禁止自动添加 SafeArea 偏移，让内容紧贴 topBar 下方
        scrollView_Retrs.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    // MARK: - 横幅

    private func setupBannerCard_Retrs() {
        // 描述副标题（在滚动区域内，Banner 上方）
        topSubLabel_Retrs.text = "Capture & share your CCD moments"
        topSubLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        topSubLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentView_Retrs.addSubview(topSubLabel_Retrs)

        contentView_Retrs.addSubview(bannerCard_Retrs)
        bannerCard_Retrs.layer.cornerRadius = 20
        bannerCard_Retrs.clipsToBounds = true

        bannerGradLayer_Retrs.colors = [
            UIColor(hexstring_Retrs: "#B794F6").cgColor,
            UIColor(hexstring_Retrs: "#667EEA").cgColor,
            UIColor(hexstring_Retrs: "#764BA2").cgColor
        ]
        bannerGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        bannerGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        bannerCard_Retrs.layer.insertSublayer(bannerGradLayer_Retrs, at: 0)

        bannerTitleLabel_Retrs.text = "CCD Moments"
        bannerTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 22, weight: .black)
        bannerTitleLabel_Retrs.textColor = .white
        bannerCard_Retrs.addSubview(bannerTitleLabel_Retrs)

        bannerSubLabel_Retrs.text = "Capture every retro grain of light"
        bannerSubLabel_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        bannerSubLabel_Retrs.textColor = UIColor.white.withAlphaComponent(0.85)
        bannerSubLabel_Retrs.numberOfLines = 2
        bannerCard_Retrs.addSubview(bannerSubLabel_Retrs)

        let cfg_Retrs = UIImage.SymbolConfiguration(pointSize: 60, weight: .light)
        bannerIconView_Retrs.image = UIImage(systemName: "camera.fill", withConfiguration: cfg_Retrs)
        bannerIconView_Retrs.tintColor = UIColor.white.withAlphaComponent(0.25)
        bannerCard_Retrs.addSubview(bannerIconView_Retrs)

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(bannerTapped_Retrs))
        bannerCard_Retrs.addGestureRecognizer(tap_Retrs)
    }

    // MARK: - 日历打卡区（紧凑 + 可展开）

    private func setupCheckinSection_Retrs() {
        contentView_Retrs.addSubview(checkinCard_Retrs)
        checkinCard_Retrs.backgroundColor = .white
        checkinCard_Retrs.layer.cornerRadius = 16
        checkinCard_Retrs.clipsToBounds = false
        checkinCard_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        checkinCard_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        checkinCard_Retrs.layer.shadowOpacity = 1
        checkinCard_Retrs.layer.shadowRadius  = 10

        // 日历图标
        let iconCfg_Retrs = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        checkinIconView_Retrs.image = UIImage(systemName: "calendar.badge.clock", withConfiguration: iconCfg_Retrs)
        checkinIconView_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        checkinCard_Retrs.addSubview(checkinIconView_Retrs)

        checkinTitleLabel_Retrs.text = "Daily Check-In"
        checkinTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        checkinTitleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        checkinCard_Retrs.addSubview(checkinTitleLabel_Retrs)

        checkinSubLabel_Retrs.text = "Tap calendar to view your streak →"
        checkinSubLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        checkinSubLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        checkinCard_Retrs.addSubview(checkinSubLabel_Retrs)

        checkinBtn_Retrs.layer.cornerRadius = 14
        checkinBtn_Retrs.addTarget(self, action: #selector(checkinTapped_Retrs), for: .touchUpInside)
        checkinCard_Retrs.addSubview(checkinBtn_Retrs)

        // 展开/收起日历按钮（右侧箭头）
        let calendarToggleBtn_Retrs = UIButton(type: .system)
        calendarToggleBtn_Retrs.setImage(
            UIImage(systemName: "chevron.down",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)),
            for: .normal)
        calendarToggleBtn_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        calendarToggleBtn_Retrs.tag = 7701
        calendarToggleBtn_Retrs.addTarget(self, action: #selector(toggleCalendar_Retrs), for: .touchUpInside)
        checkinCard_Retrs.addSubview(calendarToggleBtn_Retrs)
        calendarToggleBtn_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(checkinTitleLabel_Retrs)
            make.trailing.equalToSuperview().offset(-14)
            make.width.height.equalTo(28)
        }
    }

    /// 日历折叠视图（CollectionView 7列×6行）
    private func setupCalendarView_Retrs() {
        let calLayout_Retrs = UICollectionViewFlowLayout()
        calLayout_Retrs.minimumLineSpacing = 4
        calLayout_Retrs.minimumInteritemSpacing = 4
        calendarCollectionView_Retrs = UICollectionView(frame: .zero, collectionViewLayout: calLayout_Retrs)
        calendarCollectionView_Retrs.register(CalendarDayCell_Retrs.self,
                                               forCellWithReuseIdentifier: "CalendarDayCell_Retrs")
        calendarCollectionView_Retrs.backgroundColor = .clear
        calendarCollectionView_Retrs.isScrollEnabled = false
        calendarCollectionView_Retrs.dataSource = self
        calendarCollectionView_Retrs.delegate   = self

        calendarWrap_Retrs.backgroundColor = .clear
        calendarWrap_Retrs.isHidden = true
        calendarWrap_Retrs.clipsToBounds = true
        calendarWrap_Retrs.addSubview(calendarCollectionView_Retrs)
        contentView_Retrs.addSubview(calendarWrap_Retrs)
        calendarCollectionView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 热门帖子

    private func setupHotSection_Retrs() {
        contentView_Retrs.addSubview(hotTitleLabel_Retrs)
        hotTitleLabel_Retrs.text = "🔥  Trending"
        hotTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        hotTitleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs

        hotCollectionView_Retrs.backgroundColor = .clear
        hotCollectionView_Retrs.showsHorizontalScrollIndicator = false
        hotCollectionView_Retrs.register(HotPostCell_Retrs.self, forCellWithReuseIdentifier: "HotPostCell_Retrs")
        hotCollectionView_Retrs.tag = 100
        hotCollectionView_Retrs.dataSource = self
        hotCollectionView_Retrs.delegate   = self
        contentView_Retrs.addSubview(hotCollectionView_Retrs)
    }

    // MARK: - 主题打卡活动

    private func setupThemeSection_Retrs() {
        contentView_Retrs.addSubview(themeTitleLabel_Retrs)
        themeTitleLabel_Retrs.attributedText = makeSectionTitle_Retrs("📸  Theme Challenges")

        themeCollectionView_Retrs.backgroundColor = .clear
        themeCollectionView_Retrs.showsHorizontalScrollIndicator = false
        themeCollectionView_Retrs.register(ThemeActivityCell_Retrs.self,
                                           forCellWithReuseIdentifier: "ThemeActivityCell_Retrs")
        themeCollectionView_Retrs.tag = 200
        themeCollectionView_Retrs.dataSource = self
        themeCollectionView_Retrs.delegate   = self
        contentView_Retrs.addSubview(themeCollectionView_Retrs)
    }

    // MARK: - 淘机小课堂

    private func setupTipsSection_Retrs() {
        contentView_Retrs.addSubview(tipsTitleLabel_Retrs)
        tipsTitleLabel_Retrs.attributedText = makeSectionTitle_Retrs("🎒  CCD Tips & Tricks")

        tipsCollectionView_Retrs.backgroundColor = .clear
        tipsCollectionView_Retrs.showsHorizontalScrollIndicator = false
        tipsCollectionView_Retrs.register(CCDTipCell_Retrs.self, forCellWithReuseIdentifier: "CCDTipCell_Retrs")
        tipsCollectionView_Retrs.tag = 300
        tipsCollectionView_Retrs.dataSource = self
        tipsCollectionView_Retrs.delegate   = self
        contentView_Retrs.addSubview(tipsCollectionView_Retrs)
    }

    // MARK: - 我的CCD技巧库

    private func setupDiarySection_Retrs() {
        // 区块标题行（标题 + 添加按钮）
        contentView_Retrs.addSubview(diaryTitleLabel_Retrs)
        diaryTitleLabel_Retrs.attributedText = makeSectionTitle_Retrs("📖  My CCD Gallery")

        diaryAddBtn_Retrs.setTitle("+ Add", for: .normal)
        diaryAddBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        diaryAddBtn_Retrs.setTitleColor(.white, for: .normal)
        diaryAddBtn_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        diaryAddBtn_Retrs.layer.cornerRadius = 12
        diaryAddBtn_Retrs.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        diaryAddBtn_Retrs.addTarget(self, action: #selector(addDiaryTapped_Retrs), for: .touchUpInside)
        contentView_Retrs.addSubview(diaryAddBtn_Retrs)

        diaryCollectionView_Retrs.backgroundColor = .clear
        diaryCollectionView_Retrs.showsHorizontalScrollIndicator = false
        diaryCollectionView_Retrs.register(DiaryEntryCell_Retrs.self, forCellWithReuseIdentifier: "DiaryEntryCell_Retrs")
        diaryCollectionView_Retrs.tag = 400
        diaryCollectionView_Retrs.dataSource = self
        diaryCollectionView_Retrs.delegate   = self
        contentView_Retrs.addSubview(diaryCollectionView_Retrs)
    }

    /// 构建标准区块标题富文本
    private func makeSectionTitle_Retrs(_ text_Retrs: String) -> NSAttributedString {
        NSAttributedString(string: text_Retrs, attributes: [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: ColorConfig_Retrs.textPrimary_Retrs
        ])
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        // 固定顶部栏
        topBarView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop_Retrs + 50)
        }
        appTitleLabel_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(20)
        }
        avatarView_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(appTitleLabel_Retrs)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(38)
        }

        // 滚动视图距 topBar 下沿 20pt
        scrollView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(topBarView_Retrs.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }

        // 描述副标题（contentView 内第一个元素）
        topSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.equalToSuperview().offset(20)
        }

        // 横幅
        bannerCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(topSubLabel_Retrs.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(120)
        }
        bannerTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalToSuperview().offset(20)
        }
        bannerSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(bannerTitleLabel_Retrs.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-80)
        }
        bannerIconView_Retrs.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-14)
            make.width.height.equalTo(70)
        }

        // 打卡卡片（紧凑高度60）
        checkinCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(bannerCard_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(60)
        }
        checkinIconView_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        checkinTitleLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(checkinIconView_Retrs.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        checkinSubLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(checkinTitleLabel_Retrs.snp.bottom).offset(3)
            make.leading.equalTo(checkinTitleLabel_Retrs)
        }
        checkinBtn_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-50)
            make.centerY.equalToSuperview()
            make.width.equalTo(70)
            make.height.equalTo(28)
        }

        // 日历折叠区
        calendarWrap_Retrs.snp.makeConstraints { make in
            make.top.equalTo(checkinCard_Retrs.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(0)
        }

        // Trending
        hotTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(calendarWrap_Retrs.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
        }
        hotCollectionView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(hotTitleLabel_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(190)
        }

        // 主题打卡活动
        themeTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(hotCollectionView_Retrs.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }
        themeCollectionView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(themeTitleLabel_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }

        // 淘机小课堂
        tipsTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(themeCollectionView_Retrs.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }
        tipsCollectionView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(tipsTitleLabel_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }

        // 我的CCD技巧库
        diaryTitleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(tipsCollectionView_Retrs.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }
        diaryAddBtn_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(diaryTitleLabel_Retrs)
            make.trailing.equalToSuperview().offset(-16)
        }
        diaryCollectionView_Retrs.snp.makeConstraints { make in
            make.top.equalTo(diaryTitleLabel_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalToSuperview().offset(-130)
        }
    }

    // MARK: - 数据加载

    private func reloadData_Retrs() {
        let allPosts_Retrs = titleVM_Retrs.getPosts_Retrs()
        hotPosts_Retrs = Array(allPosts_Retrs.sorted { $0.likes_Retrs > $1.likes_Retrs }.prefix(6))
        hotCollectionView_Retrs.reloadData()

        let currentId_Retrs = userVM_Retrs.getCurrentUser_Retrs().userId_Retrs ?? 0
        diaryPosts_Retrs = allPosts_Retrs.filter { $0.titleUserId_Retrs == currentId_Retrs }
        diaryCollectionView_Retrs.reloadData()

        updateCheckinState_Retrs()
        calendarCollectionView_Retrs?.reloadData()
    }

    private func updateCheckinState_Retrs() {
        if !userVM_Retrs.isLoggedIn_Retrs {
            checkinBtn_Retrs.setTitle("Sign In", for: .normal)
            checkinBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            checkinBtn_Retrs.setTitleColor(.white, for: .normal)
            checkinBtn_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            checkinBtn_Retrs.isEnabled = true
        } else if hasCheckedIn_Retrs {
            checkinBtn_Retrs.setTitle("✓ Done", for: .normal)
            checkinBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            checkinBtn_Retrs.setTitleColor(ColorConfig_Retrs.textSecondary_Retrs, for: .normal)
            checkinBtn_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#E2E8F0")
            checkinBtn_Retrs.isEnabled = false
        } else {
            checkinBtn_Retrs.setTitle("Check In", for: .normal)
            checkinBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            checkinBtn_Retrs.setTitleColor(.white, for: .normal)
            checkinBtn_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            checkinBtn_Retrs.isEnabled = true
        }
    }

    // MARK: - 通知

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: UserViewModel_Retrs.userStateDidChangeNotification_Retrs, object: nil)
    }

    @objc private func onStateChange_Retrs() { reloadData_Retrs() }

    // MARK: - 事件

    @objc private func bannerTapped_Retrs() {
        bannerCard_Retrs.animatePressDown_Retrs { [weak self] in self?.bannerCard_Retrs.animatePressUp_Retrs() }
        if let tabbar_Retrs = tabBarController as? TabBar_Retrs {
            tabbar_Retrs.switchToIndex_Retrs(1)
        }
    }

    @objc private func checkinTapped_Retrs() {
        checkinBtn_Retrs.animatePulse_Retrs()
        if !userVM_Retrs.isLoggedIn_Retrs {
            Navigation_Retrs.toLogin_Retrs(style_retrs: .present_retrs); return
        }
        hasCheckedIn_Retrs = true
        let day_Retrs = Calendar.current.component(.day, from: Date())
        checkedInDays_Retrs.insert(day_Retrs)
        userVM_Retrs.checkIn_Retrs()
        updateCheckinState_Retrs()
        calendarCollectionView_Retrs?.reloadData()
    }

    @objc private func toggleCalendar_Retrs() {
        isCalendarExpanded_Retrs.toggle()
        let calH_Retrs: CGFloat = isCalendarExpanded_Retrs ? 220 : 0
        let arrowBtn_Retrs = checkinCard_Retrs.viewWithTag(7701) as? UIButton
        calendarWrap_Retrs.isHidden = !isCalendarExpanded_Retrs

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5) { [weak self] in
            guard let self else { return }
            self.calendarWrap_Retrs.snp.updateConstraints { make in make.height.equalTo(calH_Retrs) }
            arrowBtn_Retrs?.transform = self.isCalendarExpanded_Retrs
                ? CGAffineTransform(rotationAngle: .pi)
                : .identity
            self.view.layoutIfNeeded()
        }
    }

    @objc private func addDiaryTapped_Retrs() {
        Navigation_Retrs.toDiaryPublish_Retrs(style_retrs: .present_retrs)
    }
}

// MARK: - CollectionView DataSource & Delegate

extension Home_Retrs: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 100: return hotPosts_Retrs.count
        case 200: return ThemeActivity_Retrs.activities_Retrs.count
        case 300: return CCDTip_Retrs.tips_Retrs.count
        case 400: return max(diaryPosts_Retrs.count, 1)
        default:  return daysInCurrentMonth_Retrs() + firstWeekdayOffset_Retrs()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 100:
            let cell_Retrs = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HotPostCell_Retrs", for: indexPath) as! HotPostCell_Retrs
            cell_Retrs.configure_Retrs(post_Retrs: hotPosts_Retrs[indexPath.item])
            return cell_Retrs

        case 200:
            let cell_Retrs = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ThemeActivityCell_Retrs", for: indexPath) as! ThemeActivityCell_Retrs
            cell_Retrs.configure_Retrs(activity_Retrs: ThemeActivity_Retrs.activities_Retrs[indexPath.item])
            return cell_Retrs

        case 300:
            let cell_Retrs = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CCDTipCell_Retrs", for: indexPath) as! CCDTipCell_Retrs
            cell_Retrs.configure_Retrs(tip_Retrs: CCDTip_Retrs.tips_Retrs[indexPath.item % CCDTip_Retrs.tips_Retrs.count])
            return cell_Retrs

        case 400:
            let cell_Retrs = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DiaryEntryCell_Retrs", for: indexPath) as! DiaryEntryCell_Retrs
            let post_Retrs = diaryPosts_Retrs.isEmpty ? nil : diaryPosts_Retrs[indexPath.item]
            cell_Retrs.configure_Retrs(post_Retrs: post_Retrs)
            return cell_Retrs

        default:
            // 日历单元格
            let cell_Retrs = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CalendarDayCell_Retrs", for: indexPath) as! CalendarDayCell_Retrs
            let offset_Retrs = firstWeekdayOffset_Retrs()
            let dayNum_Retrs = indexPath.item - offset_Retrs + 1
            let today_Retrs = Calendar.current.component(.day, from: Date())
            if dayNum_Retrs >= 1 && dayNum_Retrs <= daysInCurrentMonth_Retrs() {
                cell_Retrs.configure_Retrs(
                    day_Retrs: dayNum_Retrs,
                    isToday_Retrs: dayNum_Retrs == today_Retrs,
                    isCheckedIn_Retrs: checkedInDays_Retrs.contains(dayNum_Retrs)
                )
            } else {
                cell_Retrs.configure_Retrs(day_Retrs: 0, isToday_Retrs: false, isCheckedIn_Retrs: false)
            }
            return cell_Retrs
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 100: return CGSize(width: 150, height: 185)
        case 200: return CGSize(width: UIScreen.main.bounds.width - 60, height: 150)
        case 300: return CGSize(width: 200, height: 130)
        case 400: return CGSize(width: 140, height: 140)
        default:
            let w_Retrs = (UIScreen.main.bounds.width - 32 - 24) / 7
            return CGSize(width: w_Retrs, height: w_Retrs)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 100:
            Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: hotPosts_Retrs[indexPath.item])
        case 200:
            Navigation_Retrs.toActivityDetail_Retrs(
                activity_Retrs: ThemeActivity_Retrs.activities_Retrs[indexPath.item])
        case 400:
            guard !diaryPosts_Retrs.isEmpty else {
                Navigation_Retrs.toDiaryPublish_Retrs(style_retrs: .present_retrs); return
            }
            Navigation_Retrs.toTitleDetail_Retrs(titleModel_retrs: diaryPosts_Retrs[indexPath.item])
        default: break
        }
    }

    // MARK: - 日历工具方法

    private func daysInCurrentMonth_Retrs() -> Int {
        let cal_Retrs = Calendar.current
        let range_Retrs = cal_Retrs.range(of: .day, in: .month, for: Date())
        return range_Retrs?.count ?? 30
    }

    private func firstWeekdayOffset_Retrs() -> Int {
        let cal_Retrs = Calendar.current
        var comps_Retrs = cal_Retrs.dateComponents([.year, .month], from: Date())
        comps_Retrs.day = 1
        guard let firstDay_Retrs = cal_Retrs.date(from: comps_Retrs) else { return 0 }
        let weekday_Retrs = cal_Retrs.component(.weekday, from: firstDay_Retrs)
        return (weekday_Retrs - cal_Retrs.firstWeekday + 7) % 7
    }
}

// MARK: - 热门帖子卡片单元格

/// 热门帖子横向卡片
class HotPostCell_Retrs: UICollectionViewCell {

    private let mediaView_Retrs  = MediaDisplayView_Retrs()
    private let titleLabel_Retrs = UILabel()
    private let authorLabel_Retrs = UILabel()
    private let likeLabel_Retrs  = UILabel()
    private let overlayView_Retrs = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white

        contentView.addSubview(mediaView_Retrs)
        mediaView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        overlayView_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        mediaView_Retrs.addSubview(overlayView_Retrs)
        overlayView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        let heartIV_Retrs = UIImageView(image: UIImage(systemName: "heart.fill"))
        heartIV_Retrs.tintColor = UIColor(hexstring_Retrs: "#FC8181")
        mediaView_Retrs.addSubview(heartIV_Retrs)
        heartIV_Retrs.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(12)
        }
        likeLabel_Retrs.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        likeLabel_Retrs.textColor = .white
        mediaView_Retrs.addSubview(likeLabel_Retrs)
        likeLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(heartIV_Retrs)
            make.trailing.equalTo(heartIV_Retrs.snp.leading).offset(-3)
        }

        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleLabel_Retrs.numberOfLines = 2
        contentView.addSubview(titleLabel_Retrs)
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Retrs.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        authorLabel_Retrs.font = UIFont.systemFont(ofSize: 10)
        authorLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentView.addSubview(authorLabel_Retrs)
        authorLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    func configure_Retrs(post_Retrs: TitleModel_Retrs) {
        mediaView_Retrs.configure_Retrs(mediaPath_Retrs: post_Retrs.titleMeidas_Retrs.first)
        titleLabel_Retrs.text  = post_Retrs.title_Retrs
        authorLabel_Retrs.text = "@ \(post_Retrs.titleUserName_Retrs)"
        likeLabel_Retrs.text   = "\(post_Retrs.likes_Retrs)"
    }
}

// MARK: - 主题打卡活动单元格

/// 主题活动横向卡片（带主题专属渐变 + 标题 + 参与人数 + Hot 徽章）
class ThemeActivityCell_Retrs: UICollectionViewCell {

    private let gradLayer_Retrs   = CAGradientLayer()
    private let emojiLbl_Retrs    = UILabel()
    private let titleLbl_Retrs    = UILabel()
    private let descLbl_Retrs     = UILabel()
    private let statsLbl_Retrs    = UILabel()
    private let hotBadge_Retrs    = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
        contentView.layer.insertSublayer(gradLayer_Retrs, at: 0)

        // 装饰气泡
        let bubble_Retrs = UIView()
        bubble_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        bubble_Retrs.layer.cornerRadius = 55
        contentView.addSubview(bubble_Retrs)
        bubble_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
        }

        contentView.addSubview(emojiLbl_Retrs)
        emojiLbl_Retrs.font = UIFont.systemFont(ofSize: 32)
        emojiLbl_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(16)
        }

        contentView.addSubview(titleLbl_Retrs)
        titleLbl_Retrs.font = UIFont.systemFont(ofSize: 20, weight: .black)
        titleLbl_Retrs.textColor = .white
        titleLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(emojiLbl_Retrs.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(18)
        }

        contentView.addSubview(descLbl_Retrs)
        descLbl_Retrs.font = UIFont.systemFont(ofSize: 11)
        descLbl_Retrs.textColor = UIColor.white.withAlphaComponent(0.8)
        descLbl_Retrs.numberOfLines = 1
        descLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Retrs.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-60)
        }

        let personIV_Retrs = UIImageView(image: UIImage(systemName: "person.3.fill"))
        personIV_Retrs.tintColor = UIColor.white.withAlphaComponent(0.8)
        personIV_Retrs.contentMode = .scaleAspectFit
        contentView.addSubview(personIV_Retrs)
        personIV_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(14)
        }
        contentView.addSubview(statsLbl_Retrs)
        statsLbl_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        statsLbl_Retrs.textColor = UIColor.white.withAlphaComponent(0.9)
        statsLbl_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(personIV_Retrs.snp.trailing).offset(5)
            make.centerY.equalTo(personIV_Retrs)
        }

        // Hot 徽章
        hotBadge_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#FC8181").withAlphaComponent(0.9)
        hotBadge_Retrs.layer.cornerRadius = 10
        let hotLbl_Retrs = UILabel()
        hotLbl_Retrs.text = "🔥 Hot"
        hotLbl_Retrs.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        hotLbl_Retrs.textColor = .white
        hotBadge_Retrs.addSubview(hotLbl_Retrs)
        hotLbl_Retrs.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.leading.trailing.equalToSuperview().inset(7)
        }
        contentView.addSubview(hotBadge_Retrs)
        hotBadge_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Retrs.frame = contentView.bounds
    }

    func configure_Retrs(activity_Retrs: ThemeActivity_Retrs) {
        gradLayer_Retrs.colors = activity_Retrs.gradient_Retrs.map { $0.cgColor }
        emojiLbl_Retrs.text  = activity_Retrs.emoji_Retrs
        titleLbl_Retrs.text  = activity_Retrs.title_Retrs
        descLbl_Retrs.text   = activity_Retrs.description_Retrs
        statsLbl_Retrs.text  = "\(activity_Retrs.participants_Retrs) participants"
        hotBadge_Retrs.isHidden = !activity_Retrs.isHot_Retrs
    }
}

// MARK: - 淘机小课堂单元格

/// CCD 技巧轻量卡片
class CCDTipCell_Retrs: UICollectionViewCell {

    private let bgView_Retrs    = UIView()
    private let catTag_Retrs    = UIView()
    private let catLbl_Retrs    = UILabel()
    private let tipTitle_Retrs  = UILabel()
    private let tipContent_Retrs = UILabel()
    private let iconIV_Retrs    = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        bgView_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        bgView_Retrs.layer.cornerRadius = 16
        bgView_Retrs.clipsToBounds = false
        bgView_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        bgView_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgView_Retrs.layer.shadowOpacity = 1
        bgView_Retrs.layer.shadowRadius  = 8
        contentView.addSubview(bgView_Retrs)
        bgView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        catTag_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.15)
        catTag_Retrs.layer.cornerRadius = 8
        bgView_Retrs.addSubview(catTag_Retrs)
        catLbl_Retrs.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        catLbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        catTag_Retrs.addSubview(catLbl_Retrs)
        catLbl_Retrs.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.leading.trailing.equalToSuperview().inset(7)
        }
        catTag_Retrs.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
        }

        iconIV_Retrs.contentMode = .scaleAspectFit
        iconIV_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.5)
        bgView_Retrs.addSubview(iconIV_Retrs)
        iconIV_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(22)
        }

        tipTitle_Retrs.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        tipTitle_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        tipTitle_Retrs.numberOfLines = 2
        bgView_Retrs.addSubview(tipTitle_Retrs)
        tipTitle_Retrs.snp.makeConstraints { make in
            make.top.equalTo(catTag_Retrs.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        tipContent_Retrs.font = UIFont.systemFont(ofSize: 10)
        tipContent_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        tipContent_Retrs.numberOfLines = 3
        bgView_Retrs.addSubview(tipContent_Retrs)
        tipContent_Retrs.snp.makeConstraints { make in
            make.top.equalTo(tipTitle_Retrs.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    func configure_Retrs(tip_Retrs: CCDTip_Retrs) {
        catLbl_Retrs.text    = tip_Retrs.category_Retrs
        tipTitle_Retrs.text  = tip_Retrs.title_Retrs
        tipContent_Retrs.text = tip_Retrs.content_Retrs
        iconIV_Retrs.image   = UIImage(systemName: tip_Retrs.icon_Retrs,
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium))
    }
}

// MARK: - 我的CCD技巧库单元格

/// CCD 相册忆录卡片（缩略图 + 相机型号）
class DiaryEntryCell_Retrs: UICollectionViewCell {

    private let mediaView_Retrs  = MediaDisplayView_Retrs()
    private let overlayView_Retrs = UIView()
    private let cameraLbl_Retrs  = UILabel()
    private let emptyView_Retrs  = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Retrs()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Retrs() {
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")

        contentView.addSubview(mediaView_Retrs)
        mediaView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        overlayView_Retrs.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        mediaView_Retrs.addSubview(overlayView_Retrs)
        overlayView_Retrs.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(40)
        }

        cameraLbl_Retrs.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        cameraLbl_Retrs.textColor = .white
        cameraLbl_Retrs.numberOfLines = 2
        overlayView_Retrs.addSubview(cameraLbl_Retrs)
        cameraLbl_Retrs.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-6)
        }

        // 空状态
        let addIV_Retrs = UIImageView(
            image: UIImage(systemName: "plus.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        )
        addIV_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.7)
        addIV_Retrs.contentMode = .scaleAspectFit
        emptyView_Retrs.addSubview(addIV_Retrs)
        addIV_Retrs.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalTo(30) }
        contentView.addSubview(emptyView_Retrs)
        emptyView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    func configure_Retrs(post_Retrs: TitleModel_Retrs?) {
        if let post_Retrs {
            emptyView_Retrs.isHidden  = true
            mediaView_Retrs.isHidden  = false
            overlayView_Retrs.isHidden = false
            mediaView_Retrs.configure_Retrs(mediaPath_Retrs: post_Retrs.titleMeidas_Retrs.first)
            cameraLbl_Retrs.text = post_Retrs.title_Retrs
        } else {
            emptyView_Retrs.isHidden   = false
            mediaView_Retrs.isHidden   = true
            overlayView_Retrs.isHidden = true
        }
    }
}

// MARK: - 日历单元格

/// 日历天数单元格（今天高亮/已打卡标记）
class CalendarDayCell_Retrs: UICollectionViewCell {

    private let dayLbl_Retrs     = UILabel()
    private let dotView_Retrs    = UIView()
    private let bgCircle_Retrs   = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(bgCircle_Retrs)
        bgCircle_Retrs.layer.cornerRadius = min(frame.width, frame.height) / 2
        bgCircle_Retrs.snp.makeConstraints { make in make.center.equalToSuperview(); make.width.height.equalToSuperview() }

        dayLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayLbl_Retrs.textAlignment = .center
        contentView.addSubview(dayLbl_Retrs)
        dayLbl_Retrs.snp.makeConstraints { make in make.center.equalToSuperview() }

        dotView_Retrs.layer.cornerRadius = 3
        dotView_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        contentView.addSubview(dotView_Retrs)
        dotView_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-2)
            make.width.height.equalTo(6)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure_Retrs(day_Retrs: Int, isToday_Retrs: Bool, isCheckedIn_Retrs: Bool) {
        dayLbl_Retrs.text = day_Retrs > 0 ? "\(day_Retrs)" : ""
        dotView_Retrs.isHidden = !isCheckedIn_Retrs

        if isToday_Retrs {
            bgCircle_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            dayLbl_Retrs.textColor = .white
            dayLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        } else {
            bgCircle_Retrs.backgroundColor = .clear
            dayLbl_Retrs.textColor = day_Retrs > 0
                ? ColorConfig_Retrs.textPrimary_Retrs
                : .clear
            dayLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        }
    }
}

// MARK: - 淘机小课堂数据模型

/// CCD 小课堂技巧模型
struct CCDTip_Retrs {
    var category_Retrs: String
    var title_Retrs: String
    var content_Retrs: String
    var icon_Retrs: String

    static let tips_Retrs: [CCDTip_Retrs] = [
        CCDTip_Retrs(category_Retrs: "Inspection", title_Retrs: "Used CCD Buying Checklist",
                     content_Retrs: "Check LCD for dead pixels, test autofocus speed, shoot 5 bright scenes to detect hot pixels, verify battery life.",
                     icon_Retrs: "checkmark.seal.fill"),
        CCDTip_Retrs(category_Retrs: "Maintenance", title_Retrs: "Preventing Lens Mold & Dust",
                     content_Retrs: "Store in a dry box at 40–50% humidity. Power on monthly for a few minutes. Always cap the lens when not in use.",
                     icon_Retrs: "drop.fill"),
        CCDTip_Retrs(category_Retrs: "Settings", title_Retrs: "Best Night Shot Parameters",
                     content_Retrs: "Set ISO 100–200 to control noise, keep shutter ≥ 1/30s, enable image stabilization, and leave white balance on Auto.",
                     icon_Retrs: "moon.stars.fill"),
        CCDTip_Retrs(category_Retrs: "Technique", title_Retrs: "Embracing CCD Grain",
                     content_Retrs: "High-ISO noise is the soul of CCD. ISO 400–800 with a slow shutter indoors under warm light gives the dreamiest results.",
                     icon_Retrs: "sparkles"),
        CCDTip_Retrs(category_Retrs: "Maintenance", title_Retrs: "Battery Storage & Revival",
                     content_Retrs: "Store long-term batteries at 40% charge. Reactivate every 3 months. Trickle-charging old Li-ion can restore ~70% capacity.",
                     icon_Retrs: "battery.100.bolt"),
        CCDTip_Retrs(category_Retrs: "Settings", title_Retrs: "White Balance for Vintage Color",
                     content_Retrs: "Set color temperature to 4000–4500K for warm golden tones. Cloudy WB outdoors gives a cool, film-like blue cast.",
                     icon_Retrs: "paintpalette.fill"),
    ]
}
