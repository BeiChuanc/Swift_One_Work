import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面
/// 核心作用：展示顶部描述、推荐用户横向列表与已有聊天列表
/// 设计思路：通过艺术化表头卡片、横向推荐轨道与沉浸式会话卡片提升页面视觉密度
class MessageList_Epoch: UIViewController {

    /// 会话用户列表
    private var chatUsers_Epoch: [PrewUserModel_Epoch] = []

    /// 推荐用户列表
    private var recommendedUsers_Epoch: [PrewUserModel_Epoch] = []

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 列表
    private let tableView_Epoch: UITableView = {
        let tableView_Epoch = UITableView(frame: .zero, style: .plain)
        tableView_Epoch.backgroundColor = .clear
        tableView_Epoch.separatorStyle = .none
        tableView_Epoch.rowHeight = UITableView.automaticDimension
        tableView_Epoch.estimatedRowHeight = 126
        tableView_Epoch.showsVerticalScrollIndicator = false
        return tableView_Epoch
    }()

    /// 表头容器
    private let headerContainerView_Epoch = UIView()

    // MARK: - 头部卡片元素

    /// 顶部描述卡片
    private let heroCardView_Epoch = SurfaceCardView_Epoch()

    /// 头部右上装饰光斑
    private let heroGlowView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.18)
        view_Epoch.layer.cornerRadius = 56
        view_Epoch.isUserInteractionEnabled = false
        return view_Epoch
    }()

    /// 头部左下装饰光斑
    private let heroGlowView2_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.16)
        view_Epoch.layer.cornerRadius = 48
        view_Epoch.isUserInteractionEnabled = false
        return view_Epoch
    }()

    /// 头部图标背景
    private let heroIconBgView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.layer.cornerRadius = 22
        return view_Epoch
    }()

    /// 头部图标
    private let heroIconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        imageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 顶部标签
    private let heroBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.text = "MESSAGES"
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textOnDark_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.layer.cornerRadius = 12
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 10
        label_Epoch.verticalInset_Epoch = 6
        return label_Epoch
    }()

    /// 顶部标题
    private let heroTitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Keep the warm circle close"
        label_Epoch.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 顶部副标题
    private let heroSubtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Browse creators worth talking to, then jump into the conversations you already started."
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    // MARK: - 推荐区元素

    /// 推荐区分组头
    private let recommendationHeaderView_Epoch = MessageSectionHeaderView_Epoch()

    /// 推荐用户横向列表
    private lazy var recommendationCollectionView_Epoch: UICollectionView = {
        let layout_Epoch = UICollectionViewFlowLayout()
        layout_Epoch.scrollDirection = .horizontal
        layout_Epoch.minimumLineSpacing = 12
        layout_Epoch.minimumInteritemSpacing = 0
        let collectionView_Epoch = UICollectionView(frame: .zero, collectionViewLayout: layout_Epoch)
        collectionView_Epoch.backgroundColor = .clear
        collectionView_Epoch.showsHorizontalScrollIndicator = false
        return collectionView_Epoch
    }()

    // MARK: - 生命周期

    /// 页面即将显示时刷新数据
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Epoch()
    }

    /// 页面加载完成后初始化界面
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    /// 布局完成后同步表头高度
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout_Epoch()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 界面搭建

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(tableView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupHeaderView_Epoch()

        tableView_Epoch.register(MessageListCell_Epoch.self, forCellReuseIdentifier: "MessageListCell_Epoch")
        tableView_Epoch.register(MessageEmptyCell_Epoch.self, forCellReuseIdentifier: "MessageEmptyCell_Epoch")
        recommendationCollectionView_Epoch.register(
            MessageRecommendationCell_Epoch.self,
            forCellWithReuseIdentifier: "MessageRecommendationCell_Epoch"
        )

        tableView_Epoch.dataSource = self
        tableView_Epoch.delegate = self
        recommendationCollectionView_Epoch.dataSource = self
        recommendationCollectionView_Epoch.delegate = self
        tableView_Epoch.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }

    /// 配置表头视图
    private func setupHeaderView_Epoch() {
        tableView_Epoch.tableHeaderView = headerContainerView_Epoch
        headerContainerView_Epoch.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 360)

        headerContainerView_Epoch.addSubview(heroCardView_Epoch)
        headerContainerView_Epoch.addSubview(recommendationHeaderView_Epoch)
        headerContainerView_Epoch.addSubview(recommendationCollectionView_Epoch)

        // 头部卡片内部装饰层
        heroCardView_Epoch.clipsToBounds = true
        heroCardView_Epoch.addSubview(heroGlowView_Epoch)
        heroCardView_Epoch.addSubview(heroGlowView2_Epoch)
        heroCardView_Epoch.addSubview(heroIconBgView_Epoch)
        heroIconBgView_Epoch.addSubview(heroIconImageView_Epoch)

        // 头部图标背景渐变色
        heroIconBgView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)

        // 文本堆叠
        let badgeAndIconRow_epoch = UIStackView(arrangedSubviews: [heroBadgeLabel_Epoch, UIView()])
        badgeAndIconRow_epoch.axis = .horizontal
        badgeAndIconRow_epoch.spacing = 10

        let textStack_epoch = UIStackView(arrangedSubviews: [
            badgeAndIconRow_epoch,
            heroTitleLabel_Epoch,
            heroSubtitleLabel_Epoch
        ])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 10
        textStack_epoch.alignment = .leading
        heroCardView_Epoch.addSubview(textStack_epoch)

        recommendationHeaderView_Epoch.configure_Epoch(
            iconName_Epoch: "person.2.fill",
            badgeText_Epoch: "SUGGESTED",
            title_Epoch: "People to connect with",
            subtitle_Epoch: "Tap any profile to open the creator center."
        )

        // MARK: 约束

        heroCardView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.safeAreaInsets.top + 18)
            make.left.right.equalToSuperview().inset(20)
        }

        heroGlowView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-28)
            make.right.equalToSuperview().offset(28)
            make.width.height.equalTo(112)
        }

        heroGlowView2_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(-28)
            make.width.height.equalTo(96)
        }

        heroIconBgView_Epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }

        heroIconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().offset(-22)
            make.right.lessThanOrEqualTo(heroIconBgView_Epoch.snp.left).offset(-12)
        }

        recommendationHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroCardView_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        recommendationCollectionView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(recommendationHeaderView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(128)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    /// 更新表头自适应高度
    private func updateTableHeaderLayout_Epoch() {
        guard let headerView_epoch = tableView_Epoch.tableHeaderView else { return }
        let targetSize_epoch = CGSize(
            width: tableView_Epoch.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fittingHeight_epoch = headerView_epoch.systemLayoutSizeFitting(
            targetSize_epoch,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        guard abs(headerView_epoch.frame.height - fittingHeight_epoch) > 1 else { return }
        headerView_epoch.frame.size.height = fittingHeight_epoch
        tableView_Epoch.tableHeaderView = headerView_epoch
    }

    // MARK: - 通知

    /// 注册通知
    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: MessageViewModel_Epoch.messageStateDidChangeNotification_Epoch,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    // MARK: - 数据

    /// 刷新数据
    private func reloadData_Epoch() {
        chatUsers_Epoch = MessageViewModel_Epoch.shared_Epoch.getChatUsers_Epoch()
        recommendedUsers_Epoch = buildRecommendedUsers_Epoch()
        recommendationCollectionView_Epoch.reloadData()
        tableView_Epoch.reloadData()
        updateTableHeaderLayout_Epoch()
    }

    /// 构建推荐用户列表
    /// - Returns: 推荐用户数组（排除自身和已聊用户，最多8条）
    private func buildRecommendedUsers_Epoch() -> [PrewUserModel_Epoch] {
        let currentUserId_epoch = UserViewModel_Epoch.shared_Epoch.getCurrentUser_Epoch().userId_Epoch
        let chatUserIds_epoch = Set(chatUsers_Epoch.compactMap { $0.userId_Epoch })

        let ranked_epoch = UserViewModel_Epoch.shared_Epoch.getUserFollowRanking_Epoch().filter { user_epoch in
            guard let uid_epoch = user_epoch.userId_Epoch else { return false }
            return uid_epoch != currentUserId_epoch && !chatUserIds_epoch.contains(uid_epoch)
        }

        if !ranked_epoch.isEmpty {
            return Array(ranked_epoch.prefix(8))
        }

        return Array(
            UserViewModel_Epoch.shared_Epoch.getUserFollowRanking_Epoch().filter {
                $0.userId_Epoch != currentUserId_epoch
            }.prefix(8)
        )
    }

    /// 处理状态变化通知
    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }
}

// MARK: - UITableViewDataSource

extension MessageList_Epoch: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(chatUsers_Epoch.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if chatUsers_Epoch.isEmpty {
            guard let cell_epoch = tableView.dequeueReusableCell(
                withIdentifier: "MessageEmptyCell_Epoch",
                for: indexPath
            ) as? MessageEmptyCell_Epoch else { return UITableViewCell() }
            cell_epoch.configure_Epoch()
            return cell_epoch
        }

        guard let cell_epoch = tableView.dequeueReusableCell(
            withIdentifier: "MessageListCell_Epoch",
            for: indexPath
        ) as? MessageListCell_Epoch else { return UITableViewCell() }

        let user_epoch = chatUsers_Epoch[indexPath.row]
        let lastMessage_epoch = MessageViewModel_Epoch.shared_Epoch.getLastMessageWithUser_Epoch(
            userId_epoch: user_epoch.userId_Epoch ?? 0
        )
        cell_epoch.configure_Epoch(user_epoch: user_epoch, lastMessage_epoch: lastMessage_epoch)
        return cell_epoch
    }
}

