import Foundation
import UIKit
import SnapKit

// MARK: 详情

/// 帖子详情页面
/// 核心作用：展示帖子完整信息（媒体、标题、内容、点赞、评论列表），支持举报/删除/关注
/// 设计思路：媒体卡片化+阴影，作者信息卡片+关注按钮，内容卡片，评论区样式化，输入框固定底部
/// 关键属性：titleModel_Somnia（帖子模型），数据变动通过通知自动响应
class Detail_Somnia: UIViewController {

    // MARK: - 属性

    var titleModel_Somnia: TitleModel_Somnia?

    // MARK: - 私有属性

    /// 当前帖子（从 ViewModel 实时获取确保数据最新）
    private var _currentPost_Somnia: TitleModel_Somnia? {
        guard let tid_Somnia = titleModel_Somnia?.titleId_Somnia else { return nil }
        return TitleViewModel_Somnia.shared_Somnia.getPosts_Somnia()
            .first { $0.titleId_Somnia == tid_Somnia } ?? titleModel_Somnia
    }

    /// 底部输入框底部约束（键盘弹出时更新）
    private var inputBarBottomConstraint_Somnia: Constraint?

    /// 点赞按钮渐变图层（已点赞状态）
    private var likeGradientLayer_Somnia: CAGradientLayer?

    /// 关注按钮渐变图层（未关注状态）
    private var followGradientLayer_Somnia: CAGradientLayer?

    // MARK: - 导航栏

