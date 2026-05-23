import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Hush {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Hush: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Hush: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Hush: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Hush {
        static let postTitle_Hush = "Delete Post"
        static let postMessage_Hush = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Hush = "Delete Comment"
        static let commentMessage_Hush = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Hush = "Delete"
        static let cancelButtonTitle_Hush = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Hush {
        case block_Hush       // 拉黑用户
        case post_Hush        // 举报帖子
        case comment_Hush     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Hush(
        user_Hush: PrewUserModel_Hush,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        UIAlertController.report_Hush(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Hush(
                user_Hush: user_Hush,
                viewController_Hush: viewController_Hush
            )
            completion_Hush?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Hush(
        post_Hush: TitleModel_Hush,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        UIAlertController.report_Hush(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Hush(
                post_Hush: post_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush)
        })
    }
    
    /// 举报评论
    static func report_Hush(
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        UIAlertController.report_Hush(with: false, completeBlock: {
            performReportComment_Hush(
                comment_Hush: comment_Hush,
                post_Hush: post_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Hush(
        post_Hush: TitleModel_Hush,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Hush(
            title_Hush: DeleteAlertConfig_Hush.postTitle_Hush,
            message_Hush: DeleteAlertConfig_Hush.postMessage_Hush,
            from: viewController_Hush
        ) {
            performDeletePost_Hush(
                post_Hush: post_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }
    }
    
    /// 删除评论
    static func delete_Hush(
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Hush(
            title_Hush: DeleteAlertConfig_Hush.commentTitle_Hush,
            message_Hush: DeleteAlertConfig_Hush.commentMessage_Hush,
            from: viewController_Hush
        ) {
            performDeleteComment_Hush(
                comment_Hush: comment_Hush,
                post_Hush: post_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Hush(
        title_Hush: String,
        message_Hush: String,
        from viewController_Hush: UIViewController,
        completion_Hush: @escaping () -> Void
    ) {
        let alert_Hush = UIAlertController(
            title: title_Hush,
            message: message_Hush,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Hush = UIAlertAction(
            title: DeleteAlertConfig_Hush.deleteButtonTitle_Hush,
            style: .destructive
        ) { _ in
            completion_Hush()
        }
        
        // 取消按钮
        let cancelAction_Hush = UIAlertAction(
            title: DeleteAlertConfig_Hush.cancelButtonTitle_Hush,
            style: .cancel,
            handler: nil
        )
        
        alert_Hush.addAction(deleteAction_Hush)
        alert_Hush.addAction(cancelAction_Hush)
        
        viewController_Hush.present(alert_Hush, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Hush(
        action_Hush: @escaping @MainActor () -> Void,
        completion_Hush: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Hush * 1_000_000_000))
            
            await action_Hush()
            
            // 确保在主线程上执行回调
            if let completion_Hush = completion_Hush {
                await MainActor.run {
                    completion_Hush()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Hush(
        user_Hush: PrewUserModel_Hush,
        viewController_Hush: UIViewController
    ) {
        performAsyncAction_Hush(action_Hush: {
            UserViewModel_Hush.shared_Hush.reportUser_Hush(user_hush: user_Hush)
            print("已拉黑用户: \(user_Hush.userName_Hush ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Hush(
        post_Hush: TitleModel_Hush,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        performAsyncAction_Hush(
            action_Hush: {
                TitleViewModel_Hush.shared_Hush.deletePost_Hush(post_hush: post_Hush)
                print("已举报帖子: \(post_Hush.title_Hush)")
            },
            completion_Hush: completion_Hush
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Hush(
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        performAsyncAction_Hush(
            action_Hush: {
                TitleViewModel_Hush.shared_Hush.deleteComment_Hush(
                    post_hush: post_Hush,
                    comment_hush: comment_Hush
                )
                print("已举报评论: \(comment_Hush.commentContent_Hush)")
            },
            completion_Hush: completion_Hush
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Hush(
        post_Hush: TitleModel_Hush,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        performAsyncAction_Hush(
            action_Hush: {
                TitleViewModel_Hush.shared_Hush.deletePost_Hush(
                    post_hush: post_Hush,
                    isDelete_hush: true
                )
                print("已删除帖子: \(post_Hush.title_Hush)")
            },
            completion_Hush: completion_Hush
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Hush(
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) {
        performAsyncAction_Hush(
            action_Hush: {
                TitleViewModel_Hush.shared_Hush.deleteComment_Hush(
                    post_hush: post_Hush,
                    comment_hush: comment_Hush,
                    isDelete_hush: true
                )
                print("已删除评论: \(comment_Hush.commentContent_Hush)")
            },
            completion_Hush: completion_Hush
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Hush(
        post_Hush: TitleModel_Hush,
        size_Hush: CGFloat = 25,
        color_Hush: UIColor = .black,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) -> UIButton {
        let button_Hush = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Hush = UserViewModel_Hush.shared_Hush.isCurrentUser_Hush(
            userId_hush: post_Hush.titleUserId_Hush
        )
        
        // 配置按钮图标
        let iconName_Hush = isMyPost_Hush ? "trash" : "ellipsis"
        configureButtonIcon_Hush(
            button_Hush: button_Hush,
            iconName_Hush: iconName_Hush,
            size_Hush: size_Hush,
            color_Hush: color_Hush
        )
        
        button_Hush.addAction(UIAction { [weak viewController_Hush] _ in
            guard let viewController_Hush = viewController_Hush else { return }
            handlePostButtonTap_Hush(
                button_Hush: button_Hush,
                post_Hush: post_Hush,
                isMyPost_Hush: isMyPost_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }, for: .touchUpInside)
        
        return button_Hush
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Hush(
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        size_Hush: CGFloat = 25,
        color_Hush: UIColor = .black,
        from viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)? = nil
    ) -> UIButton {
        let button_Hush = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Hush = UserViewModel_Hush.shared_Hush.isCurrentUser_Hush(
            userId_hush: comment_Hush.commentUserId_Hush
        )
        
        // 配置按钮图标
        let iconName_Hush = isMyComment_Hush ? "trash" : "ellipsis"
        configureButtonIcon_Hush(
            button_Hush: button_Hush,
            iconName_Hush: iconName_Hush,
            size_Hush: size_Hush,
            color_Hush: color_Hush
        )
        
        button_Hush.addAction(UIAction { [weak viewController_Hush] _ in
            guard let viewController_Hush = viewController_Hush else { return }
            handleCommentButtonTap_Hush(
                button_Hush: button_Hush,
                comment_Hush: comment_Hush,
                post_Hush: post_Hush,
                isMyComment_Hush: isMyComment_Hush,
                viewController_Hush: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }, for: .touchUpInside)
        
        return button_Hush
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Hush(
        size_Hush: CGFloat = 44,
        backgroundColor_Hush: UIColor? = nil,
        tintColor_Hush: UIColor = .white,
        withShadow_Hush: Bool = false
    ) -> UIButton {
        let button_Hush = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Hush = size_Hush * 0.5
        let config_Hush = UIImage.SymbolConfiguration(pointSize: iconSize_Hush, weight: .semibold)
        let image_Hush = UIImage(systemName: "ellipsis", withConfiguration: config_Hush)
        button_Hush.setImage(image_Hush, for: .normal)
        button_Hush.tintColor = tintColor_Hush
        
        // 设置背景
        let bgColor_Hush = backgroundColor_Hush ?? UIColor.white.withAlphaComponent(0.2)
        button_Hush.backgroundColor = bgColor_Hush
        button_Hush.layer.cornerRadius = size_Hush / 2
        
        // 添加阴影
        if withShadow_Hush {
            button_Hush.layer.shadowColor = UIColor.black.cgColor
            button_Hush.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Hush.layer.shadowOpacity = 0.15
            button_Hush.layer.shadowRadius = 8
        }
        
        return button_Hush
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Hush(button_Hush: UIButton) {
        UIView.animate(withDuration: animationDuration_Hush, animations: {
            button_Hush.transform = CGAffineTransform(
                scaleX: animationScale_Hush,
                y: animationScale_Hush
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Hush) {
                button_Hush.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Hush(
        button_Hush: UIButton,
        iconName_Hush: String,
        size_Hush: CGFloat,
        color_Hush: UIColor
    ) {
        let config_Hush = UIImage.SymbolConfiguration(pointSize: size_Hush, weight: .semibold)
        let image_Hush = UIImage(systemName: iconName_Hush, withConfiguration: config_Hush)
        button_Hush.setImage(image_Hush, for: .normal)
        button_Hush.tintColor = color_Hush
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Hush(
        button_Hush: UIButton,
        post_Hush: TitleModel_Hush,
        isMyPost_Hush: Bool,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)?
    ) {
        addButtonAnimation_Hush(button_Hush: button_Hush)
        
        if isMyPost_Hush {
            delete_Hush(
                post_Hush: post_Hush,
                from: viewController_Hush,
                completion_Hush: completion_Hush
            )
        } else {
            report_Hush(
                post_Hush: post_Hush,
                from: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Hush(
        button_Hush: UIButton,
        comment_Hush: Comment_Hush,
        post_Hush: TitleModel_Hush,
        isMyComment_Hush: Bool,
        viewController_Hush: UIViewController,
        completion_Hush: (() -> Void)?
    ) {
        addButtonAnimation_Hush(button_Hush: button_Hush)
        
        if isMyComment_Hush {
            delete_Hush(
                comment_Hush: comment_Hush,
                post_Hush: post_Hush,
                from: viewController_Hush,
                completion_Hush: completion_Hush
            )
        } else {
            report_Hush(
                comment_Hush: comment_Hush,
                post_Hush: post_Hush,
                from: viewController_Hush,
                completion_Hush: completion_Hush
            )
        }
    }
}
