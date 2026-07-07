import Foundation
import UIKit
import SnapKit

// MARK: - 消息气泡 Cell

/// 聊天消息气泡单元格
/// 功能：根据 isMine_Lens 决定气泡方向和样式
///   - 自己发的消息：右对齐，紫蓝渐变气泡，白色文字
///   - 对方发的消息：左对齐，深色气泡，白色文字，左侧显示对方头像
/// 设计：使用 snp.remakeConstraints 在配置时动态切换布局，
///       layoutSubviews 中更新渐变 frame，避免尺寸计算时机问题
class MessageBubbleCell_Lens: UITableViewCell {

    // MARK: - 静态标识

    static let reuseId_Lens = "MessageBubbleCell_Lens"

    // MARK: - 常量

    /// 气泡最大宽度（屏幕宽度的 65%）
    private let maxBubbleWidth_Lens = UIScreen.main.bounds.width * 0.65

    // MARK: - UI 组件

    /// 气泡背景容器（圆角矩形，支持渐变或纯色）
    private let bubbleBgView_Lens: UIView = {
        let view_Lens = UIView()
        view_Lens.layer.cornerRadius = 18
        view_Lens.layer.masksToBounds = true
        return view_Lens
    }()

    /// 消息文字标签
    private let messageLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.textColor = .white
        label_Lens.font = .systemFont(ofSize: 15)
        label_Lens.numberOfLines = 0
        return label_Lens
    }()

    /// 消息时间标签
    private let timeLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.textColor = UIColor(white: 1, alpha: 0.4)
        label_Lens.font = .systemFont(ofSize: 10)
        return label_Lens
    }()

    /// 对方用户头像（仅在对方消息时显示）
    private let avatarView_Lens = UserAvatarView_Lens()

    /// 当前渐变图层引用（仅用于自己的消息气泡）
    private var gradientLayer_Lens: CAGradientLayer?

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBaseUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 渐变层跟随气泡容器真实尺寸
        gradientLayer_Lens?.frame = bubbleBgView_Lens.bounds
    }

    // MARK: - UI 搭建

    /// 添加所有子视图（不设初始约束，由 configure 时动态设置）
    private func setupBaseUI_Lens() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(avatarView_Lens)
        contentView.addSubview(bubbleBgView_Lens)
        bubbleBgView_Lens.addSubview(messageLabel_Lens)
        contentView.addSubview(timeLabel_Lens)
    }

    // MARK: - 公共方法

    /// 配置消息气泡内容与布局方向
    /// 参数：
    /// - message_lens: 消息数据模型
    /// - otherUser_lens: 对方用户信息（用于加载对方头像，对方消息时使用）
    func configure_Lens(message_lens: MessageModel_Lens, otherUser_lens: PrewUserModel_Lens?) {
        let isMine_Lens = message_lens.isMine_Lens == true

        // 清除上次渐变层（复用时必须清除，否则层叠）
        gradientLayer_Lens?.removeFromSuperlayer()
        gradientLayer_Lens = nil

        messageLabel_Lens.text = message_lens.content_Lens
        timeLabel_Lens.text = message_lens.time_Lens ?? ""

        if isMine_Lens {
            configureMineLayout_Lens()
        } else {
            configureTheirsLayout_Lens(otherUser_lens: otherUser_lens)
        }

        // 文字约束（相对气泡背景容器）
        messageLabel_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    /// 设置"自己发的"消息布局：右对齐渐变气泡
    private func configureMineLayout_Lens() {
        avatarView_Lens.isHidden = true

        // 紫蓝渐变气泡
        bubbleBgView_Lens.backgroundColor = .clear
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        bubbleBgView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
        gradientLayer_Lens = gradient_Lens

        // 头像占位（零尺寸，不影响布局）
        avatarView_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.width.height.equalTo(0)
            make_Lens.leading.top.equalToSuperview()
        }

        // 气泡：右侧对齐
        bubbleBgView_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.right.equalToSuperview().offset(-14)
            make_Lens.top.equalToSuperview().offset(6)
            make_Lens.width.lessThanOrEqualTo(maxBubbleWidth_Lens)
        }

        // 时间：气泡正下方右对齐
        timeLabel_Lens.textAlignment = .right
        timeLabel_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.right.equalTo(bubbleBgView_Lens)
            make_Lens.top.equalTo(bubbleBgView_Lens.snp.bottom).offset(4)
            make_Lens.bottom.equalToSuperview().offset(-6)
        }
    }

    /// 设置"对方发的"消息布局：左对齐深色气泡 + 左侧头像
    /// 参数：
    /// - otherUser_lens: 发送方用户信息，用于配置头像
    private func configureTheirsLayout_Lens(otherUser_lens: PrewUserModel_Lens?) {
        avatarView_Lens.isHidden = false
        if let userId_Lens = otherUser_lens?.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }

        // 深色气泡背景
        bubbleBgView_Lens.backgroundColor = UIColor(hexstring_Lens: "#1A1A2E")

        // 头像：左侧，与气泡顶部对齐
        avatarView_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.left.equalToSuperview().offset(14)
            make_Lens.top.equalToSuperview().offset(6)
            make_Lens.width.height.equalTo(34)
        }

        // 气泡：头像右侧对齐
        bubbleBgView_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.left.equalTo(avatarView_Lens.snp.right).offset(8)
            make_Lens.top.equalToSuperview().offset(6)
            make_Lens.width.lessThanOrEqualTo(maxBubbleWidth_Lens)
        }

        // 时间：气泡正下方左对齐
        timeLabel_Lens.textAlignment = .left
        timeLabel_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.left.equalTo(bubbleBgView_Lens)
            make_Lens.top.equalTo(bubbleBgView_Lens.snp.bottom).offset(4)
            make_Lens.bottom.equalToSuperview().offset(-6)
        }
    }
}

