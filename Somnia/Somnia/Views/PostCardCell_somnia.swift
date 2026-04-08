import Foundation
import UIKit
import SnapKit

// MARK: - 首页帖子卡片Cell

/// 首页帖子卡片 Cell
/// 核心功能：展示帖子作者头像、标题、内容摘要、点赞数与评论数
/// 设计理念：白色磨砂卡片 + 薰衣草紫渐变点缀，配合弹性进场动画
/// 关键方法：configure_Somnia / onLikeTapped_Somnia
class PostCardCell_Somnia: UITableViewCell {
    
    // MARK: - 静态标识
    
    /// Cell 复用标识符
    static let reuseId_Somnia = "PostCardCell_Somnia"
    
    // MARK: - 回调
    
    /// 点赞按钮点击回调
    var onLikeTapped_Somnia: (() -> Void)?
    
    /// 头像点击回调
    var onAvatarTapped_Somnia: (() -> Void)?
    
    // MARK: - 私有 UI 属性
    
    /// 卡片容器视图
    private let cardView_Somnia = UIView()
    
    /// 渐变色装饰条（左侧）
    private let accentBar_Somnia = UIView()
    
    /// 封面占位图（渐变背景 + 系统图标）
    private let coverContainer_Somnia = UIView()
    private let coverIcon_Somnia = UIImageView()
    private var coverGradientLayer_Somnia: CAGradientLayer?
    
    /// 作者头像
    private let avatarView_Somnia = UIView()
    private let avatarIcon_Somnia = UIImageView()
    
    /// 作者名称
    private let authorLabel_Somnia = UILabel()
    
    /// 帖子标题
    private let titleLabel_Somnia = UILabel()
    
    /// 帖子内容摘要
    private let contentLabel_Somnia = UILabel()
    
    /// 底部操作栏
    private let bottomBar_Somnia = UIView()
    
    /// 点赞按钮
    private let likeButton_Somnia = UIButton(type: .custom)
    
    /// 点赞数标签
    private let likeCountLabel_Somnia = UILabel()
    
    /// 评论图标
    private let commentIcon_Somnia = UIImageView()
    
    /// 评论数标签
    private let commentCountLabel_Somnia = UILabel()
    
