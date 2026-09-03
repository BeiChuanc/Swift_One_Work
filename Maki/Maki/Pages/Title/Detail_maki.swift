import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页视图控制器

/// 帖子详情页视图控制器
/// 功能：展示帖子媒体、标题、内容、点赞；评论列表带举报按钮；数据变化自动响应
/// 设计：顶部全幅媒体 + 底部渐变叠层 + 悬浮返回按钮 + 精美信息卡 + 评论区 + 底部评论输入栏
/// 逻辑：被举报用户评论隐藏；举报评论 → 删除该评论
class Detail_Maki: UIViewController {

    // MARK: - 对外属性
    var titleModel_Maki: TitleModel_Maki?

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let card    = UIColor.white
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let cellId  = "DetailCommentCell_Maki"
        static let mediaH: CGFloat = 320
    }

    // MARK: - 数据

    private var currentPost_Maki: TitleModel_Maki? {
        guard let model_maki = titleModel_Maki else { return nil }
        return TitleViewModel_Maki.shared_Maki.getPosts_Maki().first {
            $0.titleId_Maki == model_maki.titleId_Maki
        } ?? titleModel_Maki
    }

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 媒体区

    private let mediaContainerView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.clipsToBounds = true
        return v_maki
    }()
    private let mediaDisplayView_Maki = MediaDisplayView_Maki()
    /// 媒体底部渐变叠层（突出文字区域）
    private let mediaGradOverlay_Maki = UIView()
    private let mediaGradLayer_Maki   = CAGradientLayer()

    private let backBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        btn_maki.layer.cornerRadius = 19
        btn_maki.layer.borderWidth = 1
        btn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn_maki
    }()

    // MARK: - UI 属性 / 帖子信息区

    private let infoCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = K_Maki.card
        v_maki.layer.cornerRadius = 22
        v_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.07).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_maki.layer.shadowRadius = 12
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    /// 卡片顶部橙色装饰条
    private let infoCardAccent_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 2.5
        return v_maki
    }()

    private let authorRow_Maki = UIView()
    private let authorAvatarView_Maki = UserAvatarView_Maki()
    private let authorNameLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 14, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        return lb_maki
    }()
    private let authorTagLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "Creator"
        lb_maki.font = .systemFont(ofSize: 10, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        lb_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.1)
        lb_maki.layer.cornerRadius = 7
        lb_maki.clipsToBounds = true
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    private let postTitleLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont(name: "Georgia-Bold", size: 21)
            ?? .systemFont(ofSize: 21, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        lb_maki.numberOfLines = 0
        return lb_maki
    }()
    private let postContentLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 14, weight: .regular)
        lb_maki.textColor = UIColor(hexstring_Maki: "#4A3010")
        lb_maki.numberOfLines = 0
        lb_maki.lineBreakMode = .byWordWrapping
        return lb_maki
    }()
    private var postActionBtn_Maki: UIButton?

    // MARK: - UI 属性 / 点赞行

    private let likesRow_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF5E8")
        v_maki.layer.cornerRadius = 12
        return v_maki
    }()
    private let likeBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "heart"), for: .normal)
        btn_maki.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        return btn_maki
    }()
    private let likesCountLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 14, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        return lb_maki
    }()

    // MARK: - UI 属性 / 评论区

    private let commentsSection_Maki = UIView()
    private var commentsStack_Maki: UIStackView!

    // MARK: - UI 属性 / 底部评论输入栏

    private let commentBar_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: -2)
        v_maki.layer.shadowRadius = 8
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let commentTF_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.placeholder = "Write a comment..."
        tf_maki.font = .systemFont(ofSize: 14)
        tf_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF5E8")
        tf_maki.layer.cornerRadius = 20
        tf_maki.layer.borderWidth  = 1
        tf_maki.layer.borderColor  = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.2).cgColor
        tf_maki.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf_maki.leftViewMode = .always
        tf_maki.returnKeyType = .send
        return tf_maki
    }()
    private let commentSendBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        btn_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        return btn_maki
    }()
    /// 送礼按钮：使用资源图片，与发送按钮保持相同点击区域。
    private let giftBtn_maki: UIButton = {
        let button_maki = UIButton(type: .custom)
        button_maki.setImage(UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button_maki.imageView?.contentMode = .scaleAspectFit
        return button_maki
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        bindNotifications_Maki()
        bindKeyboard_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mediaGradLayer_Maki.frame = mediaGradOverlay_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UI 构建

extension Detail_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        scrollView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildMediaSection_Maki()
        buildInfoCard_Maki()
        buildCommentsSection_Maki()

        // 底部评论栏
        view.addSubview(commentBar_Maki)
        commentBar_Maki.addSubview(commentTF_Maki)
        commentBar_Maki.addSubview(giftBtn_maki)
        commentBar_Maki.addSubview(commentSendBtn_Maki)
        commentBar_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(60)
        }
        commentTF_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(giftBtn_maki.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        giftBtn_maki.snp.makeConstraints { make in
            make.trailing.equalTo(commentSendBtn_Maki.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        commentSendBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        commentTF_Maki.delegate = self
        giftBtn_maki.addTarget(self, action: #selector(onGift_maki), for: .touchUpInside)
        commentSendBtn_Maki.addTarget(self, action: #selector(onSendComment_Maki), for: .touchUpInside)
    }

    /// 构建全幅媒体区（图片/视频 + 底部渐变叠层 + 悬浮返回按钮）
    private func buildMediaSection_Maki() {
        contentView_Maki.addSubview(mediaContainerView_Maki)
        mediaContainerView_Maki.addSubview(mediaDisplayView_Maki)
        mediaContainerView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(K_Maki.mediaH)
        }
        mediaDisplayView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 底部渐变叠层
        mediaGradLayer_Maki.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        mediaGradLayer_Maki.startPoint = CGPoint(x: 0.5, y: 0.4)
        mediaGradLayer_Maki.endPoint   = CGPoint(x: 0.5, y: 1.0)
        mediaGradOverlay_Maki.layer.insertSublayer(mediaGradLayer_Maki, at: 0)
        mediaContainerView_Maki.addSubview(mediaGradOverlay_Maki)
        mediaGradOverlay_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 返回按钮（左上角悬浮）
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        mediaContainerView_Maki.addSubview(backBtn_Maki)
        backBtn_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(38)
        }
        backBtn_Maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)

        // 点击媒体进入全屏
        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onMediaTap_Maki))
        mediaContainerView_Maki.isUserInteractionEnabled = true
        mediaContainerView_Maki.addGestureRecognizer(tap_maki)
    }

    /// 构建帖子信息白色圆角卡（作者行 + 标题 + 内容 + 点赞行）
    private func buildInfoCard_Maki() {
        contentView_Maki.addSubview(infoCard_Maki)
        infoCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(mediaContainerView_Maki.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        // 顶部橙色装饰竖条
        infoCard_Maki.addSubview(infoCardAccent_Maki)
        infoCardAccent_Maki.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(18)
            make.width.equalTo(4)
            make.height.equalTo(22)
        }

        // 作者行
        let authorAvtRing_maki = UIView()
        authorAvtRing_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.15)
        authorAvtRing_maki.layer.cornerRadius = 22
        authorAvatarView_Maki.layer.cornerRadius = 18
        authorAvatarView_Maki.clipsToBounds = true
        authorAvatarView_Maki.layer.borderWidth = 2
        authorAvatarView_Maki.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.3).cgColor

        authorRow_Maki.addSubview(authorAvtRing_maki)
        authorRow_Maki.addSubview(authorAvatarView_Maki)
        authorRow_Maki.addSubview(authorNameLb_Maki)
        authorRow_Maki.addSubview(authorTagLb_Maki)

        authorAvtRing_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        authorAvatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(authorAvtRing_maki)
            make.width.height.equalTo(36)
        }
        authorNameLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(authorAvtRing_maki.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(6)
        }
        authorTagLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLb_Maki)
            make.top.equalTo(authorNameLb_Maki.snp.bottom).offset(2)
            make.height.equalTo(16)
            make.width.equalTo(54)
        }

        infoCard_Maki.addSubview(authorRow_Maki)
        authorRow_Maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(infoCardAccent_Maki.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(44)
        }

        // 头像和名字区域点击进入用户中心
        authorAvatarView_Maki.isUserInteractionEnabled = true
        let avatarTap_maki = UITapGestureRecognizer(target: self, action: #selector(onAuthorTap_Maki))
        authorAvatarView_Maki.addGestureRecognizer(avatarTap_maki)
        authorNameLb_Maki.isUserInteractionEnabled = true
        let nameTap_maki = UITapGestureRecognizer(target: self, action: #selector(onAuthorTap_Maki))
        authorNameLb_Maki.addGestureRecognizer(nameTap_maki)

        // 标题
        infoCard_Maki.addSubview(postTitleLb_Maki)
        postTitleLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(authorRow_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 分隔线
        let divider_maki = UIView()
        divider_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")
        infoCard_Maki.addSubview(divider_maki)
        divider_maki.snp.makeConstraints { make in
            make.top.equalTo(postTitleLb_Maki.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(1)
        }

        // 内容
        infoCard_Maki.addSubview(postContentLb_Maki)
        postContentLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(divider_maki.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 点赞行
        likeBtn_Maki.addTarget(self, action: #selector(onLike_Maki), for: .touchUpInside)
        likesRow_Maki.addSubview(likeBtn_Maki)
        likesRow_Maki.addSubview(likesCountLb_Maki)
        infoCard_Maki.addSubview(likesRow_Maki)
        likesRow_Maki.snp.makeConstraints { make in
            make.top.equalTo(postContentLb_Maki.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-18)
        }
        likeBtn_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        likesCountLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(likeBtn_Maki.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-12)
        }
    }

    /// 构建评论区（区块标题 + 评论栈视图）
    private func buildCommentsSection_Maki() {
        commentsStack_Maki = UIStackView()
        commentsStack_Maki.axis = .vertical
        commentsStack_Maki.spacing = 0
        contentView_Maki.addSubview(commentsSection_Maki)
        commentsSection_Maki.snp.makeConstraints { make in
            make.top.equalTo(infoCard_Maki.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 区块标题行
        let titleRow_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right.fill"))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Comments"
        titleLb_maki.font = .systemFont(ofSize: 16, weight: .bold)
        titleLb_maki.textColor = K_Maki.tp
        titleRow_maki.addSubview(iconIV_maki)
        titleRow_maki.addSubview(titleLb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(7)
            make.centerY.trailing.equalToSuperview()
        }
        commentsSection_Maki.addSubview(titleRow_maki)
        titleRow_maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(28)
        }

        commentsSection_Maki.addSubview(commentsStack_Maki)
        commentsStack_Maki.snp.makeConstraints { make in
            make.top.equalTo(titleRow_maki.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - 数据刷新

extension Detail_Maki {

    private func reloadAll_Maki() {
        guard let post_maki = currentPost_Maki else { return }
        titleModel_Maki = post_maki
        mediaDisplayView_Maki.configure_Maki(mediaPath_Maki: post_maki.titleMeidas_Maki.first)
        authorAvatarView_Maki.configure_Maki(userId_Maki: post_maki.titleUserId_Maki)
        authorNameLb_Maki.text = post_maki.titleUserName_Maki

        postActionBtn_Maki?.removeFromSuperview()
        let actionBtn_maki = ReportDeleteHelper_Maki.createPostReportButton_Maki(
            post_Maki: post_maki, size_Maki: 16,
            color_Maki: UIColor.white, from: self
        ) { [weak self] in self?.reloadAll_Maki() }
        // 毛玻璃圆形风格，与左上角返回按钮对称
        actionBtn_maki.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        actionBtn_maki.layer.cornerRadius = 19
        actionBtn_maki.layer.borderWidth = 1
        actionBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        mediaContainerView_Maki.addSubview(actionBtn_maki)
        actionBtn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(38)
        }
        postActionBtn_Maki = actionBtn_maki

        postTitleLb_Maki.text   = post_maki.title_Maki
        postContentLb_Maki.text = post_maki.titleContent_Maki
        let liked_maki = TitleViewModel_Maki.shared_Maki.isLikedPost_Maki(post_maki: post_maki)
        likeBtn_Maki.isSelected = liked_maki
        likesCountLb_Maki.text  = "\(post_maki.likes_Maki) likes"
        rebuildComments_Maki(post_maki: post_maki)
    }

    /// 重建评论 StackView（隐藏被举报用户的评论）
    private func rebuildComments_Maki(post_maki: TitleModel_Maki) {
        commentsStack_Maki.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let blockedIds_maki    = LocalData_Maki.shared_Maki.userList_Maki.map { $0.userId_Maki ?? -1 }
        let currentId_maki     = UserViewModel_Maki.shared_Maki.getCurrentUser_Maki().userId_Maki ?? 0
        let visible_maki = post_maki.reviews_Maki.filter {
            $0.commentUserId_Maki == currentId_maki || blockedIds_maki.contains($0.commentUserId_Maki)
        }
        if visible_maki.isEmpty {
            let emptyWrap_maki = UIView()
            emptyWrap_maki.backgroundColor = .white
            emptyWrap_maki.layer.cornerRadius = 14
            let emptyLb_maki = UILabel()
            emptyLb_maki.text = "💬  No comments yet. Be the first!"
            emptyLb_maki.font = .systemFont(ofSize: 13)
            emptyLb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
            emptyLb_maki.textAlignment = .center
            emptyWrap_maki.addSubview(emptyLb_maki)
            emptyLb_maki.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12))
            }
            commentsStack_Maki.addArrangedSubview(emptyWrap_maki)
            return
        }
        for comment_maki in visible_maki {
            commentsStack_Maki.addArrangedSubview(buildCommentView_Maki(comment_maki: comment_maki, post_maki: post_maki))
        }
    }

    /// 构建单条评论视图（头像 + 用户名 + 内容 + 左侧橙色装饰线）
    private func buildCommentView_Maki(comment_maki: Comment_Maki, post_maki: TitleModel_Maki) -> UIView {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 14
        v_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.04).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_maki.layer.shadowRadius = 5
        v_maki.layer.shadowOpacity = 1

        // 左侧橙色装饰竖线
        let accentLine_maki = UIView()
        accentLine_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.5)
        accentLine_maki.layer.cornerRadius = 2

        let avatar_maki = UserAvatarView_Maki()
        avatar_maki.configure_Maki(userId_Maki: comment_maki.commentUserId_Maki)
        avatar_maki.layer.cornerRadius = 14
        avatar_maki.clipsToBounds = true

        let nameLb_maki = UILabel()
        nameLb_maki.text = comment_maki.commentUserName_Maki
        nameLb_maki.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")

        let contentLb_maki = UILabel()
        contentLb_maki.text = comment_maki.commentContent_Maki
        contentLb_maki.font = .systemFont(ofSize: 13)
        contentLb_maki.textColor = UIColor(hexstring_Maki: "#4A3010")
        contentLb_maki.numberOfLines = 0

        let reportBtn_maki = ReportDeleteHelper_Maki.createCommentReportButton_Maki(
            comment_Maki: comment_maki, post_Maki: post_maki,
            size_Maki: 11, color_Maki: UIColor(hexstring_Maki: "#C0A880"), from: self
        ) { [weak self] in self?.reloadAll_Maki() }

        v_maki.addSubview(accentLine_maki)
        v_maki.addSubview(avatar_maki)
        v_maki.addSubview(nameLb_maki)
        v_maki.addSubview(contentLb_maki)
        v_maki.addSubview(reportBtn_maki)

        accentLine_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(3)
        }
        avatar_maki.snp.makeConstraints { make in
            make.leading.equalTo(accentLine_maki.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }
        nameLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(avatar_maki.snp.trailing).offset(8)
            make.centerY.equalTo(avatar_maki)
            make.trailing.equalTo(reportBtn_maki.snp.leading).offset(-4)
        }
        contentLb_maki.snp.makeConstraints { make in
            make.top.equalTo(avatar_maki.snp.bottom).offset(6)
            make.leading.equalTo(avatar_maki)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        reportBtn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(22)
        }

        // 外层包装（加底部间距 8pt）
        let spacer_maki = UIView(); spacer_maki.backgroundColor = .clear
        spacer_maki.snp.makeConstraints { $0.height.equalTo(8) }
        let wrap_maki = UIStackView(arrangedSubviews: [v_maki, spacer_maki])
        wrap_maki.axis = .vertical
        return wrap_maki
    }
}

// MARK: - 键盘

extension Detail_Maki {

    private func bindKeyboard_Maki() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboard_Maki(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
    }

    @objc private func onKeyboard_Maki(_ n: Notification) {
        guard let kbFrame_maki = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur_maki = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let kbH_maki = max(0, view.frame.height - kbFrame_maki.origin.y)
        UIView.animate(withDuration: dur_maki) {
            self.commentBar_Maki.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-kbH_maki)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - 通知

extension Detail_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChange_Maki),
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki, object: nil)
    }
    @objc private func onDataChange_Maki() { reloadAll_Maki() }
}

