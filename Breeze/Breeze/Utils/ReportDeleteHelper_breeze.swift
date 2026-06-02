import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Breeze {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Breeze: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Breeze: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Breeze: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Breeze {
        static let postTitle_Breeze = "Delete Post"
        static let postMessage_Breeze = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Breeze = "Delete Comment"
        static let commentMessage_Breeze = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Breeze = "Delete"
        static let cancelButtonTitle_Breeze = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Breeze {
        case block_Breeze       // 拉黑用户
        case post_Breeze        // 举报帖子
        case comment_Breeze     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Breeze(
        user_Breeze: PrewUserModel_Breeze,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Breeze(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Breeze(
                user_Breeze: user_Breeze,
                viewController_Breeze: viewController_Breeze
            )
            completion_Breeze?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Breeze(
        post_Breeze: TitleModel_Breeze,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Breeze(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Breeze(
                post_Breeze: post_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze)
        })
    }
    
    /// 举报评论
    static func report_Breeze(
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Breeze(with: false, completeBlock: {
            performReportComment_Breeze(
                comment_Breeze: comment_Breeze,
                post_Breeze: post_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Breeze(
        post_Breeze: TitleModel_Breeze,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Breeze(
            title_Breeze: DeleteAlertConfig_Breeze.postTitle_Breeze,
            message_Breeze: DeleteAlertConfig_Breeze.postMessage_Breeze,
            from: viewController_Breeze
        ) {
            performDeletePost_Breeze(
                post_Breeze: post_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }
    }
    
    /// 删除评论
    static func delete_Breeze(
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Breeze(
            title_Breeze: DeleteAlertConfig_Breeze.commentTitle_Breeze,
            message_Breeze: DeleteAlertConfig_Breeze.commentMessage_Breeze,
            from: viewController_Breeze
        ) {
            performDeleteComment_Breeze(
                comment_Breeze: comment_Breeze,
                post_Breeze: post_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Breeze(
        title_Breeze: String,
        message_Breeze: String,
        from viewController_Breeze: UIViewController,
        completion_Breeze: @escaping () -> Void
    ) {
        let alert_Breeze = UIAlertController(
            title: title_Breeze,
            message: message_Breeze,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Breeze = UIAlertAction(
            title: DeleteAlertConfig_Breeze.deleteButtonTitle_Breeze,
            style: .destructive
        ) { _ in
            completion_Breeze()
        }
        
        // 取消按钮
        let cancelAction_Breeze = UIAlertAction(
            title: DeleteAlertConfig_Breeze.cancelButtonTitle_Breeze,
            style: .cancel,
            handler: nil
        )
        
        alert_Breeze.addAction(deleteAction_Breeze)
        alert_Breeze.addAction(cancelAction_Breeze)
        
        viewController_Breeze.present(alert_Breeze, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Breeze(
        action_Breeze: @escaping @MainActor () -> Void,
        completion_Breeze: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Breeze * 1_000_000_000))
            
            await action_Breeze()
            
            // 确保在主线程上执行回调
            if let completion_Breeze = completion_Breeze {
                await MainActor.run {
                    completion_Breeze()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Breeze(
        user_Breeze: PrewUserModel_Breeze,
        viewController_Breeze: UIViewController
    ) {
        performAsyncAction_Breeze(action_Breeze: {
            UserViewModel_Breeze.shared_Breeze.reportUser_Breeze(user_breeze: user_Breeze)
            print("已拉黑用户: \(user_Breeze.userName_Breeze ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Breeze(
        post_Breeze: TitleModel_Breeze,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        performAsyncAction_Breeze(
            action_Breeze: {
                TitleViewModel_Breeze.shared_Breeze.deletePost_Breeze(post_breeze: post_Breeze)
                print("已举报帖子: \(post_Breeze.title_Breeze)")
            },
            completion_Breeze: completion_Breeze
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Breeze(
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        performAsyncAction_Breeze(
            action_Breeze: {
                TitleViewModel_Breeze.shared_Breeze.deleteComment_Breeze(
                    post_breeze: post_Breeze,
                    comment_breeze: comment_Breeze
                )
                print("已举报评论: \(comment_Breeze.commentContent_Breeze)")
            },
            completion_Breeze: completion_Breeze
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Breeze(
        post_Breeze: TitleModel_Breeze,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        performAsyncAction_Breeze(
            action_Breeze: {
                TitleViewModel_Breeze.shared_Breeze.deletePost_Breeze(
                    post_breeze: post_Breeze,
                    isDelete_breeze: true
                )
                print("已删除帖子: \(post_Breeze.title_Breeze)")
            },
            completion_Breeze: completion_Breeze
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Breeze(
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) {
        performAsyncAction_Breeze(
            action_Breeze: {
                TitleViewModel_Breeze.shared_Breeze.deleteComment_Breeze(
                    post_breeze: post_Breeze,
                    comment_breeze: comment_Breeze,
                    isDelete_breeze: true
                )
                print("已删除评论: \(comment_Breeze.commentContent_Breeze)")
            },
            completion_Breeze: completion_Breeze
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Breeze(
        post_Breeze: TitleModel_Breeze,
        size_Breeze: CGFloat = 25,
        color_Breeze: UIColor = .black,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) -> UIButton {
        let button_Breeze = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Breeze = UserViewModel_Breeze.shared_Breeze.isCurrentUser_Breeze(
            userId_breeze: post_Breeze.titleUserId_Breeze
        )
        
        // 配置按钮图标
        let iconName_Breeze = isMyPost_Breeze ? "trash" : "ellipsis"
        configureButtonIcon_Breeze(
            button_Breeze: button_Breeze,
            iconName_Breeze: iconName_Breeze,
            size_Breeze: size_Breeze,
            color_Breeze: color_Breeze
        )
        
        button_Breeze.addAction(UIAction { [weak viewController_Breeze] _ in
            guard let viewController_Breeze = viewController_Breeze else { return }
            handlePostButtonTap_Breeze(
                button_Breeze: button_Breeze,
                post_Breeze: post_Breeze,
                isMyPost_Breeze: isMyPost_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }, for: .touchUpInside)
        
        return button_Breeze
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Breeze(
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        size_Breeze: CGFloat = 25,
        color_Breeze: UIColor = .black,
        from viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)? = nil
    ) -> UIButton {
        let button_Breeze = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Breeze = UserViewModel_Breeze.shared_Breeze.isCurrentUser_Breeze(
            userId_breeze: comment_Breeze.commentUserId_Breeze
        )
        
        // 配置按钮图标
        let iconName_Breeze = isMyComment_Breeze ? "trash" : "ellipsis"
        configureButtonIcon_Breeze(
            button_Breeze: button_Breeze,
            iconName_Breeze: iconName_Breeze,
            size_Breeze: size_Breeze,
            color_Breeze: color_Breeze
        )
        
        button_Breeze.addAction(UIAction { [weak viewController_Breeze] _ in
            guard let viewController_Breeze = viewController_Breeze else { return }
            handleCommentButtonTap_Breeze(
                button_Breeze: button_Breeze,
                comment_Breeze: comment_Breeze,
                post_Breeze: post_Breeze,
                isMyComment_Breeze: isMyComment_Breeze,
                viewController_Breeze: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }, for: .touchUpInside)
        
        return button_Breeze
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Breeze(
        size_Breeze: CGFloat = 44,
        backgroundColor_Breeze: UIColor? = nil,
        tintColor_Breeze: UIColor = .white,
        withShadow_Breeze: Bool = false
    ) -> UIButton {
        let button_Breeze = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Breeze = size_Breeze * 0.5
        let config_Breeze = UIImage.SymbolConfiguration(pointSize: iconSize_Breeze, weight: .semibold)
        let image_Breeze = UIImage(systemName: "ellipsis", withConfiguration: config_Breeze)
        button_Breeze.setImage(image_Breeze, for: .normal)
        button_Breeze.tintColor = tintColor_Breeze
        
        // 设置背景
        let bgColor_Breeze = backgroundColor_Breeze ?? UIColor.white.withAlphaComponent(0.2)
        button_Breeze.backgroundColor = bgColor_Breeze
        button_Breeze.layer.cornerRadius = size_Breeze / 2
        
        // 添加阴影
        if withShadow_Breeze {
            button_Breeze.layer.shadowColor = UIColor.black.cgColor
            button_Breeze.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Breeze.layer.shadowOpacity = 0.15
            button_Breeze.layer.shadowRadius = 8
        }
        
        return button_Breeze
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Breeze(button_Breeze: UIButton) {
        UIView.animate(withDuration: animationDuration_Breeze, animations: {
            button_Breeze.transform = CGAffineTransform(
                scaleX: animationScale_Breeze,
                y: animationScale_Breeze
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Breeze) {
                button_Breeze.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Breeze(
        button_Breeze: UIButton,
        iconName_Breeze: String,
        size_Breeze: CGFloat,
        color_Breeze: UIColor
    ) {
        let config_Breeze = UIImage.SymbolConfiguration(pointSize: size_Breeze, weight: .semibold)
        let image_Breeze = UIImage(systemName: iconName_Breeze, withConfiguration: config_Breeze)
        button_Breeze.setImage(image_Breeze, for: .normal)
        button_Breeze.tintColor = color_Breeze
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Breeze(
        button_Breeze: UIButton,
        post_Breeze: TitleModel_Breeze,
        isMyPost_Breeze: Bool,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)?
    ) {
        addButtonAnimation_Breeze(button_Breeze: button_Breeze)
        
        if isMyPost_Breeze {
            delete_Breeze(
                post_Breeze: post_Breeze,
                from: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        } else {
            report_Breeze(
                post_Breeze: post_Breeze,
                from: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Breeze(
        button_Breeze: UIButton,
        comment_Breeze: Comment_Breeze,
        post_Breeze: TitleModel_Breeze,
        isMyComment_Breeze: Bool,
        viewController_Breeze: UIViewController,
        completion_Breeze: (() -> Void)?
    ) {
        addButtonAnimation_Breeze(button_Breeze: button_Breeze)
        
        if isMyComment_Breeze {
            delete_Breeze(
                comment_Breeze: comment_Breeze,
                post_Breeze: post_Breeze,
                from: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        } else {
            report_Breeze(
                comment_Breeze: comment_Breeze,
                post_Breeze: post_Breeze,
                from: viewController_Breeze,
                completion_Breeze: completion_Breeze
            )
        }
    }
}
