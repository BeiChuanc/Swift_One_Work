import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Trace {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Trace: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Trace: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Trace: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Trace {
        static let postTitle_Trace = "Delete Post"
        static let postMessage_Trace = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Trace = "Delete Comment"
        static let commentMessage_Trace = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Trace = "Delete"
        static let cancelButtonTitle_Trace = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Trace {
        case block_Trace       // 拉黑用户
        case post_Trace        // 举报帖子
        case comment_Trace     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Trace(
        user_Trace: PrewUserModel_Trace,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        UIAlertController.report_Trace(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Trace(
                user_Trace: user_Trace,
                viewController_Trace: viewController_Trace
            )
            completion_Trace?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Trace(
        post_Trace: TitleModel_Trace,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        UIAlertController.report_Trace(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Trace(
                post_Trace: post_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace)
        })
    }
    
    /// 举报评论
    static func report_Trace(
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        UIAlertController.report_Trace(with: false, completeBlock: {
            performReportComment_Trace(
                comment_Trace: comment_Trace,
                post_Trace: post_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Trace(
        post_Trace: TitleModel_Trace,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Trace(
            title_Trace: DeleteAlertConfig_Trace.postTitle_Trace,
            message_Trace: DeleteAlertConfig_Trace.postMessage_Trace,
            from: viewController_Trace
        ) {
            performDeletePost_Trace(
                post_Trace: post_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }
    }
    
    /// 删除评论
    static func delete_Trace(
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Trace(
            title_Trace: DeleteAlertConfig_Trace.commentTitle_Trace,
            message_Trace: DeleteAlertConfig_Trace.commentMessage_Trace,
            from: viewController_Trace
        ) {
            performDeleteComment_Trace(
                comment_Trace: comment_Trace,
                post_Trace: post_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Trace(
        title_Trace: String,
        message_Trace: String,
        from viewController_Trace: UIViewController,
        completion_Trace: @escaping () -> Void
    ) {
        let alert_Trace = UIAlertController(
            title: title_Trace,
            message: message_Trace,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Trace = UIAlertAction(
            title: DeleteAlertConfig_Trace.deleteButtonTitle_Trace,
            style: .destructive
        ) { _ in
            completion_Trace()
        }
        
        // 取消按钮
        let cancelAction_Trace = UIAlertAction(
            title: DeleteAlertConfig_Trace.cancelButtonTitle_Trace,
            style: .cancel,
            handler: nil
        )
        
        alert_Trace.addAction(deleteAction_Trace)
        alert_Trace.addAction(cancelAction_Trace)
        
        viewController_Trace.present(alert_Trace, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Trace(
        action_Trace: @escaping @MainActor () -> Void,
        completion_Trace: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Trace * 1_000_000_000))
            
            await action_Trace()
            
            // 确保在主线程上执行回调
            if let completion_Trace = completion_Trace {
                await MainActor.run {
                    completion_Trace()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Trace(
        user_Trace: PrewUserModel_Trace,
        viewController_Trace: UIViewController
    ) {
        performAsyncAction_Trace(action_Trace: {
            UserViewModel_Trace.shared_Trace.reportUser_Trace(user_trace: user_Trace)
            print("已拉黑用户: \(user_Trace.userName_Trace ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Trace(
        post_Trace: TitleModel_Trace,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        performAsyncAction_Trace(
            action_Trace: {
                TitleViewModel_Trace.shared_Trace.deletePost_Trace(post_trace: post_Trace)
                print("已举报帖子: \(post_Trace.title_Trace)")
            },
            completion_Trace: completion_Trace
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Trace(
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        performAsyncAction_Trace(
            action_Trace: {
                TitleViewModel_Trace.shared_Trace.deleteComment_Trace(
                    post_trace: post_Trace,
                    comment_trace: comment_Trace
                )
                print("已举报评论: \(comment_Trace.commentContent_Trace)")
            },
            completion_Trace: completion_Trace
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Trace(
        post_Trace: TitleModel_Trace,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        performAsyncAction_Trace(
            action_Trace: {
                TitleViewModel_Trace.shared_Trace.deletePost_Trace(
                    post_trace: post_Trace,
                    isDelete_trace: true
                )
                print("已删除帖子: \(post_Trace.title_Trace)")
            },
            completion_Trace: completion_Trace
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Trace(
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) {
        performAsyncAction_Trace(
            action_Trace: {
                TitleViewModel_Trace.shared_Trace.deleteComment_Trace(
                    post_trace: post_Trace,
                    comment_trace: comment_Trace,
                    isDelete_trace: true
                )
                print("已删除评论: \(comment_Trace.commentContent_Trace)")
            },
            completion_Trace: completion_Trace
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Trace(
        post_Trace: TitleModel_Trace,
        size_Trace: CGFloat = 25,
        color_Trace: UIColor = .black,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) -> UIButton {
        let button_Trace = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(
            userId_trace: post_Trace.titleUserId_Trace
        )
        
        // 配置按钮图标
        let iconName_Trace = isMyPost_Trace ? "trash" : "ellipsis"
        configureButtonIcon_Trace(
            button_Trace: button_Trace,
            iconName_Trace: iconName_Trace,
            size_Trace: size_Trace,
            color_Trace: color_Trace
        )
        
        button_Trace.addAction(UIAction { [weak viewController_Trace] _ in
            guard let viewController_Trace = viewController_Trace else { return }
            handlePostButtonTap_Trace(
                button_Trace: button_Trace,
                post_Trace: post_Trace,
                isMyPost_Trace: isMyPost_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }, for: .touchUpInside)
        
        return button_Trace
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Trace(
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        size_Trace: CGFloat = 25,
        color_Trace: UIColor = .black,
        from viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)? = nil
    ) -> UIButton {
        let button_Trace = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Trace = UserViewModel_Trace.shared_Trace.isCurrentUser_Trace(
            userId_trace: comment_Trace.commentUserId_Trace
        )
        
        // 配置按钮图标
        let iconName_Trace = isMyComment_Trace ? "trash" : "ellipsis"
        configureButtonIcon_Trace(
            button_Trace: button_Trace,
            iconName_Trace: iconName_Trace,
            size_Trace: size_Trace,
            color_Trace: color_Trace
        )
        
        button_Trace.addAction(UIAction { [weak viewController_Trace] _ in
            guard let viewController_Trace = viewController_Trace else { return }
            handleCommentButtonTap_Trace(
                button_Trace: button_Trace,
                comment_Trace: comment_Trace,
                post_Trace: post_Trace,
                isMyComment_Trace: isMyComment_Trace,
                viewController_Trace: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }, for: .touchUpInside)
        
        return button_Trace
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Trace(
        size_Trace: CGFloat = 44,
        backgroundColor_Trace: UIColor? = nil,
        tintColor_Trace: UIColor = .white,
        withShadow_Trace: Bool = false
    ) -> UIButton {
        let button_Trace = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Trace = size_Trace * 0.5
        let config_Trace = UIImage.SymbolConfiguration(pointSize: iconSize_Trace, weight: .semibold)
        let image_Trace = UIImage(systemName: "ellipsis", withConfiguration: config_Trace)
        button_Trace.setImage(image_Trace, for: .normal)
        button_Trace.tintColor = tintColor_Trace
        
        // 设置背景
        let bgColor_Trace = backgroundColor_Trace ?? UIColor.white.withAlphaComponent(0.2)
        button_Trace.backgroundColor = bgColor_Trace
        button_Trace.layer.cornerRadius = size_Trace / 2
        
        // 添加阴影
        if withShadow_Trace {
            button_Trace.layer.shadowColor = UIColor.black.cgColor
            button_Trace.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Trace.layer.shadowOpacity = 0.15
            button_Trace.layer.shadowRadius = 8
        }
        
        return button_Trace
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画（供外部调用）
    static func addButtonAnimation_Trace(button_Trace: UIButton) {
        UIView.animate(withDuration: animationDuration_Trace, animations: {
            button_Trace.transform = CGAffineTransform(
                scaleX: animationScale_Trace,
                y: animationScale_Trace
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Trace) {
                button_Trace.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Trace(
        button_Trace: UIButton,
        iconName_Trace: String,
        size_Trace: CGFloat,
        color_Trace: UIColor
    ) {
        let config_Trace = UIImage.SymbolConfiguration(pointSize: size_Trace, weight: .semibold)
        let image_Trace = UIImage(systemName: iconName_Trace, withConfiguration: config_Trace)
        button_Trace.setImage(image_Trace, for: .normal)
        button_Trace.tintColor = color_Trace
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Trace(
        button_Trace: UIButton,
        post_Trace: TitleModel_Trace,
        isMyPost_Trace: Bool,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)?
    ) {
        addButtonAnimation_Trace(button_Trace: button_Trace)
        
        if isMyPost_Trace {
            delete_Trace(
                post_Trace: post_Trace,
                from: viewController_Trace,
                completion_Trace: completion_Trace
            )
        } else {
            report_Trace(
                post_Trace: post_Trace,
                from: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Trace(
        button_Trace: UIButton,
        comment_Trace: Comment_Trace,
        post_Trace: TitleModel_Trace,
        isMyComment_Trace: Bool,
        viewController_Trace: UIViewController,
        completion_Trace: (() -> Void)?
    ) {
        addButtonAnimation_Trace(button_Trace: button_Trace)
        
        if isMyComment_Trace {
            delete_Trace(
                comment_Trace: comment_Trace,
                post_Trace: post_Trace,
                from: viewController_Trace,
                completion_Trace: completion_Trace
            )
        } else {
            report_Trace(
                comment_Trace: comment_Trace,
                post_Trace: post_Trace,
                from: viewController_Trace,
                completion_Trace: completion_Trace
            )
        }
    }
}
