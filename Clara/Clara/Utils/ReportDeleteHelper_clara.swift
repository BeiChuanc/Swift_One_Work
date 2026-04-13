import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Clara {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Clara: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Clara: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Clara: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Clara {
        static let postTitle_Clara = "Delete Post"
        static let postMessage_Clara = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Clara = "Delete Comment"
        static let commentMessage_Clara = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Clara = "Delete"
        static let cancelButtonTitle_Clara = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Clara {
        case block_Clara       // 拉黑用户
        case post_Clara        // 举报帖子
        case comment_Clara     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Clara(
        user_Clara: PrewUserModel_Clara,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        UIAlertController.report_Clara(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Clara(
                user_Clara: user_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara
            )
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Clara(
        post_Clara: TitleModel_Clara,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        UIAlertController.report_Clara(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Clara(
                post_Clara: post_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara)
        })
    }
    
    /// 举报评论
    static func report_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        UIAlertController.report_Clara(with: false, completeBlock: {
            performReportComment_Clara(
                comment_Clara: comment_Clara,
                post_Clara: post_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Clara(
        post_Clara: TitleModel_Clara,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Clara(
            title_Clara: DeleteAlertConfig_Clara.postTitle_Clara,
            message_Clara: DeleteAlertConfig_Clara.postMessage_Clara,
            from: viewController_Clara
        ) {
            performDeletePost_Clara(
                post_Clara: post_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }
    }
    
    /// 删除评论
    static func delete_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Clara(
            title_Clara: DeleteAlertConfig_Clara.commentTitle_Clara,
            message_Clara: DeleteAlertConfig_Clara.commentMessage_Clara,
            from: viewController_Clara
        ) {
            performDeleteComment_Clara(
                comment_Clara: comment_Clara,
                post_Clara: post_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Clara(
        title_Clara: String,
        message_Clara: String,
        from viewController_Clara: UIViewController,
        completion_Clara: @escaping () -> Void
    ) {
        let alert_Clara = UIAlertController(
            title: title_Clara,
            message: message_Clara,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Clara = UIAlertAction(
            title: DeleteAlertConfig_Clara.deleteButtonTitle_Clara,
            style: .destructive
        ) { _ in
            completion_Clara()
        }
        
        // 取消按钮
        let cancelAction_Clara = UIAlertAction(
            title: DeleteAlertConfig_Clara.cancelButtonTitle_Clara,
            style: .cancel,
            handler: nil
        )
        
        alert_Clara.addAction(deleteAction_Clara)
        alert_Clara.addAction(cancelAction_Clara)
        
        viewController_Clara.present(alert_Clara, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Clara(
        action_Clara: @escaping @MainActor () -> Void,
        completion_Clara: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Clara * 1_000_000_000))
            
            await action_Clara()
            
            // 确保在主线程上执行回调
            if let completion_Clara = completion_Clara {
                await MainActor.run {
                    completion_Clara()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Clara(
        user_Clara: PrewUserModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        performAsyncAction_Clara(
            action_Clara: {
                UserViewModel_Clara.shared_Clara.reportUser_Clara(user_clara: user_Clara)
                print("已拉黑用户: \(user_Clara.userName_Clara ?? "Unknown")")
            },
            completion_Clara: completion_Clara
        )
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Clara(
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        performAsyncAction_Clara(
            action_Clara: {
                TitleViewModel_Clara.shared_Clara.deletePost_Clara(post_clara: post_Clara)
                print("已举报帖子: \(post_Clara.title_Clara)")
            },
            completion_Clara: completion_Clara
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        performAsyncAction_Clara(
            action_Clara: {
                TitleViewModel_Clara.shared_Clara.deleteComment_Clara(
                    post_clara: post_Clara,
                    comment_clara: comment_Clara
                )
                print("已举报评论: \(comment_Clara.commentContent_Clara)")
            },
            completion_Clara: completion_Clara
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Clara(
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        performAsyncAction_Clara(
            action_Clara: {
                TitleViewModel_Clara.shared_Clara.deletePost_Clara(
                    post_clara: post_Clara,
                    isDelete_clara: true
                )
                print("已删除帖子: \(post_Clara.title_Clara)")
            },
            completion_Clara: completion_Clara
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) {
        performAsyncAction_Clara(
            action_Clara: {
                TitleViewModel_Clara.shared_Clara.deleteComment_Clara(
                    post_clara: post_Clara,
                    comment_clara: comment_Clara,
                    isDelete_clara: true
                )
                print("已删除评论: \(comment_Clara.commentContent_Clara)")
            },
            completion_Clara: completion_Clara
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Clara(
        post_Clara: TitleModel_Clara,
        size_Clara: CGFloat = 25,
        color_Clara: UIColor = .black,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) -> UIButton {
        let button_Clara = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Clara = UserViewModel_Clara.shared_Clara.isCurrentUser_Clara(
            userId_clara: post_Clara.titleUserId_Clara
        )
        
        // 配置按钮图标
        let iconName_Clara = isMyPost_Clara ? "trash" : "ellipsis"
        configureButtonIcon_Clara(
            button_Clara: button_Clara,
            iconName_Clara: iconName_Clara,
            size_Clara: size_Clara,
            color_Clara: color_Clara
        )
        
        button_Clara.addAction(UIAction { [weak viewController_Clara] _ in
            guard let viewController_Clara = viewController_Clara else { return }
            handlePostButtonTap_Clara(
                button_Clara: button_Clara,
                post_Clara: post_Clara,
                isMyPost_Clara: isMyPost_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }, for: .touchUpInside)
        
        return button_Clara
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Clara(
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        size_Clara: CGFloat = 25,
        color_Clara: UIColor = .black,
        from viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)? = nil
    ) -> UIButton {
        let button_Clara = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Clara = UserViewModel_Clara.shared_Clara.isCurrentUser_Clara(
            userId_clara: comment_Clara.commentUserId_Clara
        )
        
        // 配置按钮图标
        let iconName_Clara = isMyComment_Clara ? "trash" : "ellipsis"
        configureButtonIcon_Clara(
            button_Clara: button_Clara,
            iconName_Clara: iconName_Clara,
            size_Clara: size_Clara,
            color_Clara: color_Clara
        )
        
        button_Clara.addAction(UIAction { [weak viewController_Clara] _ in
            guard let viewController_Clara = viewController_Clara else { return }
            handleCommentButtonTap_Clara(
                button_Clara: button_Clara,
                comment_Clara: comment_Clara,
                post_Clara: post_Clara,
                isMyComment_Clara: isMyComment_Clara,
                viewController_Clara: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }, for: .touchUpInside)
        
        return button_Clara
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Clara(
        size_Clara: CGFloat = 44,
        backgroundColor_Clara: UIColor? = nil,
        tintColor_Clara: UIColor = .white,
        withShadow_Clara: Bool = false
    ) -> UIButton {
        let button_Clara = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Clara = size_Clara * 0.5
        let config_Clara = UIImage.SymbolConfiguration(pointSize: iconSize_Clara, weight: .semibold)
        let image_Clara = UIImage(systemName: "ellipsis", withConfiguration: config_Clara)
        button_Clara.setImage(image_Clara, for: .normal)
        button_Clara.tintColor = tintColor_Clara
        
        // 设置背景
        let bgColor_Clara = backgroundColor_Clara ?? UIColor.white.withAlphaComponent(0.2)
        button_Clara.backgroundColor = bgColor_Clara
        button_Clara.layer.cornerRadius = size_Clara / 2
        
        // 添加阴影
        if withShadow_Clara {
            button_Clara.layer.shadowColor = UIColor.black.cgColor
            button_Clara.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Clara.layer.shadowOpacity = 0.15
            button_Clara.layer.shadowRadius = 8
        }
        
        return button_Clara
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Clara(button_Clara: UIButton) {
        UIView.animate(withDuration: animationDuration_Clara, animations: {
            button_Clara.transform = CGAffineTransform(
                scaleX: animationScale_Clara,
                y: animationScale_Clara
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Clara) {
                button_Clara.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Clara(
        button_Clara: UIButton,
        iconName_Clara: String,
        size_Clara: CGFloat,
        color_Clara: UIColor
    ) {
        let config_Clara = UIImage.SymbolConfiguration(pointSize: size_Clara, weight: .semibold)
        let image_Clara = UIImage(systemName: iconName_Clara, withConfiguration: config_Clara)
        button_Clara.setImage(image_Clara, for: .normal)
        button_Clara.tintColor = color_Clara
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Clara(
        button_Clara: UIButton,
        post_Clara: TitleModel_Clara,
        isMyPost_Clara: Bool,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)?
    ) {
        addButtonAnimation_Clara(button_Clara: button_Clara)
        
        if isMyPost_Clara {
            delete_Clara(
                post_Clara: post_Clara,
                from: viewController_Clara,
                completion_Clara: completion_Clara
            )
        } else {
            report_Clara(
                post_Clara: post_Clara,
                from: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Clara(
        button_Clara: UIButton,
        comment_Clara: Comment_Clara,
        post_Clara: TitleModel_Clara,
        isMyComment_Clara: Bool,
        viewController_Clara: UIViewController,
        completion_Clara: (() -> Void)?
    ) {
        addButtonAnimation_Clara(button_Clara: button_Clara)
        
        if isMyComment_Clara {
            delete_Clara(
                comment_Clara: comment_Clara,
                post_Clara: post_Clara,
                from: viewController_Clara,
                completion_Clara: completion_Clara
            )
        } else {
            report_Clara(
                comment_Clara: comment_Clara,
                post_Clara: post_Clara,
                from: viewController_Clara,
                completion_Clara: completion_Clara
            )
        }
    }
}
