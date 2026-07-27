import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页

/// 帖子详情页
/// 核心作用：展示媒体/作者/正文/点赞/评论，支持举报删除，数据变动自动响应
/// 设计思路：全屏媒体图 + 底部上浮白色内容卡片 + 评论卡片列表 + 渐变发送按钮；通知驱动刷新
/// 关键属性：titleModel_Breeze 当前帖子、comments_Breeze 评论数组
class Detail_Breeze: UIViewController {

    var titleModel_Breeze: TitleModel_Breeze?
    
    // MARK: - 数据
    
    private var comments_Breeze: [Comment_Breeze] = []
    
    // MARK: - UI：浮层导航按钮
    
    /// 返回按钮（半透明圆形，浮于媒体之上）
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        btn_breeze.layer.cornerRadius = 20
        return btn_breeze
    }()
    
    /// 举报/删除按钮容器
    private let actionContainer_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        v_breeze.layer.cornerRadius = 20
        return v_breeze
    }()
    private var actionButton_Breeze: UIButton?
    
    // MARK: - UI：评论列表
    
    private let tableView_Breeze: UITableView = {
        let tv_breeze = UITableView(frame: .zero, style: .plain)
        tv_breeze.backgroundColor = .clear
        tv_breeze.separatorStyle = .none
        tv_breeze.showsVerticalScrollIndicator = false
        tv_breeze.keyboardDismissMode = .onDrag
        tv_breeze.contentInsetAdjustmentBehavior = .never
        return tv_breeze
    }()
    
    // MARK: - UI：输入栏
    
    private let inputBar_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_breeze.layer.shadowRadius = 10
        v_breeze.layer.shadowOpacity = 0.1
        return v_breeze
    }()
    
    private let commentField_Breeze: UITextField = {
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
        field_breeze.attributedPlaceholder = NSAttributedString(string: "Share your thoughts...", attributes: attrs_breeze)
        return field_breeze
    }()
    
    private let sendButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_breeze.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.layer.cornerRadius = 20
        return btn_breeze
    }()
    
    private var sendGradient_Breeze: CAGradientLayer?
    private var inputBarBottomConstraint_Breeze: Constraint?
    
    /// 送礼按钮（原图，大小与发送按钮一致）
    private let giftButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .custom)
        btn_breeze.setImage(
            UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btn_breeze.imageView?.contentMode = .scaleAspectFit
        return btn_breeze
    }()
    
    // MARK: - 表头组件
    
    private let headerContainer_Breeze = UIView()
    
    /// 媒体视图（全屏宽，固定高度，点击可全屏浏览）
    private let mediaView_Breeze: MediaDisplayView_Breeze = {
        let v_breeze = MediaDisplayView_Breeze()
        v_breeze.isUserInteractionEnabled = true
        return v_breeze
    }()
    
    /// 媒体底部渐变遮罩（黑色渐入，提升内容卡视觉层次）
    private let mediaGradientView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.isUserInteractionEnabled = false
        return v_breeze
    }()
    
    /// 内容区白色上浮卡（圆角顶部，覆盖媒体底部）
    private let contentCard_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 28
        v_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_breeze
    }()
    
    /// 作者信息行（头像 + 名字 + 分类徽章 + 跳转箭头）
    private let avatarRow_Breeze = TappableAvatarRow_Breeze()
    
    /// 分割线
    private let dividerLine_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.divider_Breeze
        return v_breeze
    }()
    
    private let postTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    private let postContent_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    /// 点赞按钮（珊瑚红）
    private let likeButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn_breeze.setImage(UIImage(systemName: "heart", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = ColorConfig_Breeze.accentCoral_Breeze
        return btn_breeze
    }()
    
    private let likeCount_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    /// 评论数展示（图标 + 数字）
    private let commentIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iv_breeze.image = UIImage(systemName: "bubble.left", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    private let commentCount_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    /// 评论区标题
    private let commentsSectionTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Comments"
        label_breeze.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    /// 评论区标题左侧青绿竖线
    private let commentAccentBar_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        v_breeze.layer.cornerRadius = 2
        return v_breeze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        renderData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshSendGradient_Breeze()
        refreshMediaGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        
        view.addSubview(tableView_Breeze)
        view.addSubview(inputBar_Breeze)
        view.addSubview(backButton_Breeze)
        view.addSubview(actionContainer_Breeze)
        
        inputBar_Breeze.addSubview(commentField_Breeze)
        inputBar_Breeze.addSubview(giftButton_Breeze)
        inputBar_Breeze.addSubview(sendButton_Breeze)
        
        inputBar_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Breeze = make.bottom.equalToSuperview().constraint
            make.height.equalTo(64 + (view.window?.safeAreaInsets.bottom ?? 0))
        }
        // 发送按钮：最右侧
        sendButton_Breeze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(commentField_Breeze)
            make.width.height.equalTo(40)
        }
        // 礼物按钮：发送按钮左侧 10pt
        giftButton_Breeze.snp.makeConstraints { make in
            make.right.equalTo(sendButton_Breeze.snp.left).offset(-10)
            make.centerY.equalTo(sendButton_Breeze)
            make.width.height.equalTo(40)
        }
        // 输入框右边界对齐礼物按钮左侧
        commentField_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(40)
            make.right.equalTo(giftButton_Breeze.snp.left).offset(-10)
        }
        
        tableView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar_Breeze.snp.top)
        }
        tableView_Breeze.dataSource = self
        tableView_Breeze.delegate = self
        tableView_Breeze.register(DetailCommentCell_Breeze.self, forCellReuseIdentifier: DetailCommentCell_Breeze.reuseId_Breeze)
        
        // 浮层返回按钮
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
        }
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
        
        // 浮层举报/删除按钮
        actionContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }
        
        buildHeader_Breeze()
        
        likeButton_Breeze.addTarget(self, action: #selector(handleLike_Breeze), for: .touchUpInside)
        sendButton_Breeze.addTarget(self, action: #selector(handleSend_Breeze), for: .touchUpInside)
        giftButton_Breeze.addTarget(self, action: #selector(handleGift_Breeze), for: .touchUpInside)
        commentField_Breeze.delegate = self
        avatarRow_Breeze.onTapped_Breeze = { [weak self] in self?.openAuthor_Breeze() }
    }
    
    /// 搭建表头布局（媒体 + 上浮内容卡 + 点赞行 + 评论标题）
    private func buildHeader_Breeze() {
        // 媒体区
        headerContainer_Breeze.addSubview(mediaView_Breeze)
        headerContainer_Breeze.addSubview(mediaGradientView_Breeze)
        
        // 上浮内容卡
        headerContainer_Breeze.addSubview(contentCard_Breeze)
        contentCard_Breeze.addSubview(avatarRow_Breeze)
        contentCard_Breeze.addSubview(dividerLine_Breeze)
        contentCard_Breeze.addSubview(postTitle_Breeze)
        contentCard_Breeze.addSubview(postContent_Breeze)
        contentCard_Breeze.addSubview(likeButton_Breeze)
        contentCard_Breeze.addSubview(likeCount_Breeze)
        contentCard_Breeze.addSubview(commentIcon_Breeze)
        contentCard_Breeze.addSubview(commentCount_Breeze)
        contentCard_Breeze.addSubview(commentAccentBar_Breeze)
        contentCard_Breeze.addSubview(commentsSectionTitle_Breeze)
        
        let mediaHeight_breeze = APPSCREEN_Breeze.WIDTH_Breeze * 0.75
        
        mediaView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(mediaHeight_breeze)
        }
        
        mediaGradientView_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(mediaView_Breeze)
            make.height.equalTo(100)
        }
        
        // 内容卡从媒体底部上浮 28pt（圆角半径 = 28）
        contentCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Breeze.snp.bottom).offset(-28)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 作者行
        avatarRow_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.lessThanOrEqualToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        // 分割线
        dividerLine_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarRow_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }
        
        // 标题
        postTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(dividerLine_Breeze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 正文
        postContent_Breeze.snp.makeConstraints { make in
            make.top.equalTo(postTitle_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 点赞行
        likeButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(postContent_Breeze.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        likeCount_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Breeze)
            make.left.equalTo(likeButton_Breeze.snp.right).offset(6)
        }
        commentIcon_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Breeze)
            make.left.equalTo(likeCount_Breeze.snp.right).offset(20)
            make.width.height.equalTo(22)
        }
        commentCount_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Breeze)
            make.left.equalTo(commentIcon_Breeze.snp.right).offset(6)
        }
        
        // 评论区标题（左侧青绿竖条 + 文字）
        // 注意：不能再 pin bottom 到 contentCard.bottom，否则与 top 约束冲突导致高度被撑满
        commentAccentBar_Breeze.snp.makeConstraints { make in
            make.top.equalTo(likeButton_Breeze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(4)
            make.height.equalTo(18)
        }
        commentsSectionTitle_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(commentAccentBar_Breeze)
            make.left.equalTo(commentAccentBar_Breeze.snp.right).offset(8)
        }
        
        // 媒体区点击 → 全屏浏览
        let mediaTap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Breeze))
        mediaView_Breeze.addGestureRecognizer(mediaTap_breeze)
    }
    
    /// 刷新发送按钮渐变图层
    private func refreshSendGradient_Breeze() {
        guard !sendButton_Breeze.bounds.isEmpty else { return }
        sendGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: sendButton_Breeze.bounds)
        gradient_breeze.cornerRadius = sendButton_Breeze.layer.cornerRadius
        sendButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        sendGradient_Breeze = gradient_breeze
    }
    
    /// 刷新媒体底部渐变遮罩（黑色渐入）
    private func refreshMediaGradient_Breeze() {
        guard !mediaGradientView_Breeze.bounds.isEmpty else { return }
        mediaGradientView_Breeze.layer.sublayers?.removeAll()
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = mediaGradientView_Breeze.bounds
        gradient_breeze.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.35).cgColor]
        gradient_breeze.locations = [0.0, 1.0]
        mediaGradientView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
    }
    
    /// 计算并设置表头高度
    private func layoutHeader_Breeze() {
        let width_breeze = APPSCREEN_Breeze.WIDTH_Breeze
        headerContainer_Breeze.frame = CGRect(x: 0, y: 0, width: width_breeze, height: 2000)
        headerContainer_Breeze.setNeedsLayout()
        headerContainer_Breeze.layoutIfNeeded()
        // commentAccentBar 在 contentCard 坐标系内，需加上 contentCard 的 Y 偏移，换算到 headerContainer 坐标系
        let height_breeze = contentCard_Breeze.frame.origin.y + commentAccentBar_Breeze.frame.maxY + 14
        headerContainer_Breeze.frame = CGRect(x: 0, y: 0, width: width_breeze, height: height_breeze)
        tableView_Breeze.tableHeaderView = headerContainer_Breeze
    }
    
    // MARK: - 通知
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChange_Breeze),
                                               name: TitleViewModel_Breeze.titleStateDidChangeNotification_Breeze, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange_Breeze(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Breeze(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleStateChange_Breeze() {
        guard let id_breeze = titleModel_Breeze?.titleId_Breeze else { return }
        let posts_breeze = TitleViewModel_Breeze.shared_Breeze.getPosts_Breeze()
        guard let latest_breeze = posts_breeze.first(where: { $0.titleId_Breeze == id_breeze }) else {
            navigationController?.popViewController(animated: true)
            return
        }
        titleModel_Breeze = latest_breeze
        renderData_Breeze()
    }
    
    // MARK: - 渲染
    
    private func renderData_Breeze() {
        guard let post_breeze = titleModel_Breeze else { return }
        
        postTitle_Breeze.text = post_breeze.title_Breeze
        postContent_Breeze.text = post_breeze.titleContent_Breeze
        likeCount_Breeze.text = "\(post_breeze.likes_Breeze)"
        commentCount_Breeze.text = "\(post_breeze.reviews_Breeze.count)"
        mediaView_Breeze.configure_Breeze(mediaPath_Breeze: post_breeze.titleMeidas_Breeze.first)
        avatarRow_Breeze.configure_Breeze(userId_breeze: post_breeze.titleUserId_Breeze,
                                          name_breeze: post_breeze.titleUserName_Breeze,
                                          category_breeze: post_breeze.titleCategory_Breeze)
        
        // 点赞状态
        let liked_breeze = TitleViewModel_Breeze.shared_Breeze.isLikedPost_Breeze(post_breeze: post_breeze)
        let iconName_breeze = liked_breeze ? "heart.fill" : "heart"
        let iconConf_breeze = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        likeButton_Breeze.setImage(UIImage(systemName: iconName_breeze, withConfiguration: iconConf_breeze), for: .normal)
        
        rebuildActionButton_Breeze(post_breeze: post_breeze)
        
        // 过滤掉被拉黑/举报用户发布的评论（非当前登录用户且已从用户列表移除）
        comments_Breeze = post_breeze.reviews_Breeze.filter { comment_breeze in
            !UserViewModel_Breeze.shared_Breeze.isUserBlocked_Breeze(
                userId_breeze: comment_breeze.commentUserId_Breeze
            )
        }
        layoutHeader_Breeze()
        tableView_Breeze.reloadData()
    }
    
    private func rebuildActionButton_Breeze(post_breeze: TitleModel_Breeze) {
        actionButton_Breeze?.removeFromSuperview()
        let btn_breeze = ReportDeleteHelper_Breeze.createPostReportButton_Breeze(
            post_Breeze: post_breeze,
            size_Breeze: 16,
            color_Breeze: .white,
            from: self
        ) { [weak self] in self?.handleStateChange_Breeze() }
        actionContainer_Breeze.addSubview(btn_breeze)
        btn_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        actionButton_Breeze = btn_breeze
    }
    
    // MARK: - 事件
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleLike_Breeze() {
        guard let post_breeze = titleModel_Breeze else { return }
        likeButton_Breeze.animatePulse_Breeze()
        TitleViewModel_Breeze.shared_Breeze.likePost_Breeze(post_breeze: post_breeze)
    }
    
    @objc private func handleSend_Breeze() {
        guard let post_breeze = titleModel_Breeze else { return }
        let text_breeze = commentField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_breeze.isEmpty else { commentField_Breeze.animateShake_Breeze(); return }
        TitleViewModel_Breeze.shared_Breeze.releaseComment_Breeze(post_breeze: post_breeze, content_breeze: text_breeze)
        commentField_Breeze.text = ""
        commentField_Breeze.resignFirstResponder()
    }
    
    /// 点击礼物按钮：底部弹出送礼页面
    @objc private func handleGift_Breeze() {
        let giftPage_breeze = GiftPage_Breeze()
        giftPage_breeze.modalPresentationStyle = .overFullScreen
        giftPage_breeze.modalTransitionStyle = .crossDissolve
        present(giftPage_breeze, animated: true)
    }
    
    private func openAuthor_Breeze() {
        guard let post_breeze = titleModel_Breeze else { return }
        if UserViewModel_Breeze.shared_Breeze.isCurrentUser_Breeze(userId_breeze: post_breeze.titleUserId_Breeze) {
            Navigation_Breeze.toMe_Breeze()
        } else {
            let user_breeze = UserViewModel_Breeze.shared_Breeze.getUserById_Breeze(userId_breeze: post_breeze.titleUserId_Breeze)
            Navigation_Breeze.toUserInfo_Breeze(with: user_breeze)
        }
    }
    
    /// 点击媒体区域 → present 全屏媒体浏览页
    @objc private func handleMediaTap_Breeze() {
        guard let mediaPath_breeze = titleModel_Breeze?.titleMeidas_Breeze.first else { return }
        let player_breeze = MediaPlayerPage_Breeze()
        player_breeze.mediaPath_Breeze = mediaPath_breeze
        player_breeze.isVideo_Breeze = false
        player_breeze.modalPresentationStyle = .overFullScreen
        player_breeze.modalTransitionStyle = .crossDissolve
        present(player_breeze, animated: true)
    }
    
    // MARK: - 键盘
    
    @objc private func keyboardWillChange_Breeze(_ notification: Notification) {
        guard let frame_breeze = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let kbHeight_breeze = view.bounds.height - frame_breeze.origin.y
        let offset_breeze = kbHeight_breeze > 0 ? -kbHeight_breeze + view.safeAreaInsets.bottom : 0
        inputBarBottomConstraint_Breeze?.update(offset: offset_breeze)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc private func keyboardWillHide_Breeze(_ notification: Notification) {
        inputBarBottomConstraint_Breeze?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITableViewDataSource / Delegate

extension Detail_Breeze: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments_Breeze.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_breeze = tableView.dequeueReusableCell(
            withIdentifier: DetailCommentCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as? DetailCommentCell_Breeze, let post_breeze = titleModel_Breeze else {
            return UITableViewCell()
        }
        cell_breeze.configure_Breeze(comment_breeze: comments_Breeze[indexPath.row],
                                     post_breeze: post_breeze, host_breeze: self)
        return cell_breeze
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 88 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
}

// MARK: - UITextFieldDelegate

extension Detail_Breeze: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend_Breeze(); return true
    }
}

// MARK: - 可点击作者行组件

/// 可点击作者行（头像 + 昵称 + 分类徽章 + 跳转箭头）
/// 核心作用：在详情页展示作者信息并支持跳转其主页
class TappableAvatarRow_Breeze: UIView {
    
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    /// 分类徽章（彩色胶囊）
    private let categoryBadge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.layer.cornerRadius = 9
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var badgeGradient_Breeze: CAGradientLayer?
    
    private let categoryLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    private let chevron_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv_breeze.image = UIImage(systemName: "chevron.right", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.textPlaceholder_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    var onTapped_Breeze: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI_Breeze() {
        addSubview(avatarView_Breeze)
        addSubview(nameLabel_Breeze)
        addSubview(categoryBadge_Breeze)
        categoryBadge_Breeze.addSubview(categoryLabel_Breeze)
        addSubview(chevron_Breeze)
        
        avatarView_Breeze.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        nameLabel_Breeze.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Breeze.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        categoryBadge_Breeze.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Breeze.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
        }
        categoryLabel_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(7)
            make.right.equalToSuperview().offset(-7)
            make.centerY.equalToSuperview()
        }
        chevron_Breeze.snp.makeConstraints { make in
            make.left.equalTo(categoryBadge_Breeze.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
            make.right.equalToSuperview()
        }
        
        let tap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleTap_Breeze))
        addGestureRecognizer(tap_breeze)
        isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        badgeGradient_Breeze?.removeFromSuperlayer()
        guard !categoryBadge_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = CAGradientLayer()
        gradient_breeze.frame = categoryBadge_Breeze.bounds
        gradient_breeze.colors = currentBadgeColors_Breeze
        gradient_breeze.startPoint = CGPoint(x: 0, y: 0.5)
        gradient_breeze.endPoint = CGPoint(x: 1, y: 0.5)
        categoryBadge_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        badgeGradient_Breeze = gradient_breeze
    }
    
    private var currentBadgeColors_Breeze: [CGColor] = [
        ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor,
        ColorConfig_Breeze.primaryGradientEnd_Breeze.cgColor
    ]
    
    /// 配置作者信息和分类徽章
    func configure_Breeze(userId_breeze: Int, name_breeze: String, category_breeze: PostCategory_Breeze = .all_breeze) {
        avatarView_Breeze.configure_Breeze(userId_Breeze: userId_breeze)
        nameLabel_Breeze.text = name_breeze
        categoryLabel_Breeze.text = category_breeze.rawValue
        currentBadgeColors_Breeze = category_breeze.gradientColors_Breeze
        setNeedsLayout()
    }
    
    @objc private func handleTap_Breeze() { onTapped_Breeze?() }
}

