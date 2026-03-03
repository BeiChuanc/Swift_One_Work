import Foundation
import UIKit
import SnapKit

// MARK: 消息列表

/// 消息列表页面
/// 功能：展示推荐用户和聊天记录用户
/// 设计：参考首页和发现页的现代化布局，包含背景渐变、装饰元素、毛玻璃导航栏
class MessageList_Glasspaint: UIViewController {
    
    // MARK: - UI组件
    
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 背景装饰
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    private let decorCircle1_Glasspaint = UIView()
    private let decorCircle2_Glasspaint = UIView()
    
    // 导航栏
    private let navContainer_Glasspaint = UIView()
    private let navBlurEffect_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let titleLabel_Glasspaint = UILabel()
    private let subtitleLabel_Glasspaint = UILabel()
    
    // 推荐用户区域
    private let recommendContainer_Glasspaint = UIView()
    private let recommendHeaderView_Glasspaint = UIView()
    private let recommendIconContainer_Glasspaint = UIView()
    private let recommendIconView_Glasspaint = UIImageView()
    private let recommendTitleLabel_Glasspaint = UILabel()
    private let recommendSubtitleLabel_Glasspaint = UILabel()
    private let recommendRefreshButton_Glasspaint = UIButton(type: .system)
    private let recommendCollectionView_Glasspaint: UICollectionView
    
    // Chat分隔标题
    private let chatSectionHeader_Glasspaint = UIView()
    private let chatSectionIconView_Glasspaint = UIImageView()
    private let chatSectionTitleLabel_Glasspaint = UILabel()
    private let chatBadgeLabel_Glasspaint = UILabel()
    
    // 聊天列表区域
    private let chatContainer_Glasspaint = UIView()
    private let chatTableView_Glasspaint = UITableView()
    
    // 空状态视图
    private let emptyStateView_Glasspaint = UIView()
    private let emptyIconView_Glasspaint = UIImageView()
    private let emptyTitleLabel_Glasspaint = UILabel()
    private let emptySubtitleLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    private var recommendUsers_Glasspaint: [PrewUserModel_Glasspaint] = []
    private var chatUsers_Glasspaint: [PrewUserModel_Glasspaint] = []
    
    // MARK: - 生命周期
    
    init() {
        // 创建推荐用户CollectionView布局
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumInteritemSpacing = 12
        layout_glasspaint.minimumLineSpacing = 12
        layout_glasspaint.itemSize = CGSize(width: 120, height: 180)
        layout_glasspaint.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        recommendCollectionView_Glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadData_Glasspaint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupNotifications_Glasspaint()
        loadData_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变层
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.delegate = self
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        contentView_Glasspaint.addSubview(navContainer_Glasspaint)
        setupNavigationBar_Glasspaint()
        
        // 推荐用户区域
        contentView_Glasspaint.addSubview(recommendContainer_Glasspaint)
        setupRecommendSection_Glasspaint()
        
        // Chat分隔标题
        contentView_Glasspaint.addSubview(chatSectionHeader_Glasspaint)
        setupChatSectionHeader_Glasspaint()
        
        // 聊天列表区域
        contentView_Glasspaint.addSubview(chatContainer_Glasspaint)
        setupChatSection_Glasspaint()
        
        // 空状态视图
        contentView_Glasspaint.addSubview(emptyStateView_Glasspaint)
        setupEmptyState_Glasspaint()
        
        // 设置约束
        setupConstraints_Glasspaint()
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
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
        
        // 装饰圆圈2（左中）
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 100
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(100)
            make.left.equalToSuperview().offset(-80)
            make.width.height.equalTo(200)
        }
        
        // 添加旋转动画
        animateDecorationCircles_Glasspaint()
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
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 毛玻璃背景
        navContainer_Glasspaint.insertSubview(navBlurEffect_Glasspaint, at: 0)
        navBlurEffect_Glasspaint.alpha = 0
        
        // 标题容器
        let titleContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 主标题
        titleContainer_glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "💬 Messages"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Connect & Share"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 布局
        navBlurEffect_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        subtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(2)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    /// 设置推荐用户区域
    private func setupRecommendSection_Glasspaint() {
        // 头部
        recommendContainer_Glasspaint.addSubview(recommendHeaderView_Glasspaint)
        
        // 图标容器
        recommendHeaderView_Glasspaint.addSubview(recommendIconContainer_Glasspaint)
        recommendIconContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15)
        recommendIconContainer_Glasspaint.layer.cornerRadius = 20
        recommendIconContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        recommendIconContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        recommendIconContainer_Glasspaint.layer.shadowRadius = 6
        recommendIconContainer_Glasspaint.layer.shadowOpacity = 0.15
        
