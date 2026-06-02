import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心区头视图

/// 用户中心区头视图
/// 核心作用：渐变头像区 + 帖子/关注/粉丝三列统计浮卡 + 关注/消息按钮 + 帖子区标题
/// 设计思路：与 MeHeaderView_Breeze 同款渐变；白色实心头像环明确边界；三列统计浮卡叠于渐变底部
/// 关键属性：onFollow_Breeze / onMessage_Breeze 回调；isFollowingCurrent_Breeze 驱动按钮状态
class UserInfoHeaderView_Breeze: UICollectionReusableView {
    
    static let reuseId_Breeze = "UserInfoHeaderView_Breeze"
    
    // MARK: - 回调
    
    var onFollow_Breeze: (() -> Void)?
    var onMessage_Breeze: (() -> Void)?
    
    // MARK: - UI：渐变头像区
    
    private let gradientCard_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var headerGradient_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上大圆
    private let decorLarge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_breeze.layer.cornerRadius = 80
        return v_breeze
    }()
    
    /// 装饰圆 - 左下小圆
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 42
        return v_breeze
    }()
    
    /// 头像白色实心环（明确边界，与 MeHeaderView 一致）
    private let avatarRing_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        v_breeze.layer.cornerRadius = 52
        // 白色外圈加细描边增强可见性
        v_breeze.layer.borderWidth = 3
        v_breeze.layer.borderColor = UIColor.white.cgColor
        return v_breeze
    }()
    
    private let avatarView_Breeze: UserAvatarView_Breeze = {
        let av_breeze = UserAvatarView_Breeze()
        av_breeze.layer.cornerRadius = 46
        av_breeze.clipsToBounds = true
        return av_breeze
    }()
    
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    private let introLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    // MARK: - UI：三列统计浮卡
    
    private let statsCard_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 20
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_breeze.layer.shadowRadius = 12
        v_breeze.layer.shadowOpacity = 0.12
        return v_breeze
    }()
    
    private let postsStatView_Breeze     = MeStatItem_Breeze(title_breeze: "Posts")
    private let followingStatView_Breeze = MeStatItem_Breeze(title_breeze: "Following")
    private let fansStatView_Breeze      = MeStatItem_Breeze(title_breeze: "Fans")
    
    private let divider1_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.divider_Breeze
        return v_breeze
    }()
    private let divider2_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.divider_Breeze
        return v_breeze
    }()
    
    // MARK: - UI：操作按钮区
    
    private let followButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_breeze.layer.cornerRadius = 22
        btn_breeze.clipsToBounds = false
        return btn_breeze
    }()
    
    private var followGradient_Breeze: CAGradientLayer?
    
    private let messageButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: config_breeze), for: .normal)
        btn_breeze.setTitle("  Message", for: .normal)
        btn_breeze.setTitleColor(ColorConfig_Breeze.primaryGradientStart_Breeze, for: .normal)
        btn_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_breeze.layer.cornerRadius = 22
        btn_breeze.layer.borderWidth = 1.5
        btn_breeze.layer.borderColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn_breeze.backgroundColor = .white
        return btn_breeze
    }()
    
    // MARK: - UI：帖子区标题
    
    private let sectionAccentBar_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        v_breeze.layer.cornerRadius = 2
        return v_breeze
    }()
    
    private let sectionTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "Camp Stories"
        label_breeze.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        return label_breeze
    }()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupGradientCard_Breeze()
        setupStatsCard_Breeze()
        setupActionButtons_Breeze()
        setupSectionTitle_Breeze()
    }
    
    private func setupGradientCard_Breeze() {
        addSubview(gradientCard_Breeze)
        gradientCard_Breeze.addSubview(decorLarge_Breeze)
        gradientCard_Breeze.addSubview(decorSmall_Breeze)
        gradientCard_Breeze.addSubview(avatarRing_Breeze)
        avatarRing_Breeze.addSubview(avatarView_Breeze)
        gradientCard_Breeze.addSubview(nameLabel_Breeze)
        gradientCard_Breeze.addSubview(introLabel_Breeze)
        
        gradientCard_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(230)
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(160)
            make.right.equalToSuperview().offset(44)
            make.top.equalToSuperview().offset(-32)
        }
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(84)
            make.left.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(18)
        }
        
        // 头像环：固定顶部偏移，为状态栏+返回按钮留出空间
        avatarRing_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        avatarView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(92)
        }
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        introLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }
    }
    
    private func setupStatsCard_Breeze() {
        addSubview(statsCard_Breeze)
        statsCard_Breeze.addSubview(postsStatView_Breeze)
        statsCard_Breeze.addSubview(divider1_Breeze)
        statsCard_Breeze.addSubview(followingStatView_Breeze)
        statsCard_Breeze.addSubview(divider2_Breeze)
        statsCard_Breeze.addSubview(fansStatView_Breeze)
        
        statsCard_Breeze.snp.makeConstraints { make in
            make.top.equalTo(gradientCard_Breeze.snp.bottom).offset(-22)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }
        
        postsStatView_Breeze.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
        divider1_Breeze.snp.makeConstraints { make in
            make.centerX.equalTo(postsStatView_Breeze.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(30)
        }
        followingStatView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.top.bottom.equalToSuperview()
        }
        divider2_Breeze.snp.makeConstraints { make in
            make.centerX.equalTo(followingStatView_Breeze.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(30)
        }
        fansStatView_Breeze.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
    }
    
    private func setupActionButtons_Breeze() {
        addSubview(followButton_Breeze)
        addSubview(messageButton_Breeze)
        followButton_Breeze.addTarget(self, action: #selector(handleFollow_Breeze), for: .touchUpInside)
        messageButton_Breeze.addTarget(self, action: #selector(handleMessage_Breeze), for: .touchUpInside)
    }
    
    private func setupSectionTitle_Breeze() {
        addSubview(sectionAccentBar_Breeze)
        addSubview(sectionTitle_Breeze)
        
        sectionAccentBar_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(4)
            make.height.equalTo(18)
        }
        sectionTitle_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(sectionAccentBar_Breeze)
            make.left.equalTo(sectionAccentBar_Breeze.snp.right).offset(8)
        }
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshHeaderGradient_Breeze()
        refreshFollowButtonGradient_Breeze()
    }
    
    private func refreshHeaderGradient_Breeze() {
        headerGradient_Breeze?.removeFromSuperlayer()
        guard !gradientCard_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: gradientCard_Breeze.bounds)
        gradientCard_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradient_Breeze = gradient_breeze
    }
    
    private func refreshFollowButtonGradient_Breeze() {
        guard !isFollowingCurrent_Breeze, !followButton_Breeze.bounds.isEmpty else { return }
        followGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: followButton_Breeze.bounds)
        gradient_breeze.cornerRadius = followButton_Breeze.layer.cornerRadius
        followButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        followGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 数据配置
    
    private var isFollowingCurrent_Breeze: Bool = false
    
    /// 配置区头展示内容
    /// - Parameters:
    ///   - user_breeze: 目标用户
    ///   - isFromChat_breeze: 是否从聊天进入（隐藏消息按钮，关注按钮居中）
    ///   - isFollowing_breeze: 当前是否已关注
    ///   - postsCount_breeze: 该用户的帖子数量
    func configure_Breeze(user_breeze: PrewUserModel_Breeze,
                          isFromChat_breeze: Bool,
                          isFollowing_breeze: Bool,
                          postsCount_breeze: Int = 0) {
        isFollowingCurrent_Breeze = isFollowing_breeze
        
        nameLabel_Breeze.text = user_breeze.userName_Breeze ?? "Camper"
        introLabel_Breeze.text = user_breeze.userIntroduce_Breeze ?? "A fellow park camper"
        avatarView_Breeze.configure_Breeze(userId_Breeze: user_breeze.userId_Breeze ?? 0)
        
        postsStatView_Breeze.setValue_Breeze(value_breeze: postsCount_breeze)
        followingStatView_Breeze.setValue_Breeze(value_breeze: user_breeze.userFollow_Breeze ?? 0)
        fansStatView_Breeze.setValue_Breeze(value_breeze: user_breeze.userFans_Breeze ?? 0)
        
        updateFollowButton_Breeze(isFollowing_breeze: isFollowing_breeze)
        layoutActionButtons_Breeze(isFromChat_breeze: isFromChat_breeze)
    }
    
    private func updateFollowButton_Breeze(isFollowing_breeze: Bool) {
        followGradient_Breeze?.removeFromSuperlayer()
        followGradient_Breeze = nil
        
        if isFollowing_breeze {
            followButton_Breeze.setTitle("Followed", for: .normal)
            followButton_Breeze.setImage(nil, for: .normal)
            followButton_Breeze.setTitleColor(ColorConfig_Breeze.textSecondary_Breeze, for: .normal)
            followButton_Breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
            followButton_Breeze.layer.borderWidth = 1.5
            followButton_Breeze.layer.borderColor = ColorConfig_Breeze.border_Breeze.cgColor
        } else {
            let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            followButton_Breeze.setImage(
                UIImage(systemName: "person.badge.plus", withConfiguration: config_breeze),
                for: .normal
            )
            followButton_Breeze.setTitle("  Follow", for: .normal)
            followButton_Breeze.setTitleColor(.white, for: .normal)
            followButton_Breeze.tintColor = .white
            followButton_Breeze.backgroundColor = .clear
            followButton_Breeze.layer.borderWidth = 0
        }
    }
    
    private func layoutActionButtons_Breeze(isFromChat_breeze: Bool) {
        followButton_Breeze.snp.removeConstraints()
        messageButton_Breeze.snp.removeConstraints()
        
        if isFromChat_breeze {
            messageButton_Breeze.isHidden = true
            followButton_Breeze.isHidden = false
            followButton_Breeze.snp.makeConstraints { make in
                make.top.equalTo(statsCard_Breeze.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(44)
                make.bottom.equalTo(sectionAccentBar_Breeze.snp.top).offset(-18)
            }
        } else {
            messageButton_Breeze.isHidden = false
            followButton_Breeze.isHidden = false
            followButton_Breeze.snp.makeConstraints { make in
                make.top.equalTo(statsCard_Breeze.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(20)
                make.height.equalTo(44)
                make.bottom.equalTo(sectionAccentBar_Breeze.snp.top).offset(-18)
            }
            messageButton_Breeze.snp.makeConstraints { make in
                make.top.height.equalTo(followButton_Breeze)
                make.left.equalTo(followButton_Breeze.snp.right).offset(12)
                make.right.equalToSuperview().offset(-20)
                make.width.equalTo(followButton_Breeze)
            }
        }
    }
    
    // MARK: - 事件
    
    @objc private func handleFollow_Breeze() {
        followButton_Breeze.animatePulse_Breeze()
        onFollow_Breeze?()
    }
    
    @objc private func handleMessage_Breeze() {
        messageButton_Breeze.animatePulse_Breeze()
        onMessage_Breeze?()
    }
}
