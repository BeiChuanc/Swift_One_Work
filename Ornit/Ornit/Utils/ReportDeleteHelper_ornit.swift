import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Ornit {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Ornit: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Ornit: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Ornit: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Ornit {
        static let postTitle_Ornit = "Delete Post"
        static let postMessage_Ornit = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Ornit = "Delete Comment"
        static let commentMessage_Ornit = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Ornit = "Delete"
        static let cancelButtonTitle_Ornit = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Ornit {
        case block_Ornit       // 拉黑用户
        case post_Ornit        // 举报帖子
        case comment_Ornit     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Ornit(
        user_Ornit: PrewUserModel_Ornit,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        UIAlertController.report_Ornit(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Ornit(
                user_Ornit: user_Ornit,
                viewController_Ornit: viewController_Ornit
            )
            completion_Ornit?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Ornit(
        post_Ornit: TitleModel_Ornit,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        UIAlertController.report_Ornit(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Ornit(
                post_Ornit: post_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit)
        })
    }
    
    /// 举报评论
    static func report_Ornit(
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        UIAlertController.report_Ornit(with: false, completeBlock: {
            performReportComment_Ornit(
                comment_Ornit: comment_Ornit,
                post_Ornit: post_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Ornit(
        post_Ornit: TitleModel_Ornit,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Ornit(
            title_Ornit: DeleteAlertConfig_Ornit.postTitle_Ornit,
            message_Ornit: DeleteAlertConfig_Ornit.postMessage_Ornit,
            from: viewController_Ornit
        ) {
            performDeletePost_Ornit(
                post_Ornit: post_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }
    }
    
    /// 删除评论
    static func delete_Ornit(
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Ornit(
            title_Ornit: DeleteAlertConfig_Ornit.commentTitle_Ornit,
            message_Ornit: DeleteAlertConfig_Ornit.commentMessage_Ornit,
            from: viewController_Ornit
        ) {
            performDeleteComment_Ornit(
                comment_Ornit: comment_Ornit,
                post_Ornit: post_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Ornit(
        title_Ornit: String,
        message_Ornit: String,
        from viewController_Ornit: UIViewController,
        completion_Ornit: @escaping () -> Void
    ) {
        let alert_Ornit = UIAlertController(
            title: title_Ornit,
            message: message_Ornit,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Ornit = UIAlertAction(
            title: DeleteAlertConfig_Ornit.deleteButtonTitle_Ornit,
            style: .destructive
        ) { _ in
            completion_Ornit()
        }
        
        // 取消按钮
        let cancelAction_Ornit = UIAlertAction(
            title: DeleteAlertConfig_Ornit.cancelButtonTitle_Ornit,
            style: .cancel,
            handler: nil
        )
        
        alert_Ornit.addAction(deleteAction_Ornit)
        alert_Ornit.addAction(cancelAction_Ornit)
        
        viewController_Ornit.present(alert_Ornit, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Ornit(
        action_Ornit: @escaping @MainActor () -> Void,
        completion_Ornit: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Ornit * 1_000_000_000))
            
            await action_Ornit()
            
            // 确保在主线程上执行回调
            if let completion_Ornit = completion_Ornit {
                await MainActor.run {
                    completion_Ornit()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Ornit(
        user_Ornit: PrewUserModel_Ornit,
        viewController_Ornit: UIViewController
    ) {
        performAsyncAction_Ornit(action_Ornit: {
            UserViewModel_Ornit.shared_Ornit.reportUser_Ornit(user_ornit: user_Ornit)
            print("已拉黑用户: \(user_Ornit.userName_Ornit ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Ornit(
        post_Ornit: TitleModel_Ornit,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        performAsyncAction_Ornit(
            action_Ornit: {
                TitleViewModel_Ornit.shared_Ornit.deletePost_Ornit(post_ornit: post_Ornit)
                print("已举报帖子: \(post_Ornit.title_Ornit)")
            },
            completion_Ornit: completion_Ornit
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Ornit(
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        performAsyncAction_Ornit(
            action_Ornit: {
                TitleViewModel_Ornit.shared_Ornit.deleteComment_Ornit(
                    post_ornit: post_Ornit,
                    comment_ornit: comment_Ornit
                )
                print("已举报评论: \(comment_Ornit.commentContent_Ornit)")
            },
            completion_Ornit: completion_Ornit
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Ornit(
        post_Ornit: TitleModel_Ornit,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        performAsyncAction_Ornit(
            action_Ornit: {
                TitleViewModel_Ornit.shared_Ornit.deletePost_Ornit(
                    post_ornit: post_Ornit,
                    isDelete_ornit: true
                )
                print("已删除帖子: \(post_Ornit.title_Ornit)")
            },
            completion_Ornit: completion_Ornit
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Ornit(
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) {
        performAsyncAction_Ornit(
            action_Ornit: {
                TitleViewModel_Ornit.shared_Ornit.deleteComment_Ornit(
                    post_ornit: post_Ornit,
                    comment_ornit: comment_Ornit,
                    isDelete_ornit: true
                )
                print("已删除评论: \(comment_Ornit.commentContent_Ornit)")
            },
            completion_Ornit: completion_Ornit
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Ornit(
        post_Ornit: TitleModel_Ornit,
        size_Ornit: CGFloat = 25,
        color_Ornit: UIColor = .black,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) -> UIButton {
        let button_Ornit = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Ornit = UserViewModel_Ornit.shared_Ornit.isCurrentUser_Ornit(
            userId_ornit: post_Ornit.titleUserId_Ornit
        )
        
        // 配置按钮图标
        let iconName_Ornit = isMyPost_Ornit ? "trash" : "ellipsis"
        configureButtonIcon_Ornit(
            button_Ornit: button_Ornit,
            iconName_Ornit: iconName_Ornit,
            size_Ornit: size_Ornit,
            color_Ornit: color_Ornit
        )
        
        button_Ornit.addAction(UIAction { [weak viewController_Ornit] _ in
            guard let viewController_Ornit = viewController_Ornit else { return }
            handlePostButtonTap_Ornit(
                button_Ornit: button_Ornit,
                post_Ornit: post_Ornit,
                isMyPost_Ornit: isMyPost_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }, for: .touchUpInside)
        
        return button_Ornit
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Ornit(
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        size_Ornit: CGFloat = 25,
        color_Ornit: UIColor = .black,
        from viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)? = nil
    ) -> UIButton {
        let button_Ornit = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Ornit = UserViewModel_Ornit.shared_Ornit.isCurrentUser_Ornit(
            userId_ornit: comment_Ornit.commentUserId_Ornit
        )
        
        // 配置按钮图标
        let iconName_Ornit = isMyComment_Ornit ? "trash" : "ellipsis"
        configureButtonIcon_Ornit(
            button_Ornit: button_Ornit,
            iconName_Ornit: iconName_Ornit,
            size_Ornit: size_Ornit,
            color_Ornit: color_Ornit
        )
        
        button_Ornit.addAction(UIAction { [weak viewController_Ornit] _ in
            guard let viewController_Ornit = viewController_Ornit else { return }
            handleCommentButtonTap_Ornit(
                button_Ornit: button_Ornit,
                comment_Ornit: comment_Ornit,
                post_Ornit: post_Ornit,
                isMyComment_Ornit: isMyComment_Ornit,
                viewController_Ornit: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }, for: .touchUpInside)
        
        return button_Ornit
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Ornit(
        size_Ornit: CGFloat = 44,
        backgroundColor_Ornit: UIColor? = nil,
        tintColor_Ornit: UIColor = .white,
        withShadow_Ornit: Bool = false
    ) -> UIButton {
        let button_Ornit = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Ornit = size_Ornit * 0.5
        let config_Ornit = UIImage.SymbolConfiguration(pointSize: iconSize_Ornit, weight: .semibold)
        let image_Ornit = UIImage(systemName: "ellipsis", withConfiguration: config_Ornit)
        button_Ornit.setImage(image_Ornit, for: .normal)
        button_Ornit.tintColor = tintColor_Ornit
        
        // 设置背景
        let bgColor_Ornit = backgroundColor_Ornit ?? UIColor.white.withAlphaComponent(0.2)
        button_Ornit.backgroundColor = bgColor_Ornit
        button_Ornit.layer.cornerRadius = size_Ornit / 2
        
        // 添加阴影
        if withShadow_Ornit {
            button_Ornit.layer.shadowColor = UIColor.black.cgColor
            button_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Ornit.layer.shadowOpacity = 0.15
            button_Ornit.layer.shadowRadius = 8
        }
        
        return button_Ornit
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Ornit(button_Ornit: UIButton) {
        UIView.animate(withDuration: animationDuration_Ornit, animations: {
            button_Ornit.transform = CGAffineTransform(
                scaleX: animationScale_Ornit,
                y: animationScale_Ornit
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Ornit) {
                button_Ornit.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Ornit(
        button_Ornit: UIButton,
        iconName_Ornit: String,
        size_Ornit: CGFloat,
        color_Ornit: UIColor
    ) {
        let config_Ornit = UIImage.SymbolConfiguration(pointSize: size_Ornit, weight: .semibold)
        let image_Ornit = UIImage(systemName: iconName_Ornit, withConfiguration: config_Ornit)
        button_Ornit.setImage(image_Ornit, for: .normal)
        button_Ornit.tintColor = color_Ornit
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Ornit(
        button_Ornit: UIButton,
        post_Ornit: TitleModel_Ornit,
        isMyPost_Ornit: Bool,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)?
    ) {
        addButtonAnimation_Ornit(button_Ornit: button_Ornit)
        
        if isMyPost_Ornit {
            delete_Ornit(
                post_Ornit: post_Ornit,
                from: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        } else {
            report_Ornit(
                post_Ornit: post_Ornit,
                from: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Ornit(
        button_Ornit: UIButton,
        comment_Ornit: Comment_Ornit,
        post_Ornit: TitleModel_Ornit,
        isMyComment_Ornit: Bool,
        viewController_Ornit: UIViewController,
        completion_Ornit: (() -> Void)?
    ) {
        addButtonAnimation_Ornit(button_Ornit: button_Ornit)
        
        if isMyComment_Ornit {
            delete_Ornit(
                comment_Ornit: comment_Ornit,
                post_Ornit: post_Ornit,
                from: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        } else {
            report_Ornit(
                comment_Ornit: comment_Ornit,
                post_Ornit: post_Ornit,
                from: viewController_Ornit,
                completion_Ornit: completion_Ornit
            )
        }
    }
}
