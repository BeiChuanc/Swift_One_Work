import UIKit
import SnapKit

// MARK: 发现页帖子瀑布流卡片

/// 发现页帖子双列瀑布流 Cell
/// 核心作用：竖向卡片设计——顶部 4:3 媒体（MediaDisplayView_Pane）+ 底部文字信息区；
///          操作按钮叠加于图片右上角，自己帖子显示删除（trash），他人帖子显示举报（ellipsis）
/// 设计理念：圆角卡片 + 图片全宽占顶 + 底部简洁信息行，适合双列交替展示
/// 关键方法：
///   - configure_Pane(post:):         填充帖子数据
///   - estimatedHeight_Pane(post:width:): 静态方法，供瀑布流布局预估高度
class DiscoverPostCell_Pane: UICollectionViewCell {

    // MARK: - 静态常量

    static let reuseId_Pane = "DiscoverPostCell_Pane"

    // MARK: - 回调

    /// 操作按钮（举报/删除）点击回调；由外部 VC 调用 ReportDeleteHelper_Pane 处理业务
    var onMenuTapped_Pane: (() -> Void)?

    /// 头像点击回调；传出帖子作者的 userId，由外部跳转用户中心
    var onAvatarTapped_Pane: ((Int) -> Void)?

    /// 当前帖子作者 userId，供头像点击时回调使用
    private var authorUserId_Pane: Int = 0

    // MARK: - UI 组件

