import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页页面
/// 功能：展示今日灵感推荐和我的彩绘日记
/// 特性：推荐卡片横向滚动、日历视图、日记列表、图片选择与记录
class Home_Glasspaint: UIViewController {
    
    // MARK: - UI属性
    
    /// 主滚动视图
    private let scrollView_Glasspaint = UIScrollView()
    
    /// 内容容器
    private let contentView_Glasspaint = UIView()
    
    /// 背景渐变层
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    
    /// 装饰圆圈1
    private let decorCircle1_Glasspaint = UIView()
    
    /// 装饰圆圈2
    private let decorCircle2_Glasspaint = UIView()
    
    /// 粒子层
    private let particleLayer_Glasspaint = CAEmitterLayer()
    
    /// 导航栏容器
    private let navContainer_Glasspaint = UIView()
    
    /// 导航栏毛玻璃效果
    private let navBlurEffect_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    /// 用户头像
    private let avatarView_Glasspaint = CurrentUserAvatarView_Glasspaint()
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 副标题标签
    private let subtitleLabel_Glasspaint = UILabel()
    
    // 今日灵感推荐区域
    private let recommendContainer_Glasspaint = UIView()
    private let recommendTitleLabel_Glasspaint = UILabel()
    private let refreshButton_Glasspaint = UIButton(type: .system)
    private let recommendCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumLineSpacing = 16
        layout_glasspaint.itemSize = CGSize(width: 280, height: 350)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.showsHorizontalScrollIndicator = false
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView_glasspaint
    }()
    
    // 我的彩绘时光轴区域
    private let timelineContainer_Glasspaint = UIView()
    private let timelineTitleLabel_Glasspaint = UILabel()
    
    /// 日历视图
    private let calendarView_Glasspaint = PaintingCalendarView_Glasspaint()
    
    /// 日记列表表格视图
    private let diaryTableView_Glasspaint: UITableView = {
        let tableView_glasspaint = UITableView()
        tableView_glasspaint.backgroundColor = .clear
        tableView_glasspaint.separatorStyle = .none
        tableView_glasspaint.showsVerticalScrollIndicator = false
        tableView_glasspaint.isScrollEnabled = false
        return tableView_glasspaint
    }()
    
    /// 日记条目列表
    private var diaryEntries_Glasspaint: [PaintingDiaryEntry_Glasspaint] = []
    
    /// 当前选中的日期
    private var selectedDate_Glasspaint: Date?
    
    /// 空状态视图
    private let emptyStateView_Glasspaint = EmptyStateView_Glasspaint(stateType_glasspaint: .noRecommendations_glasspaint)
    
    /// 日记空状态视图
    private let diaryEmptyStateView_Glasspaint = EmptyStateView_Glasspaint(stateType_glasspaint: .custom_glasspaint("No Diary Yet", "Tap the + button to record your painting journey"))
    
    /// 底部占位视图
    private let bottomSpacer_Glasspaint = UIView()
    
    // MARK: - 数据属性
    
    /// 推荐作品列表
    private var recommendations_Glasspaint: [TitleModel_Glasspaint] = []
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadRecommendations_Glasspaint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupNotifications_Glasspaint()
        loadRecommendations_Glasspaint()
        loadDiaryData_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变层
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 主滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.delegate = self
        
        // 内容容器
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        contentView_Glasspaint.addSubview(navContainer_Glasspaint)
        setupNavigationBar_Glasspaint()
        
        // 推荐区域
        contentView_Glasspaint.addSubview(recommendContainer_Glasspaint)
        setupRecommendSection_Glasspaint()
        
        // 时光轴区域
        contentView_Glasspaint.addSubview(timelineContainer_Glasspaint)
        setupTimelineSection_Glasspaint()
        
        // 空状态视图
        contentView_Glasspaint.addSubview(emptyStateView_Glasspaint)
        emptyStateView_Glasspaint.isHidden = true
        
        // 布局
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 毛玻璃背景
        navContainer_Glasspaint.insertSubview(navBlurEffect_Glasspaint, at: 0)
        navBlurEffect_Glasspaint.alpha = 0
        
        // 用户头像容器（添加阴影和光晕效果）
        let avatarContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(avatarContainer_glasspaint)
        avatarContainer_glasspaint.addSubview(avatarView_Glasspaint)
        
        // 确保头像视图的圆角和裁剪
        avatarView_Glasspaint.layer.cornerRadius = 24
        avatarView_Glasspaint.layer.masksToBounds = true
        avatarView_Glasspaint.imageView_Glasspaint.layer.cornerRadius = 24
        avatarView_Glasspaint.imageView_Glasspaint.clipsToBounds = true
        
        // 头像边框
        avatarView_Glasspaint.layer.borderWidth = 2.5
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 头像发光效果
        avatarContainer_glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        avatarContainer_glasspaint.layer.shadowOffset = .zero
        avatarContainer_glasspaint.layer.shadowRadius = 10
        avatarContainer_glasspaint.layer.shadowOpacity = 0.5
        avatarContainer_glasspaint.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).cgPath
        
        // 头像点击事件
        avatarView_Glasspaint.onTapped_Glasspaint = { [weak self] in
            self?.handleAvatarTap_Glasspaint()
        }
        
        // 标题容器（居中布局）
        let titleContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 主标题
        titleContainer_glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "✨ GlassPaint"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Create & Inspire"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 布局
        navBlurEffect_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        // 强制刷新布局以确保圆角正确显示
        DispatchQueue.main.async {
            self.avatarView_Glasspaint.layoutIfNeeded()
            self.avatarView_Glasspaint.setNeedsLayout()
        }
        
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        subtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置推荐区域
    private func setupRecommendSection_Glasspaint() {
        // 标题容器（添加图标）
        let titleContainer_glasspaint = UIView()
        recommendContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "sparkles"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(recommendTitleLabel_Glasspaint)
        recommendTitleLabel_Glasspaint.text = "Today's Inspiration"
        recommendTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        recommendTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 刷新按钮（添加渐变背景）
        let refreshContainer_glasspaint = UIView()
        recommendContainer_Glasspaint.addSubview(refreshContainer_glasspaint)
        refreshContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        refreshContainer_glasspaint.layer.cornerRadius = 18
        
        refreshContainer_glasspaint.addSubview(refreshButton_Glasspaint)
        refreshButton_Glasspaint.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        refreshButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        refreshButton_Glasspaint.addTarget(self, action: #selector(handleRefresh_Glasspaint), for: .touchUpInside)
        
        // 布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        recommendTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        refreshContainer_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleContainer_glasspaint)
            make.width.height.equalTo(36)
        }
        
        refreshButton_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        // 推荐集合视图
        recommendContainer_Glasspaint.addSubview(recommendCollectionView_Glasspaint)
        recommendCollectionView_Glasspaint.delegate = self
        recommendCollectionView_Glasspaint.dataSource = self
        recommendCollectionView_Glasspaint.register(RecommendationCardCell_Glasspaint.self, forCellWithReuseIdentifier: "RecommendationCardCell")
        
        // 布局推荐集合视图
        recommendCollectionView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
            make.height.equalTo(350)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置时光轴区域
    private func setupTimelineSection_Glasspaint() {
        // 标题容器（添加图标）
        let titleContainer_glasspaint = UIView()
        timelineContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "calendar.badge.plus"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(timelineTitleLabel_Glasspaint)
        timelineTitleLabel_Glasspaint.text = "My Painting Diary"
        timelineTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        timelineTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 提示标签
        let hintLabel_glasspaint = UILabel()
        titleContainer_glasspaint.addSubview(hintLabel_glasspaint)
        hintLabel_glasspaint.text = "Tap date to filter"
        hintLabel_glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        hintLabel_glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        hintLabel_glasspaint.alpha = 0.7
        
        // 日历视图
        timelineContainer_Glasspaint.addSubview(calendarView_Glasspaint)
        calendarView_Glasspaint.onDateSelected_Glasspaint = { [weak self] date_glasspaint in
            self?.handleDateSelected_Glasspaint(date_glasspaint: date_glasspaint)
        }
        calendarView_Glasspaint.onAddTapped_Glasspaint = { [weak self] in
            self?.handleAddDiaryEntry_Glasspaint()
        }
        
        // 日记列表
        timelineContainer_Glasspaint.addSubview(diaryTableView_Glasspaint)
        diaryTableView_Glasspaint.delegate = self
        diaryTableView_Glasspaint.dataSource = self
        diaryTableView_Glasspaint.register(DiaryEntryCell_Glasspaint.self, forCellReuseIdentifier: "DiaryEntryCell")
        
        // 空状态视图
        timelineContainer_Glasspaint.addSubview(diaryEmptyStateView_Glasspaint)
        diaryEmptyStateView_Glasspaint.isHidden = true
        
        // 底部占位视图（确保可滚动）
        timelineContainer_Glasspaint.addSubview(bottomSpacer_Glasspaint)
        bottomSpacer_Glasspaint.backgroundColor = .clear
        
        // 布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        timelineTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.top.equalToSuperview()
        }
        
        hintLabel_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(timelineTitleLabel_Glasspaint)
            make.bottom.equalToSuperview()
        }
        
        calendarView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        diaryTableView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(calendarView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(0)
        }
        
        diaryEmptyStateView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(calendarView_Glasspaint.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(300)
        }
        
        bottomSpacer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(diaryTableView_Glasspaint.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置布局约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        recommendContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        timelineContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(recommendContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        emptyStateView_Glasspaint.snp.makeConstraints { make in
            make.center.equalTo(recommendCollectionView_Glasspaint)
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载推荐数据
    private func loadRecommendations_Glasspaint() {
        recommendations_Glasspaint = RecommendViewModel_Glasspaint.shared_Glasspaint.getTodayRecommendations_Glasspaint()
        
        // 更新UI
        if recommendations_Glasspaint.isEmpty {
            emptyStateView_Glasspaint.isHidden = false
            recommendCollectionView_Glasspaint.isHidden = true
        } else {
            emptyStateView_Glasspaint.isHidden = true
            recommendCollectionView_Glasspaint.isHidden = false
            recommendCollectionView_Glasspaint.reloadData()
        }
    }
    
    /// 加载成长数据
    /// 加载日记数据
    private func loadDiaryData_Glasspaint() {
        // 获取当前登录用户的日记数据
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        let allDiaries_glasspaint = currentUser_glasspaint.paintingDiary_Glasspaint
        
        // 配置日历（标记有记录的日期）
        calendarView_Glasspaint.configure_Glasspaint(with_glasspaint: allDiaries_glasspaint)
        
        // 更新列表数据
        updateDiaryList_Glasspaint(diaries_glasspaint: allDiaries_glasspaint)
    }
    
    /// 更新日记列表
    /// 参数：
    /// - diaries_glasspaint: 日记列表
    private func updateDiaryList_Glasspaint(diaries_glasspaint: [PaintingDiaryEntry_Glasspaint]) {
        // 如果有选中日期，筛选该日期的日记
        if let selectedDate_glasspaint = selectedDate_Glasspaint {
            let calendar_glasspaint = Calendar.current
            diaryEntries_Glasspaint = diaries_glasspaint.filter { entry_glasspaint in
                calendar_glasspaint.isDate(entry_glasspaint.date_Glasspaint, inSameDayAs: selectedDate_glasspaint)
            }.sorted { $0.createdAt_Glasspaint > $1.createdAt_Glasspaint }
            
            // 有选中日期时，空状态显示特定日期无数据
            if diaryEntries_Glasspaint.isEmpty {
                let formatter_glasspaint = DateFormatter()
                formatter_glasspaint.dateFormat = "MMM dd"
                let dateString_glasspaint = formatter_glasspaint.string(from: selectedDate_glasspaint)
                diaryEmptyStateView_Glasspaint.configure_Glasspaint(with_glasspaint: .custom_glasspaint(
                    "No Diary on \(dateString_glasspaint)",
                    "Tap the + button to add your first entry"
                ))
            }
        } else {
            // 显示所有日记，按时间倒序
            diaryEntries_Glasspaint = diaries_glasspaint.sorted { $0.createdAt_Glasspaint > $1.createdAt_Glasspaint }
            
            // 无选中日期时，空状态显示通用提示
            if diaryEntries_Glasspaint.isEmpty {
                diaryEmptyStateView_Glasspaint.configure_Glasspaint(with_glasspaint: .custom_glasspaint(
                    "No Diary Yet",
                    "Tap the + button to record your painting journey"
                ))
            }
        }
        
        // 更新空状态视图
        diaryEmptyStateView_Glasspaint.isHidden = !diaryEntries_Glasspaint.isEmpty
        diaryTableView_Glasspaint.isHidden = diaryEntries_Glasspaint.isEmpty
        
        // 更新底部占位视图约束
        bottomSpacer_Glasspaint.snp.remakeConstraints { make in
            if diaryEntries_Glasspaint.isEmpty {
                make.top.equalTo(diaryEmptyStateView_Glasspaint.snp.bottom).offset(20)
            } else {
                make.top.equalTo(diaryTableView_Glasspaint.snp.bottom)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
            make.bottom.equalToSuperview()
        }
        
        // 刷新表格
        diaryTableView_Glasspaint.reloadData()
        
        // 更新表格高度
        updateDiaryTableHeight_Glasspaint()
    }
    
    /// 更新日记表格高度
    private func updateDiaryTableHeight_Glasspaint() {
        // 计算固定高度：每个日记条目 236 像素（卡片220 + 上下间距16）
        let totalHeight_glasspaint = CGFloat(diaryEntries_Glasspaint.count) * 236
        
        // 更新表格高度约束
        diaryTableView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(totalHeight_glasspaint)
        }
        
        // 平滑更新布局，并确保滚动视图更新内容大小
        UIView.animate(withDuration: 0.3) {
            self.diaryTableView_Glasspaint.layoutIfNeeded()
            self.timelineContainer_Glasspaint.layoutIfNeeded()
            self.contentView_Glasspaint.layoutIfNeeded()
            self.scrollView_Glasspaint.layoutIfNeeded()
        } completion: { _ in
            // 确保滚动视图内容大小已更新
            self.scrollView_Glasspaint.setNeedsLayout()
            self.scrollView_Glasspaint.layoutIfNeeded()
        }
    }
    
    // MARK: - 通知
    
    /// 设置通知监听
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Glasspaint),
            name: TitleViewModel_Glasspaint.titleStateDidChangeNotification_Glasspaint,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Glasspaint),
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    @objc private func handleTitleStateChange_Glasspaint() {
        loadRecommendations_Glasspaint()
        loadDiaryData_Glasspaint()
    }
    
    @objc private func handleUserStateChange_Glasspaint() {
        loadRecommendations_Glasspaint()
        loadDiaryData_Glasspaint()
    }
    
    // MARK: - 交互
    
    /// 处理头像点击事件
    private func handleAvatarTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 切换到底部导航的"我的"页面（索引4）
        if let tabBarController_glasspaint = self.tabBarController {
            // 如果已经在"我的"页面，不做任何操作
            if tabBarController_glasspaint.selectedIndex == 4 {
                return
            }
            
            // 切换页面
            tabBarController_glasspaint.selectedIndex = 4
            
            // 添加平滑过渡动画
            UIView.transition(with: tabBarController_glasspaint.view,
                            duration: 0.25,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
        }
    }
    
    /// 处理日期选择
    /// 参数：
    /// - date_glasspaint: 选中的日期
    private func handleDateSelected_Glasspaint(date_glasspaint: Date) {
        // 检查日历是否有选中日期
        if let calendarSelectedDate_glasspaint = calendarView_Glasspaint.getSelectedDate_Glasspaint() {
            // 有选中日期
            selectedDate_Glasspaint = calendarSelectedDate_glasspaint
        } else {
            // 取消选中，显示所有日记
            selectedDate_Glasspaint = nil
        }
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .light)
        generator_glasspaint.impactOccurred()
        
        // 重新加载日记列表
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        updateDiaryList_Glasspaint(diaries_glasspaint: currentUser_glasspaint.paintingDiary_Glasspaint)
        
        // 如果有数据，平滑滚动到日记列表区域
        if !diaryEntries_Glasspaint.isEmpty && selectedDate_Glasspaint != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let tableViewOffset_glasspaint = self.calendarView_Glasspaint.frame.maxY + 20
                let scrollPoint_glasspaint = CGPoint(x: 0, y: tableViewOffset_glasspaint)
                self.scrollView_Glasspaint.setContentOffset(scrollPoint_glasspaint, animated: true)
            }
        }
    }
    
    /// 处理添加日记
    private func handleAddDiaryEntry_Glasspaint() {
        // 弹出添加日记页面
        let addDiaryVC_glasspaint = AddDiaryViewController_Glasspaint(selectedDate_glasspaint: selectedDate_Glasspaint ?? Date())
        addDiaryVC_glasspaint.onCompleted_Glasspaint = { [weak self] in
            // 刷新数据
            self?.loadDiaryData_Glasspaint()
        }
        
        // 以模态方式展示
        addDiaryVC_glasspaint.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet_glasspaint = addDiaryVC_glasspaint.sheetPresentationController {
                sheet_glasspaint.detents = [.large()]
                sheet_glasspaint.prefersGrabberVisible = true
            }
        }
        
        present(addDiaryVC_glasspaint, animated: true)
    }
    
    /// 处理删除选中日期的日记
    private func handleDeleteSelectedDateDiaries_Glasspaint() {
        // 检查是否有选中日期
        guard let selectedDate_glasspaint = selectedDate_Glasspaint else {
            return
        }
        
        // 获取选中日期的日记条目
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        let calendar_glasspaint = Calendar.current
        let diariesToDelete_glasspaint = currentUser_glasspaint.paintingDiary_Glasspaint.filter { entry_glasspaint in
            calendar_glasspaint.isDate(entry_glasspaint.date_Glasspaint, inSameDayAs: selectedDate_glasspaint)
        }
        
        // 检查是否有日记可删除
        if diariesToDelete_glasspaint.isEmpty {
            return
        }
        
        // 显示确认对话框
        let dateFormatter_glasspaint = DateFormatter()
        dateFormatter_glasspaint.dateFormat = "MMM dd, yyyy"
        let dateString_glasspaint = dateFormatter_glasspaint.string(from: selectedDate_glasspaint)
        
        let alert_glasspaint = UIAlertController(
            title: "Delete Diaries",
            message: "Delete all diary entries on \(dateString_glasspaint)? (\(diariesToDelete_glasspaint.count) entries)",
            preferredStyle: .alert
        )
        
        let deleteAction_glasspaint = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // 删除所有选中日期的日记
            for entry_glasspaint in diariesToDelete_glasspaint {
                UserViewModel_Glasspaint.shared_Glasspaint.deleteDiaryEntry_Glasspaint(entryId_glasspaint: entry_glasspaint.entryId_Glasspaint)
                
                // 删除本地图片文件
                for imagePath_glasspaint in entry_glasspaint.imagePaths_Glasspaint {
                    try? FileManager.default.removeItem(atPath: imagePath_glasspaint)
                }
            }
            
            // 清除选中状态
            self.selectedDate_Glasspaint = nil
            
            // 刷新数据
            self.loadDiaryData_Glasspaint()
            
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Diaries Deleted")
        }
        
        let cancelAction_glasspaint = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert_glasspaint.addAction(cancelAction_glasspaint)
        alert_glasspaint.addAction(deleteAction_glasspaint)
        
        present(alert_glasspaint, animated: true)
    }
    
    /// 处理删除日记
    /// 参数：
    /// - entry_glasspaint: 要删除的日记条目
    private func handleDeleteDiary_Glasspaint(entry_glasspaint: PaintingDiaryEntry_Glasspaint) {
        // 显示确认对话框
        let alert_glasspaint = UIAlertController(
            title: "Delete Diary",
            message: "Are you sure you want to delete this diary entry?",
            preferredStyle: .alert
        )
        
        let deleteAction_glasspaint = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            // 删除数据
            UserViewModel_Glasspaint.shared_Glasspaint.deleteDiaryEntry_Glasspaint(entryId_glasspaint: entry_glasspaint.entryId_Glasspaint)
            
            // 删除本地图片文件
            for imagePath_glasspaint in entry_glasspaint.imagePaths_Glasspaint {
                try? FileManager.default.removeItem(atPath: imagePath_glasspaint)
            }
            
            // 刷新数据
            self?.loadDiaryData_Glasspaint()
            
            Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Diary Deleted")
        }
        
        let cancelAction_glasspaint = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert_glasspaint.addAction(cancelAction_glasspaint)
        alert_glasspaint.addAction(deleteAction_glasspaint)
        
        present(alert_glasspaint, animated: true)
    }
    
    @objc private func handleRefresh_Glasspaint() {
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.refreshButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.refreshButton_Glasspaint.transform = .identity
            }
        }
        
        // 旋转动画
        let rotation_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation_glasspaint.fromValue = 0
        rotation_glasspaint.toValue = Double.pi * 2
        rotation_glasspaint.duration = 0.6
        rotation_glasspaint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        refreshButton_Glasspaint.layer.add(rotation_glasspaint, forKey: "refreshRotation")
        
        // 添加粒子爆炸效果
        createRefreshParticles_Glasspaint()
        
        loadRecommendations_Glasspaint()
    }
    
    /// 创建刷新粒子效果
    private func createRefreshParticles_Glasspaint() {
        let particleEmitter_glasspaint = CAEmitterLayer()
        
        // 获取按钮在视图中的位置
        let buttonFrame_glasspaint = refreshButton_Glasspaint.convert(refreshButton_Glasspaint.bounds, to: view)
        particleEmitter_glasspaint.emitterPosition = CGPoint(
            x: buttonFrame_glasspaint.midX,
            y: buttonFrame_glasspaint.midY
        )
        particleEmitter_glasspaint.emitterShape = .circle
        particleEmitter_glasspaint.emitterSize = CGSize(width: 20, height: 20)
        particleEmitter_glasspaint.renderMode = .additive
        
        let particle_glasspaint = CAEmitterCell()
        particle_glasspaint.contents = createCircleImage_Glasspaint().cgImage
        particle_glasspaint.birthRate = 50
        particle_glasspaint.lifetime = 0.8
        particle_glasspaint.velocity = 80
        particle_glasspaint.velocityRange = 40
        particle_glasspaint.emissionRange = .pi * 2
        particle_glasspaint.scale = 0.15
        particle_glasspaint.scaleRange = 0.1
        particle_glasspaint.alphaSpeed = -1.2
        particle_glasspaint.color = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        
        particleEmitter_glasspaint.emitterCells = [particle_glasspaint]
        view.layer.addSublayer(particleEmitter_glasspaint)
        
        // 0.1秒后停止发射
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            particleEmitter_glasspaint.birthRate = 0
        }
        
        // 1秒后移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particleEmitter_glasspaint.removeFromSuperlayer()
        }
    }
    
    /// 创建圆形图像（用于粒子）
    private func createCircleImage_Glasspaint() -> UIImage {
        let size_glasspaint = CGSize(width: 8, height: 8)
        let renderer_glasspaint = UIGraphicsImageRenderer(size: size_glasspaint)
        
        return renderer_glasspaint.image { context_glasspaint in
            let rect_glasspaint = CGRect(origin: .zero, size: size_glasspaint)
            context_glasspaint.cgContext.setFillColor(UIColor.white.cgColor)
            context_glasspaint.cgContext.fillEllipse(in: rect_glasspaint)
        }
    }
    
    // MARK: - 背景和装饰
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        // 渐变层设置
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#F0F4F8").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1（右上角）
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle1_Glasspaint.layer.cornerRadius = 150
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.right.equalToSuperview().offset(80)
            make.width.height.equalTo(300)
        }
        
        // 装饰圆圈2（左下角）
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 120
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }
        
        // 添加旋转动画
        animateDecorationCircles_Glasspaint()
        
        // 添加粒子效果
        setupParticleEffect_Glasspaint()
    }
    
    /// 装饰圆圈动画
    private func animateDecorationCircles_Glasspaint() {
        // 圆圈1旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 60
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        // 圆圈2反向旋转
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 80
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
        
        // 脉冲效果
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.decorCircle1_Glasspaint.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.decorCircle2_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    /// 设置粒子效果
    private func setupParticleEffect_Glasspaint() {
        // 粒子层配置
        particleLayer_Glasspaint.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -20)
        particleLayer_Glasspaint.emitterShape = .line
        particleLayer_Glasspaint.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        // 创建粒子单元（星星）
        let particleCell_glasspaint = CAEmitterCell()
        particleCell_glasspaint.contents = createStarImage_Glasspaint().cgImage
        particleCell_glasspaint.birthRate = 3
        particleCell_glasspaint.lifetime = 12
        particleCell_glasspaint.lifetimeRange = 4
        particleCell_glasspaint.velocity = 30
        particleCell_glasspaint.velocityRange = 20
        particleCell_glasspaint.emissionLongitude = .pi // 向下
        particleCell_glasspaint.emissionRange = .pi / 8
        particleCell_glasspaint.spin = 2
        particleCell_glasspaint.spinRange = 4
        particleCell_glasspaint.scale = 0.15
        particleCell_glasspaint.scaleRange = 0.1
        particleCell_glasspaint.alphaSpeed = -0.1
        particleCell_glasspaint.alphaRange = 0.3
        
        // 设置颜色（使用主题色）
        particleCell_glasspaint.color = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        particleCell_glasspaint.redRange = 0.2
        particleCell_glasspaint.greenRange = 0.2
        particleCell_glasspaint.blueRange = 0.3
        
        particleLayer_Glasspaint.emitterCells = [particleCell_glasspaint]
        view.layer.insertSublayer(particleLayer_Glasspaint, at: 1)
    }
    
    /// 创建星星图像（用于粒子）
    private func createStarImage_Glasspaint() -> UIImage {
        let size_glasspaint = CGSize(width: 20, height: 20)
        let renderer_glasspaint = UIGraphicsImageRenderer(size: size_glasspaint)
        
        return renderer_glasspaint.image { context_glasspaint in
            let ctx_glasspaint = context_glasspaint.cgContext
            
            // 绘制星星路径
            let center_glasspaint = CGPoint(x: size_glasspaint.width / 2, y: size_glasspaint.height / 2)
            let radius_glasspaint: CGFloat = 8
            let innerRadius_glasspaint: CGFloat = 4
            let points_glasspaint = 5
            
            ctx_glasspaint.beginPath()
            
            for i_glasspaint in 0..<points_glasspaint * 2 {
                let angle_glasspaint = CGFloat(i_glasspaint) * .pi / CGFloat(points_glasspaint) - .pi / 2
                let r_glasspaint = (i_glasspaint % 2 == 0) ? radius_glasspaint : innerRadius_glasspaint
                let x_glasspaint = center_glasspaint.x + r_glasspaint * cos(angle_glasspaint)
                let y_glasspaint = center_glasspaint.y + r_glasspaint * sin(angle_glasspaint)
                
                if i_glasspaint == 0 {
                    ctx_glasspaint.move(to: CGPoint(x: x_glasspaint, y: y_glasspaint))
                } else {
                    ctx_glasspaint.addLine(to: CGPoint(x: x_glasspaint, y: y_glasspaint))
                }
            }
            
            ctx_glasspaint.closePath()
            ctx_glasspaint.setFillColor(UIColor.white.cgColor)
            ctx_glasspaint.fillPath()
        }
    }
    
    // MARK: - 滚动视图代理
    
    /// 监听滚动，实现导航栏毛玻璃效果
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_glasspaint = scrollView.contentOffset.y
        let alpha_glasspaint = min(1, max(0, offset_glasspaint / 50))
        navBlurEffect_Glasspaint.alpha = alpha_glasspaint
    }
    
    // MARK: - 布局更新
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层大小
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        // 更新粒子层位置
        particleLayer_Glasspaint.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -20)
        particleLayer_Glasspaint.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        // 确保头像圆角正确显示
        let avatarRadius_glasspaint = avatarView_Glasspaint.bounds.width / 2
        avatarView_Glasspaint.layer.cornerRadius = avatarRadius_glasspaint
        avatarView_Glasspaint.imageView_Glasspaint.layer.cornerRadius = avatarRadius_glasspaint
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension Home_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecommendationCardCell",
            for: indexPath
        ) as! RecommendationCardCell_Glasspaint
        
        let post_glasspaint = recommendations_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint)
        
        // 添加入场动画
        cell_glasspaint.alpha = 0
        cell_glasspaint.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(
            withDuration: AnimationConfig_Glasspaint.durationSpring_Glasspaint,
            delay: Double(indexPath.item) * AnimationConfig_Glasspaint.delayShort_Glasspaint,
            usingSpringWithDamping: AnimationConfig_Glasspaint.springDampingNormal_Glasspaint,
            initialSpringVelocity: AnimationConfig_Glasspaint.springVelocity_Glasspaint
        ) {
            cell_glasspaint.alpha = 1.0
            cell_glasspaint.transform = .identity
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_glasspaint = recommendations_Glasspaint[indexPath.item]
        Navigation_Glasspaint.toTitleDetail_Glasspaint(titleModel_glasspaint: post_glasspaint)
    }
}

