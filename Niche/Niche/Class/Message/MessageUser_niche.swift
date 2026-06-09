import Foundation
import UIKit
import SnapKit

// MARK: 私信聊天页面

/// 私信聊天视图控制器
/// 功能：与指定用户进行私信聊天，展示聊天记录、发送消息、视频通话模拟
/// 设计：渐变顶部 + 用户信息大卡片 + 气泡尾角 + 接收方头像 + 渐变发送按钮
/// 关键：
///   - 点击顶部用户卡片进入用户中心（隐藏消息按钮，关注按钮居中）
///   - 举报按钮在右上角
///   - 取消关注后返回消息列表并删除聊天记录
class MessageUser_Niche: UIViewController {

    // MARK: - 传入数据

    var userModel_Niche: PrewUserModel_Niche?

    // MARK: - 私有属性

    private var _messages_niche: [MessageModel_Niche] {
        guard let uid_niche = userModel_Niche?.userId_Niche else { return [] }
        return MessageViewModel_Niche.shared_Niche.getMessagesWithUser_Niche(userId_niche: uid_niche)
    }

    // MARK: - UI 组件 / 头部

    /// 顶部渐变背景区
    private let _topGradient_niche = UIView()

    /// 装饰气泡
    private let _topBlob_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.12)
        v_niche.layer.cornerRadius = 44
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 返回按钮
    private let _backBtn_niche = BackButton_Niche()

    /// 举报按钮（right）
    private let _reportBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        btn_niche.backgroundColor = UIColor.white.withValues(alpha: 0.22)
        btn_niche.layer.cornerRadius = 17
        return btn_niche
    }()

    /// 用户信息卡片（居中可点击）
    private let _userCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.18)
        v_niche.layer.cornerRadius = 20
        v_niche.layer.borderWidth = 1
        v_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.25).cgColor
        v_niche.isUserInteractionEnabled = true
        return v_niche
    }()

    /// 头像外圈（白色边框）
    private let _avatarRing_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.3)
        v_niche.layer.cornerRadius = 30
        return v_niche
    }()

    private let _userAvatarView_niche = UserAvatarView_Niche()

    private let _userNameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        l_niche.textColor = .white
        return l_niche
    }()

    private let _userBioLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 11)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.75)
        l_niche.lineBreakMode = .byTruncatingTail
        return l_niche
    }()

    private let _cardArrowLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "View Profile  →"
        l_niche.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.55)
        return l_niche
    }()

    // MARK: - UI 组件 / 聊天区域

    /// 聊天背景
    private let _chatBg_niche = UIView()

    /// 聊天 TableView
    private lazy var _tableView_niche: UITableView = {
        let tv_niche = UITableView(frame: .zero, style: .plain)
        tv_niche.backgroundColor = .clear
        tv_niche.separatorStyle = .none
        tv_niche.showsVerticalScrollIndicator = false
        tv_niche.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tv_niche.register(ChatBubbleCell_Niche.self, forCellReuseIdentifier: ChatBubbleCell_Niche.reuseId_Niche)
        tv_niche.dataSource = self
        tv_niche.rowHeight = UITableView.automaticDimension
        tv_niche.estimatedRowHeight = 60
        return tv_niche
    }()

    // MARK: - UI 组件 / 输入栏

    private let _inputBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.07).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_niche.layer.shadowRadius = 10
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    private let _inputField_niche: UITextField = {
        let tf_niche = UITextField()
        tf_niche.placeholder = "Write something..."
        tf_niche.font = UIFont.systemFont(ofSize: 14)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")
        tf_niche.layer.cornerRadius = 20
        return tf_niche
    }()

    /// 发送按钮（渐变背景，UIButton type .custom）
    private let _sendBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_niche.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        return btn_niche
    }()

    /// 视频通话按钮（位于发送按钮左侧10pt）
    private let _videoCallBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        btn_niche.backgroundColor = UIColor(hexstring_Niche: "#B794F6")
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_niche.setImage(
            UIImage(systemName: "video.fill", withConfiguration: cfg_niche),
            for: .normal
        )
        btn_niche.tintColor = .white
        return btn_niche
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupActions_Niche()
        setupObservers_Niche()
        fillUserInfo_Niche()
        refreshMessages_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshMessages_Niche()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshTopGradient_Niche()
        refreshSendBtnGradient_Niche()
        refreshChatBg_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // ── 底部输入栏（固定 bottom）──
        view.addSubview(_inputBar_niche)
        _inputBar_niche.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(68)
        }

        // 先全部 addSubview 再统一设约束（避免公共祖先崩溃）
        _inputBar_niche.addSubview(_inputField_niche)
        _inputBar_niche.addSubview(_videoCallBtn_niche)
        _inputBar_niche.addSubview(_sendBtn_niche)

        /// 发送按钮固定右侧
        _sendBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        /// 视频通话按钮在发送按钮左侧10pt
        _videoCallBtn_niche.snp.makeConstraints { make in
            make.trailing.equalTo(_sendBtn_niche.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        _inputField_niche.addLeftPadding_Niche(16)
        _inputField_niche.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)
        /// 输入框右侧紧贴视频按钮
        _inputField_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.trailing.equalTo(_videoCallBtn_niche.snp.leading).offset(-10)
        }

        // ── 顶部渐变区 ──
        view.addSubview(_topGradient_niche)
        _topGradient_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(175)
        }

        _topGradient_niche.addSubview(_topBlob_niche)
        _topBlob_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(16)
            make.width.height.equalTo(88)
        }

        // 返回按钮
        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { Navigation_Niche.pop_Niche() }

        // 举报按钮
        view.addSubview(_reportBtn_niche)
        _reportBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }

        // 用户信息卡片（居中）
        _topGradient_niche.addSubview(_userCard_niche)
        _userCard_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(62)
            make.height.equalTo(68)
            make.leading.greaterThanOrEqualToSuperview().offset(70)
            make.trailing.lessThanOrEqualToSuperview().offset(-70)
        }

        // 头像外圈
        _userCard_niche.addSubview(_avatarRing_niche)
        _avatarRing_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }

        // 头像
        _avatarRing_niche.addSubview(_userAvatarView_niche)
        _userAvatarView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }

        // 右侧文字区（先全部 addSubview）
        _userCard_niche.addSubview(_userNameLabel_niche)
        _userCard_niche.addSubview(_userBioLabel_niche)
        _userCard_niche.addSubview(_cardArrowLabel_niche)

        _userNameLabel_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(_avatarRing_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
        }

        _userBioLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_userNameLabel_niche.snp.bottom).offset(3)
            make.leading.equalTo(_avatarRing_niche.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
        }

        _cardArrowLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_userBioLabel_niche.snp.bottom).offset(3)
            make.leading.equalTo(_avatarRing_niche.snp.trailing).offset(10)
        }

        // ── 聊天背景 ──
        view.addSubview(_chatBg_niche)
        _chatBg_niche.snp.makeConstraints { make in
            make.top.equalTo(_topGradient_niche.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_inputBar_niche.snp.top)
        }

        // ── 聊天列表 ──
        view.addSubview(_tableView_niche)
        _tableView_niche.snp.makeConstraints { make in
            make.top.equalTo(_topGradient_niche.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_inputBar_niche.snp.top)
        }
    }

    // MARK: - 渐变刷新

    private func refreshTopGradient_Niche() {
        _topGradient_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_topGradient_niche.bounds.isEmpty else { return }
        let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _topGradient_niche.bounds)
        grad_niche.cornerRadius = 30
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _topGradient_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshSendBtnGradient_Niche() {
        _sendBtn_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_sendBtn_niche.bounds.isEmpty else { return }
        let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _sendBtn_niche.bounds)
        grad_niche.cornerRadius = 20
        _sendBtn_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshChatBg_Niche() {
        _chatBg_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_chatBg_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _chatBg_niche.bounds
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#EEE8FF").cgColor,
            UIColor.white.cgColor
        ]
        grad_niche.startPoint = CGPoint(x: 0.5, y: 0)
        grad_niche.endPoint = CGPoint(x: 0.5, y: 1)
        _chatBg_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    // MARK: - 行为绑定

    private func setupActions_Niche() {
        _sendBtn_niche.addTarget(self, action: #selector(handleSend_Niche), for: .touchUpInside)
        _videoCallBtn_niche.addTarget(self, action: #selector(handleVideoCall_Niche), for: .touchUpInside)
        _reportBtn_niche.addTarget(self, action: #selector(handleReport_Niche), for: .touchUpInside)
        let tap_niche = UITapGestureRecognizer(target: self, action: #selector(handleUserCardTap_Niche))
        _userCard_niche.addGestureRecognizer(tap_niche)
    }

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Niche),
            name: MessageViewModel_Niche.messageStateDidChangeNotification_Niche,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Niche),
            name: UserViewModel_Niche.userStateDidChangeNotification_Niche,
            object: nil
        )
    }

    // MARK: - 数据填充

    private func fillUserInfo_Niche() {
        guard let user_niche = userModel_Niche else { return }
        _userAvatarView_niche.configure_Niche(userId_Niche: user_niche.userId_Niche ?? 0)
        _userNameLabel_niche.text = user_niche.userName_Niche ?? "User"
        _userBioLabel_niche.text = user_niche.userIntroduce_Niche ?? "Member of the tribe"
    }

    private func refreshMessages_Niche() {
        _tableView_niche.reloadData()
        scrollToBottom_Niche()
    }

    private func scrollToBottom_Niche() {
        let count_niche = _messages_niche.count
        guard count_niche > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?._tableView_niche.scrollToRow(
                at: IndexPath(row: count_niche - 1, section: 0),
                at: .bottom, animated: true
            )
        }
    }

    // MARK: - 事件处理

    @objc private func handleDataChange_Niche() { refreshMessages_Niche() }

    @objc private func handleUserStateChange_Niche() {
        guard let user_niche = userModel_Niche else { return }
        guard !UserViewModel_Niche.shared_Niche.isFollowing_Niche(user_niche: user_niche) else { return }
        Task { @MainActor in
            MessageViewModel_Niche.shared_Niche.deleteUserMessages_Niche(userId_niche: user_niche.userId_Niche ?? 0)
        }
        Navigation_Niche.popToSafeStateAfterBlock_Niche(from: self)
    }

    /// 点击视频通话按钮，以全屏模式进入 VideoChat_Niche
    @objc private func handleVideoCall_Niche() {
        let vc_niche = VideoChat_Niche()
        vc_niche.userModel_Niche = userModel_Niche
        vc_niche.modalPresentationStyle = .fullScreen
        vc_niche.modalTransitionStyle = .crossDissolve
        present(vc_niche, animated: true)
    }

    @objc private func handleSend_Niche() {
        let text_niche = _inputField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_niche.isEmpty, let uid_niche = userModel_Niche?.userId_Niche else { return }
        _inputField_niche.text = nil
        view.endEditing(true)
        Task { @MainActor in
            MessageViewModel_Niche.shared_Niche.sendMessage_Niche(
                message_niche: text_niche,
                chatType_niche: .personal_niche,
                id_niche: uid_niche
            )
        }
    }

    @objc private func handleReport_Niche() {
        guard let user_niche = userModel_Niche else { return }
        ReportDeleteHelper_Niche.block_Niche(user_Niche: user_niche, from: self) { [weak self] in
            Navigation_Niche.popToSafeStateAfterBlock_Niche(from: self ?? UIViewController())
        }
    }

    @objc private func handleUserCardTap_Niche() {
        guard let user_niche = userModel_Niche else { return }
        let vc_niche = UserInfo_Niche()
        vc_niche.userModel_Niche = user_niche
        vc_niche.isFromMessageUser_Niche = true
        Navigation_Niche.push_Niche(to: vc_niche)
    }
}