    /// 卡片容器（暖色阴影）
    private let cardView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor     = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius  = 16
        v.layer.shadowColor   = UIColor(hexstring_Pane: "#C08040").alpha_Pane(0.15).cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 4)
        v.layer.shadowRadius  = 10
        v.layer.masksToBounds = false
        return v
    }()

    /// 图片容器（上方圆角裁剪区）
    private let mediaContainer_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds       = true
        v.layer.cornerRadius  = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    /// 媒体展示（使用 MediaDisplayView_Pane 统一渲染）
    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 0
        v.clipsToBounds      = true
        return v
    }()

    /// 操作按钮（叠加于图片右上角，半透明深色圆形）
    private let menuButton_Pane: UIButton = {
        let b             = UIButton(type: .system)
        let cfg           = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        b.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.alpha_Pane(0.38)
        b.layer.cornerRadius = 14
        b.clipsToBounds   = true
        return b
    }()

    /// 帖子标题（最多 2 行）
    private let titleLabel_Pane: UILabel = {
        let l           = UILabel()
        l.font          = .systemFont(ofSize: 13, weight: .bold)
        l.textColor     = ColorConfig_Pane.textPrimary_Pane
        l.numberOfLines = 2
        return l
    }()

    /// 内容预览（最多 1 行，没有内容时隐藏）
    private let contentLabel_Pane: UILabel = {
        let l           = UILabel()
        l.font          = .systemFont(ofSize: 11)
        l.textColor     = ColorConfig_Pane.textSecondary_Pane
        l.numberOfLines = 1
        return l
    }()

    /// 主题标签胶囊（有主题时显示）
    private let themeChip_Pane: UILabel = {
        let l                 = UILabel()
        l.font                = .systemFont(ofSize: 10, weight: .medium)
        l.textColor           = ColorConfig_Pane.primaryGradientStart_Pane
        l.backgroundColor     = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.1)
        l.layer.cornerRadius  = 8
        l.clipsToBounds       = true
        l.textAlignment       = .center
        return l
    }()

    /// 作者头像
    private let avatarView_Pane: UserAvatarView_Pane = {
        let v = UserAvatarView_Pane()
        v.onlineIndicator_Pane.isHidden = true
        return v
    }()

    /// 作者名称
    private let authorLabel_Pane: UILabel = {
        let l = UILabel()
        l.font  = .systemFont(ofSize: 10)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    /// 点赞数容器（暖橙风格）
    private let likesBadge_Pane: UIView = {
        let v                 = UIView()
        v.backgroundColor     = UIColor(hexstring_Pane: "#FFF3E0")
        v.layer.cornerRadius  = 9
        v.clipsToBounds       = true
        return v
    }()

    private let likeIcon_Pane: UIImageView = {
        let iv         = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor   = UIColor(hexstring_Pane: "#FC8181")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likesLabel_Pane: UILabel = {
        let l       = UILabel()
        l.font      = .systemFont(ofSize: 10, weight: .semibold)
        l.textColor = UIColor(hexstring_Pane: "#E07060")
        return l
    }()

    // MARK: - 高亮响应

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                cardView_Pane.animatePressDown_Pane()
            } else {
                cardView_Pane.animatePressUp_Pane()
            }
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView_Pane.layer.shadowPath = UIBezierPath(
            roundedRect: cardView_Pane.bounds,
            cornerRadius: 16
        ).cgPath
    }

    // MARK: - UI 布局

    private func setupUI_Pane() {
        contentView.addSubview(cardView_Pane)
        cardView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 媒体容器（上半部分，4:3 比例）
        cardView_Pane.addSubview(mediaContainer_Pane)
        mediaContainer_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(mediaContainer_Pane.snp.width).multipliedBy(0.75)
        }
        mediaContainer_Pane.addSubview(mediaView_Pane)
        mediaView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 操作按钮（叠加图片右上角）
        mediaContainer_Pane.addSubview(menuButton_Pane)
        menuButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(28)
        }
        menuButton_Pane.addTarget(self, action: #selector(menuTapped_Pane), for: .touchUpInside)

        // 标题（媒体下方，左右 12pt 内边距）
        cardView_Pane.addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(mediaContainer_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        // 内容预览
        cardView_Pane.addSubview(contentLabel_Pane)
        contentLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Pane.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        // 主题胶囊
        cardView_Pane.addSubview(themeChip_Pane)
        themeChip_Pane.snp.makeConstraints {
            $0.top.equalTo(contentLabel_Pane.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(12)
            $0.height.equalTo(20)
        }

        // 点赞徽章（底部右对齐）
        likesBadge_Pane.addSubview(likeIcon_Pane)
        likesBadge_Pane.addSubview(likesLabel_Pane)
        cardView_Pane.addSubview(likesBadge_Pane)
        likeIcon_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(10)
        }
        likesLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(likeIcon_Pane.snp.trailing).offset(3)
            $0.trailing.equalToSuperview().offset(-6)
            $0.centerY.equalToSuperview()
        }
        likesBadge_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(18)
        }

        // 底部作者行（头像 + 作者名）
        cardView_Pane.addSubview(avatarView_Pane)
        cardView_Pane.addSubview(authorLabel_Pane)
        avatarView_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.width.height.equalTo(32)
        }
        authorLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(avatarView_Pane.snp.trailing).offset(6)
            $0.centerY.equalTo(avatarView_Pane)
            $0.trailing.lessThanOrEqualTo(likesBadge_Pane.snp.leading).offset(-6)
        }

        // 头像添加点击手势
        avatarView_Pane.isUserInteractionEnabled = true
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Pane))
        avatarView_Pane.addGestureRecognizer(tap_pane)
    }

    // MARK: - 数据配置

    /// 配置帖子卡片数据
    /// - Parameter post_pane: 帖子数据模型（TitleModel_Pane）
    func configure_Pane(post_pane: TitleModel_Pane) {
        // 媒体：使用 MediaDisplayView_Pane 统一渲染
        mediaView_Pane.configure_Pane(mediaPath_Pane: post_pane.titleMeidas_Pane.first)

        authorUserId_Pane     = post_pane.titleUserId_Pane
        titleLabel_Pane.text  = post_pane.title_Pane
        authorLabel_Pane.text = post_pane.titleUserName_Pane
        likesLabel_Pane.text  = "\(post_pane.likes_Pane)"
        avatarView_Pane.configure_Pane(userId_Pane: post_pane.titleUserId_Pane)

        // 内容预览（为空时隐藏以节省高度）
        let hasContent_pane           = !post_pane.titleContent_Pane.isEmpty
        contentLabel_Pane.isHidden    = !hasContent_pane
        contentLabel_Pane.text        = post_pane.titleContent_Pane

        // 主题胶囊（无主题时隐藏）
        let hasTheme_pane             = !post_pane.titleTheme_Pane.isEmpty
        themeChip_Pane.isHidden       = !hasTheme_pane
        themeChip_Pane.text           = hasTheme_pane ? " \(post_pane.titleTheme_Pane) " : nil

        // 根据帖子归属配置操作按钮图标
        let isMyPost_pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
            userId_pane: post_pane.titleUserId_Pane
        )
        let iconName_pane = isMyPost_pane ? "trash" : "ellipsis"
        let cfg_pane      = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        menuButton_Pane.setImage(
            UIImage(systemName: iconName_pane, withConfiguration: cfg_pane),
            for: .normal
        )
    }

    // MARK: - 静态高度计算

    /// 根据帖子内容和列宽预估 Cell 高度，供瀑布流布局使用
    /// - Parameters:
    ///   - post_pane:  帖子数据模型
    ///   - width_pane: 当前列宽（双列布局中的单列宽度）
    /// - Returns: 预估的 Cell 总高度
    static func estimatedHeight_Pane(post_pane: TitleModel_Pane, width_pane: CGFloat) -> CGFloat {
        // 媒体区高度（4:3 比例）
        let mediaH_pane: CGFloat = width_pane * 0.75

        // 标题高度（最多 2 行）
        let titleFont_pane  = UIFont.systemFont(ofSize: 13, weight: .bold)
        let titleW_pane     = width_pane - 24
        let rawTitleH_pane  = ceil((post_pane.title_Pane as NSString).boundingRect(
            with: CGSize(width: titleW_pane, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: titleFont_pane],
            context: nil
        ).height)
        let titleH_pane = min(rawTitleH_pane, titleFont_pane.lineHeight * 2 + 4)

        // 可选区域高度
        let contentH_pane: CGFloat = post_pane.titleContent_Pane.isEmpty ? 0 : 5 + 14
        let themeH_pane: CGFloat   = post_pane.titleTheme_Pane.isEmpty   ? 0 : 4 + 20

        // 组合：顶图 + 顶部间距 + 标题 + 内容 + 主题 + 底部间距 + 底部行高 + 底部内边距
        return mediaH_pane + 10 + titleH_pane + contentH_pane + themeH_pane + 8 + 28 + 12
    }

    // MARK: - 私有方法

    /// 操作按钮点击：缩放动画 + 触发回调
    @objc private func menuTapped_Pane() {
        UIView.animate(withDuration: 0.1, animations: {
            self.menuButton_Pane.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.menuButton_Pane.transform = .identity
            }
        }
        onMenuTapped_Pane?()
    }

    /// 头像点击：弹性缩放动画 + 触发跳转回调
    @objc private func avatarTapped_Pane() {
        UIView.animate(withDuration: 0.1, animations: {
            self.avatarView_Pane.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 4, options: [], animations: {
                self.avatarView_Pane.transform = .identity
            }, completion: nil)
        }
        onAvatarTapped_Pane?(authorUserId_Pane)
    }
}
