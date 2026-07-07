import Foundation
import UIKit
import SnapKit

// MARK: - 帖子展示详情页面（重构版）

/// 帖子详情页面（重构版）
/// 核心作用：完整展示帖子内容（标题、正文、媒体、点赞、评论），并提供评论输入和点赞交互
/// 设计思路：
///   - 背景多层径向光晕 + 毛玻璃导航栏 + 彩虹装饰条
///   - 作者信息卡片（彩虹头像光圈）+ 正文卡片 + 媒体阴影卡片
///   - 点赞/评论胶囊操作区 + 渐变区块标题评论区
///   - 底部毛玻璃评论输入栏，键盘弹出时联动上移
/// 关键属性：
///   - titleModel_Lens: 帖子数据，由外部传入
///   - commentBarBottomConstraint_Lens: 评论输入栏底部约束（键盘联动用）
///   - mediaHeightConstraint_Lens: 媒体区高度约束（无媒体时折叠）
class Detail_Lens: UIViewController {

    // MARK: - 外部属性

    /// 帖子数据（由 Navigation_Lens 设置）
    var titleModel_Lens: TitleModel_Lens?

    // MARK: - 私有属性

    /// 评论输入栏底部约束引用，用于键盘联动
    private var commentBarBottomConstraint_Lens: Constraint?

    /// 媒体展示高度约束（无媒体时设为 0）
    private var mediaHeightConstraint_Lens: Constraint?

    /// 举报/删除按钮（由 ReportDeleteHelper_Lens 创建，布局后替换）
    private var postReportButton_Lens: UIButton?

    // MARK: - UI 组件：背景装饰

    private let backgroundGlowView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - UI 组件：顶部导航栏

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let navBlurView_Lens: UIVisualEffectView = {
        let blur_Lens = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v = UIVisualEffectView(effect: blur_Lens)
        return v
    }()

    private let spectrumBarView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 1
        v.clipsToBounds = true
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Post Detail"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：滚动内容

    private let scrollView_Lens: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentContainer_Lens = UIView()

    // MARK: - UI 组件：帖子信息区

