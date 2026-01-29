import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Wanderbell: 通话用户信息
/// - rippleAnimationLayers_Wanderbell: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Wanderbell: 设置水波纹动画
/// - hangUpCall_Wanderbell: 挂断通话
class VideoChat_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Wanderbell: PrewUserModel_Wanderbell?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Wanderbell: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Wanderbell: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        return imageView_wanderbell
    }()
    
    /// 模糊效果
    private let blurEffectView_Wanderbell: UIVisualEffectView = {
        let blurEffect_wanderbell = UIBlurEffect(style: .dark)
        let effectView_wanderbell = UIVisualEffectView(effect: blurEffect_wanderbell)
        return effectView_wanderbell
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        return view_wanderbell
    }()
    
    /// 用户头像
    private let avatarImageView_Wanderbell: UIImageView = {
        let imageView_wanderbell = UIImageView()
        imageView_wanderbell.contentMode = .scaleAspectFill
        imageView_wanderbell.clipsToBounds = true
        imageView_wanderbell.layer.cornerRadius = 63
        imageView_wanderbell.layer.borderWidth = 4
        imageView_wanderbell.layer.borderColor = UIColor.white.cgColor
        return imageView_wanderbell
    }()
    
    /// 用户名标签
    private let usernameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title1_Wanderbell()
        label_wanderbell.textColor = .white
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 状态标签
    private let statusLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Calling..."
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = UIColor.white.withAlphaComponent(0.8)
        label_wanderbell.textAlignment = .center
        return label_wanderbell
    }()
    
    /// 挂断按钮
    private let hangUpButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .system)
        button_wanderbell.backgroundColor = UIColor(hexstring_Wanderbell: "#FF6B9D")
        button_wanderbell.layer.cornerRadius = 35
        button_wanderbell.layer.shadowColor = UIColor(hexstring_Wanderbell: "#FF6B9D").cgColor
        button_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_wanderbell.layer.shadowOpacity = 0.4
        button_wanderbell.layer.shadowRadius = 16
        
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_wanderbell = UIImage(systemName: "phone.down.fill", withConfiguration: config_wanderbell)
        button_wanderbell.setImage(image_wanderbell, for: .normal)
        button_wanderbell.tintColor = .white
        
        return button_wanderbell
    }()
    
    /// 举报按钮
    private lazy var reportButton_Wanderbell: UIButton = {
        let button_wanderbell = ReportDeleteHelper_Wanderbell.createUserReportButton_Wanderbell(
            size_wanderbell: 44,
            backgroundColor_wanderbell: UIColor.white.withAlphaComponent(0.2),
            tintColor_wanderbell: .white,
            withShadow_wanderbell: true
        )
        return button_wanderbell
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupActions_Wanderbell()
        setupAnimations_Wanderbell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Wanderbell()
        startSwayAnimation_Wanderbell()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Wanderbell()
    }
    
    deinit {
        swayAnimationTimer_Wanderbell?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        // 添加背景
        view.addSubview(backgroundImageView_Wanderbell)
        view.addSubview(blurEffectView_Wanderbell)
        view.addSubview(gradientOverlay_Wanderbell)
        
        // 设置渐变遮罩
        setupGradientOverlay_Wanderbell()
        
        // 添加内容
        view.addSubview(avatarContainerView_Wanderbell)
        view.addSubview(usernameLabel_Wanderbell)
        view.addSubview(statusLabel_Wanderbell)
        view.addSubview(hangUpButton_Wanderbell)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Wanderbell()
        
        // 添加举报按钮
        view.addSubview(reportButton_Wanderbell)
        
        // 加载用户数据
        if let userModel_wanderbell = userModel_Wanderbell {
            usernameLabel_Wanderbell.text = userModel_wanderbell.userName_Wanderbell
            
            if let imageName_wanderbell = userModel_wanderbell.userHead_Wanderbell {
                avatarImageView_Wanderbell.image = UIImage(named: imageName_wanderbell)
                backgroundImageView_Wanderbell.image = UIImage(named: imageName_wanderbell)
            }
        }
        
        setupConstraints_Wanderbell()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Wanderbell() {
        let gradientLayer_wanderbell = CAGradientLayer()
        gradientLayer_wanderbell.frame = view.bounds
        gradientLayer_wanderbell.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_wanderbell.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Wanderbell.layer.addSublayer(gradientLayer_wanderbell)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Wanderbell() {
        avatarContainerView_Wanderbell.addSubview(avatarImageView_Wanderbell)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_wanderbell = CAShapeLayer()
            let circlePath_wanderbell = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_wanderbell.path = circlePath_wanderbell.cgPath
            rippleLayer_wanderbell.strokeColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell.cgColor
            rippleLayer_wanderbell.fillColor = UIColor.clear.cgColor
            rippleLayer_wanderbell.lineWidth = 2
            rippleLayer_wanderbell.opacity = 0
            
            avatarContainerView_Wanderbell.layer.insertSublayer(rippleLayer_wanderbell, at: 0)
            rippleAnimationLayers_Wanderbell.append(rippleLayer_wanderbell)
        }
        
        avatarImageView_Wanderbell.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        // 背景图片
        backgroundImageView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Wanderbell.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Wanderbell.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Wanderbell() {
        hangUpButton_Wanderbell.addTarget(self, action: #selector(hangUpCall_Wanderbell), for: .touchUpInside)
        reportButton_Wanderbell.addTarget(self, action: #selector(reportTapped_Wanderbell), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Wanderbell() {
        // 头像渐入动画
        avatarContainerView_Wanderbell.alpha = 0
        avatarContainerView_Wanderbell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Wanderbell.alpha = 1
            self.avatarContainerView_Wanderbell.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Wanderbell.alpha = 0
        statusLabel_Wanderbell.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Wanderbell.alpha = 1
            self.statusLabel_Wanderbell.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Wanderbell.alpha = 0
        hangUpButton_Wanderbell.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Wanderbell.alpha = 1
            self.hangUpButton_Wanderbell.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Wanderbell() {
        for (index_wanderbell, layer_wanderbell) in rippleAnimationLayers_Wanderbell.enumerated() {
            let scaleAnimation_wanderbell = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_wanderbell.fromValue = 1.0
            scaleAnimation_wanderbell.toValue = 1.8
            
            let opacityAnimation_wanderbell = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_wanderbell.fromValue = 0.6
            opacityAnimation_wanderbell.toValue = 0
            
            let animationGroup_wanderbell = CAAnimationGroup()
            animationGroup_wanderbell.animations = [scaleAnimation_wanderbell, opacityAnimation_wanderbell]
            animationGroup_wanderbell.duration = 2.0
            animationGroup_wanderbell.repeatCount = .infinity
            animationGroup_wanderbell.beginTime = CACurrentMediaTime() + Double(index_wanderbell) * 0.66
            
            layer_wanderbell.add(animationGroup_wanderbell, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Wanderbell() {
        let swayAnimation_wanderbell = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_wanderbell.fromValue = -0.05
        swayAnimation_wanderbell.toValue = 0.05
        swayAnimation_wanderbell.duration = 0.8
        swayAnimation_wanderbell.autoreverses = true
        swayAnimation_wanderbell.repeatCount = .infinity
        swayAnimation_wanderbell.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Wanderbell.layer.add(swayAnimation_wanderbell, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Wanderbell() {
        for layer_wanderbell in rippleAnimationLayers_Wanderbell {
            layer_wanderbell.removeAllAnimations()
        }
        hangUpButton_Wanderbell.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Wanderbell() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Wanderbell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Wanderbell.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Wanderbell() {
        guard let userModel_wanderbell = userModel_Wanderbell else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Wanderbell.block_Wanderbell(
            user_wanderbell: userModel_wanderbell,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
