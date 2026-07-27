import UIKit
import SnapKit

// MARK: - 帖子卡片单元格

/// 帖子卡片单元格
/// 功能：展示社区帖子封面媒体（图片/视频）、分类标签、标题、作者头像/姓名及点赞数
/// 支持两种样式：homeStyle（大卡片，首页竖排）和 discoverStyle（小卡片，双列瀑布流）
/// 设计：白色圆角卡片、柔和阴影、点赞按钮带脉冲动画，触摸有弹性缩放反馈
/// 封面媒体使用 MediaDisplayView_Tidy，作者头像使用 UserAvatarView_Tidy
class PostCardCell_Tidy: UICollectionViewCell {
    
    // MARK: - 样式枚举
    
    /// 帖子卡片展示样式
    enum CardStyle_Tidy {
        case homeStyle_tidy
        case discoverStyle_tidy
    }
    
    // MARK: - 事件回调
    
    var onLikeTapped_Tidy: (() -> Void)?
    var onCardTapped_Tidy: (() -> Void)?
    /// 举报/删除按钮点击回调，携带当前帖子模型
    var onMoreTapped_Tidy: ((TitleModel_Tidy) -> Void)?
    /// 作者头像点击回调，携带作者 userId（供外部判断是否跳转用户中心）
    var onAvatarTapped_Tidy: ((Int) -> Void)?
    
    // MARK: - UI 组件
    
    /// 卡片主容器
    private let cardView_Tidy: UIView = {
        let v_tidy = UIView()
        v_tidy.backgroundColor = ColorConfig_Tidy.cardBackground_Tidy
        v_tidy.layer.cornerRadius = 16
        v_tidy.clipsToBounds = false
        return v_tidy
    }()
    
    /// 封面媒体视图（使用 MediaDisplayView_Tidy 展示图片/视频）
    private let coverMedia_Tidy: MediaDisplayView_Tidy = {
        let v = MediaDisplayView_Tidy()
        v.layer.cornerRadius = 12
        v.clipsToBounds = true
        return v
    }()

