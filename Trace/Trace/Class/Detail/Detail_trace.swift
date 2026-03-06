import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页面

/// 帖子详情页面
/// 核心作用：沉浸式展示帖子媒体、标题、正文、作者信息、点赞，并提供评论列表与发评论功能
/// 设计思路：全屏媒体覆盖顶部 + 浮动圆形导航按钮 + Sheet 式信息卡片（从媒体底部上浮）+ 底部固定输入栏
/// 关键方法：
///   - setupData_Trace(): 初始化帖子数据、动态创建举报/删除按钮
///   - handleTitleStateChange_Trace(): 响应 TitleViewModel 通知，自动刷新或返回上页
///   - reloadComments_Trace(): 重建评论 StackView
class Detail_Trace: UIViewController {

    // MARK: - 外部数据

    /// 外部传入的帖子模型，由外部在 viewDidLoad 前赋值
    var titleModel_Trace: TitleModel_Trace?

    // MARK: - 常量

    /// Tag 渐变色映射
    private static let tagGradientMap_Trace: [String: (String, String)] = [
        "Life":    ("#B794F6", "#90CDF4"),
        "Moments": ("#FBB6CE", "#FED7AA"),
        "Night":   ("#553C9A", "#6B46C1"),
        "Nature":  ("#68D391", "#38B2AC"),
        "Memory":  ("#F6AD55", "#ED8936"),
        "Stars":   ("#F6E05E", "#ECC94B"),
        "Warmth":  ("#FC8181", "#F6AD55"),
        "Friends": ("#76E4F7", "#4299E1")
    ]

    /// 评论/作者头像配色列表
    private static let avatarColors_Trace: [UIColor] = [
        ColorConfig_Trace.primaryGradientStart_Trace,
        ColorConfig_Trace.secondaryGradientStart_Trace,
        UIColor(hexstring_Trace: "#63B3ED"),
        UIColor(hexstring_Trace: "#F6AD55"),
        UIColor(hexstring_Trace: "#FC8181"),
        UIColor(hexstring_Trace: "#68D391")
    ]

    // MARK: - 浮动导航按钮（覆盖在媒体上方）

