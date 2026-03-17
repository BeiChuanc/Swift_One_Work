import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Pane {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Pane: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Pane: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Pane: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Pane {
        static let postTitle_Pane = "Delete Post"
        static let postMessage_Pane = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Pane = "Delete Comment"
        static let commentMessage_Pane = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Pane = "Delete"
        static let cancelButtonTitle_Pane = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Pane {
        case block_Pane       // 拉黑用户
        case post_Pane        // 举报帖子
        case comment_Pane     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Pane(
        user_Pane: PrewUserModel_Pane,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        UIAlertController.report_Pane(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Pane(
                user_Pane: user_Pane,
                viewController_Pane: viewController_Pane
            )
            completion_Pane?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Pane(
        post_Pane: TitleModel_Pane,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        UIAlertController.report_Pane(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Pane(
                post_Pane: post_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane)
        })
    }
    
    /// 举报评论
    static func report_Pane(
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        UIAlertController.report_Pane(with: false, completeBlock: {
            performReportComment_Pane(
                comment_Pane: comment_Pane,
                post_Pane: post_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Pane(
        post_Pane: TitleModel_Pane,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Pane(
            title_Pane: DeleteAlertConfig_Pane.postTitle_Pane,
            message_Pane: DeleteAlertConfig_Pane.postMessage_Pane,
            from: viewController_Pane
        ) {
            performDeletePost_Pane(
                post_Pane: post_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }
    }
    
    /// 删除评论
    static func delete_Pane(
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Pane(
            title_Pane: DeleteAlertConfig_Pane.commentTitle_Pane,
            message_Pane: DeleteAlertConfig_Pane.commentMessage_Pane,
            from: viewController_Pane
        ) {
            performDeleteComment_Pane(
                comment_Pane: comment_Pane,
                post_Pane: post_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Pane(
        title_Pane: String,
        message_Pane: String,
        from viewController_Pane: UIViewController,
        completion_Pane: @escaping () -> Void
    ) {
        let alert_Pane = UIAlertController(
            title: title_Pane,
            message: message_Pane,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Pane = UIAlertAction(
            title: DeleteAlertConfig_Pane.deleteButtonTitle_Pane,
            style: .destructive
        ) { _ in
            completion_Pane()
        }
        
        // 取消按钮
        let cancelAction_Pane = UIAlertAction(
            title: DeleteAlertConfig_Pane.cancelButtonTitle_Pane,
            style: .cancel,
            handler: nil
        )
        
        alert_Pane.addAction(deleteAction_Pane)
        alert_Pane.addAction(cancelAction_Pane)
        
        viewController_Pane.present(alert_Pane, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Pane(
        action_Pane: @escaping @MainActor () -> Void,
        completion_Pane: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Pane * 1_000_000_000))
            
            await action_Pane()
            
            // 确保在主线程上执行回调
            if let completion_Pane = completion_Pane {
                await MainActor.run {
                    completion_Pane()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Pane(
        user_Pane: PrewUserModel_Pane,
        viewController_Pane: UIViewController
    ) {
        performAsyncAction_Pane(action_Pane: {
            UserViewModel_Pane.shared_Pane.reportUser_Pane(user_pane: user_Pane)
            print("已拉黑用户: \(user_Pane.userName_Pane ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Pane(
        post_Pane: TitleModel_Pane,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        performAsyncAction_Pane(
            action_Pane: {
                TitleViewModel_Pane.shared_Pane.deletePost_Pane(post_pane: post_Pane)
                print("已举报帖子: \(post_Pane.title_Pane)")
            },
            completion_Pane: completion_Pane
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Pane(
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        performAsyncAction_Pane(
            action_Pane: {
                TitleViewModel_Pane.shared_Pane.deleteComment_Pane(
                    post_pane: post_Pane,
                    comment_pane: comment_Pane
                )
                print("已举报评论: \(comment_Pane.commentContent_Pane)")
            },
            completion_Pane: completion_Pane
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Pane(
        post_Pane: TitleModel_Pane,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        performAsyncAction_Pane(
            action_Pane: {
                TitleViewModel_Pane.shared_Pane.deletePost_Pane(
                    post_pane: post_Pane,
                    isDelete_pane: true
                )
                print("已删除帖子: \(post_Pane.title_Pane)")
            },
            completion_Pane: completion_Pane
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Pane(
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) {
        performAsyncAction_Pane(
            action_Pane: {
                TitleViewModel_Pane.shared_Pane.deleteComment_Pane(
                    post_pane: post_Pane,
                    comment_pane: comment_Pane,
                    isDelete_pane: true
                )
                print("已删除评论: \(comment_Pane.commentContent_Pane)")
            },
            completion_Pane: completion_Pane
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Pane(
        post_Pane: TitleModel_Pane,
        size_Pane: CGFloat = 25,
        color_Pane: UIColor = .black,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) -> UIButton {
        let button_Pane = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
            userId_pane: post_Pane.titleUserId_Pane
        )
        
        // 配置按钮图标
        let iconName_Pane = isMyPost_Pane ? "trash" : "ellipsis"
        configureButtonIcon_Pane(
            button_Pane: button_Pane,
            iconName_Pane: iconName_Pane,
            size_Pane: size_Pane,
            color_Pane: color_Pane
        )
        
        button_Pane.addAction(UIAction { [weak viewController_Pane] _ in
            guard let viewController_Pane = viewController_Pane else { return }
            handlePostButtonTap_Pane(
                button_Pane: button_Pane,
                post_Pane: post_Pane,
                isMyPost_Pane: isMyPost_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }, for: .touchUpInside)
        
        return button_Pane
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Pane(
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        size_Pane: CGFloat = 25,
        color_Pane: UIColor = .black,
        from viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)? = nil
    ) -> UIButton {
        let button_Pane = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Pane = UserViewModel_Pane.shared_Pane.isCurrentUser_Pane(
            userId_pane: comment_Pane.commentUserId_Pane
        )
        
        // 配置按钮图标
        let iconName_Pane = isMyComment_Pane ? "trash" : "ellipsis"
        configureButtonIcon_Pane(
            button_Pane: button_Pane,
            iconName_Pane: iconName_Pane,
            size_Pane: size_Pane,
            color_Pane: color_Pane
        )
        
        button_Pane.addAction(UIAction { [weak viewController_Pane] _ in
            guard let viewController_Pane = viewController_Pane else { return }
            handleCommentButtonTap_Pane(
                button_Pane: button_Pane,
                comment_Pane: comment_Pane,
                post_Pane: post_Pane,
                isMyComment_Pane: isMyComment_Pane,
                viewController_Pane: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }, for: .touchUpInside)
        
        return button_Pane
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Pane(
        size_Pane: CGFloat = 44,
        backgroundColor_Pane: UIColor? = nil,
        tintColor_Pane: UIColor = .white,
        withShadow_Pane: Bool = false
    ) -> UIButton {
        let button_Pane = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Pane = size_Pane * 0.5
        let config_Pane = UIImage.SymbolConfiguration(pointSize: iconSize_Pane, weight: .semibold)
        let image_Pane = UIImage(systemName: "ellipsis", withConfiguration: config_Pane)
        button_Pane.setImage(image_Pane, for: .normal)
        button_Pane.tintColor = tintColor_Pane
        
        // 设置背景
        let bgColor_Pane = backgroundColor_Pane ?? UIColor.white.withAlphaComponent(0.2)
        button_Pane.backgroundColor = bgColor_Pane
        button_Pane.layer.cornerRadius = size_Pane / 2
        
        // 添加阴影
        if withShadow_Pane {
            button_Pane.layer.shadowColor = UIColor.black.cgColor
            button_Pane.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Pane.layer.shadowOpacity = 0.15
            button_Pane.layer.shadowRadius = 8
        }
        
        return button_Pane
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Pane(button_Pane: UIButton) {
        UIView.animate(withDuration: animationDuration_Pane, animations: {
            button_Pane.transform = CGAffineTransform(
                scaleX: animationScale_Pane,
                y: animationScale_Pane
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Pane) {
                button_Pane.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Pane(
        button_Pane: UIButton,
        iconName_Pane: String,
        size_Pane: CGFloat,
        color_Pane: UIColor
    ) {
        let config_Pane = UIImage.SymbolConfiguration(pointSize: size_Pane, weight: .semibold)
        let image_Pane = UIImage(systemName: iconName_Pane, withConfiguration: config_Pane)
        button_Pane.setImage(image_Pane, for: .normal)
        button_Pane.tintColor = color_Pane
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Pane(
        button_Pane: UIButton,
        post_Pane: TitleModel_Pane,
        isMyPost_Pane: Bool,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)?
    ) {
        addButtonAnimation_Pane(button_Pane: button_Pane)
        
        if isMyPost_Pane {
            delete_Pane(
                post_Pane: post_Pane,
                from: viewController_Pane,
                completion_Pane: completion_Pane
            )
        } else {
            report_Pane(
                post_Pane: post_Pane,
                from: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Pane(
        button_Pane: UIButton,
        comment_Pane: Comment_Pane,
        post_Pane: TitleModel_Pane,
        isMyComment_Pane: Bool,
        viewController_Pane: UIViewController,
        completion_Pane: (() -> Void)?
    ) {
        addButtonAnimation_Pane(button_Pane: button_Pane)
        
        if isMyComment_Pane {
            delete_Pane(
                comment_Pane: comment_Pane,
                post_Pane: post_Pane,
                from: viewController_Pane,
                completion_Pane: completion_Pane
            )
        } else {
            report_Pane(
                comment_Pane: comment_Pane,
                post_Pane: post_Pane,
                from: viewController_Pane,
                completion_Pane: completion_Pane
            )
        }
    }
}