// MARK: - UITableViewDelegate

extension MessageList_Epoch: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return chatUsers_Epoch.isEmpty ? 280 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header_epoch = MessageChatSectionHeaderView_Epoch()
        header_epoch.configure_Epoch(count_Epoch: chatUsers_Epoch.count)
        return header_epoch
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !chatUsers_Epoch.isEmpty else { return }
        let user_epoch = chatUsers_Epoch[indexPath.row]
        Navigation_Epoch.toMessageUser_Epoch(with: user_epoch)
    }
}

// MARK: - UICollectionViewDataSource

extension MessageList_Epoch: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedUsers_Epoch.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_epoch = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MessageRecommendationCell_Epoch",
            for: indexPath
        ) as? MessageRecommendationCell_Epoch else { return UICollectionViewCell() }
        cell_epoch.configure_Epoch(user_epoch: recommendedUsers_Epoch[indexPath.item])
        return cell_epoch
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MessageList_Epoch: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 86, height: 118)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user_epoch = recommendedUsers_Epoch[indexPath.item]
        Navigation_Epoch.toUserInfo_Epoch(with: user_epoch)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}

// MARK: - 推荐区分组头部

/// 推荐区分组头部
/// 核心作用：展示推荐用户区的标题、图标和说明
/// 设计思路：通过图标背景、胶囊角标和双层文字提升视觉层次
private final class MessageSectionHeaderView_Epoch: UIView {