// MARK: - 与用户聊天页面

/// 与用户聊天界面
/// 功能：展示与指定用户的全部聊天记录，支持发送文字、视频通话、举报拉黑
/// 设计：
///   - 顶部用户信息卡片（渐变背景），点击进入用户中心（fromChat_Lens = true）
///   - 中间 UITableView 展示消息气泡列表
///   - 底部输入工具栏（输入框 + 视频通话按钮 + 发送按钮），随键盘上移
///   - viewWillAppear 检查关注状态，取关后自动清除记录并返回消息列表
/// 关键属性：
/// - userModel_Lens: 聊天目标用户（由外部注入）
/// - messages_Lens: 当前会话消息列表
/// - inputToolbarBottomConstraint_Lens: 用于键盘弹出时上移底部工具栏
/// 关键方法：
/// - reloadMessages_Lens: 重新获取并刷新消息列表
/// - scrollToBottom_Lens: 滚动到最新消息
class MessageUser_Lens: UIViewController {

    // MARK: - 属性

    /// 聊天目标用户（由外部注入）
    var userModel_Lens: PrewUserModel_Lens?

    /// 当前会话消息列表数据源
    private var messages_Lens: [MessageModel_Lens] = []

    /// 是否已首次显示（用于区分初次加载和从子页面返回）
    private var hasAppeared_Lens = false

    // MARK: - UI 组件

    /// 顶部用户信息卡片容器
    private let userInfoCardView_Lens = UIView()

    /// 卡片渐变图层（在 viewDidLayoutSubviews 更新 frame）
    private var cardGradientLayer_Lens: CAGradientLayer?

    /// 用户头像
    private let avatarView_Lens: UserAvatarView_Lens = {
        let view_Lens = UserAvatarView_Lens()
        view_Lens.layer.borderWidth = 2
        view_Lens.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view_Lens.clipsToBounds = true
        return view_Lens
    }()

