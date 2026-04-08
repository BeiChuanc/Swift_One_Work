import Foundation
import UIKit
import SnapKit

// MARK: - 发现页用户推荐 Cell

/// 发现页用户推荐 Cell（水平滚动列表）
/// 核心功能：展示用户头像、昵称、粉丝数，支持关注/取消关注
/// 设计理念：圆形渐变头像 + 紧凑竖排信息 + 渐变关注按钮
/// 关键方法：configure_Somnia / onFollowTapped_Somnia
class UserRecommendCell_Somnia: UICollectionViewCell {
    
    // MARK: - 静态标识
    
    /// Cell 复用标识符
    static let reuseId_Somnia = "UserRecommendCell_Somnia"
    
    // MARK: - 回调
    
    /// 关注按钮点击回调
    var onFollowTapped_Somnia: (() -> Void)?
    
    /// 头像点击回调（跳转用户主页）
    var onAvatarTapped_Somnia: (() -> Void)?
    
    // MARK: - 私有 UI 属性
    
    /// 卡片容器
    private let cardView_Somnia = UIView()
    
    /// 头像外圈渐变环
    private let avatarRing_Somnia = UIView()
    private var ringGradientLayer_Somnia: CAGradientLayer?
    
    /// 头像背景（白色圆）
    private let avatarBg_Somnia = UIView()
    
    /// 头像图标
    private let avatarIcon_Somnia = UIImageView()
    
    /// 用户名
    private let nameLabel_Somnia = UILabel()
    
    /// 粉丝数
    private let fansLabel_Somnia = UILabel()
    
    /// 关注按钮
    private let followButton_Somnia = UIButton(type: .custom)
    
