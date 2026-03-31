import UIKit
import SnapKit

// MARK: - 帖子网格 CollectionView Cell

/// 帖子双列网格 UICollectionViewCell
/// 核心作用：在发现页热门帖子网格区域展示单条帖子，使用 MediaDisplayView 展示媒体，
///           左上角叠加用户头像 + 用户名，底部叠加帖子标题 + 点赞数，右上角提供删除/举报操作按钮。
/// 设计思路：媒体全铺卡片，底部渐变遮罩保证信息可读，顶部半透明渐变保证头像区信息可读，
///           左上角头像区域使用透明 UIButton 覆盖——UIControl 被点击时 UITableView/UICollectionView
///           不触发行/项选中，彻底避免头像导航与详情跳转冲突。
/// 关键属性：onActionTapped_Flick（删除/举报回调）、onAvatarTapped_Flick（头像点击回调）
class PostGridCell_Flick: UICollectionViewCell {
    
    // MARK: - 复用标识
    
    static let reuseId_Flick = "PostGridCell_Flick"
    
    // MARK: - 回调
    
    /// 右上角操作按钮（删除/举报）点击回调，由外部 VC 负责调用 ReportDeleteHelper
    var onActionTapped_Flick: (() -> Void)?
    
    /// 左上角头像点击回调（仅非当前登录用户帖子时有效，由外部 VC 设置）
    var onAvatarTapped_Flick: (() -> Void)?
    
    // MARK: - UI 组件
    
    /// 卡片圆角容器（遮住媒体四角）
    private let cardView_Flick: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()
    
    /// 媒体展示视图（图片/视频封面）
    private let mediaView_Flick = MediaDisplayView_Flick()
    
    /// 底部渐变遮罩（保证标题/点赞可读）
    private let bottomMask_Flick = UIView()
    private var bottomMaskGrad_Flick: CAGradientLayer?
    
    /// 顶部渐变遮罩（保证头像区信息可读）
    private let topMask_Flick = UIView()
    private var topMaskGrad_Flick: CAGradientLayer?
    
