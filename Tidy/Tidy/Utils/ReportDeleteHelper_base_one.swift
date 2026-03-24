import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Base_one {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Base_one: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Base_one: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Base_one: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Base_one {
        static let postTitle_Base_one = "Delete Post"
        static let postMessage_Base_one = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Base_one = "Delete Comment"
        static let commentMessage_Base_one = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Base_one = "Delete"
        static let cancelButtonTitle_Base_one = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Base_one {
        case block_Base_one       // 拉黑用户
        case post_Base_one        // 举报帖子
        case comment_Base_one     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Base_one(
        user_Base_one: PrewUserModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Base_one(
                user_Base_one: user_Base_one,
                viewController_Base_one: viewController_Base_one
            )
            completion_Base_one?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Base_one(
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Base_one(
                post_Base_one: post_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one)
        })
    }
    
    /// 举报评论
    static func report_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        UIAlertController.report_Base_one(with: false, completeBlock: {
            performReportComment_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Base_one(
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Base_one(
            title_Base_one: DeleteAlertConfig_Base_one.postTitle_Base_one,
            message_Base_one: DeleteAlertConfig_Base_one.postMessage_Base_one,
            from: viewController_Base_one
        ) {
            performDeletePost_Base_one(
                post_Base_one: post_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }
    }
    
    /// 删除评论
    static func delete_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Base_one(
            title_Base_one: DeleteAlertConfig_Base_one.commentTitle_Base_one,
            message_Base_one: DeleteAlertConfig_Base_one.commentMessage_Base_one,
            from: viewController_Base_one
        ) {
            performDeleteComment_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Base_one(
        title_Base_one: String,
        message_Base_one: String,
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping () -> Void
    ) {
        let alert_Base_one = UIAlertController(
            title: title_Base_one,
            message: message_Base_one,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Base_one = UIAlertAction(
            title: DeleteAlertConfig_Base_one.deleteButtonTitle_Base_one,
            style: .destructive
        ) { _ in
            completion_Base_one()
        }
        
        // 取消按钮
        let cancelAction_Base_one = UIAlertAction(
            title: DeleteAlertConfig_Base_one.cancelButtonTitle_Base_one,
            style: .cancel,
            handler: nil
        )
        
        alert_Base_one.addAction(deleteAction_Base_one)
        alert_Base_one.addAction(cancelAction_Base_one)
        
        viewController_Base_one.present(alert_Base_one, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Base_one(
        action_Base_one: @escaping @MainActor () -> Void,
        completion_Base_one: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Base_one * 1_000_000_000))
            
            await action_Base_one()
            
            // 确保在主线程上执行回调
            if let completion_Base_one = completion_Base_one {
                await MainActor.run {
                    completion_Base_one()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Base_one(
        user_Base_one: PrewUserModel_Base_one,
        viewController_Base_one: UIViewController
    ) {
        performAsyncAction_Base_one(action_Base_one: {
            UserViewModel_Base_one.shared_Base_one.reportUser_Base_one(user_base_one: user_Base_one)
            print("已拉黑用户: \(user_Base_one.userName_Base_one ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Base_one(
        post_Base_one: TitleModel_Base_one,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(
            action_Base_one: {
                TitleViewModel_Base_one.shared_Base_one.deletePost_Base_one(post_base_one: post_Base_one)
                print("已举报帖子: \(post_Base_one.title_Base_one)")
            },
            completion_Base_one: completion_Base_one
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(
            action_Base_one: {
                TitleViewModel_Base_one.shared_Base_one.deleteComment_Base_one(
                    post_base_one: post_Base_one,
                    comment_base_one: comment_Base_one
                )
                print("已举报评论: \(comment_Base_one.commentContent_Base_one)")
            },
            completion_Base_one: completion_Base_one
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Base_one(
        post_Base_one: TitleModel_Base_one,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(
            action_Base_one: {
                TitleViewModel_Base_one.shared_Base_one.deletePost_Base_one(
                    post_base_one: post_Base_one,
                    isDelete_base_one: true
                )
                print("已删除帖子: \(post_Base_one.title_Base_one)")
            },
            completion_Base_one: completion_Base_one
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) {
        performAsyncAction_Base_one(
            action_Base_one: {
                TitleViewModel_Base_one.shared_Base_one.deleteComment_Base_one(
                    post_base_one: post_Base_one,
                    comment_base_one: comment_Base_one,
                    isDelete_base_one: true
                )
                print("已删除评论: \(comment_Base_one.commentContent_Base_one)")
            },
            completion_Base_one: completion_Base_one
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Base_one(
        post_Base_one: TitleModel_Base_one,
        size_Base_one: CGFloat = 25,
        color_Base_one: UIColor = .black,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post_Base_one.titleUserId_Base_one
        )
        
        // 配置按钮图标
        let iconName_Base_one = isMyPost_Base_one ? "trash" : "ellipsis"
        configureButtonIcon_Base_one(
            button_Base_one: button_Base_one,
            iconName_Base_one: iconName_Base_one,
            size_Base_one: size_Base_one,
            color_Base_one: color_Base_one
        )
        
        button_Base_one.addAction(UIAction { [weak viewController_Base_one] _ in
            guard let viewController_Base_one = viewController_Base_one else { return }
            handlePostButtonTap_Base_one(
                button_Base_one: button_Base_one,
                post_Base_one: post_Base_one,
                isMyPost_Base_one: isMyPost_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }, for: .touchUpInside)
        
        return button_Base_one
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Base_one(
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        size_Base_one: CGFloat = 25,
        color_Base_one: UIColor = .black,
        from viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)? = nil
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Base_one = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: comment_Base_one.commentUserId_Base_one
        )
        
        // 配置按钮图标
        let iconName_Base_one = isMyComment_Base_one ? "trash" : "ellipsis"
        configureButtonIcon_Base_one(
            button_Base_one: button_Base_one,
            iconName_Base_one: iconName_Base_one,
            size_Base_one: size_Base_one,
            color_Base_one: color_Base_one
        )
        
        button_Base_one.addAction(UIAction { [weak viewController_Base_one] _ in
            guard let viewController_Base_one = viewController_Base_one else { return }
            handleCommentButtonTap_Base_one(
                button_Base_one: button_Base_one,
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                isMyComment_Base_one: isMyComment_Base_one,
                viewController_Base_one: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }, for: .touchUpInside)
        
        return button_Base_one
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Base_one(
        size_Base_one: CGFloat = 44,
        backgroundColor_Base_one: UIColor? = nil,
        tintColor_Base_one: UIColor = .white,
        withShadow_Base_one: Bool = false
    ) -> UIButton {
        let button_Base_one = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Base_one = size_Base_one * 0.5
        let config_Base_one = UIImage.SymbolConfiguration(pointSize: iconSize_Base_one, weight: .semibold)
        let image_Base_one = UIImage(systemName: "ellipsis", withConfiguration: config_Base_one)
        button_Base_one.setImage(image_Base_one, for: .normal)
        button_Base_one.tintColor = tintColor_Base_one
        
        // 设置背景
        let bgColor_Base_one = backgroundColor_Base_one ?? UIColor.white.withAlphaComponent(0.2)
        button_Base_one.backgroundColor = bgColor_Base_one
        button_Base_one.layer.cornerRadius = size_Base_one / 2
        
        // 添加阴影
        if withShadow_Base_one {
            button_Base_one.layer.shadowColor = UIColor.black.cgColor
            button_Base_one.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Base_one.layer.shadowOpacity = 0.15
            button_Base_one.layer.shadowRadius = 8
        }
        
        return button_Base_one
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Base_one(button_Base_one: UIButton) {
        UIView.animate(withDuration: animationDuration_Base_one, animations: {
            button_Base_one.transform = CGAffineTransform(
                scaleX: animationScale_Base_one,
                y: animationScale_Base_one
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Base_one) {
                button_Base_one.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Base_one(
        button_Base_one: UIButton,
        iconName_Base_one: String,
        size_Base_one: CGFloat,
        color_Base_one: UIColor
    ) {
        let config_Base_one = UIImage.SymbolConfiguration(pointSize: size_Base_one, weight: .semibold)
        let image_Base_one = UIImage(systemName: iconName_Base_one, withConfiguration: config_Base_one)
        button_Base_one.setImage(image_Base_one, for: .normal)
        button_Base_one.tintColor = color_Base_one
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Base_one(
        button_Base_one: UIButton,
        post_Base_one: TitleModel_Base_one,
        isMyPost_Base_one: Bool,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)?
    ) {
        addButtonAnimation_Base_one(button_Base_one: button_Base_one)
        
        if isMyPost_Base_one {
            delete_Base_one(
                post_Base_one: post_Base_one,
                from: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        } else {
            report_Base_one(
                post_Base_one: post_Base_one,
                from: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Base_one(
        button_Base_one: UIButton,
        comment_Base_one: Comment_Base_one,
        post_Base_one: TitleModel_Base_one,
        isMyComment_Base_one: Bool,
        viewController_Base_one: UIViewController,
        completion_Base_one: (() -> Void)?
    ) {
        addButtonAnimation_Base_one(button_Base_one: button_Base_one)
        
        if isMyComment_Base_one {
            delete_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                from: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        } else {
            report_Base_one(
                comment_Base_one: comment_Base_one,
                post_Base_one: post_Base_one,
                from: viewController_Base_one,
                completion_Base_one: completion_Base_one
            )
        }
    }
}