// MARK: - 推荐卡片单元格

/// 推荐卡片单元格
class RecommendationCardCell_Glasspaint: UICollectionViewCell {
    
    private let cardView_Glasspaint = RecommendationCard_Glasspaint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Glasspaint)
        cardView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure_Glasspaint(with_glasspaint post_glasspaint: TitleModel_Glasspaint) {
        cardView_Glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint)
    }
}

// MARK: - 日记列表 TableView 代理

extension Home_Glasspaint: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryEntries_Glasspaint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_glasspaint = tableView.dequeueReusableCell(withIdentifier: "DiaryEntryCell", for: indexPath) as! DiaryEntryCell_Glasspaint
        let entry_glasspaint = diaryEntries_Glasspaint[indexPath.row]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: entry_glasspaint)
        
        // 设置删除回调
        cell_glasspaint.onDelete_Glasspaint = { [weak self] in
            self?.handleDeleteDiary_Glasspaint(entry_glasspaint: entry_glasspaint)
        }
        
        // 添加入场动画
        cell_glasspaint.alpha = 0
        cell_glasspaint.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: AnimationConfig_Glasspaint.durationNormal_Glasspaint,
            delay: Double(indexPath.row) * AnimationConfig_Glasspaint.delayShort_Glasspaint
        ) {
            cell_glasspaint.alpha = 1.0
            cell_glasspaint.transform = .identity
        }
        
        return cell_glasspaint
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 236
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry_glasspaint = diaryEntries_Glasspaint[indexPath.row]
            
            // 显示确认对话框
            let alert_glasspaint = UIAlertController(
                title: "Delete Diary",
                message: "Are you sure you want to delete this diary entry?",
                preferredStyle: .alert
            )
            
            let deleteAction_glasspaint = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                // 删除数据
                UserViewModel_Glasspaint.shared_Glasspaint.deleteDiaryEntry_Glasspaint(entryId_glasspaint: entry_glasspaint.entryId_Glasspaint)
                
                // 删除本地图片文件
                for imagePath_glasspaint in entry_glasspaint.imagePaths_Glasspaint {
                    try? FileManager.default.removeItem(atPath: imagePath_glasspaint)
                }
                
                // 刷新数据
                self?.loadDiaryData_Glasspaint()
                
                Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "Diary Deleted")
            }
            
            let cancelAction_glasspaint = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert_glasspaint.addAction(cancelAction_glasspaint)
            alert_glasspaint.addAction(deleteAction_glasspaint)
            
            present(alert_glasspaint, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}