    /// 右上角举报/删除按钮（自己的帖子显示 trash，他人帖子显示 ellipsis）
    private let moreButton_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 13
        btn.tintColor = .white
        return btn
    }()

    /// 底部作者区分割线
    private let authorDivider_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        return v
    }()
    
    /// 分类标签徽章（白底+分类色文字）
    private let categoryBadge_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb_tidy.textColor = ColorConfig_Tidy.tidyMint_Tidy
        lb_tidy.textAlignment = .center
        lb_tidy.layer.cornerRadius = 8
        lb_tidy.clipsToBounds = true
        lb_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        return lb_tidy
    }()
    
    /// 帖子标题
    private let titleLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb_tidy.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb_tidy.numberOfLines = 2
        lb_tidy.lineBreakMode = .byTruncatingTail
        return lb_tidy
    }()
    
    /// 帖子简介（仅 homeStyle 显示）
    private let contentLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb_tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        lb_tidy.numberOfLines = 2
        lb_tidy.lineBreakMode = .byTruncatingTail
        return lb_tidy
    }()
    
    /// 作者头像（使用 UserAvatarView_Tidy 展示真实用户头像）
    private let authorAvatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        return v
    }()
    
    /// 作者名
    private let authorLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb_tidy
    }()
    
    /// 点赞按钮
    private let likeButton_Tidy: UIButton = {
        let btn_tidy = UIButton(type: .custom)
        btn_tidy.setImage(UIImage(systemName: "heart"), for: .normal)
        btn_tidy.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        btn_tidy.tintColor = ColorConfig_Tidy.tidyWarm_Tidy
        return btn_tidy
    }()
    
    /// 点赞数标签
    private let likeCountLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lb_tidy.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return lb_tidy
    }()

    /// 封面图底部渐变遮罩（仅发现页小卡片启用），确保浮层徽标/点赞胶囊在任意图片上都清晰可辨
    private let imageScrimView_Tidy: UIView = {
        let v = UIView()
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()
    private var imageScrimGradient_Tidy: CAGradientLayer?

    /// 点赞信息胶囊背景（叠在封面图右下角，仅发现页小卡片启用）
    private let likeChipBg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        v.layer.cornerRadius = 10
        v.isHidden = true
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - 属性
    
    private var currentPost_Tidy: TitleModel_Tidy?
    /// 记录当前生效的展示样式，供点赞状态切换等非 configure 流程复用颜色规则
    private var currentStyle_Tidy: CardStyle_Tidy = .homeStyle_tidy
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
        setupGestures_Tidy()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
        setupGestures_Tidy()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Tidy() {
        backgroundColor = .clear
        
        contentView.layer.shadowColor = ColorConfig_Tidy.shadowColor_Tidy.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 12
        contentView.layer.shadowOpacity = 1
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(cardView_Tidy)
        cardView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 封面媒体（顶部，圆角与卡片顶部匹配）
        cardView_Tidy.addSubview(coverMedia_Tidy)
        // 底部渐变遮罩作为封面媒体的子视图，自动继承其圆角裁剪
        coverMedia_Tidy.addSubview(imageScrimView_Tidy)
        setupImageScrimGradient_Tidy()
        // 分类徽章叠加在封面左上角，举报/删除按钮叠加在右上角
        cardView_Tidy.addSubview(categoryBadge_Tidy)
        cardView_Tidy.addSubview(moreButton_Tidy)
        moreButton_Tidy.addTarget(self, action: #selector(moreButtonTapped_Tidy), for: .touchUpInside)
        // 点赞胶囊背景先于点赞按钮/数量标签添加，保证层级位于其下方
        cardView_Tidy.addSubview(likeChipBg_Tidy)
        // 标题、简介、分割线
        cardView_Tidy.addSubview(titleLabel_Tidy)
        cardView_Tidy.addSubview(contentLabel_Tidy)
        cardView_Tidy.addSubview(authorDivider_Tidy)
        // 作者行
        cardView_Tidy.addSubview(authorAvatarView_Tidy)
        cardView_Tidy.addSubview(authorLabel_Tidy)
        cardView_Tidy.addSubview(likeButton_Tidy)
        cardView_Tidy.addSubview(likeCountLabel_Tidy)
        
        likeButton_Tidy.addTarget(self, action: #selector(likeTapped_Tidy), for: .touchUpInside)
        
        applyHomeStyleLayout_Tidy()
    }

    /// 搭建封面图底部渐变遮罩层（透明 → 半透明黑），仅在发现页小卡片样式下显示
    private func setupImageScrimGradient_Tidy() {
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        grad_tidy.locations = [0.0, 1.0]
        imageScrimView_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        imageScrimGradient_Tidy = grad_tidy
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageScrimGradient_Tidy?.frame = imageScrimView_Tidy.bounds
    }
    
    private func setupGestures_Tidy() {
        let tap_tidy = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Tidy))
        contentView.addGestureRecognizer(tap_tidy)
        /// 头像独立点击手势（阻止事件冒泡到卡片点击）
        let avatarTap_tidy = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Tidy))
        authorAvatarView_Tidy.isUserInteractionEnabled = true
        authorAvatarView_Tidy.addGestureRecognizer(avatarTap_tidy)
    }
    
    // MARK: - 布局方案
    
    /// 首页大卡片布局
    private func applyHomeStyleLayout_Tidy() {
        // 图内渐变遮罩与点赞胶囊仅用于发现页小卡片，首页样式下保持隐藏，不影响原有观感
        imageScrimView_Tidy.isHidden = true
        likeChipBg_Tidy.isHidden = true

        coverMedia_Tidy.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        categoryBadge_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Tidy).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        moreButton_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Tidy).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        titleLabel_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        contentLabel_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        contentLabel_Tidy.isHidden = false
        authorDivider_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(contentLabel_Tidy.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(0.5)
        }
        authorDivider_Tidy.isHidden = false
        authorAvatarView_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(authorDivider_Tidy.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-12)
        }
        authorLabel_Tidy.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Tidy)
            make.leading.equalTo(authorAvatarView_Tidy.snp.trailing).offset(6)
        }
        likeCountLabel_Tidy.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Tidy)
            make.trailing.equalToSuperview().offset(-12)
        }
        likeButton_Tidy.snp.remakeConstraints { make in
            make.centerY.equalTo(likeCountLabel_Tidy)
            make.trailing.equalTo(likeCountLabel_Tidy.snp.leading).offset(-4)
            make.width.height.equalTo(20)
        }
    }
    
    /// 发现页小卡片布局（重构版）
    /// 设计思路：加高封面图并叠加底部渐变遮罩，分类徽标与点赞胶囊直接浮层展示在图片上，
    /// 视觉信息更集中、更接近主流图片发现类 App 的卡片观感；图片下方仅保留标题与作者行，
    /// 排版更疏朗，不再需要分割线
    private func applyDiscoverStyleLayout_Tidy() {
        imageScrimView_Tidy.isHidden = false
        likeChipBg_Tidy.isHidden = false

        coverMedia_Tidy.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(148)
        }
        // 底部渐变遮罩，托底分类徽标与点赞胶囊，保证在任意封面图上都清晰可读
        imageScrimView_Tidy.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        // 分类徽标移至封面图左下角，叠在渐变遮罩上
        categoryBadge_Tidy.snp.remakeConstraints { make in
            make.leading.equalTo(coverMedia_Tidy).offset(8)
            make.bottom.equalTo(coverMedia_Tidy).offset(-8)
            make.height.equalTo(18)
        }
        moreButton_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Tidy).offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
        // 点赞胶囊：叠在封面图右下角，先确定按钮与数量标签位置，再让胶囊背景包裹二者
        likeCountLabel_Tidy.snp.remakeConstraints { make in
            make.trailing.equalTo(coverMedia_Tidy).offset(-10)
            make.bottom.equalTo(coverMedia_Tidy).offset(-8)
        }
        likeButton_Tidy.snp.remakeConstraints { make in
            make.centerY.equalTo(likeCountLabel_Tidy)
            make.trailing.equalTo(likeCountLabel_Tidy.snp.leading).offset(-3)
            make.width.height.equalTo(13)
        }
        likeChipBg_Tidy.snp.remakeConstraints { make in
            make.leading.equalTo(likeButton_Tidy).offset(-7)
            make.trailing.equalTo(likeCountLabel_Tidy).offset(7)
            make.top.equalTo(likeCountLabel_Tidy).offset(-5)
            make.bottom.equalTo(likeCountLabel_Tidy).offset(5)
        }

        titleLabel_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(coverMedia_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        contentLabel_Tidy.isHidden = true
        contentLabel_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(0)
        }
        authorDivider_Tidy.isHidden = true
        authorDivider_Tidy.snp.remakeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(titleLabel_Tidy.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        authorAvatarView_Tidy.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(18)
            make.bottom.equalToSuperview().offset(-10)
        }
        authorLabel_Tidy.snp.remakeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Tidy)
            make.leading.equalTo(authorAvatarView_Tidy.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }
    
    // MARK: - 数据绑定
    
    /// 配置帖子卡片
    /// - Parameters:
    ///   - post_tidy: 帖子模型
    ///   - style_tidy: 展示样式（默认 homeStyle）
    func configure_Tidy(post_tidy: TitleModel_Tidy, style_tidy: CardStyle_Tidy = .homeStyle_tidy) {
        currentPost_Tidy = post_tidy
        currentStyle_Tidy = style_tidy
        
        switch style_tidy {
        case .homeStyle_tidy:    applyHomeStyleLayout_Tidy()
        case .discoverStyle_tidy: applyDiscoverStyleLayout_Tidy()
        }
        
        titleLabel_Tidy.text = post_tidy.title_Tidy
        contentLabel_Tidy.text = post_tidy.titleContent_Tidy
        authorLabel_Tidy.text = post_tidy.titleUserName_Tidy
        likeCountLabel_Tidy.text = "\(post_tidy.likes_Tidy)"
        
        // 分类徽章
        let category_tidy = post_tidy.titleCategory_Tidy
        let categoryColor_tidy = ColorConfig_Tidy.colorForCategory_Tidy(category_tidy)
        categoryBadge_Tidy.text = "  \(categoryDisplayName_Tidy(category_tidy))  "
        categoryBadge_Tidy.backgroundColor = UIColor.white.withAlphaComponent(0.88)
        categoryBadge_Tidy.textColor = categoryColor_tidy

        // 分类色动态阴影
        contentView.layer.shadowColor = categoryColor_tidy.withAlphaComponent(0.22).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 5)
        contentView.layer.shadowRadius = 14

        // 使用 MediaDisplayView_Tidy 展示封面媒体（取第一个媒体路径）
        let mediaPath_tidy = post_tidy.titleMeidas_Tidy.first
        coverMedia_Tidy.configure_Tidy(mediaPath_Tidy: mediaPath_tidy, isVideo_Tidy: false)
        
        // 使用 UserAvatarView_Tidy 展示作者头像
        authorAvatarView_Tidy.configure_Tidy(userId_Tidy: post_tidy.titleUserId_Tidy)

        // 根据是否是当前用户的帖子，切换按钮图标（trash = 删除，ellipsis = 举报）
        let isMyPost_tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: post_tidy.titleUserId_Tidy
        )
        let iconName_tidy = isMyPost_tidy ? "trash" : "ellipsis"
        let iconSize_tidy: CGFloat = style_tidy == .homeStyle_tidy ? 11 : 10
        let iconCfg_tidy = UIImage.SymbolConfiguration(pointSize: iconSize_tidy, weight: .semibold)
        moreButton_Tidy.setImage(UIImage(systemName: iconName_tidy, withConfiguration: iconCfg_tidy), for: .normal)

        // 点赞状态
        let isLiked_tidy = TitleViewModel_Tidy.shared_Tidy.isLikedPost_Tidy(post_tidy: post_tidy)
        likeButton_Tidy.isSelected = isLiked_tidy
        likeCountLabel_Tidy.textColor = likeCountTextColor_Tidy(isLiked_tidy: isLiked_tidy)
    }

    /// 根据当前展示样式与点赞状态计算点赞数文字颜色
    /// 参数：
    /// - isLiked_tidy: 是否已点赞
    /// 返回值：适配当前背景的文字颜色
    /// 说明：发现页小卡片的点赞信息叠在封面图底部的深色渐变遮罩上，需使用浅色文字保证可读性；
    ///      首页大卡片仍沿用原有的浅底深字配色
    private func likeCountTextColor_Tidy(isLiked_tidy: Bool) -> UIColor {
        if isLiked_tidy { return ColorConfig_Tidy.tidyWarm_Tidy }
        return currentStyle_Tidy == .discoverStyle_tidy
            ? UIColor.white.withAlphaComponent(0.92)
            : ColorConfig_Tidy.textSecondary_Tidy
    }
    
    // MARK: - 事件处理

    /// 举报/删除按钮点击（带弹性缩放动画）
    @objc private func moreButtonTapped_Tidy() {
        guard let post_tidy = currentPost_Tidy else { return }
        UIView.animate(withDuration: 0.10, animations: {
            self.moreButton_Tidy.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.10) {
                self.moreButton_Tidy.transform = .identity
            }
        }
        onMoreTapped_Tidy?(post_tidy)
    }
    
    @objc private func likeTapped_Tidy() {
        likeButton_Tidy.animatePulse_Tidy()
        onLikeTapped_Tidy?()
        
        let isSelected_tidy = likeButton_Tidy.isSelected
        likeButton_Tidy.isSelected = !isSelected_tidy
        if let count_tidy = Int(likeCountLabel_Tidy.text ?? "0") {
            likeCountLabel_Tidy.text = "\(likeButton_Tidy.isSelected ? count_tidy + 1 : max(0, count_tidy - 1))"
        }
        likeCountLabel_Tidy.textColor = likeCountTextColor_Tidy(isLiked_tidy: likeButton_Tidy.isSelected)
    }
    
    @objc private func cardTapped_Tidy() {
        onCardTapped_Tidy?()
    }

    /// 点击作者头像回调
    @objc private func avatarTapped_Tidy() {
        guard let userId_tidy = currentPost_Tidy?.titleUserId_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onAvatarTapped_Tidy?(userId_tidy)
    }
    
    // MARK: - 触摸反馈
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animatePressDown_Tidy()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animatePressUp_Tidy()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animatePressUp_Tidy()
    }
    
    // MARK: - 工具方法
    
    private func categoryDisplayName_Tidy(_ id_tidy: String) -> String {
        switch id_tidy {
        case "living_room": return "Lighting"
        case "bedroom":     return "Pose"
        case "kitchen":     return "Composition"
        case "bathroom":    return "Outfit"
        case "study":       return "Location"
        case "storage":     return "Editing"
        case "garden":      return "Gear"
        default:            return "Photo"
        }
    }
}
