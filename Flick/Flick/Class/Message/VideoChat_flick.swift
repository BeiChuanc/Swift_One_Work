import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：现代化视觉效果，包含头像、水波纹动画、挂断按钮、举报按钮
/// 关键属性：
/// - userModel_Flick: 通话用户信息
/// - rippleAnimationLayers_Flick: 水波纹动画图层数组
/// 关键方法：
/// - setupRippleAnimation_Flick: 设置水波纹动画
/// - hangUpCall_Flick: 挂断通话
class VideoChat_Flick: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Flick: PrewUserModel_Flick?
    
    /// 水波纹动画图层
    private var rippleAnimationLayers_Flick: [CAShapeLayer] = []
    
    /// 摇摆动画控制器
    private var swayAnimationTimer_Flick: Timer?
    
    // MARK: - UI组件
    
    /// 背景图片视图
    private let backgroundImageView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.contentMode = .scaleAspectFill
        imageView_Flick.clipsToBounds = true
        return imageView_Flick
    }()
    
    /// 模糊效果
    private let blurEffectView_Flick: UIVisualEffectView = {
        let blurEffect_Flick = UIBlurEffect(style: .dark)
        let effectView_Flick = UIVisualEffectView(effect: blurEffect_Flick)
        return effectView_Flick
    }()
    
    /// 渐变遮罩
    private let gradientOverlay_Flick: UIView = {
        let view_Flick = UIView()
        return view_Flick
    }()
    
    /// 用户头像容器
    private let avatarContainerView_Flick: UIView = {
        let view_Flick = UIView()
        return view_Flick
    }()
    
    /// 用户头像
    private let avatarImageView_Flick: UIImageView = {
        let imageView_Flick = UIImageView()
        imageView_Flick.contentMode = .scaleAspectFill
        imageView_Flick.clipsToBounds = true
        imageView_Flick.layer.cornerRadius = 63
        imageView_Flick.layer.borderWidth = 4
        imageView_Flick.layer.borderColor = UIColor.white.cgColor
        return imageView_Flick
    }()
    
    /// 用户名标签
    private let usernameLabel_Flick: UILabel = {
        let label_Flick = UILabel()
        label_Flick.textColor = .white
        label_Flick.textAlignment = .center
        return label_Flick
    }()
    
    /// 状态标签
    private let statusLabel_Flick: UILabel = {
        let label_Flick = UILabel()
        label_Flick.text = "Calling..."
        label_Flick.textColor = UIColor.white.withAlphaComponent(0.8)
        label_Flick.textAlignment = .center
        return label_Flick
    }()
    
    /// 挂断按钮 — 标准圆形红色挂断风格，搭配发光阴影
    private let hangUpButton_Flick: UIButton = {
        let button_Flick = UIButton(type: .system)
        button_Flick.backgroundColor = UIColor(hexstring_Flick: "#FF3B30")
        button_Flick.layer.cornerRadius = 36
        button_Flick.layer.shadowColor = UIColor(hexstring_Flick: "#FF3B30").cgColor
        button_Flick.layer.shadowOffset = CGSize(width: 0, height: 6)
        button_Flick.layer.shadowOpacity = 0.55
        button_Flick.layer.shadowRadius = 14
        
        let config_Flick = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image_Flick = UIImage(systemName: "phone.down.fill", withConfiguration: config_Flick)
        button_Flick.setImage(image_Flick, for: .normal)
        button_Flick.tintColor = .white
        
        return button_Flick
    }()
    
    /// 举报按钮
    private lazy var reportButton_Flick: UIButton = {
        let button_Flick = ReportDeleteHelper_Flick.createUserReportButton_Flick(
            size_Flick: 44,
            backgroundColor_Flick: UIColor.white.withAlphaComponent(0.2),
            tintColor_Flick: .white,
            withShadow_Flick: true
        )
        return button_Flick
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        setupActions_Flick()
        setupAnimations_Flick()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Flick()
        startSwayAnimation_Flick()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Flick()
    }
    
    deinit {
        swayAnimationTimer_Flick?.invalidate()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Flick() {
        // 添加背景
        view.addSubview(backgroundImageView_Flick)
        view.addSubview(blurEffectView_Flick)
        view.addSubview(gradientOverlay_Flick)
        
        // 设置渐变遮罩
        setupGradientOverlay_Flick()
        
        // 添加内容
        view.addSubview(avatarContainerView_Flick)
        view.addSubview(usernameLabel_Flick)
        view.addSubview(statusLabel_Flick)
        view.addSubview(hangUpButton_Flick)
        
        // 头像容器中添加水波纹和头像
        setupAvatarWithRipples_Flick()
        
        // 添加举报按钮
        view.addSubview(reportButton_Flick)
        
        // 加载用户数据
        if let userModel_Flick = userModel_Flick {
            usernameLabel_Flick.text = userModel_Flick.userName_Flick
            
            if let imageName_Flick = userModel_Flick.userHead_Flick {
                avatarImageView_Flick.image = UIImage(named: imageName_Flick)
                backgroundImageView_Flick.image = UIImage(named: imageName_Flick)
            }
        }
        
        setupConstraints_Flick()
    }
    
    /// 设置渐变遮罩
    private func setupGradientOverlay_Flick() {
        let gradientLayer_Flick = CAGradientLayer()
        gradientLayer_Flick.frame = view.bounds
        gradientLayer_Flick.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.black.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer_Flick.locations = [0.0, 0.5, 1.0]
        gradientOverlay_Flick.layer.addSublayer(gradientLayer_Flick)
    }
    
    /// 设置头像和水波纹
    private func setupAvatarWithRipples_Flick() {
        avatarContainerView_Flick.addSubview(avatarImageView_Flick)
        
        // 创建3个填充型水波纹图层，白色半透明渐散效果
        for _ in 0..<3 {
            let rippleLayer_Flick = CAShapeLayer()
            let circlePath_Flick = UIBezierPath(
                arcCenter: CGPoint(x: 63, y: 63),
                radius: 63,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Flick.path = circlePath_Flick.cgPath
            rippleLayer_Flick.strokeColor = UIColor.clear.cgColor
            rippleLayer_Flick.fillColor = UIColor.white.withValues(alpha: 0.18).cgColor
            rippleLayer_Flick.lineWidth = 0
            rippleLayer_Flick.opacity = 0
            
            avatarContainerView_Flick.layer.insertSublayer(rippleLayer_Flick, at: 0)
            rippleAnimationLayers_Flick.append(rippleLayer_Flick)
        }
        
        avatarImageView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Flick() {
        // 背景图片
        backgroundImageView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 模糊效果
        blurEffectView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 渐变遮罩
        gradientOverlay_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 头像容器
        avatarContainerView_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(120)
            make.width.height.equalTo(180)
        }
        
        // 用户名
        usernameLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Flick.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Flick.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮 — 圆形，宽高统一72
        hangUpButton_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.height.equalTo(72)
        }
        
        // 举报按钮
        reportButton_Flick.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 设置事件
    private func setupActions_Flick() {
        hangUpButton_Flick.addTarget(self, action: #selector(hangUpCall_Flick), for: .touchUpInside)
        reportButton_Flick.addTarget(self, action: #selector(reportTapped_Flick), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置动画
    private func setupAnimations_Flick() {
        // 头像渐入动画
        avatarContainerView_Flick.alpha = 0
        avatarContainerView_Flick.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Flick.alpha = 1
            self.avatarContainerView_Flick.transform = .identity
        }
        
        // 文字渐入动画
        usernameLabel_Flick.alpha = 0
        statusLabel_Flick.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Flick.alpha = 1
            self.statusLabel_Flick.alpha = 1
        }
        
        // 按钮渐入动画
        hangUpButton_Flick.alpha = 0
        hangUpButton_Flick.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Flick.alpha = 1
            self.hangUpButton_Flick.transform = .identity
        }
    }
    
    /// 开始水波纹动画 — 填充型白色半透明扩散，节奏均匀错开
    private func startRippleAnimation_Flick() {
        for (index_Flick, layer_Flick) in rippleAnimationLayers_Flick.enumerated() {
            // 缩放：从原始大小扩散到2.4倍
            let scaleAnimation_Flick = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation_Flick.fromValue = 1.0
            scaleAnimation_Flick.toValue = 2.4
            scaleAnimation_Flick.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            // 透明度：从较高可见度渐隐至0
            let opacityAnimation_Flick = CABasicAnimation(keyPath: "opacity")
            opacityAnimation_Flick.fromValue = 0.75
            opacityAnimation_Flick.toValue = 0
            opacityAnimation_Flick.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            let animationGroup_Flick = CAAnimationGroup()
            animationGroup_Flick.animations = [scaleAnimation_Flick, opacityAnimation_Flick]
            animationGroup_Flick.duration = 2.4
            animationGroup_Flick.repeatCount = .infinity
            // 每圈间隔0.8s均匀错开，形成连续扩散感
            animationGroup_Flick.beginTime = CACurrentMediaTime() + Double(index_Flick) * 0.8
            
            layer_Flick.add(animationGroup_Flick, forKey: "ripple")
        }
    }
    
    /// 开始摇摆动画
    private func startSwayAnimation_Flick() {
        let swayAnimation_Flick = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Flick.fromValue = -0.05
        swayAnimation_Flick.toValue = 0.05
        swayAnimation_Flick.duration = 0.8
        swayAnimation_Flick.autoreverses = true
        swayAnimation_Flick.repeatCount = .infinity
        swayAnimation_Flick.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Flick.layer.add(swayAnimation_Flick, forKey: "sway")
    }
    
    /// 停止动画
    private func stopAnimations_Flick() {
        for layer_Flick in rippleAnimationLayers_Flick {
            layer_Flick.removeAllAnimations()
        }
        hangUpButton_Flick.layer.removeAllAnimations()
    }
    
    // MARK: - 事件处理
    
    /// 挂断通话
    @objc private func hangUpCall_Flick() {
        // 添加按钮点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Flick.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Flick.transform = .identity
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击
    @objc private func reportTapped_Flick() {
        guard let userModel_Flick = userModel_Flick else { return }
        
        // 拉黑用户
        ReportDeleteHelper_Flick.block_Flick(
            user_Flick: userModel_Flick,
            from: self
        ) { [weak self] in
            // 拉黑成功后关闭视频通话并返回
            self?.dismiss(animated: true) {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