    /// 自定义导航栏（白色卡片+阴影）
    private let navBar_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.06
        return v
    }()

    /// 返回按钮（使用项目内置组件）
    private let backButton_Somnia = BackButton_Somnia()

    /// 导航标题（动态显示帖子标题）
    private let navTitleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()

    /// 右上角举报/删除按钮
    private let reportButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Somnia.textSecondary_Somnia
        return btn
    }()

    // MARK: - 滚动内容

    private let scrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Somnia = UIView()

    // MARK: - 媒体区（带阴影容器+圆角媒体视图）

    /// 媒体卡片阴影容器（不 clipsToBounds，用于投射阴影）
    private let mediaCardWrapper_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 0.18
        return v
    }()

    /// 媒体内容视图（圆角裁切）
    private let mediaView_Somnia: MediaDisplayView_Somnia = {
        let v = MediaDisplayView_Somnia()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    // MARK: - 作者信息卡片

    /// 作者信息卡片（白色卡片+圆角+阴影）
    private let authorCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.06
        return v
    }()

    /// 卡片左侧渐变装饰条
    private let authorAccentBar_Somnia: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2.5
        v.clipsToBounds = true
        return v
    }()

    /// 作者头像（UserAvatarView_Somnia 组件）
    private let authorAvatar_Somnia = UserAvatarView_Somnia()

    /// 作者昵称
    private let authorNameLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        return lbl
    }()

    /// 作者角色副标签
    private let authorSubLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Author"
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        return lbl
    }()

    /// 关注按钮（非本人帖子时展示，渐变→已关注变描边样式）
    private let followButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn.layer.cornerRadius = 16
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 内容卡片

    /// 内容卡片（标题+正文，白色卡片）
    private let contentCard_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.05
        return v
    }()

    /// 帖子标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.numberOfLines = 0
        return lbl
    }()

    /// 帖子正文
    private let contentBodyLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()

    // MARK: - 互动行（点赞）

    /// 互动行容器
    private let interactRow_Somnia = UIView()

    /// 点赞按钮（44pt 高度，图标+数量）
    private let likeButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return btn
    }()

    // MARK: - 评论区

    /// 评论区头部行
    private let commentHeaderRow_Somnia = UIView()

    /// 评论区标题
    private let commentSectionTitle_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.text = "Comments"
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        return lbl
    }()

    /// 评论数量角标（渐变胶囊）
    private let commentCountBadge_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        return lbl
    }()

    /// 评论数量角标渐变图层
    private var commentBadgeGradient_Somnia: CAGradientLayer?

    /// 评论列表容器（StackView 动态重建）
    private let commentStack_Somnia: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    // MARK: - 底部输入栏

    /// 底部输入栏容器（固定底部，白色+顶部阴影）
    private let inputBarWrapper_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.07
        return v
    }()

    /// 顶部分割线
    private let inputTopDivider_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.divider_Somnia
        return v
    }()

    /// 输入框外壳（圆角胶囊卡片）
    private let commentInputView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia
        v.layer.cornerRadius = 22
        v.layer.borderColor = ColorConfig_Somnia.border_Somnia.cgColor
        v.layer.borderWidth = 1
        return v
    }()

    private let commentTextField_Somnia: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = ColorConfig_Somnia.textPrimary_Somnia
        tf.borderStyle = .none
        return tf
    }()

    private let sendCommentButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        return btn
    }()

    /// 礼物按钮（发送按钮左侧 10pt，30×30，原图渲染）
    private let giftButton_Somnia: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshUI_Somnia()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Somnia()
        setupActions_Somnia()
        setupNotifications_Somnia()
        refreshUI_Somnia()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientLayouts_Somnia()
    }

    // MARK: - 私有方法 - UI设置

    private func setupUI_Somnia() {
        view.backgroundColor = ColorConfig_Somnia.backgroundPrimary_Somnia

        // ── 导航栏 ──
        view.addSubview(navBar_Somnia)
        navBar_Somnia.addSubview(backButton_Somnia)
        navBar_Somnia.addSubview(navTitleLabel_Somnia)
        navBar_Somnia.addSubview(reportButton_Somnia)

        // ── 底部输入栏（先添加，scrollView 以此为 bottom 参考） ──
        view.addSubview(inputBarWrapper_Somnia)
        inputBarWrapper_Somnia.addSubview(inputTopDivider_Somnia)
        inputBarWrapper_Somnia.addSubview(commentInputView_Somnia)
        commentInputView_Somnia.addSubview(commentTextField_Somnia)
        commentInputView_Somnia.addSubview(giftButton_Somnia)
        commentInputView_Somnia.addSubview(sendCommentButton_Somnia)

        // ── 滚动内容区 ──
        view.addSubview(scrollView_Somnia)
        scrollView_Somnia.addSubview(contentView_Somnia)

        // 媒体卡片
        contentView_Somnia.addSubview(mediaCardWrapper_Somnia)
        mediaCardWrapper_Somnia.addSubview(mediaView_Somnia)

        // 作者信息卡片
        contentView_Somnia.addSubview(authorCard_Somnia)
        authorCard_Somnia.addSubview(authorAccentBar_Somnia)
        authorCard_Somnia.addSubview(authorAvatar_Somnia)
        authorCard_Somnia.addSubview(authorNameLabel_Somnia)
        authorCard_Somnia.addSubview(authorSubLabel_Somnia)
        authorCard_Somnia.addSubview(followButton_Somnia)

        // 内容卡片
        contentView_Somnia.addSubview(contentCard_Somnia)
        contentCard_Somnia.addSubview(titleLabel_Somnia)
        contentCard_Somnia.addSubview(contentBodyLabel_Somnia)

        // 互动行
        interactRow_Somnia.addSubview(likeButton_Somnia)
        contentView_Somnia.addSubview(interactRow_Somnia)

        // 评论区
        commentHeaderRow_Somnia.addSubview(commentSectionTitle_Somnia)
        commentHeaderRow_Somnia.addSubview(commentCountBadge_Somnia)
        contentView_Somnia.addSubview(commentHeaderRow_Somnia)
        contentView_Somnia.addSubview(commentStack_Somnia)

        setupConstraints_Somnia()
    }

    /// 设置全部布局约束
    private func setupConstraints_Somnia() {

        // ── 导航栏 ──
        navBar_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(68)
        }
        backButton_Somnia.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        navTitleLabel_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Somnia)
            make.left.equalTo(backButton_Somnia.snp.right).offset(8)
            make.right.equalTo(reportButton_Somnia.snp.left).offset(-8)
        }
        reportButton_Somnia.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Somnia)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(40)
        }

        // ── 底部输入栏 ──
        inputBarWrapper_Somnia.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            inputBarBottomConstraint_Somnia = make.bottom.equalToSuperview().constraint
        }
        inputTopDivider_Somnia.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        commentInputView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        commentTextField_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(giftButton_Somnia.snp.left).offset(-8)
        }
        // 礼物按钮：发送按钮左侧 10pt，30×30
        giftButton_Somnia.snp.makeConstraints { make in
            make.right.equalTo(sendCommentButton_Somnia.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        sendCommentButton_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }

        // ── 滚动内容区 ──
        scrollView_Somnia.snp.makeConstraints { make in
            make.top.equalTo(navBar_Somnia.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBarWrapper_Somnia.snp.top)
        }
        contentView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // ── 媒体卡片 ──
        mediaCardWrapper_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(260)
        }
        mediaView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // ── 作者信息卡片 ──
        authorCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(mediaCardWrapper_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        authorAccentBar_Somnia.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(36)
        }
        authorAvatar_Somnia.snp.makeConstraints { make in
            make.left.equalTo(authorAccentBar_Somnia.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        authorNameLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar_Somnia.snp.right).offset(12)
            make.top.equalTo(authorAvatar_Somnia).offset(4)
            make.right.lessThanOrEqualTo(followButton_Somnia.snp.left).offset(-12)
        }
        authorSubLabel_Somnia.snp.makeConstraints { make in
            make.left.equalTo(authorNameLabel_Somnia)
            make.top.equalTo(authorNameLabel_Somnia.snp.bottom).offset(3)
        }
        followButton_Somnia.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(88)
        }

        // ── 内容卡片 ──
        contentCard_Somnia.snp.makeConstraints { make in
            make.top.equalTo(authorCard_Somnia.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview().inset(16)
        }
        contentBodyLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-18)
        }

        // ── 互动行（点赞） ──
        interactRow_Somnia.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Somnia.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }
        likeButton_Somnia.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(120)
        }

        // ── 评论区头部 ──
        commentHeaderRow_Somnia.snp.makeConstraints { make in
            make.top.equalTo(interactRow_Somnia.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        commentSectionTitle_Somnia.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        commentCountBadge_Somnia.snp.makeConstraints { make in
            make.left.equalTo(commentSectionTitle_Somnia.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(28)
        }

        // ── 评论列表 ──
        commentStack_Somnia.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderRow_Somnia.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-28)
        }
    }

    private func setupActions_Somnia() {
        backButton_Somnia.onTapped_Somnia = {
            Navigation_Somnia.pop_Somnia()
        }
        reportButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handlePostReport_Somnia()
        }, for: .touchUpInside)
        likeButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleLike_Somnia()
        }, for: .touchUpInside)
        followButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleFollow_Somnia()
        }, for: .touchUpInside)
        sendCommentButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleSendComment_Somnia()
        }, for: .touchUpInside)
        giftButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.handleGiftTapped_Somnia()
        }, for: .touchUpInside)
        commentTextField_Somnia.addTarget(self, action: #selector(handleCommentReturn_Somnia), for: .editingDidEndOnExit)

        // 点击作者区域 → 进入用户中心
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleAuthorTap_Somnia))
        authorCard_Somnia.addGestureRecognizer(tap_Somnia)
        authorCard_Somnia.isUserInteractionEnabled = true
    }

    private func setupNotifications_Somnia() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTitleChange_Somnia),
            name: TitleViewModel_Somnia.titleStateDidChangeNotification_Somnia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUserChange_Somnia),
            name: UserViewModel_Somnia.userStateDidChangeNotification_Somnia, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Somnia(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Somnia(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 私有方法 - 渐变图层更新

    /// 更新所有需要在布局完成后才能确定 frame 的渐变图层
    private func updateGradientLayouts_Somnia() {
        // 作者卡片左侧装饰条渐变
        if authorAccentBar_Somnia.bounds.width > 0 {
            authorAccentBar_Somnia.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            let barGrad_Somnia = CAGradientLayer()
            barGrad_Somnia.frame = authorAccentBar_Somnia.bounds
            barGrad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            barGrad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            barGrad_Somnia.endPoint = CGPoint(x: 0, y: 1)
            barGrad_Somnia.cornerRadius = 2.5
            authorAccentBar_Somnia.layer.insertSublayer(barGrad_Somnia, at: 0)
        }

        // 评论数量角标渐变
        if commentCountBadge_Somnia.bounds.width > 0 {
            commentBadgeGradient_Somnia?.removeFromSuperlayer()
            let badgeGrad_Somnia = CAGradientLayer()
            badgeGrad_Somnia.frame = commentCountBadge_Somnia.bounds
            badgeGrad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            badgeGrad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            badgeGrad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            badgeGrad_Somnia.cornerRadius = 10
            commentCountBadge_Somnia.layer.insertSublayer(badgeGrad_Somnia, at: 0)
            commentBadgeGradient_Somnia = badgeGrad_Somnia
        }

        // 关注按钮渐变（未关注状态下的渐变背景）
        if followButton_Somnia.bounds.width > 0,
           followButton_Somnia.backgroundColor == .clear {
            followGradientLayer_Somnia?.removeFromSuperlayer()
            let fGrad_Somnia = CAGradientLayer()
            fGrad_Somnia.frame = followButton_Somnia.bounds
            fGrad_Somnia.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            fGrad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            fGrad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            fGrad_Somnia.cornerRadius = 16
            followButton_Somnia.layer.insertSublayer(fGrad_Somnia, at: 0)
            followGradientLayer_Somnia = fGrad_Somnia
        }

        // 点赞按钮渐变（已点赞时应用）
        if let likeGrad_Somnia = likeGradientLayer_Somnia {
            likeGrad_Somnia.frame = likeButton_Somnia.bounds
        }
    }

    // MARK: - 私有方法 - 数据刷新

    private func refreshUI_Somnia() {
        guard let post_Somnia = _currentPost_Somnia else { return }

        // 导航标题 = 帖子标题
        navTitleLabel_Somnia.text = post_Somnia.title_Somnia

        // 媒体
        let mediaPath_Somnia = post_Somnia.titleMeidas_Somnia.first ?? ""
        let isVideo_Somnia = mediaPath_Somnia.hasSuffix(".mp4") || mediaPath_Somnia.hasSuffix(".mov") || mediaPath_Somnia.hasSuffix(".m4v")
        mediaView_Somnia.configure_Somnia(mediaPath_Somnia: mediaPath_Somnia, isVideo_Somnia: isVideo_Somnia)

        // 作者信息
        authorAvatar_Somnia.configure_Somnia(userId_Somnia: post_Somnia.titleUserId_Somnia)
        authorNameLabel_Somnia.text = post_Somnia.titleUserName_Somnia

        // 内容
        titleLabel_Somnia.text = post_Somnia.title_Somnia
        contentBodyLabel_Somnia.text = post_Somnia.titleContent_Somnia

        // 点赞按钮
        updateLikeButton_Somnia(post_Somnia: post_Somnia)

        // 举报/删除按钮
        updatePostReportButton_Somnia(post_Somnia: post_Somnia)

        // 关注按钮
        updateFollowButton_Somnia(post_Somnia: post_Somnia)

        // 评论列表
        refreshComments_Somnia(post_Somnia: post_Somnia)
    }

    /// 更新点赞按钮状态（44pt，已点赞时渐变背景）
    /// - Parameter post_Somnia: 当前帖子模型
    private func updateLikeButton_Somnia(post_Somnia: TitleModel_Somnia) {
        let isLiked_Somnia = TitleViewModel_Somnia.shared_Somnia.isLikedPost_Somnia(post_somnia: post_Somnia)
        let iconName_Somnia = isLiked_Somnia ? "heart.fill" : "heart"
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        likeButton_Somnia.setImage(UIImage(systemName: iconName_Somnia, withConfiguration: cfg_Somnia), for: .normal)
        likeButton_Somnia.setTitle("  \(post_Somnia.likes_Somnia)", for: .normal)

        // 移除旧渐变图层
        likeGradientLayer_Somnia?.removeFromSuperlayer()
        likeGradientLayer_Somnia = nil

        if isLiked_Somnia {
            // 已点赞：渐变背景 + 白色文字图标
            let grad_Somnia = CAGradientLayer()
            grad_Somnia.frame = likeButton_Somnia.bounds
            grad_Somnia.colors = [
                ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor
            ]
            grad_Somnia.startPoint = CGPoint(x: 0, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 1, y: 0)
            grad_Somnia.cornerRadius = 22
            likeButton_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
            likeGradientLayer_Somnia = grad_Somnia
            likeButton_Somnia.backgroundColor = .clear
            likeButton_Somnia.tintColor = .white
            likeButton_Somnia.setTitleColor(.white, for: .normal)
        } else {
            // 未点赞：浅灰背景
            likeButton_Somnia.backgroundColor = ColorConfig_Somnia.divider_Somnia
            likeButton_Somnia.tintColor = ColorConfig_Somnia.textSecondary_Somnia
            likeButton_Somnia.setTitleColor(ColorConfig_Somnia.textSecondary_Somnia, for: .normal)
        }
    }

    /// 更新帖子举报/删除按钮图标
    /// - Parameter post_Somnia: 当前帖子模型
    private func updatePostReportButton_Somnia(post_Somnia: TitleModel_Somnia) {
        let isMyPost_Somnia = UserViewModel_Somnia.shared_Somnia.isCurrentUser_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
        let iconName_Somnia = isMyPost_Somnia ? "trash" : "ellipsis.circle"
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        reportButton_Somnia.setImage(UIImage(systemName: iconName_Somnia, withConfiguration: cfg_Somnia), for: .normal)
        reportButton_Somnia.tintColor = isMyPost_Somnia
            ? UIColor(hexstring_Somnia: "#E53E3E")
            : ColorConfig_Somnia.textSecondary_Somnia
    }

    /// 更新关注按钮状态（非本人帖子时展示）
    /// - Parameter post_Somnia: 当前帖子模型
    private func updateFollowButton_Somnia(post_Somnia: TitleModel_Somnia) {
        let isMyPost_Somnia = UserViewModel_Somnia.shared_Somnia.isCurrentUser_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)

        if isMyPost_Somnia {
            // 自己的帖子不展示关注按钮
            followButton_Somnia.isHidden = true
            return
        }

        followButton_Somnia.isHidden = false
        let authorUser_Somnia = UserViewModel_Somnia.shared_Somnia.getUserById_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
        let isFollowing_Somnia = UserViewModel_Somnia.shared_Somnia.isFollowing_Somnia(user_somnia: authorUser_Somnia)

        // 移除旧渐变（避免叠加）
        followGradientLayer_Somnia?.removeFromSuperlayer()
        followGradientLayer_Somnia = nil

        if isFollowing_Somnia {
            // 已关注：描边样式
            followButton_Somnia.backgroundColor = .white
            followButton_Somnia.setTitle("Following", for: .normal)
            followButton_Somnia.setTitleColor(ColorConfig_Somnia.primaryGradientStart_Somnia, for: .normal)
            followButton_Somnia.layer.borderColor = ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor
            followButton_Somnia.layer.borderWidth = 1.5
        } else {
            // 未关注：渐变填充（图层在 viewDidLayoutSubviews 中更新）
            followButton_Somnia.backgroundColor = .clear
            followButton_Somnia.setTitle("Follow", for: .normal)
            followButton_Somnia.setTitleColor(.white, for: .normal)
            followButton_Somnia.layer.borderWidth = 0
            // 触发 viewDidLayoutSubviews 添加渐变
            followButton_Somnia.setNeedsLayout()
        }
    }

    /// 刷新评论列表（清空重建）
    /// - Parameter post_Somnia: 当前帖子模型
    private func refreshComments_Somnia(post_Somnia: TitleModel_Somnia) {
        commentStack_Somnia.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 更新评论数角标
        let count_Somnia = post_Somnia.reviews_Somnia.count
        commentCountBadge_Somnia.text = "  \(count_Somnia)  "

        for comment_Somnia in post_Somnia.reviews_Somnia {
            let commentView_Somnia = buildCommentView_Somnia(
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia
            )
            commentStack_Somnia.addArrangedSubview(commentView_Somnia)
        }

        if post_Somnia.reviews_Somnia.isEmpty {
            let emptyContainer_Somnia = UIView()
            let emptyIcon_Somnia = UIImageView()
            let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
            emptyIcon_Somnia.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg_Somnia)
            emptyIcon_Somnia.tintColor = ColorConfig_Somnia.textPlaceholder_Somnia
            emptyIcon_Somnia.contentMode = .scaleAspectFit
            let emptyLbl_Somnia = UILabel()
            emptyLbl_Somnia.text = "Be the first to comment ✨"
            emptyLbl_Somnia.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            emptyLbl_Somnia.textColor = ColorConfig_Somnia.textPlaceholder_Somnia
            emptyLbl_Somnia.textAlignment = .center
            emptyContainer_Somnia.addSubview(emptyIcon_Somnia)
            emptyContainer_Somnia.addSubview(emptyLbl_Somnia)
            emptyIcon_Somnia.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(40)
            }
            emptyLbl_Somnia.snp.makeConstraints { make in
                make.top.equalTo(emptyIcon_Somnia.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-20)
            }
            commentStack_Somnia.addArrangedSubview(emptyContainer_Somnia)
        }
    }

    /// 构建单条评论卡片视图
    /// - Parameters:
    ///   - comment_Somnia: 评论模型
    ///   - post_Somnia: 所属帖子模型
    /// - Returns: 配置完成的评论卡片视图
    private func buildCommentView_Somnia(comment_Somnia: Comment_Somnia,
                                          post_Somnia: TitleModel_Somnia) -> UIView {
        let card_Somnia = UIView()
        card_Somnia.backgroundColor = .white
        card_Somnia.layer.cornerRadius = 16
        card_Somnia.layer.shadowColor = UIColor.black.cgColor
        card_Somnia.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_Somnia.layer.shadowRadius = 6
        card_Somnia.layer.shadowOpacity = 0.04

        // 评论者头像（UserAvatarView_Somnia 组件）
        let avatar_Somnia = UserAvatarView_Somnia()
        avatar_Somnia.configure_Somnia(userId_Somnia: comment_Somnia.commentUserId_Somnia)

        let nameLabel_Somnia = UILabel()
        nameLabel_Somnia.text = comment_Somnia.commentUserName_Somnia
        nameLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia

        let contentLabel_Somnia = UILabel()
        contentLabel_Somnia.text = comment_Somnia.commentContent_Somnia
        contentLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        contentLabel_Somnia.numberOfLines = 0

        let commentReportBtn_Somnia = ReportDeleteHelper_Somnia.createCommentReportButton_Somnia(
            comment_Somnia: comment_Somnia,
            post_Somnia: post_Somnia,
            size_Somnia: 14,
            color_Somnia: ColorConfig_Somnia.textPlaceholder_Somnia,
            from: self
        ) { [weak self] in
            self?.refreshUI_Somnia()
        }

        card_Somnia.addSubview(avatar_Somnia)
        card_Somnia.addSubview(nameLabel_Somnia)
        card_Somnia.addSubview(contentLabel_Somnia)
        card_Somnia.addSubview(commentReportBtn_Somnia)

        avatar_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(14)
            make.width.height.equalTo(36)
        }
        nameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatar_Somnia)
            make.left.equalTo(avatar_Somnia.snp.right).offset(10)
            make.right.equalTo(commentReportBtn_Somnia.snp.left).offset(-8)
        }
        contentLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(5)
            make.left.equalTo(avatar_Somnia.snp.right).offset(10)
            make.right.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
        commentReportBtn_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.height.equalTo(24)
        }

        return card_Somnia
    }

    // MARK: - 私有方法 - 事件处理

    private func handlePostReport_Somnia() {
        guard let post_Somnia = _currentPost_Somnia else { return }
        let isMyPost_Somnia = UserViewModel_Somnia.shared_Somnia.isCurrentUser_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
        if isMyPost_Somnia {
            ReportDeleteHelper_Somnia.delete_Somnia(post_Somnia: post_Somnia, from: self) { [weak self] in
                Navigation_Somnia.pop_Somnia()
            }
        } else {
            ReportDeleteHelper_Somnia.report_Somnia(post_Somnia: post_Somnia, from: self) { [weak self] in
                Navigation_Somnia.pop_Somnia()
            }
        }
    }

    private func handleLike_Somnia() {
        guard let post_Somnia = _currentPost_Somnia else { return }
        // 点赞按压反馈动画
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton_Somnia.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 8) {
                self.likeButton_Somnia.transform = .identity
            }
        }
        Task { @MainActor in
            TitleViewModel_Somnia.shared_Somnia.likePost_Somnia(post_somnia: post_Somnia)
        }
    }

    /// 关注/取消关注帖子作者
    private func handleFollow_Somnia() {
        guard let post_Somnia = _currentPost_Somnia else { return }
        let authorUser_Somnia = UserViewModel_Somnia.shared_Somnia.getUserById_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
        // 按压弹簧动画反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.followButton_Somnia.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 6) {
                self.followButton_Somnia.transform = .identity
            }
        }
        UserViewModel_Somnia.shared_Somnia.followUser_Somnia(user_somnia: authorUser_Somnia)
    }

    private func handleSendComment_Somnia() {
        let text_Somnia = commentTextField_Somnia.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !text_Somnia.isEmpty, let post_Somnia = _currentPost_Somnia else { return }
        Task { @MainActor in
            TitleViewModel_Somnia.shared_Somnia.releaseComment_Somnia(post_somnia: post_Somnia, content_somnia: text_Somnia)
        }
        commentTextField_Somnia.text = ""
        view.endEditing(true)
    }

    @objc private func handleAuthorTap_Somnia() {
        guard let post_Somnia = _currentPost_Somnia else { return }
        let user_Somnia = UserViewModel_Somnia.shared_Somnia.getUserById_Somnia(userId_somnia: post_Somnia.titleUserId_Somnia)
        Navigation_Somnia.toUserInfo_Somnia(with: user_Somnia)
    }

    @objc private func handleCommentReturn_Somnia() { handleSendComment_Somnia() }
    @objc private func handleTitleChange_Somnia() { refreshUI_Somnia() }
    @objc private func handleUserChange_Somnia() { refreshUI_Somnia() }

    /// 礼物按钮点击 - 以模态方式弹起礼物页
    private func handleGiftTapped_Somnia() {
        view.endEditing(true)
        let giftVC_Somnia = GiftPage_Somnia()
        giftVC_Somnia.modalPresentationStyle = .overFullScreen
        giftVC_Somnia.modalTransitionStyle   = .crossDissolve
        present(giftVC_Somnia, animated: true)
    }

    // MARK: - 键盘事件处理

    /// 键盘弹出时底部输入栏上移避让
    /// - Parameter notification: 携带键盘高度和动画时长
    @objc private func keyboardWillShow_Somnia(_ notification: Notification) {
        guard let frame_Somnia = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur_Somnia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint_Somnia?.update(offset: -frame_Somnia.height)
        UIView.animate(withDuration: dur_Somnia) { self.view.layoutIfNeeded() }
    }

    /// 键盘收起时底部输入栏恢复原位
    /// - Parameter notification: 携带动画时长
    @objc private func keyboardWillHide_Somnia(_ notification: Notification) {
        guard let dur_Somnia = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        inputBarBottomConstraint_Somnia?.update(offset: 0)
        UIView.animate(withDuration: dur_Somnia) { self.view.layoutIfNeeded() }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
