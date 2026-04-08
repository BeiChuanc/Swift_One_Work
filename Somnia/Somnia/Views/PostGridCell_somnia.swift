import Foundation
import UIKit
import SnapKit

// MARK: - 发现页帖子网格 Cell

/// 发现页双列瀑布流帖子 Cell
/// 核心功能：紧凑型卡片，展示媒体封面、标题、点赞数及举报/删除操作
/// 设计理念：圆角卡片 + MediaDisplayView 媒体展示 + 底部毛玻璃标题条 + 右上角举报按钮
/// 关键方法：configure_Somnia / onLikeTapped_Somnia / onReportTapped_Somnia
class PostGridCell_Somnia: UICollectionViewCell {

    // MARK: - 静态标识

    /// Cell 复用标识符
    static let reuseId_Somnia = "PostGridCell_Somnia"

    // MARK: - 回调

    /// 点赞按钮点击回调
    var onLikeTapped_Somnia: (() -> Void)?

    /// 举报/删除按钮点击回调（由外部 VC 设置，通过 ReportDeleteHelper 处理）
    var onReportTapped_Somnia: (() -> Void)?

    /// 左上角头像点击回调（由外部 VC 设置，跳转用户中心）
    var onAvatarTapped_Somnia: (() -> Void)?

    // MARK: - 私有 UI 属性

    /// 卡片背景容器（圆角 + 裁切）
    private let cardView_Somnia = UIView()

    /// 媒体展示视图（支持图片/视频缩略图/占位渐变）
    private let mediaView_Somnia = MediaDisplayView_Somnia()

    /// 左上角作者头像（白边圆形，点击进入用户中心）
    private let avatarView_Somnia: UserAvatarView_Somnia = {
        let v = UserAvatarView_Somnia()
        // 固定圆角 + clipsToBounds，确保首次渲染即为圆形
        // （不依赖 layoutSubviews 时序，shadow 与 clipsToBounds 冲突故不使用）
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 2
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 右上角举报/删除菜单按钮
    private let reportButton_Somnia: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        btn.layer.cornerRadius = 13
        btn.clipsToBounds = true
        return btn
    }()

