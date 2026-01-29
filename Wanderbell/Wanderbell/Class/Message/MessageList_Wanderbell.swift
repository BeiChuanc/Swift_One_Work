import Foundation
import UIKit
import SnapKit

// MARK: 消息列表

/// 消息列表页面
/// 功能：展示推荐用户和聊天列表
/// 设计：现代化、卡片式、丰富的视觉元素
class MessageList_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Messages",
            subtitle_wanderbell: "Connect with the community",
            iconName_wanderbell: "bubble.left.and.bubble.right.fill",
            iconColor_wanderbell: UIColor(hexstring_Wanderbell: "#FC8181")
        )
    }()
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// 推荐用户区域
    private let recommendSection_Wanderbell = RecommendUsersSection_Wanderbell()
    
    /// 聊天列表
    private let chatListView_Wanderbell = ChatListView_Wanderbell()
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // 刷新数据
        recommendSection_Wanderbell.loadData_Wanderbell()
        chatListView_Wanderbell.loadData_Wanderbell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        
        // 启动标题动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        // 设置消息页渐变背景
        view.addMessageBackgroundGradient_Wanderbell()
        
        view.addSubview(pageTitleView_Wanderbell)
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        contentView_Wanderbell.addSubview(recommendSection_Wanderbell)
        contentView_Wanderbell.addSubview(chatListView_Wanderbell)
    }
    
    private func setupConstraints_Wanderbell() {
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(90)
        }
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        recommendSection_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(240)  // 增加高度以容纳更多内容
        }
        
        chatListView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(recommendSection_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
    }
}

// MARK: - 推荐用户区域

/// 推荐用户区域
/// 功能：横向滚动展示推荐用户卡片
class RecommendUsersSection_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Recommended"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "person.2.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.secondaryGradientStart_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsHorizontalScrollIndicator = false
        return scrollView_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .horizontal
        stack_wanderbell.spacing = 16
        return stack_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadData_Wanderbell()
        observeUserState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(iconView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(stackView_Wanderbell)
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconView_Wanderbell)
        }
        
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.bottom.equalToSuperview()
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
    }
    
    func loadData_Wanderbell() {
        stackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 获取推荐用户（排除当前登录用户）
        let allUsers_wanderbell = LocalData_Wanderbell.shared_Wanderbell.userList_Wanderbell
        let currentUserId_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell().userId_Wanderbell ?? 0
        let recommendedUsers_wanderbell = allUsers_wanderbell.filter { $0.userId_Wanderbell != currentUserId_wanderbell }
        
        for user_wanderbell in recommendedUsers_wanderbell {
            let card_wanderbell = RecommendUserCard_Wanderbell()
            card_wanderbell.configure_Wanderbell(user_wanderbell: user_wanderbell)
            stackView_Wanderbell.addArrangedSubview(card_wanderbell)
            
            card_wanderbell.snp.makeConstraints { make in
                make.width.equalTo(140)
            }
        }
    }
    
    private func observeUserState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: UserViewModel_Wanderbell.userStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    @objc private func handleStateChange_Wanderbell() {
        loadData_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - 聊天列表视图

/// 聊天列表视图
/// 功能：展示有聊天记录的用户列表
class ChatListView_Wanderbell: UIView {
    
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Recent Chats"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    private let iconView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.image = UIImage(systemName: "message.fill")
        imageView_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientEnd_Wanderbell
        imageView_wanderbell.contentMode = .scaleAspectFit
        return imageView_wanderbell
    }()
    
    private let stackView_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 12
        return stack_wanderbell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Wanderbell()
        loadData_Wanderbell()
        observeMessageState_Wanderbell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI_Wanderbell() {
        addSubview(iconView_Wanderbell)
        addSubview(titleLabel_Wanderbell)
        addSubview(stackView_Wanderbell)
        
        iconView_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(iconView_Wanderbell.snp.right).offset(12)
            make.centerY.equalTo(iconView_Wanderbell)
        }
        
        stackView_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func loadData_Wanderbell() {
        stackView_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 获取有聊天记录的用户
        let chatUsers_wanderbell = MessageViewModel_Wanderbell.shared_Wanderbell.getChatUsers_Wanderbell()
        
        if chatUsers_wanderbell.isEmpty {
            // 显示空状态
            let emptyView_wanderbell = createEmptyView_Wanderbell()
            stackView_Wanderbell.addArrangedSubview(emptyView_wanderbell)
        } else {
            for user_wanderbell in chatUsers_wanderbell {
                let cell_wanderbell = ChatCell_Wanderbell()
                cell_wanderbell.configure_Wanderbell(user_wanderbell: user_wanderbell)
                stackView_Wanderbell.addArrangedSubview(cell_wanderbell)
            }
        }
    }
    
    private func createEmptyView_Wanderbell() -> UIView {
        let container_wanderbell = UIView()
        container_wanderbell.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        container_wanderbell.layer.cornerRadius = 20
        
        let iconView_wanderbell = UIImageView()
        iconView_wanderbell.image = UIImage(systemName: "bubble.left.and.bubble.right")
        iconView_wanderbell.tintColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
        iconView_wanderbell.contentMode = .scaleAspectFit
        
        let label_wanderbell = UILabel()
        label_wanderbell.text = "No conversations yet\nStart chatting with recommended users!"
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.textAlignment = .center
        label_wanderbell.numberOfLines = 0
        
        container_wanderbell.addSubview(iconView_wanderbell)
        container_wanderbell.addSubview(label_wanderbell)
        
        iconView_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(60)
        }
        
        label_wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconView_wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-40)
        }
        
        container_wanderbell.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
        
        return container_wanderbell
    }
    
    private func observeMessageState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Wanderbell),
            name: MessageViewModel_Wanderbell.messageStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    @objc private func handleStateChange_Wanderbell() {
        loadData_Wanderbell()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