    // MARK: - 初始化
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Somnia()
        setupConstraints_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 更新渐变层尺寸
        coverGradientLayer_Somnia?.frame = coverContainer_Somnia.bounds
    }
    
    // MARK: - UI 构建
    
    /// 初始化所有子视图样式
    private func setupUI_Somnia() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 卡片容器
        cardView_Somnia.backgroundColor = .white
        cardView_Somnia.layer.cornerRadius = 20
        cardView_Somnia.layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6", alpha_Somnia: 0.18).cgColor
        cardView_Somnia.layer.shadowOffset = CGSize(width: 0, height: 6)
        cardView_Somnia.layer.shadowRadius = 16
        cardView_Somnia.layer.shadowOpacity = 1
        cardView_Somnia.layer.masksToBounds = false
        contentView.addSubview(cardView_Somnia)
        
        // 左侧装饰条（主渐变）
        accentBar_Somnia.layer.cornerRadius = 3
        accentBar_Somnia.clipsToBounds = true
        cardView_Somnia.addSubview(accentBar_Somnia)
        
        // 封面容器（圆角正方形）
        coverContainer_Somnia.layer.cornerRadius = 16
        coverContainer_Somnia.clipsToBounds = true
        cardView_Somnia.addSubview(coverContainer_Somnia)
        
        // 渐变背景
        let grad_Somnia = UIColor.createPrimaryGradientLayer_Somnia(frame_Somnia: .zero)
        grad_Somnia.cornerRadius = 16
        coverContainer_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        coverGradientLayer_Somnia = grad_Somnia
        
        // 封面系统图标
        coverIcon_Somnia.image = UIImage(systemName: "moon.stars.fill")
        coverIcon_Somnia.tintColor = .white.withAlphaComponent(0.9)
        coverIcon_Somnia.contentMode = .scaleAspectFit
        coverContainer_Somnia.addSubview(coverIcon_Somnia)
        
        // 作者头像容器
        avatarView_Somnia.layer.cornerRadius = 14
        avatarView_Somnia.clipsToBounds = true
        avatarView_Somnia.isUserInteractionEnabled = true
        let avatarTap_Somnia = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Somnia))
        avatarView_Somnia.addGestureRecognizer(avatarTap_Somnia)
        cardView_Somnia.addSubview(avatarView_Somnia)
        
        // 头像图标
        avatarIcon_Somnia.image = UIImage(systemName: "person.crop.circle.fill")
        avatarIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        avatarIcon_Somnia.contentMode = .scaleAspectFill
        avatarView_Somnia.addSubview(avatarIcon_Somnia)
        
        // 作者名称
        authorLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        authorLabel_Somnia.textColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        cardView_Somnia.addSubview(authorLabel_Somnia)
        
        // 标题
        titleLabel_Somnia.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        titleLabel_Somnia.numberOfLines = 1
        cardView_Somnia.addSubview(titleLabel_Somnia)
        
        // 内容摘要
        contentLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        contentLabel_Somnia.numberOfLines = 2
        contentLabel_Somnia.lineBreakMode = .byTruncatingTail
        cardView_Somnia.addSubview(contentLabel_Somnia)
        
        // 底部操作区
        cardView_Somnia.addSubview(bottomBar_Somnia)
        
        // 点赞按钮
        likeButton_Somnia.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton_Somnia.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        likeButton_Somnia.tintColor = ColorConfig_Somnia.secondaryGradientStart_Somnia
        likeButton_Somnia.addTarget(self, action: #selector(likeTapped_Somnia), for: .touchUpInside)
        bottomBar_Somnia.addSubview(likeButton_Somnia)
        
        // 点赞数
        likeCountLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        likeCountLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        bottomBar_Somnia.addSubview(likeCountLabel_Somnia)
        
        // 评论图标
        commentIcon_Somnia.image = UIImage(systemName: "bubble.left")
        commentIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientEnd_Somnia
        commentIcon_Somnia.contentMode = .scaleAspectFit
        bottomBar_Somnia.addSubview(commentIcon_Somnia)
        
        // 评论数
        commentCountLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        commentCountLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        bottomBar_Somnia.addSubview(commentCountLabel_Somnia)
        
        // 装饰条渐变
        setupAccentBarGradient_Somnia()
    }
    
    /// 设置左侧装饰条渐变色
    private func setupAccentBarGradient_Somnia() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let grad_Somnia = UIColor.createPrimaryGradientLayer_Somnia(
                frame_Somnia: CGRect(x: 0, y: 0, width: 6, height: 80)
            )
            grad_Somnia.startPoint = CGPoint(x: 0.5, y: 0)
            grad_Somnia.endPoint = CGPoint(x: 0.5, y: 1)
            grad_Somnia.cornerRadius = 3
            self.accentBar_Somnia.layer.insertSublayer(grad_Somnia, at: 0)
        }
    }
    
    // MARK: - 约束布局
    
    /// 设置 SnapKit 约束
    private func setupConstraints_Somnia() {
        cardView_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        accentBar_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(60)
        }
        
        coverContainer_Somnia.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(72)
        }
        
        coverIcon_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        avatarView_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(accentBar_Somnia.snp.trailing).offset(14)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }
        
        avatarIcon_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        authorLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Somnia.snp.trailing).offset(8)
            make.centerY.equalTo(avatarView_Somnia)
            make.trailing.lessThanOrEqualTo(coverContainer_Somnia.snp.leading).offset(-8)
        }
        
        titleLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(avatarView_Somnia.snp.leading)
            make.top.equalTo(avatarView_Somnia.snp.bottom).offset(8)
            make.trailing.lessThanOrEqualTo(coverContainer_Somnia.snp.leading).offset(-8)
        }
        
        contentLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Somnia)
            make.top.equalTo(titleLabel_Somnia.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(coverContainer_Somnia.snp.leading).offset(-8)
        }
        
        bottomBar_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel_Somnia)
            make.bottom.equalToSuperview().offset(-14)
            make.top.equalTo(contentLabel_Somnia.snp.bottom).offset(10)
            make.trailing.lessThanOrEqualTo(coverContainer_Somnia.snp.leading).offset(-8)
        }
        
        likeButton_Somnia.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        likeCountLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(likeButton_Somnia.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        
        commentIcon_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(likeCountLabel_Somnia.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        commentCountLabel_Somnia.snp.makeConstraints { make in
            make.leading.equalTo(commentIcon_Somnia.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
    }
    
    // MARK: - 数据绑定
    
    /// 配置 Cell 数据
    /// - Parameters:
    ///   - post_Somnia: 帖子数据模型
    ///   - isLiked_Somnia: 当前用户是否已点赞
    func configure_Somnia(post_Somnia: TitleModel_Somnia, isLiked_Somnia: Bool) {
        authorLabel_Somnia.text = post_Somnia.titleUserName_Somnia
        titleLabel_Somnia.text = post_Somnia.title_Somnia
        contentLabel_Somnia.text = post_Somnia.titleContent_Somnia
        likeCountLabel_Somnia.text = "\(post_Somnia.likes_Somnia)"
        commentCountLabel_Somnia.text = "\(post_Somnia.reviews_Somnia.count)"
        likeButton_Somnia.isSelected = isLiked_Somnia
        likeButton_Somnia.tintColor = isLiked_Somnia
            ? ColorConfig_Somnia.secondaryGradientStart_Somnia
            : ColorConfig_Somnia.textPlaceholder_Somnia
        
        // 根据帖子 ID 轮换封面图标，增加视觉多样性
        let icons_Somnia = ["moon.stars.fill", "sparkles", "cloud.moon.fill",
                             "star.fill", "wind", "leaf.fill", "flame.fill"]
        let iconName_Somnia = icons_Somnia[post_Somnia.titleId_Somnia % icons_Somnia.count]
        coverIcon_Somnia.image = UIImage(systemName: iconName_Somnia)
        
        // 偶数/奇数帖子交替渐变色
        if post_Somnia.titleId_Somnia % 2 == 0 {
            coverGradientLayer_Somnia?.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
        } else {
            coverGradientLayer_Somnia?.colors = [
                ColorConfig_Somnia.secondaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.secondaryGradientEnd_Somnia.cgColor
            ]
        }
    }
    
    // MARK: - 事件响应
    
    /// 点赞按钮点击
    @objc private func likeTapped_Somnia() {
        likeButton_Somnia.animatePulse_Somnia()
        onLikeTapped_Somnia?()
    }
    
    /// 头像点击
    @objc private func avatarTapped_Somnia() {
        avatarView_Somnia.animatePressDown_Somnia {
            self.avatarView_Somnia.animatePressUp_Somnia()
        }
        onAvatarTapped_Somnia?()
    }
}
