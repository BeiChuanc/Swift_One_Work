import Foundation
import UIKit
import SnapKit

// MARK: - 视频通话界面

/// 视频通话界面
/// 核心功能：模拟视频通话界面，展示对方头像和操作按钮
/// 设计思路：纯黑背景，头像居中展示，以头像为圆心向外辐射多圈同心细纹水波纹动画，
///           随机模拟对方拒接（3秒）或无人应答（10秒）自动挂断场景
/// 关键属性：
/// - userModel_Orna: 通话用户信息
/// - rippleAnimationLayers_Orna: 同心圆细纹水波纹图层数组
/// - isSimulatingDecline_Orna: 随机决定本次通话是否模拟拒接场景
/// 关键方法：
/// - setupAvatarWithRipples_Orna: 构建头像与同心圆水波纹
/// - startRippleAnimation_Orna: 启动由内向外依次显示的细纹动画
/// - startAutoHangUpTimers_Orna: 启动自动挂断计时器
/// - hangUpCall_Orna: 手动挂断通话
class VideoChat_Orna: UIViewController {
    
    // MARK: - 属性
    
    /// 通话用户
    var userModel_Orna: PrewUserModel_Orna?
    
    /// 同心圆细纹水波纹图层数组（由内向外排列）
    private var rippleAnimationLayers_Orna: [CAShapeLayer] = []
    
    /// 挂断按钮摇摆动画引用（用于停止）
    private var swayAnimationTimer_Orna: Timer?
    
    /// 无人应答自动挂断计时器（10 秒后触发）
    private var noAnswerTimer_Orna: Timer?
    
    /// 模拟拒接自动挂断计时器（3 秒后触发）
    private var declineTimer_Orna: Timer?
    
    /// 随机决定本次通话场景：true = 3秒对方拒接；false = 10秒无人应答
    private let isSimulatingDecline_Orna: Bool = Bool.random()
    
    // MARK: - UI 组件
    
    /// 头像容器视图（300×300，承载头像及同心圆水波纹图层）
    private let avatarContainerView_Orna: UIView = {
        let view_Orna = UIView()
        view_Orna.backgroundColor = .clear
        return view_Orna
    }()
    
    /// 用户头像
    private let avatarImageView_Orna: UIImageView = {
        let imageView_Orna = UIImageView()
        imageView_Orna.contentMode = .scaleAspectFill
        imageView_Orna.clipsToBounds = true
        imageView_Orna.layer.cornerRadius = 63
        imageView_Orna.layer.borderWidth = 3
        imageView_Orna.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        return imageView_Orna
    }()
    
    /// 用户名标签
    private let usernameLabel_Orna: UILabel = {
        let label_Orna = UILabel()
        label_Orna.textColor = .white
        label_Orna.textAlignment = .center
        label_Orna.font = UIFont.boldSystemFont(ofSize: 26)
        return label_Orna
    }()
    
    /// 通话状态标签
    private let statusLabel_Orna: UILabel = {
        let label_Orna = UILabel()
        label_Orna.text = "Calling..."
        label_Orna.textColor = UIColor.white.withAlphaComponent(0.6)
        label_Orna.textAlignment = .center
        label_Orna.font = UIFont.funFont_Orna(ofSize: 16)
        return label_Orna
    }()
    
    /// 挂断按钮
    private let hangUpButton_Orna: UIButton = {
        let button_Orna = UIButton(type: .system)
        button_Orna.backgroundColor = UIColor(hexstring_Orna: "#BE92FD")
        button_Orna.layer.cornerRadius = 25
        button_Orna.layer.shadowColor = UIColor(hexstring_Orna: "#FF6B9D").cgColor
        button_Orna.layer.shadowOffset = CGSize(width: 0, height: 8)
        button_Orna.layer.shadowOpacity = 0.4
        button_Orna.layer.shadowRadius = 16
        
        let config_Orna = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image_Orna = UIImage(systemName: "phone.down.fill", withConfiguration: config_Orna)
        button_Orna.setImage(image_Orna, for: .normal)
        button_Orna.tintColor = .white
        
        return button_Orna
    }()
    
