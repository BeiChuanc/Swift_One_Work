import UIKit
import SnapKit

// MARK: - 推荐用户 CollectionView Cell

/// 推荐用户卡片 UICollectionViewCell
/// 核心作用：在发现页横滑推荐栏中展示单个用户，包含头像、用户名、粉丝数和关注按钮。
/// 设计思路：圆角卡片，柔和阴影，关注按钮渐变态 vs 已关注态，按压动画反馈。
/// 关键属性：onFollowTapped_Flick（关注回调）、onCardTapped_Flick（卡片点击回调）
class UserRecommendCell_Flick: UICollectionViewCell {
    
    // MARK: - 复用标识
    
    static let reuseId_Flick = "UserRecommendCell_Flick"
    
    // MARK: - 回调
    
    /// 关注/取消关注回调
    var onFollowTapped_Flick: (() -> Void)?
    
    /// 卡片点击（查看用户主页）回调
    var onCardTapped_Flick: (() -> Void)?
    
    // MARK: - UI 组件
    
    /// 卡片容器
    private let cardView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.cardBackground_Flick
        v.layer.cornerRadius = 18
        v.layer.shadowColor = ColorConfig_Flick.shadowColor_Flick.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 1
        return v
    }()
    
    /// 用户头像
    private let avatarView_Flick = UserAvatarView_Flick()
    
    /// 用户名标签
    private let nameLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.textColor = ColorConfig_Flick.textPrimary_Flick
        l.textAlignment = .center
        return l
    }()
    
    /// 粉丝数标签
    private let fansLabel_Flick: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textColor = ColorConfig_Flick.textPlaceholder_Flick
        l.textAlignment = .center
        return l
    }()
    
    /// 关注按钮
    private let followButton_Flick: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Follow", for: .normal)
        b.setTitle("Following", for: .selected)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.setTitleColor(ColorConfig_Flick.textSecondary_Flick, for: .selected)
        b.layer.cornerRadius = 12
        return b
    }()
    
    private var followGradientLayer_Flick: CAGradientLayer?
    
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
        followGradientLayer_Flick?.frame = followButton_Flick.bounds
        followGradientLayer_Flick?.cornerRadius = followButton_Flick.layer.cornerRadius
    }
    
    // MARK: - UI 布局
    
    /// 搭建卡片内所有子视图
    private func setupUI_Flick() {
        backgroundColor = .clear
        
        contentView.addSubview(cardView_Flick)
        cardView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像
        cardView_Flick.addSubview(avatarView_Flick)
        avatarView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        // 用户名
        cardView_Flick.addSubview(nameLabel_Flick)
        nameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Flick.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        // 粉丝数
        cardView_Flick.addSubview(fansLabel_Flick)
        fansLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Flick.snp.bottom).offset(3)
            make.left.right.equalTo(nameLabel_Flick)
        }
        
        // 关注按钮
        cardView_Flick.addSubview(followButton_Flick)
        followButton_Flick.snp.makeConstraints { make in
            make.top.equalTo(fansLabel_Flick.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        // 关注按钮渐变背景
        let grad_Flick = CAGradientLayer()
        grad_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        grad_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        grad_Flick.cornerRadius = 12
        followButton_Flick.layer.insertSublayer(grad_Flick, at: 0)
        followGradientLayer_Flick = grad_Flick
        
        // 事件绑定
        followButton_Flick.addTarget(self, action: #selector(handleFollowTap_Flick), for: .touchUpInside)
        let tapGesture_Flick = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Flick))
        cardView_Flick.addGestureRecognizer(tapGesture_Flick)
    }
    
    // MARK: - 公共配置方法
    
    /// 配置推荐用户 Cell 内容
    /// - Parameters:
    ///   - user_flick: 用户数据模型
    ///   - isFollowing_flick: 当前是否已关注
    func configure_Flick(user_flick: PrewUserModel_Flick, isFollowing_flick: Bool) {
        avatarView_Flick.configure_Flick(userId_Flick: user_flick.userId_Flick ?? 0)
        nameLabel_Flick.text = user_flick.userName_Flick ?? "User"
        let fans_Flick = user_flick.userFans_Flick ?? 0
        fansLabel_Flick.text = "\(fans_Flick) fans"
        
        updateFollowState_Flick(isFollowing_flick: isFollowing_flick, animated_Flick: false)
    }
    
    // MARK: - 私有方法
    
    /// 更新关注按钮视觉状态
    private func updateFollowState_Flick(isFollowing_flick: Bool, animated_Flick: Bool) {
        followButton_Flick.isSelected = isFollowing_flick
        
        let update_Flick = { [weak self] in
            guard let self = self else { return }
            if isFollowing_flick {
                self.followGradientLayer_Flick?.opacity = 0
                self.followButton_Flick.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
                self.followButton_Flick.layer.borderWidth = 1
                self.followButton_Flick.layer.borderColor = ColorConfig_Flick.border_Flick.cgColor
            } else {
                self.followGradientLayer_Flick?.opacity = 1
                self.followButton_Flick.backgroundColor = .clear
                self.followButton_Flick.layer.borderWidth = 0
            }
        }
        
        if animated_Flick {
            UIView.animate(withDuration: AnimationConfig_Flick.durationFast_Flick, animations: update_Flick)
        } else {
            update_Flick()
        }
    }
    
    // MARK: - 事件处理
    
    @objc private func handleFollowTap_Flick() {
        followButton_Flick.animatePulse_Flick()
        let generator_Flick = UIImpactFeedbackGenerator(style: .medium)
        generator_Flick.impactOccurred()
        onFollowTapped_Flick?()
    }
    
    @objc private func handleCardTap_Flick() {
        cardView_Flick.animatePressDown_Flick { [weak self] in
            self?.cardView_Flick.animatePressUp_Flick()
        }
        onCardTapped_Flick?()
    }
}
