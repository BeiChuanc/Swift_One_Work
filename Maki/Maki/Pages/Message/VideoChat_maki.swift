import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Maki: 通话用户信息
/// - rippleAnimationLayers_Maki: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Maki: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Maki: 构建头像与同心圆水波纹
/// - startRippleAnimation_Maki: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Maki: 启动自动挂断计时器
/// - hangUpCall_Maki: 手动挂断通话
class VideoChat_Maki: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Maki: PrewUserModel_Maki?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Maki: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Maki: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Maki: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Maki: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Maki: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Maki: UIView = {
        let view_Maki = UIView()
        view_Maki.backgroundColor = .clear
        return view_Maki
    }()
    
    /// 用户头像
    private let avatarImageView_Maki: UIImageView = {
        let imageView_Maki = UIImageView()
        imageView_Maki.contentMode = .scaleAspectFill
        imageView_Maki.clipsToBounds = true
        imageView_Maki.layer.cornerRadius = 63
        imageView_Maki.layer.borderWidth = 3
        imageView_Maki.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Maki
    }()
    
    /// 用户名标签
    private let usernameLabel_Maki: UILabel = {
        let label_Maki = UILabel()
        label_Maki.textColor = .white
        label_Maki.textAlignment = .center
        label_Maki.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Maki
    }()
    
    /// 通话状态标签
    private let statusLabel_Maki: UILabel = {
        let label_Maki = UILabel()
        label_Maki.text = "Calling..."
        label_Maki.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Maki.textAlignment = .center
        label_Maki.font = UIFont.systemFont(ofSize: 16)
        return label_Maki
    }()
    
    /// 挂断按钮
    private let hangUpButton_Maki: UIButton = {
        let button_Maki = UIButton(type: .system)
        button_Maki.backgroundColor = UIColor(hexstring_Maki: "#BE92FD")
        button_Maki.layer.cornerRadius = 25
        button_Maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF6B9D").cgColor
        button_Maki.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Maki.layer.shadowOpacity = 0.4
        button_Maki.layer.shadowRadius = 16
        
        let config_Maki = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Maki = UIImage(systemName: "phone.down.fill", withConfiguration: config_Maki)
        button_Maki.setImage(image_Maki, for: .normal)
        button_Maki.tintColor = .white
        
        return button_Maki
    }()
    
    /// 举报按钮
    private lazy var reportButton_Maki: UIButton = {
        let button_Maki = ReportDeleteHelper_Maki.createUserReportButton_Maki(
            size_Maki: 44,
            backgroundColor_Maki: UIColor.white.withAlphaComponent(0.15),
            tintColor_Maki: .white,
            withShadow_Maki: true
        )
        return button_Maki
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Maki()
        setupActions_Maki()
        setupAnimations_Maki()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Maki()
        startSwayAnimation_Maki()
        startAutoHangUpTimers_Maki()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Maki()
        cancelAutoHangUpTimers_Maki()
    }
    
    deinit {
        swayAnimationTimer_Maki?.invalidate()
        cancelAutoHangUpTimers_Maki()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Maki() {
        view.addSubview(avatarContainerView_Maki)
        view.addSubview(usernameLabel_Maki)
        view.addSubview(statusLabel_Maki)
        view.addSubview(hangUpButton_Maki)
        
        setupAvatarWithRipples_Maki()
        
        view.addSubview(reportButton_Maki)
        
        // 填充用户数据
        if let userModel_Maki = userModel_Maki {
            usernameLabel_Maki.text = userModel_Maki.userName_Maki
            if let imageName_Maki = userModel_Maki.userHead_Maki {
                avatarImageView_Maki.image = UIImage(named: imageName_Maki)
            }
        }
        
        setupConstraints_Maki()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Maki() {
        avatarContainerView_Maki.addSubview(avatarImageView_Maki)
        
        // 容器中心坐标（300/2 = 150）
        let center_Maki = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Maki: CGFloat = 63
        let ringSpacing_Maki: CGFloat = 18
        let ringCount_Maki = 5
        
        for i in 0..<ringCount_Maki {
            let radius_Maki = avatarRadius_Maki + CGFloat(i + 1) * ringSpacing_Maki
            
            let rippleLayer_Maki = CAShapeLayer()
            let circlePath_Maki = UIBezierPath(
                arcCenter: center_Maki,
                radius: radius_Maki,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Maki.path = circlePath_Maki.cgPath
            rippleLayer_Maki.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Maki.fillColor = UIColor.clear.cgColor
            rippleLayer_Maki.lineWidth = 1.0
            rippleLayer_Maki.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Maki.layer.insertSublayer(rippleLayer_Maki, at: 0)
            rippleAnimationLayers_Maki.append(rippleLayer_Maki)
        }
        
        avatarImageView_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Maki() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Maki.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Maki.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Maki.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Maki() {
        hangUpButton_Maki.addTarget(self, action: #selector(hangUpCall_Maki), for: .touchUpInside)
        reportButton_Maki.addTarget(self, action: #selector(reportTapped_Maki), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Maki() {
        // 头像容器弹性进场
        avatarContainerView_Maki.alpha = 0
        avatarContainerView_Maki.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Maki.alpha = 1
            self.avatarContainerView_Maki.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Maki.alpha = 0
        statusLabel_Maki.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Maki.alpha = 1
            self.statusLabel_Maki.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Maki.alpha = 0
        hangUpButton_Maki.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Maki.alpha = 1
            self.hangUpButton_Maki.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Maki() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Maki, layer_Maki) in rippleAnimationLayers_Maki.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Maki = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Maki.values = [0, 0.55, 0.22, 0]
            opacityAnim_Maki.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Maki.duration = cycleDuration
            opacityAnim_Maki.repeatCount = .infinity
            opacityAnim_Maki.beginTime = CACurrentMediaTime() + Double(index_Maki) * staggerInterval
            opacityAnim_Maki.isRemovedOnCompletion = false
            
            layer_Maki.add(opacityAnim_Maki, forKey: "rippleOpacity_Maki")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Maki() {
        let swayAnimation_Maki = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Maki.fromValue = -0.05
        swayAnimation_Maki.toValue = 0.05
        swayAnimation_Maki.duration = 0.8
        swayAnimation_Maki.autoreverses = true
        swayAnimation_Maki.repeatCount = .infinity
        swayAnimation_Maki.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Maki.layer.add(swayAnimation_Maki, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Maki() {
        for layer_Maki in rippleAnimationLayers_Maki {
            layer_Maki.removeAllAnimations()
        }
        hangUpButton_Maki.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Maki() {
        if isSimulatingDecline_Maki {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Maki = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Maki(reason_Maki: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Maki = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Maki(reason_Maki: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Maki() {
        declineTimer_Maki?.invalidate()
        declineTimer_Maki = nil
        noAnswerTimer_Maki?.invalidate()
        noAnswerTimer_Maki = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Maki: 显示给用户的挂断原因
    private func autoHangUp_Maki(reason_Maki: String) {
        cancelAutoHangUpTimers_Maki()
        stopAnimations_Maki()
        
        let alert_Maki = UIAlertController(title: nil, message: reason_Maki, preferredStyle: .alert)
        let okAction_Maki = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Maki.addAction(okAction_Maki)
        present(alert_Maki, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Maki() {
        cancelAutoHangUpTimers_Maki()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Maki.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Maki.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Maki() {
        guard let userModel_Maki = userModel_Maki else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Maki()
        
        ReportDeleteHelper_Maki.block_Maki(
            user_Maki: userModel_Maki,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Maki.popToSafeStateAfterBlock_Maki(from: self)
        }
    }
}
