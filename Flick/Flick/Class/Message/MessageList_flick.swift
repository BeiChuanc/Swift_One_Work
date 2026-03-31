import Foundation
import UIKit
import SnapKit

// MARK: - 消息列表页面

/// 消息列表页面
/// 核心功能：渐变顶部 Banner + 推荐用户故事环横滑 + 有聊天记录的用户纵列表
/// 设计思路：复刻 Discover 页风格的渐变装饰顶栏，推荐区采用故事环动效，聊天行用渐变未读徽章和富文本预览
/// 关键属性：
/// - recommendedUsers_Flick: 推荐用户（本地数据排除已聊天者）
/// - chatUsers_Flick: 有聊天记录的用户（MessageViewModel 提供）
class MessageList_Flick: UIViewController {

    // MARK: - 数据

    private var recommendedUsers_Flick: [PrewUserModel_Flick] = []
    private var chatUsers_Flick: [PrewUserModel_Flick] = []

    // MARK: - 顶部渐变 Banner

    /// 顶部渐变装饰容器
    private let topBannerView_Flick: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var bannerGradientLayer_Flick: CAGradientLayer?

    /// 装饰大圆（左上）
    private let decorCircle1_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰小圆（右下）
    private let decorCircle2_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰闪光图标
    private let decorSparkle_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.18)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 装饰星形图标
    private let decorStar_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.12)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 页面主标题
    private let pageTitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "Messages"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 0.15
        label.layer.shadowRadius = 4
        return label
    }()

    /// 副标题
    private let pageSubtitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "✦  Your conversations"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withValues(alpha: 0.8)
        return label
    }()

    /// 聊天数量 Pill
    private let chatCountPill_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withValues(alpha: 0.3).cgColor
        return v
    }()

    private let chatCountLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let chatCountIcon_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "message.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 主列表

    /// 主聊天列表
    private let tableView_Flick: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 28, right: 0)
        return tv
    }()

    /// 推荐用户区域头视图（嵌入 TableView headerView）
    private lazy var recommendedSectionView_Flick: UIView = {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: APPSCREEN_Flick.WIDTH_Flick, height: 188))
        v.backgroundColor = .clear
        return v
    }()

    /// 推荐区域白色卡片背景
    private let recommendedCard_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 12
        return v
    }()

    /// 推荐区域标题
    private let suggestedLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "People You May Know"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ColorConfig_Flick.textPrimary_Flick
        return label
    }()

    /// "See All" 按钮
    private let seeAllButton_Flick: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("See All", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.tintColor = ColorConfig_Flick.primaryGradientStart_Flick
        return btn
    }()

    /// 推荐用户横向集合视图
    private lazy var recommendedCV_Flick: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 76, height: 96)
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(
            MsgRecommendCell_Flick.self,
            forCellWithReuseIdentifier: MsgRecommendCell_Flick.reuseID_Flick
        )
        return cv
    }()

    /// 空状态视图
    private let emptyChatView_Flick = UIView()

    private let emptyIconView_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        iv.tintColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.4)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyTitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "No chats yet"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ColorConfig_Flick.textPrimary_Flick
        label.textAlignment = .center
        return label
    }()

    private let emptyTipLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "Say hi to someone from\nthe suggestions above!"
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorConfig_Flick.textSecondary_Flick
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData_Flick()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        setupConstraints_Flick()
        setupObservers_Flick()
        refreshData_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBannerGradient_Flick()
        updateDecorLayout_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance_Flick()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        // 顶部 Banner
        view.addSubview(topBannerView_Flick)
        topBannerView_Flick.addSubview(decorCircle1_Flick)
        topBannerView_Flick.addSubview(decorCircle2_Flick)
        topBannerView_Flick.addSubview(decorSparkle_Flick)
        topBannerView_Flick.addSubview(decorStar_Flick)
        topBannerView_Flick.addSubview(pageTitleLabel_Flick)
        topBannerView_Flick.addSubview(pageSubtitleLabel_Flick)
        topBannerView_Flick.addSubview(chatCountPill_Flick)
        chatCountPill_Flick.addSubview(chatCountIcon_Flick)
        chatCountPill_Flick.addSubview(chatCountLabel_Flick)

        // 推荐用户头视图
        buildRecommendedSection_Flick()

        // 聊天列表
        tableView_Flick.delegate = self
        tableView_Flick.dataSource = self
        tableView_Flick.register(
            MsgChatRowCell_Flick.self,
            forCellReuseIdentifier: MsgChatRowCell_Flick.reuseID_Flick
        )
        tableView_Flick.tableHeaderView = recommendedSectionView_Flick
        view.addSubview(tableView_Flick)

        // 空状态
        buildEmptyChatView_Flick()
        view.addSubview(emptyChatView_Flick)
    }

    /// 构建推荐用户区域
    private func buildRecommendedSection_Flick() {
        recommendedCV_Flick.delegate = self
        recommendedCV_Flick.dataSource = self

        recommendedSectionView_Flick.addSubview(recommendedCard_Flick)
        recommendedCard_Flick.addSubview(suggestedLabel_Flick)
        recommendedCard_Flick.addSubview(seeAllButton_Flick)
        recommendedCard_Flick.addSubview(recommendedCV_Flick)

        recommendedCard_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-4)
        }

        suggestedLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
        }

        seeAllButton_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(suggestedLabel_Flick)
            make.right.equalToSuperview().offset(-16)
        }

        recommendedCV_Flick.snp.makeConstraints { make in
            make.top.equalTo(suggestedLabel_Flick.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(114)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    /// 构建空状态视图
    private func buildEmptyChatView_Flick() {
        emptyChatView_Flick.addSubview(emptyIconView_Flick)
        emptyChatView_Flick.addSubview(emptyTitleLabel_Flick)
        emptyChatView_Flick.addSubview(emptyTipLabel_Flick)

        emptyIconView_Flick.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        emptyTitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Flick.snp.bottom).offset(12)
            make.left.right.centerX.equalToSuperview()
        }
        emptyTipLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel_Flick.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }

    // MARK: - 约束

    private func setupConstraints_Flick() {
        topBannerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(96)
        }

        pageTitleLabel_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-28)
            make.left.equalToSuperview().offset(20)
        }

        pageSubtitleLabel_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(20)
        }

        chatCountPill_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(pageTitleLabel_Flick)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(28)
        }

        chatCountIcon_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        chatCountLabel_Flick.snp.makeConstraints { make in
            make.left.equalTo(chatCountIcon_Flick.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        tableView_Flick.snp.makeConstraints { make in
            make.top.equalTo(topBannerView_Flick.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        emptyChatView_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.centerY).offset(20)
            make.width.equalToSuperview().multipliedBy(0.65)
        }
    }

    // MARK: - 渐变 & 装饰布局

    /// 创建/更新顶部渐变层
    private func updateBannerGradient_Flick() {
        bannerGradientLayer_Flick?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.frame = topBannerView_Flick.bounds
        gradient.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        topBannerView_Flick.layer.insertSublayer(gradient, at: 0)
        bannerGradientLayer_Flick = gradient
    }

    /// 更新装饰圆位置和圆角
    private func updateDecorLayout_Flick() {
        let h = topBannerView_Flick.bounds.height
        let w = topBannerView_Flick.bounds.width
        decorCircle1_Flick.frame = CGRect(x: -40, y: -40, width: 160, height: 160)
        decorCircle1_Flick.layer.cornerRadius = 80
        decorCircle2_Flick.frame = CGRect(x: w - 80, y: h - 30, width: 120, height: 120)
        decorCircle2_Flick.layer.cornerRadius = 60
    }

    // MARK: - 入场动画

    private func animateEntrance_Flick() {
        pageTitleLabel_Flick.alpha = 0
        pageSubtitleLabel_Flick.alpha = 0
        chatCountPill_Flick.alpha = 0
        pageTitleLabel_Flick.transform = CGAffineTransform(translationX: -20, y: 0)
        pageSubtitleLabel_Flick.transform = CGAffineTransform(translationX: -20, y: 0)

        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0.05,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: 0.5
        ) {
            self.pageTitleLabel_Flick.alpha = 1
            self.pageTitleLabel_Flick.transform = .identity
        }

        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0.12,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: 0.5
        ) {
            self.pageSubtitleLabel_Flick.alpha = 1
            self.pageSubtitleLabel_Flick.transform = .identity
            self.chatCountPill_Flick.alpha = 1
        }
    }

    // MARK: - 数据刷新

    private func refreshData_Flick() {
        chatUsers_Flick = MessageViewModel_Flick.shared_Flick.getChatUsers_Flick()

        let chattedIds = Set(chatUsers_Flick.compactMap { $0.userId_Flick })
        recommendedUsers_Flick = LocalData_Flick.shared_Flick.userList_Flick.filter {
            !chattedIds.contains($0.userId_Flick ?? -1)
        }

        // 更新聊天数量 Pill
        chatCountLabel_Flick.text = "\(chatUsers_Flick.count) chats"

        emptyChatView_Flick.isHidden = !chatUsers_Flick.isEmpty
        tableView_Flick.reloadData()
        recommendedCV_Flick.reloadData()
    }

    // MARK: - 通知监听

    private func setupObservers_Flick() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Flick),
            name: MessageViewModel_Flick.messageStateDidChangeNotification_Flick,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Flick),
            name: UserViewModel_Flick.userStateDidChangeNotification_Flick,
            object: nil
        )
    }

    @objc private func handleStateChange_Flick() {
        refreshData_Flick()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageList_Flick: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Flick.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MsgChatRowCell_Flick.reuseID_Flick,
            for: indexPath
        ) as! MsgChatRowCell_Flick

        let user = chatUsers_Flick[indexPath.row]
        let lastMsg = user.userId_Flick.flatMap {
            MessageViewModel_Flick.shared_Flick.getLastMessageWithUser_Flick(userId_flick: $0)
        }
        cell.configure_Flick(user_Flick: user, lastMessage_Flick: lastMsg)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 按压动画反馈
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.animatePressDown_Flick { cell.animatePressUp_Flick() }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Navigation_Flick.toMessageUser_Flick(with: self.chatUsers_Flick[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !chatUsers_Flick.isEmpty else { return nil }
        let header = UIView()
        header.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        // 左侧彩条装饰
        let accentBar = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: 4, height: 18)
        gradient.cornerRadius = 2
        accentBar.layer.addSublayer(gradient)

        let label = UILabel()
        label.text = "Chats"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ColorConfig_Flick.textPrimary_Flick

        let countBadge = UIView()
        countBadge.backgroundColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.12)
        countBadge.layer.cornerRadius = 10

        let countLabel = UILabel()
        countLabel.text = "\(chatUsers_Flick.count)"
        countLabel.font = .systemFont(ofSize: 11, weight: .bold)
        countLabel.textColor = ColorConfig_Flick.primaryGradientStart_Flick

        header.addSubview(accentBar)
        header.addSubview(label)
        header.addSubview(countBadge)
        countBadge.addSubview(countLabel)

        accentBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(accentBar.snp.right).offset(8)
        }
        countBadge.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(label.snp.right).offset(8)
            make.height.equalTo(20)
        }
        countLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.right.equalToSuperview().inset(8)
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return chatUsers_Flick.isEmpty ? 0 : 44
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension MessageList_Flick: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedUsers_Flick.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MsgRecommendCell_Flick.reuseID_Flick,
            for: indexPath
        ) as! MsgRecommendCell_Flick
        cell.configure_Flick(user_Flick: recommendedUsers_Flick[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 推荐用户点击进入用户中心页，而非直接开启聊天
        Navigation_Flick.toUserInfo_Flick(with: recommendedUsers_Flick[indexPath.item])
    }
}