    /// 作者信息卡片
    private let authorCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        return v
    }()

    /// 作者头像彩虹光圈
    private let authorRingView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    /// 作者信息容器（头像 + 昵称，点击跳转个人中心）
    private let authorRow_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        return v
    }()

    private let authorAvatar_Lens = UserAvatarView_Lens()

    private let authorNameLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let authorHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "View Profile"
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        return l
    }()

    private let authorChevron_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 正文卡片
    private let postCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        return v
    }()

    private let postTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()

    private let postContentLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.72)
        l.numberOfLines = 0
        return l
    }()

    // MARK: - UI 组件：媒体展示

    private let mediaCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.35
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 12
        return v
    }()

    private let mediaDisplayView_Lens: MediaDisplayView_Lens = {
        let v = MediaDisplayView_Lens()
        v.isUserInteractionEnabled = true
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 媒体底部渐变遮罩
    private let mediaGradientOverlay_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    // MARK: - UI 组件：点赞/评论操作行

    private let actionCardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        return v
    }()

    private let likeChipView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        v.layer.cornerRadius = 18
        return v
    }()

    private let likeButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        b.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        return b
    }()

    private let likeCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.75)
        return l
    }()

    private let commentChipView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        v.layer.cornerRadius = 18
        return v
    }()

    private let commentIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv.image = UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.8)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentCountLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.75)
        return l
    }()

    // MARK: - UI 组件：评论区

    private let commentHeaderView_Lens = UIView()

    private let commentAccentBar_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 1.5
        return v
    }()

    private let commentSectionLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "COMMENTS"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.85)
        return l
    }()

    private let commentCountBadge_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        return l
    }()

    /// 评论列表容器（动态添加评论行视图）
    private let commentsContainer_Lens = UIView()

    // MARK: - UI 组件：底部评论输入栏

    private let commentInputBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        return v
    }()

    private let commentBarBlur_Lens: UIVisualEffectView = {
        let blur_Lens = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let v = UIVisualEffectView(effect: blur_Lens)
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()

    private let commentTopDivider_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isHidden = true
        return v
    }()

    /// 输入框外层胶囊容器
    private let inputCapsuleView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08)
        v.layer.cornerRadius = 26
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12).cgColor
        return v
    }()

    private let inputIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        iv.image = UIImage(systemName: "text.bubble", withConfiguration: cfg_Lens)
        iv.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentTextField_Lens: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = .white
        tf.backgroundColor = .clear
        tf.borderStyle = .none
        let placeholder_Lens = NSAttributedString(
            string: "Write a comment...",
            attributes: [.foregroundColor: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.32)]
        )
        tf.attributedPlaceholder = placeholder_Lens
        return tf
    }()

    /// 发送按钮渐变背景（独立于按钮图层，避免遮挡图标）
    private let sendBgView_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private let sendGradientLayer_Lens: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(hexstring_Lens: "#7B2FF7").cgColor,
            UIColor(hexstring_Lens: "#2D5BE3").cgColor
        ]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        return g
    }()

    private let sendIconView_Lens: UIImageView = {
        let iv = UIImageView()
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)
        iv.image = UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Lens)?
            .withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    private let sendButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        setupConstraints_Lens()
        bindActions_Lens()
        bindNotifications_Lens()
        renderPostData_Lens()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navBarHeight_Lens = view.safeAreaInsets.top + 56
        navBar_Lens.snp.updateConstraints { $0.height.equalTo(navBarHeight_Lens) }
        if scrollView_Lens.contentInset.top != navBarHeight_Lens {
            scrollView_Lens.contentInset.top = navBarHeight_Lens
            scrollView_Lens.scrollIndicatorInsets.top = navBarHeight_Lens
        }
        // 同步彩虹装饰条
        if spectrumBarView_Lens.layer.sublayers?.isEmpty != false {
            let grad_Lens = CAGradientLayer()
            grad_Lens.colors = [
                UIColor(hexstring_Lens: "#C77DFF").cgColor,
                UIColor(hexstring_Lens: "#4D96FF").cgColor,
                UIColor(hexstring_Lens: "#6BCB77").cgColor,
                UIColor(hexstring_Lens: "#FFD93D").cgColor,
                UIColor(hexstring_Lens: "#FF6B6B").cgColor
            ]
            grad_Lens.startPoint = CGPoint(x: 0, y: 0.5)
            grad_Lens.endPoint = CGPoint(x: 1, y: 0.5)
            grad_Lens.frame = spectrumBarView_Lens.bounds
            spectrumBarView_Lens.layer.addSublayer(grad_Lens)
        } else if let grad_Lens = spectrumBarView_Lens.layer.sublayers?.first as? CAGradientLayer {
            grad_Lens.frame = spectrumBarView_Lens.bounds
        }
        // 同步作者光圈
        if let ringLayer_Lens = authorRingView_Lens.layer.sublayers?.first as? CAGradientLayer {
            ringLayer_Lens.frame = authorRingView_Lens.bounds
        }
        // 同步媒体渐变遮罩
        if mediaGradientOverlay_Lens.layer.sublayers?.isEmpty != false {
            let overlayGrad_Lens = CAGradientLayer()
            overlayGrad_Lens.colors = [
                UIColor.clear.cgColor,
                UIColor(hexstring_Lens: "#000000", alpha_Lens: 0.35).cgColor
            ]
            overlayGrad_Lens.locations = [0.5, 1.0]
            overlayGrad_Lens.frame = mediaGradientOverlay_Lens.bounds
            mediaGradientOverlay_Lens.layer.addSublayer(overlayGrad_Lens)
        } else if let overlayGrad_Lens = mediaGradientOverlay_Lens.layer.sublayers?.first as? CAGradientLayer {
            overlayGrad_Lens.frame = mediaGradientOverlay_Lens.bounds
        }
        // 同步评论标题渐变竖条
        if commentAccentBar_Lens.layer.sublayers?.isEmpty != false {
            let barGrad_Lens = CAGradientLayer()
            barGrad_Lens.colors = [
                UIColor(hexstring_Lens: "#7B2FF7").cgColor,
                UIColor(hexstring_Lens: "#4D96FF").cgColor
            ]
            barGrad_Lens.startPoint = CGPoint(x: 0.5, y: 0)
            barGrad_Lens.endPoint = CGPoint(x: 0.5, y: 1)
            barGrad_Lens.cornerRadius = 1.5
            barGrad_Lens.frame = commentAccentBar_Lens.bounds
            commentAccentBar_Lens.layer.addSublayer(barGrad_Lens)
        } else if let barGrad_Lens = commentAccentBar_Lens.layer.sublayers?.first as? CAGradientLayer {
            barGrad_Lens.frame = commentAccentBar_Lens.bounds
        }
        sendGradientLayer_Lens.frame = sendBgView_Lens.bounds
        sendGradientLayer_Lens.cornerRadius = sendBgView_Lens.bounds.height / 2
        mediaCardView_Lens.layer.shadowPath = UIBezierPath(
            roundedRect: mediaCardView_Lens.bounds, cornerRadius: 18
        ).cgPath
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 构建视图层级
    private func setupUI_Lens() {
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")

        view.insertSubview(backgroundGlowView_Lens, at: 0)
        backgroundGlowView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(320)
        }
        setupBackgroundGlows_Lens()

        view.addSubview(scrollView_Lens)
        scrollView_Lens.addSubview(contentContainer_Lens)
        scrollView_Lens.contentInsetAdjustmentBehavior = .never

        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(navBlurView_Lens)
        navBar_Lens.addSubview(spectrumBarView_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        navBlurView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        spectrumBarView_Lens.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(2)
        }

        // 作者卡片
        contentContainer_Lens.addSubview(authorCardView_Lens)
        authorCardView_Lens.addSubview(authorRow_Lens)
        setupAuthorRingGradient_Lens()
        authorRow_Lens.addSubview(authorRingView_Lens)
        authorRingView_Lens.addSubview(authorAvatar_Lens)
        authorRow_Lens.addSubview(authorNameLabel_Lens)
        authorRow_Lens.addSubview(authorHintLabel_Lens)
        authorRow_Lens.addSubview(authorChevron_Lens)

        // 正文卡片
        contentContainer_Lens.addSubview(postCardView_Lens)
        postCardView_Lens.addSubview(postTitleLabel_Lens)
        postCardView_Lens.addSubview(postContentLabel_Lens)

        // 媒体卡片
        contentContainer_Lens.addSubview(mediaCardView_Lens)
        mediaCardView_Lens.addSubview(mediaDisplayView_Lens)
        mediaCardView_Lens.addSubview(mediaGradientOverlay_Lens)

        // 操作胶囊卡片
        contentContainer_Lens.addSubview(actionCardView_Lens)
        actionCardView_Lens.addSubview(likeChipView_Lens)
        likeChipView_Lens.addSubview(likeButton_Lens)
        likeChipView_Lens.addSubview(likeCountLabel_Lens)
        actionCardView_Lens.addSubview(commentChipView_Lens)
        commentChipView_Lens.addSubview(commentIconView_Lens)
        commentChipView_Lens.addSubview(commentCountLabel_Lens)

        // 评论区
        contentContainer_Lens.addSubview(commentHeaderView_Lens)
        commentHeaderView_Lens.addSubview(commentAccentBar_Lens)
        commentHeaderView_Lens.addSubview(commentSectionLabel_Lens)
        commentHeaderView_Lens.addSubview(commentCountBadge_Lens)
        contentContainer_Lens.addSubview(commentsContainer_Lens)

        // 底部评论输入栏
        view.addSubview(commentInputBar_Lens)
        commentInputBar_Lens.addSubview(commentBarBlur_Lens)
        commentInputBar_Lens.addSubview(commentTopDivider_Lens)
        commentInputBar_Lens.addSubview(inputCapsuleView_Lens)
        inputCapsuleView_Lens.addSubview(inputIconView_Lens)
        inputCapsuleView_Lens.addSubview(commentTextField_Lens)
        commentInputBar_Lens.addSubview(sendBgView_Lens)
        sendBgView_Lens.layer.insertSublayer(sendGradientLayer_Lens, at: 0)
        sendBgView_Lens.addSubview(sendIconView_Lens)
        commentInputBar_Lens.addSubview(sendButton_Lens)
        commentBarBlur_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        let authorTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleAuthorTap_Lens))
        authorRow_Lens.addGestureRecognizer(authorTap_Lens)

        let mediaTap_Lens = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Lens))
        mediaDisplayView_Lens.addGestureRecognizer(mediaTap_Lens)

        let bgTap_Lens = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Lens))
        bgTap_Lens.cancelsTouchesInView = false
        scrollView_Lens.addGestureRecognizer(bgTap_Lens)
    }

    /// 构建背景多层径向光晕
    private func setupBackgroundGlows_Lens() {
        let purple_Lens = CAGradientLayer()
        purple_Lens.type = .radial
        purple_Lens.colors = [
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.22).cgColor,
            UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0).cgColor
        ]
        purple_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        purple_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        purple_Lens.frame = CGRect(x: -60, y: -40, width: 280, height: 280)
        backgroundGlowView_Lens.layer.addSublayer(purple_Lens)

        let blue_Lens = CAGradientLayer()
        blue_Lens.type = .radial
        blue_Lens.colors = [
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0.15).cgColor,
            UIColor(hexstring_Lens: "#2D5BE3", alpha_Lens: 0).cgColor
        ]
        blue_Lens.startPoint = CGPoint(x: 0.5, y: 0.5)
        blue_Lens.endPoint = CGPoint(x: 1.0, y: 1.0)
        let sw_Lens = UIScreen.main.bounds.width
        blue_Lens.frame = CGRect(x: sw_Lens - 80, y: 60, width: 220, height: 220)
        backgroundGlowView_Lens.layer.addSublayer(blue_Lens)
    }

    /// 构建作者头像彩虹光圈
    private func setupAuthorRingGradient_Lens() {
        let gradient_Lens = CAGradientLayer()
        gradient_Lens.colors = [
            UIColor(hexstring_Lens: "#C77DFF").cgColor,
            UIColor(hexstring_Lens: "#4D96FF").cgColor,
            UIColor(hexstring_Lens: "#6BCB77").cgColor,
            UIColor(hexstring_Lens: "#FFD93D").cgColor,
            UIColor(hexstring_Lens: "#7B2FF7").cgColor
        ]
        gradient_Lens.startPoint = CGPoint(x: 0, y: 0)
        gradient_Lens.endPoint = CGPoint(x: 1, y: 1)
        gradient_Lens.cornerRadius = 22
        gradient_Lens.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        authorRingView_Lens.layer.insertSublayer(gradient_Lens, at: 0)
    }

    // MARK: - 约束

    /// 设置 SnapKit 布局约束
    private func setupConstraints_Lens() {
        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(14)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }

        commentInputBar_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(76)
            commentBarBottomConstraint_Lens = $0.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        commentTopDivider_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        sendBgView_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(52)
        }
        sendIconView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        sendButton_Lens.snp.makeConstraints {
            $0.edges.equalTo(sendBgView_Lens)
        }
        inputCapsuleView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(sendBgView_Lens.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(52)
        }
        inputIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        commentTextField_Lens.snp.makeConstraints {
            $0.leading.equalTo(inputIconView_Lens.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(44)
        }

        scrollView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(commentInputBar_Lens.snp.top).offset(-8)
        }
        contentContainer_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(view)
        }

        authorCardView_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        authorRow_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
            $0.height.equalTo(44)
        }
        authorRingView_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        authorAvatar_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(2)
        }
        authorNameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(authorRingView_Lens).offset(2)
            $0.leading.equalTo(authorRingView_Lens.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(authorChevron_Lens.snp.leading).offset(-8)
        }
        authorHintLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(authorNameLabel_Lens.snp.bottom).offset(2)
            $0.leading.equalTo(authorNameLabel_Lens)
        }
        authorChevron_Lens.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }

        postCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(authorCardView_Lens.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        postTitleLabel_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(16)
        }
        postContentLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(postTitleLabel_Lens.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }

        mediaCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(postCardView_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            mediaHeightConstraint_Lens = $0.height.equalTo(240).constraint
        }
        mediaDisplayView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaGradientOverlay_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }

        actionCardView_Lens.snp.makeConstraints {
            $0.top.equalTo(mediaCardView_Lens.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
        likeChipView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }
        likeButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        likeCountLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(likeButton_Lens.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
        commentChipView_Lens.snp.makeConstraints {
            $0.leading.equalTo(likeChipView_Lens.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }
        commentIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        commentCountLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(commentIconView_Lens.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }

        commentHeaderView_Lens.snp.makeConstraints {
            $0.top.equalTo(actionCardView_Lens.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        commentAccentBar_Lens.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalTo(3)
            $0.height.equalTo(14)
        }
        commentSectionLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(commentAccentBar_Lens.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
        commentCountBadge_Lens.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        commentsContainer_Lens.snp.makeConstraints {
            $0.top.equalTo(commentHeaderView_Lens.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - 事件绑定与通知

    /// 绑定按钮事件和键盘通知
    private func bindActions_Lens() {
        backButton_Lens.addTarget(self, action: #selector(handleBack_Lens), for: .touchUpInside)
        likeButton_Lens.addTarget(self, action: #selector(handleLike_Lens), for: .touchUpInside)
        sendButton_Lens.addTarget(self, action: #selector(handleSendComment_Lens), for: .touchUpInside)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Lens(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Lens(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    /// 监听帖子状态变化通知
    private func bindNotifications_Lens() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleStateChanged_Lens),
            name: TitleViewModel_Lens.titleStateDidChangeNotification_Lens,
            object: nil
        )
    }

    // MARK: - 数据渲染

    /// 渲染帖子完整数据到界面（首次加载和通知刷新均调用）
    private func renderPostData_Lens() {
        guard let post_Lens = titleModel_Lens else { return }

        // 作者信息
        authorAvatar_Lens.configure_Lens(userId_Lens: post_Lens.titleUserId_Lens)
        authorNameLabel_Lens.text = post_Lens.titleUserName_Lens

        // 帖子内容
        postTitleLabel_Lens.text = post_Lens.title_Lens
        postContentLabel_Lens.text = post_Lens.titleContent_Lens

        // 媒体（仅取第一个）
        let mediaPath_Lens = post_Lens.titleMeidas_Lens.first
        if let path_Lens = mediaPath_Lens, !path_Lens.isEmpty {
            mediaCardView_Lens.isHidden = false
            mediaHeightConstraint_Lens?.update(offset: 240)
            let isVideo_Lens = isVideoPath_Lens(path_Lens)
            mediaDisplayView_Lens.configure_Lens(mediaPath_Lens: path_Lens, isVideo_Lens: isVideo_Lens)
        } else {
            mediaCardView_Lens.isHidden = true
            mediaHeightConstraint_Lens?.update(offset: 0)
        }

        // 点赞状态
        let isLiked_Lens = TitleViewModel_Lens.shared_Lens.isLikedPost_Lens(post_lens: post_Lens)
        likeButton_Lens.tintColor = isLiked_Lens
            ? UIColor(hexstring_Lens: "#FF6B6B")
            : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        likeCountLabel_Lens.text = "\(post_Lens.likes_Lens)"
        commentCountLabel_Lens.text = "\(post_Lens.reviews_Lens.count)"
        commentCountBadge_Lens.text = "\(post_Lens.reviews_Lens.count) total"

        // 举报/删除按钮
        refreshPostReportButton_Lens(post_Lens: post_Lens)

        // 评论列表
        renderComments_Lens(post_Lens: post_Lens)
    }

    /// 创建/更新帖子举报删除按钮（放置在导航栏右侧）
    private func refreshPostReportButton_Lens(post_Lens: TitleModel_Lens) {
        postReportButton_Lens?.removeFromSuperview()
        let btn_Lens = ReportDeleteHelper_Lens.createPostReportButton_Lens(
            post_Lens: post_Lens,
            size_Lens: 16,
            color_Lens: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.7),
            from: self
        ) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                Navigation_Lens.pop_Lens(from: self)
            }
        }
        navBar_Lens.addSubview(btn_Lens)
        btn_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(backButton_Lens)
            $0.width.height.equalTo(36)
        }
        postReportButton_Lens = btn_Lens
    }

    /// 渲染评论列表（清除旧视图后重新构建）
    private func renderComments_Lens(post_Lens: TitleModel_Lens) {
        commentsContainer_Lens.subviews.forEach { $0.removeFromSuperview() }

        // 过滤被举报用户的评论
        let visibleComments_Lens = post_Lens.reviews_Lens.filter { shouldShowComment_Lens(comment_Lens: $0) }

        if visibleComments_Lens.isEmpty {
            buildEmptyCommentView_Lens()
            return
        }

        var prevView_Lens: UIView? = nil
        for comment_Lens in visibleComments_Lens {
            let rowView_Lens = buildCommentRowView_Lens(comment_Lens: comment_Lens, post_Lens: post_Lens)
            commentsContainer_Lens.addSubview(rowView_Lens)
            rowView_Lens.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(16)
                if let prev_Lens = prevView_Lens {
                    $0.top.equalTo(prev_Lens.snp.bottom).offset(10)
                } else {
                    $0.top.equalToSuperview()
                }
            }
            prevView_Lens = rowView_Lens
        }
        prevView_Lens?.snp.makeConstraints { $0.bottom.equalToSuperview() }
    }

    /// 判断该评论是否应显示（当前用户的评论始终显示，被举报用户的评论隐藏）
    /// - Parameter comment_Lens: 评论数据
    /// - Returns: true 显示，false 隐藏
    private func shouldShowComment_Lens(comment_Lens: Comment_Lens) -> Bool {
        // 当前登录用户自己的评论始终显示
        if UserViewModel_Lens.shared_Lens.isCurrentUser_Lens(userId_lens: comment_Lens.commentUserId_Lens) {
            return true
        }
        // 若该用户已从 userList 中移除（被举报），则隐藏其评论
        let userExists_Lens = LocalData_Lens.shared_Lens.userList_Lens.contains {
            $0.userId_Lens == comment_Lens.commentUserId_Lens
        }
        return userExists_Lens
    }

    /// 构建单条评论行视图
    /// - Parameters:
    ///   - comment_Lens: 评论数据
    ///   - post_Lens: 所属帖子（举报/删除操作需要）
    /// - Returns: 配置好的评论行 UIView
    private func buildCommentRowView_Lens(comment_Lens: Comment_Lens, post_Lens: TitleModel_Lens) -> UIView {
        let container_Lens = UIView()
        container_Lens.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        container_Lens.layer.cornerRadius = 14
        container_Lens.layer.borderWidth = 1
        container_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.05).cgColor

        let avatar_Lens = UserAvatarView_Lens()
        avatar_Lens.layer.cornerRadius = 16
        avatar_Lens.clipsToBounds = true

        let nameLabel_Lens = UILabel()
        nameLabel_Lens.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLabel_Lens.textColor = .white
        nameLabel_Lens.text = comment_Lens.commentUserName_Lens

        let contentLabel_Lens = UILabel()
        contentLabel_Lens.font = .systemFont(ofSize: 14)
        contentLabel_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.72)
        contentLabel_Lens.numberOfLines = 0
        contentLabel_Lens.text = comment_Lens.commentContent_Lens

        let reportBtn_Lens = ReportDeleteHelper_Lens.createCommentReportButton_Lens(
            comment_Lens: comment_Lens,
            post_Lens: post_Lens,
            size_Lens: 14,
            color_Lens: UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35),
            from: self
        )

        container_Lens.addSubview(avatar_Lens)
        container_Lens.addSubview(nameLabel_Lens)
        container_Lens.addSubview(contentLabel_Lens)
        container_Lens.addSubview(reportBtn_Lens)
        avatar_Lens.configure_Lens(userId_Lens: comment_Lens.commentUserId_Lens)

        avatar_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(14)
            $0.width.height.equalTo(32)
        }
        nameLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(avatar_Lens)
            $0.leading.equalTo(avatar_Lens.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualTo(reportBtn_Lens.snp.leading).offset(-4)
        }
        contentLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Lens.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel_Lens)
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(14)
        }
        reportBtn_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(26)
        }
        return container_Lens
    }

    /// 构建无评论时的占位视图
    private func buildEmptyCommentView_Lens() {
        let wrap_Lens = UIView()
        wrap_Lens.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        wrap_Lens.layer.cornerRadius = 14
        wrap_Lens.layer.borderWidth = 1
        wrap_Lens.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.05).cgColor

        let icon_Lens = UIImageView(image: UIImage(systemName: "text.bubble"))
        icon_Lens.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.2)
        icon_Lens.contentMode = .scaleAspectFit

        let label_Lens = UILabel()
        label_Lens.text = "No comments yet. Be the first!"
        label_Lens.font = .systemFont(ofSize: 13)
        label_Lens.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        label_Lens.textAlignment = .center

        wrap_Lens.addSubview(icon_Lens)
        wrap_Lens.addSubview(label_Lens)
        commentsContainer_Lens.addSubview(wrap_Lens)

        wrap_Lens.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        icon_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(36)
        }
        label_Lens.snp.makeConstraints {
            $0.top.equalTo(icon_Lens.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
    }

    // MARK: - 事件响应

    @objc private func handleBack_Lens() {
        Navigation_Lens.pop_Lens(from: self)
    }

    /// 点击作者头像或昵称 → 跳转个人中心
    @objc private func handleAuthorTap_Lens() {
        guard let post_Lens = titleModel_Lens else { return }
        let user_Lens = UserViewModel_Lens.shared_Lens.getUserById_Lens(userId_lens: post_Lens.titleUserId_Lens)
        Navigation_Lens.toUserInfo_Lens(with: user_Lens)
    }

    /// 点击媒体区域 → 全屏浏览
    @objc private func handleMediaTap_Lens() {
        guard let post_Lens = titleModel_Lens,
              let mediaPath_Lens = post_Lens.titleMeidas_Lens.first,
              !mediaPath_Lens.isEmpty else { return }
        let player_Lens = MediaPlayerPage_Lens()
        player_Lens.mediaPath_Lens = mediaPath_Lens
        player_Lens.isVideo_Lens = isVideoPath_Lens(mediaPath_Lens)
        player_Lens.modalPresentationStyle = .fullScreen
        present(player_Lens, animated: true)
    }

    /// 点击点赞按钮
    @objc private func handleLike_Lens() {
        guard let post_Lens = titleModel_Lens else { return }
        TitleViewModel_Lens.shared_Lens.likePost_Lens(post_lens: post_Lens)
    }

    /// 点击发送评论
    @objc private func handleSendComment_Lens() {
        guard let post_Lens = titleModel_Lens else { return }
        let text_Lens = commentTextField_Lens.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_Lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please write something first.")
            return
        }
        TitleViewModel_Lens.shared_Lens.releaseComment_Lens(post_lens: post_Lens, content_lens: text_Lens)
        commentTextField_Lens.text = nil
        view.endEditing(true)
    }

    /// 帖子状态通知回调：从 ViewModel 重新拉取最新帖子数据并刷新
    @objc private func onTitleStateChanged_Lens() {
        guard let currentPost_Lens = titleModel_Lens else { return }
        if let updated_Lens = TitleViewModel_Lens.shared_Lens.getPosts_Lens().first(where: {
            $0.titleId_Lens == currentPost_Lens.titleId_Lens
        }) {
            titleModel_Lens = updated_Lens
            renderPostData_Lens()
        } else {
            // 帖子已被删除，返回上一页
            Navigation_Lens.pop_Lens(from: self)
        }
    }

    @objc private func dismissKeyboard_Lens() {
        view.endEditing(true)
    }

    /// 键盘弹出：评论输入栏联动上移
    @objc private func keyboardWillShow_Lens(_ notification: Notification) {
        guard let userInfo_Lens = notification.userInfo,
              let frame_Lens = userInfo_Lens[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Lens = userInfo_Lens[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_Lens) {
            self.commentBarBottomConstraint_Lens?.update(offset: self.view.safeAreaInsets.bottom - frame_Lens.height)
            self.view.layoutIfNeeded()
        }
    }

    /// 键盘收起：评论输入栏恢复原位
    @objc private func keyboardWillHide_Lens(_ notification: Notification) {
        guard let userInfo_Lens = notification.userInfo,
              let duration_Lens = userInfo_Lens[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_Lens) {
            self.commentBarBottomConstraint_Lens?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 辅助方法

    /// 根据路径扩展名判断是否为视频文件
    /// - Parameter path_Lens: 文件路径
    /// - Returns: true 为视频，false 为图片
    private func isVideoPath_Lens(_ path_Lens: String) -> Bool {
        let ext_Lens = (path_Lens as NSString).pathExtension.lowercased()
        return ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens)
    }
}
