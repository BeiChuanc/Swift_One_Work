import UIKit
import SnapKit

// MARK: 通用帖子卡片视图

// MARK: - 代理协议

/// 帖子卡片交互代理协议
/// 功能：将卡片内的点击事件向上传递给所在页面
protocol PostCardDelegate_Sprig: AnyObject {
    /// 点击卡片主体（进入详情）
    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapCard_sprig post_sprig: TitleModel_Sprig)
    /// 点击用户头像或昵称（进入用户主页）
    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapUser_sprig post_sprig: TitleModel_Sprig)
    /// 点击点赞按钮
    func postCard_Sprig(_ card_sprig: PostCardView_Sprig, didTapLike_sprig post_sprig: TitleModel_Sprig)
}

// MARK: - 帖子卡片视图

/// 通用帖子卡片
/// 功能：展示帖子的作者信息、媒体占位、标题、内容摘要、点赞/评论数
/// 特性：圆角阴影卡片风格，点赞动画，用于首页和发现页
class PostCardView_Sprig: UIView {
    
    // MARK: - 公共属性
    
    /// 代理
    weak var delegate_Sprig: PostCardDelegate_Sprig?

    /// 外部传入的 UIViewController，供举报/删除 Alert 使用
    weak var viewController_Sprig: UIViewController?
    
    /// 当前帖子模型（只读）
    private(set) var post_Sprig: TitleModel_Sprig?
    
    // MARK: - 私有 UI
    