// MARK: - 推荐用户 Cell

/// 故事环风格推荐用户 Cell
/// 功能：渐变旋转环 + 圆形头像 + 在线绿点 + 昵称
private class MsgRecommendCell_Flick: UICollectionViewCell {

    static let reuseID_Flick = "MsgRecommendCell_Flick"

    // 渐变边框环（最外层）
    private let ringView_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 34
        v.layer.borderWidth = 2.5
        v.clipsToBounds = false
        return v
    }()

    private let ringGradient_Flick = CAGradientLayer()

    // 白色间隔环（环与头像之间的留白）
    private let gapRing_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 31
        return v
    }()

    // 头像
    private let avatarView_Flick: UserAvatarView_Flick = {
        let v = UserAvatarView_Flick()
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    // 在线绿点
    private let onlineDot_Flick: UIView = {
        let dot = UIView()
        dot.backgroundColor = UIColor(hexstring_Flick: "#48BB78")
        dot.layer.cornerRadius = 6
        dot.layer.borderWidth = 2
        dot.layer.borderColor = UIColor.white.cgColor
        return dot
    }()

    // 昵称
    private let nameLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = ColorConfig_Flick.textPrimary_Flick
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutGradientRing_Flick()
    }

    private func setupCell_Flick() {
        contentView.backgroundColor = .clear

        contentView.addSubview(ringView_Flick)
        ringView_Flick.addSubview(gapRing_Flick)
        gapRing_Flick.addSubview(avatarView_Flick)
        ringView_Flick.addSubview(onlineDot_Flick)
        contentView.addSubview(nameLabel_Flick)

        ringView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(68)
        }

        gapRing_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(62)
        }

        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }

        onlineDot_Flick.snp.makeConstraints { make in
            make.bottom.equalTo(ringView_Flick).offset(-4)
            make.right.equalTo(ringView_Flick).offset(-2)
            make.width.height.equalTo(12)
        }

        nameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(ringView_Flick.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(2)
            make.bottom.lessThanOrEqualToSuperview().inset(4)
        }
    }

    private func layoutGradientRing_Flick() {
        ringGradient_Flick.removeFromSuperlayer()
        ringGradient_Flick.frame = CGRect(x: 0, y: 0, width: 68, height: 68)
        ringGradient_Flick.cornerRadius = 34
        ringGradient_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        ringGradient_Flick.startPoint = CGPoint(x: 0, y: 0)
        ringGradient_Flick.endPoint = CGPoint(x: 1, y: 1)
        ringView_Flick.layer.insertSublayer(ringGradient_Flick, at: 0)
    }

    func configure_Flick(user_Flick: PrewUserModel_Flick) {
        nameLabel_Flick.text = user_Flick.userName_Flick
        if let uid = user_Flick.userId_Flick {
            avatarView_Flick.configure_Flick(userId_Flick: uid)
        }
    }
}