        // 图标
        recommendIconContainer_Glasspaint.addSubview(recommendIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        recommendIconView_Glasspaint.image = UIImage(systemName: "sparkles", withConfiguration: iconConfig_glasspaint)
        recommendIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        recommendIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        recommendHeaderView_Glasspaint.addSubview(recommendTitleLabel_Glasspaint)
        recommendTitleLabel_Glasspaint.text = "Discover Artists"
        recommendTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 20, weight: .black)
        recommendTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        recommendHeaderView_Glasspaint.addSubview(recommendSubtitleLabel_Glasspaint)
        recommendSubtitleLabel_Glasspaint.text = "Connect with talented creators"
        recommendSubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        recommendSubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 刷新按钮
        recommendHeaderView_Glasspaint.addSubview(recommendRefreshButton_Glasspaint)
        let refreshConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        recommendRefreshButton_Glasspaint.setImage(UIImage(systemName: "arrow.clockwise.circle.fill", withConfiguration: refreshConfig_glasspaint), for: .normal)
        recommendRefreshButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        recommendRefreshButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        recommendRefreshButton_Glasspaint.layer.cornerRadius = 20
        recommendRefreshButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        recommendRefreshButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        recommendRefreshButton_Glasspaint.layer.shadowRadius = 6
        recommendRefreshButton_Glasspaint.layer.shadowOpacity = 0.2
        recommendRefreshButton_Glasspaint.addTarget(self, action: #selector(handleRefreshRecommend_Glasspaint), for: .touchUpInside)
        
        // CollectionView
        recommendContainer_Glasspaint.addSubview(recommendCollectionView_Glasspaint)
        recommendCollectionView_Glasspaint.backgroundColor = .clear
        recommendCollectionView_Glasspaint.showsHorizontalScrollIndicator = false
        recommendCollectionView_Glasspaint.delegate = self
        recommendCollectionView_Glasspaint.dataSource = self
        recommendCollectionView_Glasspaint.register(RecommendUserCell_Glasspaint.self, forCellWithReuseIdentifier: "RecommendUserCell")
    }
    
