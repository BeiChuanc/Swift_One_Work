import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Sprig: 通话用户信息
/// - rippleAnimationLayers_Sprig: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Sprig: 设置水波纹动画
/// - hangUpCall_Sprig: 挂断通话
class VideoChat_Sprig: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Sprig: PrewUserModel_Sprig?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Sprig: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Sprig: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.contentMode = .scaleAspectFill
        imageView_Sprig.clipsToBounds = true
        return imageView_Sprig
    }()
    
    /// 模糊效果
    private let blurEffectView_Sprig: UIVisualEffectView = {
        let blurEffect_Sprig = UIBlurEffect(style: .dark)
        let effectView_Sprig = UIVisualEffectView(effect: blurEffect_Sprig)
        return effectView_Sprig
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Sprig: UIView = {
        let view_Sprig = UIView()
        return view_Sprig
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Sprig: UIView = {
        let view_Sprig = UIView()
        return view_Sprig
    }()
    
    /// 用户头像
    private let avatarImageView_Sprig: UIImageView = {
        let imageView_Sprig = UIImageView()
        imageView_Sprig.contentMode = .scaleAspectFill
        imageView_Sprig.clipsToBounds = true
        imageView_Sprig.layer.cornerRadius = 63
        imageView_Sprig.layer.borderWidth = 4
        imageView_Sprig.layer.borderColor = UIColor.white.cgColor
        return imageView_Sprig
    }()
    
    /// 用户名标签
    private let usernameLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.textColor = .white
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()
    
    /// 状态标签
    private let statusLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Calling..."
        label_Sprig.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()
    
    /// 挂断按钮
    private let hangUpButton_Sprig: UIButton = {
        let button_Sprig = UIButton(type: .system)
        button_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#BE92FD")
        button_Sprig.layer.cornerRadius = 25
        button_Sprig.layer.shadowColor = UIColor(hexstring_Sprig: "#FF6B9D").cgColor
        button_Sprig.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Sprig.layer.shadowOpacity = 0.4
        button_Sprig.layer.shadowRadius = 16
        
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Sprig = UIImage(systemName: "phone.down.fill", withConfiguration: config_Sprig)
        button_Sprig.setImage(image_Sprig, for: .normal)
        button_Sprig.tintColor = .white
        
        return button_Sprig
    }()
    
    /// 举报按钮
    private lazy var reportButton_Sprig: UIButton = {
        let button_Sprig = ReportDeleteHelper_Sprig.createUserReportButton_Sprig(
            size_Sprig: 44,
            backgroundColor_Sprig: UIColor.white.withAlphaComponent(0.2),
            tintColor_Sprig: .white,
            withShadow_Sprig: true
        )
        return button_Sprig
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sprig()
        setupActions_Sprig()
        setupAnimations_Sprig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Sprig()
        startSwayAnimation_Sprig()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Sprig()
    }
    
    deinit {
        swayAnimationTimer_Sprig?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Sprig() {
        // 添加背景
        view.addSubview(backgroundImageView_Sprig)
        view.addSubview(blurEffectView_Sprig)
        view.addSubview(gradientOverlay_Sprig)
        
        // 设置渐变遮罩
        setupGradientOverlay_Sprig()
        
        // 添加内容
        view.addSubview(avatarContainerView_Sprig)
        view.addSubview(usernameLabel_Sprig)
        view.addSubview(statusLabel_Sprig)
        view.addSubview(hangUpButton_Sprig)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Sprig()
        
        // 添加举报按钮
        view.addSubview(reportButton_Sprig)
        
        // 加载用户数据
        if let userModel_Sprig = userModel_Sprig {
            usernameLabel_Sprig.text = userModel_Sprig.userName_Sprig
            
            if let imageName_Sprig = userModel_Sprig.userHead_Sprig {
                avatarImageView_Sprig.image = UIImage(named: imageName_Sprig)
                backgroundImageView_Sprig.image = UIImage(named: imageName_Sprig)
            }
        }
        
        setupConstraints_Sprig()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Sprig() {
        let gradientLayer_Sprig = CAGradientLayer()
        gradientLayer_Sprig.frame = view.bounds
        gradientLayer_Sprig.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Sprig.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Sprig.layer.addSublayer(gradientLayer_Sprig)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Sprig() {
        avatarContainerView_Sprig.addSubview(avatarImageView_Sprig)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_Sprig = CAShapeLayer()
            let circlePath_Sprig = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Sprig.path = circlePath_Sprig.cgPath
            rippleLayer_Sprig.strokeColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
            rippleLayer_Sprig.fillColor = UIColor.clear.cgColor
            rippleLayer_Sprig.lineWidth = 2
            rippleLayer_Sprig.opacity = 0
            
            avatarContainerView_Sprig.layer.insertSublayer(rippleLayer_Sprig, at: 0)
            rippleAnimationLayers_Sprig.append(rippleLayer_Sprig)
        }
        
        avatarImageView_Sprig.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Sprig() {
        // 背景图片
        backgroundImageView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Sprig.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Sprig.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Sprig.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Sprig.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Sprig.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Sprig.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Sprig() {
        hangUpButton_Sprig.addTarget(self, action: #selector(hangUpCall_Sprig), for: .touchUpInside)
        reportButton_Sprig.addTarget(self, action: #selector(reportTapped_Sprig), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Sprig() {
        // 头像渐入动画
        avatarContainerView_Sprig.alpha = 0
        avatarContainerView_Sprig.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Sprig.alpha = 1
            self.avatarContainerView_Sprig.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Sprig.alpha = 0
        statusLabel_Sprig.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Sprig.alpha = 1
            self.statusLabel_Sprig.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Sprig.alpha = 0
        hangUpButton_Sprig.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Sprig.alpha = 1
            self.hangUpButton_Sprig.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Sprig() {
        for (index_Sprig, layer_Sprig) in rippleAnimationLayers_Sprig.enumerated() {
            let scaleAnimation_Sprig = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Sprig.fromValue = 1.0
            scaleAnimation_Sprig.toValue = 1.8
            
            let opacityAnimation_Sprig = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Sprig.fromValue = 0.6
            opacityAnimation_Sprig.toValue = 0
            
            let animationGroup_Sprig = CAAnimationGroup()
            animationGroup_Sprig.animations = [scaleAnimation_Sprig, opacityAnimation_Sprig]
            animationGroup_Sprig.duration = 2.0
            animationGroup_Sprig.repeatCount = .infinity
            animationGroup_Sprig.beginTime = CACurrentMediaTime() + Double(index_Sprig) * 0.66
            
            layer_Sprig.add(animationGroup_Sprig, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Sprig() {
        let swayAnimation_Sprig = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Sprig.fromValue = -0.05
        swayAnimation_Sprig.toValue = 0.05
        swayAnimation_Sprig.duration = 0.8
        swayAnimation_Sprig.autoreverses = true
        swayAnimation_Sprig.repeatCount = .infinity
        swayAnimation_Sprig.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Sprig.layer.add(swayAnimation_Sprig, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Sprig() {
        for layer_Sprig in rippleAnimationLayers_Sprig {
            layer_Sprig.removeAllAnimations()
        }
        hangUpButton_Sprig.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Sprig() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Sprig.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Sprig.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Sprig() {
        guard let userModel_Sprig = userModel_Sprig else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Sprig.block_Sprig(
            user_Sprig: userModel_Sprig,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