// MARK: - 聊天行 Cell

/// 聊天列表行 Cell
/// 功能：圆形头像 + 渐变在线指示器 + 昵称 + 消息预览 + 时间 + 未读徽章
private class MsgChatRowCell_Flick: UITableViewCell {

    static let reuseID_Flick = "MsgChatRowCell_Flick"

    // 行背景卡片（悬浮白色圆角）
    private let cardView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.05).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        return v
    }()

    // 头像（带渐变环）
    private let avatarContainerView_Flick: UIView = UIView()
    private let avatarView_Flick = UserAvatarView_Flick()

    // 头像渐变环（有未读消息时显示）
    private let avatarRingLayer_Flick = CAGradientLayer()

    // 在线状态小圆点
    private let onlineDot_Flick: UIView = {
        let dot = UIView()
        dot.backgroundColor = UIColor(hexstring_Flick: "#48BB78")
        dot.layer.cornerRadius = 5
        dot.layer.borderWidth = 2
        dot.layer.borderColor = UIColor.white.cgColor
        return dot
    }()

    // 昵称
    private let nameLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ColorConfig_Flick.textPrimary_Flick
        return label
    }()

    // 消息预览（带 emoji 前缀）
    private let previewLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = ColorConfig_Flick.textSecondary_Flick
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    // 时间
    private let timeLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        label.textAlignment = .right
        return label
    }()

    // 未读消息数徽章（渐变胶囊）
    private let unreadBadge_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 9
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()

    private let unreadGradient_Flick = CAGradientLayer()

    private let unreadLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    // 向右箭头
    private let chevron_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = ColorConfig_Flick.textPlaceholder_Flick
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView_Flick.layer.cornerRadius = avatarView_Flick.bounds.width / 2
        avatarView_Flick.clipsToBounds = true
        layoutAvatarRing_Flick()
        layoutUnreadGradient_Flick()
    }

    private func setupCellUI_Flick() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(cardView_Flick)
        cardView_Flick.addSubview(avatarContainerView_Flick)
        avatarContainerView_Flick.addSubview(avatarView_Flick)
        avatarContainerView_Flick.addSubview(onlineDot_Flick)
        cardView_Flick.addSubview(nameLabel_Flick)
        cardView_Flick.addSubview(previewLabel_Flick)
        cardView_Flick.addSubview(timeLabel_Flick)
        cardView_Flick.addSubview(unreadBadge_Flick)
        unreadBadge_Flick.addSubview(unreadLabel_Flick)
        cardView_Flick.addSubview(chevron_Flick)

        cardView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        avatarContainerView_Flick.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(52)
        }

        avatarView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }

        onlineDot_Flick.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.width.height.equalTo(10)
        }

        chevron_Flick.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        timeLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.right.equalTo(chevron_Flick.snp.left).offset(-6)
        }

        unreadBadge_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.right.equalTo(chevron_Flick.snp.left).offset(-6)
            make.height.equalTo(18)
        }

        unreadLabel_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.left.right.equalToSuperview().inset(6)
        }

        nameLabel_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(avatarContainerView_Flick.snp.right).offset(12)
            make.right.equalTo(timeLabel_Flick.snp.left).offset(-8)
        }

        previewLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Flick.snp.bottom).offset(4)
            make.left.equalTo(nameLabel_Flick)
            make.right.equalTo(unreadBadge_Flick.snp.left).offset(-8)
        }
    }

    private func layoutAvatarRing_Flick() {
        avatarRingLayer_Flick.removeFromSuperlayer()
        guard !unreadBadge_Flick.isHidden else { return }
        avatarRingLayer_Flick.frame = avatarContainerView_Flick.bounds
        avatarRingLayer_Flick.cornerRadius = 26
        avatarRingLayer_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.secondaryGradientStart_Flick.cgColor
        ]
        avatarRingLayer_Flick.startPoint = CGPoint(x: 0, y: 0)
        avatarRingLayer_Flick.endPoint = CGPoint(x: 1, y: 1)
        avatarContainerView_Flick.layer.insertSublayer(avatarRingLayer_Flick, at: 0)
        avatarContainerView_Flick.layer.cornerRadius = 26
        avatarContainerView_Flick.clipsToBounds = true
    }

    private func layoutUnreadGradient_Flick() {
        unreadGradient_Flick.removeFromSuperlayer()
        unreadGradient_Flick.frame = unreadBadge_Flick.bounds
        unreadGradient_Flick.cornerRadius = 9
        unreadGradient_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        unreadGradient_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        unreadGradient_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        unreadBadge_Flick.layer.insertSublayer(unreadGradient_Flick, at: 0)
    }

    func configure_Flick(user_Flick: PrewUserModel_Flick, lastMessage_Flick: MessageModel_Flick?) {
        nameLabel_Flick.text = user_Flick.userName_Flick

        if let content = lastMessage_Flick?.content_Flick {
            let isMine = lastMessage_Flick?.isMine_Flick ?? false
            previewLabel_Flick.text = isMine ? "You: \(content)" : content
        } else {
            previewLabel_Flick.text = "Say hi! 👋"
        }

        timeLabel_Flick.text = lastMessage_Flick?.time_Flick ?? ""

        if let uid = user_Flick.userId_Flick {
            avatarView_Flick.configure_Flick(userId_Flick: uid)
        }

        // 对方发送的消息展示未读徽章
        let hasUnread = lastMessage_Flick?.isMine_Flick == false
        unreadBadge_Flick.isHidden = !hasUnread
        unreadLabel_Flick.text = "1"

        // 有未读消息时名字加粗
        nameLabel_Flick.font = hasUnread
            ? .systemFont(ofSize: 15, weight: .heavy)
            : .systemFont(ofSize: 15, weight: .bold)
        previewLabel_Flick.textColor = hasUnread
            ? ColorConfig_Flick.textPrimary_Flick
            : ColorConfig_Flick.textSecondary_Flick

        setNeedsLayout()
    }
}
