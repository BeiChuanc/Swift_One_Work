import UIKit
import FSPagerView
import SnapKit

// MARK: - 首页 Banner 分页单元格

/// 首页 FSPagerView Banner 单元格
/// 功能：展示精选帖子的封面媒体（图片/视频）、分类标签、标题、作者头像及点赞数
/// 设计：全圆角卡片 + 底部渐变遮罩 + 分类彩色徽章，营造杂志封面质感
/// 媒体展示使用 MediaDisplayView_Tidy，作者头像使用 UserAvatarView_Tidy
class HomeBannerCell_Tidy: FSPagerViewCell {
    
    // MARK: - UI 组件

    /// 封面媒体视图（图片/视频封面，填充整张卡片）
    private let coverMedia_Tidy: MediaDisplayView_Tidy = {
        let v = MediaDisplayView_Tidy()
        // 父视图 contentView 已 clipsToBounds，此处禁用自身圆角裁剪
        v.layer.cornerRadius = 0
        v.clipsToBounds = false
        return v
    }()

    /// 封面右上角大装饰圆
    private let bannerDecoCircleLg_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 80
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 封面左下角中装饰圆
    private let bannerDecoCircleMd_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 48
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 封面装饰描边环
    private let bannerDecoRing_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 52
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 底部渐变遮罩层（增强文字可读性）
    private var gradientMaskLayer_Tidy: CAGradientLayer?

