import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Sylva: 通话用户信息
/// - rippleAnimationLayers_Sylva: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Sylva: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Sylva: 构建头像与同心圆水波纹
/// - startRippleAnimation_Sylva: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Sylva: 启动自动挂断计时器
/// - hangUpCall_Sylva: 手动挂断通话
class VideoChat_Sylva: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Sylva: PrewUserModel_Sylva?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Sylva: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Sylva: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Sylva: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Sylva: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Sylva: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Sylva: UIView = {
        let view_Sylva = UIView()
        view_Sylva.backgroundColor = .clear
        return view_Sylva
    }()
    
    /// 用户头像
    private let avatarImageView_Sylva: UIImageView = {
        let imageView_Sylva = UIImageView()
        imageView_Sylva.contentMode = .scaleAspectFill
        imageView_Sylva.clipsToBounds = true
        imageView_Sylva.layer.cornerRadius = 63
        imageView_Sylva.layer.borderWidth = 3
        imageView_Sylva.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Sylva
    }()
    
    /// 用户名标签
    private let usernameLabel_Sylva: UILabel = {
        let label_Sylva = UILabel()
        label_Sylva.textColor = .white
        label_Sylva.textAlignment = .center
        label_Sylva.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Sylva
    }()
    
    /// 通话状态标签
    private let statusLabel_Sylva: UILabel = {
        let label_Sylva = UILabel()
        label_Sylva.text = "Calling..."
        label_Sylva.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Sylva.textAlignment = .center
        label_Sylva.font = UIFont.systemFont(ofSize: 16)
        return label_Sylva
    }()
    
    /// 挂断按钮
    private let hangUpButton_Sylva: UIButton = {
        let button_Sylva = UIButton(type: .system)
        button_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#BE92FD")
        button_Sylva.layer.cornerRadius = 25
        button_Sylva.layer.shadowColor = UIColor(hexstring_Sylva: "#FF6B9D").cgColor
        button_Sylva.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Sylva.layer.shadowOpacity = 0.4
        button_Sylva.layer.shadowRadius = 16
        
        let config_Sylva = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Sylva = UIImage(systemName: "phone.down.fill", withConfiguration: config_Sylva)
        button_Sylva.setImage(image_Sylva, for: .normal)
        button_Sylva.tintColor = .white
        
        return button_Sylva
    }()
    
    /// 举报按钮
    private lazy var reportButton_Sylva: UIButton = {
        let button_Sylva = ReportDeleteHelper_Sylva.createUserReportButton_Sylva(
            size_Sylva: 44,
            backgroundColor_Sylva: UIColor.white.withAlphaComponent(0.15),
            tintColor_Sylva: .white,
            withShadow_Sylva: true
        )
        return button_Sylva
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Sylva()
        setupActions_Sylva()
        setupAnimations_Sylva()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Sylva()
        startSwayAnimation_Sylva()
        startAutoHangUpTimers_Sylva()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Sylva()
        cancelAutoHangUpTimers_Sylva()
    }
    
    deinit {
        swayAnimationTimer_Sylva?.invalidate()
        cancelAutoHangUpTimers_Sylva()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Sylva() {
        view.addSubview(avatarContainerView_Sylva)
        view.addSubview(usernameLabel_Sylva)
        view.addSubview(statusLabel_Sylva)
        view.addSubview(hangUpButton_Sylva)
        
        setupAvatarWithRipples_Sylva()
        
        view.addSubview(reportButton_Sylva)
        
        // 填充用户数据
        if let userModel_Sylva = userModel_Sylva {
            usernameLabel_Sylva.text = userModel_Sylva.userName_Sylva
            if let imageName_Sylva = userModel_Sylva.userHead_Sylva {
                avatarImageView_Sylva.image = UIImage(named: imageName_Sylva)
            }
        }
        
        setupConstraints_Sylva()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Sylva() {
        avatarContainerView_Sylva.addSubview(avatarImageView_Sylva)
        
        // 容器中心坐标（300/2 = 150）
        let center_Sylva = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Sylva: CGFloat = 63
        let ringSpacing_Sylva: CGFloat = 18
        let ringCount_Sylva = 5
        
        for i in 0..<ringCount_Sylva {
            let radius_Sylva = avatarRadius_Sylva + CGFloat(i + 1) * ringSpacing_Sylva
            
            let rippleLayer_Sylva = CAShapeLayer()
            let circlePath_Sylva = UIBezierPath(
                arcCenter: center_Sylva,
                radius: radius_Sylva,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Sylva.path = circlePath_Sylva.cgPath
            rippleLayer_Sylva.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Sylva.fillColor = UIColor.clear.cgColor
            rippleLayer_Sylva.lineWidth = 1.0
            rippleLayer_Sylva.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Sylva.layer.insertSublayer(rippleLayer_Sylva, at: 0)
            rippleAnimationLayers_Sylva.append(rippleLayer_Sylva)
        }
        
        avatarImageView_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Sylva() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Sylva.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Sylva.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Sylva.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Sylva.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Sylva.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Sylva() {
        hangUpButton_Sylva.addTarget(self, action: #selector(hangUpCall_Sylva), for: .touchUpInside)
        reportButton_Sylva.addTarget(self, action: #selector(reportTapped_Sylva), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Sylva() {
        // 头像容器弹性进场
        avatarContainerView_Sylva.alpha = 0
        avatarContainerView_Sylva.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Sylva.alpha = 1
            self.avatarContainerView_Sylva.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Sylva.alpha = 0
        statusLabel_Sylva.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Sylva.alpha = 1
            self.statusLabel_Sylva.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Sylva.alpha = 0
        hangUpButton_Sylva.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Sylva.alpha = 1
            self.hangUpButton_Sylva.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Sylva() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Sylva, layer_Sylva) in rippleAnimationLayers_Sylva.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Sylva = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Sylva.values = [0, 0.55, 0.22, 0]
            opacityAnim_Sylva.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Sylva.duration = cycleDuration
            opacityAnim_Sylva.repeatCount = .infinity
            opacityAnim_Sylva.beginTime = CACurrentMediaTime() + Double(index_Sylva) * staggerInterval
            opacityAnim_Sylva.isRemovedOnCompletion = false
            
            layer_Sylva.add(opacityAnim_Sylva, forKey: "rippleOpacity_Sylva")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Sylva() {
        let swayAnimation_Sylva = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Sylva.fromValue = -0.05
        swayAnimation_Sylva.toValue = 0.05
        swayAnimation_Sylva.duration = 0.8
        swayAnimation_Sylva.autoreverses = true
        swayAnimation_Sylva.repeatCount = .infinity
        swayAnimation_Sylva.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Sylva.layer.add(swayAnimation_Sylva, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Sylva() {
        for layer_Sylva in rippleAnimationLayers_Sylva {
            layer_Sylva.removeAllAnimations()
        }
        hangUpButton_Sylva.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Sylva() {
        if isSimulatingDecline_Sylva {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Sylva = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Sylva(reason_Sylva: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Sylva = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Sylva(reason_Sylva: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Sylva() {
        declineTimer_Sylva?.invalidate()
        declineTimer_Sylva = nil
        noAnswerTimer_Sylva?.invalidate()
        noAnswerTimer_Sylva = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Sylva: 显示给用户的挂断原因
    private func autoHangUp_Sylva(reason_Sylva: String) {
        cancelAutoHangUpTimers_Sylva()
        stopAnimations_Sylva()
        
        let alert_Sylva = UIAlertController(title: nil, message: reason_Sylva, preferredStyle: .alert)
        let okAction_Sylva = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Sylva.addAction(okAction_Sylva)
        present(alert_Sylva, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Sylva() {
        cancelAutoHangUpTimers_Sylva()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Sylva.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Sylva.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Sylva() {
        guard let userModel_Sylva = userModel_Sylva else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Sylva()
        
        ReportDeleteHelper_Sylva.block_Sylva(
            user_Sylva: userModel_Sylva,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Sylva.popToSafeStateAfterBlock_Sylva(from: self)
        }
    }
}