// MARK: - UITableViewDataSource

extension MessageUser_Niche: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        _messages_niche.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_niche = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell_Niche.reuseId_Niche,
            for: indexPath
        ) as? ChatBubbleCell_Niche else {
            return UITableViewCell()
        }
        cell_niche.configure_Niche(
            message: _messages_niche[indexPath.row],
            senderUser: userModel_Niche
        )
        return cell_niche
    }
}

// MARK: - 聊天气泡 Cell

/// 聊天气泡单元格
/// 设计：
///   发送方：右侧渐变紫蓝气泡（右下角尖角）
///   接收方：左侧白色卡片气泡（左下角尖角）+ 发送者头像
///   时间戳：气泡下方小字
class ChatBubbleCell_Niche: UITableViewCell {

    static let reuseId_Niche = "ChatBubbleCell_Niche"

    // MARK: - 私有属性

    private var _isMine_niche: Bool = false
    private var _bubbleGradLayer_niche: CAGradientLayer?

    // MARK: - 子视图

    /// 接收方头像（仅接收方显示）
    private let _senderAvatar_niche = UserAvatarView_Niche()

    /// 气泡视图
    private let _bubble_niche: UIView = {
        let v_niche = UIView()
        v_niche.clipsToBounds = true
        return v_niche
    }()

