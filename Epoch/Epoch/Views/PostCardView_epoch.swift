import Foundation
import UIKit
import SnapKit

// MARK: - 帖子卡片样式

/// 帖子卡片样式
enum PostCardStyle_Epoch {
    /// 首页样式
    case home_epoch
    /// 发现页样式
    case discover_epoch
}

// MARK: - 帖子卡片视图

/// 帖子卡片视图
/// 核心作用：统一展示帖子作者、媒体、标题、摘要和互动入口
/// 设计思路：首页与发现页共用同一结构，通过样式控制边距和媒体高度，减少重复 UI
/// 关键属性 / 方法：
/// - onPostTapped_Epoch: 点击卡片主体回调
/// - onUserTapped_Epoch: 点击作者信息回调
/// - onLikeTapped_Epoch: 点击点赞回调
/// - configure_Epoch: 绑定帖子模型与宿主控制器
class PostCardView_Epoch: UIControl {

    /// 内容面板
    private let containerView_Epoch = SurfaceCardView_Epoch()

    /// 轻装饰条
    private let accentStripView_Epoch = UIView()

    /// 作者头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 作者点击按钮
    private let authorButton_Epoch = UIButton(type: .custom)

    /// 作者昵称
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 作者描述
    private let metaLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    /// 媒体视图
    private let mediaView_Epoch = MediaDisplayView_Epoch()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 内容摘要
    private let contentLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 点赞按钮
    private let likeButton_Epoch = UIButton(type: .system)

    /// 评论按钮
    private let commentButton_Epoch = UIButton(type: .system)

    /// 打开按钮
    private let openButton_Epoch = UIButton(type: .system)

    /// 举报容器
    private let reportContainerView_Epoch = UIView()

    /// 当前帖子
    private var postModel_Epoch: TitleModel_Epoch?

    /// 宿主控制器
    private weak var hostViewController_Epoch: UIViewController?

    /// 举报按钮
    private var reportButton_Epoch: UIButton?

    /// 当前样式
    private let style_Epoch: PostCardStyle_Epoch

    /// 点击帖子回调
    var onPostTapped_Epoch: (() -> Void)?

    /// 点击用户回调
    var onUserTapped_Epoch: (() -> Void)?

    /// 点击点赞回调
    var onLikeTapped_Epoch: (() -> Void)?

    /// 隐藏右下角 Open 按钮
    /// - Parameter hidden_epoch: true 表示隐藏
    func setOpenButtonHidden_Epoch(_ hidden_epoch: Bool) {
        openButton_Epoch.isHidden = hidden_epoch
    }

