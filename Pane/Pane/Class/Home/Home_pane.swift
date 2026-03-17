import Foundation
import UIKit
import SnapKit

// MARK: 首页

// MARK: - 首页 ViewController

/// 首页页面
/// 核心作用：展示打卡进度条 / 月度日历热力图 / 专属窗景册
/// 设计理念：窗景集首页，卡片式布局模拟从窗口望向不同场景的视觉感受
/// 关键方法：
///   loadCheckInData_Pane()    - 刷新打卡进度条数据
///   loadCalendarData_Pane()   - 刷新月度日历热力图数据
///   loadAlbumsData_Pane()     - 刷新横向窗景册列表
///   animateCells_Pane()       - 入场动画
class Home_Pane: UIViewController {

    // MARK: - Section 标识

    private enum Section_Pane: Int, CaseIterable {
        case checkin_pane  = 0   // 打卡进度条（始终显示，未登录展示引导态）
        case calendar_pane = 1   // 月度可视化日历热力图
        case albums_pane   = 2   // 横向窗景册列表（始终显示，空状态引导创建）
    }

    // MARK: - UI组件

    /// 顶部自定义导航栏
    private let headerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 头部渐变背景层
    private var headerGradientLayer_Pane: CAGradientLayer?

    /// App 标题（渐变色）
    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Pane"
        l.font = UIFont(name: "Georgia-Bold", size: 28) ?? .systemFont(ofSize: 28, weight: .black)
        l.textColor = ColorConfig_Pane.primaryGradientStart_Pane
        return l
    }()

    /// 副标题
    private let subtitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Window Views"
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    /// 装饰性色块（Logo 左侧竖线）
    private let logoDot_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.clipsToBounds = true
        return v
    }()

    private var logoDotGradient_Pane: CAGradientLayer?

    /// 用户头像按钮（点击切换到「我的」Tab）
    private let avatarButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius  = 18
        btn.layer.masksToBounds = false
        btn.layer.borderWidth   = 2
        btn.layer.borderColor   = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.4).cgColor
        btn.layer.shadowColor   = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
        btn.layer.shadowOpacity = 0.25
        btn.layer.shadowOffset  = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius  = 6
        return btn
    }()

    /// 头像内嵌的 UserAvatarView
    private let avatarView_Pane: UserAvatarView_Pane = {
        let v = UserAvatarView_Pane()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 打卡按钮（右上角，展示连续天数）
    private let checkInButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()

    private var checkInButtonGradient_Pane: CAGradientLayer?

    /// 打卡按钮内火焰图标
    private let checkInFlameIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.tintColor = UIColor(hexstring_Pane: "#FF8C42")
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 主内容 CollectionView
    private lazy var collectionView_Pane: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: buildLayout_Pane())
        cv.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        cv.showsVerticalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        cv.dataSource = self
        cv.delegate   = self
        return cv
    }()

    /// 下拉刷新
    private let refreshControl_Pane = UIRefreshControl()

    // MARK: - 数据属性

    /// 打卡进度数据
    private var checkInRecords_Pane: [(date: String, checked: Bool, isToday: Bool)] = []

    /// 当前打卡连续天数
    private var checkInStreak_Pane: Int = 0

    /// 今天是否已打卡
    private var checkedToday_Pane: Bool = false

    /// 日历当前显示年份
    private var calendarYear_Pane  = Calendar.current.component(.year, from: Date())
    /// 日历当前显示月份
    private var calendarMonth_Pane = Calendar.current.component(.month, from: Date())
    /// 当月各日发帖数（键 = 日，值 = 数量）
    private var calendarData_Pane: [Int: Int] = [:]

    /// 当前用户窗景册列表
    private var albums_Pane: [WindowAlbum_Pane] = []

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Pane()
        setupHeader_Pane()
        setupCollectionView_Pane()
        registerNotifications_Pane()
        loadAllData_Pane()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        // 每次回到首页整体刷新一次（打卡状态、相册、帖子均可能在其他页面变更）
        loadAllData_Pane()
        updateCheckInButtonStyle_Pane()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCells_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Pane?.frame   = headerView_Pane.bounds
        logoDotGradient_Pane?.frame       = logoDot_Pane.bounds
        checkInButtonGradient_Pane?.frame = checkInButton_Pane.bounds
        // 同步更新头像按钮圆角（button.bounds 在 layout 后才确定）
        avatarButton_Pane.layer.cornerRadius = avatarButton_Pane.bounds.height / 2
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 初始化

    private func setupView_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
    }

    /// 构建顶部导航头部（Logo 左侧竖线装饰 + 右侧打卡 + 搜索）
    private func setupHeader_Pane() {
        view.addSubview(headerView_Pane)
        headerView_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(58)
        }

        // 头部背景（极浅渐变，增强质感）
        let hgl = CAGradientLayer()
        hgl.colors = [
            ColorConfig_Pane.backgroundPrimary_Pane.withAlphaComponent(0.98).cgColor,
            ColorConfig_Pane.backgroundPrimary_Pane.withAlphaComponent(0.95).cgColor
        ]
        hgl.startPoint = CGPoint(x: 0, y: 0)
        hgl.endPoint   = CGPoint(x: 0, y: 1)
        headerView_Pane.layer.addSublayer(hgl)
        headerGradientLayer_Pane = hgl

        // 左侧装饰竖线（渐变色）
        headerView_Pane.addSubview(logoDot_Pane)
        logoDot_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview().offset(-2)
            $0.width.equalTo(4)
            $0.height.equalTo(28)
        }
        let dotGL = UIColor.createPrimaryGradientLayer_Pane(frame_Pane: .zero)
        dotGL.cornerRadius = 2
        logoDot_Pane.layer.addSublayer(dotGL)
        logoDotGradient_Pane = dotGL

        // Logo 文字
        headerView_Pane.addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(logoDot_Pane.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(8)
        }

        headerView_Pane.addSubview(subtitleLabel_Pane)
        subtitleLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Pane)
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(0)
        }

        // 用户头像按钮（点击切换到「我的」Tab）
        headerView_Pane.addSubview(avatarButton_Pane)
        avatarButton_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        avatarButton_Pane.addSubview(avatarView_Pane)
        avatarView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }
        refreshAvatarView_Pane()
        avatarButton_Pane.addTarget(self, action: #selector(handleAvatarTap_Pane), for: .touchUpInside)

        // 打卡按钮（头像左侧）
        headerView_Pane.addSubview(checkInButton_Pane)
        checkInButton_Pane.snp.makeConstraints {
            $0.trailing.equalTo(avatarButton_Pane.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
            $0.width.greaterThanOrEqualTo(70)
        }
        checkInButton_Pane.addTarget(self, action: #selector(handleCheckInButtonTap_Pane), for: .touchUpInside)

        // 打卡按钮：火焰图标 + 连续天数
        checkInButton_Pane.addSubview(checkInFlameIcon_Pane)
        checkInFlameIcon_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
        checkInButton_Pane.contentEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 12)

        // 打卡按钮渐变背景
        let cgl = CAGradientLayer()
        cgl.colors = [
            UIColor(hexstring_Pane: "#FF7043").cgColor,
            UIColor(hexstring_Pane: "#E91E8C").cgColor
        ]
        cgl.startPoint     = CGPoint(x: 0, y: 0.5)
        cgl.endPoint       = CGPoint(x: 1, y: 0.5)
        cgl.cornerRadius   = 18
        checkInButton_Pane.layer.insertSublayer(cgl, at: 0)
        checkInButtonGradient_Pane = cgl

        // 打卡按钮阴影
        checkInButton_Pane.layer.masksToBounds = false
        checkInButton_Pane.layer.shadowColor   = UIColor(hexstring_Pane: "#FF7043").withAlphaComponent(0.4).cgColor
        checkInButton_Pane.layer.shadowOpacity = 1.0
        checkInButton_Pane.layer.shadowOffset  = CGSize(width: 0, height: 3)
        checkInButton_Pane.layer.shadowRadius  = 8

        // 头部底部细分割线
        let separator_pane = UIView()
        separator_pane.backgroundColor = ColorConfig_Pane.divider_Pane
        headerView_Pane.addSubview(separator_pane)
        separator_pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }

        updateCheckInButtonStyle_Pane()
    }

    /// 根据打卡状态更新打卡按钮文字和样式
    private func updateCheckInButtonStyle_Pane() {
        let streak_pane = UserViewModel_Pane.shared_Pane.getCheckInStreak_Pane()
        let checked_pane = UserViewModel_Pane.shared_Pane.hasCheckedInToday_Pane()
        let title_pane = checked_pane ? "✓ \(streak_pane)d" : (streak_pane > 0 ? "\(streak_pane)d" : "Check In")
        checkInButton_Pane.setTitle(title_pane, for: .normal)
        // 已打卡时降低按钮亮度
        checkInButtonGradient_Pane?.opacity = checked_pane ? 0.65 : 1.0
    }

    /// 配置 CollectionView 和下拉刷新，注册所有用到的 Cell
    private func setupCollectionView_Pane() {
        collectionView_Pane.register(
            HomeCheckInBannerCell_Pane.self,
            forCellWithReuseIdentifier: HomeCheckInBannerCell_Pane.reuseId_Pane
        )
        collectionView_Pane.register(
            HomeCalendarCell_Pane.self,
            forCellWithReuseIdentifier: HomeCalendarCell_Pane.reuseId_Pane
        )
        collectionView_Pane.register(
            HomeAlbumSectionCell_Pane.self,
            forCellWithReuseIdentifier: HomeAlbumSectionCell_Pane.reuseId_Pane
        )

        view.addSubview(collectionView_Pane)
        collectionView_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        refreshControl_Pane.tintColor = ColorConfig_Pane.primaryGradientStart_Pane
        refreshControl_Pane.addTarget(self, action: #selector(handleRefresh_Pane), for: .valueChanged)
        collectionView_Pane.refreshControl = refreshControl_Pane
    }

    // MARK: - 数据加载

    /// 加载全部数据并整体刷新 CollectionView
    private func loadAllData_Pane() {
        let titleVM_pane = TitleViewModel_Pane.shared_Pane
        let userVM_pane  = UserViewModel_Pane.shared_Pane

        // 打卡数据（已登录时有效，未登录返回空）
        checkInStreak_Pane  = userVM_pane.getCheckInStreak_Pane()
        checkedToday_Pane   = userVM_pane.hasCheckedInToday_Pane()
        checkInRecords_Pane = userVM_pane.getCheckInRecord_Pane(days_pane: 7)

        // 日历数据：仅已登录时展示用户打卡记录，未登录不展示任何热力数据
        calendarData_Pane = userVM_pane.isLoggedIn_Pane
            ? userVM_pane.getCheckInCalendarData_Pane(year_pane: calendarYear_Pane, month_pane: calendarMonth_Pane)
            : [:]

        // 相册数据（从用户模型读取）
        albums_Pane = userVM_pane.isLoggedIn_Pane
            ? userVM_pane.getCurrentUser_Pane().userWindowAlbums_Pane
            : titleVM_pane.getUserAlbums_Pane()

        // 刷新头像
        refreshAvatarView_Pane()

        collectionView_Pane.reloadData()
    }

    /// 刷新头像按钮内的 UserAvatarView
    private func refreshAvatarView_Pane() {
        let user_pane = UserViewModel_Pane.shared_Pane.getCurrentUser_Pane()
        avatarView_Pane.configure_Pane(userId_Pane: user_pane.userId_Pane ?? 0)
    }

    /// 刷新打卡进度条数据（登录状态才有数据）
    private func loadCheckInData_Pane() {
        let vm_pane         = UserViewModel_Pane.shared_Pane
        checkInStreak_Pane  = vm_pane.getCheckInStreak_Pane()
        checkedToday_Pane   = vm_pane.hasCheckedInToday_Pane()
        checkInRecords_Pane = vm_pane.getCheckInRecord_Pane(days_pane: 7)
        // 状态更新后统一整体刷新，避免 reloadSections 与其他更新冲突导致崩溃
        collectionView_Pane.reloadData()
    }

    /// 加载月度日历热力图数据（当前显示月）
    /// 已登录时从用户模型拓展字段 userCheckInDates_Pane 读取；未登录时不展示任何热力数据
    private func loadCalendarData_Pane() {
        let userVM_pane = UserViewModel_Pane.shared_Pane
        calendarData_Pane = userVM_pane.isLoggedIn_Pane
            ? userVM_pane.getCheckInCalendarData_Pane(year_pane: calendarYear_Pane, month_pane: calendarMonth_Pane)
            : [:]
        collectionView_Pane.reloadData()
    }

    /// 加载当前用户窗景册列表
    private func loadAlbumsData_Pane() {
        albums_Pane = TitleViewModel_Pane.shared_Pane.getUserAlbums_Pane()
        collectionView_Pane.reloadData()
    }

    // MARK: - 通知注册

    private func registerNotifications_Pane() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Pane),
            name: TitleViewModel_Pane.titleStateDidChangeNotification_Pane,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Pane),
            name: UserViewModel_Pane.userStateDidChangeNotification_Pane,
            object: nil
        )
    }

    // MARK: - CompositionalLayout 构建

    private func buildLayout_Pane() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            switch Section_Pane(rawValue: sectionIndex) {
            case .checkin_pane:   return self.buildCheckInSection_Pane()
            case .calendar_pane:  return self.buildCalendarSection_Pane()
            case .albums_pane:    return self.buildAlbumsSection_Pane()
            default:              return self.buildCheckInSection_Pane()
            }
        }
    }

    /// Section 0：打卡进度条（全宽单 Cell，固定高度 88）
    private func buildCheckInSection_Pane() -> NSCollectionLayoutSection {
        let item_pane  = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group_pane = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88)), subitems: [item_pane])
        let section_pane = NSCollectionLayoutSection(group: group_pane)
        section_pane.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 20, trailing: 16)
        return section_pane
    }

    /// Section 2：月度日历热力图（全宽单 Cell）
    /// 高度分解：头部(68) + 星期行偏移(12) + 星期行(14) + 分割线偏移(4) + 分割线(0.5)
    ///           + 格子偏移(4) + 格子(6×30+5×3) + 统计偏移(10) + 统计行(20) + 底部内距(12) + card底部(8)
    private func buildCalendarSection_Pane() -> NSCollectionLayoutSection {
        let gridH_pane:   CGFloat = 6 * 30 + 5 * 3
        let cellH_pane:   CGFloat = 68 + 12 + 14 + 4 + 1 + 4 + gridH_pane + 10 + 20 + 12 + 8
        let itemSize_pane = NSCollectionLayoutSize(
            widthDimension:  .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let groupSize_pane = NSCollectionLayoutSize(
            widthDimension:  .fractionalWidth(1),
            heightDimension: .absolute(cellH_pane)
        )
        let item_pane    = NSCollectionLayoutItem(layoutSize: itemSize_pane)
        let group_pane   = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize_pane, subitems: [item_pane])
        let section_pane = NSCollectionLayoutSection(group: group_pane)
        section_pane.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return section_pane
    }

    /// Section 3：横向窗景册列表（全宽单 Cell，高度 = 区头36 + 间距12 + 列表/空状态128）
    private func buildAlbumsSection_Pane() -> NSCollectionLayoutSection {
        let totalH_pane: CGFloat = 36 + 12 + 128
        let item_pane    = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
        let group_pane   = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(totalH_pane)),
            subitems: [item_pane]
        )
        let section_pane = NSCollectionLayoutSection(group: group_pane)
        section_pane.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 24, trailing: 0)
        return section_pane
    }

    // MARK: - 动画

    /// 页面出现时各 Cell 逐个从底部滑入
    private func animateCells_Pane() {
        collectionView_Pane.visibleCells.enumerated().forEach { idx_pane, cell_pane in
            let delay_pane = Double(idx_pane) * AnimationConfig_Pane.delayShort_Pane
            cell_pane.animateSlideInFromBottom_Pane(offset_Pane: 40, delay_Pane: delay_pane)
        }
    }

    // MARK: - 事件处理

    /// 点击头像 → 切换到「我的」Tab（index 4）
    @objc private func handleAvatarTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .light)
        gen_pane.impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.avatarButton_Pane.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0,
                           usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5,
                           animations: { self.avatarButton_Pane.transform = .identity }) { _ in
                self.tabBarController?.selectedIndex = 4
            }
        }
    }

    /// 弹出日期当日记录弹窗
    private func presentDayRecords_Pane(day_pane: Int) {
        let popup_pane = HomeDayRecordsPopup_Pane()
        popup_pane.year_Pane  = calendarYear_Pane
        popup_pane.month_Pane = calendarMonth_Pane
        popup_pane.day_Pane   = day_pane
        popup_pane.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet_pane = popup_pane.sheetPresentationController {
                sheet_pane.detents            = [.medium(), .large()]
                sheet_pane.prefersGrabberVisible = true
            }
        }
        present(popup_pane, animated: true)
    }

    /// 弹出快速记录半弹窗
    private func presentQuickRecord_Pane() {
        let sheet_pane = HomeQuickRecordSheet_Pane()
        let nav_pane   = UINavigationController(rootViewController: sheet_pane)
        nav_pane.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let s_pane = nav_pane.sheetPresentationController {
                s_pane.detents            = [.medium(), .large()]
                s_pane.prefersGrabberVisible = true
            }
        }
        sheet_pane.onPublished_Pane = { [weak self] in
            self?.loadAllData_Pane()
        }
        present(nav_pane, animated: true)
    }

    /// 打卡按钮点击：未登录跳登录；已登录则跳打卡页
    @objc private func handleCheckInButtonTap_Pane() {
        let gen_pane = UIImpactFeedbackGenerator(style: .medium)
        gen_pane.impactOccurred()
        checkInButton_Pane.animatePulse_Pane()
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Pane.toLogin_Pane()
            }
            return
        }
        Navigation_Pane.toCheckIn_Pane()
    }

    @objc private func handleRefresh_Pane() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.loadAllData_Pane()
            self.refreshControl_Pane.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animateCells_Pane()
            }
        }
    }

    @objc private func handleTitleStateChange_Pane() {
        loadAllData_Pane()
    }

    @objc private func handleUserStateChange_Pane() {
        loadAllData_Pane()
        updateCheckInButtonStyle_Pane()
    }

    /// 首页相册列表项删除确认弹窗
    /// - Parameter album_pane: 要删除的窗景册
    private func confirmDeleteAlbumFromHome_Pane(album_pane: WindowAlbum_Pane) {
        let alert_pane = UIAlertController(
            title: "Delete Album",
            message: "Delete \"\(album_pane.albumName_Pane)\"? Images inside will not be removed.",
            preferredStyle: .alert
        )
        alert_pane.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            TitleViewModel_Pane.shared_Pane.deleteAlbum_Pane(albumId_pane: album_pane.albumId_Pane)
        })
        alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_pane, animated: true)
    }

    /// 弹出创建窗景册对话框
    private func presentCreateAlbumDialog_Pane() {
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Pane.toLogin_Pane()
            }
            return
        }

        let alert_pane = UIAlertController(
            title: "New Window Album",
            message: "Give your album a name",
            preferredStyle: .alert
        )
        alert_pane.addTextField { tf in
            tf.placeholder = "e.g. Four Seasons Views"
            tf.autocapitalizationType = .words
        }
        alert_pane.addTextField { tf in
            tf.placeholder = "Description (optional)"
        }

        let createAction_pane = UIAlertAction(title: "Create", style: .default) { [weak alert_pane] _ in
            let rawName_pane: String = alert_pane?.textFields?[0].text ?? ""
            let rawDesc_pane: String = alert_pane?.textFields?[1].text ?? ""
            let name_pane = rawName_pane.trimmingCharacters(in: .whitespacesAndNewlines)
            let desc_pane = rawDesc_pane.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name_pane.isEmpty else {
                Utils_Pane.showWarning_Pane(message_Pane: "Album name cannot be empty.")
                return
            }
            TitleViewModel_Pane.shared_Pane.createAlbum_Pane(
                name_pane: name_pane,
                desc_pane: desc_pane
            )
            let successMsg_pane: String = "Album \"\(name_pane)\" created!"
            Utils_Pane.showSuccess_Pane(
                message_Pane: successMsg_pane,
                image_Pane: UIImage(systemName: "checkmark.circle.fill")
            )
        }
        alert_pane.addAction(createAction_pane)
        alert_pane.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_pane, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension Home_Pane: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section_Pane.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section_Pane(rawValue: section) {
        case .checkin_pane:   return 1   // 始终显示，未登录内部展示引导态
        case .calendar_pane:  return 1
        case .albums_pane:    return 1   // 始终显示，空状态由 Cell 内部处理
        default:              return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section_Pane(rawValue: indexPath.section) {

        case .checkin_pane:
            let cell_pane = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeCheckInBannerCell_Pane.reuseId_Pane,
                for: indexPath
            ) as! HomeCheckInBannerCell_Pane
            let isLoggedIn_pane = UserViewModel_Pane.shared_Pane.isLoggedIn_Pane
            cell_pane.configure_Pane(
                streak_pane: checkInStreak_Pane,
                records_pane: checkInRecords_Pane,
                checkedToday_pane: checkedToday_Pane,
                isLoggedIn_pane: isLoggedIn_pane
            )
            cell_pane.onTapped_Pane = {
                if isLoggedIn_pane {
                    Navigation_Pane.toCheckIn_Pane()
                } else {
                    Navigation_Pane.toLogin_Pane()
                }
            }
            return cell_pane

        case .calendar_pane:
            let cell_pane = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeCalendarCell_Pane.reuseId_Pane,
                for: indexPath
            ) as! HomeCalendarCell_Pane
            cell_pane.configure_Pane(
                year_pane: calendarYear_Pane,
                month_pane: calendarMonth_Pane,
                checkInByDay_pane: calendarData_Pane,
                streak_pane: checkInStreak_Pane
            )
            cell_pane.onMonthChange_Pane = { [weak self] year_pane, month_pane in
                guard let self = self else { return }
                self.calendarYear_Pane  = year_pane
                self.calendarMonth_Pane = month_pane
                self.loadCalendarData_Pane()
            }
            cell_pane.onDayTapped_Pane = { [weak self] day_pane in
                self?.presentDayRecords_Pane(day_pane: day_pane)
            }
            return cell_pane

        case .albums_pane:
            let cell_pane = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeAlbumSectionCell_Pane.reuseId_Pane,
                for: indexPath
            ) as! HomeAlbumSectionCell_Pane
            cell_pane.configure_Pane(albums_pane: albums_Pane)
            cell_pane.onCreateAlbum_Pane = { [weak self] in
                self?.presentCreateAlbumDialog_Pane()
            }
            cell_pane.onSelectAlbum_Pane = { album_pane in
                Navigation_Pane.toAlbum_Pane(album_pane: album_pane)
            }
            cell_pane.onQuickRecord_Pane = { [weak self] in
                self?.presentQuickRecord_Pane()
            }
            cell_pane.onDeleteAlbum_Pane = { [weak self] album_pane in
                self?.confirmDeleteAlbumFromHome_Pane(album_pane: album_pane)
            }
            return cell_pane

        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Home_Pane: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section_Pane(rawValue: indexPath.section) {
        case .checkin_pane:
            Navigation_Pane.toCheckIn_Pane()
        default:
            break
        }
    }
}