    /// 底部信息叠层（毛玻璃）
    private let infoOverlay_Somnia: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemUltraThinMaterialLight)
        return UIVisualEffectView(effect: blur)
    }()

    /// 帖子标题
    private let titleLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = ColorConfig_Somnia.textPrimary_Somnia
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 作者名称
    private let authorLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        return lbl
    }()

    /// 点赞按钮
    private let likeButton_Somnia = UIButton(type: .custom)

    /// 点赞数标签
    private let likeCountLabel_Somnia: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = ColorConfig_Somnia.textSecondary_Somnia
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
        setupConstraints_Somnia()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - UI 构建

    /// 初始化所有子视图及样式
    private func setupUI_Somnia() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        // 卡片容器：圆角裁切
        cardView_Somnia.layer.cornerRadius = 18
        cardView_Somnia.clipsToBounds = true
        cardView_Somnia.backgroundColor = .white
        contentView.addSubview(cardView_Somnia)

        // 媒体视图：填满卡片，内部处理图片/视频/占位
        mediaView_Somnia.layer.cornerRadius = 0
        cardView_Somnia.addSubview(mediaView_Somnia)

        // 左上角作者头像（叠加在媒体上方）
        cardView_Somnia.addSubview(avatarView_Somnia)
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Somnia))
        avatarView_Somnia.addGestureRecognizer(tap_Somnia)

        // 举报按钮：叠加在媒体右上角
        cardView_Somnia.addSubview(reportButton_Somnia)
        reportButton_Somnia.addAction(UIAction { [weak self] _ in
            self?.onReportTapped_Somnia?()
        }, for: .touchUpInside)

        // 底部毛玻璃信息层
        cardView_Somnia.addSubview(infoOverlay_Somnia)

        // 标题
        infoOverlay_Somnia.contentView.addSubview(titleLabel_Somnia)

        // 作者
        infoOverlay_Somnia.contentView.addSubview(authorLabel_Somnia)

        // 点赞按钮
        likeButton_Somnia.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton_Somnia.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        likeButton_Somnia.tintColor = ColorConfig_Somnia.secondaryGradientStart_Somnia
        likeButton_Somnia.addTarget(self, action: #selector(likeTapped_Somnia), for: .touchUpInside)
        infoOverlay_Somnia.contentView.addSubview(likeButton_Somnia)

        // 点赞数
        infoOverlay_Somnia.contentView.addSubview(likeCountLabel_Somnia)

        // 卡片阴影（品牌紫色调）
        layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6", alpha_Somnia: 0.18).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 14
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

    // MARK: - 约束布局

    /// 设置 SnapKit 约束
    private func setupConstraints_Somnia() {
        cardView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 媒体视图填满整个卡片
        mediaView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 左上角头像：36×36pt，距左上角 8pt
        avatarView_Somnia.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(36)
        }

        // 举报按钮：距右上角 8pt
        reportButton_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }

        // 底部毛玻璃层：高度 78pt
        infoOverlay_Somnia.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(cardView_Somnia)
            make.height.equalTo(78)
        }

        titleLabel_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        authorLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel_Somnia)
            make.trailing.lessThanOrEqualTo(likeButton_Somnia.snp.leading).offset(-4)
        }

        likeButton_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(20)
        }

        likeCountLabel_Somnia.snp.makeConstraints { make in
            make.trailing.equalTo(likeButton_Somnia.snp.leading).offset(-3)
            make.centerY.equalTo(likeButton_Somnia)
        }
    }

    // MARK: - 数据绑定

    /// 配置 Cell 数据
    /// - Parameters:
    ///   - post_Somnia: 帖子数据模型
    ///   - isLiked_Somnia: 当前用户是否已点赞
    func configure_Somnia(post_Somnia: TitleModel_Somnia, isLiked_Somnia: Bool) {
        titleLabel_Somnia.text = post_Somnia.title_Somnia
        authorLabel_Somnia.text = post_Somnia.titleUserName_Somnia
        likeCountLabel_Somnia.text = "\(post_Somnia.likes_Somnia)"
        likeButton_Somnia.isSelected = isLiked_Somnia
        likeButton_Somnia.tintColor = isLiked_Somnia
            ? ColorConfig_Somnia.secondaryGradientStart_Somnia
            : ColorConfig_Somnia.textPlaceholder_Somnia

        // 加载作者头像
        avatarView_Somnia.configure_Somnia(userId_Somnia: post_Somnia.titleUserId_Somnia)

        // 使用 MediaDisplayView 加载媒体（图片/视频/占位均由组件内部处理）
        let mediaPath_Somnia = post_Somnia.titleMeidas_Somnia.first ?? ""
        let isVideo_Somnia = mediaPath_Somnia.hasSuffix(".mp4") || mediaPath_Somnia.hasSuffix(".mov")
        mediaView_Somnia.configure_Somnia(
            mediaPath_Somnia: mediaPath_Somnia.isEmpty ? nil : mediaPath_Somnia,
            isVideo_Somnia: isVideo_Somnia
        )
    }

    // MARK: - 事件响应

    /// 点赞按钮点击
    @objc private func likeTapped_Somnia() {
        likeButton_Somnia.animatePulse_Somnia()
        onLikeTapped_Somnia?()
    }

    /// 头像点击：弹簧缩放反馈 + 触发外部跳转回调
    @objc private func avatarTapped_Somnia() {
        UIView.animate(
            withDuration: 0.12,
            animations: { self.avatarView_Somnia.transform = CGAffineTransform(scaleX: 0.88, y: 0.88) },
            completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5,
                               initialSpringVelocity: 6, options: [], animations: {
                    self.avatarView_Somnia.transform = .identity
                })
            }
        )
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Somnia?()
    }

    // MARK: - 触摸动画

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        cardView_Somnia.animatePressDown_Somnia()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cardView_Somnia.animatePressUp_Somnia()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cardView_Somnia.animatePressUp_Somnia()
    }
}
