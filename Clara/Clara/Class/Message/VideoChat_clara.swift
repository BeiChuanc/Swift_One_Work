import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Clara: 通话用户信息
/// - rippleAnimationLayers_Clara: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Clara: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Clara: 构建头像与同心圆水波纹
/// - startRippleAnimation_Clara: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Clara: 启动自动挂断计时器
/// - hangUpCall_Clara: 手动挂断通话
class VideoChat_Clara: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Clara: PrewUserModel_Clara?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Clara: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Clara: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Clara: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Clara: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Clara: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Clara: UIView = {
        let view_Clara = UIView()
        view_Clara.backgroundColor = .clear
        return view_Clara
    }()
    
    /// 用户头像
    private let avatarImageView_Clara: UIImageView = {
        let imageView_Clara = UIImageView()
        imageView_Clara.contentMode = .scaleAspectFill
        imageView_Clara.clipsToBounds = true
        imageView_Clara.layer.cornerRadius = 63
        imageView_Clara.layer.borderWidth = 3
        imageView_Clara.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Clara
    }()
    
    /// 用户名标签
    private let usernameLabel_Clara: UILabel = {
        let label_Clara = UILabel()
        label_Clara.textColor = .white
        label_Clara.textAlignment = .center
        label_Clara.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Clara
    }()
    
    /// 通话状态标签
    private let statusLabel_Clara: UILabel = {
        let label_Clara = UILabel()
        label_Clara.text = "Calling..."
        label_Clara.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Clara.textAlignment = .center
        label_Clara.font = UIFont.systemFont(ofSize: 16)
        return label_Clara
    }()
    
    /// 挂断按钮
    private let hangUpButton_Clara: UIButton = {
        let button_Clara = UIButton(type: .system)
        button_Clara.backgroundColor = UIColor(hexstring_Clara: "#BE92FD")
        button_Clara.layer.cornerRadius = 25
        button_Clara.layer.shadowColor = UIColor(hexstring_Clara: "#FF6B9D").cgColor
        button_Clara.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Clara.layer.shadowOpacity = 0.4
        button_Clara.layer.shadowRadius = 16
        
        let config_Clara = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Clara = UIImage(systemName: "phone.down.fill", withConfiguration: config_Clara)
        button_Clara.setImage(image_Clara, for: .normal)
        button_Clara.tintColor = .white
        
        return button_Clara
    }()
    
    /// 举报按钮
    private lazy var reportButton_Clara: UIButton = {
        let button_Clara = ReportDeleteHelper_Clara.createUserReportButton_Clara(
            size_Clara: 44,
            backgroundColor_Clara: UIColor.white.withAlphaComponent(0.15),
            tintColor_Clara: .white,
            withShadow_Clara: true
        )
        return button_Clara
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Clara()
        setupActions_Clara()
        setupAnimations_Clara()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Clara()
        startSwayAnimation_Clara()
        startAutoHangUpTimers_Clara()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Clara()
        cancelAutoHangUpTimers_Clara()
    }
    
    deinit {
        swayAnimationTimer_Clara?.invalidate()
        cancelAutoHangUpTimers_Clara()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Clara() {
        view.addSubview(avatarContainerView_Clara)
        view.addSubview(usernameLabel_Clara)
        view.addSubview(statusLabel_Clara)
        view.addSubview(hangUpButton_Clara)
        
        setupAvatarWithRipples_Clara()
        
        view.addSubview(reportButton_Clara)
        
        // 填充用户数据
        if let userModel_Clara = userModel_Clara {
            usernameLabel_Clara.text = userModel_Clara.userName_Clara
            if let imageName_Clara = userModel_Clara.userHead_Clara {
                avatarImageView_Clara.image = UIImage(named: imageName_Clara)
            }
        }
        
        setupConstraints_Clara()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Clara() {
        avatarContainerView_Clara.addSubview(avatarImageView_Clara)
        
        // 容器中心坐标（300/2 = 150）
        let center_Clara = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Clara: CGFloat = 63
        let ringSpacing_Clara: CGFloat = 18
        let ringCount_Clara = 5
        
        for i in 0..<ringCount_Clara {
            let radius_Clara = avatarRadius_Clara + CGFloat(i + 1) * ringSpacing_Clara
            
            let rippleLayer_Clara = CAShapeLayer()
            let circlePath_Clara = UIBezierPath(
                arcCenter: center_Clara,
                radius: radius_Clara,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Clara.path = circlePath_Clara.cgPath
            rippleLayer_Clara.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Clara.fillColor = UIColor.clear.cgColor
            rippleLayer_Clara.lineWidth = 1.0
            rippleLayer_Clara.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Clara.layer.insertSublayer(rippleLayer_Clara, at: 0)
            rippleAnimationLayers_Clara.append(rippleLayer_Clara)
        }
        
        avatarImageView_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Clara() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Clara.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Clara.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Clara() {
        hangUpButton_Clara.addTarget(self, action: #selector(hangUpCall_Clara), for: .touchUpInside)
        reportButton_Clara.addTarget(self, action: #selector(reportTapped_Clara), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Clara() {
        // 头像容器弹性进场
        avatarContainerView_Clara.alpha = 0
        avatarContainerView_Clara.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Clara.alpha = 1
            self.avatarContainerView_Clara.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Clara.alpha = 0
        statusLabel_Clara.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Clara.alpha = 1
            self.statusLabel_Clara.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Clara.alpha = 0
        hangUpButton_Clara.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Clara.alpha = 1
            self.hangUpButton_Clara.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Clara() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Clara, layer_Clara) in rippleAnimationLayers_Clara.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Clara = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Clara.values = [0, 0.55, 0.22, 0]
            opacityAnim_Clara.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Clara.duration = cycleDuration
            opacityAnim_Clara.repeatCount = .infinity
            opacityAnim_Clara.beginTime = CACurrentMediaTime() + Double(index_Clara) * staggerInterval
            opacityAnim_Clara.isRemovedOnCompletion = false
            
            layer_Clara.add(opacityAnim_Clara, forKey: "rippleOpacity_Clara")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Clara() {
        let swayAnimation_Clara = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Clara.fromValue = -0.05
        swayAnimation_Clara.toValue = 0.05
        swayAnimation_Clara.duration = 0.8
        swayAnimation_Clara.autoreverses = true
        swayAnimation_Clara.repeatCount = .infinity
        swayAnimation_Clara.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Clara.layer.add(swayAnimation_Clara, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Clara() {
        for layer_Clara in rippleAnimationLayers_Clara {
            layer_Clara.removeAllAnimations()
        }
        hangUpButton_Clara.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Clara() {
        if isSimulatingDecline_Clara {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Clara = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Clara(reason_Clara: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Clara = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Clara(reason_Clara: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Clara() {
        declineTimer_Clara?.invalidate()
        declineTimer_Clara = nil
        noAnswerTimer_Clara?.invalidate()
        noAnswerTimer_Clara = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Clara: 显示给用户的挂断原因
    private func autoHangUp_Clara(reason_Clara: String) {
        cancelAutoHangUpTimers_Clara()
        stopAnimations_Clara()
        
        let alert_Clara = UIAlertController(title: nil, message: reason_Clara, preferredStyle: .alert)
        let okAction_Clara = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Clara.addAction(okAction_Clara)
        present(alert_Clara, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Clara() {
        cancelAutoHangUpTimers_Clara()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Clara.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Clara.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Clara() {
        guard let userModel_Clara = userModel_Clara else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Clara()
        
        ReportDeleteHelper_Clara.block_Clara(
            user_Clara: userModel_Clara,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Clara.popToSafeStateAfterBlock_Clara(from: self)
        }
    }
}
