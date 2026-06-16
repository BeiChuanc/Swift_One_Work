import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Retrs {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Retrs: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Retrs: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Retrs: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Retrs {
        static let postTitle_Retrs = "Delete Post"
        static let postMessage_Retrs = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Retrs = "Delete Comment"
        static let commentMessage_Retrs = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Retrs = "Delete"
        static let cancelButtonTitle_Retrs = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Retrs {
        case block_Retrs       // 拉黑用户
        case post_Retrs        // 举报帖子
        case comment_Retrs     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Retrs(
        user_Retrs: PrewUserModel_Retrs,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        UIAlertController.report_Retrs(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Retrs(
                user_Retrs: user_Retrs,
                viewController_Retrs: viewController_Retrs
            )
            completion_Retrs?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Retrs(
        post_Retrs: TitleModel_Retrs,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        UIAlertController.report_Retrs(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Retrs(
                post_Retrs: post_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs)
        })
    }
    
    /// 举报评论
    static func report_Retrs(
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        UIAlertController.report_Retrs(with: false, completeBlock: {
            performReportComment_Retrs(
                comment_Retrs: comment_Retrs,
                post_Retrs: post_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Retrs(
        post_Retrs: TitleModel_Retrs,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Retrs(
            title_Retrs: DeleteAlertConfig_Retrs.postTitle_Retrs,
            message_Retrs: DeleteAlertConfig_Retrs.postMessage_Retrs,
            from: viewController_Retrs
        ) {
            performDeletePost_Retrs(
                post_Retrs: post_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }
    }
    
    /// 删除评论
    static func delete_Retrs(
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Retrs(
            title_Retrs: DeleteAlertConfig_Retrs.commentTitle_Retrs,
            message_Retrs: DeleteAlertConfig_Retrs.commentMessage_Retrs,
            from: viewController_Retrs
        ) {
            performDeleteComment_Retrs(
                comment_Retrs: comment_Retrs,
                post_Retrs: post_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Retrs(
        title_Retrs: String,
        message_Retrs: String,
        from viewController_Retrs: UIViewController,
        completion_Retrs: @escaping () -> Void
    ) {
        let alert_Retrs = UIAlertController(
            title: title_Retrs,
            message: message_Retrs,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Retrs = UIAlertAction(
            title: DeleteAlertConfig_Retrs.deleteButtonTitle_Retrs,
            style: .destructive
        ) { _ in
            completion_Retrs()
        }
        
        // 取消按钮
        let cancelAction_Retrs = UIAlertAction(
            title: DeleteAlertConfig_Retrs.cancelButtonTitle_Retrs,
            style: .cancel,
            handler: nil
        )
        
        alert_Retrs.addAction(deleteAction_Retrs)
        alert_Retrs.addAction(cancelAction_Retrs)
        
        viewController_Retrs.present(alert_Retrs, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Retrs(
        action_Retrs: @escaping @MainActor () -> Void,
        completion_Retrs: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Retrs * 1_000_000_000))
            
            await action_Retrs()
            
            // 确保在主线程上执行回调
            if let completion_Retrs = completion_Retrs {
                await MainActor.run {
                    completion_Retrs()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Retrs(
        user_Retrs: PrewUserModel_Retrs,
        viewController_Retrs: UIViewController
    ) {
        performAsyncAction_Retrs(action_Retrs: {
            UserViewModel_Retrs.shared_Retrs.reportUser_Retrs(user_retrs: user_Retrs)
            print("已拉黑用户: \(user_Retrs.userName_Retrs ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Retrs(
        post_Retrs: TitleModel_Retrs,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        performAsyncAction_Retrs(
            action_Retrs: {
                TitleViewModel_Retrs.shared_Retrs.deletePost_Retrs(post_retrs: post_Retrs)
                print("已举报帖子: \(post_Retrs.title_Retrs)")
            },
            completion_Retrs: completion_Retrs
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Retrs(
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        performAsyncAction_Retrs(
            action_Retrs: {
                TitleViewModel_Retrs.shared_Retrs.deleteComment_Retrs(
                    post_retrs: post_Retrs,
                    comment_retrs: comment_Retrs
                )
                print("已举报评论: \(comment_Retrs.commentContent_Retrs)")
            },
            completion_Retrs: completion_Retrs
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Retrs(
        post_Retrs: TitleModel_Retrs,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        performAsyncAction_Retrs(
            action_Retrs: {
                TitleViewModel_Retrs.shared_Retrs.deletePost_Retrs(
                    post_retrs: post_Retrs,
                    isDelete_retrs: true
                )
                print("已删除帖子: \(post_Retrs.title_Retrs)")
            },
            completion_Retrs: completion_Retrs
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Retrs(
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) {
        performAsyncAction_Retrs(
            action_Retrs: {
                TitleViewModel_Retrs.shared_Retrs.deleteComment_Retrs(
                    post_retrs: post_Retrs,
                    comment_retrs: comment_Retrs,
                    isDelete_retrs: true
                )
                print("已删除评论: \(comment_Retrs.commentContent_Retrs)")
            },
            completion_Retrs: completion_Retrs
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Retrs(
        post_Retrs: TitleModel_Retrs,
        size_Retrs: CGFloat = 25,
        color_Retrs: UIColor = .black,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) -> UIButton {
        let button_Retrs = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Retrs = UserViewModel_Retrs.shared_Retrs.isCurrentUser_Retrs(
            userId_retrs: post_Retrs.titleUserId_Retrs
        )
        
        // 配置按钮图标
        let iconName_Retrs = isMyPost_Retrs ? "trash" : "ellipsis"
        configureButtonIcon_Retrs(
            button_Retrs: button_Retrs,
            iconName_Retrs: iconName_Retrs,
            size_Retrs: size_Retrs,
            color_Retrs: color_Retrs
        )
        
        button_Retrs.addAction(UIAction { [weak viewController_Retrs] _ in
            guard let viewController_Retrs = viewController_Retrs else { return }
            handlePostButtonTap_Retrs(
                button_Retrs: button_Retrs,
                post_Retrs: post_Retrs,
                isMyPost_Retrs: isMyPost_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }, for: .touchUpInside)
        
        return button_Retrs
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Retrs(
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        size_Retrs: CGFloat = 25,
        color_Retrs: UIColor = .black,
        from viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)? = nil
    ) -> UIButton {
        let button_Retrs = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Retrs = UserViewModel_Retrs.shared_Retrs.isCurrentUser_Retrs(
            userId_retrs: comment_Retrs.commentUserId_Retrs
        )
        
        // 配置按钮图标
        let iconName_Retrs = isMyComment_Retrs ? "trash" : "ellipsis"
        configureButtonIcon_Retrs(
            button_Retrs: button_Retrs,
            iconName_Retrs: iconName_Retrs,
            size_Retrs: size_Retrs,
            color_Retrs: color_Retrs
        )
        
        button_Retrs.addAction(UIAction { [weak viewController_Retrs] _ in
            guard let viewController_Retrs = viewController_Retrs else { return }
            handleCommentButtonTap_Retrs(
                button_Retrs: button_Retrs,
                comment_Retrs: comment_Retrs,
                post_Retrs: post_Retrs,
                isMyComment_Retrs: isMyComment_Retrs,
                viewController_Retrs: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }, for: .touchUpInside)
        
        return button_Retrs
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Retrs(
        size_Retrs: CGFloat = 44,
        backgroundColor_Retrs: UIColor? = nil,
        tintColor_Retrs: UIColor = .white,
        withShadow_Retrs: Bool = false
    ) -> UIButton {
        let button_Retrs = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Retrs = size_Retrs * 0.5
        let config_Retrs = UIImage.SymbolConfiguration(pointSize: iconSize_Retrs, weight: .semibold)
        let image_Retrs = UIImage(systemName: "ellipsis", withConfiguration: config_Retrs)
        button_Retrs.setImage(image_Retrs, for: .normal)
        button_Retrs.tintColor = tintColor_Retrs
        
        // 设置背景
        let bgColor_Retrs = backgroundColor_Retrs ?? UIColor.white.withAlphaComponent(0.2)
        button_Retrs.backgroundColor = bgColor_Retrs
        button_Retrs.layer.cornerRadius = size_Retrs / 2
        
        // 添加阴影
        if withShadow_Retrs {
            button_Retrs.layer.shadowColor = UIColor.black.cgColor
            button_Retrs.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Retrs.layer.shadowOpacity = 0.15
            button_Retrs.layer.shadowRadius = 8
        }
        
        return button_Retrs
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Retrs(button_Retrs: UIButton) {
        UIView.animate(withDuration: animationDuration_Retrs, animations: {
            button_Retrs.transform = CGAffineTransform(
                scaleX: animationScale_Retrs,
                y: animationScale_Retrs
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Retrs) {
                button_Retrs.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Retrs(
        button_Retrs: UIButton,
        iconName_Retrs: String,
        size_Retrs: CGFloat,
        color_Retrs: UIColor
    ) {
        let config_Retrs = UIImage.SymbolConfiguration(pointSize: size_Retrs, weight: .semibold)
        let image_Retrs = UIImage(systemName: iconName_Retrs, withConfiguration: config_Retrs)
        button_Retrs.setImage(image_Retrs, for: .normal)
        button_Retrs.tintColor = color_Retrs
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Retrs(
        button_Retrs: UIButton,
        post_Retrs: TitleModel_Retrs,
        isMyPost_Retrs: Bool,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)?
    ) {
        addButtonAnimation_Retrs(button_Retrs: button_Retrs)
        
        if isMyPost_Retrs {
            delete_Retrs(
                post_Retrs: post_Retrs,
                from: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        } else {
            report_Retrs(
                post_Retrs: post_Retrs,
                from: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Retrs(
        button_Retrs: UIButton,
        comment_Retrs: Comment_Retrs,
        post_Retrs: TitleModel_Retrs,
        isMyComment_Retrs: Bool,
        viewController_Retrs: UIViewController,
        completion_Retrs: (() -> Void)?
    ) {
        addButtonAnimation_Retrs(button_Retrs: button_Retrs)
        
        if isMyComment_Retrs {
            delete_Retrs(
                comment_Retrs: comment_Retrs,
                post_Retrs: post_Retrs,
                from: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        } else {
            report_Retrs(
                comment_Retrs: comment_Retrs,
                post_Retrs: post_Retrs,
                from: viewController_Retrs,
                completion_Retrs: completion_Retrs
            )
        }
    }
}
