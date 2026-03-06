import UIKit
import SnapKit

// MARK: - 视频通话页

/// 视频通话页视图控制器
/// 核心作用：模拟沉浸式全屏通话界面，头像居中波浪扩散 + 15秒无人接听自动关闭 + 挂断按钮持续晃动
/// 设计思路：深色全屏渐变背景 + 居中 UserAvatarView + CALayer 波浪扩散 + 右上角举报 + 底部单挂断
/// 关键属性：userModel_Trace（通话对象），noAnswerTimer_Trace（15秒自动关闭），rippleLayers_Trace（波浪圆圈）
class VideoChat_Trace: UIViewController {

    // MARK: - 公共属性

    /// 通话对象用户模型（由外部传入）
    var userModel_Trace: PrewUserModel_Trace?

    // MARK: - 私有属性

    /// 15 秒无人接听自动关闭计时器
    private var noAnswerTimer_Trace: Timer?
    /// 波浪动画圆圈 layer
    private var rippleLayers_Trace: [CALayer] = []
    /// 标记波浪 layer 已初始化，防止 viewDidLayoutSubviews 多次添加
    private var didSetupRipples_Trace = false
    /// 波浪专用容器视图（z 轴位于背景之上、头像之下，clipsToBounds = false 允许圆圈向外扩散）
    private let rippleContainerView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        v.clipsToBounds = false
        return v
    }()

    // MARK: - UI 组件

    /// 全屏背景渐变层
    private let bgGradLayer_Trace = CAGradientLayer()

    /// 全屏背景容器
    private let bgView_Trace = UIView()

    /// 远端用户头像（使用 UserAvatarView_Trace 组件，圆形）
    private let remoteAvatarView_Trace: UserAvatarView_Trace = {
        let v = UserAvatarView_Trace()
        v.layer.masksToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        return v
    }()

    /// 对方姓名标签
    private let remoteNameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()

    /// 通话状态标签（"Calling..." / "No answer"）
    private let statusLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.text = "Calling..."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.75)
        lbl.textAlignment = .center
        return lbl
    }()

    /// 顶部关闭按钮（左上角）
    private let closeBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "chevron.down", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 举报按钮（右上角，使用 ReportDeleteHelper_Trace 统一构建）
    private lazy var reportBtn_Trace: UIButton = ReportDeleteHelper_Trace.createUserReportButton_Trace(
        size_Trace: 40,
        backgroundColor_Trace: UIColor.white.withAlphaComponent(0.15),
        tintColor_Trace: .white,
        withShadow_Trace: false
    )

    /// 挂断按钮（底部居中，红色醒目，持续缓慢晃动）
    private let endCallBtn_Trace: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        btn.setImage(UIImage(systemName: "phone.down.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(hexstring_Trace: "#FF4757")
        btn.layer.cornerRadius = 38
        btn.layer.masksToBounds = false
        btn.layer.shadowColor = UIColor(hexstring_Trace: "#FF4757").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0.55
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground_Trace()
        setupAvatarArea_Trace()
        setupTopBar_Trace()
        setupBottomBar_Trace()
        fillUserInfo_Trace()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradLayer_Trace.frame = bgView_Trace.bounds
        // 更新头像圆角（UserAvatarView 内部也会更新，此处同步边框圆角）
        remoteAvatarView_Trace.layer.cornerRadius = remoteAvatarView_Trace.bounds.width / 2
        // 布局稳定后初始化一次波浪层（坐标依赖 rippleContainerView_Trace.bounds）
        if !didSetupRipples_Trace && rippleContainerView_Trace.bounds != .zero {
            didSetupRipples_Trace = true
            setupRippleLayers_Trace()
            startRippleAnimation_Trace()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNoAnswerTimer_Trace()
        startEndCallWobble_Trace()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllTimers_Trace()
        rippleLayers_Trace.forEach { $0.removeAllAnimations() }
        endCallBtn_Trace.layer.removeAnimation(forKey: "wobble_Trace")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - UI 配置

    /// 搭建全屏深色渐变背景
    private func setupBackground_Trace() {
        view.addSubview(bgView_Trace)
        bgView_Trace.snp.makeConstraints { make in make.edges.equalToSuperview() }

        bgGradLayer_Trace.colors = [
            UIColor(hexstring_Trace: "#1A0533").cgColor,
            UIColor(hexstring_Trace: "#0D1B3E").cgColor,
            UIColor(hexstring_Trace: "#0A0A1A").cgColor
        ]
        bgGradLayer_Trace.locations = [0, 0.5, 1.0]
        bgGradLayer_Trace.startPoint = CGPoint(x: 0.3, y: 0)
        bgGradLayer_Trace.endPoint   = CGPoint(x: 0.7, y: 1)
        bgView_Trace.layer.insertSublayer(bgGradLayer_Trace, at: 0)
    }

    /// 搭建头像区域（rippleContainerView 先加入确保 z 轴低于头像，头像居中）
    private func setupAvatarArea_Trace() {
        // rippleContainerView 先加入 view，z 轴低于头像
        view.addSubview(rippleContainerView_Trace)
        view.addSubview(remoteAvatarView_Trace)
        view.addSubview(remoteNameLabel_Trace)
        view.addSubview(statusLabel_Trace)

        remoteAvatarView_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            // 垂直居中略微上移，为姓名/状态留出空间
            make.centerY.equalToSuperview().offset(-80)
            make.width.height.equalTo(120)
        }

        // 波浪容器与头像共享中心，尺寸足够容纳最大扩散圆（120 * 2.8 ≈ 336，取 360）
        rippleContainerView_Trace.snp.makeConstraints { make in
            make.center.equalTo(remoteAvatarView_Trace)
            make.width.height.equalTo(360)
        }
        remoteNameLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(remoteAvatarView_Trace.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(40)
        }
        statusLabel_Trace.snp.makeConstraints { make in
            make.top.equalTo(remoteNameLabel_Trace.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }

    /// 搭建顶部导航栏（左关闭 + 右举报）
    private func setupTopBar_Trace() {
        view.addSubview(closeBtn_Trace)
        view.addSubview(reportBtn_Trace)

        closeBtn_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
        reportBtn_Trace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(40)
        }

        closeBtn_Trace.addTarget(self, action: #selector(handleClose_Trace), for: .touchUpInside)
        reportBtn_Trace.addTarget(self, action: #selector(handleReport_Trace), for: .touchUpInside)
    }

    /// 搭建底部挂断区域（仅挂断按钮，水平居中）
    private func setupBottomBar_Trace() {
        view.addSubview(endCallBtn_Trace)
        endCallBtn_Trace.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-48)
            make.width.height.equalTo(76)
        }
        endCallBtn_Trace.addTarget(self, action: #selector(handleEndCall_Trace), for: .touchUpInside)
    }

    /// 将用户信息填充到 UI 组件
    private func fillUserInfo_Trace() {
        remoteNameLabel_Trace.text = userModel_Trace?.userName_Trace ?? "Unknown"
        if let userId = userModel_Trace?.userId_Trace {
            remoteAvatarView_Trace.configure_Trace(userId_Trace: userId)
        }
    }

    // MARK: - 波浪动画

    /// 在 rippleContainerView_Trace 内创建三圈波浪扩散 layer
    /// rippleContainerView 已与头像共享中心，所有 ripple 以容器中心为圆心
    /// 必须在 rippleContainerView_Trace.bounds 已确定后调用（viewDidLayoutSubviews 中）
    private func setupRippleLayers_Trace() {
        // 容器中心即头像中心（容器与头像共享 center 约束）
        let center = CGPoint(
            x: rippleContainerView_Trace.bounds.midX,
            y: rippleContainerView_Trace.bounds.midY
        )
        let baseSize: CGFloat = 120

        [(1.6, 0.0), (2.2, 0.55), (2.8, 1.1)].forEach { (scale, delay) in
            let ripple = CALayer()
            ripple.bounds   = CGRect(x: 0, y: 0, width: baseSize, height: baseSize)
            ripple.position = center
            ripple.cornerRadius = baseSize / 2
            // 动画前先设为透明，避免在 beginTime 延迟期间显示为静态圆圈
            ripple.opacity  = 0
            ripple.backgroundColor = ColorConfig_Trace.primaryGradientStart_Trace
                .withAlphaComponent(0.25).cgColor
            rippleContainerView_Trace.layer.addSublayer(ripple)
            rippleLayers_Trace.append(ripple)

            ripple.setValue(scale, forKey: "scale")
            ripple.setValue(delay, forKey: "delay")
        }
    }

    /// 启动波浪循环动画（scale + opacity 联合组动画，fillMode 保证首帧即可见）
    private func startRippleAnimation_Trace() {
        rippleLayers_Trace.forEach { ripple in
            let scale = ripple.value(forKey: "scale") as? Double ?? 1.6
            let delay = ripple.value(forKey: "delay") as? Double ?? 0.0

            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue   = scale

            let alphaAnim = CABasicAnimation(keyPath: "opacity")
            alphaAnim.fromValue = 0.65
            alphaAnim.toValue   = 0.0

            let group = CAAnimationGroup()
            group.animations  = [scaleAnim, alphaAnim]
            group.duration    = 2.0
            group.beginTime   = CACurrentMediaTime() + delay
            group.repeatCount = .infinity
            group.timingFunction = CAMediaTimingFunction(name: .easeOut)
            // fillMode + isRemovedOnCompletion 确保动画帧之间不闪烁
            group.fillMode = .forwards
            group.isRemovedOnCompletion = false
            ripple.add(group, forKey: "ripple_Trace")
        }
    }

    // MARK: - 挂断按钮持续晃动

    /// 为挂断按钮添加持续缓慢左右摆动动画（CAKeyframeAnimation 驱动，无需 Timer）
    private func startEndCallWobble_Trace() {
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        // 轻微摆动：±8° ≈ ±0.14 rad，来回循环
        wobble.values   = [0, -0.14, 0, 0.14, 0]
        wobble.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        wobble.duration = 1.6
        wobble.repeatCount = .infinity
        wobble.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        wobble.isRemovedOnCompletion = false
        endCallBtn_Trace.layer.add(wobble, forKey: "wobble_Trace")
    }

    // MARK: - 计时逻辑

    /// 启动 15 秒无人接听计时器
    private func startNoAnswerTimer_Trace() {
        noAnswerTimer_Trace = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            self?.handleNoAnswer_Trace()
        }
    }

    /// 停止所有计时器
    private func stopAllTimers_Trace() {
        noAnswerTimer_Trace?.invalidate()
        noAnswerTimer_Trace = nil
    }

    /// 15 秒无人接听处理：文本切换 → 1.5 秒后自动 dismiss
    private func handleNoAnswer_Trace() {
        stopAllTimers_Trace()
        rippleLayers_Trace.forEach { layer in
            layer.removeAllAnimations()
            layer.opacity = 0
        }

        UIView.animate(withDuration: 0.3) {
            self.statusLabel_Trace.alpha = 0
        } completion: { _ in
            self.statusLabel_Trace.text = "No answer"
            UIView.animate(withDuration: 0.3) { self.statusLabel_Trace.alpha = 1 }
        }

        Utils_Trace.showWarning_Trace(message_Trace: "No answer", delay_Trace: 1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            Navigation_Trace.dismiss_Trace()
        }
    }

    // MARK: - 事件处理

    /// 关闭视频通话页
    @objc private func handleClose_Trace() {
        stopAllTimers_Trace()
        Navigation_Trace.dismiss_Trace()
    }

    /// 挂断通话
    @objc private func handleEndCall_Trace() {
        stopAllTimers_Trace()
        endCallBtn_Trace.animatePressDown_Trace {
            Navigation_Trace.dismiss_Trace()
        }
    }

    /// 举报当前通话用户：举报成功后关闭视频通话页（dismiss），再返回上一层（pop）
    @objc private func handleReport_Trace() {
        guard let user = userModel_Trace else { return }
        ReportDeleteHelper_Trace.block_Trace(user_Trace: user, from: self) { [weak self] in
            guard let self = self else { return }
            self.stopAllTimers_Trace()
            // dismiss VideoChat 模态，完成后再 pop 一层（返回消息列表）
            Navigation_Trace.dismiss_Trace(completion: {
                Navigation_Trace.pop_Trace()
            })
        }
    }
}
