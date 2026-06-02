import Foundation
import UIKit
import SnapKit

// MARK: - 底部用户确认弹窗组件

/// 底部用户确认弹窗
/// 核心作用：进入聊天前以底部弹窗展示目标用户信息，二次确认后才进入聊天
/// 设计思路：自带半透明遮罩 + 底部卡片，提供 confirm/cancel 回调，自管理显示与消失
class UserConfirmSheet_Breeze: UIView {
    
    // MARK: - 回调
    
    /// 确认回调
    private var onConfirm_Breeze: (() -> Void)?
    
    // MARK: - UI 组件
    
    /// 遮罩
    private let dimView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view_breeze.alpha = 0
        return view_breeze
    }()
    
    /// 底部卡片
    private let cardView_Breeze: UIView = {
        let view_breeze = UIView()
        view_breeze.backgroundColor = ColorConfig_Breeze.cardBackground_Breeze
        view_breeze.layer.cornerRadius = 24
        view_breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view_breeze
    }()
    
    /// 头像
    private let avatarView_Breeze = UserAvatarView_Breeze()
    
    /// 名字
    private let nameLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    /// 简介
    private let introLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        label_breeze.textAlignment = .center
        label_breeze.numberOfLines = 2
        return label_breeze
    }()
    
    /// 提示
    private let tipLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_breeze.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        label_breeze.textAlignment = .center
        label_breeze.text = "Enter the chat with this camper?"
        return label_breeze
    }()
    
    /// 确认按钮
    private let confirmButton_Breeze: UIButton = {
        let button_breeze = UIButton(type: .system)
        button_breeze.setTitle("Enter Chat", for: .normal)
        button_breeze.setTitleColor(.white, for: .normal)
        button_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button_breeze.backgroundColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        button_breeze.layer.cornerRadius = 24
        return button_breeze
    }()
    
    /// 取消按钮
    private let cancelButton_Breeze: UIButton = {
        let button_breeze = UIButton(type: .system)
        button_breeze.setTitle("Cancel", for: .normal)
        button_breeze.setTitleColor(ColorConfig_Breeze.textSecondary_Breeze, for: .normal)
        button_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return button_breeze
    }()
    
    /// 卡片底部约束（用于滑入滑出动画）
    private var cardBottomConstraint_Breeze: Constraint?
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Breeze()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI 设置
    
    private func setupUI_Breeze() {
        addSubview(dimView_Breeze)
        addSubview(cardView_Breeze)
        cardView_Breeze.addSubview(avatarView_Breeze)
        cardView_Breeze.addSubview(nameLabel_Breeze)
        cardView_Breeze.addSubview(introLabel_Breeze)
        cardView_Breeze.addSubview(tipLabel_Breeze)
        cardView_Breeze.addSubview(confirmButton_Breeze)
        cardView_Breeze.addSubview(cancelButton_Breeze)
        
        dimView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        cardView_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            cardBottomConstraint_Breeze = make.bottom.equalToSuperview().offset(420).constraint
        }
        avatarView_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Breeze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        introLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Breeze.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(30)
        }
        tipLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(introLabel_Breeze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }
        confirmButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(tipLabel_Breeze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        cancelButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(confirmButton_Breeze.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-34)
        }
        
        confirmButton_Breeze.addTarget(self, action: #selector(handleConfirm_Breeze), for: .touchUpInside)
        cancelButton_Breeze.addTarget(self, action: #selector(dismissSheet_Breeze), for: .touchUpInside)
        let tap_breeze = UITapGestureRecognizer(target: self, action: #selector(dismissSheet_Breeze))
        dimView_Breeze.addGestureRecognizer(tap_breeze)
    }
    
    // MARK: - 公共方法
    
    /// 展示确认弹窗
    /// - Parameters:
    ///   - user_breeze: 目标用户
    ///   - onConfirm_breeze: 确认回调
    static func show_Breeze(user_breeze: PrewUserModel_Breeze, onConfirm_breeze: @escaping () -> Void) {
        guard let window_breeze = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        let sheet_breeze = UserConfirmSheet_Breeze(frame: window_breeze.bounds)
        sheet_breeze.onConfirm_Breeze = onConfirm_breeze
        sheet_breeze.configure_Breeze(user_breeze: user_breeze)
        window_breeze.addSubview(sheet_breeze)
        sheet_breeze.present_Breeze()
    }
    
    /// 配置用户信息
    private func configure_Breeze(user_breeze: PrewUserModel_Breeze) {
        nameLabel_Breeze.text = user_breeze.userName_Breeze ?? "Camper"
        introLabel_Breeze.text = user_breeze.userIntroduce_Breeze ?? "A fellow park camper"
        avatarView_Breeze.configure_Breeze(userId_Breeze: user_breeze.userId_Breeze ?? 0)
    }
    
    /// 弹出动画
    private func present_Breeze() {
        layoutIfNeeded()
        cardBottomConstraint_Breeze?.update(offset: 0)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            self.dimView_Breeze.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - 事件
    
    /// 确认
    @objc private func handleConfirm_Breeze() {
        let confirm_breeze = onConfirm_Breeze
        dismissSheetWithCompletion_Breeze(completion_breeze: {
            confirm_breeze?()
        })
    }
    
    /// 收起弹窗
    @objc private func dismissSheet_Breeze() {
        dismissSheetWithCompletion_Breeze(completion_breeze: nil)
    }
    
    /// 收起弹窗（带完成回调）
    private func dismissSheetWithCompletion_Breeze(completion_breeze: (() -> Void)?) {
        cardBottomConstraint_Breeze?.update(offset: 420)
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView_Breeze.alpha = 0
            self.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
            completion_breeze?()
        })
    }
}