    /// 关注按钮渐变图层
    private var followGradientLayer_Somnia: CAGradientLayer?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
        setupConstraints_Somnia()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ringGradientLayer_Somnia?.frame = avatarRing_Somnia.bounds
        followGradientLayer_Somnia?.frame = followButton_Somnia.bounds
        avatarRing_Somnia.layer.cornerRadius = avatarRing_Somnia.bounds.width / 2
        avatarBg_Somnia.layer.cornerRadius = avatarBg_Somnia.bounds.width / 2
        avatarIcon_Somnia.layer.cornerRadius = avatarIcon_Somnia.bounds.width / 2
        followButton_Somnia.layer.cornerRadius = followButton_Somnia.bounds.height / 2
        followGradientLayer_Somnia?.cornerRadius = followButton_Somnia.bounds.height / 2
    }
    
    // MARK: - UI 构建
    
    /// 初始化所有子视图样式
    private func setupUI_Somnia() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 卡片容器
        cardView_Somnia.backgroundColor = .white
        cardView_Somnia.layer.cornerRadius = 20
        cardView_Somnia.layer.shadowColor = UIColor(hexstring_Somnia: "#B794F6", alpha_Somnia: 0.12).cgColor
        cardView_Somnia.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView_Somnia.layer.shadowRadius = 12
        cardView_Somnia.layer.shadowOpacity = 1
        contentView.addSubview(cardView_Somnia)
        
        // 头像外圈渐变环
        avatarRing_Somnia.clipsToBounds = true
        cardView_Somnia.addSubview(avatarRing_Somnia)
        
        let ring_Somnia = UIColor.createPrimaryGradientLayer_Somnia(frame_Somnia: .zero)
        ring_Somnia.startPoint = CGPoint(x: 0, y: 0)
        ring_Somnia.endPoint = CGPoint(x: 1, y: 1)
        avatarRing_Somnia.layer.insertSublayer(ring_Somnia, at: 0)
        ringGradientLayer_Somnia = ring_Somnia
        
        // 头像白色背景圆
        avatarBg_Somnia.backgroundColor = .white
        cardView_Somnia.addSubview(avatarBg_Somnia)
        
        // 头像图标
        avatarIcon_Somnia.image = UIImage(systemName: "person.crop.circle.fill")
        avatarIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        avatarIcon_Somnia.contentMode = .scaleAspectFill
        avatarIcon_Somnia.clipsToBounds = true
        avatarIcon_Somnia.isUserInteractionEnabled = true
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(avatarTapped_Somnia))
        avatarIcon_Somnia.addGestureRecognizer(tap_Somnia)
        cardView_Somnia.addSubview(avatarIcon_Somnia)
        
        // 用户名
        nameLabel_Somnia.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel_Somnia.textColor = ColorConfig_Somnia.textPrimary_Somnia
        nameLabel_Somnia.textAlignment = .center
        cardView_Somnia.addSubview(nameLabel_Somnia)
        
        // 粉丝数
        fansLabel_Somnia.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        fansLabel_Somnia.textColor = ColorConfig_Somnia.textSecondary_Somnia
        fansLabel_Somnia.textAlignment = .center
        cardView_Somnia.addSubview(fansLabel_Somnia)
        
        // 关注按钮
        followButton_Somnia.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        followButton_Somnia.setTitleColor(.white, for: .normal)
        followButton_Somnia.setTitleColor(ColorConfig_Somnia.textSecondary_Somnia, for: .selected)
        followButton_Somnia.addTarget(self, action: #selector(followTapped_Somnia), for: .touchUpInside)
        followButton_Somnia.clipsToBounds = true
        cardView_Somnia.addSubview(followButton_Somnia)
        
        // 关注按钮渐变背景
        let btnGrad_Somnia = UIColor.createPrimaryGradientLayer_Somnia(frame_Somnia: .zero)
        followButton_Somnia.layer.insertSublayer(btnGrad_Somnia, at: 0)
        followGradientLayer_Somnia = btnGrad_Somnia
    }
    
    // MARK: - 约束布局
    
    /// 设置 SnapKit 约束
    private func setupConstraints_Somnia() {
        cardView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarRing_Somnia.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(58)
        }
        
        avatarBg_Somnia.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Somnia)
            make.width.height.equalTo(52)
        }
        
        avatarIcon_Somnia.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Somnia)
            make.width.height.equalTo(48)
        }
        
        nameLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Somnia.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
        }
        
        fansLabel_Somnia.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Somnia.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
        
        followButton_Somnia.snp.makeConstraints { make in
            make.top.equalTo(fansLabel_Somnia.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - 数据绑定
    
    /// 配置 Cell 数据
    /// - Parameters:
    ///   - user_Somnia: 用户数据模型
    ///   - isFollowing_Somnia: 当前是否已关注
    func configure_Somnia(user_Somnia: PrewUserModel_Somnia, isFollowing_Somnia: Bool) {
        nameLabel_Somnia.text = user_Somnia.userName_Somnia ?? "Dreamer"
        
        let fans_Somnia = user_Somnia.userFans_Somnia ?? 0
        fansLabel_Somnia.text = "\(fans_Somnia) followers"
        
        updateFollowState_Somnia(isFollowing_Somnia: isFollowing_Somnia)
        
        // 根据用户 ID 轮换头像图标
        let avatarIcons_Somnia = ["person.crop.circle.fill",
                                   "person.crop.circle.badge.plus",
                                   "person.crop.circle.badge.checkmark"]
        let idx_Somnia = (user_Somnia.userId_Somnia ?? 0) % avatarIcons_Somnia.count
        avatarIcon_Somnia.image = UIImage(systemName: avatarIcons_Somnia[idx_Somnia])
        
        // 根据用户 ID 轮换头像渐变色
        if (user_Somnia.userId_Somnia ?? 0) % 2 == 0 {
            avatarIcon_Somnia.tintColor = ColorConfig_Somnia.primaryGradientStart_Somnia
        } else {
            avatarIcon_Somnia.tintColor = ColorConfig_Somnia.secondaryGradientStart_Somnia
        }
    }
    
    /// 更新关注状态 UI
    /// - Parameter isFollowing_Somnia: 是否已关注
    private func updateFollowState_Somnia(isFollowing_Somnia: Bool) {
        followButton_Somnia.isSelected = isFollowing_Somnia
        
        if isFollowing_Somnia {
            followButton_Somnia.setTitle("Following", for: .selected)
            followGradientLayer_Somnia?.colors = [
                ColorConfig_Somnia.divider_Somnia.cgColor,
                ColorConfig_Somnia.divider_Somnia.cgColor
            ]
            followButton_Somnia.setTitleColor(ColorConfig_Somnia.textSecondary_Somnia, for: .selected)
        } else {
            followButton_Somnia.setTitle("Follow", for: .normal)
            followGradientLayer_Somnia?.colors = [
                ColorConfig_Somnia.primaryGradientStart_Somnia.cgColor,
                ColorConfig_Somnia.primaryGradientEnd_Somnia.cgColor
            ]
            followButton_Somnia.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - 事件响应
    
    /// 关注按钮点击
    @objc private func followTapped_Somnia() {
        followButton_Somnia.animatePressDown_Somnia {
            self.followButton_Somnia.animatePressUp_Somnia()
        }
        onFollowTapped_Somnia?()
    }
    
    /// 头像点击
    @objc private func avatarTapped_Somnia() {
        avatarIcon_Somnia.animatePressDown_Somnia {
            self.avatarIcon_Somnia.animatePressUp_Somnia()
        }
        onAvatarTapped_Somnia?()
    }
}
