import UIKit
import SnapKit

// MARK: 用户推荐横向单元格

/// 发现页推荐用户横向列表单元格
/// 功能：展示用户头像、昵称、粉丝数，并提供关注/取消关注切换按钮
/// 特性：关注状态切换时按钮带渐变颜色动画
class UserRecommendCell_Sprig: UICollectionViewCell {
    
    static let reuseId_Sprig = "UserRecommendCell_Sprig"
    
    // MARK: - 回调
    
    /// 关注/取消关注按钮点击回调（传出用户模型）
    var onFollowTap_Sprig: ((PrewUserModel_Sprig) -> Void)?
    
    // MARK: - 私有属性
    
    private var userModel_Sprig: PrewUserModel_Sprig?
    
    // MARK: - 私有 UI
    
    /// 卡片白底圆角容器
    private let cardView_Sprig: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 0.06
        return v
    }()
    
    /// 头像渐变背景
    private let avatarView_Sprig: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 26
        v.clipsToBounds = true
        return v
    }()
    
    private let avatarGradient_Sprig = CAGradientLayer()
    
    private let avatarIcon_Sprig: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "person.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    /// 用户昵称
    private let nameLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Sprig.textPrimary_Sprig
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        return l
    }()
    
    /// 粉丝数标签
    private let fansLabel_Sprig: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        l.textAlignment = .center
        return l
    }()
    
    /// 关注/已关注按钮
    private let followButton_Sprig: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        return btn
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Sprig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Sprig()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarGradient_Sprig.frame = avatarView_Sprig.bounds
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Sprig() {
        backgroundColor = .clear
        addSubview(cardView_Sprig)
        
        cardView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        }
        
        // 头像
        avatarGradient_Sprig.startPoint = CGPoint(x: 0, y: 0)
        avatarGradient_Sprig.endPoint = CGPoint(x: 1, y: 1)
        avatarView_Sprig.layer.insertSublayer(avatarGradient_Sprig, at: 0)
        avatarView_Sprig.addSubview(avatarIcon_Sprig)
        
        cardView_Sprig.addSubview(avatarView_Sprig)
        cardView_Sprig.addSubview(nameLabel_Sprig)
        cardView_Sprig.addSubview(fansLabel_Sprig)
        cardView_Sprig.addSubview(followButton_Sprig)
        
        avatarView_Sprig.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        avatarIcon_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        nameLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
        }
        
        fansLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Sprig.snp.bottom).offset(3)
            make.left.right.equalToSuperview().inset(8)
        }
        
        followButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(fansLabel_Sprig.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        followButton_Sprig.addTarget(self, action: #selector(handleFollowTap_Sprig), for: .touchUpInside)
    }
    
    // MARK: - 数据填充
    
    /// 填充用户数据
    /// 参数：user_sprig - 用户模型
    func configure_Sprig(user_sprig: PrewUserModel_Sprig) {
        self.userModel_Sprig = user_sprig
        
        nameLabel_Sprig.text = user_sprig.userName_Sprig
        let fans_sprig = user_sprig.userFans_Sprig ?? 0
        fansLabel_Sprig.text = "\(fans_sprig) fans"
        
        // 头像渐变色按用户 ID 变化
        let gradients_sprig: [(UIColor, UIColor)] = [
            (ColorConfig_Sprig.primaryGradientStart_Sprig, ColorConfig_Sprig.primaryGradientEnd_Sprig),
            (ColorConfig_Sprig.leafGreen_Sprig, ColorConfig_Sprig.freshMint_Sprig),
            (ColorConfig_Sprig.petalPink_Sprig, ColorConfig_Sprig.bloomOrange_Sprig),
            (ColorConfig_Sprig.lavender_Sprig, ColorConfig_Sprig.primaryGradientStart_Sprig),
            (ColorConfig_Sprig.bloomOrange_Sprig, ColorConfig_Sprig.sunflowerYellow_Sprig),
        ]
        let idx_sprig = (user_sprig.userId_Sprig ?? 0) % gradients_sprig.count
        let (start_sprig, end_sprig) = gradients_sprig[idx_sprig]
        avatarGradient_Sprig.colors = [start_sprig.cgColor, end_sprig.cgColor]
        
        updateFollowButtonState_Sprig(user_sprig: user_sprig)
    }
    
    /// 更新关注按钮状态
    private func updateFollowButtonState_Sprig(user_sprig: PrewUserModel_Sprig) {
        let isFollowing_sprig = UserViewModel_Sprig.shared_Sprig.isFollowing_Sprig(user_sprig: user_sprig)
        
        UIView.animate(withDuration: AnimationConfig_Sprig.durationFast_Sprig) {
            if isFollowing_sprig {
                self.followButton_Sprig.setTitle("Following", for: .normal)
                self.followButton_Sprig.setTitleColor(ColorConfig_Sprig.textSecondary_Sprig, for: .normal)
                self.followButton_Sprig.backgroundColor = ColorConfig_Sprig.tagBackground_Sprig
                self.followButton_Sprig.layer.borderWidth = 0
            } else {
                self.followButton_Sprig.setTitle("Follow", for: .normal)
                self.followButton_Sprig.setTitleColor(.white, for: .normal)
                self.followButton_Sprig.backgroundColor = ColorConfig_Sprig.tagSelected_Sprig
                self.followButton_Sprig.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - 按钮响应
    
    @objc private func handleFollowTap_Sprig() {
        guard let user_sprig = userModel_Sprig else { return }
        followButton_Sprig.animatePulse_Sprig()
        onFollowTap_Sprig?(user_sprig)
        // 延迟刷新按钮状态（等待 ViewModel 更新）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateFollowButtonState_Sprig(user_sprig: user_sprig)
        }
    }
}
