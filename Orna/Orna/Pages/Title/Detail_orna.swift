
import Foundation
import UIKit
import SnapKit

// MARK: 帖子展示详情页面

/// 帖子详情页面视图控制器
/// 核心作用：展示帖子完整内容、支持点赞、评论与全屏媒体浏览
/// 设计思路：
///   - 顶部媒体大图（复用 MediaDisplayView_Orna）沉浸式铺满至屏幕最顶部（延伸至状态栏之下），
///     消除背景色与图片之间的空隙；底部做圆角处理，并叠加渐变遮罩确保悬浮的返回/举报按钮清晰可辨；
///     状态栏样式随滚动位置在浅色（悬浮于图片上）与深色（滚动至白色内容卡片后）间动态切换；点击进入全屏浏览页
///   - 媒体下方衔接一张白色圆角"内容卡片"（顶部带装饰性把手条，呼应底部弹层的视觉语言），
///     承载作者行、标题正文、点赞/评论互动胶囊、分割线与评论区，与全 App 卡片化设计语言统一
///   - 作者行可点击进入对方用户中心（本人则进入"我的"），头像描边使用强调色呼应主题；
///     非本人帖子额外展示"关注"按钮，形成"查看详情 → 直接关注作者"的完整闭环
///   - 媒体图上点赞数达阈值时叠加"热门"徽标，呼应发现页视觉语言，强化高互动内容辨识度
///   - 点赞与评论数改为胶囊徽标样式：点赞态切换背板与文案配色，未点赞使用中性浅紫背板；
///     互动区与评论区之间以分割线 + 居中"摆件"圆徽装饰，呼应桌面摆件主题
///   - 评论列表每条均包裹在浅紫气泡背景中提升可读性，均带举报按钮，举报即删除；
///     已被举报/拉黑用户的评论自动隐藏；无评论时在同一列表容器内展示统一风格的缺省态
///   - 页面数据响应式：监听 TitleViewModel_Orna 状态变化自动刷新，帖子被删除后自动返回
///   - 底部固定输入栏发表新评论，输入框聚焦时描边变为强调色提供清晰反馈，
///     发送按钮采用品牌紫粉渐变 + Configuration 图标呼应全局强调色
/// 关键属性：
///   - titleModel_Orna: 当前展示的帖子模型
class Detail_Orna: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {

    /// 帖子模型
    var titleModel_Orna: TitleModel_Orna?

    // MARK: - UI · 顶部工具条（叠加在媒体上）

