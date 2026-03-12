import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Doze: 通话用户信息
/// - rippleAnimationLayers_Doze: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Doze: 设置水波纹动画
/// - hangUpCall_Doze: 挂断通话
class VideoChat_Doze: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Doze: PrewUserModel_Doze?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Doze: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Doze: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.contentMode = .scaleAspectFill
        imageView_Doze.clipsToBounds = true
        return imageView_Doze
    }()
    
    /// 模糊效果
    private let blurEffectView_Doze: UIVisualEffectView = {
        let blurEffect_Doze = UIBlurEffect(style: .dark)
        let effectView_Doze = UIVisualEffectView(effect: blurEffect_Doze)
        return effectView_Doze
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Doze: UIView = {
        let view_Doze = UIView()
        return view_Doze
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Doze: UIView = {
        let view_Doze = UIView()
        return view_Doze
    }()
    
    /// 用户头像
    private let avatarImageView_Doze: UIImageView = {
        let imageView_Doze = UIImageView()
        imageView_Doze.contentMode = .scaleAspectFill
        imageView_Doze.clipsToBounds = true
        imageView_Doze.layer.cornerRadius = 63
        imageView_Doze.layer.borderWidth = 4
        imageView_Doze.layer.borderColor = UIColor.white.cgColor
        return imageView_Doze
    }()
    
    /// 用户名标签
    private let usernameLabel_Doze: UILabel = {
        let label_Doze = UILabel()
        label_Doze.textColor = .white
        label_Doze.textAlignment = .center
        return label_Doze
    }()
    
    /// 状态标签
    private let statusLabel_Doze: UILabel = {
        let label_Doze = UILabel()
        label_Doze.text = "Calling..."
        label_Doze.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Doze.textAlignment = .center
        return label_Doze
    }()
    
    /// 挂断按钮
    private let hangUpButton_Doze: UIButton = {
        let button_Doze = UIButton(type: .system)
        button_Doze.backgroundColor = UIColor(hexstring_Doze: "#BE92FD")
        button_Doze.layer.cornerRadius = 25
        button_Doze.layer.shadowColor = UIColor(hexstring_Doze: "#FF6B9D").cgColor
        button_Doze.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Doze.layer.shadowOpacity = 0.4
        button_Doze.layer.shadowRadius = 16
        
        let config_Doze = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Doze = UIImage(systemName: "phone.down.fill", withConfiguration: config_Doze)
        button_Doze.setImage(image_Doze, for: .normal)
        button_Doze.tintColor = .white
        
        return button_Doze
    }()
    
    /// 举报按钮
    private lazy var reportButton_Doze: UIButton = {
        let button_Doze = ReportDeleteHelper_Doze.createUserReportButton_Doze(
            size_Doze: 44,
            backgroundColor_Doze: UIColor.white.withAlphaComponent(0.2),
            tintColor_Doze: .white,
            withShadow_Doze: true
        )
        return button_Doze
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Doze()
        setupActions_Doze()
        setupAnimations_Doze()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Doze()
        startSwayAnimation_Doze()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Doze()
    }
    
    deinit {
        swayAnimationTimer_Doze?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Doze() {
        // 添加背景
        view.addSubview(backgroundImageView_Doze)
        view.addSubview(blurEffectView_Doze)
        view.addSubview(gradientOverlay_Doze)
        
        // 设置渐变遮罩
        setupGradientOverlay_Doze()
        
        // 添加内容
        view.addSubview(avatarContainerView_Doze)
        view.addSubview(usernameLabel_Doze)
        view.addSubview(statusLabel_Doze)
        view.addSubview(hangUpButton_Doze)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Doze()
        
        // 添加举报按钮
        view.addSubview(reportButton_Doze)
        
        // 加载用户数据
        if let userModel_Doze = userModel_Doze {
            usernameLabel_Doze.text = userModel_Doze.userName_Doze
            
            if let imageName_Doze = userModel_Doze.userHead_Doze {
                avatarImageView_Doze.image = UIImage(named: imageName_Doze)
                backgroundImageView_Doze.image = UIImage(named: imageName_Doze)
            }
        }
        
        setupConstraints_Doze()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Doze() {
        let gradientLayer_Doze = CAGradientLayer()
        gradientLayer_Doze.frame = view.bounds
        gradientLayer_Doze.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Doze.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Doze.layer.addSublayer(gradientLayer_Doze)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Doze() {
        avatarContainerView_Doze.addSubview(avatarImageView_Doze)
        
        // 创建3个水波纹图层
        for _ in 0..<3 {
            let rippleLayer_Doze = CAShapeLayer()
            let circlePath_Doze = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Doze.path = circlePath_Doze.cgPath
            rippleLayer_Doze.strokeColor = ColorConfig_Doze.primaryGradientStart_Doze.cgColor
            rippleLayer_Doze.fillColor = UIColor.clear.cgColor
            rippleLayer_Doze.lineWidth = 2
            rippleLayer_Doze.opacity = 0
            
            avatarContainerView_Doze.layer.insertSublayer(rippleLayer_Doze, at: 0)
            rippleAnimationLayers_Doze.append(rippleLayer_Doze)
        }
        
        avatarImageView_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Doze() {
        // 背景图片
        backgroundImageView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Doze.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Doze() {
        hangUpButton_Doze.addTarget(self, action: #selector(hangUpCall_Doze), for: .touchUpInside)
        reportButton_Doze.addTarget(self, action: #selector(reportTapped_Doze), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Doze() {
        // 头像渐入动画
        avatarContainerView_Doze.alpha = 0
        avatarContainerView_Doze.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Doze.alpha = 1
            self.avatarContainerView_Doze.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Doze.alpha = 0
        statusLabel_Doze.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Doze.alpha = 1
            self.statusLabel_Doze.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Doze.alpha = 0
        hangUpButton_Doze.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Doze.alpha = 1
            self.hangUpButton_Doze.transform = .identity
        }
    }
    
    /// 开始水波纹动画
    private func startRippleAnimation_Doze() {
        for (index_Doze, layer_Doze) in rippleAnimationLayers_Doze.enumerated() {
            let scaleAnimation_Doze = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Doze.fromValue = 1.0
            scaleAnimation_Doze.toValue = 1.8
            
            let opacityAnimation_Doze = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Doze.fromValue = 0.6
            opacityAnimation_Doze.toValue = 0
            
            let animationGroup_Doze = CAAnimationGroup()
            animationGroup_Doze.animations = [scaleAnimation_Doze, opacityAnimation_Doze]
            animationGroup_Doze.duration = 2.0
            animationGroup_Doze.repeatCount = .infinity
            animationGroup_Doze.beginTime = CACurrentMediaTime() + Double(index_Doze) * 0.66
            
            layer_Doze.add(animationGroup_Doze, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Doze() {
        let swayAnimation_Doze = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Doze.fromValue = -0.05
        swayAnimation_Doze.toValue = 0.05
        swayAnimation_Doze.duration = 0.8
        swayAnimation_Doze.autoreverses = true
        swayAnimation_Doze.repeatCount = .infinity
        swayAnimation_Doze.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Doze.layer.add(swayAnimation_Doze, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Doze() {
        for layer_Doze in rippleAnimationLayers_Doze {
            layer_Doze.removeAllAnimations()
        }
        hangUpButton_Doze.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Doze() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Doze.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Doze.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Doze() {
        guard let userModel_Doze = userModel_Doze else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Doze.block_Doze(
            user_Doze: userModel_Doze,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