    /// 图标背景
    private let iconBgView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.layer.cornerRadius = 16
        return view_Epoch
    }()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView()
        imageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 角标
    private let badgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        label_Epoch.layer.cornerRadius = 10
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 8
        label_Epoch.verticalInset_Epoch = 4
        return label_Epoch
    }()

    /// 标题
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 副标题
    private let subtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 1
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置推荐区分组头
    /// - Parameters:
    ///   - iconName_Epoch: 图标名称
    ///   - badgeText_Epoch: 角标文案
    ///   - title_Epoch: 标题
    ///   - subtitle_Epoch: 副标题
    func configure_Epoch(
        iconName_Epoch: String,
        badgeText_Epoch: String,
        title_Epoch: String,
        subtitle_Epoch: String
    ) {
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        badgeLabel_Epoch.text = badgeText_Epoch
        titleLabel_Epoch.text = title_Epoch
        subtitleLabel_Epoch.text = subtitle_Epoch
    }

    private func setupUI_Epoch() {
        iconBgView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)

        let titleRowStack_epoch = UIStackView(arrangedSubviews: [titleLabel_Epoch, badgeLabel_Epoch, UIView()])
        titleRowStack_epoch.axis = .horizontal
        titleRowStack_epoch.spacing = 8
        titleRowStack_epoch.alignment = .center

        let textStack_epoch = UIStackView(arrangedSubviews: [titleRowStack_epoch, subtitleLabel_Epoch])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 3
        addSubview(textStack_epoch)

        iconBgView_Epoch.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.left.equalTo(iconBgView_Epoch.snp.right).offset(10)
            make.right.top.bottom.equalToSuperview()
        }
    }
}

