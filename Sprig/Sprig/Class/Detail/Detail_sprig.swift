import UIKit
import SnapKit

// MARK: 帖子详情页

/// 帖子详情页视图控制器
/// 功能：展示帖子完整内容、评论列表、点赞操作和评论发布
/// 布局：UIScrollView + 底部固定评论输入栏
/// 特性：监听 TitleStateDidChange 自动刷新点赞数和评论列表
class Detail_Sprig: UIViewController {
    
    // MARK: - 公共属性
    
    /// 帖子模型（由外部传入）
    var titleModel_Sprig: TitleModel_Sprig?
    
    // MARK: - 私有属性
    
    private var currentPost_Sprig: TitleModel_Sprig? {
        guard let model_sprig = titleModel_Sprig else { return nil }
        return TitleViewModel_Sprig.shared_Sprig.getPosts_Sprig()
            .first(where: { $0.titleId_Sprig == model_sprig.titleId_Sprig }) ?? model_sprig
    }
    
    // MARK: - UI 组件
    
    private lazy var scrollView_Sprig: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        // 禁止自动调整内容内边距，避免顶部媒体区与屏幕顶部产生安全区间距
        sv.contentInsetAdjustmentBehavior = .never
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    private let contentView_Sprig = UIView()
    
    // 返回按钮
    private lazy var backButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // 右上角举报/删除按钮（浮在媒体区上）
    private lazy var reportButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 18
        return btn
    }()
    
    // 媒体区（使用 MediaDisplayView_Sprig 统一组件）
    private let mediaView_Sprig = MediaDisplayView_Sprig()
    
    // 作者信息区
    private let authorAvatarView_Sprig = UserAvatarView_Sprig()
    
    private let authorNameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        return l
    }()
    
    private let postDateLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        return l
    }()

    // 关注按钮（在作者信息旁）
    private let followButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn.setImage(UIImage(systemName: "person.badge.plus", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Follow", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 14
        btn.clipsToBounds = true
        return btn
    }()

    /// 关注按钮渐变层
    private let followBtnGrad_Sprig = CAGradientLayer()
    
    // 标题
    private let titleLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        l.numberOfLines = 0
        return l
    }()
    
    // 标签行
    private let tagsStack_Sprig: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()
    
    // 正文内容
    private let bodyLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        return l
    }()
    
    // 操作行（点赞+评论数）
    private let likeButton_Sprig: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        return btn
    }()
    
    private let likeCountLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return l
    }()
    
    private let commentCountLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        return l
    }()
    
    // 评论区分割线
    private let commentDivider_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Sprig.divider_Sprig
        return v
    }()
    
    // 评论区标题
    private let commentSectionLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        return l
    }()
    
    // 评论列表容器（动态 stackView）
    private let commentsStack_Sprig: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    // 底部评论输入栏（无悬浮阴影，顶部左右圆角）
    private let inputBarView_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        // 左上、右上圆角，使输入栏顶部贴合内容区而非悬浮
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    private let commentTextField_Sprig: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Share your thoughts..."
        tf.font = .systemFont(ofSize: 14)
        tf.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig
        tf.layer.cornerRadius = 20
        tf.addLeftPadding_Sprig(16)
        return tf
    }()
    
    private let sendButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Sprig.leafGreen_Sprig
        btn.layer.cornerRadius = 20
        return btn
    }()

    /// 送礼按钮（位于发送按钮左侧 10pt，40×40，图标使用 Assets 中的 gift_btn）
    private let giftButton_Sprig: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_btn"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView_Sprig()
        setupInputBar_Sprig()
        setupKeyboardObservers_Sprig()
        registerNotifications_Sprig()
        populateContent_Sprig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        followBtnGrad_Sprig.frame = followButton_Sprig.bounds
    }
    
    // MARK: - UI 搭建
    
    private func setupScrollView_Sprig() {
        view.addSubview(scrollView_Sprig)
        scrollView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        scrollView_Sprig.addSubview(contentView_Sprig)
        contentView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 媒体区（MediaDisplayView 统一组件）
        mediaView_Sprig.layer.cornerRadius = 0
        mediaView_Sprig.isUserInteractionEnabled = true
        contentView_Sprig.addSubview(mediaView_Sprig)
        mediaView_Sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(260)
        }
        // 点击媒体区进入全屏媒体浏览页
        let mediaTap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Sprig))
        mediaView_Sprig.addGestureRecognizer(mediaTap_sprig)
        
        // 返回按钮（浮在媒体区上）
        view.addSubview(backButton_Sprig)
        backButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        backButton_Sprig.addTarget(self, action: #selector(handleBack_Sprig), for: .touchUpInside)

        // 举报/删除按钮（浮在媒体区右上角）
        view.addSubview(reportButton_Sprig)
        reportButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        reportButton_Sprig.addTarget(self, action: #selector(handleReport_Sprig), for: .touchUpInside)
        
        // 白色卡片内容区（圆角叠在媒体上方）
        let cardView_sprig = UIView()
        cardView_sprig.backgroundColor = .white
        cardView_sprig.layer.cornerRadius = 24
        cardView_sprig.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView_Sprig.addSubview(cardView_sprig)
        cardView_sprig.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Sprig.snp.bottom).offset(-24)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 作者头像（UserAvatarView 统一组件）
        authorAvatarView_Sprig.layer.cornerRadius = 22
        authorAvatarView_Sprig.clipsToBounds = true
        cardView_sprig.addSubview(authorAvatarView_Sprig)
        authorAvatarView_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }
        
        // 作者昵称 + 日期
        cardView_sprig.addSubview(authorNameLabel_Sprig)
        cardView_sprig.addSubview(postDateLabel_Sprig)
        authorNameLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(authorAvatarView_Sprig).offset(3)
            make.left.equalTo(authorAvatarView_Sprig.snp.right).offset(10)
        }
        postDateLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(authorNameLabel_Sprig.snp.bottom).offset(3)
            make.left.equalTo(authorAvatarView_Sprig.snp.right).offset(10)
        }

        // 关注按钮（渐变背景，作者信息右侧）
        followBtnGrad_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        followBtnGrad_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        followBtnGrad_Sprig.endPoint   = CGPoint(x: 1, y: 0.5)
        followBtnGrad_Sprig.cornerRadius = 14
        followButton_Sprig.layer.insertSublayer(followBtnGrad_Sprig, at: 0)
        cardView_sprig.addSubview(followButton_Sprig)
        followButton_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Sprig)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(80)
        }
        followButton_Sprig.addTarget(self, action: #selector(handleFollowTap_Sprig), for: .touchUpInside)
        
        // 标题
        cardView_sprig.addSubview(titleLabel_Sprig)
        titleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(authorAvatarView_Sprig.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 标签行
        cardView_sprig.addSubview(tagsStack_Sprig)
        tagsStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sprig.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(22)
        }
        
        // 正文
        cardView_sprig.addSubview(bodyLabel_Sprig)
        bodyLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(tagsStack_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 点赞区
        cardView_sprig.addSubview(likeButton_Sprig)
        cardView_sprig.addSubview(likeCountLabel_Sprig)
        cardView_sprig.addSubview(commentCountLabel_Sprig)
        likeButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel_Sprig.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        likeCountLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Sprig)
            make.left.equalTo(likeButton_Sprig.snp.right).offset(6)
        }
        commentCountLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Sprig)
            make.left.equalTo(likeCountLabel_Sprig.snp.right).offset(20)
        }
        likeButton_Sprig.addTarget(self, action: #selector(handleLikeTap_Sprig), for: .touchUpInside)
        
        // 评论分割线
        cardView_sprig.addSubview(commentDivider_Sprig)
        commentDivider_Sprig.snp.makeConstraints { make in
            make.top.equalTo(likeButton_Sprig.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(0.5)
        }
        
        // 评论区标题
        cardView_sprig.addSubview(commentSectionLabel_Sprig)
        commentSectionLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(commentDivider_Sprig.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }
        
        // 评论列表
        cardView_sprig.addSubview(commentsStack_Sprig)
        commentsStack_Sprig.snp.makeConstraints { make in
            make.top.equalTo(commentSectionLabel_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupInputBar_Sprig() {
        view.addSubview(inputBarView_Sprig)
        inputBarView_Sprig.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            // 加高输入栏，提升操作舒适度
            make.height.equalTo(76)
        }
        
        // 顶部分割线，替代阴影营造层次感
        let topDivider_sprig = UIView()
        topDivider_sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        inputBarView_Sprig.addSubview(topDivider_sprig)
        topDivider_sprig.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        inputBarView_Sprig.addSubview(commentTextField_Sprig)
        inputBarView_Sprig.addSubview(giftButton_Sprig)
        inputBarView_Sprig.addSubview(sendButton_Sprig)

        // 发送按钮：最右侧，44×44
        sendButton_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        // 送礼按钮：发送按钮左侧 10pt，40×40
        giftButton_Sprig.snp.makeConstraints { make in
            make.right.equalTo(sendButton_Sprig.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        // 输入框：左边距 16，右侧紧贴礼物按钮左侧 10pt
        commentTextField_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(giftButton_Sprig.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }

        sendButton_Sprig.addTarget(self, action: #selector(handleSendComment_Sprig), for: .touchUpInside)
        giftButton_Sprig.addTarget(self, action: #selector(handleGiftTap_Sprig), for: .touchUpInside)
    }
    
    // MARK: - 内容填充
    
    private func populateContent_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        
        titleLabel_Sprig.text = post_sprig.title_Sprig
        bodyLabel_Sprig.text = post_sprig.titleContent_Sprig
        authorNameLabel_Sprig.text = post_sprig.titleUserName_Sprig
        postDateLabel_Sprig.text = "Just now · \(post_sprig.reviews_Sprig.count) comments"
        
        updateLikeUI_Sprig(post_sprig: post_sprig)
        updateComments_Sprig(post_sprig: post_sprig)
        updateFollowUI_Sprig(post_sprig: post_sprig)
        updateReportUI_Sprig(post_sprig: post_sprig)
        
        // 标签
        tagsStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag_sprig in post_sprig.titleTags_Sprig {
            let badge_sprig = makeTagBadge_Sprig(text_sprig: tag_sprig)
            tagsStack_Sprig.addArrangedSubview(badge_sprig)
        }
        
        // 使用 MediaDisplayView_Sprig 加载媒体
        mediaView_Sprig.configure_Sprig(mediaPath_Sprig: post_sprig.titleMeidas_Sprig.first)

        // 使用 UserAvatarView_Sprig 展示作者头像
        authorAvatarView_Sprig.configure_Sprig(userId_Sprig: post_sprig.titleUserId_Sprig)
    }

    /// 更新关注按钮 UI（如果是自己的帖子则隐藏关注按钮）
    private func updateFollowUI_Sprig(post_sprig: TitleModel_Sprig) {
        let isSelf_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig
        )
        // 自己的帖子不显示关注按钮
        followButton_Sprig.isHidden = isSelf_sprig
        guard !isSelf_sprig else { return }
        let author_sprig = UserViewModel_Sprig.shared_Sprig.getUserById_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig)
        let isFollowing_sprig = UserViewModel_Sprig.shared_Sprig.isFollowing_Sprig(user_sprig: author_sprig)
        let symName_sprig = isFollowing_sprig ? "person.badge.checkmark" : "person.badge.plus"
        let titleStr_sprig = isFollowing_sprig ? "  Followed" : "  Follow"
        let cfg_sprig = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        followButton_Sprig.setImage(UIImage(systemName: symName_sprig, withConfiguration: cfg_sprig), for: .normal)
        followButton_Sprig.setTitle(titleStr_sprig, for: .normal)
        followBtnGrad_Sprig.colors = isFollowing_sprig
            ? [UIColor(hexstring_Sprig: "#A0AEC0").cgColor, UIColor(hexstring_Sprig: "#CBD5E0").cgColor]
            : [ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor, ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor]
    }

    /// 更新举报/删除按钮图标（自己的帖子显示删除图标）
    private func updateReportUI_Sprig(post_sprig: TitleModel_Sprig) {
        let isSelf_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig
        )
        let iconName_sprig = isSelf_sprig ? "trash" : "ellipsis"
        let cfg_sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        reportButton_Sprig.setImage(UIImage(systemName: iconName_sprig, withConfiguration: cfg_sprig), for: .normal)
    }
    
    private func updateLikeUI_Sprig(post_sprig: TitleModel_Sprig) {
        let isLiked_sprig = TitleViewModel_Sprig.shared_Sprig.isLikedPost_Sprig(post_sprig: post_sprig)
        likeButton_Sprig.isSelected = isLiked_sprig
        likeButton_Sprig.tintColor = isLiked_sprig
            ? ColorConfig_Sprig.likeRed_Sprig
            : ColorConfig_Sprig.textPlaceholder_Sprig
        likeCountLabel_Sprig.text = "\(post_sprig.likes_Sprig) likes"
        likeCountLabel_Sprig.textColor = isLiked_sprig
            ? ColorConfig_Sprig.likeRed_Sprig
            : ColorConfig_Sprig.textSecondary_Sprig
        commentCountLabel_Sprig.text = "💬 \(post_sprig.reviews_Sprig.count) comments"
    }
    
    private func updateComments_Sprig(post_sprig: TitleModel_Sprig) {
        commentsStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        commentSectionLabel_Sprig.text = "Comments (\(post_sprig.reviews_Sprig.count))"
        
        if post_sprig.reviews_Sprig.isEmpty {
            let emptyL_sprig = UILabel()
            emptyL_sprig.text = "No comments yet. Be the first to share! 🌿"
            emptyL_sprig.font = .systemFont(ofSize: 13)
            emptyL_sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
            emptyL_sprig.textAlignment = .center
            commentsStack_Sprig.addArrangedSubview(emptyL_sprig)
        } else {
            for (i_sprig, comment_sprig) in post_sprig.reviews_Sprig.enumerated() {
                let commentView_sprig = buildCommentView_Sprig(comment_sprig: comment_sprig, index_sprig: i_sprig)
                commentsStack_Sprig.addArrangedSubview(commentView_sprig)
            }
        }
    }
    
    // MARK: - 通知
    
    private func registerNotifications_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Sprig),
            name: TitleViewModel_Sprig.titleStateDidChangeNotification_Sprig,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserStateChanged_Sprig),
            name: UserViewModel_Sprig.userStateDidChangeNotification_Sprig,
            object: nil
        )
    }
    
    @objc private func onTitleStateChanged_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        updateLikeUI_Sprig(post_sprig: post_sprig)
        updateComments_Sprig(post_sprig: post_sprig)
    }

    @objc private func onUserStateChanged_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        updateFollowUI_Sprig(post_sprig: post_sprig)
    }
    
    // MARK: - 按钮响应

    /// 点击送礼按钮，弹出 GiftView_Sprig 礼物面板（模态底部弹起）
    @objc private func handleGiftTap_Sprig() {
        giftButton_Sprig.animatePulse_Sprig()
        let giftVC_sprig = GiftView_Sprig()
        giftVC_sprig.modalPresentationStyle = .overFullScreen
        giftVC_sprig.modalTransitionStyle   = .crossDissolve
        present(giftVC_sprig, animated: true)
    }

    /// 点击媒体区，打开全屏媒体浏览页（MediaPlayerPage_Sprig）
    /// 将帖子媒体路径及类型传入，由播放页自动检测图片/视频并渲染
    @objc private func handleMediaTap_Sprig() {
        guard let post_sprig = currentPost_Sprig,
              let mediaPath_sprig = post_sprig.titleMeidas_Sprig.first,
              !mediaPath_sprig.isEmpty else { return }
        let player_sprig = MediaPlayerPage_Sprig()
        player_sprig.mediaPath_Sprig = mediaPath_sprig
        player_sprig.isVideo_Sprig   = false   // 播放页会自动检测是否为视频
        player_sprig.modalPresentationStyle = .overFullScreen
        // 关闭系统转场动画，由 MediaPlayerPage 内部 viewWillAppear/viewDidAppear 统一管理淡入，消除闪烁
        player_sprig.modalTransitionStyle   = .crossDissolve
        present(player_sprig, animated: false)
    }

    @objc private func handleBack_Sprig() {
        backButton_Sprig.animatePulse_Sprig()
        Navigation_Sprig.pop_Sprig()
    }

    /// 点击举报/删除按钮
    @objc private func handleReport_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        reportButton_Sprig.animatePulse_Sprig()
        let isSelf_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig
        )
        if isSelf_sprig {
            ReportDeleteHelper_Sprig.delete_Sprig(post_Sprig: post_sprig, from: self) { }
        } else {
            ReportDeleteHelper_Sprig.report_Sprig(post_Sprig: post_sprig, from: self) { }
        }
    }

    /// 点击关注按钮
    @objc private func handleFollowTap_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        followButton_Sprig.animatePulse_Sprig()
        let author_sprig = UserViewModel_Sprig.shared_Sprig.getUserById_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig)
        UserViewModel_Sprig.shared_Sprig.followUser_Sprig(user_sprig: author_sprig)
    }
    
    @objc private func handleLikeTap_Sprig() {
        guard let post_sprig = currentPost_Sprig else { return }
        likeButton_Sprig.animatePulse_Sprig()
        Task { @MainActor in
            TitleViewModel_Sprig.shared_Sprig.likePost_Sprig(post_sprig: post_sprig)
        }
    }
    
    @objc private func handleSendComment_Sprig() {
        guard let post_sprig = currentPost_Sprig,
              let text_sprig = commentTextField_Sprig.text, !text_sprig.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        
        Task { @MainActor in
            TitleViewModel_Sprig.shared_Sprig.releaseComment_Sprig(
                post_sprig: post_sprig,
                content_sprig: text_sprig
            )
        }
        commentTextField_Sprig.text = ""
        commentTextField_Sprig.resignFirstResponder()
        
        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let bottomOffset_sprig = CGPoint(
                x: 0,
                y: max(0, self.scrollView_Sprig.contentSize.height - self.scrollView_Sprig.bounds.height + 80)
            )
            self.scrollView_Sprig.setContentOffset(bottomOffset_sprig, animated: true)
        }
    }
    
    // MARK: - 键盘处理
    
    private func setupKeyboardObservers_Sprig() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Sprig(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Sprig(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow_Sprig(_ notification: Notification) {
        guard let keyboardFrame_sprig = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight_sprig = keyboardFrame_sprig.height
        UIView.animate(withDuration: 0.25) {
            self.inputBarView_Sprig.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-keyboardHeight_sprig + self.view.safeAreaInsets.bottom)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide_Sprig(_ notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.inputBarView_Sprig.snp.updateConstraints { make in
                // 键盘收起，恢复到安全区底部
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 私有工具
    
    /// 构建评论行视图（带举报/删除按钮）
    private func buildCommentView_Sprig(comment_sprig: Comment_Sprig, index_sprig: Int) -> UIView {
        let container_sprig = UIView()
        container_sprig.backgroundColor = ColorConfig_Sprig.backgroundFloral_Sprig
        container_sprig.layer.cornerRadius = 14

        // 头像（UserAvatarView_Sprig）
        let avatarV_sprig = UserAvatarView_Sprig()
        avatarV_sprig.layer.cornerRadius = 16
        avatarV_sprig.clipsToBounds = true
        avatarV_sprig.configure_Sprig(userId_Sprig: comment_sprig.commentUserId_Sprig)
        
        let nameL_sprig = UILabel()
        nameL_sprig.text = comment_sprig.commentUserName_Sprig
        nameL_sprig.font = .systemFont(ofSize: 13, weight: .semibold)
        nameL_sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        
        let contentL_sprig = UILabel()
        contentL_sprig.text = comment_sprig.commentContent_Sprig
        contentL_sprig.font = .systemFont(ofSize: 13)
        contentL_sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        contentL_sprig.numberOfLines = 0

        // 右上角举报/删除按钮
        let actionBtn_sprig = UIButton(type: .system)
        let isOwner_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: comment_sprig.commentUserId_Sprig
        )
        let iconName_sprig = isOwner_sprig ? "trash" : "ellipsis"
        let btnCfg_sprig = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        actionBtn_sprig.setImage(UIImage(systemName: iconName_sprig, withConfiguration: btnCfg_sprig), for: .normal)
        actionBtn_sprig.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        
        container_sprig.addSubview(avatarV_sprig)
        container_sprig.addSubview(nameL_sprig)
        container_sprig.addSubview(contentL_sprig)
        container_sprig.addSubview(actionBtn_sprig)
        
        avatarV_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.height.equalTo(32)
        }
        nameL_sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarV_sprig)
            make.left.equalTo(avatarV_sprig.snp.right).offset(10)
            make.right.equalTo(actionBtn_sprig.snp.left).offset(-8)
        }
        contentL_sprig.snp.makeConstraints { make in
            make.top.equalTo(nameL_sprig.snp.bottom).offset(4)
            make.left.equalTo(avatarV_sprig.snp.right).offset(10)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        actionBtn_sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }

        // 绑定举报/删除事件（评论操作需要同时传帖子模型）
        actionBtn_sprig.addAction(UIAction { [weak self] _ in
            guard let self, let post_sprig = self.currentPost_Sprig else { return }
            if isOwner_sprig {
                ReportDeleteHelper_Sprig.delete_Sprig(
                    comment_Sprig: comment_sprig,
                    post_Sprig: post_sprig,
                    from: self
                ) { }
            } else {
                ReportDeleteHelper_Sprig.report_Sprig(
                    comment_Sprig: comment_sprig,
                    post_Sprig: post_sprig,
                    from: self
                ) { }
            }
        }, for: .touchUpInside)
        
        return container_sprig
    }
    
    /// 创建标签 badge
    private func makeTagBadge_Sprig(text_sprig: String) -> UIView {
        let container_sprig = UIView()
        container_sprig.backgroundColor = ColorConfig_Sprig.tagBackground_Sprig
        container_sprig.layer.cornerRadius = 10
        let label_sprig = UILabel()
        label_sprig.text = text_sprig
        label_sprig.font = .systemFont(ofSize: 11, weight: .medium)
        label_sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        container_sprig.addSubview(label_sprig)
        label_sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
        return container_sprig
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
