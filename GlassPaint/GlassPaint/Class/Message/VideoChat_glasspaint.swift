import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Glasspaint: 通话用户信息
/// - rippleAnimationLayers_Glasspaint: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Glasspaint: 设置水波纹动画
/// - hangUpCall_Glasspaint: 挂断通话
class VideoChat_Glasspaint: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Glasspaint: PrewUserModel_Glasspaint?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Glasspaint: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Glasspaint: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        imageView_Glasspaint.contentMode = .scaleAspectFill
        imageView_Glasspaint.clipsToBounds = true
        return imageView_Glasspaint
    }()
    
    /// 模糊效果
    private let blurEffectView_Glasspaint: UIVisualEffectView = {
        let blurEffect_Glasspaint = UIBlurEffect(style: .dark)
        let effectView_Glasspaint = UIVisualEffectView(effect: blurEffect_Glasspaint)
        return effectView_Glasspaint
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        return view_Glasspaint
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        return view_Glasspaint
    }()
    
    /// 用户头像
    private let avatarImageView_Glasspaint: UserAvatarView_Glasspaint = {
        let avatarView_Glasspaint = UserAvatarView_Glasspaint()
        avatarView_Glasspaint.layer.borderWidth = 4
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        return avatarView_Glasspaint
    }()
    
    /// 用户名标签
    private let usernameLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label_Glasspaint.textColor = .white
        label_Glasspaint.textAlignment = .center
        return label_Glasspaint
    }()
    
    /// 状态标签
    private let statusLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.text = "Calling..."
        label_Glasspaint.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label_Glasspaint.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Glasspaint.textAlignment = .center
        return label_Glasspaint
    }()
    
    /// 挂断按钮
    private let hangUpButton_Glasspaint: UIButton = {
        let button_Glasspaint = UIButton(type: .system)
        button_Glasspaint.backgroundColor = UIColor(hexstring_Glasspaint: "#FF6B9D")
        button_Glasspaint.layer.cornerRadius = 35
        button_Glasspaint.layer.shadowColor = UIColor(hexstring_Glasspaint: "#FF6B9D").cgColor
        button_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Glasspaint.layer.shadowOpacity = 0.4
        button_Glasspaint.layer.shadowRadius = 16
        
        let config_Glasspaint = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Glasspaint = UIImage(systemName: "phone.down.fill", withConfiguration: config_Glasspaint)
        button_Glasspaint.setImage(image_Glasspaint, for: .normal)
        button_Glasspaint.tintColor = .white
        
        return button_Glasspaint
    }()
    
    /// 举报按钮
    private lazy var reportButton_Glasspaint: UIButton = {
        let button_Glasspaint = ReportDeleteHelper_Glasspaint.createUserReportButton_Glasspaint(
            size_Glasspaint: 44,
            backgroundColor_Glasspaint: UIColor.white.withAlphaComponent(0.2),
            tintColor_Glasspaint: .white,
            withShadow_Glasspaint: true
        )
        return button_Glasspaint
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupActions_Glasspaint()
        setupAnimations_Glasspaint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Glasspaint()
        startSwayAnimation_Glasspaint()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Glasspaint()
    }
    
    deinit {
        swayAnimationTimer_Glasspaint?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        // 添加背景
        view.addSubview(backgroundImageView_Glasspaint)
        view.addSubview(blurEffectView_Glasspaint)
        view.addSubview(gradientOverlay_Glasspaint)
        
        // 设置渐变遮罩
        setupGradientOverlay_Glasspaint()
        
        // 添加内容
        view.addSubview(avatarContainerView_Glasspaint)
        view.addSubview(usernameLabel_Glasspaint)
        view.addSubview(statusLabel_Glasspaint)
        view.addSubview(hangUpButton_Glasspaint)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Glasspaint()
        
        // 添加举报按钮
        view.addSubview(reportButton_Glasspaint)
        
        // 加载用户数据
        if let userModel_Glasspaint = userModel_Glasspaint {
            usernameLabel_Glasspaint.text = userModel_Glasspaint.userName_Glasspaint
            
            // 配置头像
            avatarImageView_Glasspaint.configure_Glasspaint(userId_Glasspaint: userModel_Glasspaint.userId_Glasspaint ?? 0)
            
            // 设置背景图（尝试加载头像路径）
            if let imageName_Glasspaint = userModel_Glasspaint.userHead_Glasspaint {
                if let assetImage_Glasspaint = UIImage(named: imageName_Glasspaint) {
                    backgroundImageView_Glasspaint.image = assetImage_Glasspaint
                } else if let localImage_Glasspaint = UIImage(contentsOfFile: imageName_Glasspaint) {
                    backgroundImageView_Glasspaint.image = localImage_Glasspaint
                }
            }
        }
        
        setupConstraints_Glasspaint()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Glasspaint() {
        let gradientLayer_Glasspaint = CAGradientLayer()
        gradientLayer_Glasspaint.frame = view.bounds
        gradientLayer_Glasspaint.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Glasspaint.layer.addSublayer(gradientLayer_Glasspaint)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Glasspaint() {
        avatarContainerView_Glasspaint.addSubview(avatarImageView_Glasspaint)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_Glasspaint = CAShapeLayer()
            let circlePath_Glasspaint = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Glasspaint.path = circlePath_Glasspaint.cgPath
            rippleLayer_Glasspaint.strokeColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
            rippleLayer_Glasspaint.fillColor = UIColor.clear.cgColor
            rippleLayer_Glasspaint.lineWidth = 2
            rippleLayer_Glasspaint.opacity = 0
            
            avatarContainerView_Glasspaint.layer.insertSublayer(rippleLayer_Glasspaint, at: 0)
            rippleAnimationLayers_Glasspaint.append(rippleLayer_Glasspaint)
        }
        
        avatarImageView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
        
        // 设置头像圆角
        avatarImageView_Glasspaint.layer.cornerRadius = 63
        avatarImageView_Glasspaint.clipsToBounds = true
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        // 背景图片
        backgroundImageView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Glasspaint.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Glasspaint.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Glasspaint() {
        hangUpButton_Glasspaint.addTarget(self, action: #selector(hangUpCall_Glasspaint), for: .touchUpInside)
        reportButton_Glasspaint.addTarget(self, action: #selector(reportTapped_Glasspaint), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Glasspaint() {
        // 头像渐入动画
        avatarContainerView_Glasspaint.alpha = 0
        avatarContainerView_Glasspaint.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Glasspaint.alpha = 1
            self.avatarContainerView_Glasspaint.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Glasspaint.alpha = 0
        statusLabel_Glasspaint.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Glasspaint.alpha = 1
            self.statusLabel_Glasspaint.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Glasspaint.alpha = 0
        hangUpButton_Glasspaint.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Glasspaint.alpha = 1
            self.hangUpButton_Glasspaint.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Glasspaint() {
        for (index_Glasspaint, layer_Glasspaint) in rippleAnimationLayers_Glasspaint.enumerated() {
            let scaleAnimation_Glasspaint = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Glasspaint.fromValue = 1.0
            scaleAnimation_Glasspaint.toValue = 1.8
            
            let opacityAnimation_Glasspaint = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Glasspaint.fromValue = 0.6
            opacityAnimation_Glasspaint.toValue = 0
            
            let animationGroup_Glasspaint = CAAnimationGroup()
            animationGroup_Glasspaint.animations = [scaleAnimation_Glasspaint, opacityAnimation_Glasspaint]
            animationGroup_Glasspaint.duration = 2.0
            animationGroup_Glasspaint.repeatCount = .infinity
            animationGroup_Glasspaint.beginTime = CACurrentMediaTime() + Double(index_Glasspaint) * 0.66
            
            layer_Glasspaint.add(animationGroup_Glasspaint, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Glasspaint() {
        let swayAnimation_Glasspaint = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Glasspaint.fromValue = -0.05
        swayAnimation_Glasspaint.toValue = 0.05
        swayAnimation_Glasspaint.duration = 0.8
        swayAnimation_Glasspaint.autoreverses = true
        swayAnimation_Glasspaint.repeatCount = .infinity
        swayAnimation_Glasspaint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Glasspaint.layer.add(swayAnimation_Glasspaint, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Glasspaint() {
        for layer_Glasspaint in rippleAnimationLayers_Glasspaint {
            layer_Glasspaint.removeAllAnimations()
        }
        hangUpButton_Glasspaint.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Glasspaint() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Glasspaint.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Glasspaint() {
        guard let userModel_Glasspaint = userModel_Glasspaint else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Glasspaint.block_Glasspaint(
            user_Glasspaint: userModel_Glasspaint,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