    private let mediaGradientOverlay_Orna: CAGradientLayer = {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor.black.withAlphaComponent(0.32).cgColor,
            UIColor.black.withAlphaComponent(0.0).cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0.5, y: 0)
        layer_orna.endPoint = CGPoint(x: 0.5, y: 1)
        return layer_orna
    }()

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 18
        return b
    }()

    private let actionButtonContainer_Orna: UIView = UIView()

    /// 热门标签徽标（点赞数达到阈值时叠加展示于媒体图上，纯展示无交互）
    /// 设计思路：与发现页瀑布流卡片的"热门"视觉语言保持一致，强化高互动内容的辨识度
    private let hotBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D")
        v.layer.cornerRadius = 13
        v.layer.shadowColor = UIColor(hexstring_Orna: "#FF6B9D").cgColor
        v.layer.shadowOpacity = 0.4
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 6
        v.isHidden = true
        return v
    }()

    private let hotBadgeLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "🔥 Hot"
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .white
        return l
    }()

    /// 返回按钮的顶部约束引用，随安全区高度动态更新（举报按钮通过 centerY 跟随返回按钮），
    /// 确保媒体图全面屏铺满至状态栏之下的同时，悬浮按钮始终清晰落在刘海/灵动岛下方
    private var backButtonTopConstraint_Orna: Constraint?

    // MARK: - UI · 滚动容器

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        // 关闭系统自动安全区内边距：即便 scrollView 自身 frame 已铺满至屏幕顶部，
        // .automatic 仍会隐式叠加一段与安全区等高的顶部内容内边距，导致媒体图与
        // 状态栏之间重新露出一截背景色空隙，必须显式关闭该行为实现真正的沉浸式铺满
        sv.contentInsetAdjustmentBehavior = .never
        // 背景改为白色（与内容卡片、底部输入栏同色）：当帖子正文/评论较少、内容总高度
        // 小于可视滚动区域时，卡片末端到底部输入栏之间会露出一段 scrollView 自身背景，
        // 若背景仍是淡紫色会与上下相邻的白色区块产生生硬断层的"截断感"；改为白色后
        // 该区域与卡片、输入栏视觉自然融合，不再有色块突变
        sv.backgroundColor = .white
        return sv
    }()

    private let contentView_Orna = UIView()

    /// 顶部媒体大图，底部做圆角处理与下方内容卡片衔接
    private let mediaView_Orna: MediaDisplayView_Orna = {
        let v = MediaDisplayView_Orna()
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    // MARK: - UI · 内容卡片（承载作者行 / 正文 / 互动 / 评论）

    /// 白色圆角内容卡片，与媒体图底部圆角衔接，向上轻微覆盖形成"贴纸"层叠效果
    private let contentCardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 内容卡片外层容器阴影：contentCardView_Orna 自身 clipsToBounds 无法承载阴影，
    /// 使用独立底层视图承接投影，强化卡片相对于淡紫背景的"层叠悬浮"立体感
    private let contentCardShadowView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowOffset = CGSize(width: 0, height: -6)
        v.layer.shadowRadius = 16
        return v
    }()

    /// 卡片顶部装饰性把手条，呼应底部弹层的通用视觉语言，弱化图片与卡片的生硬切割感
    private let cardGrabberView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#EDE9FE")
        v.layer.cornerRadius = 2.5
        return v
    }()

    // MARK: - UI · 作者行

    private let authorRow_Orna = UIView()

    private let authorAvatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.25).cgColor
        return v
    }()

    private let authorNameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let authorSubtitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "✨ Shared a desk moment"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let authorChevronView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(hexstring_Orna: "#D8D2F0")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 关注按钮：仅在浏览他人帖子时展示，与作者行行尾的箭头指示互斥出现
    /// 设计思路：复用用户中心页关注按钮的交互闭环（isFollowing_Orna/followUser_Orna），
    /// 让详情页也能一键关注作者，避免仅有跳转箭头而缺乏可直接执行的强化功能
    private let followButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        b.layer.cornerRadius = 14
        return b
    }()

    // MARK: - UI · 正文

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.numberOfLines = 0
        return l
    }()

    private let contentLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#4A4658")
        l.numberOfLines = 0
        return l
    }()

    // MARK: - UI · 互动胶囊

    private let interactionRow_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        return sv
    }()

    /// 点赞胶囊按钮：点赞态与未点赞态分别切换配色，取代原先纯文字按钮
    private let likeButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.imagePadding = 6
        config_orna.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 14, bottom: 9, trailing: 14)
        config_orna.background.cornerRadius = 18
        config_orna.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing_orna = incoming
            outgoing_orna.font = .systemFont(ofSize: 13, weight: .bold)
            return outgoing_orna
        }
        b.configuration = config_orna
        return b
    }()

    /// 评论数展示胶囊（纯展示，不可交互），与点赞胶囊保持一致的视觉规格
    private let commentPillView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        v.layer.cornerRadius = 18
        return v
    }()

    private let commentIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        iv.tintColor = UIColor(hexstring_Orna: "#8B87A0")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let dividerView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        return v
    }()

    /// 分割线中央的装饰性"摆件"圆徽，呼应桌面摆件主题，弱化纯直线分割的单调感
    private let dividerOrnamentView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
        return v
    }()

    private let dividerOrnamentIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor(hexstring_Orna: "#7B61FF")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI · 评论区

    /// 评论分区头（图标徽标 + 标题），与消息列表/发布页等分区头保持同一视觉语言
    private lazy var commentSectionHeader_Orna = makeSectionHeader_Orna(
        icon_orna: "bubble.left.and.bubble.right.fill", accentColorHex_orna: "#FF6B9D"
    )

    private let commentSectionTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let commentListStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    /// 评论区缺省态视图，作为唯一的排列子视图插入 commentListStack_Orna，
    /// 使有评论 / 无评论两种情况共用同一 Auto Layout 高度来源，避免额外维护一套独立约束
    private let emptyCommentView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        v.layer.cornerRadius = 16
        return v
    }()

    private let emptyCommentIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right"))
        iv.tintColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyCommentLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "No comments yet — be the first to say something!"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI · 底部评论输入栏

    private let inputBarView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: -3)
        v.layer.shadowRadius = 10
        return v
    }()

    private let inputField_Orna: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 14, weight: .regular)
        tf.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        tf.placeholder = "Add a comment..."
        tf.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        tf.layer.cornerRadius = 20
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
        let padding_orna = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftView = padding_orna
        tf.leftViewMode = .always
        return tf
    }()

    /// 发送按钮：采用 UIButton.Configuration 承载图标，确保图标稳定渲染在自定义渐变背板之上，
    /// 不受手动 insertSublayer 与系统旧版 imageView 图层时序差异的影响
    private let sendButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        config_orna.baseForegroundColor = .white
        config_orna.contentInsets = .zero
        b.configuration = config_orna
        b.layer.cornerRadius = 20
        b.clipsToBounds = true
        return b
    }()

    private var sendButtonGradientLayer_Orna: CAGradientLayer?

    /// 当前状态栏是否呈浅色样式（悬浮于媒体图上时为 true，滚动至白色内容卡片后为 false）
    private var isStatusBarLight_Orna: Bool = true

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        isStatusBarLight_Orna = scrollView_Orna.contentOffset.y < 140
        setNeedsStatusBarAppearanceUpdate()
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mediaGradientOverlay_Orna.frame = CGRect(x: 0, y: 0, width: mediaView_Orna.bounds.width, height: 120)
        sendButtonGradientLayer_Orna?.frame = sendButton_Orna.bounds

        // 媒体图已铺满至屏幕最顶部，悬浮按钮需结合安全区高度动态下移，
        // 确保始终清晰落在刘海/灵动岛下方而不被状态栏遮挡
        let topInset_orna = view.safeAreaInsets.top
        backButtonTopConstraint_Orna?.update(offset: topInset_orna + 8)
    }

    /// 状态栏样式随滚动位置动态切换：悬浮于媒体图上方时为浅色，滚动至白色内容卡片后为深色
    override var preferredStatusBarStyle: UIStatusBarStyle { isStatusBarLight_Orna ? .lightContent : .darkContent }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(mediaView_Orna)
        mediaView_Orna.layer.addSublayer(mediaGradientOverlay_Orna)
        mediaView_Orna.addSubview(backButton_Orna)
        mediaView_Orna.addSubview(actionButtonContainer_Orna)
        hotBadgeView_Orna.addSubview(hotBadgeLabel_Orna)
        mediaView_Orna.addSubview(hotBadgeView_Orna)

        contentView_Orna.addSubview(contentCardShadowView_Orna)
        contentView_Orna.addSubview(contentCardView_Orna)
        contentCardView_Orna.addSubview(cardGrabberView_Orna)

        authorRow_Orna.addSubview(authorAvatarView_Orna)
        authorRow_Orna.addSubview(authorNameLabel_Orna)
        authorRow_Orna.addSubview(authorSubtitleLabel_Orna)
        authorRow_Orna.addSubview(authorChevronView_Orna)
        authorRow_Orna.addSubview(followButton_Orna)
        contentCardView_Orna.addSubview(authorRow_Orna)

        contentCardView_Orna.addSubview(titleLabel_Orna)
        contentCardView_Orna.addSubview(contentLabel_Orna)

        interactionRow_Orna.addArrangedSubview(likeButton_Orna)
        commentPillView_Orna.addSubview(commentIconView_Orna)
        commentPillView_Orna.addSubview(commentCountLabel_Orna)
        interactionRow_Orna.addArrangedSubview(commentPillView_Orna)
        contentCardView_Orna.addSubview(interactionRow_Orna)

        contentCardView_Orna.addSubview(dividerView_Orna)
        dividerOrnamentView_Orna.addSubview(dividerOrnamentIconView_Orna)
        contentCardView_Orna.addSubview(dividerOrnamentView_Orna)

        commentSectionHeader_Orna.addSubview(commentSectionTitleLabel_Orna)
        contentCardView_Orna.addSubview(commentSectionHeader_Orna)
        contentCardView_Orna.addSubview(commentListStack_Orna)

        emptyCommentView_Orna.addSubview(emptyCommentIconView_Orna)
        emptyCommentView_Orna.addSubview(emptyCommentLabel_Orna)

        view.addSubview(inputBarView_Orna)
        inputBarView_Orna.addSubview(inputField_Orna)
        inputBarView_Orna.addSubview(sendButton_Orna)
        setupSendButtonGradient_Orna()
    }

    /// 发送按钮紫粉渐变背景，与全 App 主要 CTA 按钮保持同一强调色
    private func setupSendButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        sendButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        sendButtonGradientLayer_Orna = layer_orna
    }

    /// 搭建评论分区头图标徽标，与消息列表/发布页等分区头保持同一视觉语言
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private func makeSectionHeader_Orna(icon_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 14
        container_orna.addSubview(badge_orna)

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = accentColor_orna
        iconView_orna.contentMode = .scaleAspectFit
        badge_orna.addSubview(iconView_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        return container_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        // 滚动容器直接铺满至屏幕顶部（而非安全区顶部），使媒体大图能够沉浸式延伸至
        // 状态栏/刘海区域之下，消除此前"状态栏与媒体图之间露出一截背景色空隙"的观感
        scrollView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputBarView_Orna.snp.top)
        }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        mediaView_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(320)
        }
        // 返回/举报按钮叠加在媒体图上，相对 mediaView_Orna 自身定位（而非安全区，避免跨越
        // UIScrollView 内容边界产生约束冲突），顶部偏移在 viewDidLayoutSubviews 中结合
        // view.safeAreaInsets.top 动态调整，确保媒体图全面屏铺满的同时按钮不被状态栏遮挡
        backButton_Orna.snp.makeConstraints {
            backButtonTopConstraint_Orna = $0.top.equalToSuperview().offset(12).constraint
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        actionButtonContainer_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(36)
        }
        hotBadgeView_Orna.snp.makeConstraints {
            $0.bottom.equalTo(mediaView_Orna.snp.bottom).offset(-46)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(26)
        }
        hotBadgeLabel_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
        }

        // 内容卡片向上覆盖媒体图底部圆角 20，形成层叠贴纸效果
        contentCardView_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaView_Orna.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentCardShadowView_Orna.snp.makeConstraints {
            $0.edges.equalTo(contentCardView_Orna)
        }
        cardGrabberView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }

        authorRow_Orna.snp.makeConstraints {
            $0.top.equalTo(cardGrabberView_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        authorAvatarView_Orna.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        authorChevronView_Orna.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(12)
        }
        followButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(28)
            $0.width.greaterThanOrEqualTo(72)
        }
        authorNameLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(authorAvatarView_Orna.snp.trailing).offset(10)
            $0.trailing.lessThanOrEqualTo(authorChevronView_Orna.snp.leading).offset(-8)
            $0.trailing.lessThanOrEqualTo(followButton_Orna.snp.leading).offset(-8)
            $0.top.equalTo(authorAvatarView_Orna).offset(1)
        }
        authorSubtitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(authorNameLabel_Orna)
            $0.top.equalTo(authorNameLabel_Orna.snp.bottom).offset(3)
        }

        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(authorRow_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        contentLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        interactionRow_Orna.snp.makeConstraints {
            $0.top.equalTo(contentLabel_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(36)
        }
        commentIconView_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(13)
        }
        commentCountLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(commentIconView_Orna.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
        }

        dividerView_Orna.snp.makeConstraints {
            $0.top.equalTo(interactionRow_Orna.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        dividerOrnamentView_Orna.snp.makeConstraints {
            $0.center.equalTo(dividerView_Orna)
            $0.width.height.equalTo(22)
        }
        dividerOrnamentIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(11)
        }

        commentSectionHeader_Orna.snp.makeConstraints {
            $0.top.equalTo(dividerView_Orna.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        commentSectionTitleLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(commentSectionHeader_Orna).offset(36)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        commentListStack_Orna.snp.makeConstraints {
            $0.top.equalTo(commentSectionHeader_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-30)
        }
        emptyCommentIconView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        emptyCommentLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(emptyCommentIconView_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-22)
        }

        // 输入栏白色背板铺满至屏幕真正底部边缘（而非止步于安全区），消除底部因安全区
        // 预留区域露出淡紫背景而产生的空隙；输入框与发送按钮则仍锚定在安全区之上，
        // 确保交互控件不会被 Home 指示条遮挡
        inputBarView_Orna.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        inputField_Orna.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(40)
        }
        sendButton_Orna.snp.makeConstraints {
            $0.leading.equalTo(inputField_Orna.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(inputField_Orna)
            $0.width.height.equalTo(40)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        scrollView_Orna.delegate = self
        inputField_Orna.delegate = self

        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        likeButton_Orna.addTarget(self, action: #selector(handleLikeTapped_Orna), for: .touchUpInside)
        followButton_Orna.addTarget(self, action: #selector(handleFollowTapped_Orna), for: .touchUpInside)
        sendButton_Orna.addTarget(self, action: #selector(handleSendCommentTapped_Orna), for: .touchUpInside)
        inputField_Orna.addTarget(self, action: #selector(handleSendCommentTapped_Orna), for: .editingDidEndOnExit)

        authorRow_Orna.isUserInteractionEnabled = true
        authorRow_Orna.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAuthorTapped_Orna)))

        mediaView_Orna.isUserInteractionEnabled = true
        let mediaTap_orna = UITapGestureRecognizer(target: self, action: #selector(handleMediaTapped_Orna))
        mediaView_Orna.addGestureRecognizer(mediaTap_orna)
    }

    /// 滚动位置切换状态栏样式：悬浮于媒体图上方时使用浅色，滚动至白色内容卡片区域后改为深色
    /// 参数：
    /// - scrollView: 触发滚动回调的滚动容器
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let shouldBeLight_orna = scrollView.contentOffset.y < 140
        guard shouldBeLight_orna != isStatusBarLight_Orna else { return }
        isStatusBarLight_Orna = shouldBeLight_orna
        setNeedsStatusBarAppearanceUpdate()
    }

    /// 评论输入框获得焦点时描边切换为强调色，提供清晰的聚焦反馈
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputField_Orna.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.5).cgColor
            self.inputField_Orna.backgroundColor = .white
        }
    }

    /// 评论输入框失去焦点时描边恢复为默认浅紫色
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.inputField_Orna.layer.borderColor = UIColor(hexstring_Orna: "#EDE9FE").cgColor
            self.inputField_Orna.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        }
    }

    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - 数据刷新

    @objc private func refreshAll_Orna() {
        guard let post_orna = titleModel_Orna else { return }

        // 帖子已被删除/举报：自动返回上一页
        guard TitleViewModel_Orna.shared_Orna.getPosts_Orna().contains(where: { $0.titleId_Orna == post_orna.titleId_Orna }) else {
            Navigation_Orna.pop_Orna(from: self)
            return
        }

        mediaView_Orna.configure_Orna(mediaPath_Orna: post_orna.titleMeidas_Orna.first, isVideo_Orna: post_orna.isVideoMedia_Orna)
        authorAvatarView_Orna.configure_Orna(userId_Orna: post_orna.titleUserId_Orna)
        authorNameLabel_Orna.text = post_orna.titleUserName_Orna
        titleLabel_Orna.text = post_orna.title_Orna
        contentLabel_Orna.text = post_orna.titleContent_Orna
        hotBadgeView_Orna.isHidden = post_orna.likes_Orna < 30

        refreshFollowButton_Orna(post_orna: post_orna)

        let isLiked_orna = TitleViewModel_Orna.shared_Orna.isLikedPost_Orna(post_orna: post_orna)
        refreshLikeButtonStyle_Orna(isLiked_orna: isLiked_orna, likeCount_orna: post_orna.likes_Orna)

        let visibleComments_orna = TitleViewModel_Orna.shared_Orna.getVisibleComments_Orna(post_orna: post_orna)
        commentCountLabel_Orna.text = "\(visibleComments_orna.count)"
        commentSectionTitleLabel_Orna.text = "Comments (\(visibleComments_orna.count))"

        rebuildActionButton_Orna(post_orna: post_orna)
        refreshComments_Orna(post_orna: post_orna, comments_orna: visibleComments_orna)
    }

    /// 刷新点赞胶囊按钮的图标、文案与配色（点赞态使用粉色强调，未点赞使用中性浅紫）
    /// 参数：
    /// - isLiked_orna: 当前用户是否已点赞
    /// - likeCount_orna: 点赞总数
    private func refreshLikeButtonStyle_Orna(isLiked_orna: Bool, likeCount_orna: Int) {
        var config_orna = likeButton_Orna.configuration
        let iconName_orna = isLiked_orna ? "heart.fill" : "heart"
        let tintColor_orna = isLiked_orna ? UIColor(hexstring_Orna: "#FF6B9D") : UIColor(hexstring_Orna: "#8B87A0")
        config_orna?.image = UIImage(systemName: iconName_orna, withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config_orna?.title = "\(likeCount_orna)"
        config_orna?.baseForegroundColor = tintColor_orna
        config_orna?.background.backgroundColor = isLiked_orna
            ? UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.12)
            : UIColor(hexstring_Orna: "#F6F3FF")
        likeButton_Orna.configuration = config_orna
    }

    /// 刷新作者行的关注按钮：本人帖子展示跳转箭头，他人帖子展示关注按钮（互斥展示）
    /// 参数：
    /// - post_orna: 当前展示的帖子模型
    private func refreshFollowButton_Orna(post_orna: TitleModel_Orna) {
        let isSelf_orna = UserViewModel_Orna.shared_Orna.isCurrentUser_Orna(userId_orna: post_orna.titleUserId_Orna)
        followButton_Orna.isHidden = isSelf_orna
        authorChevronView_Orna.isHidden = !isSelf_orna
        guard !isSelf_orna else { return }

        let author_orna = UserViewModel_Orna.shared_Orna.getUserById_Orna(userId_orna: post_orna.titleUserId_Orna)
        let isFollowing_orna = UserViewModel_Orna.shared_Orna.isFollowing_Orna(user_orna: author_orna)
        followButton_Orna.setTitle(isFollowing_orna ? "✓ Following" : "+ Follow", for: .normal)
        followButton_Orna.setTitleColor(isFollowing_orna ? UIColor(hexstring_Orna: "#7B61FF") : .white, for: .normal)
        followButton_Orna.backgroundColor = isFollowing_orna ? UIColor(hexstring_Orna: "#F6F3FF") : UIColor(hexstring_Orna: "#7B61FF")
    }

    /// 重建举报/删除按钮
    private func rebuildActionButton_Orna(post_orna: TitleModel_Orna) {
        actionButtonContainer_Orna.subviews.forEach { $0.removeFromSuperview() }
        let button_orna = ReportDeleteHelper_Orna.createPostReportButton_Orna(
            post_Orna: post_orna,
            size_Orna: 15,
            color_Orna: .white,
            from: self
        ) { [weak self] in
            Navigation_Orna.pop_Orna(from: self)
        }
        button_orna.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        button_orna.layer.cornerRadius = 18
        actionButtonContainer_Orna.addSubview(button_orna)
        button_orna.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    /// 刷新评论列表：与缺省态视图共用同一个 UIStackView，
    /// 举报评论后自动从列表移除，无评论时展示统一风格的缺省态卡片
    private func refreshComments_Orna(post_orna: TitleModel_Orna, comments_orna: [Comment_Orna]) {
        commentListStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard !comments_orna.isEmpty else {
            commentListStack_Orna.addArrangedSubview(emptyCommentView_Orna)
            return
        }

        for comment_orna in comments_orna {
            let row_orna = CommentRowView_Orna()
            row_orna.configure_Orna(comment_orna: comment_orna, post_orna: post_orna, from: self)
            commentListStack_Orna.addArrangedSubview(row_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 点赞/取消点赞
    @objc private func handleLikeTapped_Orna() {
        guard let post_orna = titleModel_Orna else { return }
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        TitleViewModel_Orna.shared_Orna.likePost_Orna(post_orna: post_orna)
    }

    /// 关注/取消关注帖子作者
    @objc private func handleFollowTapped_Orna() {
        guard let post_orna = titleModel_Orna else { return }
        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }
        let author_orna = UserViewModel_Orna.shared_Orna.getUserById_Orna(userId_orna: post_orna.titleUserId_Orna)
        UserViewModel_Orna.shared_Orna.followUser_Orna(user_orna: author_orna)
    }

    /// 点击作者行：本人进入"我的"，他人进入用户中心
    @objc private func handleAuthorTapped_Orna() {
        guard let post_orna = titleModel_Orna else { return }
        if UserViewModel_Orna.shared_Orna.isCurrentUser_Orna(userId_orna: post_orna.titleUserId_Orna) {
            Navigation_Orna.toMe_Orna()
        } else {
            let author_orna = UserViewModel_Orna.shared_Orna.getUserById_Orna(userId_orna: post_orna.titleUserId_Orna)
            Navigation_Orna.toUserInfo_Orna(with: author_orna)
        }
    }

    /// 点击媒体：进入全屏浏览
    @objc private func handleMediaTapped_Orna() {
        guard let post_orna = titleModel_Orna, let path_orna = post_orna.titleMeidas_Orna.first else { return }
        let player_orna = MediaPlayerPage_Orna()
        player_orna.mediaPath_Orna = path_orna
        player_orna.isVideo_Orna = post_orna.isVideoMedia_Orna
        player_orna.modalPresentationStyle = .overFullScreen
        present(player_orna, animated: false)
    }

    /// 发布新评论
    @objc private func handleSendCommentTapped_Orna() {
        guard let post_orna = titleModel_Orna else { return }
        let text_orna = (inputField_Orna.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_orna.isEmpty else { return }

        guard UserViewModel_Orna.shared_Orna.isLoggedIn_Orna else {
            Navigation_Orna.toLogin_Orna()
            return
        }

        TitleViewModel_Orna.shared_Orna.releaseComment_Orna(post_orna: post_orna, content_orna: text_orna)
        inputField_Orna.text = ""
    }
}

// MARK: - 评论行视图

/// 评论行视图（浅紫气泡背景 + 头像 + 昵称 + 内容 + 举报按钮）
/// 核心作用：以独立气泡卡片承载单条评论，提升长列表中的可读性与视觉分隔度
private class CommentRowView_Orna: UIView {

    private let bubbleView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        v.layer.cornerRadius = 14
        return v
    }()

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let contentLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#4A4658")
        l.numberOfLines = 0
        return l
    }()

    private let actionButtonContainer_Orna = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView_Orna)
        bubbleView_Orna.addSubview(avatarView_Orna)
        bubbleView_Orna.addSubview(nameLabel_Orna)
        bubbleView_Orna.addSubview(contentLabel_Orna)
        bubbleView_Orna.addSubview(actionButtonContainer_Orna)

        bubbleView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }

        avatarView_Orna.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(12)
            $0.width.height.equalTo(32)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna)
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(10)
            $0.trailing.equalTo(actionButtonContainer_Orna.snp.leading).offset(-8)
        }
        contentLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(4)
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.equalToSuperview().offset(-12)
            $0.bottom.equalToSuperview().offset(-12)
        }
        actionButtonContainer_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(22)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// 配置评论内容
    func configure_Orna(comment_orna: Comment_Orna, post_orna: TitleModel_Orna, from viewController_orna: UIViewController) {
        avatarView_Orna.configure_Orna(userId_Orna: comment_orna.commentUserId_Orna)
        nameLabel_Orna.text = comment_orna.commentUserName_Orna
        contentLabel_Orna.text = comment_orna.commentContent_Orna

        actionButtonContainer_Orna.subviews.forEach { $0.removeFromSuperview() }
        let button_orna = ReportDeleteHelper_Orna.createCommentReportButton_Orna(
            comment_Orna: comment_orna,
            post_Orna: post_orna,
            size_Orna: 11,
            color_Orna: UIColor(hexstring_Orna: "#B5AFCB"),
            from: viewController_orna
        )
        actionButtonContainer_Orna.addSubview(button_orna)
        button_orna.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
