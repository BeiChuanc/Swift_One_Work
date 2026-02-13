import Foundation
import UIKit
import SnapKit
import Kingfisher

// MARK: 推荐卡片视图

/// 推荐卡片视图
/// 功能：展示今日推荐的彩绘作品
/// 特性：渐变背景、毛玻璃效果、难度标签、复刻率进度条
class RecommendationCard_Glasspaint: UIView {
    
    // MARK: - UI属性
    
    /// 卡片容器
    private let cardContainer_Glasspaint = UIView()
    
    /// 渐变背景层
    private let gradientLayer_Glasspaint = CAGradientLayer()
    
    /// 毛玻璃效果层
    private let blurEffectView_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    
    /// 作品图片容器
    private let imageContainer_Glasspaint = UIView()
    
    /// 作品图片
    private let artworkImageView_Glasspaint = UIImageView()
    
    /// 图片遮罩渐变
    private let imageMaskLayer_Glasspaint = CAGradientLayer()
    
    /// 收藏按钮
    private let favoriteButton_Glasspaint = UIButton(type: .system)
    
    /// 信息容器
    private let infoContainer_Glasspaint = UIView()
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 作者信息容器
    private let authorContainer_Glasspaint = UIView()
    
    /// 作者头像
    private let authorAvatar_Glasspaint = UIImageView()
    
    /// 作者名称
    private let authorLabel_Glasspaint = UILabel()
    
    /// 难度标签
    private let levelTag_Glasspaint = PaintingTagView_Glasspaint()
    
    /// 风格标签
    private let styleTag_Glasspaint = PaintingTagView_Glasspaint()
    
    /// 载体标签
    private let carrierTag_Glasspaint = PaintingTagView_Glasspaint()
    
    /// 复刻率容器
    private let replicationContainer_Glasspaint = UIView()
    
    /// 复刻率图标
    private let replicationIcon_Glasspaint = UIImageView()
    
    /// 复刻率标签
    private let replicationLabel_Glasspaint = UILabel()
    
    /// 复刻率进度条
    private let progressBar_Glasspaint = ReplicationProgressBar_Glasspaint()
    
    /// 统计容器
    private let statsContainer_Glasspaint = UIView()
    
    /// 点赞图标
    private let likeIcon_Glasspaint = UIImageView()
    
    /// 点赞数
    private let likeLabel_Glasspaint = UILabel()
    
    /// 评论图标
    private let commentIcon_Glasspaint = UIImageView()
    
    /// 评论数
    private let commentLabel_Glasspaint = UILabel()
    
    // MARK: - 数据属性
    
    /// 作品数据
    private var post_Glasspaint: TitleModel_Glasspaint?
    
    /// 点击回调
    var onTap_Glasspaint: ((TitleModel_Glasspaint) -> Void)?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 卡片容器
        addSubview(cardContainer_Glasspaint)
        cardContainer_Glasspaint.backgroundColor = .clear
        cardContainer_Glasspaint.layer.cornerRadius = 20
        cardContainer_Glasspaint.layer.masksToBounds = false
        
        // 阴影设置
        layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.3
        layer.cornerRadius = 20
        
        // 毛玻璃背景
        cardContainer_Glasspaint.addSubview(blurEffectView_Glasspaint)
        blurEffectView_Glasspaint.layer.cornerRadius = 20
        blurEffectView_Glasspaint.layer.masksToBounds = true
        
