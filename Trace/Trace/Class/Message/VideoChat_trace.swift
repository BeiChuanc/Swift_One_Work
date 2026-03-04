import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Trace: 通话用户信息
/// - rippleAnimationLayers_Trace: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Trace: 设置水波纹动画
/// - hangUpCall_Trace: 挂断通话
class VideoChat_Trace: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Trace: PrewUserModel_Trace?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Trace: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Trace: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Trace: UIImageView = {
        let imageView_Trace = UIImageView()
        imageView_Trace.contentMode = .scaleAspectFill
        imageView_Trace.clipsToBounds = true
        return imageView_Trace
    }()
    
    /// 模糊效果
    private let blurEffectView_Trace: UIVisualEffectView = {
        let blurEffect_Trace = UIBlurEffect(style: .dark)
        let effectView_Trace = UIVisualEffectView(effect: blurEffect_Trace)
        return effectView_Trace
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Trace: UIView = {
        let view_Trace = UIView()
        return view_Trace
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Trace: UIView = {
        let view_Trace = UIView()
        return view_Trace
    }()
    
    /// 用户头像
    private let avatarImageView_Trace: UserAvatarView_Trace = {
        let avatarView_Trace = UserAvatarView_Trace()
        avatarView_Trace.layer.borderWidth = 4
        avatarView_Trace.layer.borderColor = UIColor.white.cgColor
        return avatarView_Trace
    }()
    
    /// 用户名标签
    private let usernameLabel_Trace: UILabel = {
        let label_Trace = UILabel()
        label_Trace.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_Trace.textColor = .white
        label_Trace.textAlignment = .center
        return label_Trace
    }()
    
    /// 状态标签
    private let statusLabel_Trace: UILabel = {
        let label_Trace = UILabel()
        label_Trace.text = "Calling..."
        label_Trace.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label_Trace.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Trace.textAlignment = .center
        return label_Trace
    }()
    
    /// 挂断按钮
    private let hangUpButton_Trace: UIButton = {
        let button_Trace = UIButton(type: .system)
        button_Trace.backgroundColor = UIColor(hexstring_Trace: "#FF6B9D")
        button_Trace.layer.cornerRadius = 35
        button_Trace.layer.shadowColor = UIColor(hexstring_Trace: "#FF6B9D").cgColor
        button_Trace.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Trace.layer.shadowOpacity = 0.4
        button_Trace.layer.shadowRadius = 16
        
        let config_Trace = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Trace = UIImage(systemName: "phone.down.fill", withConfiguration: config_Trace)
        button_Trace.setImage(image_Trace, for: .normal)
        button_Trace.tintColor = .white
        
        return button_Trace
    }()
    
    /// 举报按钮
    private lazy var reportButton_Trace: UIButton = {
        let button_Trace = ReportDeleteHelper_Trace.createUserReportButton_Trace(
            size_Trace: 44,
            backgroundColor_Trace: UIColor.white.withAlphaComponent(0.2),
            tintColor_Trace: .white,
            withShadow_Trace: true
        )
        return button_Trace
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Trace()
        setupActions_Trace()
        setupAnimations_Trace()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Trace()
        startSwayAnimation_Trace()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Trace()
    }
    
    deinit {
        swayAnimationTimer_Trace?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Trace() {
        // 添加背景
        view.addSubview(backgroundImageView_Trace)
        view.addSubview(blurEffectView_Trace)
        view.addSubview(gradientOverlay_Trace)
        
        // 设置渐变遮罩
        setupGradientOverlay_Trace()
        
        // 添加内容
        view.addSubview(avatarContainerView_Trace)
        view.addSubview(usernameLabel_Trace)
        view.addSubview(statusLabel_Trace)
        view.addSubview(hangUpButton_Trace)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Trace()
        
        // 添加举报按钮
        view.addSubview(reportButton_Trace)
        
        // 加载用户数据
        if let userModel_Trace = userModel_Trace {
            usernameLabel_Trace.text = userModel_Trace.userName_Trace
            
            // 配置头像
            avatarImageView_Trace.configure_Trace(userId_Trace: userModel_Trace.userId_Trace ?? 0)
            
            // 设置背景图（尝试加载头像路径）
            if let imageName_Trace = userModel_Trace.userHead_Trace {
                if let assetImage_Trace = UIImage(named: imageName_Trace) {
                    backgroundImageView_Trace.image = assetImage_Trace
                } else if let localImage_Trace = UIImage(contentsOfFile: imageName_Trace) {
                    backgroundImageView_Trace.image = localImage_Trace
                }
            }
        }
        
        setupConstraints_Trace()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Trace() {
        let gradientLayer_Trace = CAGradientLayer()
        gradientLayer_Trace.frame = view.bounds
        gradientLayer_Trace.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Trace.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Trace.layer.addSublayer(gradientLayer_Trace)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Trace() {
        avatarContainerView_Trace.addSubview(avatarImageView_Trace)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_Trace = CAShapeLayer()
            let circlePath_Trace = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Trace.path = circlePath_Trace.cgPath
            rippleLayer_Trace.strokeColor = ColorConfig_Trace.primaryGradientStart_Trace.cgColor
            rippleLayer_Trace.fillColor = UIColor.clear.cgColor
            rippleLayer_Trace.lineWidth = 2
            rippleLayer_Trace.opacity = 0
            
            avatarContainerView_Trace.layer.insertSublayer(rippleLayer_Trace, at: 0)
            rippleAnimationLayers_Trace.append(rippleLayer_Trace)
        }
        
        avatarImageView_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
        
        // 设置头像圆角
        avatarImageView_Trace.layer.cornerRadius = 63
        avatarImageView_Trace.clipsToBounds = true
    }
    
    /// 设置约束
    private func setupConstraints_Trace() {
        // 背景图片
        backgroundImageView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Trace.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Trace.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Trace() {
        hangUpButton_Trace.addTarget(self, action: #selector(hangUpCall_Trace), for: .touchUpInside)
        reportButton_Trace.addTarget(self, action: #selector(reportTapped_Trace), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Trace() {
        // 头像渐入动画
        avatarContainerView_Trace.alpha = 0
        avatarContainerView_Trace.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Trace.alpha = 1
            self.avatarContainerView_Trace.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Trace.alpha = 0
        statusLabel_Trace.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Trace.alpha = 1
            self.statusLabel_Trace.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Trace.alpha = 0
        hangUpButton_Trace.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Trace.alpha = 1
            self.hangUpButton_Trace.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Trace() {
        for (index_Trace, layer_Trace) in rippleAnimationLayers_Trace.enumerated() {
            let scaleAnimation_Trace = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Trace.fromValue = 1.0
            scaleAnimation_Trace.toValue = 1.8
            
            let opacityAnimation_Trace = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Trace.fromValue = 0.6
            opacityAnimation_Trace.toValue = 0
            
            let animationGroup_Trace = CAAnimationGroup()
            animationGroup_Trace.animations = [scaleAnimation_Trace, opacityAnimation_Trace]
            animationGroup_Trace.duration = 2.0
            animationGroup_Trace.repeatCount = .infinity
            animationGroup_Trace.beginTime = CACurrentMediaTime() + Double(index_Trace) * 0.66
            
            layer_Trace.add(animationGroup_Trace, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Trace() {
        let swayAnimation_Trace = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Trace.fromValue = -0.05
        swayAnimation_Trace.toValue = 0.05
        swayAnimation_Trace.duration = 0.8
        swayAnimation_Trace.autoreverses = true
        swayAnimation_Trace.repeatCount = .infinity
        swayAnimation_Trace.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Trace.layer.add(swayAnimation_Trace, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Trace() {
        for layer_Trace in rippleAnimationLayers_Trace {
            layer_Trace.removeAllAnimations()
        }
        hangUpButton_Trace.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Trace() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Trace.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Trace.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Trace() {
        guard let userModel_Trace = userModel_Trace else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Trace.block_Trace(
            user_Trace: userModel_Trace,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
