import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页面 - 重构版

/// 帖子详情控制器
/// 核心作用：展示帖子媒体（点击全屏）、标题、内容、评论列表，支持点赞、发评论、举报/删除
/// 设计思路：全幅媒体卡 + 浮动导航按钮 + 作者信息行 + 内容卡 + 互动行 + 评论区 + 底部输入栏
class Detail_Retrs: UIViewController {

    // MARK: - 属性

    var titleModel_Retrs: TitleModel_Retrs?

    private let titleVM_Retrs = TitleViewModel_Retrs.shared_Retrs
    private let userVM_Retrs  = UserViewModel_Retrs.shared_Retrs

    private let scrollView_Retrs  = UIScrollView()
    private let contentView_Retrs = UIView()

    /// 导航按钮（悬浮在媒体卡上方）
    private let backBtn_Retrs  = UIButton(type: .system)
    private var menuBtn_Retrs: UIButton?
    private var giftBtn_Retrs: UIButton?

    /// 媒体区
    private let mediaCard_Retrs = UIView()
    private let mediaView_Retrs = MediaDisplayView_Retrs()

    /// 作者信息行（媒体卡下方）
    private let authorRow_Retrs       = UIView()
    private let authorAvatar_Retrs    = UserAvatarView_Retrs()
    private let authorNameLabel_Retrs = UILabel()
    private let authorTagLabel_Retrs  = UILabel()

    /// 内容卡（标题 + 正文）
    private let contentCard_Retrs  = UIView()
    private let titleLabel_Retrs   = UILabel()
    private let contentLabel_Retrs = UILabel()

    /// 互动行（点赞 + 评论数）
    private let actionRow_Retrs     = UIView()
    private let likeBtn_Retrs       = UIButton(type: .system)
    private let likeCountLabel_Retrs = UILabel()
    private let commentCountLabel_Retrs = UILabel()

    /// 评论区
    private let commentsHeader_Retrs = UIView()
    private let commentsTitleLabel_Retrs = UILabel()
    private let commentsStack_Retrs  = UIStackView()

    /// 底部输入栏
    private let inputBar_Retrs  = UIView()
    private let inputWrap_Retrs = UIView()
    private let inputField_Retrs = UITextField()
    private let sendCommentBtn_Retrs = UIButton(type: .system)
    private let sendGradLayer_Retrs  = CAGradientLayer()
    private var inputBarBottomConstraint_Retrs: Constraint?

