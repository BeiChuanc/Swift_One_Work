import UIKit
import SnapKit

// MARK: - 聊天确认底部弹窗

/// 聊天确认底部弹窗组件
/// 核心作用：在用户进入聊天前展示目标用户的关键信息，提供确认/取消操作
/// 设计思路：
///   半透明蒙层 + 白色圆角卡片由底部滑入，展示头像、姓名、简介；
///   点击蒙层或取消按钮滑出消失，点击确认按钮触发 onConfirm_Tidy 回调。
/// 关键属性/方法：
///   - userModel_Tidy：目标用户模型（外部注入）
///   - onConfirm_Tidy：点击确认后的回调
///   - present_Tidy(in:)：将弹窗添加到指定容器并执行入场动画
///   - dismiss_Tidy(completion:)：执行出场动画后移除视图
class ChatConfirmSheet_Tidy: UIView {

    // MARK: - 公开属性

    /// 点击"Start Chat"确认后触发的回调
    var onConfirm_Tidy: (() -> Void)?

    // MARK: - 私有属性

    /// 目标用户模型
    private let userModel_Tidy: PrewUserModel_Tidy

    // MARK: - UI 组件 - 蒙层

    /// 半透明背景蒙层
    private let overlayView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withValues(alpha: 0)
        return v
    }()

    // MARK: - UI 组件 - 卡片容器

    /// 底部圆角白色卡片
    private let cardView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.12).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 1
        return v
    }()

    // MARK: - UI 组件 - 拖拽指示器

    /// 顶部拖拽小横条
    private let dragIndicator_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.divider_Tidy
        v.layer.cornerRadius = 2.5
        return v
    }()

    // MARK: - UI 组件 - 标题

    /// 弹窗顶部标题
    private let titleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Start Chatting"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件 - 用户信息区

    /// 头像外圈渐变光环容器
    private let avatarRingView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 38
        v.clipsToBounds = true
        return v
    }()

    private var avatarRingGradient_Tidy: CAGradientLayer?

    /// 用户头像
    private let avatarView_Tidy: UserAvatarView_Tidy = {
        let v = UserAvatarView_Tidy()
        v.layer.cornerRadius = 32
        v.clipsToBounds = true
        return v
    }()

    /// 用户名称
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.textColor = ColorConfig_Tidy.textPrimary_Tidy
        l.textAlignment = .center
        return l
    }()

    /// 用户简介
    private let bioLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI 组件 - 提示文字

    /// 提示信息文字
    private let hintLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "You're about to enter a chat with this user"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: - UI 组件 - 操作按钮区

    private let btnStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    /// 取消按钮
    private let cancelBtn_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(ColorConfig_Tidy.textSecondary_Tidy, for: .normal)
        btn.backgroundColor = ColorConfig_Tidy.backgroundSecondary_Tidy
        btn.layer.cornerRadius = 22
        return btn
    }()

    /// 确认进入聊天按钮（主色实色背景，避免动态视图中渐变图层时序问题）
    private let confirmBtn_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Start Chat", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        btn.layer.cornerRadius = 22
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "bubble.left.fill", withConfiguration: cfg), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return btn
    }()

    // MARK: - 初始化

    /// 初始化弹窗
    /// - Parameter userModel_Tidy: 目标用户模型，用于展示头像和基本信息
    init(userModel_Tidy: PrewUserModel_Tidy) {
        self.userModel_Tidy = userModel_Tidy
        super.init(frame: .zero)
        setupLayout_Tidy()
        bindActions_Tidy()
        populateUserInfo_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 布局更新

    override func layoutSubviews() {
        super.layoutSubviews()
        updateAvatarRing_Tidy()
    }

    // MARK: - 公开方法

    /// 将弹窗添加到指定父视图并执行入场动画
    /// - Parameter parentView_Tidy: 要附着的父视图（通常为 window 或 VC 的 view）
    func present_Tidy(in parentView_Tidy: UIView) {
        parentView_Tidy.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 初始位置：卡片在屏幕外底部
        parentView_Tidy.layoutIfNeeded()
        cardView_Tidy.transform = CGAffineTransform(translationX: 0, y: cardView_Tidy.bounds.height + 80)

        // 入场动画：蒙层渐入 + 卡片上滑
        UIView.animate(withDuration: 0.38, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.overlayView_Tidy.backgroundColor = UIColor.black.withValues(alpha: 0.5)
            self.cardView_Tidy.transform = .identity
        }
    }

    /// 执行出场动画并在完成后从父视图移除
    /// - Parameter completion_Tidy: 动画完成后的回调（可选）
    func dismiss_Tidy(completion_Tidy: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseIn, animations: {
            self.overlayView_Tidy.backgroundColor = UIColor.black.withValues(alpha: 0)
            self.cardView_Tidy.transform = CGAffineTransform(translationX: 0, y: self.cardView_Tidy.bounds.height + 80)
        }, completion: { _ in
            self.removeFromSuperview()
            completion_Tidy?()
        })
    }

    // MARK: - 私有 - 布局

    /// 搭建视图层级与约束
    private func setupLayout_Tidy() {
        addSubview(overlayView_Tidy)
        addSubview(cardView_Tidy)
        cardView_Tidy.addSubview(dragIndicator_Tidy)
        cardView_Tidy.addSubview(titleLabel_Tidy)
        cardView_Tidy.addSubview(avatarRingView_Tidy)
        avatarRingView_Tidy.addSubview(avatarView_Tidy)
        cardView_Tidy.addSubview(nameLabel_Tidy)
        cardView_Tidy.addSubview(bioLabel_Tidy)
        cardView_Tidy.addSubview(hintLabel_Tidy)
        cardView_Tidy.addSubview(btnStack_Tidy)
        btnStack_Tidy.addArrangedSubview(cancelBtn_Tidy)
        btnStack_Tidy.addArrangedSubview(confirmBtn_Tidy)

        overlayView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        cardView_Tidy.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        dragIndicator_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(dragIndicator_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        avatarRingView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(76)
        }

        avatarView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(64)
        }

        nameLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        bioLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Tidy.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        hintLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        btnStack_Tidy.snp.makeConstraints { make in
            make.top.equalTo(hintLabel_Tidy.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-34)
        }
    }

    // MARK: - 私有 - 数据填充

    /// 根据用户模型填充头像、姓名、简介
    private func populateUserInfo_Tidy() {
        nameLabel_Tidy.text = userModel_Tidy.userName_Tidy ?? "Unknown"
        let bio_Tidy = userModel_Tidy.userIntroduce_Tidy ?? "No bio yet."
        bioLabel_Tidy.text = bio_Tidy.isEmpty ? "No bio yet." : bio_Tidy
        if let userId_Tidy = userModel_Tidy.userId_Tidy {
            avatarView_Tidy.configure_Tidy(userId_Tidy: userId_Tidy)
        }
    }

    // MARK: - 私有 - 事件绑定

    /// 绑定按钮点击和蒙层点击事件
    private func bindActions_Tidy() {
        cancelBtn_Tidy.addTarget(self, action: #selector(cancelTapped_Tidy), for: .touchUpInside)
        confirmBtn_Tidy.addTarget(self, action: #selector(confirmTapped_Tidy), for: .touchUpInside)

        // 点击蒙层关闭弹窗
        let tap_Tidy = UITapGestureRecognizer(target: self, action: #selector(overlayTapped_Tidy))
        overlayView_Tidy.addGestureRecognizer(tap_Tidy)
    }

    // MARK: - 私有 - 按钮响应

    /// 点击取消或蒙层 - 关闭弹窗
    @objc private func cancelTapped_Tidy() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss_Tidy()
    }

    /// 点击蒙层 - 关闭弹窗
    @objc private func overlayTapped_Tidy() {
        dismiss_Tidy()
    }

    /// 点击确认 - 关闭弹窗后触发跳转回调
    @objc private func confirmTapped_Tidy() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 按钮缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.confirmBtn_Tidy.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) { self.confirmBtn_Tidy.transform = .identity }
        })
        dismiss_Tidy(completion_Tidy: { [weak self] in
            self?.onConfirm_Tidy?()
        })
    }

    // MARK: - 私有 - 渐变更新

    /// 更新头像外圈渐变光环
    private func updateAvatarRing_Tidy() {
        guard avatarRingView_Tidy.bounds.width > 0, avatarRingGradient_Tidy == nil else { return }
        let grad_Tidy = UIColor.createSecondaryGradientLayer_Tidy(frame_Tidy: avatarRingView_Tidy.bounds)
        grad_Tidy.cornerRadius = 38
        avatarRingView_Tidy.layer.insertSublayer(grad_Tidy, at: 0)
        avatarRingGradient_Tidy = grad_Tidy
    }

}
