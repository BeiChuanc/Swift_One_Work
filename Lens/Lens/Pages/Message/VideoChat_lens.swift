import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Lens: 通话用户信息
/// - rippleAnimationLayers_Lens: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Lens: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Lens: 构建头像与同心圆水波纹
/// - startRippleAnimation_Lens: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Lens: 启动自动挂断计时器
/// - hangUpCall_Lens: 手动挂断通话
class VideoChat_Lens: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Lens: PrewUserModel_Lens?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Lens: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Lens: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Lens: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Lens: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Lens: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Lens: UIView = {
        let view_Lens = UIView()
        view_Lens.backgroundColor = .clear
        return view_Lens
    }()
    
    /// 用户头像
    private let avatarImageView_Lens: UIImageView = {
        let imageView_Lens = UIImageView()
        imageView_Lens.contentMode = .scaleAspectFill
        imageView_Lens.clipsToBounds = true
        imageView_Lens.layer.cornerRadius = 63
        imageView_Lens.layer.borderWidth = 3
        imageView_Lens.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Lens
    }()
    
    /// 用户名标签
    private let usernameLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.textColor = .white
        label_Lens.textAlignment = .center
        label_Lens.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Lens
    }()
    
    /// 通话状态标签
    private let statusLabel_Lens: UILabel = {
        let label_Lens = UILabel()
        label_Lens.text = "Calling..."
        label_Lens.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Lens.textAlignment = .center
        label_Lens.font = UIFont.systemFont(ofSize: 16)
        return label_Lens
    }()
    
    /// 挂断按钮
    private let hangUpButton_Lens: UIButton = {
        let button_Lens = UIButton(type: .system)
        button_Lens.backgroundColor = UIColor(hexstring_Lens: "#BE92FD")
        button_Lens.layer.cornerRadius = 25
        button_Lens.layer.shadowColor = UIColor(hexstring_Lens: "#FF6B9D").cgColor
        button_Lens.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Lens.layer.shadowOpacity = 0.4
        button_Lens.layer.shadowRadius = 16
        
        let config_Lens = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Lens = UIImage(systemName: "phone.down.fill", withConfiguration: config_Lens)
        button_Lens.setImage(image_Lens, for: .normal)
        button_Lens.tintColor = .white
        
        return button_Lens
    }()
    
    /// 举报按钮
    private lazy var reportButton_Lens: UIButton = {
        let button_Lens = ReportDeleteHelper_Lens.createUserReportButton_Lens(
            size_Lens: 44,
            backgroundColor_Lens: UIColor.white.withAlphaComponent(0.15),
            tintColor_Lens: .white,
            withShadow_Lens: true
        )
        return button_Lens
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Lens()
        setupActions_Lens()
        setupAnimations_Lens()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Lens()
        startSwayAnimation_Lens()
        startAutoHangUpTimers_Lens()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Lens()
        cancelAutoHangUpTimers_Lens()
    }
    
    deinit {
        swayAnimationTimer_Lens?.invalidate()
        cancelAutoHangUpTimers_Lens()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Lens() {
        view.addSubview(avatarContainerView_Lens)
        view.addSubview(usernameLabel_Lens)
        view.addSubview(statusLabel_Lens)
        view.addSubview(hangUpButton_Lens)
        
        setupAvatarWithRipples_Lens()
        
        view.addSubview(reportButton_Lens)
        
        // 填充用户数据
        if let userModel_Lens = userModel_Lens {
            usernameLabel_Lens.text = userModel_Lens.userName_Lens
            if let imageName_Lens = userModel_Lens.userHead_Lens {
                avatarImageView_Lens.image = UIImage(named: imageName_Lens)
            }
        }
        
        setupConstraints_Lens()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Lens() {
        avatarContainerView_Lens.addSubview(avatarImageView_Lens)
        
        // 容器中心坐标（300/2 = 150）
        let center_Lens = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Lens: CGFloat = 63
        let ringSpacing_Lens: CGFloat = 18
        let ringCount_Lens = 5
        
        for i in 0..<ringCount_Lens {
            let radius_Lens = avatarRadius_Lens + CGFloat(i + 1) * ringSpacing_Lens
            
            let rippleLayer_Lens = CAShapeLayer()
            let circlePath_Lens = UIBezierPath(
                arcCenter: center_Lens,
                radius: radius_Lens,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Lens.path = circlePath_Lens.cgPath
            rippleLayer_Lens.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Lens.fillColor = UIColor.clear.cgColor
            rippleLayer_Lens.lineWidth = 1.0
            rippleLayer_Lens.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Lens.layer.insertSublayer(rippleLayer_Lens, at: 0)
            rippleAnimationLayers_Lens.append(rippleLayer_Lens)
        }
        
        avatarImageView_Lens.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Lens() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Lens.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Lens.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Lens.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Lens.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Lens.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Lens.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Lens.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Lens() {
        hangUpButton_Lens.addTarget(self, action: #selector(hangUpCall_Lens), for: .touchUpInside)
        reportButton_Lens.addTarget(self, action: #selector(reportTapped_Lens), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Lens() {
        // 头像容器弹性进场
        avatarContainerView_Lens.alpha = 0
        avatarContainerView_Lens.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Lens.alpha = 1
            self.avatarContainerView_Lens.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Lens.alpha = 0
        statusLabel_Lens.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Lens.alpha = 1
            self.statusLabel_Lens.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Lens.alpha = 0
        hangUpButton_Lens.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Lens.alpha = 1
            self.hangUpButton_Lens.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Lens() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Lens, layer_Lens) in rippleAnimationLayers_Lens.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Lens = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Lens.values = [0, 0.55, 0.22, 0]
            opacityAnim_Lens.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Lens.duration = cycleDuration
            opacityAnim_Lens.repeatCount = .infinity
            opacityAnim_Lens.beginTime = CACurrentMediaTime() + Double(index_Lens) * staggerInterval
            opacityAnim_Lens.isRemovedOnCompletion = false
            
            layer_Lens.add(opacityAnim_Lens, forKey: "rippleOpacity_Lens")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Lens() {
        let swayAnimation_Lens = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Lens.fromValue = -0.05
        swayAnimation_Lens.toValue = 0.05
        swayAnimation_Lens.duration = 0.8
        swayAnimation_Lens.autoreverses = true
        swayAnimation_Lens.repeatCount = .infinity
        swayAnimation_Lens.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Lens.layer.add(swayAnimation_Lens, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Lens() {
        for layer_Lens in rippleAnimationLayers_Lens {
            layer_Lens.removeAllAnimations()
        }
        hangUpButton_Lens.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Lens() {
        if isSimulatingDecline_Lens {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Lens = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Lens(reason_Lens: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Lens = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Lens(reason_Lens: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Lens() {
        declineTimer_Lens?.invalidate()
        declineTimer_Lens = nil
        noAnswerTimer_Lens?.invalidate()
        noAnswerTimer_Lens = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Lens: 显示给用户的挂断原因
    private func autoHangUp_Lens(reason_Lens: String) {
        cancelAutoHangUpTimers_Lens()
        stopAnimations_Lens()
        
        let alert_Lens = UIAlertController(title: nil, message: reason_Lens, preferredStyle: .alert)
        let okAction_Lens = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Lens.addAction(okAction_Lens)
        present(alert_Lens, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Lens() {
        cancelAutoHangUpTimers_Lens()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Lens.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Lens.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Lens() {
        guard let userModel_Lens = userModel_Lens else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Lens()
        
        ReportDeleteHelper_Lens.block_Lens(
            user_Lens: userModel_Lens,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Lens.popToSafeStateAfterBlock_Lens(from: self)
        }
    }
}
