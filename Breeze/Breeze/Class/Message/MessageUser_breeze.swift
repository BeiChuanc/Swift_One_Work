import Foundation
import UIKit
import SnapKit

// MARK: 与用户聊天页面

/// 与用户聊天页面
/// 核心作用：一对一聊天；顶部渐变导航栏展示用户信息，气泡列表显示消息，底部输入栏发送
/// 设计思路：渐变头部（与 Discover 同款）内嵌用户信息卡 + 气泡列表 + 白色磨砂输入栏
/// 关键属性：userModel_Breeze 聊天对象、messages_Breeze 消息列表
class MessageUser_Breeze: UIViewController {
    
    /// 聊天用户
    var userModel_Breeze: PrewUserModel_Breeze?
    
    // MARK: - 数据
    
    /// 消息列表
    private var messages_Breeze: [MessageModel_Breeze] = []
    
    // MARK: - UI：渐变头部导航栏
    
    /// 头部渐变容器
    private let headerView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 头部渐变图层
    private var headerGradientLayer_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右侧
    private let decorCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view_breeze.layer.cornerRadius = 55
        return view_breeze
    }()
    
    /// 返回按钮（白色）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 头像视图（居中）
    private let headerAvatar_Breeze = UserAvatarView_Breeze()
    
    /// 头像外圈（白色环）
    private let headerAvatarRing_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view_breeze.layer.cornerRadius = 26
        return view_breeze
    }()
    
    /// 用户名（居中，白色）
    private let headerName_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 用户简介（居中，半透明白）
    private let headerIntro_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 1
        return label_breeze
    }()
    
    /// 头部中央可点击区域（进入用户主页）
    private let headerTapArea_Breeze = UIControl()
    
    /// 举报按钮容器
    private let reportContainer_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view_breeze.layer.cornerRadius = 18
        return view_breeze
    }()
    
    // MARK: - UI：消息列表
    
    /// 消息气泡列表
    private let tableView_Breeze: UITableView = {
        let tv_breeze = UITableView(frame: .zero, style: .plain)
        tv_breeze.backgroundColor = .clear
        tv_breeze.separatorStyle = .none
        tv_breeze.showsVerticalScrollIndicator = false
        tv_breeze.keyboardDismissMode = .onDrag
        tv_breeze.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return tv_breeze
    }()
    
    // MARK: - UI：输入栏
    
    /// 输入栏容器（白色，顶部阴影）
    private let inputBar_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = .white
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: -3)
        view_breeze.layer.shadowRadius = 10
        view_breeze.layer.shadowOpacity = 0.1
        return view_breeze
    }()
    
    /// 输入框（薄荷背景圆角）
    private let inputField_Breeze: UITextField = {
        let field_breeze = UITextField()
        field_breeze.font = UIFont.systemFont(ofSize: 14)
        field_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        field_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        field_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        field_breeze.layer.cornerRadius = 20
        field_breeze.returnKeyType = .send
        field_breeze.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field_breeze.leftViewMode = .always
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        field_breeze.attributedPlaceholder = NSAttributedString(
            string: "Type a message...",
            attributes: attrs_breeze
        )
        return field_breeze
    }()
    
    /// 发送按钮（渐变圆形）
    private let sendButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_breeze.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.layer.cornerRadius = 20
        return btn_breeze
    }()
    
    /// 发送按钮渐变图层
    private var sendGradient_Breeze: CAGradientLayer?
    
    /// 输入栏底部约束（随键盘弹起调整）
    private var inputBarBottomConstraint_Breeze: Constraint?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        configureUser_Breeze()
        reloadData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Breeze()
        refreshSendButtonGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    /// 主入口
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderView_Breeze()
        setupInputBar_Breeze()
        setupTableView_Breeze()
        setupReportButton_Breeze()
    }
    
    // MARK: - 头部渐变导航栏
    
    /// 搭建渐变头部（返回键 + 中央用户信息 + 举报按钮）
    private func setupHeaderView_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorCircle_Breeze)
        headerView_Breeze.addSubview(backButton_Breeze)
        headerView_Breeze.addSubview(headerTapArea_Breeze)
        headerTapArea_Breeze.addSubview(headerAvatarRing_Breeze)
        headerAvatarRing_Breeze.addSubview(headerAvatar_Breeze)
        headerTapArea_Breeze.addSubview(headerName_Breeze)
        headerTapArea_Breeze.addSubview(headerIntro_Breeze)
        headerView_Breeze.addSubview(reportContainer_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        // 装饰圆 - 右上角
        decorCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.right.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-22)
        }
        
        // 返回按钮 - 左侧
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        // 举报容器 - 右侧
        reportContainer_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Breeze)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        
        // 头部可点击区域（头像 + 名字 + 简介，居中）
        headerTapArea_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalTo(backButton_Breeze.snp.right).offset(8)
            make.right.equalTo(reportContainer_Breeze.snp.left).offset(-8)
        }
        
        // 头像外圈
        headerAvatarRing_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        // 头像（内缩 3pt）
        headerAvatar_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(46)
        }
        
        headerName_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerAvatarRing_Breeze.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(4)
        }
        
        headerIntro_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerName_Breeze.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        // headerView 底部约束：由 headerTapArea 底部决定，确保 tableView 正确定位
        headerView_Breeze.snp.makeConstraints { make in
            make.bottom.equalTo(headerTapArea_Breeze.snp.bottom).offset(16)
        }
        
        // 事件
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
        headerTapArea_Breeze.addAction(
            UIAction { [weak self] _ in self?.openUserInfo_Breeze() },
            for: .touchUpInside
        )
    }
    
    /// 刷新头部渐变图层
    private func refreshHeaderGradient_Breeze() {
        headerGradientLayer_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradientLayer_Breeze = gradient_breeze
    }
    
    // MARK: - 输入栏
    
    /// 搭建底部输入栏（输入框 + 发送按钮）
    private func setupInputBar_Breeze() {
        view.addSubview(inputBar_Breeze)
        inputBar_Breeze.addSubview(inputField_Breeze)
        inputBar_Breeze.addSubview(sendButton_Breeze)
        
        inputBar_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Breeze = make.bottom.equalToSuperview().constraint
            make.height.equalTo(64 + (view.window?.safeAreaInsets.bottom ?? 0))
        }
        
        inputField_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalTo(sendButton_Breeze.snp.left).offset(-10)
            make.height.equalTo(40)
        }
        
        sendButton_Breeze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(inputField_Breeze)
            make.width.height.equalTo(40)
        }
        
        sendButton_Breeze.addTarget(self, action: #selector(handleSend_Breeze), for: .touchUpInside)
        inputField_Breeze.delegate = self
    }
    
    /// 刷新发送按钮渐变图层
    private func refreshSendButtonGradient_Breeze() {
        guard !sendButton_Breeze.bounds.isEmpty else { return }
        sendGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: sendButton_Breeze.bounds)
        gradient_breeze.cornerRadius = sendButton_Breeze.layer.cornerRadius
        sendButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        sendGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 消息列表
    
    /// 搭建气泡消息列表
    private func setupTableView_Breeze() {
        view.addSubview(tableView_Breeze)
        tableView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar_Breeze.snp.top)
        }
        tableView_Breeze.dataSource = self
        tableView_Breeze.rowHeight = UITableView.automaticDimension
        tableView_Breeze.estimatedRowHeight = 60
        tableView_Breeze.register(ChatBubbleCell_Breeze.self,
                                   forCellReuseIdentifier: ChatBubbleCell_Breeze.reuseId_Breeze)
    }
    
    // MARK: - 举报按钮
    
    /// 配置举报按钮（白色圆形，嵌入 reportContainer）
    private func setupReportButton_Breeze() {
        let button_breeze = ReportDeleteHelper_Breeze.createUserReportButton_Breeze(
            size_Breeze: 36,
            backgroundColor_Breeze: .clear,
            tintColor_Breeze: .white,
            withShadow_Breeze: false
        )
        button_breeze.addTarget(self, action: #selector(handleReport_Breeze), for: .touchUpInside)
        reportContainer_Breeze.addSubview(button_breeze)
        button_breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - 数据配置
    
    /// 配置头部用户信息
    private func configureUser_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        headerAvatar_Breeze.configure_Breeze(userId_Breeze: user_breeze.userId_Breeze ?? 0)
        headerName_Breeze.text = user_breeze.userName_Breeze ?? "Camper"
        headerIntro_Breeze.text = user_breeze.userIntroduce_Breeze ?? "A fellow park camper"
    }
    
    // MARK: - 通知监听
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData_Breeze),
            name: MessageViewModel_Breeze.messageStateDidChangeNotification_Breeze,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange_Breeze(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Breeze(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - 数据刷新
    
    @objc private func reloadData_Breeze() {
        guard let userId_breeze = userModel_Breeze?.userId_Breeze else { return }
        messages_Breeze = MessageViewModel_Breeze.shared_Breeze.getMessagesWithUser_Breeze(userId_breeze: userId_breeze)
        tableView_Breeze.reloadData()
        scrollToBottom_Breeze()
    }
    
    /// 滚动到最新消息
    private func scrollToBottom_Breeze() {
        guard !messages_Breeze.isEmpty else { return }
        let indexPath_breeze = IndexPath(row: messages_Breeze.count - 1, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.tableView_Breeze.scrollToRow(at: indexPath_breeze, at: .bottom, animated: true)
        }
    }
    
    // MARK: - 事件
    
    /// 返回上一页
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 发送消息
    @objc private func handleSend_Breeze() {
        guard let userId_breeze = userModel_Breeze?.userId_Breeze else { return }
        let text_breeze = inputField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_breeze.isEmpty else {
            inputField_Breeze.animateShake_Breeze()
            return
        }
        MessageViewModel_Breeze.shared_Breeze.sendMessage_Breeze(
            message_breeze: text_breeze,
            chatType_breeze: .personal_breeze,
            id_breeze: userId_breeze
        )
        inputField_Breeze.text = ""
    }
    
    /// 举报用户
    @objc private func handleReport_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        ReportDeleteHelper_Breeze.block_Breeze(user_Breeze: user_breeze, from: self) { [weak self] in
            guard let self else { return }
            Navigation_Breeze.popToSafeStateAfterBlock_Breeze(from: self)
        }
    }
    
    /// 进入用户主页（从聊天入口）
    private func openUserInfo_Breeze() {
        guard let user_breeze = userModel_Breeze else { return }
        Navigation_Breeze.toUserInfo_Breeze(with: user_breeze, fromChat_breeze: true)
    }
    
    // MARK: - 键盘处理
    
    @objc private func keyboardWillChange_Breeze(_ notification: Notification) {
        guard let frame_breeze = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let keyboardHeight_breeze = view.bounds.height - frame_breeze.origin.y
        let offset_breeze = keyboardHeight_breeze > 0 ? -keyboardHeight_breeze + view.safeAreaInsets.bottom : 0
        inputBarBottomConstraint_Breeze?.update(offset: offset_breeze)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        scrollToBottom_Breeze()
    }
    
    @objc private func keyboardWillHide_Breeze(_ notification: Notification) {
        inputBarBottomConstraint_Breeze?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource

extension MessageUser_Breeze: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_Breeze.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_breeze = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? ChatBubbleCell_Breeze else {
            return UITableViewCell()
        }
        cell_breeze.configure_Breeze(
            message_breeze: messages_Breeze[indexPath.row],
            otherUserId_breeze: userModel_Breeze?.userId_Breeze ?? 0
        )
        return cell_breeze
    }
}