    private var currentPost_Retrs: TitleModel_Retrs? {
        guard let id_Retrs = titleModel_Retrs?.titleId_Retrs else { return nil }
        return titleVM_Retrs.getPosts_Retrs().first { $0.titleId_Retrs == id_Retrs }
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Retrs.backgroundPrimary_Retrs
        setupScrollView_Retrs()
        setupMediaCard_Retrs()
        setupNavButtons_Retrs()
        setupAuthorRow_Retrs()
        setupContentCard_Retrs()
        setupActionRow_Retrs()
        setupCommentsArea_Retrs()
        setupInputBar_Retrs()
        setupConstraints_Retrs()
        observeNotifications_Retrs()
        fillData_Retrs()

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Retrs))
        tap_Retrs.cancelsTouchesInView = false
        scrollView_Retrs.addGestureRecognizer(tap_Retrs)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendGradLayer_Retrs.frame = sendCommentBtn_Retrs.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI 搭建

    private func setupScrollView_Retrs() {
        scrollView_Retrs.showsVerticalScrollIndicator = false
        scrollView_Retrs.alwaysBounceVertical = true
        view.addSubview(scrollView_Retrs)
        scrollView_Retrs.addSubview(contentView_Retrs)
    }

    /// 全幅媒体卡（带圆角和色调阴影）
    private func setupMediaCard_Retrs() {
        mediaCard_Retrs.clipsToBounds = true
        mediaCard_Retrs.layer.cornerRadius = 0
        contentView_Retrs.addSubview(mediaCard_Retrs)
        mediaCard_Retrs.addSubview(mediaView_Retrs)
        mediaView_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }
        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(mediaTapped_Retrs))
        mediaCard_Retrs.addGestureRecognizer(tap_Retrs)
    }

    /// 悬浮导航按钮（返回 + 菜单，添加在 view 上方覆盖媒体卡）
    private func setupNavButtons_Retrs() {
        let safeTop_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 44

        styleNavBtn_Retrs(backBtn_Retrs)
        backBtn_Retrs.setImage(
            UIImage(systemName: "arrow.left",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)),
            for: .normal
        )
        backBtn_Retrs.tintColor = ColorConfig_Retrs.textPrimary_Retrs
        backBtn_Retrs.addTarget(self, action: #selector(backTapped_Retrs), for: .touchUpInside)
        view.addSubview(backBtn_Retrs)
        backBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeTop_Retrs + 12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
    }

    private func styleNavBtn_Retrs(_ btn_Retrs: UIButton) {
        btn_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        btn_Retrs.layer.cornerRadius = 18
        btn_Retrs.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        btn_Retrs.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn_Retrs.layer.shadowOpacity = 1
        btn_Retrs.layer.shadowRadius  = 6
    }

    /// 作者信息行
    private func setupAuthorRow_Retrs() {
        authorRow_Retrs.backgroundColor = .white
        contentView_Retrs.addSubview(authorRow_Retrs)

        authorRow_Retrs.addSubview(authorAvatar_Retrs)
        authorAvatar_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        authorNameLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        authorNameLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        authorRow_Retrs.addSubview(authorNameLabel_Retrs)
        authorNameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(authorAvatar_Retrs.snp.trailing).offset(10)
        }

        authorTagLabel_Retrs.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        authorTagLabel_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs.withAlphaComponent(0.7)
        authorRow_Retrs.addSubview(authorTagLabel_Retrs)
        authorTagLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(authorNameLabel_Retrs.snp.bottom).offset(2)
            make.leading.equalTo(authorNameLabel_Retrs)
        }

        // 右侧"View Profile" 入口
        let profileBtn_Retrs = UIButton(type: .system)
        profileBtn_Retrs.setTitle("Profile →", for: .normal)
        profileBtn_Retrs.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        profileBtn_Retrs.setTitleColor(ColorConfig_Retrs.primaryGradientStart_Retrs, for: .normal)
        authorRow_Retrs.addSubview(profileBtn_Retrs)
        profileBtn_Retrs.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        profileBtn_Retrs.addTarget(self, action: #selector(authorTapped_Retrs), for: .touchUpInside)

        let tap_Retrs = UITapGestureRecognizer(target: self, action: #selector(authorTapped_Retrs))
        authorRow_Retrs.addGestureRecognizer(tap_Retrs)
        authorRow_Retrs.isUserInteractionEnabled = true
    }

    /// 内容卡（白色圆角，标题 + 正文）
    private func setupContentCard_Retrs() {
        contentCard_Retrs.backgroundColor = .white
        contentCard_Retrs.layer.cornerRadius = 20
        contentCard_Retrs.clipsToBounds = false
        contentCard_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.08).cgColor
        contentCard_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentCard_Retrs.layer.shadowOpacity = 1
        contentCard_Retrs.layer.shadowRadius  = 12
        contentView_Retrs.addSubview(contentCard_Retrs)

        titleLabel_Retrs.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel_Retrs.textColor = ColorConfig_Retrs.textPrimary_Retrs
        titleLabel_Retrs.numberOfLines = 0
        contentCard_Retrs.addSubview(titleLabel_Retrs)
        titleLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        let divider_Retrs = UIView()
        divider_Retrs.backgroundColor = ColorConfig_Retrs.divider_Retrs
        contentCard_Retrs.addSubview(divider_Retrs)
        divider_Retrs.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(1)
        }

        contentLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentLabel_Retrs.numberOfLines = 0
        contentLabel_Retrs.lineBreakMode = .byWordWrapping
        contentCard_Retrs.addSubview(contentLabel_Retrs)
        contentLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(divider_Retrs.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    /// 互动行（点赞按钮 + 点赞数 + 评论数）
    private func setupActionRow_Retrs() {
        actionRow_Retrs.backgroundColor = .white
        contentView_Retrs.addSubview(actionRow_Retrs)

        let heartCfg_Retrs = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        likeBtn_Retrs.setImage(UIImage(systemName: "heart", withConfiguration: heartCfg_Retrs), for: .normal)
        likeBtn_Retrs.setImage(UIImage(systemName: "heart.fill", withConfiguration: heartCfg_Retrs), for: .selected)
        likeBtn_Retrs.tintColor = UIColor(hexstring_Retrs: "#FC8181")
        likeBtn_Retrs.addTarget(self, action: #selector(likeTapped_Retrs), for: .touchUpInside)
        actionRow_Retrs.addSubview(likeBtn_Retrs)
        likeBtn_Retrs.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }

        likeCountLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        likeCountLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        actionRow_Retrs.addSubview(likeCountLabel_Retrs)
        likeCountLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(likeBtn_Retrs.snp.trailing).offset(4)
        }

        // 评论数（气泡图标 + 数字）
        let bubbleIV_Retrs = UIImageView(
            image: UIImage(systemName: "bubble.right",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        )
        bubbleIV_Retrs.tintColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        actionRow_Retrs.addSubview(bubbleIV_Retrs)
        bubbleIV_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(likeCountLabel_Retrs.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        commentCountLabel_Retrs.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        commentCountLabel_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        actionRow_Retrs.addSubview(commentCountLabel_Retrs)
        commentCountLabel_Retrs.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(bubbleIV_Retrs.snp.trailing).offset(4)
        }
    }

    /// 评论区（区块标题 + 评论栈）
    private func setupCommentsArea_Retrs() {
        // 区块标题行
        contentView_Retrs.addSubview(commentsHeader_Retrs)
        let dot_Retrs = UIView()
        dot_Retrs.backgroundColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        dot_Retrs.layer.cornerRadius = 3
        commentsHeader_Retrs.addSubview(dot_Retrs)
        dot_Retrs.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(6)
        }
        commentsTitleLabel_Retrs.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        commentsTitleLabel_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        commentsHeader_Retrs.addSubview(commentsTitleLabel_Retrs)
        commentsTitleLabel_Retrs.snp.makeConstraints { make in
            make.leading.equalTo(dot_Retrs.snp.trailing).offset(8)
            make.centerY.trailing.equalToSuperview()
        }

        // 评论栈
        commentsStack_Retrs.axis = .vertical
        commentsStack_Retrs.spacing = 10
        contentView_Retrs.addSubview(commentsStack_Retrs)
    }

    /// 底部输入栏（毛玻璃背景 + 浅紫输入框 + 渐变发送按钮）
    private func setupInputBar_Retrs() {
        view.addSubview(inputBar_Retrs)
        inputBar_Retrs.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        inputBar_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.1).cgColor
        inputBar_Retrs.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBar_Retrs.layer.shadowOpacity = 1
        inputBar_Retrs.layer.shadowRadius  = 8

        inputWrap_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#EEF2FF")
        inputWrap_Retrs.layer.cornerRadius = 20
        inputBar_Retrs.addSubview(inputWrap_Retrs)

        inputField_Retrs.placeholder = "Add a comment..."
        inputField_Retrs.font = UIFont.systemFont(ofSize: 14)
        inputField_Retrs.backgroundColor = .clear
        inputField_Retrs.returnKeyType = .send
        inputField_Retrs.delegate = self
        let lp_Retrs = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 36))
        inputField_Retrs.leftView = lp_Retrs
        inputField_Retrs.leftViewMode = .always
        inputWrap_Retrs.addSubview(inputField_Retrs)
        inputField_Retrs.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 渐变发送按钮
        sendGradLayer_Retrs.colors = [
            ColorConfig_Retrs.primaryGradientStart_Retrs.cgColor,
            ColorConfig_Retrs.primaryGradientEnd_Retrs.cgColor
        ]
        sendGradLayer_Retrs.startPoint = CGPoint(x: 0, y: 0)
        sendGradLayer_Retrs.endPoint   = CGPoint(x: 1, y: 1)
        sendGradLayer_Retrs.cornerRadius = 18
        sendCommentBtn_Retrs.layer.insertSublayer(sendGradLayer_Retrs, at: 0)
        sendCommentBtn_Retrs.layer.cornerRadius = 18
        sendCommentBtn_Retrs.clipsToBounds = true
        // 用 UIImageView 直接叠在按钮上，避免 system 按钮图片被渐变层遮挡
        let sendIcon_Retrs = UIImageView(
            image: UIImage(systemName: "paperplane.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        )
        sendIcon_Retrs.tintColor = .white
        sendIcon_Retrs.contentMode = .scaleAspectFit
        sendIcon_Retrs.isUserInteractionEnabled = false
        sendCommentBtn_Retrs.addSubview(sendIcon_Retrs)
        sendIcon_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }
        sendCommentBtn_Retrs.addTarget(self, action: #selector(sendCommentTapped_Retrs), for: .touchUpInside)
        inputBar_Retrs.addSubview(sendCommentBtn_Retrs)

        // 约束在 setupConstraints_Retrs 中统一设置（需要用到 safeAreaInsets）

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Retrs(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Retrs(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - 约束

    private func setupConstraints_Retrs() {
        let screenW_Retrs = UIScreen.main.bounds.width
        scrollView_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputBar_Retrs.snp.top)
        }
        contentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(screenW_Retrs)
        }
        mediaCard_Retrs.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(280)
        }
        authorRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Retrs.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        contentCard_Retrs.snp.makeConstraints { make in
            make.top.equalTo(authorRow_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        actionRow_Retrs.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Retrs.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        commentsHeader_Retrs.snp.makeConstraints { make in
            make.top.equalTo(actionRow_Retrs.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(22)
        }
        commentsStack_Retrs.snp.makeConstraints { make in
            make.top.equalTo(commentsHeader_Retrs.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-20)
        }
        let safeBottom_Retrs = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
        inputBar_Retrs.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(60 + safeBottom_Retrs)
            inputBarBottomConstraint_Retrs = make.bottom.equalToSuperview().constraint
        }
        // 输入框和按钮在安全区之上居中
        inputWrap_Retrs.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendCommentBtn_Retrs.snp.leading).offset(-8)
            make.height.equalTo(40)
            make.centerY.equalToSuperview().offset(-safeBottom_Retrs / 2)
        }
        sendCommentBtn_Retrs.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview().offset(-safeBottom_Retrs / 2)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 数据填充

    private func fillData_Retrs() {
        guard let post_Retrs = currentPost_Retrs ?? titleModel_Retrs else { return }

        // 右上角菜单按钮（悬浮）
        menuBtn_Retrs?.removeFromSuperview()
        let btn_Retrs = ReportDeleteHelper_Retrs.createPostReportButton_Retrs(
            post_Retrs: post_Retrs, size_Retrs: 14,
            color_Retrs: ColorConfig_Retrs.textPrimary_Retrs, from: self,
            completion_Retrs: { Navigation_Retrs.pop_Retrs() }
        )
        styleNavBtn_Retrs(btn_Retrs)
        view.addSubview(btn_Retrs)
        btn_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        menuBtn_Retrs = btn_Retrs

        // 送礼按钮（菜单按钮左侧 10pt，高度与菜单按钮一致，宽度自适应原图）
        giftBtn_Retrs?.removeFromSuperview()
        let gift_Retrs = UIButton(type: .custom)
        gift_Retrs.setImage(UIImage(named: "gift_btn"), for: .normal)
        gift_Retrs.imageView?.contentMode = .scaleAspectFit
        styleNavBtn_Retrs(gift_Retrs)
        gift_Retrs.addTarget(self, action: #selector(giftTapped_Retrs), for: .touchUpInside)
        view.addSubview(gift_Retrs)
        gift_Retrs.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn_Retrs)
            make.trailing.equalTo(btn_Retrs.snp.leading).offset(-10)
            make.height.equalTo(36)
        }
        giftBtn_Retrs = gift_Retrs

        view.bringSubviewToFront(backBtn_Retrs)

        let isVideo_Retrs = post_Retrs.titleMeidas_Retrs.first
            .map { $0.hasSuffix(".mp4") || $0.hasSuffix(".mov") || $0.hasSuffix(".m4v") } ?? false
        mediaView_Retrs.configure_Retrs(mediaPath_Retrs: post_Retrs.titleMeidas_Retrs.first, isVideo_Retrs: isVideo_Retrs)

        authorAvatar_Retrs.configure_Retrs(userId_Retrs: post_Retrs.titleUserId_Retrs)
        authorNameLabel_Retrs.text = post_Retrs.titleUserName_Retrs
        authorTagLabel_Retrs.text  = "CCD Enthusiast"

        titleLabel_Retrs.text   = post_Retrs.title_Retrs
        contentLabel_Retrs.text = post_Retrs.titleContent_Retrs

        likeCountLabel_Retrs.text    = "\(post_Retrs.likes_Retrs)"
        commentCountLabel_Retrs.text = "\(post_Retrs.reviews_Retrs.count)"
        likeBtn_Retrs.isSelected     = titleVM_Retrs.isLikedPost_Retrs(post_retrs: post_Retrs)

        commentsTitleLabel_Retrs.text = "Comments (\(post_Retrs.reviews_Retrs.count))"
        rebuildComments_Retrs(post_Retrs: post_Retrs)
    }

    private func rebuildComments_Retrs(post_Retrs: TitleModel_Retrs) {
        commentsStack_Retrs.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let blockedIds_Retrs = getBlockedUserIds_Retrs()
        let visible_Retrs = post_Retrs.reviews_Retrs.filter {
            !blockedIds_Retrs.contains($0.commentUserId_Retrs) ||
            userVM_Retrs.isCurrentUser_Retrs(userId_retrs: $0.commentUserId_Retrs)
        }
        if visible_Retrs.isEmpty {
            let lbl_Retrs = UILabel()
            lbl_Retrs.text = "No comments yet. Be the first!"
            lbl_Retrs.font = UIFont.systemFont(ofSize: 13)
            lbl_Retrs.textColor = ColorConfig_Retrs.textPlaceholder_Retrs
            lbl_Retrs.textAlignment = .center
            commentsStack_Retrs.addArrangedSubview(lbl_Retrs)
            return
        }
        visible_Retrs.forEach { commentsStack_Retrs.addArrangedSubview(buildCommentCard_Retrs(comment_Retrs: $0, post_Retrs: post_Retrs)) }
    }

    private func getBlockedUserIds_Retrs() -> Set<Int> {
        let validIds_Retrs = Set(LocalData_Retrs.shared_Retrs.userList_Retrs.compactMap { $0.userId_Retrs })
        let currentId_Retrs = userVM_Retrs.getCurrentUser_Retrs().userId_Retrs ?? -1
        return Set((currentPost_Retrs?.reviews_Retrs ?? []).map { $0.commentUserId_Retrs }
            .filter { !validIds_Retrs.contains($0) && $0 != currentId_Retrs })
    }

    /// 构建单条评论卡片（白色圆角 + 头像 + 用户名 + 内容 + 操作按钮）
    private func buildCommentCard_Retrs(comment_Retrs: Comment_Retrs, post_Retrs: TitleModel_Retrs) -> UIView {
        let card_Retrs = UIView()
        card_Retrs.backgroundColor = .white
        card_Retrs.layer.cornerRadius = 16
        card_Retrs.clipsToBounds = false
        card_Retrs.layer.shadowColor = ColorConfig_Retrs.primaryGradientStart_Retrs
            .withAlphaComponent(0.07).cgColor
        card_Retrs.layer.shadowOffset = CGSize(width: 0, height: 3)
        card_Retrs.layer.shadowOpacity = 1
        card_Retrs.layer.shadowRadius  = 8

        let av_Retrs = UserAvatarView_Retrs()
        av_Retrs.configure_Retrs(userId_Retrs: comment_Retrs.commentUserId_Retrs)
        card_Retrs.addSubview(av_Retrs)
        av_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(34)
        }

        let nameLbl_Retrs = UILabel()
        nameLbl_Retrs.text = comment_Retrs.commentUserName_Retrs
        nameLbl_Retrs.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_Retrs.textColor = ColorConfig_Retrs.primaryGradientStart_Retrs
        card_Retrs.addSubview(nameLbl_Retrs)
        nameLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(av_Retrs)
            make.leading.equalTo(av_Retrs.snp.trailing).offset(8)
        }

        let contentLbl_Retrs = UILabel()
        contentLbl_Retrs.text = comment_Retrs.commentContent_Retrs
        contentLbl_Retrs.font = UIFont.systemFont(ofSize: 13)
        contentLbl_Retrs.textColor = ColorConfig_Retrs.textSecondary_Retrs
        contentLbl_Retrs.numberOfLines = 0
        card_Retrs.addSubview(contentLbl_Retrs)
        contentLbl_Retrs.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_Retrs.snp.bottom).offset(4)
            make.leading.equalTo(av_Retrs.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-12)
        }

        let reportBtn_Retrs = ReportDeleteHelper_Retrs.createCommentReportButton_Retrs(
            comment_Retrs: comment_Retrs, post_Retrs: post_Retrs, size_Retrs: 13,
            color_Retrs: ColorConfig_Retrs.textPlaceholder_Retrs, from: self,
            completion_Retrs: { [weak self] in self?.fillData_Retrs() }
        )
        card_Retrs.addSubview(reportBtn_Retrs)
        reportBtn_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        return card_Retrs
    }

    // MARK: - 通知 & 键盘

    private func observeNotifications_Retrs() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Retrs),
            name: TitleViewModel_Retrs.titleStateDidChangeNotification_Retrs, object: nil)
    }

    @objc private func onStateChange_Retrs() { fillData_Retrs() }

    @objc private func keyboardWillShow_Retrs(_ notification: Notification) {
        guard let frame_Retrs = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        inputBarBottomConstraint_Retrs?.update(offset: -frame_Retrs.height)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Retrs(_ notification: Notification) {
        inputBarBottomConstraint_Retrs?.update(offset: 0)
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    // MARK: - 事件

    @objc private func backTapped_Retrs() { Navigation_Retrs.pop_Retrs() }
    @objc private func dismissKeyboard_Retrs() { view.endEditing(true) }

    /// 点击送礼按钮
    @objc private func giftTapped_Retrs() {
        guard let post_Retrs = currentPost_Retrs ?? titleModel_Retrs else { return }
        giftBtn_Retrs?.animatePulse_Retrs()
        let user_Retrs = UserViewModel_Retrs.shared_Retrs.getUserById_Retrs(userId_retrs: post_Retrs.titleUserId_Retrs)
        Navigation_Retrs.toGiftPage_Retrs(with: user_Retrs)
    }

    @objc private func mediaTapped_Retrs() {
        guard let path_Retrs = (currentPost_Retrs ?? titleModel_Retrs)?.titleMeidas_Retrs.first else { return }
        let vc_Retrs = MediaPlayerPage_Retrs()
        vc_Retrs.mediaPath_Retrs = path_Retrs
        vc_Retrs.modalPresentationStyle = .fullScreen
        present(vc_Retrs, animated: true)
    }

    @objc private func authorTapped_Retrs() {
        guard let post_Retrs = currentPost_Retrs ?? titleModel_Retrs else { return }
        if userVM_Retrs.isCurrentUser_Retrs(userId_retrs: post_Retrs.titleUserId_Retrs) {
            Navigation_Retrs.toMe_Retrs()
        } else {
            Navigation_Retrs.toUserInfo_Retrs(with: userVM_Retrs.getUserById_Retrs(userId_retrs: post_Retrs.titleUserId_Retrs))
        }
    }

    @objc private func likeTapped_Retrs() {
        guard let post_Retrs = currentPost_Retrs ?? titleModel_Retrs else { return }
        likeBtn_Retrs.animatePulse_Retrs()
        titleVM_Retrs.likePost_Retrs(post_retrs: post_Retrs)
    }

    @objc private func sendCommentTapped_Retrs() {
        let text_Retrs = inputField_Retrs.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Retrs.isEmpty, let post_Retrs = currentPost_Retrs ?? titleModel_Retrs else { return }
        sendCommentBtn_Retrs.animatePulse_Retrs()
        titleVM_Retrs.releaseComment_Retrs(post_retrs: post_Retrs, content_retrs: text_Retrs)
        inputField_Retrs.text = ""
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Retrs: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTapped_Retrs(); return true
    }
}