    /// 卡片整体点击手势（兜底方案，处理 UIScrollView 延迟导致 UIControl 无法响应的场景）
    private lazy var cardTapGesture_Epoch: UITapGestureRecognizer = {
        let tap_epoch = UITapGestureRecognizer(target: self, action: #selector(postTapped_Epoch))
        tap_epoch.delegate = self
        return tap_epoch
    }()

    init(style_Epoch: PostCardStyle_Epoch = .home_epoch) {
        self.style_Epoch = style_Epoch
        super.init(frame: .zero)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定帖子数据
    /// - Parameters:
    ///   - post_epoch: 帖子模型
    ///   - hostViewController_Epoch: 宿主控制器
    func configure_Epoch(post_epoch: TitleModel_Epoch, hostViewController_Epoch: UIViewController?) {
        self.postModel_Epoch = post_epoch
        self.hostViewController_Epoch = hostViewController_Epoch
        nameLabel_Epoch.text = post_epoch.titleUserName_Epoch
        // 发现页列宽较窄，使用简短格式避免截断
        if style_Epoch == .discover_epoch {
            metaLabel_Epoch.text = "\(post_epoch.likes_Epoch) likes"
        } else {
            metaLabel_Epoch.text = "\(post_epoch.likes_Epoch) likes • \(post_epoch.reviews_Epoch.count) comments"
        }
        titleLabel_Epoch.text = post_epoch.title_Epoch
        contentLabel_Epoch.text = post_epoch.titleContent_Epoch
        avatarView_Epoch.configure_Epoch(userId_Epoch: post_epoch.titleUserId_Epoch)
        mediaView_Epoch.configure_Epoch(
            mediaPath_Epoch: post_epoch.titleMeidas_Epoch.first,
            isVideo_Epoch: isVideoMedia_Epoch(post_epoch.titleMeidas_Epoch.first)
        )
        refreshLikeState_Epoch()
        reloadReportButton_Epoch()
    }

    /// 刷新点赞态
    func refreshLikeState_Epoch() {
        guard let postModel_Epoch = postModel_Epoch else { return }
        let isLiked_epoch = UserViewModel_Epoch.shared_Epoch.isLikedByCurrentUser_Epoch(post_epoch: postModel_Epoch)
        let imageName_epoch = isLiked_epoch ? "heart.fill" : "heart"
        likeButton_Epoch.setImage(UIImage(systemName: imageName_epoch), for: .normal)
        likeButton_Epoch.tintColor = isLiked_epoch ? UIColor(hexstring_Epoch: "#F56565") : ColorConfig_Epoch.textSecondary_Epoch
        likeButton_Epoch.setTitle(" \(postModel_Epoch.likes_Epoch)", for: .normal)
    }

    /// 重载举报按钮
    private func reloadReportButton_Epoch() {
        reportButton_Epoch?.removeFromSuperview()
        guard let postModel_Epoch = postModel_Epoch,
              let hostViewController_Epoch = hostViewController_Epoch else {
            return
        }
        let button_epoch = ReportDeleteHelper_Epoch.createPostReportButton_Epoch(
            post_Epoch: postModel_Epoch,
            size_Epoch: 20,
            color_Epoch: ColorConfig_Epoch.textSecondary_Epoch,
            from: hostViewController_Epoch
        )
        reportContainerView_Epoch.addSubview(button_epoch)
        button_epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportButton_Epoch = button_epoch
    }

    /// 构建界面
    private func setupUI_Epoch() {
        backgroundColor = .clear

        authorButton_Epoch.addTarget(self, action: #selector(authorTapped_Epoch), for: .touchUpInside)
        likeButton_Epoch.addTarget(self, action: #selector(likeTapped_Epoch), for: .touchUpInside)
        commentButton_Epoch.addTarget(self, action: #selector(postTapped_Epoch), for: .touchUpInside)
        openButton_Epoch.addTarget(self, action: #selector(postTapped_Epoch), for: .touchUpInside)
        addTarget(self, action: #selector(postTapped_Epoch), for: .touchUpInside)
        // 添加整体点击手势兜底，解决 UIScrollView 吞掉 UIControl 触摸事件的问题
        containerView_Epoch.addGestureRecognizer(cardTapGesture_Epoch)

        commentButton_Epoch.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        commentButton_Epoch.setTitleColor(ColorConfig_Epoch.textSecondary_Epoch, for: .normal)
        commentButton_Epoch.tintColor = ColorConfig_Epoch.textSecondary_Epoch

        openButton_Epoch.setTitle("Open", for: .normal)
        openButton_Epoch.setTitleColor(ColorConfig_Epoch.primaryGradientStart_Epoch, for: .normal)
        openButton_Epoch.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)

        accentStripView_Epoch.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.24)
        accentStripView_Epoch.layer.cornerRadius = 4

        let textStack_epoch = UIStackView(arrangedSubviews: [nameLabel_Epoch, metaLabel_Epoch])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 2

        let headerContent_epoch = UIView()
        addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(accentStripView_Epoch)
        headerContent_epoch.addSubview(avatarView_Epoch)
        headerContent_epoch.addSubview(textStack_epoch)
        headerContent_epoch.addSubview(reportContainerView_Epoch)
        headerContent_epoch.addSubview(authorButton_Epoch)
        containerView_Epoch.addSubview(headerContent_epoch)
        containerView_Epoch.addSubview(mediaView_Epoch)
        containerView_Epoch.addSubview(titleLabel_Epoch)
        containerView_Epoch.addSubview(contentLabel_Epoch)

        let footerStack_epoch = UIStackView(arrangedSubviews: [likeButton_Epoch, commentButton_Epoch, UIView(), openButton_Epoch])
        footerStack_epoch.axis = .horizontal
        footerStack_epoch.alignment = .center
        footerStack_epoch.spacing = 12
        containerView_Epoch.addSubview(footerStack_epoch)

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        accentStripView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(18)
            make.width.equalTo(52)
            make.height.equalTo(8)
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }

        reportContainerView_Epoch.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.left.equalTo(avatarView_Epoch.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(reportContainerView_Epoch.snp.left).offset(-10)
        }

        authorButton_Epoch.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(textStack_epoch.snp.right)
        }

        let contentInset_epoch: CGFloat = style_Epoch == .home_epoch ? 18 : 14
        let mediaHeight_epoch: CGFloat = style_Epoch == .home_epoch ? 220 : 170

        headerContent_epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(contentInset_epoch + 10)
            make.left.right.equalToSuperview().inset(contentInset_epoch)
            make.height.equalTo(44)
        }

        mediaView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(headerContent_epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(contentInset_epoch)
            make.height.equalTo(mediaHeight_epoch)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(contentInset_epoch)
        }

        contentLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(contentInset_epoch)
        }

        footerStack_epoch.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(contentInset_epoch)
            make.bottom.equalToSuperview().offset(-contentInset_epoch)
            make.height.greaterThanOrEqualTo(28)
        }

        // 发现页列宽较窄，隐藏 Open 按钮，点击整卡跳转详情
        if style_Epoch == .discover_epoch {
            openButton_Epoch.isHidden = true
        }
    }