    /// 右上角举报/删除按钮（自己的帖子显示 trash，他人帖子显示 ellipsis）
    private let moreButton_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 14
        btn.tintColor = .white
        return btn
    }()

    // MARK: - 回调

    /// 举报/删除按钮点击回调，携带当前帖子模型
    var onMoreTapped_Tidy: ((TitleModel_Tidy) -> Void)?

    // MARK: - 私有属性

    /// 当前帖子（供按钮点击时传递）
    private var currentPost_Tidy: TitleModel_Tidy?
    
    /// 分类徽章背景视图
    private let categoryBadge_Tidy: UIView = {
        let v_tidy = UIView()
        v_tidy.layer.cornerRadius = 11
        v_tidy.clipsToBounds = true
        v_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.90)
        return v_tidy
    }()

    /// 分类徽章文字
    private let categoryLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb_tidy.textColor = ColorConfig_Tidy.tidyMint_Tidy
        lb_tidy.textAlignment = .center
        return lb_tidy
    }()
    
    /// 帖子标题
    private let titleLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb_tidy.textColor = .white
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
        lb_tidy.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_tidy.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb_tidy
    }()
    
    /// 点赞图标
    private let likeIcon_Tidy: UIImageView = {
        let iv_tidy = UIImageView()
        iv_tidy.image = UIImage(systemName: "heart.fill")
        iv_tidy.tintColor = UIColor(hexstring_Tidy: "#FF6B6B")
        iv_tidy.contentMode = .scaleAspectFit
        return iv_tidy
    }()
    
    /// 点赞数
    private let likeLabel_Tidy: UILabel = {
        let lb_tidy = UILabel()
        lb_tidy.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_tidy.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb_tidy
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientMask_Tidy()
    }
    
    // MARK: - UI 搭建
    
    /// 搭建基础 UI 结构
    private func setupUI_Tidy() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        // 1. 封面媒体视图（最底层，填满卡片）
        contentView.addSubview(coverMedia_Tidy)
        coverMedia_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 2. 装饰元素（叠加在媒体视图上方，增强无图时视觉效果）
        contentView.addSubview(bannerDecoCircleLg_Tidy)
        contentView.addSubview(bannerDecoCircleMd_Tidy)
        contentView.addSubview(bannerDecoRing_Tidy)

        bannerDecoCircleLg_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.top.equalToSuperview().offset(-48)
            make.trailing.equalToSuperview().offset(48)
        }
        bannerDecoCircleMd_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(96)
            make.bottom.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(-24)
        }
        bannerDecoRing_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(104)
            make.trailing.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(-32)
        }

        // 3. 分类徽章 + 右上角举报/删除按钮
        categoryBadge_Tidy.addSubview(categoryLabel_Tidy)
        contentView.addSubview(categoryBadge_Tidy)
        contentView.addSubview(moreButton_Tidy)

        categoryLabel_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
        categoryBadge_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
        }
        moreButton_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.width.height.equalTo(28)
        }
        moreButton_Tidy.addTarget(self, action: #selector(moreButtonTapped_Tidy), for: .touchUpInside)
        
        // 4. 标题
        contentView.addSubview(titleLabel_Tidy)
        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-42)
        }
        
        // 5. 底部作者行（头像 + 名称 + 点赞）
        contentView.addSubview(authorAvatarView_Tidy)
        contentView.addSubview(authorLabel_Tidy)
        contentView.addSubview(likeIcon_Tidy)
        contentView.addSubview(likeLabel_Tidy)
        
        authorAvatarView_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(22)
        }
        authorLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Tidy)
            make.leading.equalTo(authorAvatarView_Tidy.snp.trailing).offset(6)
        }
        likeLabel_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Tidy)
            make.trailing.equalToSuperview().offset(-14)
        }
        likeIcon_Tidy.snp.makeConstraints { make in
            make.centerY.equalTo(likeLabel_Tidy)
            make.trailing.equalTo(likeLabel_Tidy.snp.leading).offset(-4)
            make.width.height.equalTo(14)
        }
    }
    
    /// 更新底部渐变遮罩（加强底部深色遮罩，让标题文字更清晰）
    private func updateGradientMask_Tidy() {
        gradientMaskLayer_Tidy?.removeFromSuperlayer()
        let mask_tidy = CAGradientLayer()
        mask_tidy.frame = contentView.bounds
        mask_tidy.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.80).cgColor
        ]
        mask_tidy.locations = [0.0, 0.45, 0.72, 1.0]
        mask_tidy.startPoint = CGPoint(x: 0.5, y: 0)
        mask_tidy.endPoint   = CGPoint(x: 0.5, y: 1)
        // 插入在装饰圆之上、文字之下
        contentView.layer.insertSublayer(mask_tidy, below: categoryBadge_Tidy.layer)
        gradientMaskLayer_Tidy = mask_tidy
    }
    
    // MARK: - 数据绑定
    
    /// 填充帖子数据
    /// - Parameter post_tidy: 要展示的帖子模型
    func configure_Tidy(post_tidy: TitleModel_Tidy) {
        currentPost_Tidy = post_tidy
        titleLabel_Tidy.text = post_tidy.title_Tidy
        authorLabel_Tidy.text = post_tidy.titleUserName_Tidy
        likeLabel_Tidy.text = "\(post_tidy.likes_Tidy)"
        
        // 分类徽章（白底 + 分类色文字）
        let category_tidy = post_tidy.titleCategory_Tidy
        categoryLabel_Tidy.text = categoryDisplayName_Tidy(category_tidy)
        categoryLabel_Tidy.textColor = ColorConfig_Tidy.colorForCategory_Tidy(category_tidy)

        // 分类渐变背景（作为媒体加载前的占位背景色）
        setupCategoryBackground_Tidy(category_tidy)

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
        let iconCfg_tidy = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        moreButton_Tidy.setImage(UIImage(systemName: iconName_tidy, withConfiguration: iconCfg_tidy), for: .normal)
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
    
    /// 设置分类渐变背景（作为无封面图时的底色）
    private func setupCategoryBackground_Tidy(_ category_tidy: String) {
        contentView.layer.sublayers?
            .filter { $0 is CAGradientLayer && $0 !== gradientMaskLayer_Tidy }
            .forEach { $0.removeFromSuperlayer() }
        
        let bgGradient_tidy = UIColor.createCategoryGradientLayer_Tidy(
            categoryId_Tidy: category_tidy,
            frame_Tidy: contentView.bounds.isEmpty
                ? CGRect(x: 0, y: 0, width: 300, height: 200)
                : contentView.bounds
        )
        contentView.layer.insertSublayer(bgGradient_tidy, at: 0)
    }
    
    /// 根据分类 ID 返回展示名称
    private func categoryDisplayName_Tidy(_ id_tidy: String) -> String {
        switch id_tidy {
        case "living_room": return "Living Room"
        case "bedroom":     return "Bedroom"
        case "kitchen":     return "Kitchen"
        case "bathroom":    return "Bathroom"
        case "study":       return "Study"
        case "storage":     return "Storage"
        case "garden":      return "Garden"
        default:            return "Home"
        }
    }
}
