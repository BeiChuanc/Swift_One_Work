
import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页面

/// 帖子详情控制器
/// 核心作用：展示单个帖子的媒体、作者信息、完整内容、互动统计和评论列表。
/// 设计思路：页面顶部为全屏媒体英雄区（带渐变蒙版），下方为作者行、内容卡、互动区、评论区；
///          通过 `TitleViewModel_Posture` 通知自动响应帖子变化（删除/点赞/评论）。
/// 关键属性：`titleModel_Posture` 为外部传入帖子，`likeButton_Posture` 响应式更新点赞态。
/// 关键方法：`renderPost_Posture()` 渲染全页，`sendComment_Posture()` 发送评论。
@MainActor
class Detail_Posture: UIViewController {

    // MARK: - 外部传入

    var titleModel_Posture: TitleModel_Posture?

    // MARK: - 存储属性（在 renderPost_Posture 中更新）

    private let mediaView_Posture    = MediaDisplayView_Posture()
    private let avatarView_Posture   = UserAvatarView_Posture()
    private let authorLabel_Posture  = UILabel()
    private let titleLabel_Posture   = UILabel()
    private let bodyLabel_Posture    = UILabel()
    private let categoryChip_Posture = UILabel()
    private let likeButton_Posture   = UIButton(type: .system)
    private let likeCountLabel_Posture  = UILabel()
    private let commentCountLabel_Posture = UILabel()
    private let commentsStackView_Posture = UIStackView()
    private let commentField_Posture = UITextField()
    private var reportButton_Posture: UIButton?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        renderPost_Posture()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Posture()
        observePostState_Posture()
        renderPost_Posture()