// MARK: - 事件响应

extension Detail_Maki {

    @objc private func onBack_Maki() { Navigation_Maki.pop_Maki() }

    /// 点击作者头像/名字 → 跳转用户中心
    @objc private func onAuthorTap_Maki() {
        guard let post_maki = currentPost_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let user_maki = UserViewModel_Maki.shared_Maki.getUserById_Maki(userId_maki: post_maki.titleUserId_Maki)
        Navigation_Maki.toUserInfo_Maki(with: user_maki)
    }

    @objc private func onMediaTap_Maki() {
        guard let mediaPath_maki = currentPost_Maki?.titleMeidas_Maki.first else { return }
        let vc_maki = MediaPlayerPage_Maki()
        vc_maki.mediaPath_Maki = mediaPath_maki
        vc_maki.modalPresentationStyle = .fullScreen
        present(vc_maki, animated: true)
    }

    @objc private func onLike_Maki() {
        guard let post_maki = currentPost_Maki else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        TitleViewModel_Maki.shared_Maki.likePost_Maki(post_maki: post_maki)
        UIView.animate(withDuration: 0.15, animations: {
            self.likeBtn_Maki.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        }) { _ in
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [],
                animations: { self.likeBtn_Maki.transform = .identity }
            )
        }
    }

    /// 打开发帖详情对应的送礼界面。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    @objc private func onGift_maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toGiftPage_maki(from_maki: self)
    }

    @objc private func onSendComment_Maki() {
        let text_maki = commentTF_Maki.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_maki.isEmpty, let post_maki = currentPost_Maki else { return }
        commentTF_Maki.text = nil
        TitleViewModel_Maki.shared_Maki.releaseComment_Maki(post_maki: post_maki, content_maki: text_maki)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Maki: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSendComment_Maki()
        return true
    }
}
