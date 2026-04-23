import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Nest: 通话用户信息
/// - rippleAnimationLayers_Nest: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Nest: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Nest: 构建头像与同心圆水波纹
/// - startRippleAnimation_Nest: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Nest: 启动自动挂断计时器
/// - hangUpCall_Nest: 手动挂断通话
class VideoChat_Nest: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Nest: PrewUserModel_Nest?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Nest: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Nest: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Nest: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Nest: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Nest: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Nest: UIView = {
        let view_Nest = UIView()
        view_Nest.backgroundColor = .clear
        return view_Nest
    }()
    
    /// 用户头像
    private let avatarImageView_Nest: UIImageView = {
        let imageView_Nest = UIImageView()
        imageView_Nest.contentMode = .scaleAspectFill
        imageView_Nest.clipsToBounds = true
        imageView_Nest.layer.cornerRadius = 63
        imageView_Nest.layer.borderWidth = 3
        imageView_Nest.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Nest
    }()
    
    /// 用户名标签
    private let usernameLabel_Nest: UILabel = {
        let label_Nest = UILabel()
        label_Nest.textColor = .white
        label_Nest.textAlignment = .center
        label_Nest.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Nest
    }()
    
    /// 通话状态标签
    private let statusLabel_Nest: UILabel = {
        let label_Nest = UILabel()
        label_Nest.text = "Calling..."
        label_Nest.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Nest.textAlignment = .center
        label_Nest.font = UIFont.systemFont(ofSize: 16)
        return label_Nest
    }()
    
    /// 挂断按钮（红色正圆）
    private let hangUpButton_Nest: UIButton = {
        let button_Nest = UIButton(type: .system)
        button_Nest.backgroundColor = UIColor(hexstring_Nest: "#F56565")
        button_Nest.layer.cornerRadius = 35
        button_Nest.layer.shadowColor = UIColor(hexstring_Nest: "#F56565").cgColor
        button_Nest.layer.shadowOffset = CGSize(width: 0, height: 6)
        button_Nest.layer.shadowOpacity = 0.45
        button_Nest.layer.shadowRadius = 14

        let config_Nest = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image_Nest = UIImage(systemName: "phone.down.fill", withConfiguration: config_Nest)
        button_Nest.setImage(image_Nest, for: .normal)
        button_Nest.tintColor = .white

        return button_Nest
    }()
    
    /// 举报按钮
    private lazy var reportButton_Nest: UIButton = {
        let button_Nest = ReportDeleteHelper_Nest.createUserReportButton_Nest(
            size_Nest: 44,
            backgroundColor_Nest: UIColor.white.withAlphaComponent(0.15),
            tintColor_Nest: .white,
            withShadow_Nest: true
        )
        return button_Nest
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Nest()
        setupActions_Nest()
        setupAnimations_Nest()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Nest()
        startSwayAnimation_Nest()
        startAutoHangUpTimers_Nest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Nest()
        cancelAutoHangUpTimers_Nest()
    }
    
    deinit {
        swayAnimationTimer_Nest?.invalidate()
        cancelAutoHangUpTimers_Nest()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Nest() {
        view.addSubview(avatarContainerView_Nest)
        view.addSubview(usernameLabel_Nest)
        view.addSubview(statusLabel_Nest)
        view.addSubview(hangUpButton_Nest)
        
        setupAvatarWithRipples_Nest()
        
        view.addSubview(reportButton_Nest)
        
        // 填充用户数据
        if let userModel_Nest = userModel_Nest {
            usernameLabel_Nest.text = userModel_Nest.userName_Nest
            if let imageName_Nest = userModel_Nest.userHead_Nest {
                avatarImageView_Nest.image = UIImage(named: imageName_Nest)
            }
        }
        
        setupConstraints_Nest()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Nest() {
        avatarContainerView_Nest.addSubview(avatarImageView_Nest)
        
        // 容器中心坐标（300/2 = 150）
        let center_Nest = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Nest: CGFloat = 63
        let ringSpacing_Nest: CGFloat = 18
        let ringCount_Nest = 5
        
        for i in 0..<ringCount_Nest {
            let radius_Nest = avatarRadius_Nest + CGFloat(i + 1) * ringSpacing_Nest
            
            let rippleLayer_Nest = CAShapeLayer()
            let circlePath_Nest = UIBezierPath(
                arcCenter: center_Nest,
                radius: radius_Nest,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Nest.path = circlePath_Nest.cgPath
            rippleLayer_Nest.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Nest.fillColor = UIColor.clear.cgColor
            rippleLayer_Nest.lineWidth = 1.0
            rippleLayer_Nest.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Nest.layer.insertSublayer(rippleLayer_Nest, at: 0)
            rippleAnimationLayers_Nest.append(rippleLayer_Nest)
        }
        
        avatarImageView_Nest.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Nest() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Nest.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Nest.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Nest.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Nest.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮（正圆 70×70）
        hangUpButton_Nest.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.width.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Nest.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Nest() {
        hangUpButton_Nest.addTarget(self, action: #selector(hangUpCall_Nest), for: .touchUpInside)
        reportButton_Nest.addTarget(self, action: #selector(reportTapped_Nest), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Nest() {
        // 头像容器弹性进场
        avatarContainerView_Nest.alpha = 0
        avatarContainerView_Nest.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Nest.alpha = 1
            self.avatarContainerView_Nest.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Nest.alpha = 0
        statusLabel_Nest.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Nest.alpha = 1
            self.statusLabel_Nest.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Nest.alpha = 0
        hangUpButton_Nest.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Nest.alpha = 1
            self.hangUpButton_Nest.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Nest() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Nest, layer_Nest) in rippleAnimationLayers_Nest.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Nest = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Nest.values = [0, 0.55, 0.22, 0]
            opacityAnim_Nest.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Nest.duration = cycleDuration
            opacityAnim_Nest.repeatCount = .infinity
            opacityAnim_Nest.beginTime = CACurrentMediaTime() + Double(index_Nest) * staggerInterval
            opacityAnim_Nest.isRemovedOnCompletion = false
            
            layer_Nest.add(opacityAnim_Nest, forKey: "rippleOpacity_Nest")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Nest() {
        let swayAnimation_Nest = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Nest.fromValue = -0.05
        swayAnimation_Nest.toValue = 0.05
        swayAnimation_Nest.duration = 0.8
        swayAnimation_Nest.autoreverses = true
        swayAnimation_Nest.repeatCount = .infinity
        swayAnimation_Nest.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Nest.layer.add(swayAnimation_Nest, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Nest() {
        for layer_Nest in rippleAnimationLayers_Nest {
            layer_Nest.removeAllAnimations()
        }
        hangUpButton_Nest.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Nest() {
        if isSimulatingDecline_Nest {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Nest = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Nest(reason_Nest: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Nest = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Nest(reason_Nest: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Nest() {
        declineTimer_Nest?.invalidate()
        declineTimer_Nest = nil
        noAnswerTimer_Nest?.invalidate()
        noAnswerTimer_Nest = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Nest: 显示给用户的挂断原因
    private func autoHangUp_Nest(reason_Nest: String) {
        cancelAutoHangUpTimers_Nest()
        stopAnimations_Nest()
        
        let alert_Nest = UIAlertController(title: nil, message: reason_Nest, preferredStyle: .alert)
        let okAction_Nest = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Nest.addAction(okAction_Nest)
        present(alert_Nest, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Nest() {
        cancelAutoHangUpTimers_Nest()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Nest.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Nest.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Nest() {
        guard let userModel_Nest = userModel_Nest else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Nest()
        
        ReportDeleteHelper_Nest.block_Nest(
            user_Nest: userModel_Nest,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Nest.popToSafeStateAfterBlock_Nest(from: self)
        }
    }
}