// MARK: - UITextFieldDelegate

extension MessageUser_Breeze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Breeze()
        return true
    }
}

// MARK: - 聊天气泡单元格

/// 聊天气泡单元格
/// 核心作用：根据消息归属左右展示气泡（我方=渐变色右对齐；对方=白色卡片左对齐+头像）
/// 设计思路：气泡用 CAGradientLayer 实现渐变；`layoutSubviews` 刷新渐变帧；时间标签紧贴气泡下方
/// 关键属性：isMine_Breeze 记录归属，用于 layoutSubviews 判断是否刷新渐变
class ChatBubbleCell_Breeze: UITableViewCell {
    
    static let reuseId_Breeze = "ChatBubbleCell_Breeze"
    
    // MARK: - UI 组件
    
    /// 对方头像
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    /// 气泡容器
    private let bubbleView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.layer.cornerRadius = 18
        return view_breeze
    }()
    
    /// 消息文字
    private let messageLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    /// 时间标签（气泡正下方）
    private let timeLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        return label_breeze
    }()
    
    /// 我方气泡渐变图层
    private var bubbleGradient_Breeze: CAGradientLayer?
    
    /// 当前消息是否为我方发送（供 layoutSubviews 判断）
    private var isMine_Breeze: Bool = false
    
    // MARK: - 约束组
    
    /// 我方约束（气泡靠右，时间标签靠右）
    private var mineConstraints_Breeze: [Constraint] = []
    /// 对方约束（气泡靠头像右侧，时间标签靠左）
    private var otherConstraints_Breeze: [Constraint] = []
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(avatarView_Breeze)
        contentView.addSubview(bubbleView_Breeze)
        bubbleView_Breeze.addSubview(messageLabel_Breeze)
        contentView.addSubview(timeLabel_Breeze)
        
        // 对方头像 - 始终左对齐
        avatarView_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(34)
        }
        
        // 消息文字 - 气泡内边距
        messageLabel_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 11, left: 14, bottom: 11, right: 14))
        }
        
        // 气泡 - 宽度上限 68%
        bubbleView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.width.lessThanOrEqualTo(APPSCREEN_Breeze.WIDTH_Breeze * 0.68)
        }
        
        // 时间标签 - 紧贴气泡下方
        timeLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(bubbleView_Breeze.snp.bottom).offset(3)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        // 我方约束
        bubbleView_Breeze.snp.prepareConstraints { make in
            mineConstraints_Breeze.append(make.right.equalToSuperview().offset(-14).constraint)
        }
        timeLabel_Breeze.snp.prepareConstraints { make in
            mineConstraints_Breeze.append(make.right.equalTo(bubbleView_Breeze).constraint)
        }
        
        // 对方约束
        bubbleView_Breeze.snp.prepareConstraints { make in
            otherConstraints_Breeze.append(make.left.equalTo(avatarView_Breeze.snp.right).offset(8).constraint)
        }
        timeLabel_Breeze.snp.prepareConstraints { make in
            otherConstraints_Breeze.append(make.left.equalTo(bubbleView_Breeze).constraint)
        }
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 我方气泡在尺寸确定后更新渐变图层
        if isMine_Breeze { refreshBubbleGradient_Breeze() }
    }
    
    /// 刷新我方气泡渐变（teal → skyBlue，水平方向）
    private func refreshBubbleGradient_Breeze() {
        bubbleGradient_Breeze?.removeFromSuperlayer()
        guard !bubbleView_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = bubbleView_Breeze.bounds
        gradient_breeze.colors = [
            ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
        ]
        gradient_breeze.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_breeze.endPoint = CGPoint(x: 1, y: 0.5)
        gradient_breeze.cornerRadius = bubbleView_Breeze.layer.cornerRadius
        bubbleView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        bubbleGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 数据配置
    
    /// 配置气泡展示内容
    /// - Parameters:
    ///   - message_breeze: 消息模型
    ///   - otherUserId_breeze: 对方用户 ID（用于显示头像）
    func configure_Breeze(message_breeze: MessageModel_Breeze, otherUserId_breeze: Int) {
        let isMine_breeze = message_breeze.isMine_Breeze ?? false
        isMine_Breeze = isMine_breeze
        
        messageLabel_Breeze.text = message_breeze.content_Breeze
        timeLabel_Breeze.text = message_breeze.time_Breeze ?? ""
        
        // 停用所有约束后重新激活对应侧
        mineConstraints_Breeze.forEach { $0.deactivate() }
        otherConstraints_Breeze.forEach { $0.deactivate() }
        
        if isMine_breeze {
            avatarView_Breeze.isHidden = true
            // 气泡纯色先占位，layoutSubviews 再换渐变
            bubbleView_Breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
            bubbleGradient_Breeze?.removeFromSuperlayer()
            bubbleGradient_Breeze = nil
            bubbleView_Breeze.layer.shadowOpacity = 0
            messageLabel_Breeze.textColor = .white
            mineConstraints_Breeze.forEach { $0.activate() }
        } else {
            avatarView_Breeze.isHidden = false
            avatarView_Breeze.configure_Breeze(userId_Breeze: otherUserId_breeze)
            // 对方气泡：白色卡片 + 微阴影
            bubbleGradient_Breeze?.removeFromSuperlayer()
            bubbleGradient_Breeze = nil
            bubbleView_Breeze.backgroundColor = .white
            bubbleView_Breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
            bubbleView_Breeze.layer.shadowOffset = CGSize(width: 0, height: 2)
            bubbleView_Breeze.layer.shadowRadius = 6
            bubbleView_Breeze.layer.shadowOpacity = 0.1
            messageLabel_Breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
            otherConstraints_Breeze.forEach { $0.activate() }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleGradient_Breeze?.removeFromSuperlayer()
        bubbleGradient_Breeze = nil
        isMine_Breeze = false
    }
}