    /// 用户昵称
    private let userNameLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.textColor = .white
        label_Lens.font = .boldSystemFont(ofSize: 17)
        label_Lens.numberOfLines = 1
        return label_Lens
    }()

    /// 用户简介
    private let userIntroduceLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.textColor = UIColor(white: 1, alpha: 0.7)
        label_Lens.font = .systemFont(ofSize: 13)
        label_Lens.numberOfLines = 2
        return label_Lens
    }()

    /// 返回按钮
    private let backButton_Lens: UIButton = {
        let button_Lens = UIButton(type: .system)
        let config_Lens = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button_Lens.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_Lens), for: .normal)
        button_Lens.tintColor = .white
        return button_Lens
    }()

    /// 举报按钮（右上角）
    private lazy var reportButton_Lens: UIButton = {
        ReportDeleteHelper_Lens.createUserReportButton_Lens(
            size_Lens: 38,
            backgroundColor_Lens: UIColor.white.withAlphaComponent(0.2),
            tintColor_Lens: .white,
            withShadow_Lens: false
        )
    }()

    /// 消息气泡列表
    private lazy var tableView_Lens: UITableView = {
        let table_Lens = UITableView(frame: .zero, style: .plain)
        table_Lens.backgroundColor = .clear
        table_Lens.separatorStyle = .none
        table_Lens.rowHeight = UITableView.automaticDimension
        table_Lens.estimatedRowHeight = 80
        table_Lens.showsVerticalScrollIndicator = false
        table_Lens.register(MessageBubbleCell_Lens.self, forCellReuseIdentifier: MessageBubbleCell_Lens.reuseId_Lens)
        table_Lens.dataSource = self
        table_Lens.delegate = self
        table_Lens.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return table_Lens
    }()

    /// 底部输入工具栏容器
    private let inputToolbarView_Lens: UIView = {
        let view_Lens = UIView()
        view_Lens.backgroundColor = UIColor(hexstring_Lens: "#1A1A2E")
        return view_Lens
    }()

    /// 文本输入框
    private let inputTextField_Lens: UITextField = {
        let textField_Lens = UITextField()
        textField_Lens.placeholder = "Message..."
        textField_Lens.textColor = .white
        textField_Lens.font = .systemFont(ofSize: 15)
        textField_Lens.attributedPlaceholder = NSAttributedString(
            string: "Message...",
            attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.35)]
        )
        textField_Lens.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        textField_Lens.layer.cornerRadius = 20
        textField_Lens.returnKeyType = .send
        // 左侧内边距
        let paddingView_Lens = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        textField_Lens.leftView = paddingView_Lens
        textField_Lens.leftViewMode = .always
        return textField_Lens
    }()

    /// 发送按钮（蓝紫渐变）
    private let sendButton_Lens: UIButton = {
        let button_Lens = UIButton(type: .system)
        let config_Lens = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button_Lens.setImage(UIImage(systemName: "arrow.up", withConfiguration: config_Lens), for: .normal)
        button_Lens.tintColor = .white
        button_Lens.layer.cornerRadius = 20
        button_Lens.layer.masksToBounds = true
        return button_Lens
    }()

    /// 视频通话按钮（带半透明紫色背景圆角样式）
    private let videoChatButton_Lens: UIButton = {
        let button_Lens = UIButton(type: .system)
        let config_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button_Lens.setImage(UIImage(systemName: "video.fill", withConfiguration: config_Lens), for: .normal)
        button_Lens.tintColor = .white
        button_Lens.layer.cornerRadius = 20
        button_Lens.layer.masksToBounds = true
        return button_Lens
    }()

    /// 发送按钮渐变图层
    private var sendButtonGradientLayer_Lens: CAGradientLayer?

    /// 视频通话按钮渐变图层
    private var videoButtonGradientLayer_Lens: CAGradientLayer?

    /// 底部工具栏约束（键盘弹出时更新 offset）
    private var inputToolbarBottomConstraint_Lens: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        setupUI_Lens()
        setupActions_Lens()
        setupKeyboardObservers_Lens()
        setupNotification_Lens()
        fillUserInfo_Lens()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 初次进入只刷新数据，不检查关注状态（关注可能尚未发生）
        guard hasAppeared_Lens else {
            hasAppeared_Lens = true
            reloadMessages_Lens()
            scrollToBottom_Lens(animated: false)
            return
        }

        // 从子页面（如 UserInfo）返回：检查是否已取消关注
        guard let userModel_Lens = userModel_Lens,
              let userId_Lens = userModel_Lens.userId_Lens else {
            reloadMessages_Lens()
            return
        }

        let isFollowing_Lens = UserViewModel_Lens.shared_Lens.isFollowing_Lens(user_lens: userModel_Lens)
        let hasMessages_Lens = !MessageViewModel_Lens.shared_Lens
            .getMessagesWithUser_Lens(userId_lens: userId_Lens).isEmpty

        // 取消关注且有聊天记录：清除记录并返回消息列表
        if !isFollowing_Lens && hasMessages_Lens {
            MessageViewModel_Lens.shared_Lens.deleteUserMessages_Lens(userId_lens: userId_Lens)
            Navigation_Lens.pop_Lens(from: self)
            return
        }

        reloadMessages_Lens()
        scrollToBottom_Lens(animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层 frame
        cardGradientLayer_Lens?.frame = userInfoCardView_Lens.bounds
        sendButtonGradientLayer_Lens?.frame = sendButton_Lens.bounds
        videoButtonGradientLayer_Lens?.frame = videoChatButton_Lens.bounds

        // 同步头像圆角（需在 layout 后才能拿到正确 bounds）
        let avatarRadius_Lens = avatarView_Lens.bounds.width / 2
        avatarView_Lens.layer.cornerRadius = avatarRadius_Lens
    }

    // MARK: - UI 搭建

    /// 统一构建页面布局
    private func setupUI_Lens() {
        setupUserInfoCard_Lens()
        setupTableView_Lens()
        setupInputToolbar_Lens()
    }

    /// 构建顶部用户信息卡片
    private func setupUserInfoCard_Lens() {
        view.addSubview(userInfoCardView_Lens)
        userInfoCardView_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.left.right.equalToSuperview()
            // 卡片底部 = 安全区顶部 + 120pt 内容区
            make_Lens.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
        }

        // 棱镜渐变背景
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        userInfoCardView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
        cardGradientLayer_Lens = gradient_Lens

        // 返回按钮（左上，安全区内）
        userInfoCardView_Lens.addSubview(backButton_Lens)
        backButton_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make_Lens.left.equalToSuperview().offset(12)
            make_Lens.width.height.equalTo(40)
        }

        // 举报按钮（右上，安全区内）
        userInfoCardView_Lens.addSubview(reportButton_Lens)
        reportButton_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make_Lens.right.equalToSuperview().offset(-12)
            make_Lens.width.height.equalTo(38)
        }

        // 头像（安全区下方居中偏左）
        userInfoCardView_Lens.addSubview(avatarView_Lens)
        avatarView_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make_Lens.left.equalToSuperview().offset(60)
            make_Lens.width.height.equalTo(68)
        }

        // 昵称 + 简介纵向堆叠
        let textStack_Lens = UIStackView(arrangedSubviews: [userNameLabel_Lens, userIntroduceLabel_Lens])
        textStack_Lens.axis = .vertical
        textStack_Lens.spacing = 4
        userInfoCardView_Lens.addSubview(textStack_Lens)
        textStack_Lens.snp.makeConstraints { make_Lens in
            make_Lens.left.equalTo(avatarView_Lens.snp.right).offset(12)
            make_Lens.right.equalTo(reportButton_Lens.snp.left).offset(-8)
            make_Lens.centerY.equalTo(avatarView_Lens)
        }

        // 点击卡片跳转用户中心
        let tapGesture_Lens = UITapGestureRecognizer(target: self, action: #selector(handleUserInfoCardTap_Lens))
        userInfoCardView_Lens.addGestureRecognizer(tapGesture_Lens)
    }

    /// 构建消息列表
    private func setupTableView_Lens() {
        view.addSubview(tableView_Lens)
        tableView_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.equalTo(userInfoCardView_Lens.snp.bottom)
            make_Lens.left.right.equalToSuperview()
            make_Lens.bottom.equalTo(view.snp.bottom).offset(-(60 + view.safeAreaInsets.bottom))
        }

        // 点击列表收起键盘
        let tapGesture_Lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        tapGesture_Lens.cancelsTouchesInView = false
        tableView_Lens.addGestureRecognizer(tapGesture_Lens)
    }

    /// 构建底部输入工具栏
    private func setupInputToolbar_Lens() {
        // 工具栏顶部分割线
        let divider_Lens = UIView()
        divider_Lens.backgroundColor = UIColor(white: 1, alpha: 0.08)
        inputToolbarView_Lens.addSubview(divider_Lens)
        divider_Lens.snp.makeConstraints { make_Lens in
            make_Lens.top.left.right.equalToSuperview()
            make_Lens.height.equalTo(0.5)
        }

        view.addSubview(inputToolbarView_Lens)
        inputToolbarView_Lens.snp.makeConstraints { make_Lens in
            make_Lens.left.right.equalToSuperview()
            make_Lens.height.equalTo(60)
            // 存储约束用于键盘动画
            inputToolbarBottomConstraint_Lens = make_Lens.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }

        // 视频通话按钮
        inputToolbarView_Lens.addSubview(videoChatButton_Lens)
        videoChatButton_Lens.snp.makeConstraints { make_Lens in
            make_Lens.right.equalToSuperview().offset(-16)
            make_Lens.centerY.equalToSuperview()
            make_Lens.width.height.equalTo(40)
        }

        // 视频通话按钮半透明渐变背景（紫色系，区别于发送按钮）
        let videoGradient_Lens = CAGradientLayer()
        videoGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").withAlphaComponent(0.35).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").withAlphaComponent(0.35).cgColor
        ]
        videoGradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        videoGradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        videoGradient_Lens.cornerRadius = 20
        videoChatButton_Lens.layer.insertSublayer(videoGradient_Lens, at: 0)
        videoButtonGradientLayer_Lens = videoGradient_Lens
        // 确保图标在渐变层之上
        if let imageView_Lens = videoChatButton_Lens.imageView {
            videoChatButton_Lens.bringSubviewToFront(imageView_Lens)
        }

        // 发送按钮
        inputToolbarView_Lens.addSubview(sendButton_Lens)
        sendButton_Lens.snp.makeConstraints { make_Lens in
            make_Lens.right.equalTo(videoChatButton_Lens.snp.left).offset(-8)
            make_Lens.centerY.equalToSuperview()
            make_Lens.width.height.equalTo(40)
        }

        // 添加发送按钮渐变
        let sendGradient_Lens = CAGradientLayer()
        sendGradient_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        sendGradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        sendGradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        sendGradient_Lens.cornerRadius = 20
        sendButton_Lens.layer.insertSublayer(sendGradient_Lens, at: 0)
        sendButtonGradientLayer_Lens = sendGradient_Lens
        // 确保发送图标在渐变层之上
        if let imageView_Lens = sendButton_Lens.imageView {
            sendButton_Lens.bringSubviewToFront(imageView_Lens)
        }

        // 输入框
        inputToolbarView_Lens.addSubview(inputTextField_Lens)
        inputTextField_Lens.snp.makeConstraints { make_Lens in
            make_Lens.left.equalToSuperview().offset(14)
            make_Lens.right.equalTo(sendButton_Lens.snp.left).offset(-10)
            make_Lens.centerY.equalToSuperview()
            make_Lens.height.equalTo(40)
        }

        // 更新 tableView 底部约束（现在知道工具栏高度）
        tableView_Lens.snp.remakeConstraints { make_Lens in
            make_Lens.top.equalTo(userInfoCardView_Lens.snp.bottom)
            make_Lens.left.right.equalToSuperview()
            make_Lens.bottom.equalTo(inputToolbarView_Lens.snp.top)
        }
    }

    // MARK: - 数据填充

    /// 将 userModel_Lens 的用户信息渲染到卡片区域
    private func fillUserInfo_Lens() {
        guard let userModel_Lens = userModel_Lens else { return }
        if let userId_Lens = userModel_Lens.userId_Lens {
            avatarView_Lens.configure_Lens(userId_Lens: userId_Lens)
        }
        userNameLabel_Lens.text = userModel_Lens.userName_Lens ?? "User"
        userIntroduceLabel_Lens.text = userModel_Lens.userIntroduce_Lens ?? ""
    }

    // MARK: - 消息操作

    /// 重新获取消息列表并刷新 TableView
    private func reloadMessages_Lens() {
        guard let userId_Lens = userModel_Lens?.userId_Lens else { return }
        messages_Lens = MessageViewModel_Lens.shared_Lens.getMessagesWithUser_Lens(userId_lens: userId_Lens)
        tableView_Lens.reloadData()
    }

    /// 滚动到最新消息
    /// 参数：
    /// - animated: 是否启用滚动动画
    private func scrollToBottom_Lens(animated: Bool = true) {
        guard !messages_Lens.isEmpty else { return }
        let indexPath_Lens = IndexPath(row: messages_Lens.count - 1, section: 0)
        tableView_Lens.scrollToRow(at: indexPath_Lens, at: .bottom, animated: animated)
    }

    // MARK: - 动作绑定

    /// 绑定所有按钮事件
    private func setupActions_Lens() {
        backButton_Lens.addTarget(self, action: #selector(handleBack_Lens), for: .touchUpInside)
        reportButton_Lens.addTarget(self, action: #selector(handleReport_Lens), for: .touchUpInside)
        sendButton_Lens.addTarget(self, action: #selector(handleSend_Lens), for: .touchUpInside)
        videoChatButton_Lens.addTarget(self, action: #selector(handleVideoChat_Lens), for: .touchUpInside)
        inputTextField_Lens.delegate = self
    }

    // MARK: - 键盘处理

    /// 注册键盘通知
    private func setupKeyboardObservers_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow_Lens(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide_Lens(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 键盘即将弹出：上移输入工具栏
    @objc private func handleKeyboardWillShow_Lens(_ notification: Notification) {
        guard
            let keyboardFrame_Lens = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration_Lens = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        // 键盘高度去除安全区（工具栏基准是 safeAreaLayoutGuide.bottom）
        let pushHeight_Lens = keyboardFrame_Lens.height - view.safeAreaInsets.bottom
        inputToolbarBottomConstraint_Lens?.update(offset: -pushHeight_Lens)

        UIView.animate(withDuration: duration_Lens) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.scrollToBottom_Lens(animated: true)
        }
    }

    /// 键盘即将收起：恢复输入工具栏位置
    @objc private func handleKeyboardWillHide_Lens(_ notification: Notification) {
        guard
            let duration_Lens = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        inputToolbarBottomConstraint_Lens?.update(offset: 0)
        UIView.animate(withDuration: duration_Lens) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 通知注册

    /// 注册消息状态变化通知，新消息到达时自动刷新并滚动到底部
    private func setupNotification_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageStateChange_Lens),
            name: MessageViewModel_Lens.messageStateDidChangeNotification_Lens,
            object: nil
        )
    }

    @objc private func handleMessageStateChange_Lens() {
        reloadMessages_Lens()
        scrollToBottom_Lens(animated: true)
    }

    // MARK: - 事件处理

    /// 返回上一页
    @objc private func handleBack_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    /// 点击用户信息卡片：跳转用户中心（隐藏消息按钮）
    @objc private func handleUserInfoCardTap_Lens() {
        guard let userModel_Lens = userModel_Lens else { return }
        let userInfoVC_Lens = UserInfo_Lens()
        userInfoVC_Lens.userModel_Lens = userModel_Lens
        userInfoVC_Lens.fromChat_Lens = true
        Navigation_Lens.push_Lens(to: userInfoVC_Lens, from: self)
    }

    /// 发送消息
    @objc private func handleSend_Lens() {
        guard
            let text_Lens = inputTextField_Lens.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text_Lens.isEmpty,
            let userId_Lens = userModel_Lens?.userId_Lens
        else { return }

        MessageViewModel_Lens.shared_Lens.sendMessage_Lens(
            message_lens: text_Lens,
            chatType_lens: .personal_lens,
            id_lens: userId_Lens
        )

        inputTextField_Lens.text = nil
    }

    /// 发起视频通话：实例化 VideoChat_Lens，注入用户模型后 present
    @objc private func handleVideoChat_Lens() {
        guard let userModel_Lens = userModel_Lens else { return }
        let videoChatVC_Lens = VideoChat_Lens()
        videoChatVC_Lens.userModel_Lens = userModel_Lens
        videoChatVC_Lens.modalPresentationStyle = .fullScreen
        present(videoChatVC_Lens, animated: true)
    }

    /// 举报/拉黑用户：确认后删除消息记录并安全返回
    @objc private func handleReport_Lens() {
        guard let userModel_Lens = userModel_Lens else { return }

        ReportDeleteHelper_Lens.block_Lens(
            user_Lens: userModel_Lens,
            from: self
        ) { [weak self] in
            guard let self = self,
                  let userId_Lens = userModel_Lens.userId_Lens else { return }
            // 拉黑成功：删除与该用户的全部消息
            MessageViewModel_Lens.shared_Lens.deleteUserMessages_Lens(userId_lens: userId_Lens)
            // 清除导航堆栈并返回安全页面
            Navigation_Lens.popToSafeStateAfterBlock_Lens(from: self)
        }
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Lens() {
        view.endEditing(true)
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MessageUser_Lens: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages_Lens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_Lens = tableView.dequeueReusableCell(
            withIdentifier: MessageBubbleCell_Lens.reuseId_Lens,
            for: indexPath
        ) as! MessageBubbleCell_Lens

        let message_Lens = messages_Lens[indexPath.row]
        cell_Lens.configure_Lens(message_lens: message_Lens, otherUser_lens: userModel_Lens)
        return cell_Lens
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Lens: UITextFieldDelegate {

    /// 点击键盘 Return 键触发发送
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Lens()
        return true
    }
}