    /// 消息文字
    private let _msgLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 14)
        l_niche.numberOfLines = 0
        return l_niche
    }()

    /// 时间标签
    private let _timeLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        l_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        return l_niche
    }()

    // MARK: - 初始化

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI_Niche()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _bubbleGradLayer_niche?.frame = _bubble_niche.bounds
        applyBubbleTail_Niche()
    }

    // MARK: - UI 构建

    private func setupCellUI_Niche() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(_senderAvatar_niche)
        contentView.addSubview(_bubble_niche)
        contentView.addSubview(_timeLabel_niche)
        _bubble_niche.addSubview(_msgLabel_niche)

        _msgLabel_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14))
        }
    }

    // MARK: - 配置

    func configure_Niche(message: MessageModel_Niche, senderUser: PrewUserModel_Niche?) {
        _isMine_niche = message.isMine_Niche ?? false
        _msgLabel_niche.text  = message.content_Niche ?? ""
        _timeLabel_niche.text = message.time_Niche ?? ""

        if _isMine_niche {
            configureSentBubble_Niche()
        } else {
            configureReceivedBubble_Niche(senderUser: senderUser)
        }
    }

    /// 设置发送方气泡（右侧渐变）
    private func configureSentBubble_Niche() {
        _senderAvatar_niche.isHidden = true
        _msgLabel_niche.textColor = .white

        // 渐变气泡
        _bubble_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        _bubble_niche.backgroundColor = .clear
        _bubble_niche.layer.shadowOpacity = 0

        let grad_niche = CAGradientLayer()
        grad_niche.colors = [
            ColorConfig_Niche.primaryGradientStart_Niche.cgColor,
            ColorConfig_Niche.primaryGradientEnd_Niche.cgColor
        ]
        grad_niche.startPoint = CGPoint(x: 0, y: 0.5)
        grad_niche.endPoint   = CGPoint(x: 1, y: 0.5)
        _bubble_niche.layer.insertSublayer(grad_niche, at: 0)
        _bubbleGradLayer_niche = grad_niche

        // 约束（右对齐）
        _senderAvatar_niche.snp.remakeConstraints { make in
            make.size.equalTo(CGSize.zero)
        }

        _bubble_niche.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-16)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.72)
            make.bottom.equalTo(_timeLabel_niche.snp.top).offset(-4)
        }

        _timeLabel_niche.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-6)
        }
    }

    /// 设置接收方气泡（左侧白色卡片 + 头像）
    private func configureReceivedBubble_Niche(senderUser: PrewUserModel_Niche?) {
        _senderAvatar_niche.isHidden = false
        if let user_niche = senderUser {
            _senderAvatar_niche.configure_Niche(userId_Niche: user_niche.userId_Niche ?? 0)
        }
        _msgLabel_niche.textColor = ColorConfig_Niche.textPrimary_Niche

        // 白色气泡
        _bubble_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        _bubbleGradLayer_niche = nil
        _bubble_niche.backgroundColor = .white
        _bubble_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.07).cgColor
        _bubble_niche.layer.shadowOffset = CGSize(width: 0, height: 2)
        _bubble_niche.layer.shadowRadius = 6
        _bubble_niche.layer.shadowOpacity = 1

        // 约束（左对齐，头像 + 气泡）
        _senderAvatar_niche.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-6)
            make.width.height.equalTo(28)
        }

        _bubble_niche.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalTo(_senderAvatar_niche.snp.trailing).offset(8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.66)
            make.bottom.equalTo(_timeLabel_niche.snp.top).offset(-4)
        }

        _timeLabel_niche.snp.remakeConstraints { make in
            make.leading.equalTo(_senderAvatar_niche.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-6)
        }
    }

    /// 应用气泡尾角（不同圆角角度模拟尾角效果）
    private func applyBubbleTail_Niche() {
        guard !_bubble_niche.bounds.isEmpty else { return }
        _bubble_niche.layer.cornerRadius = 18
        if _isMine_niche {
            // 右下角缩小形成尾角
            _bubble_niche.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner
            ]
        } else {
            // 左下角缩小形成尾角
            _bubble_niche.layer.maskedCorners = [
                .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner
            ]
        }
        _bubbleGradLayer_niche?.frame = _bubble_niche.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _bubbleGradLayer_niche = nil
        _msgLabel_niche.text   = nil
        _timeLabel_niche.text  = nil
    }
}
