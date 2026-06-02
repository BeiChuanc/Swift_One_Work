import Foundation
import UIKit
import SnapKit

// MARK: 消息列表页面

/// 消息列表页面
/// 核心作用：响应式展示与当前用户存在聊天记录的用户列表，点击进入聊天
/// 设计思路：渐变头部（与 Discover 同款） + UITableView 会话卡片列表 + 空态视图
/// 关键属性：chatUsers_Breeze 有聊天记录的用户列表、subtitleLabel_Breeze 动态更新会话数
class MessageList_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 有聊天记录的用户列表
    private var chatUsers_Breeze: [PrewUserModel_Breeze] = []
    
    // MARK: - UI：渐变头部
    
    /// 头部渐变容器
    private let headerView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 头部渐变图层
    private var headerGradientLayer_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上角大圆
    private let decorLargeCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        view_breeze.layer.cornerRadius = 80
        return view_breeze
    }()
    
    /// 装饰圆 - 右侧中圆
    private let decorMedCircle_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view_breeze.layer.cornerRadius = 50
        return view_breeze
    }()
    
    /// 主标题
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Messages"
        label_breeze.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    /// 副标题（动态显示会话数）
    private let subtitleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    // MARK: - UI：列表区
    
    /// 会话列表
    private let tableView_Breeze: UITableView = {
        let tv_breeze = UITableView(frame: .zero, style: .plain)
        tv_breeze.backgroundColor = .clear
        tv_breeze.separatorStyle = .none
        tv_breeze.showsVerticalScrollIndicator = false
        tv_breeze.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 120, right: 0)
        return tv_breeze
    }()
    
    // MARK: - UI：空态视图
    
    /// 空态容器
    private let emptyView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.isHidden = true
        return view_breeze
    }()
    
    /// 空态图标
    private let emptyIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 52, weight: .thin)
        iv_breeze.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    /// 空态主文案
    private let emptyTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "No conversations yet"
        label_breeze.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 空态副文案
    private let emptySubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Start chatting from a fellow camper's profile"
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeaderGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    /// 主入口
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeaderView_Breeze()
        setupTableView_Breeze()
        setupEmptyView_Breeze()
    }
    
    /// 搭建渐变头部
    private func setupHeaderView_Breeze() {
        view.addSubview(headerView_Breeze)
        headerView_Breeze.addSubview(decorLargeCircle_Breeze)
        headerView_Breeze.addSubview(decorMedCircle_Breeze)
        headerView_Breeze.addSubview(titleLabel_Breeze)
        headerView_Breeze.addSubview(subtitleLabel_Breeze)
        
        headerView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorLargeCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.right.equalToSuperview().offset(42)
            make.top.equalToSuperview().offset(-32)
        }
        
        decorMedCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(decorLargeCircle_Breeze.snp.bottom).offset(-6)
        }
        
        titleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.left.equalToSuperview().offset(22)
        }
        
        subtitleLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Breeze.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(22)
            make.right.equalTo(decorLargeCircle_Breeze.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    /// 刷新头部渐变图层
    private func refreshHeaderGradient_Breeze() {
        headerGradientLayer_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: headerView_Breeze.bounds)
        headerView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradientLayer_Breeze = gradient_breeze
    }
    
    /// 搭建会话列表
    private func setupTableView_Breeze() {
        view.addSubview(tableView_Breeze)
        tableView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(headerView_Breeze.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        tableView_Breeze.dataSource = self
        tableView_Breeze.delegate = self
        tableView_Breeze.register(MessageListCell_Breeze.self,
                                   forCellReuseIdentifier: MessageListCell_Breeze.reuseId_Breeze)
    }
    
    /// 搭建空态视图
    private func setupEmptyView_Breeze() {
        view.addSubview(emptyView_Breeze)
        emptyView_Breeze.addSubview(emptyIcon_Breeze)
        emptyView_Breeze.addSubview(emptyTitle_Breeze)
        emptyView_Breeze.addSubview(emptySubtitle_Breeze)
        
        emptyView_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tableView_Breeze)
            make.left.right.equalToSuperview().inset(40)
        }
        
        emptyIcon_Breeze.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        
        emptyTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Breeze.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
        }
        
        emptySubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(emptyTitle_Breeze.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 通知
    
    /// 注册消息状态变化通知
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData_Breeze),
            name: MessageViewModel_Breeze.messageStateDidChangeNotification_Breeze,
            object: nil
        )
    }
    
    // MARK: - 数据
    
    /// 重新加载会话列表并同步头部副标题
    @objc private func reloadData_Breeze() {
        chatUsers_Breeze = MessageViewModel_Breeze.shared_Breeze.getChatUsers_Breeze()
        
        // 更新副标题
        let count_breeze = chatUsers_Breeze.count
        subtitleLabel_Breeze.text = count_breeze == 0
            ? "No active conversations"
            : "\(count_breeze) active conversation\(count_breeze > 1 ? "s" : "")"
        
        emptyView_Breeze.isHidden = !chatUsers_Breeze.isEmpty
        tableView_Breeze.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension MessageList_Breeze: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatUsers_Breeze.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_breeze = tableView.dequeueReusableCell(
            withIdentifier: MessageListCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? MessageListCell_Breeze else {
            return UITableViewCell()
        }
        let user_breeze = chatUsers_Breeze[indexPath.row]
        let lastMsg_breeze = MessageViewModel_Breeze.shared_Breeze
            .getLastMessageWithUser_Breeze(userId_breeze: user_breeze.userId_Breeze ?? 0)
        cell_breeze.configure_Breeze(user_breeze: user_breeze, lastMessage_breeze: lastMsg_breeze)
        return cell_breeze
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Navigation_Breeze.toMessageUser_Breeze(with: chatUsers_Breeze[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}

// MARK: - 消息列表单元格

/// 消息列表单元格
/// 核心作用：展示一个会话条目（头像+青绿边框圈/昵称/最后消息/时间）
/// 设计思路：白色卡片阴影 + 大头像（带 teal 边框环）+ 双行文字 + 右侧时间
class MessageListCell_Breeze: UITableViewCell {
    
    static let reuseId_Breeze = "MessageListCell_Breeze"
    
    // MARK: - UI 组件
    
    /// 卡片容器
    private let cardView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = .white
        view_breeze.layer.cornerRadius = 18
        view_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        view_breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_breeze.layer.shadowRadius = 10
        view_breeze.layer.shadowOpacity = 0.1
        return view_breeze
    }()
    
    /// 头像外圈（青绿渐变环）
    private let avatarRing_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.layer.cornerRadius = 28
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 头像渐变环图层
    private var ringGradientLayer_Breeze: CAGradientLayer?
    
    /// 头像视图
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    /// 用户昵称
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    /// 最后消息预览
    private let messageLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.numberOfLines = 1
        return label_breeze
    }()
    
    /// 时间标签（右上角，青绿色）
    private let timeLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        return label_breeze
    }()
    
    /// 右侧箭头图标
    private let arrowIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        iv_breeze.image = UIImage(systemName: "chevron.right", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
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
        
        contentView.addSubview(cardView_Breeze)
        cardView_Breeze.addSubview(avatarRing_Breeze)
        avatarRing_Breeze.addSubview(avatarView_Breeze)
        cardView_Breeze.addSubview(nameLabel_Breeze)
        cardView_Breeze.addSubview(messageLabel_Breeze)
        cardView_Breeze.addSubview(timeLabel_Breeze)
        cardView_Breeze.addSubview(arrowIcon_Breeze)
        
        cardView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 头像外圈（56pt = 头像 50pt + 3pt 各边渐变环）
        avatarRing_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        // 头像（内缩 3pt 让渐变环露出）
        avatarView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalTo(avatarRing_Breeze.snp.right).offset(12)
            make.right.lessThanOrEqualTo(timeLabel_Breeze.snp.left).offset(-8)
        }
        
        timeLabel_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel_Breeze)
            make.right.equalTo(arrowIcon_Breeze.snp.left).offset(-6)
        }
        
        arrowIcon_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel_Breeze)
            make.right.equalToSuperview().offset(-14)
            make.width.height.equalTo(12)
        }
        
        messageLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Breeze.snp.bottom).offset(6)
            make.left.equalTo(avatarRing_Breeze.snp.right).offset(12)
            make.right.equalTo(arrowIcon_Breeze.snp.left).offset(-8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshAvatarRingGradient_Breeze()
    }
    
    /// 刷新头像外圈渐变（teal → skyBlue，环绕）
    private func refreshAvatarRingGradient_Breeze() {
        ringGradientLayer_Breeze?.removeFromSuperlayer()
        guard !avatarRing_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = avatarRing_Breeze.bounds
        gradient_breeze.colors = [
            ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
            ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
        ]
        gradient_breeze.startPoint = CGPoint(x: 0, y: 0)
        gradient_breeze.endPoint = CGPoint(x: 1, y: 1)
        avatarRing_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        ringGradientLayer_Breeze = gradient_breeze
    }
    
    // MARK: - 数据配置
    
    /// 配置会话条目展示内容
    /// - Parameters:
    ///   - user_breeze: 会话用户模型
    ///   - lastMessage_breeze: 最近一条消息（可为空）
    func configure_Breeze(user_breeze: PrewUserModel_Breeze, lastMessage_breeze: MessageModel_Breeze?) {
        avatarView_Breeze.configure_Breeze(userId_Breeze: user_breeze.userId_Breeze ?? 0)
        nameLabel_Breeze.text = user_breeze.userName_Breeze ?? "Camper"
        messageLabel_Breeze.text = lastMessage_breeze?.content_Breeze ?? "Say hello to start the conversation"
        timeLabel_Breeze.text = lastMessage_breeze?.time_Breeze ?? ""
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ringGradientLayer_Breeze = nil
    }
}
