import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Moode: 通话用户信息
/// - rippleAnimationLayers_Moode: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Moode: 设置水波纹动画
/// - hangUpCall_Moode: 挂断通话
class VideoChat_Moode: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Moode: PrewUserModel_Moode?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Moode: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Moode: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.contentMode = .scaleAspectFill
        imageView_Moode.clipsToBounds = true
        return imageView_Moode
    }()
    
    /// 模糊效果
    private let blurEffectView_Moode: UIVisualEffectView = {
        let blurEffect_Moode = UIBlurEffect(style: .dark)
        let effectView_Moode = UIVisualEffectView(effect: blurEffect_Moode)
        return effectView_Moode
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Moode: UIView = {
        let view_Moode = UIView()
        return view_Moode
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Moode: UIView = {
        let view_Moode = UIView()
        return view_Moode
    }()
    
    /// 用户头像
    private let avatarImageView_Moode: UIImageView = {
        let imageView_Moode = UIImageView()
        imageView_Moode.contentMode = .scaleAspectFill
        imageView_Moode.clipsToBounds = true
        imageView_Moode.layer.cornerRadius = 63
        imageView_Moode.layer.borderWidth = 4
        imageView_Moode.layer.borderColor = UIColor.white.cgColor
        return imageView_Moode
    }()
    
    /// 用户名标签
    private let usernameLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.textColor = .white
        label_Moode.textAlignment = .center
        return label_Moode
    }()
    
    /// 状态标签
    private let statusLabel_Moode: UILabel = {
        let label_Moode = UILabel()
        label_Moode.text = "Calling..."
        label_Moode.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Moode.textAlignment = .center
        return label_Moode
    }()
    
    /// 挂断按钮
    private let hangUpButton_Moode: UIButton = {
        let button_Moode = UIButton(type: .system)
        button_Moode.backgroundColor = UIColor(hexstring_Moode: "#FF6B9D")
        button_Moode.layer.cornerRadius = 35
        button_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#FF6B9D").cgColor
        button_Moode.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Moode.layer.shadowOpacity = 0.4
        button_Moode.layer.shadowRadius = 16
        
        let config_Moode = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Moode = UIImage(systemName: "phone.down.fill", withConfiguration: config_Moode)
        button_Moode.setImage(image_Moode, for: .normal)
        button_Moode.tintColor = .white
        
        return button_Moode
    }()
    
    /// 举报按钮
    private lazy var reportButton_Moode: UIButton = {
        let button_Moode = ReportDeleteHelper_Moode.createUserReportButton_Moode(
            size_Moode: 44,
            backgroundColor_Moode: UIColor.white.withAlphaComponent(0.2),
            tintColor_Moode: .white,
            withShadow_Moode: true
        )
        return button_Moode
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Moode()
        setupActions_Moode()
        setupAnimations_Moode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Moode()
        startSwayAnimation_Moode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Moode()
    }
    
    deinit {
        swayAnimationTimer_Moode?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Moode() {
        // 添加背景
        view.addSubview(backgroundImageView_Moode)
        view.addSubview(blurEffectView_Moode)
        view.addSubview(gradientOverlay_Moode)
        
        // 设置渐变遮罩
        setupGradientOverlay_Moode()
        
        // 添加内容
        view.addSubview(avatarContainerView_Moode)
        view.addSubview(usernameLabel_Moode)
        view.addSubview(statusLabel_Moode)
        view.addSubview(hangUpButton_Moode)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Moode()
        
        // 添加举报按钮
        view.addSubview(reportButton_Moode)
        
        // 加载用户数据
        if let userModel_Moode = userModel_Moode {
            usernameLabel_Moode.text = userModel_Moode.userName_Moode
            
            if let imageName_Moode = userModel_Moode.userHead_Moode {
                avatarImageView_Moode.image = UIImage(named: imageName_Moode)
                backgroundImageView_Moode.image = UIImage(named: imageName_Moode)
            }
        }
        
        setupConstraints_Moode()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Moode() {
        let gradientLayer_Moode = CAGradientLayer()
        gradientLayer_Moode.frame = view.bounds
        gradientLayer_Moode.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Moode.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Moode.layer.addSublayer(gradientLayer_Moode)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Moode() {
        avatarContainerView_Moode.addSubview(avatarImageView_Moode)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_Moode = CAShapeLayer()
            let circlePath_Moode = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Moode.path = circlePath_Moode.cgPath
            rippleLayer_Moode.strokeColor = ColorConfig_Moode.primaryGradientStart_Moode.cgColor
            rippleLayer_Moode.fillColor = UIColor.clear.cgColor
            rippleLayer_Moode.lineWidth = 2
            rippleLayer_Moode.opacity = 0
            
            avatarContainerView_Moode.layer.insertSublayer(rippleLayer_Moode, at: 0)
            rippleAnimationLayers_Moode.append(rippleLayer_Moode)
        }
        
        avatarImageView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Moode() {
        // 背景图片
        backgroundImageView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Moode.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Moode.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Moode() {
        hangUpButton_Moode.addTarget(self, action: #selector(hangUpCall_Moode), for: .touchUpInside)
        reportButton_Moode.addTarget(self, action: #selector(reportTapped_Moode), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Moode() {
        // 头像渐入动画
        avatarContainerView_Moode.alpha = 0
        avatarContainerView_Moode.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Moode.alpha = 1
            self.avatarContainerView_Moode.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Moode.alpha = 0
        statusLabel_Moode.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Moode.alpha = 1
            self.statusLabel_Moode.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Moode.alpha = 0
        hangUpButton_Moode.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Moode.alpha = 1
            self.hangUpButton_Moode.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Moode() {
        for (index_Moode, layer_Moode) in rippleAnimationLayers_Moode.enumerated() {
            let scaleAnimation_Moode = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Moode.fromValue = 1.0
            scaleAnimation_Moode.toValue = 1.8
            
            let opacityAnimation_Moode = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Moode.fromValue = 0.6
            opacityAnimation_Moode.toValue = 0
            
            let animationGroup_Moode = CAAnimationGroup()
            animationGroup_Moode.animations = [scaleAnimation_Moode, opacityAnimation_Moode]
            animationGroup_Moode.duration = 2.0
            animationGroup_Moode.repeatCount = .infinity
            animationGroup_Moode.beginTime = CACurrentMediaTime() + Double(index_Moode) * 0.66
            
            layer_Moode.add(animationGroup_Moode, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Moode() {
        let swayAnimation_Moode = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Moode.fromValue = -0.05
        swayAnimation_Moode.toValue = 0.05
        swayAnimation_Moode.duration = 0.8
        swayAnimation_Moode.autoreverses = true
        swayAnimation_Moode.repeatCount = .infinity
        swayAnimation_Moode.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Moode.layer.add(swayAnimation_Moode, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Moode() {
        for layer_Moode in rippleAnimationLayers_Moode {
            layer_Moode.removeAllAnimations()
        }
        hangUpButton_Moode.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Moode() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Moode.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Moode.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Moode() {
        guard let userModel_Moode = userModel_Moode else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Moode.block_Moode(
            user_Moode: userModel_Moode,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
