import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Niche: 通话用户信息
/// - rippleAnimationLayers_Niche: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Niche: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Niche: 构建头像与同心圆水波纹
/// - startRippleAnimation_Niche: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Niche: 启动自动挂断计时器
/// - hangUpCall_Niche: 手动挂断通话
class VideoChat_Niche: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Niche: PrewUserModel_Niche?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Niche: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Niche: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Niche: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Niche: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Niche: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Niche: UIView = {
        let view_Niche = UIView()
        view_Niche.backgroundColor = .clear
        return view_Niche
    }()
    
    /// 用户头像
    private let avatarImageView_Niche: UIImageView = {
        let imageView_Niche = UIImageView()
        imageView_Niche.contentMode = .scaleAspectFill
        imageView_Niche.clipsToBounds = true
        imageView_Niche.layer.cornerRadius = 63
        imageView_Niche.layer.borderWidth = 3
        imageView_Niche.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Niche
    }()
    
    /// 用户名标签
    private let usernameLabel_Niche: UILabel = {
        let label_Niche = UILabel()
        label_Niche.textColor = .white
        label_Niche.textAlignment = .center
        label_Niche.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Niche
    }()
    
    /// 通话状态标签
    private let statusLabel_Niche: UILabel = {
        let label_Niche = UILabel()
        label_Niche.text = "Calling..."
        label_Niche.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Niche.textAlignment = .center
        label_Niche.font = UIFont.systemFont(ofSize: 16)
        return label_Niche
    }()
    
    /// 挂断按钮
    private let hangUpButton_Niche: UIButton = {
        let button_Niche = UIButton(type: .system)
        button_Niche.backgroundColor = UIColor(hexstring_Niche: "#BE92FD")
        button_Niche.layer.cornerRadius = 25
        button_Niche.layer.shadowColor = UIColor(hexstring_Niche: "#FF6B9D").cgColor
        button_Niche.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Niche.layer.shadowOpacity = 0.4
        button_Niche.layer.shadowRadius = 16
        
        let config_Niche = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Niche = UIImage(systemName: "phone.down.fill", withConfiguration: config_Niche)
        button_Niche.setImage(image_Niche, for: .normal)
        button_Niche.tintColor = .white
        
        return button_Niche
    }()
    
    /// 举报按钮
    private lazy var reportButton_Niche: UIButton = {
        let button_Niche = ReportDeleteHelper_Niche.createUserReportButton_Niche(
            size_Niche: 44,
            backgroundColor_Niche: UIColor.white.withAlphaComponent(0.15),
            tintColor_Niche: .white,
            withShadow_Niche: true
        )
        return button_Niche
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Niche()
        setupActions_Niche()
        setupAnimations_Niche()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Niche()
        startSwayAnimation_Niche()
        startAutoHangUpTimers_Niche()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Niche()
        cancelAutoHangUpTimers_Niche()
    }
    
    deinit {
        swayAnimationTimer_Niche?.invalidate()
        cancelAutoHangUpTimers_Niche()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Niche() {
        view.addSubview(avatarContainerView_Niche)
        view.addSubview(usernameLabel_Niche)
        view.addSubview(statusLabel_Niche)
        view.addSubview(hangUpButton_Niche)
        
        setupAvatarWithRipples_Niche()
        
        view.addSubview(reportButton_Niche)
        
        // 填充用户数据
        if let userModel_Niche = userModel_Niche {
            usernameLabel_Niche.text = userModel_Niche.userName_Niche
            if let imageName_Niche = userModel_Niche.userHead_Niche {
                avatarImageView_Niche.image = UIImage(named: imageName_Niche)
            }
        }
        
        setupConstraints_Niche()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Niche() {
        avatarContainerView_Niche.addSubview(avatarImageView_Niche)
        
        // 容器中心坐标（300/2 = 150）
        let center_Niche = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Niche: CGFloat = 63
        let ringSpacing_Niche: CGFloat = 18
        let ringCount_Niche = 5
        
        for i in 0..<ringCount_Niche {
            let radius_Niche = avatarRadius_Niche + CGFloat(i + 1) * ringSpacing_Niche
            
            let rippleLayer_Niche = CAShapeLayer()
            let circlePath_Niche = UIBezierPath(
                arcCenter: center_Niche,
                radius: radius_Niche,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Niche.path = circlePath_Niche.cgPath
            rippleLayer_Niche.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Niche.fillColor = UIColor.clear.cgColor
            rippleLayer_Niche.lineWidth = 1.0
            rippleLayer_Niche.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Niche.layer.insertSublayer(rippleLayer_Niche, at: 0)
            rippleAnimationLayers_Niche.append(rippleLayer_Niche)
        }
        
        avatarImageView_Niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Niche() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Niche.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Niche.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Niche.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Niche.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Niche() {
        hangUpButton_Niche.addTarget(self, action: #selector(hangUpCall_Niche), for: .touchUpInside)
        reportButton_Niche.addTarget(self, action: #selector(reportTapped_Niche), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Niche() {
        // 头像容器弹性进场
        avatarContainerView_Niche.alpha = 0
        avatarContainerView_Niche.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Niche.alpha = 1
            self.avatarContainerView_Niche.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Niche.alpha = 0
        statusLabel_Niche.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Niche.alpha = 1
            self.statusLabel_Niche.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Niche.alpha = 0
        hangUpButton_Niche.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Niche.alpha = 1
            self.hangUpButton_Niche.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Niche() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Niche, layer_Niche) in rippleAnimationLayers_Niche.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Niche = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Niche.values = [0, 0.55, 0.22, 0]
            opacityAnim_Niche.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Niche.duration = cycleDuration
            opacityAnim_Niche.repeatCount = .infinity
            opacityAnim_Niche.beginTime = CACurrentMediaTime() + Double(index_Niche) * staggerInterval
            opacityAnim_Niche.isRemovedOnCompletion = false
            
            layer_Niche.add(opacityAnim_Niche, forKey: "rippleOpacity_Niche")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Niche() {
        let swayAnimation_Niche = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Niche.fromValue = -0.05
        swayAnimation_Niche.toValue = 0.05
        swayAnimation_Niche.duration = 0.8
        swayAnimation_Niche.autoreverses = true
        swayAnimation_Niche.repeatCount = .infinity
        swayAnimation_Niche.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Niche.layer.add(swayAnimation_Niche, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Niche() {
        for layer_Niche in rippleAnimationLayers_Niche {
            layer_Niche.removeAllAnimations()
        }
        hangUpButton_Niche.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Niche() {
        if isSimulatingDecline_Niche {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Niche = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Niche(reason_Niche: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Niche = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Niche(reason_Niche: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Niche() {
        declineTimer_Niche?.invalidate()
        declineTimer_Niche = nil
        noAnswerTimer_Niche?.invalidate()
        noAnswerTimer_Niche = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Niche: 显示给用户的挂断原因
    private func autoHangUp_Niche(reason_Niche: String) {
        cancelAutoHangUpTimers_Niche()
        stopAnimations_Niche()
        
        let alert_Niche = UIAlertController(title: nil, message: reason_Niche, preferredStyle: .alert)
        let okAction_Niche = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Niche.addAction(okAction_Niche)
        present(alert_Niche, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Niche() {
        cancelAutoHangUpTimers_Niche()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Niche.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Niche.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Niche() {
        guard let userModel_Niche = userModel_Niche else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Niche()
        
        ReportDeleteHelper_Niche.block_Niche(
            user_Niche: userModel_Niche,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Niche.popToSafeStateAfterBlock_Niche(from: self)
        }
    }
}