    /// 设置Chat分隔标题
    private func setupChatSectionHeader_Glasspaint() {
        // 图标
        chatSectionHeader_Glasspaint.addSubview(chatSectionIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        chatSectionIconView_Glasspaint.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: iconConfig_glasspaint)
        chatSectionIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        chatSectionIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        chatSectionHeader_Glasspaint.addSubview(chatSectionTitleLabel_Glasspaint)
        chatSectionTitleLabel_Glasspaint.text = "Chats"
        chatSectionTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 26, weight: .black)
        chatSectionTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 徽章
        chatSectionHeader_Glasspaint.addSubview(chatBadgeLabel_Glasspaint)
        chatBadgeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        chatBadgeLabel_Glasspaint.textColor = .white
        chatBadgeLabel_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        chatBadgeLabel_Glasspaint.textAlignment = .center
        chatBadgeLabel_Glasspaint.layer.cornerRadius = 12
        chatBadgeLabel_Glasspaint.layer.masksToBounds = true
    }
    
    /// 设置聊天列表区域
    private func setupChatSection_Glasspaint() {
        // TableView
        chatContainer_Glasspaint.addSubview(chatTableView_Glasspaint)
        chatTableView_Glasspaint.delegate = self
        chatTableView_Glasspaint.dataSource = self
        chatTableView_Glasspaint.backgroundColor = .clear
        chatTableView_Glasspaint.separatorStyle = .none
        chatTableView_Glasspaint.register(ChatUserCell_Glasspaint.self, forCellReuseIdentifier: "ChatUserCell")
        chatTableView_Glasspaint.isScrollEnabled = false
    }
    
    /// 设置空状态视图
    private func setupEmptyState_Glasspaint() {
        emptyStateView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        emptyStateView_Glasspaint.layer.cornerRadius = 24
        emptyStateView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        emptyStateView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        emptyStateView_Glasspaint.layer.shadowRadius = 12
        emptyStateView_Glasspaint.layer.shadowOpacity = 0.1
        emptyStateView_Glasspaint.isHidden = true
        
        // 图标
        emptyStateView_Glasspaint.addSubview(emptyIconView_Glasspaint)
        let iconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 70, weight: .light)
        emptyIconView_Glasspaint.image = UIImage(systemName: "message.badge.circle", withConfiguration: iconConfig_glasspaint)
        emptyIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.6)
        emptyIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        emptyStateView_Glasspaint.addSubview(emptyTitleLabel_Glasspaint)
        emptyTitleLabel_Glasspaint.text = "No Messages Yet"
        emptyTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        emptyTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        emptyTitleLabel_Glasspaint.textAlignment = .center
        
        // 副标题
        emptyStateView_Glasspaint.addSubview(emptySubtitleLabel_Glasspaint)
        emptySubtitleLabel_Glasspaint.text = "Start a conversation with recommended artists\nand share your creative journey"
        emptySubtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        emptySubtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        emptySubtitleLabel_Glasspaint.textAlignment = .center
        emptySubtitleLabel_Glasspaint.numberOfLines = 0
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 导航栏
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        
        navBlurEffect_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 推荐用户区域
        recommendContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        recommendHeaderView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        recommendIconContainer_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        recommendIconView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        recommendTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(recommendIconContainer_Glasspaint.snp.right).offset(12)
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(recommendRefreshButton_Glasspaint.snp.left).offset(-12)
        }
        
        recommendSubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(recommendTitleLabel_Glasspaint)
            make.top.equalTo(recommendTitleLabel_Glasspaint.snp.bottom).offset(2)
            make.right.equalTo(recommendRefreshButton_Glasspaint.snp.left).offset(-12)
        }
        
        recommendRefreshButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        recommendCollectionView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(recommendHeaderView_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(180)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // Chat分隔标题
        chatSectionHeader_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(recommendContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
        
        chatSectionIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(28)
        }
        
        chatSectionTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(chatSectionIconView_Glasspaint.snp.right).offset(10)
            make.centerY.equalTo(chatSectionIconView_Glasspaint)
        }
        
        chatBadgeLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(chatSectionTitleLabel_Glasspaint.snp.right).offset(12)
            make.centerY.equalTo(chatSectionTitleLabel_Glasspaint)
            make.width.greaterThanOrEqualTo(36)
            make.height.equalTo(24)
        }
        
        // 聊天列表区域
        chatContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(chatSectionHeader_Glasspaint.snp.bottom)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        chatTableView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(0)
        }
        
        // 空状态视图
        emptyStateView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(chatSectionHeader_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(240)
        }
        
        emptyIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(80)
        }
        
        emptyTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        emptySubtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        // 加载推荐用户（随机选择3-5个用户）
        let allUsers_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        // 排除当前用户
        let filteredUsers_glasspaint = allUsers_glasspaint.filter { user_glasspaint in
            user_glasspaint.userId_Glasspaint != currentUser_glasspaint.userId_Glasspaint
        }
        
        // 随机选择3-5个用户
        let count_glasspaint = min(5, filteredUsers_glasspaint.count)
        recommendUsers_Glasspaint = Array(filteredUsers_glasspaint.shuffled().prefix(count_glasspaint))
        
        // 加载聊天用户
        chatUsers_Glasspaint = MessageViewModel_Glasspaint.shared_Glasspaint.getChatUsers_Glasspaint()
        
        // 更新UI
        updateUI_Glasspaint()
    }
    
    /// 更新UI
    private func updateUI_Glasspaint() {
        recommendCollectionView_Glasspaint.reloadData()
        chatTableView_Glasspaint.reloadData()
        
        // 更新聊天列表高度
        let chatHeight_glasspaint = CGFloat(chatUsers_Glasspaint.count) * 88
        chatTableView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(chatHeight_glasspaint)
        }
        
        // 更新徽章
        chatBadgeLabel_Glasspaint.text = "\(chatUsers_Glasspaint.count)"
        chatBadgeLabel_Glasspaint.isHidden = chatUsers_Glasspaint.isEmpty
        
        // 显示/隐藏空状态
        let isEmpty_glasspaint = chatUsers_Glasspaint.isEmpty
        chatContainer_Glasspaint.isHidden = isEmpty_glasspaint
        emptyStateView_Glasspaint.isHidden = !isEmpty_glasspaint
    }
    
    /// 设置通知
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Glasspaint),
            name: MessageViewModel_Glasspaint.messageStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 处理消息状态变化
    @objc private func handleMessageStateChange_Glasspaint() {
        loadData_Glasspaint()
    }
    
    /// 刷新推荐
    @objc private func handleRefreshRecommend_Glasspaint() {
        // 旋转动画
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.recommendRefreshButton_Glasspaint.transform = CGAffineTransform(rotationAngle: .pi)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.recommendRefreshButton_Glasspaint.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
        }
        
        // 重新加载推荐用户
        let allUsers_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        
        let filteredUsers_glasspaint = allUsers_glasspaint.filter { user_glasspaint in
            user_glasspaint.userId_Glasspaint != currentUser_glasspaint.userId_Glasspaint
        }
        
        let count_glasspaint = min(5, filteredUsers_glasspaint.count)
        recommendUsers_Glasspaint = Array(filteredUsers_glasspaint.shuffled().prefix(count_glasspaint))
        
        recommendCollectionView_Glasspaint.reloadData()
    }
    
    /// 处理关注用户
    /// 参数：
    /// - user_glasspaint: 用户数据
    /// - cell: 对应的单元格
    private func handleFollowUser_Glasspaint(_ user_glasspaint: PrewUserModel_Glasspaint, cell: RecommendUserCell_Glasspaint?) {
        // 调用关注逻辑
        UserViewModel_Glasspaint.shared_Glasspaint.followUser_Glasspaint(user_glasspaint: user_glasspaint)
        
        // 只更新当前单元格的关注状态
        if let cell_glasspaint = cell {
            let isFollowing_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.isFollowing_Glasspaint(user_glasspaint: user_glasspaint)
            cell_glasspaint.updateFollowState_Glasspaint(isFollowing: isFollowing_glasspaint)
        }
    }
    
    /// 打开聊天页面
    /// 参数：
    /// - user_glasspaint: 聊天用户
    private func openChat_Glasspaint(with user_glasspaint: PrewUserModel_Glasspaint) {
        let chatVC_glasspaint = MessageUser_Glasspaint()
        chatVC_glasspaint.userModel_Glasspaint = user_glasspaint
        chatVC_glasspaint.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC_glasspaint, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension MessageList_Glasspaint: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 根据滚动位置调整导航栏毛玻璃效果
        let offset_glasspaint = scrollView.contentOffset.y
        let threshold_glasspaint: CGFloat = 60
        
        if offset_glasspaint > threshold_glasspaint {
            let alpha_glasspaint = min((offset_glasspaint - threshold_glasspaint) / 40, 1.0)
            navBlurEffect_Glasspaint.alpha = alpha_glasspaint
        } else {
            navBlurEffect_Glasspaint.alpha = 0
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource

extension MessageList_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendUsers_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendUserCell", for: indexPath) as! RecommendUserCell_Glasspaint
        let user_glasspaint = recommendUsers_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with: user_glasspaint)
        
        // 设置关注回调
        cell_glasspaint.onFollowTap_Glasspaint = { [weak self, weak cell_glasspaint] user_glasspaint in
            self?.handleFollowUser_Glasspaint(user_glasspaint, cell: cell_glasspaint)
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user_glasspaint = recommendUsers_Glasspaint[indexPath.item]
        
        // 选中动画
        if let cell_glasspaint = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell_glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell_glasspaint.transform = .identity
                }
            }
        }
        
        openChat_Glasspaint(with: user_glasspaint)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension MessageList_Glasspaint: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Glasspaint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_glasspaint = tableView.dequeueReusableCell(withIdentifier: "ChatUserCell", for: indexPath) as! ChatUserCell_Glasspaint
        let user_glasspaint = chatUsers_Glasspaint[indexPath.row]
        
        // 获取最后一条消息
        if let userId_glasspaint = user_glasspaint.userId_Glasspaint {
            let lastMessage_glasspaint = MessageViewModel_Glasspaint.shared_Glasspaint.getLastMessageWithUser_Glasspaint(userId_glasspaint: userId_glasspaint)
            cell_glasspaint.configure_Glasspaint(with: user_glasspaint, lastMessage: lastMessage_glasspaint)
        }
        
        return cell_glasspaint
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user_glasspaint = chatUsers_Glasspaint[indexPath.row]
        openChat_Glasspaint(with: user_glasspaint)
    }
}