    /// 举报按钮
    private lazy var reportButton_Orna: UIButton = {
        let button_Orna = ReportDeleteHelper_Orna.createUserReportButton_Orna(
            size_Orna: 44,
            backgroundColor_Orna: UIColor.white.withAlphaComponent(0.15),
            tintColor_Orna: .white,
            withShadow_Orna: true
        )
        return button_Orna
    }()
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI_Orna()
        setupActions_Orna()
        setupAnimations_Orna()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRippleAnimation_Orna()
        startSwayAnimation_Orna()
        startAutoHangUpTimers_Orna()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAnimations_Orna()
        cancelAutoHangUpTimers_Orna()
    }
    
    deinit {
        swayAnimationTimer_Orna?.invalidate()
        cancelAutoHangUpTimers_Orna()
    }
    
    // MARK: - UI 设置
    
    /// 构建界面布局
    private func setupUI_Orna() {
        view.addSubview(avatarContainerView_Orna)
        view.addSubview(usernameLabel_Orna)
        view.addSubview(statusLabel_Orna)
        view.addSubview(hangUpButton_Orna)
        
        setupAvatarWithRipples_Orna()
        
        view.addSubview(reportButton_Orna)
        
        // 填充用户数据
        if let userModel_Orna = userModel_Orna {
            usernameLabel_Orna.text = userModel_Orna.userName_Orna
            if let imageName_Orna = userModel_Orna.userHead_Orna {
                avatarImageView_Orna.image = UIImage(named: imageName_Orna)
            }
        }
        
        setupConstraints_Orna()
    }
    
    /// 构建头像与同心圆水波纹图层
    /// 容器尺寸 300×300，头像居中，以头像圆心为基准向外依次创建 5 圈细纹
    private func setupAvatarWithRipples_Orna() {
        avatarContainerView_Orna.addSubview(avatarImageView_Orna)
        
        // 容器中心坐标（300/2 = 150）
        let center_Orna = CGPoint(x: 150, y: 150)
        
        // 头像半径 63，从外缘起步每隔 18pt 创建一圈细纹，共 5 圈
        let avatarRadius_Orna: CGFloat = 63
        let ringSpacing_Orna: CGFloat = 18
        let ringCount_Orna = 5
        
        for i in 0..<ringCount_Orna {
            let radius_Orna = avatarRadius_Orna + CGFloat(i + 1) * ringSpacing_Orna
            
            let rippleLayer_Orna = CAShapeLayer()
            let circlePath_Orna = UIBezierPath(
                arcCenter: center_Orna,
                radius: radius_Orna,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            rippleLayer_Orna.path = circlePath_Orna.cgPath
            rippleLayer_Orna.strokeColor = UIColor.white.withAlphaComponent(0.75).cgColor
            rippleLayer_Orna.fillColor = UIColor.clear.cgColor
            rippleLayer_Orna.lineWidth = 1.0
            rippleLayer_Orna.opacity = 0
            
            // 插入到头像视图层级之下
            avatarContainerView_Orna.layer.insertSublayer(rippleLayer_Orna, at: 0)
            rippleAnimationLayers_Orna.append(rippleLayer_Orna)
        }
        
        avatarImageView_Orna.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(126)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Orna() {
        // 头像容器：300×300，水波纹在此范围内完整展示
        avatarContainerView_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.width.height.equalTo(300)
        }
        
        // 用户名
        usernameLabel_Orna.snp.makeConstraints { make in
            make.top.equalTo(avatarContainerView_Orna.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 状态标签
        statusLabel_Orna.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel_Orna.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        // 挂断按钮
        hangUpButton_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.width.equalTo(120)
            make.height.equalTo(70)
        }
        
        // 举报按钮
        reportButton_Orna.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(44)
        }
    }
    
    /// 绑定按钮事件
    private func setupActions_Orna() {
        hangUpButton_Orna.addTarget(self, action: #selector(hangUpCall_Orna), for: .touchUpInside)
        reportButton_Orna.addTarget(self, action: #selector(reportTapped_Orna), for: .touchUpInside)
    }
    
    // MARK: - 动画设置
    
    /// 设置进场动画
    private func setupAnimations_Orna() {
        // 头像容器弹性进场
        avatarContainerView_Orna.alpha = 0
        avatarContainerView_Orna.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0) {
            self.avatarContainerView_Orna.alpha = 1
            self.avatarContainerView_Orna.transform = .identity
        }
        
        // 文字淡入
        usernameLabel_Orna.alpha = 0
        statusLabel_Orna.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.usernameLabel_Orna.alpha = 1
            self.statusLabel_Orna.alpha = 1
        }
        
        // 挂断按钮从下方滑入
        hangUpButton_Orna.alpha = 0
        hangUpButton_Orna.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.hangUpButton_Orna.alpha = 1
            self.hangUpButton_Orna.transform = .identity
        }
    }
    
    /// 启动水波纹动画：由内向外依次对各圈细纹做透明度脉冲
    /// 各圈之间错开 0.5 秒，形成涟漪向外扩散的视觉效果
    private func startRippleAnimation_Orna() {
        let cycleDuration: Double = 2.5
        let staggerInterval: Double = 0.5
        
        for (index_Orna, layer_Orna) in rippleAnimationLayers_Orna.enumerated() {
            // 透明度关键帧：快速亮起 → 缓慢消散
            let opacityAnim_Orna = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnim_Orna.values = [0, 0.55, 0.22, 0]
            opacityAnim_Orna.keyTimes = [0, 0.2, 0.65, 1.0]
            opacityAnim_Orna.duration = cycleDuration
            opacityAnim_Orna.repeatCount = .infinity
            opacityAnim_Orna.beginTime = CACurrentMediaTime() + Double(index_Orna) * staggerInterval
            opacityAnim_Orna.isRemovedOnCompletion = false
            
            layer_Orna.add(opacityAnim_Orna, forKey: "rippleOpacity_Orna")
        }
    }
    
    /// 启动挂断按钮左右摇摆动画
    private func startSwayAnimation_Orna() {
        let swayAnimation_Orna = CABasicAnimation(keyPath: "transform.rotation")
        swayAnimation_Orna.fromValue = -0.05
        swayAnimation_Orna.toValue = 0.05
        swayAnimation_Orna.duration = 0.8
        swayAnimation_Orna.autoreverses = true
        swayAnimation_Orna.repeatCount = .infinity
        swayAnimation_Orna.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        hangUpButton_Orna.layer.add(swayAnimation_Orna, forKey: "sway")
    }
    
    /// 停止所有图层动画
    private func stopAnimations_Orna() {
        for layer_Orna in rippleAnimationLayers_Orna {
            layer_Orna.removeAllAnimations()
        }
        hangUpButton_Orna.layer.removeAllAnimations()
    }
    
    // MARK: - 自动挂断
    
    /// 启动自动挂断计时器
    /// 随机选择场景：对方 3 秒拒接 或 10 秒无人应答（仅一个计时器生效）
    private func startAutoHangUpTimers_Orna() {
        if isSimulatingDecline_Orna {
            // 模拟场景：对方 3 秒后主动拒接
            declineTimer_Orna = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Orna(reason_Orna: "The other party declined your call")
            }
        } else {
            // 模拟场景：10 秒内无人应答
            noAnswerTimer_Orna = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                self?.autoHangUp_Orna(reason_Orna: "No answer")
            }
        }
    }
    
    /// 取消所有自动挂断计时器
    private func cancelAutoHangUpTimers_Orna() {
        declineTimer_Orna?.invalidate()
        declineTimer_Orna = nil
        noAnswerTimer_Orna?.invalidate()
        noAnswerTimer_Orna = nil
    }
    
    /// 自动挂断并展示提示弹窗
    /// - Parameter reason_Orna: 显示给用户的挂断原因
    private func autoHangUp_Orna(reason_Orna: String) {
        cancelAutoHangUpTimers_Orna()
        stopAnimations_Orna()
        
        let alert_Orna = UIAlertController(title: nil, message: reason_Orna, preferredStyle: .alert)
        let okAction_Orna = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert_Orna.addAction(okAction_Orna)
        present(alert_Orna, animated: true)
    }
    
    // MARK: - 事件处理
    
    /// 手动挂断通话
    @objc private func hangUpCall_Orna() {
        cancelAutoHangUpTimers_Orna()
        
        // 按钮点击缩放反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.hangUpButton_Orna.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.hangUpButton_Orna.transform = .identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
    
    /// 举报按钮点击：拉黑该用户并清除导航堆栈中所有与该用户相关的页面
    @objc private func reportTapped_Orna() {
        guard let userModel_Orna = userModel_Orna else { return }
        
        // 先取消自动挂断，避免与举报流程冲突
        cancelAutoHangUpTimers_Orna()
        
        ReportDeleteHelper_Orna.block_Orna(
            user_Orna: userModel_Orna,
            from: self
        ) { [weak self] in
            guard let self = self else { return }
            // 拉黑成功：dismiss 当前视图并清除导航栈中的相关页面
            Navigation_Orna.popToSafeStateAfterBlock_Orna(from: self)
        }
    }
}