    /// 右上角操作按钮（自己帖子→trash，他人帖子→ellipsis）
    private let actionButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor.black.withValues(alpha: 0.35)
        b.layer.cornerRadius = 14
        b.tintColor = .white
        return b
    }()
    
    /// 用户头像（左上角）
    private let avatarView_Flick = UserAvatarView_Flick()
    
    /// 透明头像点击按钮（覆盖头像区域，UIControl 被点击时 UICollectionView 不触发项选中）
    private let avatarTapBtn_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        return btn
    }()
    
    /// 用户名标签（左上角，与头像同行）
    private let userNameLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor.white.withValues(alpha: 0.9)
        l.numberOfLines = 1
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        l.layer.shadowRadius = 2
        l.layer.shadowOpacity = 0.5
        return l
    }()
    
    /// 帖子标题标签（底部）
    private let titleLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        l.layer.shadowColor = UIColor.black.cgColor
        l.layer.shadowOffset = CGSize(width: 0, height: 1)
        l.layer.shadowRadius = 3
        l.layer.shadowOpacity = 0.4
        return l
    }()
    
    /// 点赞数标签（底部最下）
    private let likesLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = UIColor.white.withValues(alpha: 0.85)
        return l
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bottomMaskGrad_Flick?.frame = bottomMask_Flick.bounds
        topMaskGrad_Flick?.frame    = topMask_Flick.bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }
    
    // MARK: - UI 布局
    
    /// 搭建所有子视图及约束
    /// 布局结构（从上至下）：
    ///   顶部：[头像 + 用户名（左上角）]  [操作按钮（右上角）]
    ///   底部：[帖子标题]
    ///         [点赞数]
    private func setupUI_Flick() {
        backgroundColor = .clear
        
        // 外层阴影（masksToBounds = false 才生效）
        layer.shadowColor = ColorConfig_Flick.shadowColor_Flick.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 1
        layer.masksToBounds = false
        
        // ── 基础视图 ──────────────────────────────────────────
        
        // 卡片容器（圆角裁切）
        contentView.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 媒体视图（填满卡片）
        mediaView_Flick.layer.cornerRadius = 16
        cardView_Flick.addSubview(mediaView_Flick)
        mediaView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // ── 渐变遮罩 ─────────────────────────────────────────
        
        // 底部渐变（透明 → 深黑，保证标题/点赞可读）
        cardView_Flick.addSubview(bottomMask_Flick)
        bottomMask_Flick.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        let maskGrad_Flick = CAGradientLayer()
        maskGrad_Flick.colors = [UIColor.clear.cgColor, UIColor.black.withValues(alpha: 0.65).cgColor]
        maskGrad_Flick.startPoint = CGPoint(x: 0.5, y: 0)
        maskGrad_Flick.endPoint   = CGPoint(x: 0.5, y: 1)
        bottomMask_Flick.layer.addSublayer(maskGrad_Flick)
        bottomMaskGrad_Flick = maskGrad_Flick
        
        // 顶部渐变（深黑 → 透明，保证左上角头像信息可读）
        cardView_Flick.addSubview(topMask_Flick)
        topMask_Flick.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(64)
        }
        let topGrad_Flick = CAGradientLayer()
        topGrad_Flick.colors = [UIColor.black.withValues(alpha: 0.45).cgColor, UIColor.clear.cgColor]
        topGrad_Flick.startPoint = CGPoint(x: 0.5, y: 0)
        topGrad_Flick.endPoint   = CGPoint(x: 0.5, y: 1)
        topMask_Flick.layer.addSublayer(topGrad_Flick)
        topMaskGrad_Flick = topGrad_Flick
        
        // ── 顶部信息行 ────────────────────────────────────────
        
        // 用户头像（左上角，24x24）
        cardView_Flick.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(24)
        }
        
        // 透明头像按钮（覆盖头像区域，UIButton 不触发项选中）
        cardView_Flick.addSubview(avatarTapBtn_Flick)
        avatarTapBtn_Flick.snp.makeConstraints { make in
            make.edges.equalTo(avatarView_Flick)
        }
        avatarTapBtn_Flick.addTarget(self, action: #selector(handleAvatarTap_Flick), for: .touchUpInside)
        
        // 用户名（与头像水平居中对齐，左贴头像右侧）
        cardView_Flick.addSubview(userNameLabel_Flick)
        userNameLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Flick)
            make.left.equalTo(avatarView_Flick.snp.right).offset(5)
            make.right.lessThanOrEqualTo(cardView_Flick.snp.right).offset(-44)
        }
        
        // 右上角操作按钮
        cardView_Flick.addSubview(actionButton_Flick)
        actionButton_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
        actionButton_Flick.addTarget(self, action: #selector(handleActionTap_Flick), for: .touchUpInside)
        
        // ── 底部信息 ──────────────────────────────────────────
        
        // 点赞数（最底部左侧）
        cardView_Flick.addSubview(likesLabel_Flick)
        likesLabel_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // 帖子标题（点赞数上方）
        cardView_Flick.addSubview(titleLabel_Flick)
        titleLabel_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.bottom.equalTo(likesLabel_Flick.snp.top).offset(-4)
        }
    }
    
    // MARK: - 公共配置方法
    
    /// 配置网格 Cell 内容
    /// - Parameter post_flick: 帖子数据模型
    /// 头像策略：非当前登录用户的帖子启用透明按钮；本人帖子隐藏按钮（无需跳转自身用户中心）
    func configure_Flick(post_flick: TitleModel_Flick) {
        // 媒体
        let mediaPath_Flick = post_flick.titleMeidas_Flick.first
        mediaView_Flick.configure_Flick(mediaPath_Flick: mediaPath_Flick)
        
        // 用户信息
        avatarView_Flick.configure_Flick(userId_Flick: post_flick.titleUserId_Flick)
        userNameLabel_Flick.text = "@\(post_flick.titleUserName_Flick)"
        
        // 帖子信息
        titleLabel_Flick.text  = post_flick.title_Flick
        likesLabel_Flick.text  = "♥ \(post_flick.likes_Flick)"
        
        // 操作按钮图标（自己→trash，他人→ellipsis）
        let isMyPost_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: post_flick.titleUserId_Flick
        )
        let iconName_Flick = isMyPost_Flick ? "trash" : "ellipsis"
        let config_Flick = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        actionButton_Flick.setImage(
            UIImage(systemName: iconName_Flick, withConfiguration: config_Flick),
            for: .normal
        )
        
        // 本人帖子：隐藏透明头像按钮；他人帖子：启用透明按钮
        avatarTapBtn_Flick.isHidden = isMyPost_Flick
    }
    
    // MARK: - 事件处理
    
    /// 操作按钮点击（举报/删除）
    @objc private func handleActionTap_Flick() {
        actionButton_Flick.animatePulse_Flick()
        let generator_Flick = UIImpactFeedbackGenerator(style: .medium)
        generator_Flick.impactOccurred()
        onActionTapped_Flick?()
    }
    
    /// 头像按钮点击（进入用户中心）
    /// UIButton 被点击时 UICollectionView 不触发项选中，不会与详情跳转冲突
    @objc private func handleAvatarTap_Flick() {
        avatarView_Flick.animatePressDown_Flick { [weak self] in
            self?.avatarView_Flick.animatePressUp_Flick()
        }
        let generator_Flick = UIImpactFeedbackGenerator(style: .light)
        generator_Flick.impactOccurred()
        onAvatarTapped_Flick?()
    }
    
    // MARK: - 触摸动画
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        cardView_Flick.animatePressDown_Flick()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cardView_Flick.animatePressUp_Flick()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cardView_Flick.animatePressUp_Flick()
    }
}