    /// 判断媒体是否为视频
    /// - Parameter mediaPath_Epoch: 媒体路径
    /// - Returns: 是否为视频
    private func isVideoMedia_Epoch(_ mediaPath_Epoch: String?) -> Bool {
        guard let mediaPath_Epoch = mediaPath_Epoch?.lowercased() else { return false }
        return mediaPath_Epoch.hasSuffix(".mov")
            || mediaPath_Epoch.hasSuffix(".mp4")
            || mediaPath_Epoch.hasSuffix(".m4v")
            || mediaPath_Epoch.contains("video")
    }

    /// 处理作者点击
    @objc private func authorTapped_Epoch() {
        onUserTapped_Epoch?()
    }

    /// 处理点赞点击
    @objc private func likeTapped_Epoch() {
        onLikeTapped_Epoch?()
    }

    /// 处理帖子点击
    @objc private func postTapped_Epoch() {
        animatePressDown_Epoch { [weak self] in
            self?.animatePressUp_Epoch()
        }
        onPostTapped_Epoch?()
    }
}

// MARK: - 手势代理（防止卡片手势与内部按钮冲突）

extension PostCardView_Epoch: UIGestureRecognizerDelegate {

    /// 判断手势是否应生效
    /// 触摸点命中 UIButton 时拒绝手势，让按钮正常响应；命中非交互区域时接受手势触发卡片导航
    /// - Parameters:
    ///   - gestureRecognizer: 手势识别器
    ///   - touch: 触摸对象
    /// - Returns: 是否允许手势接收该次触摸
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        // 通过 hitTest 找到最终命中视图，若为按钮则拒绝手势，避免双重触发
        let point_epoch = touch.location(in: self)
        let hitView_epoch = self.hitTest(point_epoch, with: nil)
        return !(hitView_epoch is UIButton)
    }
}

// MARK: - 帖子表格单元格

/// 帖子表格单元格
class PostTableViewCell_Epoch: UITableViewCell {

    /// 卡片视图
    let postCardView_Epoch = PostCardView_Epoch(style_Epoch: .home_epoch)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(postCardView_Epoch)
        postCardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 帖子瀑布流单元格

/// 帖子瀑布流单元格
class PostCollectionViewCell_Epoch: UICollectionViewCell {

    /// 卡片视图
    let postCardView_Epoch = PostCardView_Epoch(style_Epoch: .discover_epoch)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(postCardView_Epoch)
        postCardView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