// MARK: - 推荐用户Cell

/// 推荐用户Cell
/// 设计：渐变卡片、阴影、圆角头像、等级徽章
class RecommendUserCell_Glasspaint: UICollectionViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let gradientLayer_Glasspaint = CAGradientLayer()
    private let avatarContainer_Glasspaint = UIView()
    private let avatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let nameLabel_Glasspaint = UILabel()
    private let followButton_Glasspaint = UIButton(type: .system)
    
    var onFollowTap_Glasspaint: ((PrewUserModel_Glasspaint) -> Void)?
    private var currentUser_Glasspaint: PrewUserModel_Glasspaint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Glasspaint.frame = containerView_Glasspaint.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentUser_Glasspaint = nil
        onFollowTap_Glasspaint = nil
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        contentView.addSubview(containerView_Glasspaint)
        containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        containerView_Glasspaint.layer.cornerRadius = 20
        containerView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        containerView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView_Glasspaint.layer.shadowRadius = 10
        containerView_Glasspaint.layer.shadowOpacity = 0.15
        
        // 渐变背景
        gradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_Glasspaint.cornerRadius = 20
        containerView_Glasspaint.layer.insertSublayer(gradientLayer_Glasspaint, at: 0)
        
        // 头像容器
        containerView_Glasspaint.addSubview(avatarContainer_Glasspaint)
        avatarContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15)
        avatarContainer_Glasspaint.layer.cornerRadius = 36
        
        // 头像
        avatarContainer_Glasspaint.addSubview(avatarView_Glasspaint)
        avatarView_Glasspaint.layer.borderWidth = 2
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 用户名
        containerView_Glasspaint.addSubview(nameLabel_Glasspaint)
        nameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        nameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        nameLabel_Glasspaint.textAlignment = .center
        nameLabel_Glasspaint.numberOfLines = 1
        
        // 关注按钮
        containerView_Glasspaint.addSubview(followButton_Glasspaint)
        followButton_Glasspaint.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        followButton_Glasspaint.layer.cornerRadius = 12
        followButton_Glasspaint.layer.borderWidth = 1.5
        followButton_Glasspaint.addTarget(self, action: #selector(handleFollowTap_Glasspaint), for: .touchUpInside)
        updateFollowButtonState_Glasspaint(isFollowing: false)
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarContainer_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(72)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        nameLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarContainer_Glasspaint.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }
        
        followButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Glasspaint.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(70)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    /// 更新关注按钮状态
    /// 参数：
    /// - isFollowing: 是否已关注
    private func updateFollowButtonState_Glasspaint(isFollowing: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            if isFollowing {
                self.followButton_Glasspaint.setTitle("Followed", for: .normal)
                self.followButton_Glasspaint.setTitleColor(ColorConfig_Glasspaint.primaryGradientStart_Glasspaint, for: .normal)
                self.followButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
                self.followButton_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
            } else {
                self.followButton_Glasspaint.setTitle("Follow", for: .normal)
                self.followButton_Glasspaint.setTitleColor(.white, for: .normal)
                self.followButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
                self.followButton_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
            }
        })
    }
    
    /// 处理关注按钮点击
    @objc private func handleFollowTap_Glasspaint() {
        guard let user_glasspaint = currentUser_Glasspaint else { return }
        
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 动画效果
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.followButton_Glasspaint.transform = .identity
            }
        }
        
        onFollowTap_Glasspaint?(user_glasspaint)
    }
    
    /// 配置Cell
    /// 参数：
    /// - user_glasspaint: 用户数据
    func configure_Glasspaint(with user_glasspaint: PrewUserModel_Glasspaint) {
        currentUser_Glasspaint = user_glasspaint
        nameLabel_Glasspaint.text = user_glasspaint.userName_Glasspaint
        
        // 更新关注状态
        let isFollowing_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.isFollowing_Glasspaint(user_glasspaint: user_glasspaint)
        updateFollowButtonState_Glasspaint(isFollowing: isFollowing_glasspaint)
        
        // 配置头像
        avatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: user_glasspaint.userId_Glasspaint!)
    }
    
    /// 更新关注状态（公开方法）
    /// 参数：
    /// - isFollowing: 是否已关注
    func updateFollowState_Glasspaint(isFollowing: Bool) {
        updateFollowButtonState_Glasspaint(isFollowing: isFollowing)
    }
}