    /// 浮动导航遮罩层（完全透明，仅承载按钮）
    private let navOverlayView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 返回按钮（小圆形磨砂白）
    private let backBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        btn.layer.cornerRadius = 18
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        btn.layer.borderWidth = 1
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 3)
        btn.layer.shadowRadius = 8
        btn.layer.shadowOpacity = 0.22
        btn.layer.masksToBounds = false
        return btn
    }()

    /// 帖子操作按钮（举报/删除，setupData 中根据登录状态创建）
    private var postActionButton_Trace: UIButton?

    // MARK: - 主滚动区域

    private let scrollView_Trace: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        return v
    }()

    // MARK: - 媒体区域

    /// 媒体展示组件（全屏宽，无圆角）
    private let mediaView_Trace = MediaDisplayView_Trace()

    /// 媒体顶部渐变遮罩容器（保证浮动按钮在媒体上的可读性）
    private let mediaGradientOverlayView_Trace: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let mediaGradientLayer_Trace = CAGradientLayer()

    /// 媒体底部光晕装饰（与卡片过渡区域）
    private let mediaBottomGlowView_Trace: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let mediaBottomGlowLayer_Trace = CAGradientLayer()

    // MARK: - 信息卡片（Sheet 式悬浮在媒体底部上方）

    private let infoCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -6)
        v.layer.shadowRadius = 16
        v.layer.shadowOpacity = 0.08
        v.layer.masksToBounds = false
        return v
    }()

    /// Sheet 拖动指示条
    private let dragIndicatorView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Trace: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()

    // MARK: Tag 徽章

    private let tagBadgeView_Trace: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()

    private let tagGradientLayer_Trace = CAGradientLayer()

    private let tagLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    // MARK: 点赞按钮（图标 + 数字均通过 setImage/setTitle 内置布局，避免 subview 遮盖图标）

    private let likeButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 18
        btn.backgroundColor = UIColor(hexstring_Trace: "#FFF5F5")
        btn.layer.borderColor = UIColor(hexstring_Trace: "#FED7D7").cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        // 图标与文字之间留 4pt，整体左右各 14pt padding
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        return btn
    }()

    // MARK: 帖子标题

    private let titleLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        lbl.numberOfLines = 0
        return lbl
    }()

    // MARK: 统计行（点赞数 + 评论数 展示）

    private let statsRowView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Trace: "#F7FAFC")
        v.layer.cornerRadius = 12
        return v
    }()

    private let statsLikesLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl
    }()

    private let statsCommentsLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        return lbl
    }()

    // MARK: 作者信息行

    /// 作者头像（UserAvatarView_Trace 根据 userId 自动加载）
    private let authorAvatarView_Trace = UserAvatarView_Trace()

    private let authorNameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl
    }()

    private let authorByLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Posted by"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        return lbl
    }()

    // MARK: 正文

    private let dividerView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.divider_Trace
        return v
    }()

    private let contentLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textSecondary_Trace
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()

    // MARK: - 评论卡片

    private let commentsCardView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.06
        v.layer.masksToBounds = false
        return v
    }()

    private let commentsHeaderLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = ColorConfig_Trace.textPrimary_Trace
        return lbl
    }()

    /// 评论数量徽章
    private let commentCountBadge_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace.withAlphaComponent(0.12)
        v.layer.cornerRadius = 10
        return v
    }()

    private let commentCountBadgeLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = ColorConfig_Trace.primaryGradientStart_Trace
        return lbl
    }()

    /// 评论列表 Stack（动态重建）
    private let commentsStackView_Trace: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        return sv
    }()

    /// 空评论状态提示
    private let emptyCommentsView_Trace: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyEmojiLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "🌱"
        lbl.font = UIFont.systemFont(ofSize: 28)
        lbl.textAlignment = .center
        return lbl
    }()

    private let emptyCommentsLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "No comments yet. Be the first!"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Trace.textPlaceholder_Trace
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 评论输入栏（固定底部）

    private let commentInputBar_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.07
        v.layer.masksToBounds = false
        return v
    }()

    private let commentInputField_Trace: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.textColor = ColorConfig_Trace.textPrimary_Trace
        tf.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace
        tf.layer.cornerRadius = 20
        tf.layer.masksToBounds = true
        let lPad = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftView = lPad
        tf.leftViewMode = .always
        let rPad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        tf.rightView = rPad
        tf.rightViewMode = .always
        return tf
    }()

    private let sendButton_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Trace.primaryGradientStart_Trace
        btn.isEnabled = false
        btn.alpha = 0.35
        return btn
    }()

    /// 送礼按钮（位于发送按钮左侧 10pt，使用 Assets 中的 gift_btn 图片）
    private let giftBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_btn"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.masksToBounds = true
        return btn
    }()

    // MARK: - 装饰圆圈（媒体顶部点缀）

    private let decorCircle1_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 55
        v.isUserInteractionEnabled = false
        return v
    }()

    private let decorCircle2_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 35
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        setupData_Trace()
        registerNotifications_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mediaH_trace = view.bounds.width * 0.72
        mediaGradientLayer_Trace.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: mediaH_trace * 0.55)
        mediaBottomGlowLayer_Trace.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 80)
        tagGradientLayer_Trace.frame = tagBadgeView_Trace.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Trace() {
        view.backgroundColor = ColorConfig_Trace.backgroundPrimary_Trace

        // 滚动区域（从 view.top 全屏展开，浮动导航层覆盖其上）
        view.addSubview(scrollView_Trace)
        scrollView_Trace.addSubview(contentView_Trace)

        // 媒体视图（移除默认圆角，贴边全宽）
        mediaView_Trace.layer.cornerRadius = 0
        contentView_Trace.addSubview(mediaView_Trace)

        // 媒体顶部渐变遮罩（保证导航按钮可读性）
        mediaGradientLayer_Trace.colors = [
            UIColor.black.withAlphaComponent(0.45).cgColor,
            UIColor.clear.cgColor
        ]
        mediaGradientLayer_Trace.startPoint = CGPoint(x: 0.5, y: 0)
        mediaGradientLayer_Trace.endPoint = CGPoint(x: 0.5, y: 1)
        mediaGradientOverlayView_Trace.layer.addSublayer(mediaGradientLayer_Trace)
        mediaView_Trace.addSubview(mediaGradientOverlayView_Trace)

        // 媒体底部光晕（与信息卡片过渡）
        mediaBottomGlowLayer_Trace.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.22).cgColor
        ]
        mediaBottomGlowLayer_Trace.startPoint = CGPoint(x: 0.5, y: 0)
        mediaBottomGlowLayer_Trace.endPoint = CGPoint(x: 0.5, y: 1)
        mediaBottomGlowView_Trace.layer.addSublayer(mediaBottomGlowLayer_Trace)
        mediaView_Trace.addSubview(mediaBottomGlowView_Trace)

        // 媒体上装饰圆圈
        mediaView_Trace.addSubview(decorCircle1_Trace)
        mediaView_Trace.addSubview(decorCircle2_Trace)

        // 信息卡片及内容
        contentView_Trace.addSubview(infoCardView_Trace)
        infoCardView_Trace.addSubview(dragIndicatorView_Trace)

        tagGradientLayer_Trace.cornerRadius = 12
        tagBadgeView_Trace.layer.addSublayer(tagGradientLayer_Trace)
        tagBadgeView_Trace.addSubview(tagLabel_Trace)
        infoCardView_Trace.addSubview(tagBadgeView_Trace)
        infoCardView_Trace.addSubview(likeButton_Trace)
        infoCardView_Trace.addSubview(titleLabel_Trace)

        // 统计行
        statsRowView_Trace.addSubview(statsLikesLabel_Trace)
        statsRowView_Trace.addSubview(statsCommentsLabel_Trace)
        infoCardView_Trace.addSubview(statsRowView_Trace)

        // 作者信息
        infoCardView_Trace.addSubview(authorAvatarView_Trace)
        infoCardView_Trace.addSubview(authorByLabel_Trace)
        infoCardView_Trace.addSubview(authorNameLabel_Trace)
        infoCardView_Trace.addSubview(dividerView_Trace)
        infoCardView_Trace.addSubview(contentLabel_Trace)

        // 评论卡片
        commentsCardView_Trace.addSubview(commentsHeaderLabel_Trace)
        commentCountBadge_Trace.addSubview(commentCountBadgeLabel_Trace)
        commentsCardView_Trace.addSubview(commentCountBadge_Trace)
        commentsCardView_Trace.addSubview(commentsStackView_Trace)
        emptyCommentsView_Trace.addSubview(emptyEmojiLabel_Trace)
        emptyCommentsView_Trace.addSubview(emptyCommentsLabel_Trace)
        commentsCardView_Trace.addSubview(emptyCommentsView_Trace)
        contentView_Trace.addSubview(commentsCardView_Trace)

        // 评论输入栏（固定底部）
        view.addSubview(commentInputBar_Trace)
        commentInputBar_Trace.addSubview(commentInputField_Trace)
        commentInputBar_Trace.addSubview(giftBtn_Trace)
        commentInputBar_Trace.addSubview(sendButton_Trace)

        // 浮动导航层（最顶层）
        view.addSubview(navOverlayView_Trace)
        navOverlayView_Trace.addSubview(backBtn_Trace)

        buildConstraints_Trace()
        bindActions_Trace()
    }

    private func buildConstraints_Trace() {
        let mediaH_trace = view.bounds.width * 0.72

        // 滚动区（全屏宽，从 view.top 开始，底部接评论输入栏）
        scrollView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentInputBar_Trace.snp.top)
        }

        contentView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 媒体区域（贴顶全宽）
        mediaView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(mediaH_trace)
        }

        mediaGradientOverlayView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(mediaH_trace * 0.55)
        }

        mediaBottomGlowView_Trace.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        decorCircle1_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(110)
        }

        decorCircle2_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-30)
            make.top.equalToSuperview().offset(60)
            make.width.height.equalTo(70)
        }

        // 信息卡片（叠盖在媒体底部 40pt 以上）
        infoCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Trace.snp.bottom).offset(-40)
            make.leading.trailing.equalToSuperview()
        }

        // 拖动指示条
        dragIndicatorView_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        // Tag 徽章
        tagBadgeView_Trace.snp.makeConstraints { make in
            make.top.equalTo(dragIndicatorView_Trace.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(22)
            make.height.equalTo(26)
        }

        tagLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        // 点赞按钮（右侧与 tag 同行）
        likeButton_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-22)
            make.centerY.equalTo(tagBadgeView_Trace)
            make.height.equalTo(36)
        }

        // 帖子标题
        titleLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(tagBadgeView_Trace.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        // 统计行
        statsRowView_Trace.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Trace.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-22)
            make.height.equalTo(40)
        }

        statsLikesLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(14)
        }

        statsCommentsLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(statsLikesLabel_Trace.snp.trailing).offset(18)
        }

        // 作者信息行
        authorAvatarView_Trace.snp.makeConstraints { make in
            make.top.equalTo(statsRowView_Trace.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(22)
            make.width.height.equalTo(32)
        }

        authorByLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_Trace.snp.trailing).offset(10)
            make.top.equalTo(authorAvatarView_Trace)
        }

        authorNameLabel_Trace.snp.makeConstraints { make in
            make.leading.equalTo(authorByLabel_Trace)
            make.top.equalTo(authorByLabel_Trace.snp.bottom).offset(1)
        }

        // 分割线
        dividerView_Trace.snp.makeConstraints { make in
            make.top.equalTo(authorAvatarView_Trace.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(0.5)
        }

        // 帖子正文
        contentLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Trace.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().offset(-26)
        }

        // 评论卡片（紧接信息卡片，左右留边距）
        commentsCardView_Trace.snp.makeConstraints { make in
            make.top.equalTo(infoCardView_Trace.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }

        commentsHeaderLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
        }

        commentCountBadge_Trace.snp.makeConstraints { make in
            make.centerY.equalTo(commentsHeaderLabel_Trace)
            make.leading.equalTo(commentsHeaderLabel_Trace.snp.trailing).offset(8)
            make.height.equalTo(20)
        }

        commentCountBadgeLabel_Trace.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        commentsStackView_Trace.snp.makeConstraints { make in
            make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }

        emptyCommentsView_Trace.snp.makeConstraints { make in
            make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(84)
            make.bottom.equalToSuperview().offset(-14)
        }

        emptyEmojiLabel_Trace.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }

        emptyCommentsLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(emptyEmojiLabel_Trace.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // 评论输入栏（固定底部）
        commentInputBar_Trace.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        commentInputField_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
            // 输入框右侧紧贴送礼按钮
            make.trailing.equalTo(giftBtn_Trace.snp.leading).offset(-8)
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }

        // 送礼按钮：发送按钮左侧 10pt，垂直居中与输入框对齐，固定 40x40
        giftBtn_Trace.snp.makeConstraints { make in
            make.trailing.equalTo(sendButton_Trace.snp.leading).offset(-10)
            make.centerY.equalTo(commentInputField_Trace)
            make.width.height.equalTo(40)
        }

        sendButton_Trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(commentInputField_Trace)
            make.width.height.equalTo(40)
        }

        // 浮动导航遮罩层（最顶层，不占滚动空间）
        navOverlayView_Trace.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(62)
        }

        backBtn_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 数据填充

    private func setupData_Trace() {
        guard let post_trace = titleModel_Trace else { return }

        // 媒体（取第一个，覆盖全宽）
        mediaView_Trace.configure_Trace(mediaPath_Trace: post_trace.titleMeidas_Trace.first)

        // Tag 徽章渐变色
        let tag_trace = post_trace.titleTag_Trace
        let colors_trace = Self.tagGradientMap_Trace[tag_trace] ?? ("#B794F6", "#90CDF4")
        tagGradientLayer_Trace.colors = [
            UIColor(hexstring_Trace: colors_trace.0).cgColor,
            UIColor(hexstring_Trace: colors_trace.1).cgColor
        ]
        tagGradientLayer_Trace.startPoint = CGPoint(x: 0, y: 0)
        tagGradientLayer_Trace.endPoint = CGPoint(x: 1, y: 1)
        tagLabel_Trace.text = "  \(tag_trace)  "

        // 帖子标题
        titleLabel_Trace.text = post_trace.title_Trace

        // 点赞按钮
        updateLikeButton_Trace(post_trace: post_trace)

        // 统计数据
        statsLikesLabel_Trace.text = "❤️  \(post_trace.likes_Trace) Likes"
        statsCommentsLabel_Trace.text = "💬  \(post_trace.reviews_Trace.count) Comments"

        // 作者头像（UserAvatarView_Trace 根据 userId 自动加载真实头像）
        authorAvatarView_Trace.configure_Trace(userId_Trace: post_trace.titleUserId_Trace)
        authorNameLabel_Trace.text = post_trace.titleUserName_Trace

        // 帖子正文
        contentLabel_Trace.text = post_trace.titleContent_Trace

        // 举报/删除按钮：在 setupData 阶段创建，确保 titleModel_Trace 已赋值
        // 自己的帖子显示删除（trash），他人帖子显示举报（ellipsis），助手类内部自动区分
        setupPostActionButton_Trace(post_trace: post_trace)

        // 评论列表
        reloadComments_Trace()
    }

    /// 创建并配置帖子操作按钮（举报/删除），添加至浮动导航层
    /// - Parameter post_trace: 当前帖子数据
    private func setupPostActionButton_Trace(post_trace: TitleModel_Trace) {
        let actionBtn_trace = ReportDeleteHelper_Trace.createPostReportButton_Trace(
            post_Trace: post_trace,
            size_Trace: 15,
            color_Trace: .white,
            from: self,
            completion_Trace: nil // 帖子删除后由通知机制自动 pop 返回
        )
        actionBtn_trace.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        actionBtn_trace.layer.cornerRadius = 18
        actionBtn_trace.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        actionBtn_trace.layer.borderWidth = 1
        actionBtn_trace.layer.shadowColor = UIColor.black.cgColor
        actionBtn_trace.layer.shadowOffset = CGSize(width: 0, height: 3)
        actionBtn_trace.layer.shadowRadius = 8
        actionBtn_trace.layer.shadowOpacity = 0.22
        actionBtn_trace.layer.masksToBounds = false
        navOverlayView_Trace.addSubview(actionBtn_trace)
        postActionButton_Trace = actionBtn_trace

        actionBtn_trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_Trace)
            make.width.height.equalTo(36)
        }
    }

    /// 更新点赞按钮图标、颜色、数字
    /// - Parameter post_trace: 当前帖子数据
    private func updateLikeButton_Trace(post_trace: TitleModel_Trace) {
        let isLiked_trace = TitleViewModel_Trace.shared_Trace.isLikedPost_Trace(post_trace: post_trace)
        let iconColor_trace = isLiked_trace
            ? UIColor(hexstring_Trace: "#FC8181")
            : UIColor(hexstring_Trace: "#FC8181").withAlphaComponent(0.5)

        // 使用 UIButton 内置 image + title 布局，避免 subview 遮盖图标
        let cfg_trace = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        let iconName_trace = isLiked_trace ? "heart.fill" : "heart"
        likeButton_Trace.setImage(UIImage(systemName: iconName_trace, withConfiguration: cfg_trace), for: .normal)
        likeButton_Trace.tintColor = iconColor_trace
        likeButton_Trace.setTitle("\(post_trace.likes_Trace)", for: .normal)
        likeButton_Trace.setTitleColor(iconColor_trace, for: .normal)
    }

    /// 重建评论列表 StackView
    private func reloadComments_Trace() {
        guard let post_trace = titleModel_Trace else { return }

        // 清空旧评论视图
        commentsStackView_Trace.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let comments_trace = post_trace.reviews_Trace
        let isEmpty_trace = comments_trace.isEmpty

        // 评论头部标题（隐藏评论数，由徽章展示）
        commentsHeaderLabel_Trace.text = "💬  Comments"
        commentCountBadgeLabel_Trace.text = "\(comments_trace.count)"
        commentCountBadge_Trace.isHidden = isEmpty_trace
        emptyCommentsView_Trace.isHidden = !isEmpty_trace

        if isEmpty_trace {
            commentsStackView_Trace.snp.remakeConstraints { make in
                make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0)
            }
            emptyCommentsView_Trace.snp.remakeConstraints { make in
                make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(84)
                make.bottom.equalToSuperview().offset(-14)
            }
        } else {
            emptyCommentsView_Trace.snp.remakeConstraints { make in
                make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0)
            }
            commentsStackView_Trace.snp.remakeConstraints { make in
                make.top.equalTo(commentsHeaderLabel_Trace.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-12)
            }

            for (idx_trace, comment_trace) in comments_trace.enumerated() {
                let cellView_trace = buildCommentCell_Trace(
                    comment_trace: comment_trace,
                    post_trace: post_trace,
                    showDivider_trace: idx_trace < comments_trace.count - 1
                )
                commentsStackView_Trace.addArrangedSubview(cellView_trace)
            }
        }

        // 同步更新统计行
        statsCommentsLabel_Trace.text = "💬  \(comments_trace.count) Comments"
    }

    /// 构建单条评论视图
    /// - Parameters:
    ///   - comment_trace: 评论数据
    ///   - post_trace: 所属帖子（举报/删除助手类需要）
    ///   - showDivider_trace: 是否在底部绘制分割线
    /// - Returns: 配置好的评论 UIView
    private func buildCommentCell_Trace(
        comment_trace: Comment_Trace,
        post_trace: TitleModel_Trace,
        showDivider_trace: Bool
    ) -> UIView {
        let cell_trace = UIView()
        cell_trace.backgroundColor = .white

        // 头像（UserAvatarView_Trace 根据评论者 userId 自动加载）
        let avatarView_trace = UserAvatarView_Trace()
        avatarView_trace.configure_Trace(userId_Trace: comment_trace.commentUserId_Trace)

        // 用户名
        let nameLbl_trace = UILabel()
        nameLbl_trace.text = comment_trace.commentUserName_Trace
        nameLbl_trace.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLbl_trace.textColor = ColorConfig_Trace.textPrimary_Trace

        // 评论内容
        let contentLbl_trace = UILabel()
        contentLbl_trace.text = comment_trace.commentContent_Trace
        contentLbl_trace.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLbl_trace.textColor = ColorConfig_Trace.textSecondary_Trace
        contentLbl_trace.numberOfLines = 0

        // 举报/删除按钮（由助手类创建，自动区分本人/他人）
        let reportBtn_trace = ReportDeleteHelper_Trace.createCommentReportButton_Trace(
            comment_Trace: comment_trace,
            post_Trace: post_trace,
            size_Trace: 12,
            color_Trace: ColorConfig_Trace.textPlaceholder_Trace,
            from: self
        ) { [weak self] in
            self?.reloadComments_Trace()
        }

        // 分割线
        let divider_trace = UIView()
        divider_trace.backgroundColor = ColorConfig_Trace.divider_Trace

        // 视图层级
        cell_trace.addSubview(avatarView_trace)
        cell_trace.addSubview(nameLbl_trace)
        cell_trace.addSubview(reportBtn_trace)
        cell_trace.addSubview(contentLbl_trace)
        cell_trace.addSubview(divider_trace)

        // 布局约束
        avatarView_trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(36)
        }

        reportBtn_trace.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }

        nameLbl_trace.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_trace.snp.trailing).offset(10)
            make.top.equalTo(avatarView_trace)
            make.trailing.lessThanOrEqualTo(reportBtn_trace.snp.leading).offset(-6)
        }

        contentLbl_trace.snp.makeConstraints { make in
            make.leading.equalTo(nameLbl_trace)
            make.top.equalTo(nameLbl_trace.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-56)
            make.bottom.equalTo(divider_trace.snp.top).offset(-14)
        }

        divider_trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(62)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
            make.height.equalTo(showDivider_trace ? 0.5 : 0)
        }

        return cell_trace
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        backBtn_Trace.addTarget(self, action: #selector(handleBackTap_Trace), for: .touchUpInside)
        likeButton_Trace.addTarget(self, action: #selector(handleLikeTap_Trace), for: .touchUpInside)
        commentInputField_Trace.delegate = self
        commentInputField_Trace.addTarget(self, action: #selector(commentFieldChanged_Trace), for: .editingChanged)
        sendButton_Trace.addTarget(self, action: #selector(handleSendComment_Trace), for: .touchUpInside)
        giftBtn_Trace.addTarget(self, action: #selector(handleGiftTap_Trace), for: .touchUpInside)

        let bgTap_trace = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Trace))
        bgTap_trace.cancelsTouchesInView = false
        scrollView_Trace.addGestureRecognizer(bgTap_trace)
    }

    // MARK: - 通知注册

    private func registerNotifications_Trace() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Trace),
            name: TitleViewModel_Trace.titleStateDidChangeNotification_Trace,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardShow_Trace(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardHide_Trace),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 事件处理

    /// 返回上页
    @objc private func handleBackTap_Trace() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Trace.pop_Trace()
    }

    /// 点赞 / 取消点赞（带弹跳动画）
    @objc private func handleLikeTap_Trace() {
        guard let post_trace = titleModel_Trace else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: {
            self.likeButton_Trace.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.6, options: []) {
                self.likeButton_Trace.transform = .identity
            }
        })
        TitleViewModel_Trace.shared_Trace.likePost_Trace(post_trace: post_trace)
    }

    /// 响应 TitleViewModel 状态变化通知，刷新数据；帖子被删则自动返回
    @objc private func handleTitleStateChange_Trace() {
        guard let currentId_trace = titleModel_Trace?.titleId_Trace else { return }
        let updated_trace = TitleViewModel_Trace.shared_Trace.getPosts_Trace().first {
            $0.titleId_Trace == currentId_trace
        }
        if let post_trace = updated_trace {
            titleModel_Trace = post_trace
            updateLikeButton_Trace(post_trace: post_trace)
            statsLikesLabel_Trace.text = "❤️  \(post_trace.likes_Trace) Likes"
            reloadComments_Trace()
        } else {
            // 帖子已被删除，返回上页
            Navigation_Trace.pop_Trace()
        }
    }

    /// 输入框内容变化：控制发送按钮可用状态
    @objc private func commentFieldChanged_Trace() {
        let hasText_trace = !(commentInputField_Trace.text?.isEmpty ?? true)
        sendButton_Trace.isEnabled = hasText_trace
        UIView.animate(withDuration: 0.18) {
            self.sendButton_Trace.alpha = hasText_trace ? 1.0 : 0.35
        }
    }

    /// 发送评论
    @objc private func handleSendComment_Trace() {
        guard let post_trace = titleModel_Trace,
              let text_trace = commentInputField_Trace.text?.trimmingCharacters(in: .whitespaces),
              !text_trace.isEmpty else { return }
        commentInputField_Trace.text = ""
        sendButton_Trace.isEnabled = false
        sendButton_Trace.alpha = 0.35
        view.endEditing(true)
        TitleViewModel_Trace.shared_Trace.releaseComment_Trace(
            post_trace: post_trace,
            content_trace: text_trace
        )
    }

    /// 送礼按钮点击：需要登录才可操作，登录后给出礼物互动反馈
    /// 送礼按钮点击：弹出 GiftView_Trace 模态送礼界面
    @objc private func handleGiftTap_Trace() {
        giftBtn_Trace.animatePulse_Trace()
        let giftVC = GiftView_Trace()
        giftVC.modalPresentationStyle = .overFullScreen
        giftVC.modalTransitionStyle = .crossDissolve
        present(giftVC, animated: false)
    }

    @objc private func dismissKeyboard_Trace() {
        view.endEditing(true)
    }

    // MARK: - 键盘处理

    @objc private func handleKeyboardShow_Trace(_ noti: Notification) {
        guard let frame_trace = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let kbH_trace = frame_trace.height
        UIView.animate(withDuration: 0.28) {
            self.commentInputBar_Trace.transform = CGAffineTransform(translationX: 0, y: -kbH_trace)
        }
        scrollView_Trace.contentInset.bottom = kbH_trace + 60
    }

    @objc private func handleKeyboardHide_Trace() {
        UIView.animate(withDuration: 0.28) {
            self.commentInputBar_Trace.transform = .identity
        }
        scrollView_Trace.contentInset.bottom = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Trace: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendComment_Trace()
        return true
    }
}