        let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Posture))
        tap_Posture.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Posture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建详情页主体 UI
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        setupBackgroundGlows_Posture()

        // 滚动容器
        let scrollView_Posture = UIScrollView()
        scrollView_Posture.showsVerticalScrollIndicator = false
        scrollView_Posture.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_Posture)

        let contentView_Posture = UIView()
        scrollView_Posture.addSubview(contentView_Posture)
        scrollView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 评论输入栏（固定在底部，z-order 高）
        let commentBar_Posture = buildCommentInputBar_Posture()
        view.addSubview(commentBar_Posture)
        commentBar_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(58)
        }

        // 各区块
        let heroSection_Posture    = buildHeroMediaSection_Posture()
        let authorRow_Posture      = buildAuthorRow_Posture()
        let contentCard_Posture    = buildContentCard_Posture()
        let interactionBar_Posture = buildInteractionBar_Posture()
        let commentsSection_Posture = buildCommentsSection_Posture()

        // 用栈统一管理内容
        let contentStack_Posture = UIStackView()
        contentStack_Posture.axis = .vertical
        contentStack_Posture.spacing = 0

        contentView_Posture.addSubview(heroSection_Posture)
        contentView_Posture.addSubview(contentStack_Posture)

        heroSection_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        contentStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(heroSection_Posture.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-130)
        }

        contentStack_Posture.addArrangedSubview(authorRow_Posture)
        contentStack_Posture.setCustomSpacing(16, after: authorRow_Posture)
        contentStack_Posture.addArrangedSubview(contentCard_Posture)
        contentStack_Posture.setCustomSpacing(16, after: contentCard_Posture)
        contentStack_Posture.addArrangedSubview(interactionBar_Posture)
        contentStack_Posture.setCustomSpacing(22, after: interactionBar_Posture)
        contentStack_Posture.addArrangedSubview(commentsSection_Posture)

        // 悬浮返回按钮
        let backButton_Posture = UIButton(type: .system)
        backButton_Posture.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton_Posture.tintColor = .white
        backButton_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        backButton_Posture.layer.cornerRadius = 22
        backButton_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)
        view.addSubview(backButton_Posture)
        backButton_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }
    }

    // MARK: - 区块构建

    /// 搭建背景光晕
    private func setupBackgroundGlows_Posture() {
        [
            (ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.12), CGFloat(160), false, -50.0, 500.0),
            (ColorConfig_Posture.accentMint_Posture.withAlphaComponent(0.10),           CGFloat(130), true,   44.0, 700.0),
        ].forEach { cfg_Posture in
            let b_Posture = UIView()
            b_Posture.backgroundColor = cfg_Posture.0
            b_Posture.layer.cornerRadius = cfg_Posture.1 / 2
            b_Posture.isUserInteractionEnabled = false
            view.insertSubview(b_Posture, at: 0)
            b_Posture.snp.makeConstraints { make in
                if cfg_Posture.2 { make.trailing.equalToSuperview().offset(cfg_Posture.3)
                } else { make.leading.equalToSuperview().offset(cfg_Posture.3) }
                make.top.equalToSuperview().offset(cfg_Posture.4)
                make.width.height.equalTo(cfg_Posture.1)
            }
        }
    }

    /// 构建英雄媒体区（全屏媒体 + 底部渐变蒙版 + 举报按钮）
    /// - Parameters: 无
    /// - Returns: UIView - 英雄媒体区
    /// - Throws: 无
    private func buildHeroMediaSection_Posture() -> UIView {
        let container_Posture = UIView()

        mediaView_Posture.layer.cornerRadius = 0
        mediaView_Posture.clipsToBounds = true
        container_Posture.addSubview(mediaView_Posture)

        // 底部渐变蒙版
        let gradientMask_Posture = UIView()
        gradientMask_Posture.isUserInteractionEnabled = false
        container_Posture.addSubview(gradientMask_Posture)

        let maskGrad_Posture = CAGradientLayer()
        maskGrad_Posture.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        maskGrad_Posture.startPoint = CGPoint(x: 0.5, y: 0)
        maskGrad_Posture.endPoint   = CGPoint(x: 0.5, y: 1)
        gradientMask_Posture.layer.insertSublayer(maskGrad_Posture, at: 0)

        container_Posture.snp.makeConstraints { make in
            make.height.equalTo(UIScreen.main.bounds.width * 0.88)
        }

        mediaView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        gradientMask_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        DispatchQueue.main.async {
            maskGrad_Posture.frame = gradientMask_Posture.bounds
        }

        return container_Posture
    }

    /// 构建作者信息行（头像 + 名称 + 分类标签 + 点击跳转）
    /// - Parameters: 无
    /// - Returns: UIView - 作者行容器
    /// - Throws: 无
    private func buildAuthorRow_Posture() -> UIView {
        let wrapper_Posture = UIView()

        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 28
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 14
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 8)

        // 头像环
        let ringView_Posture = UIView()
        ringView_Posture.backgroundColor = ColorConfig_Posture.primaryGradientStart_Posture.withAlphaComponent(0.18)
        ringView_Posture.layer.cornerRadius = 26
        ringView_Posture.layer.borderWidth  = 2
        ringView_Posture.layer.borderColor  = ColorConfig_Posture.primaryGradientStart_Posture.cgColor
        ringView_Posture.addSubview(avatarView_Posture)
        avatarView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(42)
        }

        authorLabel_Posture.font = .systemFont(ofSize: 16, weight: .bold)
        authorLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 分类标签
        categoryChip_Posture.font = .systemFont(ofSize: 10, weight: .heavy)
        categoryChip_Posture.textAlignment = .center
        categoryChip_Posture.layer.cornerRadius = 11
        categoryChip_Posture.clipsToBounds = true

        // 作者副标题
        let subLabel_Posture = UILabel()
        subLabel_Posture.text = "Posture Contributor"
        subLabel_Posture.font = .systemFont(ofSize: 12, weight: .medium)
        subLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        // 右箭头
        let arrowView_Posture = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowView_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        arrowView_Posture.contentMode = .scaleAspectFit

        card_Posture.addSubview(ringView_Posture)
        card_Posture.addSubview(authorLabel_Posture)
        card_Posture.addSubview(subLabel_Posture)
        card_Posture.addSubview(categoryChip_Posture)
        card_Posture.addSubview(arrowView_Posture)

        ringView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
        authorLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(ringView_Posture.snp.trailing).offset(12)
            make.trailing.equalTo(arrowView_Posture.snp.leading).offset(-8)
        }
        subLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(authorLabel_Posture.snp.bottom).offset(4)
            make.leading.equalTo(authorLabel_Posture)
        }
        categoryChip_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(subLabel_Posture)
            make.leading.equalTo(subLabel_Posture.snp.trailing).offset(8)
            make.height.equalTo(22)
            make.width.greaterThanOrEqualTo(56)
        }
        arrowView_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
            make.width.equalTo(8)
            make.height.equalTo(14)
        }
        card_Posture.snp.makeConstraints { make in
            make.height.equalTo(86)
        }

        // 点击作者行跳转用户中心
        card_Posture.isUserInteractionEnabled = true
        card_Posture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAuthor_Posture)))

        wrapper_Posture.addSubview(card_Posture)
        card_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
        }

        return wrapper_Posture
    }

    /// 构建帖子内容卡片（标题 + 正文）
    /// - Parameters: 无
    /// - Returns: UIView - 内容卡片容器
    /// - Throws: 无
    private func buildContentCard_Posture() -> UIView {
        let wrapper_Posture = UIView()
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 30
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 16
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 10)

        // 顶部装饰渐变色条
        let stripe_Posture = UIView()
        stripe_Posture.layer.cornerRadius = 30
        stripe_Posture.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        stripe_Posture.clipsToBounds = true
        let stripeGrad_Posture = CAGradientLayer()
        stripeGrad_Posture.colors = [
            ColorConfig_Posture.primaryGradientStart_Posture.cgColor,
            ColorConfig_Posture.primaryGradientEnd_Posture.cgColor
        ]
        stripeGrad_Posture.startPoint = CGPoint(x: 0, y: 0)
        stripeGrad_Posture.endPoint   = CGPoint(x: 1, y: 0)
        stripe_Posture.layer.insertSublayer(stripeGrad_Posture, at: 0)

        titleLabel_Posture.font = .systemFont(ofSize: 26, weight: .heavy)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 0

        // 分割线
        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture

        bodyLabel_Posture.font = .systemFont(ofSize: 16, weight: .regular)
        bodyLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        bodyLabel_Posture.numberOfLines = 0
        bodyLabel_Posture.lineBreakMode = .byWordWrapping

        card_Posture.addSubview(stripe_Posture)
        card_Posture.addSubview(titleLabel_Posture)
        card_Posture.addSubview(divider_Posture)
        card_Posture.addSubview(bodyLabel_Posture)

        stripe_Posture.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(stripe_Posture.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        divider_Posture.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Posture.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        bodyLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(divider_Posture.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }

        wrapper_Posture.addSubview(card_Posture)
        card_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
        }

        DispatchQueue.main.async {
            stripeGrad_Posture.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 36, height: 6)
        }

        return wrapper_Posture
    }

    /// 构建互动区（点赞按钮 + 数量芯片）
    /// - Parameters: 无
    /// - Returns: UIView - 互动区容器
    /// - Throws: 无
    private func buildInteractionBar_Posture() -> UIView {
        let wrapper_Posture = UIView()
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 26
        card_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius  = 12
        card_Posture.layer.shadowOffset  = CGSize(width: 0, height: 6)

        // 大号点赞按钮
        likeButton_Posture.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton_Posture.tintColor = ColorConfig_Posture.secondaryGradientStart_Posture
        likeButton_Posture.backgroundColor = ColorConfig_Posture.secondaryLight_Posture
        likeButton_Posture.layer.cornerRadius = 24
        likeButton_Posture.addAction(UIAction { [weak self] _ in self?.handleLikeTap_Posture() }, for: .touchUpInside)

        // 点赞数芯片
        likeCountLabel_Posture.font  = .systemFont(ofSize: 22, weight: .heavy)
        likeCountLabel_Posture.textColor = ColorConfig_Posture.secondaryGradientStart_Posture

        let likeCaption_Posture = UILabel()
        likeCaption_Posture.text = "Likes"
        likeCaption_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        likeCaption_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        let likeStat_Posture = makeStatColumn_Posture(countLabel: likeCountLabel_Posture, caption: likeCaption_Posture)

        // 评论数芯片
        commentCountLabel_Posture.font  = .systemFont(ofSize: 22, weight: .heavy)
        commentCountLabel_Posture.textColor = ColorConfig_Posture.accentIndigo_Posture

        let commentCaption_Posture = UILabel()
        commentCaption_Posture.text = "Comments"
        commentCaption_Posture.font = .systemFont(ofSize: 11, weight: .semibold)
        commentCaption_Posture.textColor = ColorConfig_Posture.textSecondary_Posture

        let commentStat_Posture = makeStatColumn_Posture(countLabel: commentCountLabel_Posture, caption: commentCaption_Posture)

        let divider_Posture = UIView()
        divider_Posture.backgroundColor = ColorConfig_Posture.divider_Posture

        card_Posture.addSubview(likeButton_Posture)
        card_Posture.addSubview(likeStat_Posture)
        card_Posture.addSubview(divider_Posture)
        card_Posture.addSubview(commentStat_Posture)

        likeButton_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        likeStat_Posture.snp.makeConstraints { make in
            make.leading.equalTo(likeButton_Posture.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
        }
        divider_Posture.snp.makeConstraints { make in
            make.leading.equalTo(likeStat_Posture.snp.trailing).offset(22)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(32)
        }
        commentStat_Posture.snp.makeConstraints { make in
            make.leading.equalTo(divider_Posture.snp.trailing).offset(22)
            make.centerY.equalToSuperview()
        }
        card_Posture.snp.makeConstraints { make in
            make.height.equalTo(78)
        }

        wrapper_Posture.addSubview(card_Posture)
        card_Posture.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(18)
        }

        return wrapper_Posture
    }

    /// 创建统计列（数值 + 说明）
    private func makeStatColumn_Posture(countLabel: UILabel, caption: UILabel) -> UIView {
        let v_Posture = UIView()
        v_Posture.addSubview(countLabel)
        v_Posture.addSubview(caption)
        countLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        caption.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return v_Posture
    }

    /// 构建评论区（标题 + 评论列表）
    /// - Parameters: 无
    /// - Returns: UIView - 评论区容器
    /// - Throws: 无
    private func buildCommentsSection_Posture() -> UIView {
        let wrapper_Posture = UIView()

        // 分区标题
        let dot_Posture = UIView()
        dot_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture
        dot_Posture.layer.cornerRadius = 5

        let headerLabel_Posture = UILabel()
        headerLabel_Posture.text = "Community Notes"
        headerLabel_Posture.font = .systemFont(ofSize: 20, weight: .heavy)
        headerLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        commentsStackView_Posture.axis = .vertical
        commentsStackView_Posture.spacing = 12

        wrapper_Posture.addSubview(dot_Posture)
        wrapper_Posture.addSubview(headerLabel_Posture)
        wrapper_Posture.addSubview(commentsStackView_Posture)

        dot_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(2)
            make.width.height.equalTo(10)
        }
        headerLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(dot_Posture)
            make.leading.equalTo(dot_Posture.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(18)
        }
        commentsStackView_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview()
        }

        return wrapper_Posture
    }

    /// 构建底部评论输入栏
    /// - Parameters: 无
    /// - Returns: UIView - 评论输入栏
    /// - Throws: 无
    private func buildCommentInputBar_Posture() -> UIView {
        let bar_Posture = UIView()
        bar_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        bar_Posture.layer.cornerRadius = 24
        bar_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        bar_Posture.layer.shadowOpacity = 1
        bar_Posture.layer.shadowRadius  = 14
        bar_Posture.layer.shadowOffset  = CGSize(width: 0, height: -6)

        commentField_Posture.placeholder = "Share your thoughts..."
        commentField_Posture.font = .systemFont(ofSize: 14, weight: .medium)

        let sendButton_Posture = UIButton(type: .system)
        sendButton_Posture.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton_Posture.tintColor = .white
        sendButton_Posture.backgroundColor = ColorConfig_Posture.accentIndigo_Posture
        sendButton_Posture.layer.cornerRadius = 18
        sendButton_Posture.addAction(UIAction { [weak self] _ in self?.sendComment_Posture() }, for: .touchUpInside)

        let iconView_Posture = UIImageView(image: UIImage(systemName: "pencil.and.outline"))
        iconView_Posture.tintColor = ColorConfig_Posture.textPlaceholder_Posture
        iconView_Posture.contentMode = .scaleAspectFit

        bar_Posture.addSubview(iconView_Posture)
        bar_Posture.addSubview(commentField_Posture)
        bar_Posture.addSubview(sendButton_Posture)

        iconView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        commentField_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconView_Posture.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(sendButton_Posture.snp.leading).offset(-10)
        }
        sendButton_Posture.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(36)
        }

        return bar_Posture
    }

    // MARK: - 数据刷新

    /// 监听帖子状态变化
    private func observePostState_Posture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostStateChange_Posture),
            name: TitleViewModel_Posture.titleStateDidChangeNotification_Posture,
            object: nil
        )
    }

    /// 响应帖子状态变化
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    @objc private func handlePostStateChange_Posture() {
        guard let currentPost_Posture = titleModel_Posture else { return }
        let posts_Posture = TitleViewModel_Posture.shared_Posture.getPosts_Posture()
        guard let refreshedPost_Posture = posts_Posture.first(where: { $0.titleId_Posture == currentPost_Posture.titleId_Posture }) else {
            Navigation_Posture.pop_Posture()
            return
        }
        titleModel_Posture = refreshedPost_Posture
        renderPost_Posture()
    }

    /// 渲染帖子详情全页
    /// - Parameters: 无
    /// - Returns: Void
    /// - Throws: 无
    private func renderPost_Posture() {
        guard let post_Posture = titleModel_Posture, isViewLoaded else { return }

        // 媒体
        mediaView_Posture.configure_Posture(mediaPath_Posture: post_Posture.titleMeidas_Posture.first)

        // 作者
        avatarView_Posture.configure_Posture(userId_Posture: post_Posture.titleUserId_Posture)
        authorLabel_Posture.text = post_Posture.titleUserName_Posture

        // 分类标签
        let tag_Posture = categoryTag_Posture(for: post_Posture)
        let tagColors_Posture = ColorConfig_Posture.tagColors_Posture(for: tag_Posture)
        categoryChip_Posture.text = "  \(tag_Posture)  "
        categoryChip_Posture.backgroundColor = tagColors_Posture.bg
        categoryChip_Posture.textColor = tagColors_Posture.text

        // 内容
        titleLabel_Posture.text = post_Posture.title_Posture
        bodyLabel_Posture.text  = post_Posture.titleContent_Posture

        // 互动统计
        likeCountLabel_Posture.text    = "\(post_Posture.likes_Posture)"
        commentCountLabel_Posture.text = "\(post_Posture.reviews_Posture.count)"

        // 点赞状态
        let liked_Posture = TitleViewModel_Posture.shared_Posture.isLikedPost_Posture(post_posture: post_Posture)
        likeButton_Posture.setImage(UIImage(systemName: liked_Posture ? "heart.fill" : "heart"), for: .normal)
        likeButton_Posture.backgroundColor = liked_Posture
            ? ColorConfig_Posture.secondaryGradientStart_Posture
            : ColorConfig_Posture.secondaryLight_Posture
        likeButton_Posture.tintColor = liked_Posture ? .white : ColorConfig_Posture.secondaryGradientStart_Posture

        // 举报/删除按钮
        reportButton_Posture?.removeFromSuperview()
        let btn_Posture = ReportDeleteHelper_Posture.createPostReportButton_Posture(
            post_Posture: post_Posture, size_Posture: 18,
            color_Posture: .white, from: self
        )
        btn_Posture.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        btn_Posture.layer.cornerRadius = 22
        view.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().inset(18)
            make.width.height.equalTo(44)
        }
        reportButton_Posture = btn_Posture

        renderComments_Posture(post_posture: post_Posture)
    }

    /// 渲染评论列表
    /// - Parameter post_posture: 当前帖子
    /// - Returns: Void
    /// - Throws: 无
    private func renderComments_Posture(post_posture: TitleModel_Posture) {
        commentsStackView_Posture.arrangedSubviews.forEach { view_posture in
            commentsStackView_Posture.removeArrangedSubview(view_posture)
            view_posture.removeFromSuperview()
        }

        guard !post_posture.reviews_Posture.isEmpty else {
            commentsStackView_Posture.addArrangedSubview(createEmptyCommentView_Posture())
            return
        }

        post_posture.reviews_Posture.enumerated().forEach { index_Posture, comment_Posture in
            let commentView_Posture = DetailCommentView_Posture()
            commentView_Posture.configure_Posture(
                comment_posture: comment_Posture,
                post_posture: post_posture,
                index_posture: index_Posture,
                parentViewController_posture: self
            )
            commentsStackView_Posture.addArrangedSubview(commentView_Posture)
        }
    }

    /// 创建空评论状态视图
    /// - Parameters: 无
    /// - Returns: UIView - 空状态视图
    /// - Throws: 无
    private func createEmptyCommentView_Posture() -> UIView {
        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 22

        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = ColorConfig_Posture.accentIndigoLight_Posture
        iconBg_Posture.layer.cornerRadius = 28

        let icon_Posture = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        icon_Posture.tintColor = ColorConfig_Posture.accentIndigo_Posture
        icon_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(icon_Posture)
        icon_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        let label_Posture = UILabel()
        label_Posture.text = "Be the first to leave a note."
        label_Posture.font = .systemFont(ofSize: 14, weight: .semibold)
        label_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        label_Posture.textAlignment = .center

        card_Posture.addSubview(iconBg_Posture)
        card_Posture.addSubview(label_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        label_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
        card_Posture.snp.makeConstraints { make in make.height.equalTo(126) }

        return card_Posture
    }

    // MARK: - 辅助

    /// 根据帖子内容推断分类标签
    private func categoryTag_Posture(for post_Posture: TitleModel_Posture) -> String {
        let src_Posture = "\(post_Posture.title_Posture) \(post_Posture.titleContent_Posture)".lowercased()
        if src_Posture.contains("neck")  { return "NECK" }
        if src_Posture.contains("core")  { return "CORE" }
        if src_Posture.contains("desk")  { return "DESK" }
        if src_Posture.contains("walk")  { return "WALK" }
        if src_Posture.contains("back")  { return "BACK" }
        if src_Posture.contains("breath") { return "BREATH" }
        return "POSTURE"
    }

    // MARK: - 事件

    /// 点赞/取消点赞
    private func handleLikeTap_Posture() {
        guard let post_Posture = titleModel_Posture else { return }
        likeButton_Posture.animatePulse_Posture()
        TitleViewModel_Posture.shared_Posture.likePost_Posture(post_posture: post_Posture)
    }

    /// 发送评论
    private func sendComment_Posture() {
        guard let post_Posture = titleModel_Posture else { return }
        let text_Posture = (commentField_Posture.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_Posture.isEmpty else { return }
        commentField_Posture.text = nil
        TitleViewModel_Posture.shared_Posture.releaseComment_Posture(post_posture: post_Posture, content_posture: text_Posture)
    }

    /// 点击作者跳转用户中心
    @objc private func tapAuthor_Posture() {
        guard let post_Posture = titleModel_Posture else { return }
        let user_Posture = UserViewModel_Posture.shared_Posture.getUserById_Posture(userId_posture: post_Posture.titleUserId_Posture)
        Navigation_Posture.toUserInfo_Posture(with: user_Posture)
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Posture() { view.endEditing(true) }
}

// MARK: - 评论项视图

/// 详情页评论项
/// 核心作用：展示单条评论，含头像、作者名、内容和举报/删除入口。
/// 设计思路：按 index 取调色盘颜色染色左条和阴影，使评论列表色彩层次丰富。
/// 关键属性：`stripeView_Posture` 为彩色左条，`avatarView_Posture` 展示评论者头像。
/// 关键方法：`configure_Posture(...)` 绑定评论数据与配色。
@MainActor
private class DetailCommentView_Posture: UIView {

    private let cardView_Posture      = UIView()
    private let stripeView_Posture    = UIView()
    private let avatarView_Posture    = UserAvatarView_Posture()
    private let nameLabel_Posture     = UILabel()
    private let contentLabel_Posture  = UILabel()
    private var reportButton_Posture: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI_Posture() {
        addSubview(cardView_Posture)
        cardView_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        cardView_Posture.layer.cornerRadius = 24
        cardView_Posture.layer.shadowColor  = ColorConfig_Posture.shadowColor_Posture.cgColor
        cardView_Posture.layer.shadowOpacity = 1
        cardView_Posture.layer.shadowRadius  = 10
        cardView_Posture.layer.shadowOffset  = CGSize(width: 0, height: 6)
        cardView_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }

        stripeView_Posture.layer.cornerRadius = 3
        cardView_Posture.addSubview(stripeView_Posture)

        avatarView_Posture.layer.cornerRadius = 18
        avatarView_Posture.clipsToBounds = true
        cardView_Posture.addSubview(avatarView_Posture)

        nameLabel_Posture.font = .systemFont(ofSize: 14, weight: .bold)
        nameLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        cardView_Posture.addSubview(nameLabel_Posture)

        contentLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        contentLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        contentLabel_Posture.numberOfLines = 0
        cardView_Posture.addSubview(contentLabel_Posture)

        stripeView_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.bottom.equalToSuperview().inset(14)
            make.width.equalTo(4)
        }
        avatarView_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(stripeView_Posture.snp.trailing).offset(12)
            make.width.height.equalTo(36)
        }
        nameLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Posture)
            make.leading.equalTo(avatarView_Posture.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(48)
        }
        contentLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Posture.snp.bottom).offset(10)
            make.leading.equalTo(avatarView_Posture)
            make.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    /// 绑定评论数据，按 index 取调色盘配色
    /// - Parameters:
    ///   - comment_posture: 评论模型
    ///   - post_posture: 所属帖子
    ///   - index_posture: 列表位置，决定颜色
    ///   - parentViewController_posture: 弹窗宿主页面
    /// - Returns: Void
    /// - Throws: 无
    func configure_Posture(comment_posture: Comment_Posture, post_posture: TitleModel_Posture, index_posture: Int, parentViewController_posture: UIViewController) {
        let palette_Posture = ColorConfig_Posture.cardAccentPalette_Posture[index_posture % ColorConfig_Posture.cardAccentPalette_Posture.count]
        stripeView_Posture.backgroundColor = palette_Posture.main
        cardView_Posture.layer.shadowColor = palette_Posture.shadow.cgColor

        avatarView_Posture.configure_Posture(userId_Posture: comment_posture.commentUserId_Posture)
        nameLabel_Posture.text    = comment_posture.commentUserName_Posture
        contentLabel_Posture.text = comment_posture.commentContent_Posture

        reportButton_Posture?.removeFromSuperview()
        let btn_Posture = ReportDeleteHelper_Posture.createCommentReportButton_Posture(
            comment_Posture: comment_posture, post_Posture: post_posture,
            size_Posture: 14, color_Posture: ColorConfig_Posture.textSecondary_Posture,
            from: parentViewController_posture
        )
        cardView_Posture.addSubview(btn_Posture)
        btn_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
        reportButton_Posture = btn_Posture
    }
}