// MARK: - 聊天区分组头部

/// 聊天区分组头部
/// 核心作用：展示消息列表分区标题与会话计数
/// 设计思路：通过左侧装饰线、图标和计数胶囊区分推荐区与会话区
private final class MessageChatSectionHeaderView_Epoch: UIView {

    /// 左侧装饰线
    private let accentLineView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.layer.cornerRadius = 2
        return view_Epoch
    }()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "tray.full.fill"))
        imageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 标题
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.text = "Recent chats"
        label_Epoch.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 计数胶囊
    private let countBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textOnDark_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.layer.cornerRadius = 12
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 10
        label_Epoch.verticalInset_Epoch = 5
        return label_Epoch
    }()

    /// 副标题
    private let subtitleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置聊天分组头
    /// - Parameter count_Epoch: 当前会话数量
    func configure_Epoch(count_Epoch: Int) {
        if count_Epoch == 0 {
            countBadgeLabel_Epoch.text = "Empty"
            subtitleLabel_Epoch.text = "No conversations yet."
        } else {
            countBadgeLabel_Epoch.text = "\(count_Epoch)"
            subtitleLabel_Epoch.text = "Open a chat to continue the ritual."
        }
    }

    private func setupUI_Epoch() {
        // 装饰线渐变色
        let gradientLayer_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: CGRect(x: 0, y: 0, width: 4, height: 32))
        gradientLayer_epoch.cornerRadius = 2
        accentLineView_Epoch.layer.addSublayer(gradientLayer_epoch)

        addSubview(accentLineView_Epoch)
        addSubview(iconImageView_Epoch)
        addSubview(titleLabel_Epoch)
        addSubview(countBadgeLabel_Epoch)
        addSubview(subtitleLabel_Epoch)

        accentLineView_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(32)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.left.equalTo(accentLineView_Epoch.snp.right).offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(18)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Epoch.snp.right).offset(8)
            make.top.equalTo(iconImageView_Epoch)
            make.right.lessThanOrEqualTo(countBadgeLabel_Epoch.snp.left).offset(-8)
        }

        countBadgeLabel_Epoch.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel_Epoch)
            make.right.equalToSuperview().offset(-20)
        }

        subtitleLabel_Epoch.snp.makeConstraints { make in
            make.left.equalTo(iconImageView_Epoch)
            make.top.equalTo(iconImageView_Epoch.snp.bottom).offset(3)
            make.right.equalToSuperview().offset(-20)
        }
    }
}

// MARK: - 推荐用户单元格

/// 推荐用户单元格
/// 核心作用：展示推荐用户头像和名字，点击进入用户中心
/// 设计思路：去除厚重卡片，改为轻底色圆角容器，头像外圈渐变环、名字采用双行布局
private final class MessageRecommendationCell_Epoch: UICollectionViewCell {

