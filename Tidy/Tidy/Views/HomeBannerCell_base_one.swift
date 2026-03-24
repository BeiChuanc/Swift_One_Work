import UIKit
import FSPagerView
import SnapKit

// MARK: - 首页 Banner 分页单元格

/// 首页 FSPagerView Banner 单元格
/// 功能：展示精选帖子的封面媒体（图片/视频）、分类标签、标题、作者头像及点赞数
/// 设计：全圆角卡片 + 底部渐变遮罩 + 分类彩色徽章，营造杂志封面质感
/// 媒体展示使用 MediaDisplayView_Base_one，作者头像使用 UserAvatarView_Base_one
class HomeBannerCell_Base_one: FSPagerViewCell {
    
    // MARK: - UI 组件

    /// 封面媒体视图（图片/视频封面，填充整张卡片）
    private let coverMedia_Base_one: MediaDisplayView_Base_one = {
        let v = MediaDisplayView_Base_one()
        // 父视图 contentView 已 clipsToBounds，此处禁用自身圆角裁剪
        v.layer.cornerRadius = 0
        v.clipsToBounds = false
        return v
    }()

    /// 封面右上角大装饰圆
    private let bannerDecoCircleLg_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 80
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 封面左下角中装饰圆
    private let bannerDecoCircleMd_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 48
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 封面装饰描边环
    private let bannerDecoRing_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.16).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 52
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 底部渐变遮罩层（增强文字可读性）
    private var gradientMaskLayer_Base_one: CAGradientLayer?

    /// 右上角举报/删除按钮（自己的帖子显示 trash，他人帖子显示 ellipsis）
    private let moreButton_Base_one: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        btn.layer.cornerRadius = 14
        btn.tintColor = .white
        return btn
    }()

    // MARK: - 回调

    /// 举报/删除按钮点击回调，携带当前帖子模型
    var onMoreTapped_Base_one: ((TitleModel_Base_one) -> Void)?

    // MARK: - 私有属性

    /// 当前帖子（供按钮点击时传递）
    private var currentPost_Base_one: TitleModel_Base_one?
    
    /// 分类徽章背景视图
    private let categoryBadge_Base_one: UIView = {
        let v_base_one = UIView()
        v_base_one.layer.cornerRadius = 11
        v_base_one.clipsToBounds = true
        v_base_one.backgroundColor = UIColor.white.withAlphaComponent(0.90)
        return v_base_one
    }()

    /// 分类徽章文字
    private let categoryLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb_base_one.textColor = ColorConfig_Base_one.tidyMint_Base_one
        lb_base_one.textAlignment = .center
        return lb_base_one
    }()
    
    /// 帖子标题
    private let titleLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb_base_one.textColor = .white
        lb_base_one.numberOfLines = 2
        lb_base_one.lineBreakMode = .byTruncatingTail
        return lb_base_one
    }()
    
    /// 作者头像（使用 UserAvatarView_Base_one 展示真实用户头像）
    private let authorAvatarView_Base_one: UserAvatarView_Base_one = {
        let v = UserAvatarView_Base_one()
        return v
    }()
    
    /// 作者名
    private let authorLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_base_one.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb_base_one
    }()
    
    /// 点赞图标
    private let likeIcon_Base_one: UIImageView = {
        let iv_base_one = UIImageView()
        iv_base_one.image = UIImage(systemName: "heart.fill")
        iv_base_one.tintColor = UIColor(hexstring_Base_one: "#FF6B6B")
        iv_base_one.contentMode = .scaleAspectFit
        return iv_base_one
    }()
    
    /// 点赞数
    private let likeLabel_Base_one: UILabel = {
        let lb_base_one = UILabel()
        lb_base_one.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lb_base_one.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb_base_one
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Base_one()
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientMask_Base_one()
    }
    
    // MARK: - UI 搭建
    
    /// 搭建基础 UI 结构
    private func setupUI_Base_one() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        // 1. 封面媒体视图（最底层，填满卡片）
        contentView.addSubview(coverMedia_Base_one)
        coverMedia_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 2. 装饰元素（叠加在媒体视图上方，增强无图时视觉效果）
        contentView.addSubview(bannerDecoCircleLg_Base_one)
        contentView.addSubview(bannerDecoCircleMd_Base_one)
        contentView.addSubview(bannerDecoRing_Base_one)

        bannerDecoCircleLg_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.top.equalToSuperview().offset(-48)
            make.trailing.equalToSuperview().offset(48)
        }
        bannerDecoCircleMd_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(96)
            make.bottom.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(-24)
        }
        bannerDecoRing_Base_one.snp.makeConstraints { make in
            make.width.height.equalTo(104)
            make.trailing.equalToSuperview().offset(-22)
            make.bottom.equalToSuperview().offset(-32)
        }

        // 3. 分类徽章 + 右上角举报/删除按钮
        categoryBadge_Base_one.addSubview(categoryLabel_Base_one)
        contentView.addSubview(categoryBadge_Base_one)
        contentView.addSubview(moreButton_Base_one)

        categoryLabel_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }
        categoryBadge_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
        }
        moreButton_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.width.height.equalTo(28)
        }
        moreButton_Base_one.addTarget(self, action: #selector(moreButtonTapped_Base_one), for: .touchUpInside)
        
        // 4. 标题
        contentView.addSubview(titleLabel_Base_one)
        titleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-42)
        }
        
        // 5. 底部作者行（头像 + 名称 + 点赞）
        contentView.addSubview(authorAvatarView_Base_one)
        contentView.addSubview(authorLabel_Base_one)
        contentView.addSubview(likeIcon_Base_one)
        contentView.addSubview(likeLabel_Base_one)
        
        authorAvatarView_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.height.equalTo(22)
        }
        authorLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.leading.equalTo(authorAvatarView_Base_one.snp.trailing).offset(6)
        }
        likeLabel_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(authorAvatarView_Base_one)
            make.trailing.equalToSuperview().offset(-14)
        }
        likeIcon_Base_one.snp.makeConstraints { make in
            make.centerY.equalTo(likeLabel_Base_one)
            make.trailing.equalTo(likeLabel_Base_one.snp.leading).offset(-4)
            make.width.height.equalTo(14)
        }
    }
    
    /// 更新底部渐变遮罩（加强底部深色遮罩，让标题文字更清晰）
    private func updateGradientMask_Base_one() {
        gradientMaskLayer_Base_one?.removeFromSuperlayer()
        let mask_base_one = CAGradientLayer()
        mask_base_one.frame = contentView.bounds
        mask_base_one.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.15).cgColor,
            UIColor.black.withAlphaComponent(0.55).cgColor,
            UIColor.black.withAlphaComponent(0.80).cgColor
        ]
        mask_base_one.locations = [0.0, 0.45, 0.72, 1.0]
        mask_base_one.startPoint = CGPoint(x: 0.5, y: 0)
        mask_base_one.endPoint   = CGPoint(x: 0.5, y: 1)
        // 插入在装饰圆之上、文字之下
        contentView.layer.insertSublayer(mask_base_one, below: categoryBadge_Base_one.layer)
        gradientMaskLayer_Base_one = mask_base_one
    }
    
    // MARK: - 数据绑定
    
    /// 填充帖子数据
    /// - Parameter post_base_one: 要展示的帖子模型
    func configure_Base_one(post_base_one: TitleModel_Base_one) {
        currentPost_Base_one = post_base_one
        titleLabel_Base_one.text = post_base_one.title_Base_one
        authorLabel_Base_one.text = post_base_one.titleUserName_Base_one
        likeLabel_Base_one.text = "\(post_base_one.likes_Base_one)"
        
        // 分类徽章（白底 + 分类色文字）
        let category_base_one = post_base_one.titleCategory_Base_one
        categoryLabel_Base_one.text = categoryDisplayName_Base_one(category_base_one)
        categoryLabel_Base_one.textColor = ColorConfig_Base_one.colorForCategory_Base_one(category_base_one)

        // 分类渐变背景（作为媒体加载前的占位背景色）
        setupCategoryBackground_Base_one(category_base_one)

        // 使用 MediaDisplayView_Base_one 展示封面媒体（取第一个媒体路径）
        let mediaPath_base_one = post_base_one.titleMeidas_Base_one.first
        coverMedia_Base_one.configure_Base_one(mediaPath_Base_one: mediaPath_base_one, isVideo_Base_one: false)

        // 使用 UserAvatarView_Base_one 展示作者头像
        authorAvatarView_Base_one.configure_Base_one(userId_Base_one: post_base_one.titleUserId_Base_one)

        // 根据是否是当前用户的帖子，切换按钮图标（trash = 删除，ellipsis = 举报）
        let isMyPost_base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post_base_one.titleUserId_Base_one
        )
        let iconName_base_one = isMyPost_base_one ? "trash" : "ellipsis"
        let iconCfg_base_one = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        moreButton_Base_one.setImage(UIImage(systemName: iconName_base_one, withConfiguration: iconCfg_base_one), for: .normal)
    }

    // MARK: - 事件处理

    /// 举报/删除按钮点击（带弹性缩放动画）
    @objc private func moreButtonTapped_Base_one() {
        guard let post_base_one = currentPost_Base_one else { return }
        UIView.animate(withDuration: 0.10, animations: {
            self.moreButton_Base_one.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.10) {
                self.moreButton_Base_one.transform = .identity
            }
        }
        onMoreTapped_Base_one?(post_base_one)
    }
    
    /// 设置分类渐变背景（作为无封面图时的底色）
    private func setupCategoryBackground_Base_one(_ category_base_one: String) {
        contentView.layer.sublayers?
            .filter { $0 is CAGradientLayer && $0 !== gradientMaskLayer_Base_one }
            .forEach { $0.removeFromSuperlayer() }
        
        let bgGradient_base_one = UIColor.createCategoryGradientLayer_Base_one(
            categoryId_Base_one: category_base_one,
            frame_Base_one: contentView.bounds.isEmpty
                ? CGRect(x: 0, y: 0, width: 300, height: 200)
                : contentView.bounds
        )
        contentView.layer.insertSublayer(bgGradient_base_one, at: 0)
    }
    
    /// 根据分类 ID 返回展示名称
    private func categoryDisplayName_Base_one(_ id_base_one: String) -> String {
        switch id_base_one {
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
