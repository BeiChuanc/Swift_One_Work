import Foundation
import UIKit
import SnapKit

// MARK: - 我的页区头视图

/// 我的页区头视图
/// 核心作用：渐变头像卡 + 统计数据卡片 + 自定义分段切换器，事件以闭包回调宿主
/// 设计思路：顶部渐变（与 Discover 同款）内嵌头像/名字/简介；白色统计卡片浮出渐变底部；自定义分段替代系统 UISegmentedControl
/// 关键属性：onSettings/onEdit/onAvatarTap/onSegmentChange 回调、渐变图层 headerGradient_Breeze
class MeHeaderView_Breeze: UICollectionReusableView {
    
    static let reuseId_Breeze = "MeHeaderView_Breeze"
    
    // MARK: - 回调
    
    var onSettings_Breeze: (() -> Void)?
    var onEdit_Breeze: (() -> Void)?
    var onAvatarTap_Breeze: (() -> Void)?
    var onSegmentChange_Breeze: ((Int) -> Void)?
    
    // MARK: - UI：渐变头像区
    
    /// 渐变容器（clipsToBounds 确保装饰圆不溢出）
    private let gradientCard_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.clipsToBounds = true
        return view_breeze
    }()
    
    /// 渐变图层
    private var headerGradient_Breeze: CAGradientLayer?
    
    /// 装饰圆 - 右上大圆
    private let decorLarge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v_breeze.layer.cornerRadius = 75
        return v_breeze
    }()
    
    /// 装饰圆 - 左下小圆
    private let decorSmall_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v_breeze.layer.cornerRadius = 38
        return v_breeze
    }()
    
    /// 设置按钮（白色半透明圆形）
    private let settingsButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn_breeze.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 编辑按钮（白色半透明圆形）
    private let editButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        btn_breeze.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    /// 头像外圈（白色环）
    private let avatarRing_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        v_breeze.layer.cornerRadius = 50
        return v_breeze
    }()
    
    /// 头像组件
    private let avatarView_Breeze: CurrentUserAvatarView_Breeze = {
        let av_breeze = CurrentUserAvatarView_Breeze()
        av_breeze.layer.cornerRadius = 44
        av_breeze.clipsToBounds = true
        return av_breeze
    }()
    
    /// 相机角标（右下角）
    private let cameraBadge_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 14
        v_breeze.isUserInteractionEnabled = false
        return v_breeze
    }()
    
    private let cameraIcon_Breeze: UIImageView = {
        let iv_breeze = UIImageView()
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        iv_breeze.image = UIImage(systemName: "camera.fill", withConfiguration: config_breeze)
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        return iv_breeze
    }()
    
    /// 用户昵称（白色）
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 用户简介（半透明白）
    private let introLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    // MARK: - UI：统计卡片
    
    /// 统计数据白色浮卡
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
    
    private let postsStatView_Breeze  = MeStatItem_Breeze(title_breeze: "Posts")
    private let likesStatView_Breeze  = MeStatItem_Breeze(title_breeze: "Likes")
    private let followStatView_Breeze = MeStatItem_Breeze(title_breeze: "Following")
    
    /// 统计卡内部竖向分割线
    private let divider1_Breeze = MeHeaderView_Breeze.makeDivider_Breeze()
    private let divider2_Breeze = MeHeaderView_Breeze.makeDivider_Breeze()
    
    // MARK: - UI：自定义分段控件
    
    /// 分段容器（背景胶囊）
    private let segmentContainer_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        v_breeze.layer.cornerRadius = 14
        return v_breeze
    }()
    
    /// "My Posts" 分段按钮
    private let segMyPosts_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("My Posts", for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_breeze.tag = 0
        return btn_breeze
    }()
    
    /// "Liked" 分段按钮
    private let segLiked_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        btn_breeze.setTitle("Liked", for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn_breeze.tag = 1
        return btn_breeze
    }()
    
    /// 分段指示器（滑块）
    private let segIndicator_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.cornerRadius = 11
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_breeze.layer.shadowRadius = 6
        v_breeze.layer.shadowOpacity = 0.1
        return v_breeze
    }()
    
    /// 当前选中分段
    private var currentSegment_Breeze: Int = 0
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupGradientCard_Breeze()
        setupStatsCard_Breeze()
        setupSegment_Breeze()
    }
    
    /// 搭建渐变头像区
    private func setupGradientCard_Breeze() {
        addSubview(gradientCard_Breeze)
        gradientCard_Breeze.addSubview(decorLarge_Breeze)
        gradientCard_Breeze.addSubview(decorSmall_Breeze)
        gradientCard_Breeze.addSubview(settingsButton_Breeze)
        gradientCard_Breeze.addSubview(editButton_Breeze)
        gradientCard_Breeze.addSubview(avatarRing_Breeze)
        avatarRing_Breeze.addSubview(avatarView_Breeze)
        gradientCard_Breeze.addSubview(cameraBadge_Breeze)
        cameraBadge_Breeze.addSubview(cameraIcon_Breeze)
        gradientCard_Breeze.addSubview(nameLabel_Breeze)
        gradientCard_Breeze.addSubview(introLabel_Breeze)
        
        gradientCard_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(210)
        }
        
        decorLarge_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(150)
            make.right.equalToSuperview().offset(40)
            make.top.equalToSuperview().offset(-28)
        }
        
        decorSmall_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(76)
            make.left.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(16)
        }
        
        settingsButton_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        
        editButton_Breeze.snp.makeConstraints { make in
            make.centerY.equalTo(settingsButton_Breeze)
            make.right.equalTo(settingsButton_Breeze.snp.left).offset(-10)
            make.width.height.equalTo(36)
        }
        
        // 头像外圈
        avatarRing_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        // 头像（内缩 6pt 留出白色环）
        avatarView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(88)
        }
        
        // 相机角标
        cameraBadge_Breeze.snp.makeConstraints { make in
            make.right.equalTo(avatarRing_Breeze).offset(-2)
            make.bottom.equalTo(avatarRing_Breeze).offset(-2)
            make.width.height.equalTo(28)
        }
        
        cameraIcon_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Breeze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        
        introLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }
        
        settingsButton_Breeze.addTarget(self, action: #selector(handleSettings_Breeze), for: .touchUpInside)
        editButton_Breeze.addTarget(self, action: #selector(handleEdit_Breeze), for: .touchUpInside)
        
        let avatarTap_breeze = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTap_Breeze))
        avatarRing_Breeze.addGestureRecognizer(avatarTap_breeze)
        avatarRing_Breeze.isUserInteractionEnabled = true
        avatarView_Breeze.onTapped_Breeze = { [weak self] in self?.onAvatarTap_Breeze?() }
    }
    
    /// 搭建统计数据卡片
    private func setupStatsCard_Breeze() {
        addSubview(statsCard_Breeze)
        statsCard_Breeze.addSubview(postsStatView_Breeze)
        statsCard_Breeze.addSubview(divider1_Breeze)
        statsCard_Breeze.addSubview(likesStatView_Breeze)
        statsCard_Breeze.addSubview(divider2_Breeze)
        statsCard_Breeze.addSubview(followStatView_Breeze)
        
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
        
        likesStatView_Breeze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
            make.top.bottom.equalToSuperview()
        }
        
        divider2_Breeze.snp.makeConstraints { make in
            make.centerX.equalTo(likesStatView_Breeze.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(30)
        }
        
        followStatView_Breeze.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3)
        }
    }
    
    /// 搭建自定义分段选择器
    private func setupSegment_Breeze() {
        addSubview(segmentContainer_Breeze)
        segmentContainer_Breeze.addSubview(segIndicator_Breeze)
        segmentContainer_Breeze.addSubview(segMyPosts_Breeze)
        segmentContainer_Breeze.addSubview(segLiked_Breeze)
        
        segmentContainer_Breeze.snp.makeConstraints { make in
            make.top.equalTo(statsCard_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        segMyPosts_Breeze.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        segLiked_Breeze.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        segMyPosts_Breeze.addTarget(self, action: #selector(handleSegTap_Breeze(_:)), for: .touchUpInside)
        segLiked_Breeze.addTarget(self, action: #selector(handleSegTap_Breeze(_:)), for: .touchUpInside)
    }
    
    // MARK: - 布局更新
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshHeaderGradient_Breeze()
        updateSegmentIndicator_Breeze(animated: false)
    }
    
    /// 刷新头部渐变图层
    private func refreshHeaderGradient_Breeze() {
        headerGradient_Breeze?.removeFromSuperlayer()
        guard !gradientCard_Breeze.bounds.isEmpty else { return }
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: gradientCard_Breeze.bounds)
        gradientCard_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        headerGradient_Breeze = gradient_breeze
    }
    
    /// 更新分段指示器位置
    /// - Parameter animated: 是否动画
    private func updateSegmentIndicator_Breeze(animated: Bool) {
        guard !segmentContainer_Breeze.bounds.isEmpty else { return }
        let halfWidth_breeze = segmentContainer_Breeze.bounds.width / 2
        let indicatorX_breeze: CGFloat = currentSegment_Breeze == 0 ? 4 : halfWidth_breeze
        let indicatorFrame_breeze = CGRect(
            x: indicatorX_breeze,
            y: 4,
            width: halfWidth_breeze - 4,
            height: segmentContainer_Breeze.bounds.height - 8
        )
        
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                self.segIndicator_Breeze.frame = indicatorFrame_breeze
            }
        } else {
            segIndicator_Breeze.frame = indicatorFrame_breeze
        }
        
        // 更新按钮文字颜色
        segMyPosts_Breeze.tintColor = currentSegment_Breeze == 0
            ? ColorConfig_Breeze.primaryGradientStart_Breeze
            : ColorConfig_Breeze.textPlaceholder_Breeze
        segLiked_Breeze.tintColor = currentSegment_Breeze == 1
            ? ColorConfig_Breeze.primaryGradientStart_Breeze
            : ColorConfig_Breeze.textPlaceholder_Breeze
    }
    
    // MARK: - 数据配置
    
    /// 配置区头展示数据
    /// - Parameter selectedSegment_breeze: 当前选中分段（0=My Posts / 1=Liked）
    func configure_Breeze(selectedSegment_breeze: Int) {
        let user_breeze = UserViewModel_Breeze.shared_Breeze.getCurrentUser_Breeze()
        nameLabel_Breeze.text = user_breeze.userName_Breeze ?? "Guest"
        introLabel_Breeze.text = user_breeze.userIntroduce_Breeze ?? "Wandering through the woods"
        avatarView_Breeze.loadCurrentUserAvatar_Breeze()
        
        // 统计数据
        let prew_breeze = PrewUserModel_Breeze()
        prew_breeze.userId_Breeze = user_breeze.userId_Breeze
        let postsCount_breeze = TitleViewModel_Breeze.shared_Breeze.getUserPosts_Breeze(user_breeze: prew_breeze).count
        postsStatView_Breeze.update_Breeze(value_breeze: postsCount_breeze)
        likesStatView_Breeze.update_Breeze(value_breeze: user_breeze.userLike_Breeze.count)
        followStatView_Breeze.update_Breeze(value_breeze: user_breeze.userFollow_Breeze.count)
        
        currentSegment_Breeze = selectedSegment_breeze
        updateSegmentIndicator_Breeze(animated: false)
    }
    
    // MARK: - 事件
    
    @objc private func handleSettings_Breeze() { onSettings_Breeze?() }
    @objc private func handleEdit_Breeze() { onEdit_Breeze?() }
    @objc private func handleAvatarTap_Breeze() { onAvatarTap_Breeze?() }
    
    /// 分段按钮点击
    @objc private func handleSegTap_Breeze(_ sender: UIButton) {
        guard sender.tag != currentSegment_Breeze else { return }
        currentSegment_Breeze = sender.tag
        updateSegmentIndicator_Breeze(animated: true)
        onSegmentChange_Breeze?(currentSegment_Breeze)
    }
    
    // MARK: - 工厂方法
    
    /// 创建统计分割线
    private static func makeDivider_Breeze() -> UIView {
        let v_breeze = UIView()
        v_breeze.backgroundColor = ColorConfig_Breeze.divider_Breeze
        return v_breeze
    }
}

// MARK: - 统计项视图

/// 统计项视图（数字 + 标题，数字使用主题青绿色）
/// 核心作用：展示 Posts / Likes / Following 等统计数据
class MeStatItem_Breeze: UIView {
    
    /// 数值标签（青绿主题色）
    private let valueLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label_breeze.textColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 标题标签
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 初始化
    /// - Parameter title_breeze: 统计标题（英文）
    init(title_breeze: String) {
        super.init(frame: .zero)
        titleLabel_Breeze.text = title_breeze
        addSubview(valueLabel_Breeze)
        addSubview(titleLabel_Breeze)
        valueLabel_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
        }
        titleLabel_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(valueLabel_Breeze.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新统计数值
    func update_Breeze(value_breeze: Int) {
        valueLabel_Breeze.text = "\(value_breeze)"
    }
    
    /// 更新统计数值（兼容旧调用方 setValue_Breeze）
    func setValue_Breeze(value_breeze: Int) {
        update_Breeze(value_breeze: value_breeze)
    }
}

// MARK: - StatItemView_Breeze 保留别名（向下兼容）

/// 旧统计项视图别名，保持历史引用兼容
typealias StatItemView_Breeze = MeStatItem_Breeze