// MARK: - 详情评论单元格

/// 详情评论单元格
/// 核心作用：以白色卡片形式展示单条评论（头像/昵称/内容/举报按钮）
class DetailCommentCell_Breeze: UITableViewCell {
    
    static let reuseId_Breeze = "DetailCommentCell_Breeze"
    
    // MARK: - UI 组件
    
    /// 卡片容器
    private let cardView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 16
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_breeze.layer.shadowRadius = 8
        v_breeze.layer.shadowOpacity = 0.08
        return v_breeze
    }()
    
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    private let contentLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.numberOfLines = 0
        return label_breeze
    }()
    
    private let reportContainer_Breeze = UIView()
    private var reportButton_Breeze: UIButton?
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI_Breeze() {
        backgroundColor = .clear
        contentView.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        selectionStyle = .none
        
        contentView.addSubview(cardView_Breeze)
        cardView_Breeze.addSubview(avatarView_Breeze)
        cardView_Breeze.addSubview(nameLabel_Breeze)
        cardView_Breeze.addSubview(contentLabel_Breeze)
        cardView_Breeze.addSubview(reportContainer_Breeze)
        
        cardView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.left.right.equalToSuperview().inset(16)
        }
        
        avatarView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(34)
        }
        
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Breeze)
            make.left.equalTo(avatarView_Breeze.snp.right).offset(10)
        }
        
        reportContainer_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel_Breeze)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(26)
        }
        
        contentLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Breeze.snp.bottom).offset(6)
            make.left.equalTo(avatarView_Breeze.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }
    
    func configure_Breeze(comment_breeze: Comment_Breeze, post_breeze: TitleModel_Breeze, host_breeze: UIViewController) {
        avatarView_Breeze.configure_Breeze(userId_Breeze: comment_breeze.commentUserId_Breeze)
        nameLabel_Breeze.text = comment_breeze.commentUserName_Breeze
        contentLabel_Breeze.text = comment_breeze.commentContent_Breeze
        
        reportButton_Breeze?.removeFromSuperview()
        let btn_breeze = ReportDeleteHelper_Breeze.createCommentReportButton_Breeze(
            comment_Breeze: comment_breeze,
            post_Breeze: post_breeze,
            size_Breeze: 13,
            color_Breeze: ColorConfig_Breeze.textPlaceholder_Breeze,
            from: host_breeze
        )
        reportContainer_Breeze.addSubview(btn_breeze)
        btn_breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        reportButton_Breeze = btn_breeze
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reportButton_Breeze?.removeFromSuperview()
        reportButton_Breeze = nil
    }
}
