import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Tidy {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Tidy: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Tidy: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Tidy: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Tidy {
        static let postTitle_Tidy = "Delete Post"
        static let postMessage_Tidy = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Tidy = "Delete Comment"
        static let commentMessage_Tidy = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Tidy = "Delete"
        static let cancelButtonTitle_Tidy = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Tidy {
        case block_Tidy       // 拉黑用户
        case post_Tidy        // 举报帖子
        case comment_Tidy     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Tidy(
        user_Tidy: PrewUserModel_Tidy,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        UIAlertController.report_Tidy(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Tidy(
                user_Tidy: user_Tidy,
                viewController_Tidy: viewController_Tidy
            )
            completion_Tidy?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Tidy(
        post_Tidy: TitleModel_Tidy,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        UIAlertController.report_Tidy(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Tidy(
                post_Tidy: post_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy)
        })
    }
    
    /// 举报评论
    static func report_Tidy(
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        UIAlertController.report_Tidy(with: false, completeBlock: {
            performReportComment_Tidy(
                comment_Tidy: comment_Tidy,
                post_Tidy: post_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Tidy(
        post_Tidy: TitleModel_Tidy,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Tidy(
            title_Tidy: DeleteAlertConfig_Tidy.postTitle_Tidy,
            message_Tidy: DeleteAlertConfig_Tidy.postMessage_Tidy,
            from: viewController_Tidy
        ) {
            performDeletePost_Tidy(
                post_Tidy: post_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }
    }
    
    /// 删除评论
    static func delete_Tidy(
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Tidy(
            title_Tidy: DeleteAlertConfig_Tidy.commentTitle_Tidy,
            message_Tidy: DeleteAlertConfig_Tidy.commentMessage_Tidy,
            from: viewController_Tidy
        ) {
            performDeleteComment_Tidy(
                comment_Tidy: comment_Tidy,
                post_Tidy: post_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Tidy(
        title_Tidy: String,
        message_Tidy: String,
        from viewController_Tidy: UIViewController,
        completion_Tidy: @escaping () -> Void
    ) {
        let alert_Tidy = UIAlertController(
            title: title_Tidy,
            message: message_Tidy,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Tidy = UIAlertAction(
            title: DeleteAlertConfig_Tidy.deleteButtonTitle_Tidy,
            style: .destructive
        ) { _ in
            completion_Tidy()
        }
        
        // 取消按钮
        let cancelAction_Tidy = UIAlertAction(
            title: DeleteAlertConfig_Tidy.cancelButtonTitle_Tidy,
            style: .cancel,
            handler: nil
        )
        
        alert_Tidy.addAction(deleteAction_Tidy)
        alert_Tidy.addAction(cancelAction_Tidy)
        
        viewController_Tidy.present(alert_Tidy, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Tidy(
        action_Tidy: @escaping @MainActor () -> Void,
        completion_Tidy: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Tidy * 1_000_000_000))
            
            await action_Tidy()
            
            // 确保在主线程上执行回调
            if let completion_Tidy = completion_Tidy {
                await MainActor.run {
                    completion_Tidy()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Tidy(
        user_Tidy: PrewUserModel_Tidy,
        viewController_Tidy: UIViewController
    ) {
        performAsyncAction_Tidy(action_Tidy: {
            UserViewModel_Tidy.shared_Tidy.reportUser_Tidy(user_tidy: user_Tidy)
            print("已拉黑用户: \(user_Tidy.userName_Tidy ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Tidy(
        post_Tidy: TitleModel_Tidy,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        performAsyncAction_Tidy(
            action_Tidy: {
                TitleViewModel_Tidy.shared_Tidy.deletePost_Tidy(post_tidy: post_Tidy)
                print("已举报帖子: \(post_Tidy.title_Tidy)")
            },
            completion_Tidy: completion_Tidy
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Tidy(
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        performAsyncAction_Tidy(
            action_Tidy: {
                TitleViewModel_Tidy.shared_Tidy.deleteComment_Tidy(
                    post_tidy: post_Tidy,
                    comment_tidy: comment_Tidy
                )
                print("已举报评论: \(comment_Tidy.commentContent_Tidy)")
            },
            completion_Tidy: completion_Tidy
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Tidy(
        post_Tidy: TitleModel_Tidy,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        performAsyncAction_Tidy(
            action_Tidy: {
                TitleViewModel_Tidy.shared_Tidy.deletePost_Tidy(
                    post_tidy: post_Tidy,
                    isDelete_tidy: true
                )
                print("已删除帖子: \(post_Tidy.title_Tidy)")
            },
            completion_Tidy: completion_Tidy
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Tidy(
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) {
        performAsyncAction_Tidy(
            action_Tidy: {
                TitleViewModel_Tidy.shared_Tidy.deleteComment_Tidy(
                    post_tidy: post_Tidy,
                    comment_tidy: comment_Tidy,
                    isDelete_tidy: true
                )
                print("已删除评论: \(comment_Tidy.commentContent_Tidy)")
            },
            completion_Tidy: completion_Tidy
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Tidy(
        post_Tidy: TitleModel_Tidy,
        size_Tidy: CGFloat = 25,
        color_Tidy: UIColor = .black,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) -> UIButton {
        let button_Tidy = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: post_Tidy.titleUserId_Tidy
        )
        
        // 配置按钮图标
        let iconName_Tidy = isMyPost_Tidy ? "trash" : "ellipsis"
        configureButtonIcon_Tidy(
            button_Tidy: button_Tidy,
            iconName_Tidy: iconName_Tidy,
            size_Tidy: size_Tidy,
            color_Tidy: color_Tidy
        )
        
        button_Tidy.addAction(UIAction { [weak viewController_Tidy] _ in
            guard let viewController_Tidy = viewController_Tidy else { return }
            handlePostButtonTap_Tidy(
                button_Tidy: button_Tidy,
                post_Tidy: post_Tidy,
                isMyPost_Tidy: isMyPost_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }, for: .touchUpInside)
        
        return button_Tidy
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Tidy(
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        size_Tidy: CGFloat = 25,
        color_Tidy: UIColor = .black,
        from viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)? = nil
    ) -> UIButton {
        let button_Tidy = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Tidy = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: comment_Tidy.commentUserId_Tidy
        )
        
        // 配置按钮图标
        let iconName_Tidy = isMyComment_Tidy ? "trash" : "ellipsis"
        configureButtonIcon_Tidy(
            button_Tidy: button_Tidy,
            iconName_Tidy: iconName_Tidy,
            size_Tidy: size_Tidy,
            color_Tidy: color_Tidy
        )
        
        button_Tidy.addAction(UIAction { [weak viewController_Tidy] _ in
            guard let viewController_Tidy = viewController_Tidy else { return }
            handleCommentButtonTap_Tidy(
                button_Tidy: button_Tidy,
                comment_Tidy: comment_Tidy,
                post_Tidy: post_Tidy,
                isMyComment_Tidy: isMyComment_Tidy,
                viewController_Tidy: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }, for: .touchUpInside)
        
        return button_Tidy
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Tidy(
        size_Tidy: CGFloat = 44,
        backgroundColor_Tidy: UIColor? = nil,
        tintColor_Tidy: UIColor = .white,
        withShadow_Tidy: Bool = false
    ) -> UIButton {
        let button_Tidy = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Tidy = size_Tidy * 0.5
        let config_Tidy = UIImage.SymbolConfiguration(pointSize: iconSize_Tidy, weight: .semibold)
        let image_Tidy = UIImage(systemName: "ellipsis", withConfiguration: config_Tidy)
        button_Tidy.setImage(image_Tidy, for: .normal)
        button_Tidy.tintColor = tintColor_Tidy
        
        // 设置背景
        let bgColor_Tidy = backgroundColor_Tidy ?? UIColor.white.withAlphaComponent(0.2)
        button_Tidy.backgroundColor = bgColor_Tidy
        button_Tidy.layer.cornerRadius = size_Tidy / 2
        
        // 添加阴影
        if withShadow_Tidy {
            button_Tidy.layer.shadowColor = UIColor.black.cgColor
            button_Tidy.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Tidy.layer.shadowOpacity = 0.15
            button_Tidy.layer.shadowRadius = 8
        }
        
        return button_Tidy
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Tidy(button_Tidy: UIButton) {
        UIView.animate(withDuration: animationDuration_Tidy, animations: {
            button_Tidy.transform = CGAffineTransform(
                scaleX: animationScale_Tidy,
                y: animationScale_Tidy
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Tidy) {
                button_Tidy.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Tidy(
        button_Tidy: UIButton,
        iconName_Tidy: String,
        size_Tidy: CGFloat,
        color_Tidy: UIColor
    ) {
        let config_Tidy = UIImage.SymbolConfiguration(pointSize: size_Tidy, weight: .semibold)
        let image_Tidy = UIImage(systemName: iconName_Tidy, withConfiguration: config_Tidy)
        button_Tidy.setImage(image_Tidy, for: .normal)
        button_Tidy.tintColor = color_Tidy
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Tidy(
        button_Tidy: UIButton,
        post_Tidy: TitleModel_Tidy,
        isMyPost_Tidy: Bool,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)?
    ) {
        addButtonAnimation_Tidy(button_Tidy: button_Tidy)
        
        if isMyPost_Tidy {
            delete_Tidy(
                post_Tidy: post_Tidy,
                from: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        } else {
            report_Tidy(
                post_Tidy: post_Tidy,
                from: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Tidy(
        button_Tidy: UIButton,
        comment_Tidy: Comment_Tidy,
        post_Tidy: TitleModel_Tidy,
        isMyComment_Tidy: Bool,
        viewController_Tidy: UIViewController,
        completion_Tidy: (() -> Void)?
    ) {
        addButtonAnimation_Tidy(button_Tidy: button_Tidy)
        
        if isMyComment_Tidy {
            delete_Tidy(
                comment_Tidy: comment_Tidy,
                post_Tidy: post_Tidy,
                from: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        } else {
            report_Tidy(
                comment_Tidy: comment_Tidy,
                post_Tidy: post_Tidy,
                from: viewController_Tidy,
                completion_Tidy: completion_Tidy
            )
        }
    }
}