        // 渐变背景层（放在毛玻璃上）
        gradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.2).cgColor
        ]
        gradientLayer_Glasspaint.cornerRadius = 20
        blurEffectView_Glasspaint.layer.addSublayer(gradientLayer_Glasspaint)
        
        // 作品图片容器
        cardContainer_Glasspaint.addSubview(imageContainer_Glasspaint)
        imageContainer_Glasspaint.backgroundColor = .clear
        imageContainer_Glasspaint.layer.cornerRadius = 16
        imageContainer_Glasspaint.layer.masksToBounds = true
        
        // 作品图片
        imageContainer_Glasspaint.addSubview(artworkImageView_Glasspaint)
        artworkImageView_Glasspaint.contentMode = .scaleAspectFill
        artworkImageView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint
        
        // 图片底部渐变遮罩
        imageMaskLayer_Glasspaint.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        imageMaskLayer_Glasspaint.locations = [0.6, 1.0]
        artworkImageView_Glasspaint.layer.addSublayer(imageMaskLayer_Glasspaint)
        
        // 收藏按钮（悬浮在图片上）
        imageContainer_Glasspaint.addSubview(favoriteButton_Glasspaint)
        favoriteButton_Glasspaint.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favoriteButton_Glasspaint.tintColor = .white
        favoriteButton_Glasspaint.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        favoriteButton_Glasspaint.layer.cornerRadius = 18
        favoriteButton_Glasspaint.addTarget(self, action: #selector(handleFavoriteTap_Glasspaint), for: .touchUpInside)
        
        // 信息容器
        cardContainer_Glasspaint.addSubview(infoContainer_Glasspaint)
        infoContainer_Glasspaint.backgroundColor = .clear
        
        // 标题
        infoContainer_Glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        titleLabel_Glasspaint.numberOfLines = 2
        titleLabel_Glasspaint.lineBreakMode = .byTruncatingTail
        titleLabel_Glasspaint.setContentHuggingPriority(.required, for: .vertical)
        titleLabel_Glasspaint.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel_Glasspaint.adjustsFontSizeToFitWidth = false
        
        // 作者信息容器
        infoContainer_Glasspaint.addSubview(authorContainer_Glasspaint)
        authorContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.withAlphaComponent(0.5)
        authorContainer_Glasspaint.layer.cornerRadius = 12
        authorContainer_Glasspaint.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // 作者头像
        authorContainer_Glasspaint.addSubview(authorAvatar_Glasspaint)
        authorAvatar_Glasspaint.contentMode = .scaleAspectFill
        authorAvatar_Glasspaint.layer.cornerRadius = 10
        authorAvatar_Glasspaint.layer.masksToBounds = true
        authorAvatar_Glasspaint.backgroundColor = ColorConfig_Glasspaint.divider_Glasspaint
        
        // 作者名称
        authorContainer_Glasspaint.addSubview(authorLabel_Glasspaint)
        authorLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        authorLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        authorLabel_Glasspaint.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // 标签容器
        let tagsStack_glasspaint = UIStackView(arrangedSubviews: [levelTag_Glasspaint, styleTag_Glasspaint, carrierTag_Glasspaint])
        infoContainer_Glasspaint.addSubview(tagsStack_glasspaint)
        tagsStack_glasspaint.axis = .horizontal
        tagsStack_glasspaint.spacing = 6
        tagsStack_glasspaint.distribution = .equalSpacing
        tagsStack_glasspaint.alignment = .center
        
        // 复刻率容器
        infoContainer_Glasspaint.addSubview(replicationContainer_Glasspaint)
        replicationContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.highReplicationColor_Glasspaint.withAlphaComponent(0.1)
        replicationContainer_Glasspaint.layer.cornerRadius = 8
        
        // 复刻率图标
        replicationContainer_Glasspaint.addSubview(replicationIcon_Glasspaint)
        replicationIcon_Glasspaint.image = UIImage(systemName: "star.fill")
        replicationIcon_Glasspaint.tintColor = ColorConfig_Glasspaint.highReplicationColor_Glasspaint
        replicationIcon_Glasspaint.contentMode = .scaleAspectFit
        
        // 复刻率标签
        replicationContainer_Glasspaint.addSubview(replicationLabel_Glasspaint)
        replicationLabel_Glasspaint.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        replicationLabel_Glasspaint.textColor = ColorConfig_Glasspaint.highReplicationColor_Glasspaint
        replicationLabel_Glasspaint.text = "Easy to Replicate"
        replicationLabel_Glasspaint.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // 复刻率进度条
        infoContainer_Glasspaint.addSubview(progressBar_Glasspaint)
        progressBar_Glasspaint.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // 统计容器
        infoContainer_Glasspaint.addSubview(statsContainer_Glasspaint)
        statsContainer_Glasspaint.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // 点赞统计
        statsContainer_Glasspaint.addSubview(likeIcon_Glasspaint)
        likeIcon_Glasspaint.image = UIImage(systemName: "heart.fill")
        likeIcon_Glasspaint.tintColor = ColorConfig_Glasspaint.styleCuteColor_Glasspaint
        likeIcon_Glasspaint.contentMode = .scaleAspectFit
        
        statsContainer_Glasspaint.addSubview(likeLabel_Glasspaint)
        likeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likeLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 评论统计
        statsContainer_Glasspaint.addSubview(commentIcon_Glasspaint)
        commentIcon_Glasspaint.image = UIImage(systemName: "bubble.left.fill")
        commentIcon_Glasspaint.tintColor = ColorConfig_Glasspaint.levelIntermediateColor_Glasspaint
        commentIcon_Glasspaint.contentMode = .scaleAspectFit
        
        statsContainer_Glasspaint.addSubview(commentLabel_Glasspaint)
        commentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 布局
        cardContainer_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        blurEffectView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainer_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
            make.height.equalTo(180)
        }
        
        artworkImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        favoriteButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(12)
            make.width.height.equalTo(36)
        }
        
        infoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(imageContainer_Glasspaint.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(14)
            make.bottom.lessThanOrEqualToSuperview().offset(-14).priority(.high)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(38) // 确保至少可以显示2行文字（15*2 + 行间距）
        }
        
        authorContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(6)
            make.left.equalToSuperview()
        }
        
        authorAvatar_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(4)
            make.width.height.equalTo(20)
        }
        
        authorLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar_Glasspaint.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        
        tagsStack_glasspaint.snp.makeConstraints { make in
            make.top.equalTo(authorContainer_Glasspaint.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }
        
        replicationContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(tagsStack_glasspaint.snp.bottom).offset(10)
            make.left.equalToSuperview()
        }
        
        replicationIcon_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(4)
            make.width.height.equalTo(12)
        }
        
        replicationLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(replicationIcon_Glasspaint.snp.right).offset(4)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-8)
        }
        
        progressBar_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(replicationContainer_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        statsContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(progressBar_Glasspaint.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        likeIcon_Glasspaint.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        likeLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(likeIcon_Glasspaint.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        commentIcon_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(likeLabel_Glasspaint.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        commentLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(commentIcon_Glasspaint.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        // 添加点击手势
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(handleTap_Glasspaint))
        cardContainer_Glasspaint.addGestureRecognizer(tapGesture_glasspaint)
        cardContainer_Glasspaint.isUserInteractionEnabled = true
    }
    
    // MARK: - 配置
    
    /// 配置卡片
    /// 参数：
    /// - post_glasspaint: 作品数据
    func configure_Glasspaint(with_glasspaint post_glasspaint: TitleModel_Glasspaint) {
        self.post_Glasspaint = post_glasspaint
        
        // 设置标题
        titleLabel_Glasspaint.text = post_glasspaint.title_Glasspaint
        
        // 设置作者信息
        authorLabel_Glasspaint.text = "by \(post_glasspaint.titleUserName_Glasspaint)"
        
        // 设置作者头像（使用默认图标）
        authorAvatar_Glasspaint.image = UIImage(systemName: "person.circle.fill")
        authorAvatar_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 设置图片
        if let mediaUrl_glasspaint = post_glasspaint.titleMeidas_Glasspaint.first {
            // 如果是网络URL
            if let url_glasspaint = URL(string: mediaUrl_glasspaint), mediaUrl_glasspaint.hasPrefix("http") {
                artworkImageView_Glasspaint.kf.setImage(with: url_glasspaint, placeholder: UIImage(systemName: "photo.fill"))
            } else {
                // 本地图片或Assets图片
                artworkImageView_Glasspaint.image = UIImage(named: mediaUrl_glasspaint) ?? UIImage(systemName: "photo.fill")
                artworkImageView_Glasspaint.tintColor = ColorConfig_Glasspaint.divider_Glasspaint
            }
        }
        
        // 设置标签
        levelTag_Glasspaint.configure_Glasspaint(with_glasspaint: .level_glasspaint(post_glasspaint.paintingLevel_Glasspaint))
        styleTag_Glasspaint.configure_Glasspaint(with_glasspaint: .style_glasspaint(post_glasspaint.paintingStyle_Glasspaint))
        carrierTag_Glasspaint.configure_Glasspaint(with_glasspaint: .carrier_glasspaint(post_glasspaint.carrier_Glasspaint))
        
        // 设置统计数据
        likeLabel_Glasspaint.text = "\(post_glasspaint.likes_Glasspaint)"
        commentLabel_Glasspaint.text = "\(post_glasspaint.reviews_Glasspaint.count)"
        
        // 设置复刻率
        progressBar_Glasspaint.setProgress_Glasspaint(progress_glasspaint: post_glasspaint.replicationRate_Glasspaint, animated_glasspaint: true)
        
        // 根据风格设置渐变色
        updateGradientColors_Glasspaint(style_glasspaint: post_glasspaint.paintingStyle_Glasspaint)
    }
    
    /// 更新渐变颜色
    /// 参数：
    /// - style_glasspaint: 风格类型
    private func updateGradientColors_Glasspaint(style_glasspaint: PaintingStyle_Glasspaint) {
        let startColor_glasspaint: UIColor
        let endColor_glasspaint: UIColor
        
        switch style_glasspaint {
        case .minimalist_glasspaint:
            startColor_glasspaint = ColorConfig_Glasspaint.styleMinimalistColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint
        case .retro_glasspaint:
            startColor_glasspaint = ColorConfig_Glasspaint.styleRetroColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.secondaryGradientEnd_Glasspaint
        case .cute_glasspaint:
            startColor_glasspaint = ColorConfig_Glasspaint.styleCuteColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint
        case .modern_glasspaint:
            startColor_glasspaint = ColorConfig_Glasspaint.styleModernColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint
        case .artistic_glasspaint:
            startColor_glasspaint = ColorConfig_Glasspaint.styleArtisticColor_Glasspaint
            endColor_glasspaint = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        }
        
        gradientLayer_Glasspaint.colors = [
            startColor_glasspaint.cgColor,
            endColor_glasspaint.cgColor
        ]
    }
    
    // MARK: - 交互
    
    /// 处理卡片点击
    @objc private func handleTap_Glasspaint() {
        guard let post_glasspaint = post_Glasspaint else { return }
        
        // 卡片缩放动画
        animatePressDown_Glasspaint {
            self.animatePressUp_Glasspaint()
        }
        
        // 触发回调
        onTap_Glasspaint?(post_glasspaint)
    }
    
    /// 处理收藏按钮点击
    @objc private func handleFavoriteTap_Glasspaint() {
        guard let post_glasspaint = post_Glasspaint else { return }
        
        // 脉冲动画
        favoriteButton_Glasspaint.animatePulse_Glasspaint()
        
        // 点赞操作
        TitleViewModel_Glasspaint.shared_Glasspaint.likePost_Glasspaint(post_glasspaint: post_glasspaint)
        
        // 更新图标
        let isLiked_glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.isLikedPost_Glasspaint(post_glasspaint: post_glasspaint)
        let iconName_glasspaint = isLiked_glasspaint ? "heart.fill" : "heart"
        favoriteButton_Glasspaint.setImage(UIImage(systemName: iconName_glasspaint), for: .normal)
    }
    
    // MARK: - 布局
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Glasspaint.frame = blurEffectView_Glasspaint.bounds
        imageMaskLayer_Glasspaint.frame = artworkImageView_Glasspaint.bounds
        
        // 更新阴影路径以提高性能
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 20
        ).cgPath
    }
}
