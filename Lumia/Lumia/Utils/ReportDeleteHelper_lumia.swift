import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Lumia {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Lumia: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Lumia: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Lumia: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Lumia {
        static let postTitle_Lumia = "Delete Post"
        static let postMessage_Lumia = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Lumia = "Delete Comment"
        static let commentMessage_Lumia = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Lumia = "Delete"
        static let cancelButtonTitle_Lumia = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Lumia {
        case block_Lumia       // 拉黑用户
        case post_Lumia        // 举报帖子
        case comment_Lumia     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Lumia(
        user_Lumia: PrewUserModel_Lumia,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lumia(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Lumia(
                user_Lumia: user_Lumia,
                viewController_Lumia: viewController_Lumia
            )
            completion_Lumia?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Lumia(
        post_Lumia: TitleModel_Lumia,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lumia(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Lumia(
                post_Lumia: post_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia)
        })
    }
    
    /// 举报评论
    static func report_Lumia(
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lumia(with: false, completeBlock: {
            performReportComment_Lumia(
                comment_Lumia: comment_Lumia,
                post_Lumia: post_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Lumia(
        post_Lumia: TitleModel_Lumia,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Lumia(
            title_Lumia: DeleteAlertConfig_Lumia.postTitle_Lumia,
            message_Lumia: DeleteAlertConfig_Lumia.postMessage_Lumia,
            from: viewController_Lumia
        ) {
            performDeletePost_Lumia(
                post_Lumia: post_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }
    }
    
    /// 删除评论
    static func delete_Lumia(
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Lumia(
            title_Lumia: DeleteAlertConfig_Lumia.commentTitle_Lumia,
            message_Lumia: DeleteAlertConfig_Lumia.commentMessage_Lumia,
            from: viewController_Lumia
        ) {
            performDeleteComment_Lumia(
                comment_Lumia: comment_Lumia,
                post_Lumia: post_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Lumia(
        title_Lumia: String,
        message_Lumia: String,
        from viewController_Lumia: UIViewController,
        completion_Lumia: @escaping () -> Void
    ) {
        let alert_Lumia = UIAlertController(
            title: title_Lumia,
            message: message_Lumia,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Lumia = UIAlertAction(
            title: DeleteAlertConfig_Lumia.deleteButtonTitle_Lumia,
            style: .destructive
        ) { _ in
            completion_Lumia()
        }
        
        // 取消按钮
        let cancelAction_Lumia = UIAlertAction(
            title: DeleteAlertConfig_Lumia.cancelButtonTitle_Lumia,
            style: .cancel,
            handler: nil
        )
        
        alert_Lumia.addAction(deleteAction_Lumia)
        alert_Lumia.addAction(cancelAction_Lumia)
        
        viewController_Lumia.present(alert_Lumia, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Lumia(
        action_Lumia: @escaping @MainActor () -> Void,
        completion_Lumia: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Lumia * 1_000_000_000))
            
            await action_Lumia()
            
            // 确保在主线程上执行回调
            if let completion_Lumia = completion_Lumia {
                await MainActor.run {
                    completion_Lumia()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Lumia(
        user_Lumia: PrewUserModel_Lumia,
        viewController_Lumia: UIViewController
    ) {
        performAsyncAction_Lumia(action_Lumia: {
            UserViewModel_Lumia.shared_Lumia.reportUser_Lumia(user_lumia: user_Lumia)
            print("已拉黑用户: \(user_Lumia.userName_Lumia ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Lumia(
        post_Lumia: TitleModel_Lumia,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        performAsyncAction_Lumia(
            action_Lumia: {
                TitleViewModel_Lumia.shared_Lumia.deletePost_Lumia(post_lumia: post_Lumia)
                print("已举报帖子: \(post_Lumia.title_Lumia)")
            },
            completion_Lumia: completion_Lumia
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Lumia(
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        performAsyncAction_Lumia(
            action_Lumia: {
                TitleViewModel_Lumia.shared_Lumia.deleteComment_Lumia(
                    post_lumia: post_Lumia,
                    comment_lumia: comment_Lumia
                )
                print("已举报评论: \(comment_Lumia.commentContent_Lumia)")
            },
            completion_Lumia: completion_Lumia
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Lumia(
        post_Lumia: TitleModel_Lumia,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        performAsyncAction_Lumia(
            action_Lumia: {
                TitleViewModel_Lumia.shared_Lumia.deletePost_Lumia(
                    post_lumia: post_Lumia,
                    isDelete_lumia: true
                )
                print("已删除帖子: \(post_Lumia.title_Lumia)")
            },
            completion_Lumia: completion_Lumia
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Lumia(
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) {
        performAsyncAction_Lumia(
            action_Lumia: {
                TitleViewModel_Lumia.shared_Lumia.deleteComment_Lumia(
                    post_lumia: post_Lumia,
                    comment_lumia: comment_Lumia,
                    isDelete_lumia: true
                )
                print("已删除评论: \(comment_Lumia.commentContent_Lumia)")
            },
            completion_Lumia: completion_Lumia
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Lumia(
        post_Lumia: TitleModel_Lumia,
        size_Lumia: CGFloat = 25,
        color_Lumia: UIColor = .black,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) -> UIButton {
        let button_Lumia = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(
            userId_lumia: post_Lumia.titleUserId_Lumia
        )
        
        // 配置按钮图标
        let iconName_Lumia = isMyPost_Lumia ? "trash" : "ellipsis"
        configureButtonIcon_Lumia(
            button_Lumia: button_Lumia,
            iconName_Lumia: iconName_Lumia,
            size_Lumia: size_Lumia,
            color_Lumia: color_Lumia
        )
        
        button_Lumia.addAction(UIAction { [weak viewController_Lumia] _ in
            guard let viewController_Lumia = viewController_Lumia else { return }
            handlePostButtonTap_Lumia(
                button_Lumia: button_Lumia,
                post_Lumia: post_Lumia,
                isMyPost_Lumia: isMyPost_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }, for: .touchUpInside)
        
        return button_Lumia
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Lumia(
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        size_Lumia: CGFloat = 25,
        color_Lumia: UIColor = .black,
        from viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)? = nil
    ) -> UIButton {
        let button_Lumia = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(
            userId_lumia: comment_Lumia.commentUserId_Lumia
        )
        
        // 配置按钮图标
        let iconName_Lumia = isMyComment_Lumia ? "trash" : "ellipsis"
        configureButtonIcon_Lumia(
            button_Lumia: button_Lumia,
            iconName_Lumia: iconName_Lumia,
            size_Lumia: size_Lumia,
            color_Lumia: color_Lumia
        )
        
        button_Lumia.addAction(UIAction { [weak viewController_Lumia] _ in
            guard let viewController_Lumia = viewController_Lumia else { return }
            handleCommentButtonTap_Lumia(
                button_Lumia: button_Lumia,
                comment_Lumia: comment_Lumia,
                post_Lumia: post_Lumia,
                isMyComment_Lumia: isMyComment_Lumia,
                viewController_Lumia: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }, for: .touchUpInside)
        
        return button_Lumia
    }
    
    /// 创建主题讨论区评论举报/删除按钮
    /// 根据评论归属自动选择「trash」删除图标（自己）或「ellipsis」举报图标（他人）
    /// - Parameters:
    ///   - comment_Lumia: 讨论区评论对象
    ///   - size_Lumia: SF Symbol 点大小，默认 12
    ///   - color_Lumia: 他人评论按钮的图标颜色，默认淡紫色
    ///   - viewController_Lumia: 发起弹窗的视图控制器
    ///   - onDelete_Lumia: 用户确认删除后执行的回调（负责从数据层移除评论）
    ///   - onBlock_Lumia: 用户确认拉黑后执行的回调（负责同步移除评论）
    /// - Returns: 配置完毕的 UIButton
    @MainActor static func createDiscussionCommentButton_Lumia(
        comment_Lumia: ThemeDiscussionComment_Lumia,
        size_Lumia: CGFloat = 12,
        color_Lumia: UIColor = UIColor(hexstring_Lumia: "#C0A8D8"),
        from viewController_Lumia: UIViewController,
        onDelete_Lumia: (() -> Void)? = nil,
        onBlock_Lumia: (() -> Void)? = nil
    ) -> UIButton {
        let button_Lumia = UIButton(type: .system)

        // 判断是否是自己的评论
        let isMyComment_Lumia = UserViewModel_Lumia.shared_Lumia.isCurrentUser_Lumia(
            userId_lumia: comment_Lumia.userId_Lumia
        )

        // 与 createCommentReportButton_Lumia 保持一致：自己→trash，他人→ellipsis
        let iconName_Lumia = isMyComment_Lumia ? "trash" : "ellipsis"
        let tintColor_Lumia: UIColor = isMyComment_Lumia
            ? UIColor(hexstring_Lumia: "#E53E3E", alpha_Lumia: 0.75)
            : color_Lumia
        configureButtonIcon_Lumia(
            button_Lumia: button_Lumia,
            iconName_Lumia: iconName_Lumia,
            size_Lumia: size_Lumia,
            color_Lumia: tintColor_Lumia
        )

        button_Lumia.addAction(UIAction { [weak viewController_Lumia] _ in
            guard let vc_Lumia = viewController_Lumia else { return }
            addButtonAnimation_Lumia(button_Lumia: button_Lumia)

            if isMyComment_Lumia {
                // 自己的评论：展示删除确认弹窗
                showDeleteConfirmAlert_Lumia(
                    title_Lumia: DeleteAlertConfig_Lumia.commentTitle_Lumia,
                    message_Lumia: DeleteAlertConfig_Lumia.commentMessage_Lumia,
                    from: vc_Lumia,
                    completion_Lumia: { onDelete_Lumia?() }
                )
            } else {
                // 他人的评论：拉黑用户
                let reportUser_Lumia = PrewUserModel_Lumia()
                reportUser_Lumia.userId_Lumia = comment_Lumia.userId_Lumia
                reportUser_Lumia.userName_Lumia = comment_Lumia.userName_Lumia
                reportUser_Lumia.userHead_Lumia = comment_Lumia.userHead_Lumia
                block_Lumia(
                    user_Lumia: reportUser_Lumia,
                    from: vc_Lumia,
                    completion_Lumia: { onBlock_Lumia?() }
                )
            }
        }, for: .touchUpInside)

        return button_Lumia
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Lumia(
        size_Lumia: CGFloat = 44,
        backgroundColor_Lumia: UIColor? = nil,
        tintColor_Lumia: UIColor = .white,
        withShadow_Lumia: Bool = false
    ) -> UIButton {
        let button_Lumia = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Lumia = size_Lumia * 0.5
        let config_Lumia = UIImage.SymbolConfiguration(pointSize: iconSize_Lumia, weight: .semibold)
        let image_Lumia = UIImage(systemName: "ellipsis", withConfiguration: config_Lumia)
        button_Lumia.setImage(image_Lumia, for: .normal)
        button_Lumia.tintColor = tintColor_Lumia
        
        // 设置背景
        let bgColor_Lumia = backgroundColor_Lumia ?? UIColor.white.withAlphaComponent(0.2)
        button_Lumia.backgroundColor = bgColor_Lumia
        button_Lumia.layer.cornerRadius = size_Lumia / 2
        
        // 添加阴影
        if withShadow_Lumia {
            button_Lumia.layer.shadowColor = UIColor.black.cgColor
            button_Lumia.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Lumia.layer.shadowOpacity = 0.15
            button_Lumia.layer.shadowRadius = 8
        }
        
        return button_Lumia
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Lumia(button_Lumia: UIButton) {
        UIView.animate(withDuration: animationDuration_Lumia, animations: {
            button_Lumia.transform = CGAffineTransform(
                scaleX: animationScale_Lumia,
                y: animationScale_Lumia
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Lumia) {
                button_Lumia.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Lumia(
        button_Lumia: UIButton,
        iconName_Lumia: String,
        size_Lumia: CGFloat,
        color_Lumia: UIColor
    ) {
        let config_Lumia = UIImage.SymbolConfiguration(pointSize: size_Lumia, weight: .semibold)
        let image_Lumia = UIImage(systemName: iconName_Lumia, withConfiguration: config_Lumia)
        button_Lumia.setImage(image_Lumia, for: .normal)
        button_Lumia.tintColor = color_Lumia
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Lumia(
        button_Lumia: UIButton,
        post_Lumia: TitleModel_Lumia,
        isMyPost_Lumia: Bool,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)?
    ) {
        addButtonAnimation_Lumia(button_Lumia: button_Lumia)
        
        if isMyPost_Lumia {
            delete_Lumia(
                post_Lumia: post_Lumia,
                from: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        } else {
            report_Lumia(
                post_Lumia: post_Lumia,
                from: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Lumia(
        button_Lumia: UIButton,
        comment_Lumia: Comment_Lumia,
        post_Lumia: TitleModel_Lumia,
        isMyComment_Lumia: Bool,
        viewController_Lumia: UIViewController,
        completion_Lumia: (() -> Void)?
    ) {
        addButtonAnimation_Lumia(button_Lumia: button_Lumia)
        
        if isMyComment_Lumia {
            delete_Lumia(
                comment_Lumia: comment_Lumia,
                post_Lumia: post_Lumia,
                from: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        } else {
            report_Lumia(
                comment_Lumia: comment_Lumia,
                post_Lumia: post_Lumia,
                from: viewController_Lumia,
                completion_Lumia: completion_Lumia
            )
        }
    }
}