    /// 渐变环容器（绘制渐变边框，需配合 clipsToBounds 实现圆形裁剪）
    private let ringContainerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.clipsToBounds = true
        return view_Epoch
    }()

    /// 渐变环图层
    private var ringGradientLayer_Epoch: CAGradientLayer?

    /// 头像外圈白色间隔（裁剪为圆形）
    private let avatarRingSeparatorView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view_Epoch.clipsToBounds = true
        return view_Epoch
    }()

    /// 头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 用户名字
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.textAlignment = .center
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 轻底色容器
    private let containerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.surfaceTint_Epoch
        view_Epoch.layer.cornerRadius = 22
        view_Epoch.layer.borderWidth = 1
        view_Epoch.layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
        view_Epoch.layer.shadowColor = ColorConfig_Epoch.shadowColor_Epoch.cgColor
        view_Epoch.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Epoch.layer.shadowOpacity = 0.10
        view_Epoch.layer.shadowRadius = 10
        return view_Epoch
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 渐变环尺寸跟随布局更新，同时刷新圆角使裁剪保持圆形
        ringGradientLayer_Epoch?.frame = ringContainerView_Epoch.bounds
        ringContainerView_Epoch.layer.cornerRadius = ringContainerView_Epoch.bounds.width / 2
        avatarRingSeparatorView_Epoch.layer.cornerRadius = avatarRingSeparatorView_Epoch.bounds.width / 2
    }

    private func setupUI_Epoch() {
        contentView.addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(ringContainerView_Epoch)
        ringContainerView_Epoch.addSubview(avatarRingSeparatorView_Epoch)
        avatarRingSeparatorView_Epoch.addSubview(avatarView_Epoch)
        containerView_Epoch.addSubview(nameLabel_Epoch)

        // 渐变环图层
        let gradientLayer_epoch = CAGradientLayer()
        gradientLayer_epoch.colors = [
            ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.secondaryGradientStart_Epoch.cgColor,
            ColorConfig_Epoch.accentPink_Epoch.cgColor
        ]
        gradientLayer_epoch.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_epoch.endPoint = CGPoint(x: 1, y: 1)
        ringContainerView_Epoch.layer.insertSublayer(gradientLayer_epoch, at: 0)
        ringGradientLayer_Epoch = gradientLayer_epoch

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        ringContainerView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        avatarRingSeparatorView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(54)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(ringContainerView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    /// 配置推荐用户单元格
    /// - Parameter user_epoch: 用户模型
    func configure_Epoch(user_epoch: PrewUserModel_Epoch) {
        nameLabel_Epoch.text = user_epoch.userName_Epoch
        if let userId_epoch = user_epoch.userId_Epoch {
            avatarView_Epoch.configure_Epoch(userId_Epoch: userId_epoch)
        }
    }
}

// MARK: - 会话单元格

/// 会话单元格
/// 核心作用：展示会话用户头像、名字、简介、最后一条消息与时间
/// 设计思路：通过渐变左装饰线、图标消息预览和右侧时间胶囊丰富卡片视觉层次
private final class MessageListCell_Epoch: UITableViewCell {

    /// 内容卡片
    private let cardView_Epoch = SurfaceCardView_Epoch()

    /// 左侧渐变装饰线
    private let accentLineView_Epoch = UIView()

    /// 头像容器（带渐变边框）
    private let avatarRingView_Epoch = UIView()

    /// 头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 用户名
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 用户简介
    private let introLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 1
        return label_Epoch
    }()

    /// 消息图标
    private let messageIconView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "quote.bubble"))
        imageView_Epoch.tintColor = ColorConfig_Epoch.primaryGradientStart_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 最后一条消息预览
    private let messageLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 2
        return label_Epoch
    }()

    /// 时间胶囊
    private let timeLabel_Epoch: PaddingLabel_Epoch = {
        let label_Epoch = PaddingLabel_Epoch()
        label_Epoch.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        label_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.12)
        label_Epoch.layer.cornerRadius = 11
        label_Epoch.clipsToBounds = true
        label_Epoch.horizontalInset_Epoch = 8
        label_Epoch.verticalInset_Epoch = 5
        return label_Epoch
    }()

    /// 尾部箭头
    private let arrowView_Epoch: UIImageView = {
        let imageView_Epoch = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView_Epoch.tintColor = ColorConfig_Epoch.textPlaceholder_Epoch
        imageView_Epoch.contentMode = .scaleAspectFit
        return imageView_Epoch
    }()

    /// 渐变装饰线图层
    private var lineGradientLayer_Epoch: CAGradientLayer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 同步装饰线渐变尺寸
        lineGradientLayer_Epoch?.frame = accentLineView_Epoch.bounds
        accentLineView_Epoch.layer.cornerRadius = 2
    }

    private func setupUI_Epoch() {
        contentView.addSubview(cardView_Epoch)
        cardView_Epoch.addSubview(accentLineView_Epoch)
        cardView_Epoch.addSubview(avatarRingView_Epoch)
        avatarRingView_Epoch.addSubview(avatarView_Epoch)
        cardView_Epoch.addSubview(nameLabel_Epoch)
        cardView_Epoch.addSubview(introLabel_Epoch)
        cardView_Epoch.addSubview(messageIconView_Epoch)
        cardView_Epoch.addSubview(messageLabel_Epoch)
        cardView_Epoch.addSubview(timeLabel_Epoch)
        cardView_Epoch.addSubview(arrowView_Epoch)

        // 装饰线渐变
        let gradientLine_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
        gradientLine_epoch.cornerRadius = 2
        accentLineView_Epoch.layer.insertSublayer(gradientLine_epoch, at: 0)
        lineGradientLayer_Epoch = gradientLine_epoch

        // 头像浅色边框环，clipsToBounds 确保圆形裁剪生效
        avatarRingView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.18)
        avatarRingView_Epoch.layer.cornerRadius = 32
        avatarRingView_Epoch.clipsToBounds = true

        cardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16))
        }

        accentLineView_Epoch.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 14, bottom: 18, right: 0))
            make.width.equalTo(4)
        }

        avatarRingView_Epoch.snp.makeConstraints { make in
            make.left.equalTo(accentLineView_Epoch.snp.right).offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }

        timeLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-16)
        }

        arrowView_Epoch.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-18)
            make.width.equalTo(10)
            make.height.equalTo(14)
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalTo(avatarRingView_Epoch.snp.right).offset(14)
            make.right.lessThanOrEqualTo(timeLabel_Epoch.snp.left).offset(-8)
        }

        introLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(3)
            make.left.equalTo(nameLabel_Epoch)
            make.right.equalToSuperview().offset(-16)
        }

        messageIconView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Epoch.snp.bottom).offset(10)
            make.left.equalTo(nameLabel_Epoch)
            make.width.height.equalTo(14)
        }

        messageLabel_Epoch.snp.makeConstraints { make in
            make.centerY.equalTo(messageIconView_Epoch)
            make.left.equalTo(messageIconView_Epoch.snp.right).offset(6)
            make.right.equalTo(arrowView_Epoch.snp.left).offset(-10)
            make.bottom.lessThanOrEqualToSuperview().offset(-18)
        }
    }

    /// 配置会话单元格
    /// - Parameters:
    ///   - user_epoch: 用户模型
    ///   - lastMessage_epoch: 最后一条消息
    func configure_Epoch(user_epoch: PrewUserModel_Epoch, lastMessage_epoch: MessageModel_Epoch?) {
        nameLabel_Epoch.text = user_epoch.userName_Epoch
        introLabel_Epoch.text = user_epoch.userIntroduce_Epoch
        messageLabel_Epoch.text = lastMessage_epoch?.content_Epoch ?? "Start a chat"
        timeLabel_Epoch.text = lastMessage_epoch?.time_Epoch ?? "Now"
        if let userId_epoch = user_epoch.userId_Epoch {
            avatarView_Epoch.configure_Epoch(userId_Epoch: userId_epoch)
        }
    }
}

// MARK: - 空状态单元格

/// 空状态单元格
/// 核心作用：在没有会话数据时展示消息空状态
/// 设计思路：将空状态内嵌在列表中，推荐区正常显示，不影响上方结构
private final class MessageEmptyCell_Epoch: UITableViewCell {

    /// 空状态视图
    private let emptyStateView_Epoch = EmptyStateView_Epoch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(emptyStateView_Epoch)
        emptyStateView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 12, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置空状态
    func configure_Epoch() {
        emptyStateView_Epoch.configure_Epoch(
            iconName_Epoch: "bubble.left.and.text.bubble.right",
            title_Epoch: "No chats yet",
            subtitle_Epoch: "Open a creator profile above and start a conversation to see it here."
        )
        emptyStateView_Epoch.actionHandler_Epoch = nil
    }
}