    /// 卡片容器（白底圆角阴影）
    private let cardContainer_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Sprig.cardBackground_Sprig
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 0.07
        return v
    }()
    
    /// 用户头像（通用头像组件）
    private let avatarView_Sprig = UserAvatarView_Sprig()
    
    /// 用户昵称
    private let userNameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        return l
    }()
    
    /// 帖子标签 badge 容器
    private let tagContainerStack_Sprig: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()

    /// 右上角举报/删除按钮
    private let actionBtn_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        btn.layer.cornerRadius = 13
        return btn
    }()
    
    /// 媒体展示区域（支持图片/视频/SF Symbol/占位符）
    private let mediaView_Sprig = MediaDisplayView_Sprig()
    
    /// 帖子标题
    private let titleLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        l.numberOfLines = 2
        return l
    }()
    
    /// 帖子内容摘要（2行截断）
    private let contentLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig
        l.numberOfLines = 2
        return l
    }()
    
    /// 分割线
    private let divider_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Sprig.divider_Sprig
        return v
    }()
    
    /// 点赞按钮
    private let likeButton_Sprig: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        btn.contentHorizontalAlignment = .left
        return btn
    }()
    
    /// 点赞数标签
    private let likeCountLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return l
    }()
    
    /// 评论图标
    private let commentIconView_Sprig: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left"))
        iv.tintColor = ColorConfig_Sprig.textPlaceholder_Sprig
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 评论数标签
    private let commentCountLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return l
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
        setupGestures_Sprig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Sprig()
        setupGestures_Sprig()
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // MediaDisplayView/UserAvatarView 内部自管理，无需手动更新渐变 frame
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Sprig() {
        backgroundColor = .clear
        addSubview(cardContainer_Sprig)
        
        // 卡片约束
        cardContainer_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
        }
        
        // 用户头像（UserAvatarView 统一组件）
        avatarView_Sprig.layer.cornerRadius = 18
        avatarView_Sprig.clipsToBounds = true
        cardContainer_Sprig.addSubview(avatarView_Sprig)
        cardContainer_Sprig.addSubview(userNameLabel_Sprig)
        cardContainer_Sprig.addSubview(tagContainerStack_Sprig)
        cardContainer_Sprig.addSubview(actionBtn_Sprig)
        
        // 媒体区域（MediaDisplayView 统一组件）
        cardContainer_Sprig.addSubview(mediaView_Sprig)
        
        cardContainer_Sprig.addSubview(titleLabel_Sprig)
        cardContainer_Sprig.addSubview(contentLabel_Sprig)
        cardContainer_Sprig.addSubview(divider_Sprig)
        cardContainer_Sprig.addSubview(likeButton_Sprig)
        cardContainer_Sprig.addSubview(likeCountLabel_Sprig)
        cardContainer_Sprig.addSubview(commentIconView_Sprig)
        cardContainer_Sprig.addSubview(commentCountLabel_Sprig)
        
        setupConstraints_Sprig()
        actionBtn_Sprig.addTarget(self, action: #selector(handleActionTap_Sprig), for: .touchUpInside)
    }
    
    /// 设置全部约束
    private func setupConstraints_Sprig() {
        // 头像
        avatarView_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        // 用户名
        userNameLabel_Sprig.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Sprig.snp.right).offset(10)
            make.centerY.equalTo(avatarView_Sprig)
            make.right.lessThanOrEqualTo(tagContainerStack_Sprig.snp.left).offset(-8)
        }
        
        // 标签
        tagContainerStack_Sprig.snp.makeConstraints { make in
            make.right.equalTo(actionBtn_Sprig.snp.left).offset(-8)
            make.centerY.equalTo(avatarView_Sprig)
            make.height.equalTo(20)
        }

        // 右上角举报/删除按钮
        actionBtn_Sprig.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(avatarView_Sprig)
            make.width.height.equalTo(26)
        }
        
        // 媒体区域
        mediaView_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }
        
        // 标题
        titleLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 内容
        contentLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Sprig.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 分割线
        divider_Sprig.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Sprig.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        
        // 底部操作区
        likeButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(divider_Sprig.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-14)
        }
        likeCountLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Sprig)
            make.left.equalTo(likeButton_Sprig.snp.right).offset(5)
        }
        commentIconView_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Sprig)
            make.left.equalTo(likeCountLabel_Sprig.snp.right).offset(16)
            make.width.height.equalTo(18)
        }
        commentCountLabel_Sprig.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton_Sprig)
            make.left.equalTo(commentIconView_Sprig.snp.right).offset(5)
        }
    }
    
    // MARK: - 手势设置
    
    private func setupGestures_Sprig() {
        // 卡片整体点击
        let tap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Sprig))
        cardContainer_Sprig.addGestureRecognizer(tap_sprig)
        cardContainer_Sprig.isUserInteractionEnabled = true
        
        // 用户头像/昵称点击
        let userTap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleUserTap_Sprig))
        avatarView_Sprig.addGestureRecognizer(userTap_sprig)
        avatarView_Sprig.isUserInteractionEnabled = true
        
        let userNameTap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleUserTap_Sprig))
        userNameLabel_Sprig.addGestureRecognizer(userNameTap_sprig)
        userNameLabel_Sprig.isUserInteractionEnabled = true
        
        // 点赞按钮
        likeButton_Sprig.addTarget(self, action: #selector(handleLikeTap_Sprig), for: .touchUpInside)
    }
    
    // MARK: - 手势响应
    
    @objc private func handleCardTap_Sprig() {
        guard let post_sprig = post_Sprig else { return }
        animatePressDown_Sprig()
        animatePressUp_Sprig {
            self.delegate_Sprig?.postCard_Sprig(self, didTapCard_sprig: post_sprig)
        }
    }
    
    @objc private func handleUserTap_Sprig() {
        guard let post_sprig = post_Sprig else { return }
        delegate_Sprig?.postCard_Sprig(self, didTapUser_sprig: post_sprig)
    }
    
    @objc private func handleLikeTap_Sprig() {
        guard let post_sprig = post_Sprig else { return }
        // 触发心跳脉冲动画
        likeButton_Sprig.animatePulse_Sprig()
        delegate_Sprig?.postCard_Sprig(self, didTapLike_sprig: post_sprig)
    }

    /// 点击右上角举报/删除按钮
    @objc private func handleActionTap_Sprig() {
        guard let post_sprig = post_Sprig, let vc_sprig = viewController_Sprig else { return }
        actionBtn_Sprig.animatePulse_Sprig()
        let isOwner_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig
        )
        if isOwner_sprig {
            ReportDeleteHelper_Sprig.delete_Sprig(
                post_Sprig: post_sprig,
                from: vc_sprig
            ) { }
        } else {
            ReportDeleteHelper_Sprig.report_Sprig(
                post_Sprig: post_sprig,
                from: vc_sprig
            ) { }
        }
    }
    
    // MARK: - 数据填充
    
    /// 填充帖子数据并刷新 UI
    /// 参数：post_sprig - 帖子模型
    func configure_Sprig(post_sprig: TitleModel_Sprig) {
        self.post_Sprig = post_sprig
        
        userNameLabel_Sprig.text = post_sprig.titleUserName_Sprig
        titleLabel_Sprig.text = post_sprig.title_Sprig
        contentLabel_Sprig.text = post_sprig.titleContent_Sprig
        likeCountLabel_Sprig.text = "\(post_sprig.likes_Sprig)"
        commentCountLabel_Sprig.text = "\(post_sprig.reviews_Sprig.count)"
        
        // 点赞状态
        let isLiked_sprig = TitleViewModel_Sprig.shared_Sprig.isLikedPost_Sprig(post_sprig: post_sprig)
        likeButton_Sprig.isSelected = isLiked_sprig
        likeButton_Sprig.tintColor = isLiked_sprig
            ? ColorConfig_Sprig.likeRed_Sprig
            : ColorConfig_Sprig.textPlaceholder_Sprig
        likeCountLabel_Sprig.textColor = isLiked_sprig
            ? ColorConfig_Sprig.likeRed_Sprig
            : ColorConfig_Sprig.textSecondary_Sprig

        // 使用 MediaDisplayView_Sprig 加载帖子封面媒体
        mediaView_Sprig.configure_Sprig(mediaPath_Sprig: post_sprig.titleMeidas_Sprig.first)

        // 使用 UserAvatarView_Sprig 展示作者头像
        avatarView_Sprig.configure_Sprig(userId_Sprig: post_sprig.titleUserId_Sprig)

        // 清空旧 badge 并重新添加
        tagContainerStack_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag_sprig in post_sprig.titleTags_Sprig.prefix(2) {
            tagContainerStack_Sprig.addArrangedSubview(makeTagBadge_Sprig(title_sprig: tag_sprig))
        }

        // 举报/删除按钮图标随归属者切换
        let isOwner_sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_sprig.titleUserId_Sprig
        )
        let btnIconName_sprig = isOwner_sprig ? "trash" : "ellipsis"
        let btnCfg_sprig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        actionBtn_Sprig.setImage(UIImage(systemName: btnIconName_sprig, withConfiguration: btnCfg_sprig), for: .normal)
    }
    
    // MARK: - 私有工具
    
    /// 创建标签 badge 视图
    private func makeTagBadge_Sprig(title_sprig: String) -> UIView {
        let container_sprig = UIView()
        container_sprig.backgroundColor = ColorConfig_Sprig.tagBackground_Sprig
        container_sprig.layer.cornerRadius = 8
        let label_sprig = UILabel()
        label_sprig.text = title_sprig
        label_sprig.font = .systemFont(ofSize: 10, weight: .medium)
        label_sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        container_sprig.addSubview(label_sprig)
        label_sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        }
        return container_sprig
    }
}

// MARK: - PostCardTableCell（TableView 包装）

/// 用于 UITableView 的 PostCardView 包装 Cell
/// 功能：将 PostCardView 嵌入 UITableViewCell，供首页/发现页等多处复用
class PostCardTableCell_Sprig: UITableViewCell {

    static let reuseId_Sprig = "PostCardTableCell_Sprig"

    /// 内部帖子卡片视图（对外暴露以设置 delegate）
    let cardView_Sprig = PostCardView_Sprig()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Sprig)
        cardView_Sprig.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 填充帖子数据
    /// 参数：post_sprig - 帖子数据模型
    func configure_Sprig(post_sprig: TitleModel_Sprig) {
        cardView_Sprig.configure_Sprig(post_sprig: post_sprig)
    }
}