// MARK: - 聊天用户Cell

/// 聊天用户Cell
/// 设计：现代化卡片、左侧色块装饰、渐变元素
class ChatUserCell_Glasspaint: UITableViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let colorAccent_Glasspaint = UIView()
    private let avatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let nameLabel_Glasspaint = UILabel()
    private let lastMessageLabel_Glasspaint = UILabel()
    private let timeLabel_Glasspaint = UILabel()
    private let unreadBadge_Glasspaint = UILabel()
    private let arrowIconView_Glasspaint = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView_Glasspaint)
        containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        containerView_Glasspaint.layer.cornerRadius = 18
        containerView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        containerView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView_Glasspaint.layer.shadowRadius = 8
        containerView_Glasspaint.layer.shadowOpacity = 0.08
        
        // 左侧色块装饰
        containerView_Glasspaint.addSubview(colorAccent_Glasspaint)
        colorAccent_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        colorAccent_Glasspaint.layer.cornerRadius = 18
        colorAccent_Glasspaint.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        // 头像
        containerView_Glasspaint.addSubview(avatarView_Glasspaint)
        avatarView_Glasspaint.layer.borderWidth = 2
        avatarView_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor
        
        // 用户名
        containerView_Glasspaint.addSubview(nameLabel_Glasspaint)
        nameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        nameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 最后消息
        containerView_Glasspaint.addSubview(lastMessageLabel_Glasspaint)
        lastMessageLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lastMessageLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        lastMessageLabel_Glasspaint.numberOfLines = 1
        
        // 时间
        containerView_Glasspaint.addSubview(timeLabel_Glasspaint)
        timeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 箭头图标
        containerView_Glasspaint.addSubview(arrowIconView_Glasspaint)
        let arrowConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        arrowIconView_Glasspaint.image = UIImage(systemName: "chevron.right", withConfiguration: arrowConfig_glasspaint)
        arrowIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.5)
        arrowIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 未读徽章
        containerView_Glasspaint.addSubview(unreadBadge_Glasspaint)
        unreadBadge_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        unreadBadge_Glasspaint.textColor = .white
        unreadBadge_Glasspaint.backgroundColor = UIColor.systemRed
        unreadBadge_Glasspaint.textAlignment = .center
        unreadBadge_Glasspaint.layer.cornerRadius = 10
        unreadBadge_Glasspaint.layer.masksToBounds = true
        unreadBadge_Glasspaint.isHidden = true
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
        }
        
        colorAccent_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(4)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        nameLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Glasspaint.snp.right).offset(14)
            make.top.equalTo(avatarView_Glasspaint).offset(6)
            make.right.equalTo(timeLabel_Glasspaint.snp.left).offset(-8)
        }
        
        lastMessageLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Glasspaint)
            make.top.equalTo(nameLabel_Glasspaint.snp.bottom).offset(6)
            make.right.equalTo(arrowIconView_Glasspaint.snp.left).offset(-8)
        }
        
        timeLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Glasspaint)
            make.right.equalToSuperview().offset(-18)
        }
        
        arrowIconView_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        unreadBadge_Glasspaint.snp.makeConstraints { make in
            make.centerY.equalTo(lastMessageLabel_Glasspaint)
            make.right.equalTo(arrowIconView_Glasspaint.snp.left).offset(-12)
            make.width.greaterThanOrEqualTo(20)
            make.height.equalTo(20)
        }
    }
    
    /// 配置Cell
    /// 参数：
    /// - user_glasspaint: 用户数据
    /// - lastMessage: 最后一条消息
    func configure_Glasspaint(with user_glasspaint: PrewUserModel_Glasspaint, lastMessage: MessageModel_Glasspaint?) {
        nameLabel_Glasspaint.text = user_glasspaint.userName_Glasspaint
        
        if let message_glasspaint = lastMessage {
            lastMessageLabel_Glasspaint.text = message_glasspaint.content_Glasspaint ?? "..."
            timeLabel_Glasspaint.text = message_glasspaint.time_Glasspaint ?? ""
        } else {
            lastMessageLabel_Glasspaint.text = "Start a conversation..."
            timeLabel_Glasspaint.text = ""
        }
        
        // 配置头像
        avatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: user_glasspaint.userId_Glasspaint!)
    }
}
