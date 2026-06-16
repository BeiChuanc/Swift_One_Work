import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Retrs: 通话用户信息
/// - rippleAnimationLayers_Retrs: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Retrs: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Retrs: 构建头像与同心圆水波纹
/// - startRippleAnimation_Retrs: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Retrs: 启动自动挂断计时器
/// - hangUpCall_Retrs: 手动挂断通话
class VideoChat_Retrs: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Retrs: PrewUserModel_Retrs?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Retrs: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Retrs: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Retrs: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Retrs: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Retrs: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Retrs: UIView = {
        let view_Retrs = UIView()
        view_Retrs.backgroundColor = .clear
        return view_Retrs
    }()
    
    /// 用户头像
    private let avatarImageView_Retrs: UIImageView = {
        let imageView_Retrs = UIImageView()
        imageView_Retrs.contentMode = .scaleAspectFill
        imageView_Retrs.clipsToBounds = true
        imageView_Retrs.layer.cornerRadius = 63
        imageView_Retrs.layer.borderWidth = 3
        imageView_Retrs.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Retrs
    }()
    
    /// 用户名标签
    private let usernameLabel_Retrs: UILabel = {
        let label_Retrs = UILabel()
        label_Retrs.textColor = .white
        label_Retrs.textAlignment = .center
        label_Retrs.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Retrs
    }()
    
    /// 通话状态标签
    private let statusLabel_Retrs: UILabel = {
        let label_Retrs = UILabel()
        label_Retrs.text = "Calling..."
        label_Retrs.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Retrs.textAlignment = .center
        label_Retrs.font = UIFont.systemFont(ofSize: 16)
        return label_Retrs
    }()
    
    /// 挂断按钮
    private let hangUpButton_Retrs: UIButton = {
        let button_Retrs = UIButton(type: .system)
        button_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#BE92FD")
        button_Retrs.layer.cornerRadius = 25
        button_Retrs.layer.shadowColor = UIColor(hexstring_Retrs: "#FF6B9D").cgColor
        button_Retrs.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Retrs.layer.shadowOpacity = 0.4
        button_Retrs.layer.shadowRadius = 16
        
        let config_Retrs = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Retrs = UIImage(systemName: "phone.down.fill", withConfiguration: config_Retrs)
        button_Retrs.setImage(image_Retrs, for: .normal)
        button_Retrs.tintColor = .white
        
        return button_Retrs
    }()
    
    /// 举报按钮
    private lazy var reportButton_Retrs: UIButton = {
        let button_Retrs = ReportDeleteHelper_Retrs.createUserReportButton_Retrs(
            size_Retrs: 44,
            backgroundColor_Retrs: UIColor.white.withAlphaComponent(0.15),
            tintColor_Retrs: .white,
            withShadow_Retrs: true
        )
        return button_Retrs
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Retrs()
        setupActions_Retrs()
        setupAnimations_Retrs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Retrs()
        startSwayAnimation_Retrs()
        startAutoHangUpTimers_Retrs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Retrs()
        cancelAutoHangUpTimers_Retrs()
    }
    
    deinit {
        swayAnimationTimer_Retrs?.invalidate()
        cancelAutoHangUpTimers_Retrs()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Retrs() {
        view.addSubview(avatarContainerView_Retrs)
        view.addSubview(usernameLabel_Retrs)
        view.addSubview(statusLabel_Retrs)
        view.addSubview(hangUpButton_Retrs)
        
        setupAvatarWithRipples_Retrs()
        
        view.addSubview(reportButton_Retrs)
        
        // 填充用户数据
        if let userModel_Retrs = userModel_Retrs {
            usernameLabel_Retrs.text = userModel_Retrs.userName_Retrs
            if let imageName_Retrs = userModel_Retrs.userHead_Retrs {
                avatarImageView_Retrs.image = UIImage(named: imageName_Retrs)
            }
        }
        
        setupConstraints_Retrs()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Retrs() {
        avatarContainerView_Retrs.addSubview(avatarImageView_Retrs)
        
        // 容器中心坐标（300/2 = 150）
        let center_Retrs = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Retrs: CGFloat = 63
        let ringSpacing_Retrs: CGFloat = 18
        let ringCount_Retrs = 5
        
        for i in 0..<ringCount_Retrs {
            let radius_Retrs = avatarRadius_Retrs + CGFloat(i + 1) * ringSpacing_Retrs
            
            let rippleLayer_Retrs = CAShapeLayer()
            let circlePath_Retrs = UIBezierPath(
                arcCenter: center_Retrs,
                radius: radius_Retrs,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Retrs.path = circlePath_Retrs.cgPath
            rippleLayer_Retrs.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Retrs.fillColor = UIColor.clear.cgColor
            rippleLayer_Retrs.lineWidth = 1.0
            rippleLayer_Retrs.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Retrs.layer.insertSublayer(rippleLayer_Retrs, at: 0)
            rippleAnimationLayers_Retrs.append(rippleLayer_Retrs)
        }
        
        avatarImageView_Retrs.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Retrs() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Retrs.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Retrs.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Retrs.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Retrs.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Retrs() {
        hangUpButton_Retrs.addTarget(self, action: #selector(hangUpCall_Retrs), for: .touchUpInside)
        reportButton_Retrs.addTarget(self, action: #selector(reportTapped_Retrs), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Retrs() {
        // 头像容器弹性进场
        avatarContainerView_Retrs.alpha = 0
        avatarContainerView_Retrs.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Retrs.alpha = 1
            self.avatarContainerView_Retrs.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Retrs.alpha = 0
        statusLabel_Retrs.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Retrs.alpha = 1
            self.statusLabel_Retrs.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Retrs.alpha = 0
        hangUpButton_Retrs.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Retrs.alpha = 1
            self.hangUpButton_Retrs.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Retrs() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Retrs, layer_Retrs) in rippleAnimationLayers_Retrs.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Retrs = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Retrs.values = [0, 0.55, 0.22, 0]
            opacityAnim_Retrs.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Retrs.duration = cycleDuration
            opacityAnim_Retrs.repeatCount = .infinity
            opacityAnim_Retrs.beginTime = CACurrentMediaTime() + Double(index_Retrs) * staggerInterval
            opacityAnim_Retrs.isRemovedOnCompletion = false
            
            layer_Retrs.add(opacityAnim_Retrs, forKey: "rippleOpacity_Retrs")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Retrs() {
        let swayAnimation_Retrs = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Retrs.fromValue = -0.05
        swayAnimation_Retrs.toValue = 0.05
        swayAnimation_Retrs.duration = 0.8
        swayAnimation_Retrs.autoreverses = true
        swayAnimation_Retrs.repeatCount = .infinity
        swayAnimation_Retrs.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Retrs.layer.add(swayAnimation_Retrs, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Retrs() {
        for layer_Retrs in rippleAnimationLayers_Retrs {
            layer_Retrs.removeAllAnimations()
        }
        hangUpButton_Retrs.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Retrs() {
        if isSimulatingDecline_Retrs {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Retrs = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Retrs(reason_Retrs: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Retrs = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Retrs(reason_Retrs: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Retrs() {
        declineTimer_Retrs?.invalidate()
        declineTimer_Retrs = nil
        noAnswerTimer_Retrs?.invalidate()
        noAnswerTimer_Retrs = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Retrs: 显示给用户的挂断原因
    private func autoHangUp_Retrs(reason_Retrs: String) {
        cancelAutoHangUpTimers_Retrs()
        stopAnimations_Retrs()
        
        let alert_Retrs = UIAlertController(title: nil, message: reason_Retrs, preferredStyle: .alert)
        let okAction_Retrs = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Retrs.addAction(okAction_Retrs)
        present(alert_Retrs, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Retrs() {
        cancelAutoHangUpTimers_Retrs()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Retrs.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Retrs.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Retrs() {
        guard let userModel_Retrs = userModel_Retrs else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Retrs()
        
        ReportDeleteHelper_Retrs.block_Retrs(
            user_Retrs: userModel_Retrs,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Retrs.popToSafeStateAfterBlock_Retrs(from: self)
        }
    }
}
