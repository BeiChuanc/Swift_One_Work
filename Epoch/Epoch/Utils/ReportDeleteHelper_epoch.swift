import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Epoch {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Epoch: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Epoch: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Epoch: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Epoch {
        static let postTitle_Epoch = "Delete Post"
        static let postMessage_Epoch = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Epoch = "Delete Comment"
        static let commentMessage_Epoch = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Epoch = "Delete"
        static let cancelButtonTitle_Epoch = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Epoch {
        case block_Epoch       // 拉黑用户
        case post_Epoch        // 举报帖子
        case comment_Epoch     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Epoch(
        user_Epoch: PrewUserModel_Epoch,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        UIAlertController.report_Epoch(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Epoch(
                user_Epoch: user_Epoch,
                viewController_Epoch: viewController_Epoch
            )
            completion_Epoch?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Epoch(
        post_Epoch: TitleModel_Epoch,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        UIAlertController.report_Epoch(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Epoch(
                post_Epoch: post_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch)
        })
    }
    
    /// 举报评论
    static func report_Epoch(
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        UIAlertController.report_Epoch(with: false, completeBlock: {
            performReportComment_Epoch(
                comment_Epoch: comment_Epoch,
                post_Epoch: post_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Epoch(
        post_Epoch: TitleModel_Epoch,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Epoch(
            title_Epoch: DeleteAlertConfig_Epoch.postTitle_Epoch,
            message_Epoch: DeleteAlertConfig_Epoch.postMessage_Epoch,
            from: viewController_Epoch
        ) {
            performDeletePost_Epoch(
                post_Epoch: post_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }
    }
    
    /// 删除评论
    static func delete_Epoch(
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Epoch(
            title_Epoch: DeleteAlertConfig_Epoch.commentTitle_Epoch,
            message_Epoch: DeleteAlertConfig_Epoch.commentMessage_Epoch,
            from: viewController_Epoch
        ) {
            performDeleteComment_Epoch(
                comment_Epoch: comment_Epoch,
                post_Epoch: post_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Epoch(
        title_Epoch: String,
        message_Epoch: String,
        from viewController_Epoch: UIViewController,
        completion_Epoch: @escaping () -> Void
    ) {
        let alert_Epoch = UIAlertController(
            title: title_Epoch,
            message: message_Epoch,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Epoch = UIAlertAction(
            title: DeleteAlertConfig_Epoch.deleteButtonTitle_Epoch,
            style: .destructive
        ) { _ in
            completion_Epoch()
        }
        
        // 取消按钮
        let cancelAction_Epoch = UIAlertAction(
            title: DeleteAlertConfig_Epoch.cancelButtonTitle_Epoch,
            style: .cancel,
            handler: nil
        )
        
        alert_Epoch.addAction(deleteAction_Epoch)
        alert_Epoch.addAction(cancelAction_Epoch)
        
        viewController_Epoch.present(alert_Epoch, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Epoch(
        action_Epoch: @escaping @MainActor () -> Void,
        completion_Epoch: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Epoch * 1_000_000_000))
            
            await action_Epoch()
            
            // 确保在主线程上执行回调
            if let completion_Epoch = completion_Epoch {
                await MainActor.run {
                    completion_Epoch()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Epoch(
        user_Epoch: PrewUserModel_Epoch,
        viewController_Epoch: UIViewController
    ) {
        performAsyncAction_Epoch(action_Epoch: {
            UserViewModel_Epoch.shared_Epoch.reportUser_Epoch(user_epoch: user_Epoch)
            print("已拉黑用户: \(user_Epoch.userName_Epoch ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Epoch(
        post_Epoch: TitleModel_Epoch,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        performAsyncAction_Epoch(
            action_Epoch: {
                TitleViewModel_Epoch.shared_Epoch.deletePost_Epoch(post_epoch: post_Epoch)
                print("已举报帖子: \(post_Epoch.title_Epoch)")
            },
            completion_Epoch: completion_Epoch
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Epoch(
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        performAsyncAction_Epoch(
            action_Epoch: {
                TitleViewModel_Epoch.shared_Epoch.deleteComment_Epoch(
                    post_epoch: post_Epoch,
                    comment_epoch: comment_Epoch
                )
                print("已举报评论: \(comment_Epoch.commentContent_Epoch)")
            },
            completion_Epoch: completion_Epoch
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Epoch(
        post_Epoch: TitleModel_Epoch,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        performAsyncAction_Epoch(
            action_Epoch: {
                TitleViewModel_Epoch.shared_Epoch.deletePost_Epoch(
                    post_epoch: post_Epoch,
                    isDelete_epoch: true
                )
                print("已删除帖子: \(post_Epoch.title_Epoch)")
            },
            completion_Epoch: completion_Epoch
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Epoch(
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) {
        performAsyncAction_Epoch(
            action_Epoch: {
                TitleViewModel_Epoch.shared_Epoch.deleteComment_Epoch(
                    post_epoch: post_Epoch,
                    comment_epoch: comment_Epoch,
                    isDelete_epoch: true
                )
                print("已删除评论: \(comment_Epoch.commentContent_Epoch)")
            },
            completion_Epoch: completion_Epoch
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Epoch(
        post_Epoch: TitleModel_Epoch,
        size_Epoch: CGFloat = 25,
        color_Epoch: UIColor = .black,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) -> UIButton {
        let button_Epoch = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Epoch = UserViewModel_Epoch.shared_Epoch.isCurrentUser_Epoch(
            userId_epoch: post_Epoch.titleUserId_Epoch
        )
        
        // 配置按钮图标
        let iconName_Epoch = isMyPost_Epoch ? "trash" : "ellipsis"
        configureButtonIcon_Epoch(
            button_Epoch: button_Epoch,
            iconName_Epoch: iconName_Epoch,
            size_Epoch: size_Epoch,
            color_Epoch: color_Epoch
        )
        
        button_Epoch.addAction(UIAction { [weak viewController_Epoch] _ in
            guard let viewController_Epoch = viewController_Epoch else { return }
            handlePostButtonTap_Epoch(
                button_Epoch: button_Epoch,
                post_Epoch: post_Epoch,
                isMyPost_Epoch: isMyPost_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }, for: .touchUpInside)
        
        return button_Epoch
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Epoch(
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        size_Epoch: CGFloat = 25,
        color_Epoch: UIColor = .black,
        from viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)? = nil
    ) -> UIButton {
        let button_Epoch = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Epoch = UserViewModel_Epoch.shared_Epoch.isCurrentUser_Epoch(
            userId_epoch: comment_Epoch.commentUserId_Epoch
        )
        
        // 配置按钮图标
        let iconName_Epoch = isMyComment_Epoch ? "trash" : "ellipsis"
        configureButtonIcon_Epoch(
            button_Epoch: button_Epoch,
            iconName_Epoch: iconName_Epoch,
            size_Epoch: size_Epoch,
            color_Epoch: color_Epoch
        )
        
        button_Epoch.addAction(UIAction { [weak viewController_Epoch] _ in
            guard let viewController_Epoch = viewController_Epoch else { return }
            handleCommentButtonTap_Epoch(
                button_Epoch: button_Epoch,
                comment_Epoch: comment_Epoch,
                post_Epoch: post_Epoch,
                isMyComment_Epoch: isMyComment_Epoch,
                viewController_Epoch: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }, for: .touchUpInside)
        
        return button_Epoch
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Epoch(
        size_Epoch: CGFloat = 44,
        backgroundColor_Epoch: UIColor? = nil,
        tintColor_Epoch: UIColor = .white,
        withShadow_Epoch: Bool = false
    ) -> UIButton {
        let button_Epoch = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Epoch = size_Epoch * 0.8
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: iconSize_Epoch, weight: .semibold)
        let image_Epoch = UIImage(systemName: "ellipsis", withConfiguration: config_Epoch)
        button_Epoch.setImage(image_Epoch, for: .normal)
        button_Epoch.tintColor = tintColor_Epoch
        
        // 设置背景
        let bgColor_Epoch = backgroundColor_Epoch ?? UIColor.white.withAlphaComponent(0.2)
        button_Epoch.backgroundColor = bgColor_Epoch
        button_Epoch.layer.cornerRadius = size_Epoch / 2
        
        // 添加阴影
        if withShadow_Epoch {
            button_Epoch.layer.shadowColor = UIColor.black.cgColor
            button_Epoch.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Epoch.layer.shadowOpacity = 0.15
            button_Epoch.layer.shadowRadius = 8
        }
        
        return button_Epoch
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Epoch(button_Epoch: UIButton) {
        UIView.animate(withDuration: animationDuration_Epoch, animations: {
            button_Epoch.transform = CGAffineTransform(
                scaleX: animationScale_Epoch,
                y: animationScale_Epoch
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Epoch) {
                button_Epoch.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Epoch(
        button_Epoch: UIButton,
        iconName_Epoch: String,
        size_Epoch: CGFloat,
        color_Epoch: UIColor
    ) {
        let config_Epoch = UIImage.SymbolConfiguration(pointSize: size_Epoch, weight: .semibold)
        let image_Epoch = UIImage(systemName: iconName_Epoch, withConfiguration: config_Epoch)
        button_Epoch.setImage(image_Epoch, for: .normal)
        button_Epoch.tintColor = color_Epoch
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Epoch(
        button_Epoch: UIButton,
        post_Epoch: TitleModel_Epoch,
        isMyPost_Epoch: Bool,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)?
    ) {
        addButtonAnimation_Epoch(button_Epoch: button_Epoch)
        
        if isMyPost_Epoch {
            delete_Epoch(
                post_Epoch: post_Epoch,
                from: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        } else {
            report_Epoch(
                post_Epoch: post_Epoch,
                from: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Epoch(
        button_Epoch: UIButton,
        comment_Epoch: Comment_Epoch,
        post_Epoch: TitleModel_Epoch,
        isMyComment_Epoch: Bool,
        viewController_Epoch: UIViewController,
        completion_Epoch: (() -> Void)?
    ) {
        addButtonAnimation_Epoch(button_Epoch: button_Epoch)
        
        if isMyComment_Epoch {
            delete_Epoch(
                comment_Epoch: comment_Epoch,
                post_Epoch: post_Epoch,
                from: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        } else {
            report_Epoch(
                comment_Epoch: comment_Epoch,
                post_Epoch: post_Epoch,
                from: viewController_Epoch,
                completion_Epoch: completion_Epoch
            )
        }
    }
}
