import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Glasspaint {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Glasspaint: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Glasspaint: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Glasspaint: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Glasspaint {
        static let postTitle_Glasspaint = "Delete Post"
        static let postMessage_Glasspaint = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Glasspaint = "Delete Comment"
        static let commentMessage_Glasspaint = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Glasspaint = "Delete"
        static let cancelButtonTitle_Glasspaint = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Glasspaint {
        case block_Glasspaint       // 拉黑用户
        case post_Glasspaint        // 举报帖子
        case comment_Glasspaint     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Glasspaint(
        user_Glasspaint: PrewUserModel_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        UIAlertController.report_Glasspaint(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Glasspaint(
                user_Glasspaint: user_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint
            )
            completion_Glasspaint?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Glasspaint(
        post_Glasspaint: TitleModel_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        UIAlertController.report_Glasspaint(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Glasspaint(
                post_Glasspaint: post_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint)
        })
    }
    
    /// 举报评论
    static func report_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        UIAlertController.report_Glasspaint(with: false, completeBlock: {
            performReportComment_Glasspaint(
                comment_Glasspaint: comment_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint)
        })
    }
    
    /// 举报时空胶囊
    static func report_Glasspaint(
        capsule_Glasspaint: TimeCapsulePost_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        UIAlertController.report_Glasspaint(with: false, completeBlock: {
            performReportTimeCapsule_Glasspaint(
                capsule_Glasspaint: capsule_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Glasspaint(
        post_Glasspaint: TitleModel_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Glasspaint(
            title_Glasspaint: DeleteAlertConfig_Glasspaint.postTitle_Glasspaint,
            message_Glasspaint: DeleteAlertConfig_Glasspaint.postMessage_Glasspaint,
            from: viewController_Glasspaint
        ) {
            performDeletePost_Glasspaint(
                post_Glasspaint: post_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }
    }
    
    /// 删除评论
    static func delete_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Glasspaint(
            title_Glasspaint: DeleteAlertConfig_Glasspaint.commentTitle_Glasspaint,
            message_Glasspaint: DeleteAlertConfig_Glasspaint.commentMessage_Glasspaint,
            from: viewController_Glasspaint
        ) {
            performDeleteComment_Glasspaint(
                comment_Glasspaint: comment_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Glasspaint(
        title_Glasspaint: String,
        message_Glasspaint: String,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: @escaping () -> Void
    ) {
        let alert_Glasspaint = UIAlertController(
            title: title_Glasspaint,
            message: message_Glasspaint,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Glasspaint = UIAlertAction(
            title: DeleteAlertConfig_Glasspaint.deleteButtonTitle_Glasspaint,
            style: .destructive
        ) { _ in
            completion_Glasspaint()
        }
        
        // 取消按钮
        let cancelAction_Glasspaint = UIAlertAction(
            title: DeleteAlertConfig_Glasspaint.cancelButtonTitle_Glasspaint,
            style: .cancel,
            handler: nil
        )
        
        alert_Glasspaint.addAction(deleteAction_Glasspaint)
        alert_Glasspaint.addAction(cancelAction_Glasspaint)
        
        viewController_Glasspaint.present(alert_Glasspaint, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Glasspaint(
        action_Glasspaint: @escaping @MainActor () -> Void,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Glasspaint * 1_000_000_000))
            
            await action_Glasspaint()
            
            // 确保在主线程上执行回调
            if let completion_Glasspaint = completion_Glasspaint {
                await MainActor.run {
                    completion_Glasspaint()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Glasspaint(
        user_Glasspaint: PrewUserModel_Glasspaint,
        viewController_Glasspaint: UIViewController
    ) {
        performAsyncAction_Glasspaint(action_Glasspaint: {
            UserViewModel_Glasspaint.shared_Glasspaint.reportUser_Glasspaint(user_glasspaint: user_Glasspaint)
            print("已拉黑用户: \(user_Glasspaint.userName_Glasspaint ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Glasspaint(
        post_Glasspaint: TitleModel_Glasspaint,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        performAsyncAction_Glasspaint(
            action_Glasspaint: {
                TitleViewModel_Glasspaint.shared_Glasspaint.deletePost_Glasspaint(post_glasspaint: post_Glasspaint)
                print("已举报帖子: \(post_Glasspaint.title_Glasspaint)")
            },
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        performAsyncAction_Glasspaint(
            action_Glasspaint: {
                TitleViewModel_Glasspaint.shared_Glasspaint.deleteComment_Glasspaint(
                    post_glasspaint: post_Glasspaint,
                    comment_glasspaint: comment_Glasspaint
                )
                print("已举报评论: \(comment_Glasspaint.commentContent_Glasspaint)")
            },
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    /// 执行举报时空胶囊操作
    private static func performReportTimeCapsule_Glasspaint(
        capsule_Glasspaint: TimeCapsulePost_Glasspaint,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        performAsyncAction_Glasspaint(
            action_Glasspaint: {
                UserViewModel_Glasspaint.shared_Glasspaint.reportTimeCapsule_Glasspaint(capsule_glasspaint: capsule_Glasspaint)
                print("已举报时空胶囊: \(capsule_Glasspaint.title_Glasspaint)")
            },
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Glasspaint(
        post_Glasspaint: TitleModel_Glasspaint,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        performAsyncAction_Glasspaint(
            action_Glasspaint: {
                TitleViewModel_Glasspaint.shared_Glasspaint.deletePost_Glasspaint(
                    post_glasspaint: post_Glasspaint,
                    isDelete_glasspaint: true
                )
                print("已删除帖子: \(post_Glasspaint.title_Glasspaint)")
            },
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) {
        performAsyncAction_Glasspaint(
            action_Glasspaint: {
                TitleViewModel_Glasspaint.shared_Glasspaint.deleteComment_Glasspaint(
                    post_glasspaint: post_Glasspaint,
                    comment_glasspaint: comment_Glasspaint,
                    isDelete_glasspaint: true
                )
                print("已删除评论: \(comment_Glasspaint.commentContent_Glasspaint)")
            },
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Glasspaint(
        post_Glasspaint: TitleModel_Glasspaint,
        size_Glasspaint: CGFloat = 25,
        color_Glasspaint: UIColor = .black,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) -> UIButton {
        let button_Glasspaint = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.isCurrentUser_Glasspaint(
            userId_glasspaint: post_Glasspaint.titleUserId_Glasspaint
        )
        
        // 配置按钮图标
        let iconName_Glasspaint = isMyPost_Glasspaint ? "trash" : "ellipsis"
        configureButtonIcon_Glasspaint(
            button_Glasspaint: button_Glasspaint,
            iconName_Glasspaint: iconName_Glasspaint,
            size_Glasspaint: size_Glasspaint,
            color_Glasspaint: color_Glasspaint
        )
        
        button_Glasspaint.addAction(UIAction { [weak viewController_Glasspaint] _ in
            guard let viewController_Glasspaint = viewController_Glasspaint else { return }
            handlePostButtonTap_Glasspaint(
                button_Glasspaint: button_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                isMyPost_Glasspaint: isMyPost_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }, for: .touchUpInside)
        
        return button_Glasspaint
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        size_Glasspaint: CGFloat = 25,
        color_Glasspaint: UIColor = .black,
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)? = nil
    ) -> UIButton {
        let button_Glasspaint = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.isCurrentUser_Glasspaint(
            userId_glasspaint: comment_Glasspaint.commentUserId_Glasspaint
        )
        
        // 配置按钮图标
        let iconName_Glasspaint = isMyComment_Glasspaint ? "trash" : "ellipsis"
        configureButtonIcon_Glasspaint(
            button_Glasspaint: button_Glasspaint,
            iconName_Glasspaint: iconName_Glasspaint,
            size_Glasspaint: size_Glasspaint,
            color_Glasspaint: color_Glasspaint
        )
        
        button_Glasspaint.addAction(UIAction { [weak viewController_Glasspaint] _ in
            guard let viewController_Glasspaint = viewController_Glasspaint else { return }
            handleCommentButtonTap_Glasspaint(
                button_Glasspaint: button_Glasspaint,
                comment_Glasspaint: comment_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                isMyComment_Glasspaint: isMyComment_Glasspaint,
                viewController_Glasspaint: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }, for: .touchUpInside)
        
        return button_Glasspaint
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Glasspaint(
        size_Glasspaint: CGFloat = 44,
        backgroundColor_Glasspaint: UIColor? = nil,
        tintColor_Glasspaint: UIColor = .white,
        withShadow_Glasspaint: Bool = false
    ) -> UIButton {
        let button_Glasspaint = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Glasspaint = size_Glasspaint * 0.5
        let config_Glasspaint = UIImage.SymbolConfiguration(pointSize: iconSize_Glasspaint, weight: .semibold)
        let image_Glasspaint = UIImage(systemName: "ellipsis", withConfiguration: config_Glasspaint)
        button_Glasspaint.setImage(image_Glasspaint, for: .normal)
        button_Glasspaint.tintColor = tintColor_Glasspaint
        
        // 设置背景
        let bgColor_Glasspaint = backgroundColor_Glasspaint ?? UIColor.white.withAlphaComponent(0.2)
        button_Glasspaint.backgroundColor = bgColor_Glasspaint
        button_Glasspaint.layer.cornerRadius = size_Glasspaint / 2
        
        // 添加阴影
        if withShadow_Glasspaint {
            button_Glasspaint.layer.shadowColor = UIColor.black.cgColor
            button_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Glasspaint.layer.shadowOpacity = 0.15
            button_Glasspaint.layer.shadowRadius = 8
        }
        
        return button_Glasspaint
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Glasspaint(button_Glasspaint: UIButton) {
        UIView.animate(withDuration: animationDuration_Glasspaint, animations: {
            button_Glasspaint.transform = CGAffineTransform(
                scaleX: animationScale_Glasspaint,
                y: animationScale_Glasspaint
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Glasspaint) {
                button_Glasspaint.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Glasspaint(
        button_Glasspaint: UIButton,
        iconName_Glasspaint: String,
        size_Glasspaint: CGFloat,
        color_Glasspaint: UIColor
    ) {
        let config_Glasspaint = UIImage.SymbolConfiguration(pointSize: size_Glasspaint, weight: .semibold)
        let image_Glasspaint = UIImage(systemName: iconName_Glasspaint, withConfiguration: config_Glasspaint)
        button_Glasspaint.setImage(image_Glasspaint, for: .normal)
        button_Glasspaint.tintColor = color_Glasspaint
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Glasspaint(
        button_Glasspaint: UIButton,
        post_Glasspaint: TitleModel_Glasspaint,
        isMyPost_Glasspaint: Bool,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)?
    ) {
        addButtonAnimation_Glasspaint(button_Glasspaint: button_Glasspaint)
        
        if isMyPost_Glasspaint {
            delete_Glasspaint(
                post_Glasspaint: post_Glasspaint,
                from: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        } else {
            report_Glasspaint(
                post_Glasspaint: post_Glasspaint,
                from: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Glasspaint(
        button_Glasspaint: UIButton,
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint,
        isMyComment_Glasspaint: Bool,
        viewController_Glasspaint: UIViewController,
        completion_Glasspaint: (() -> Void)?
    ) {
        addButtonAnimation_Glasspaint(button_Glasspaint: button_Glasspaint)
        
        if isMyComment_Glasspaint {
            delete_Glasspaint(
                comment_Glasspaint: comment_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                from: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        } else {
            report_Glasspaint(
                comment_Glasspaint: comment_Glasspaint,
                post_Glasspaint: post_Glasspaint,
                from: viewController_Glasspaint,
                completion_Glasspaint: completion_Glasspaint
            )
        }
    }
}
