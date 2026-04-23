import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Nest {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Nest: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Nest: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Nest: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Nest {
        static let postTitle_Nest = "Delete Post"
        static let postMessage_Nest = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Nest = "Delete Comment"
        static let commentMessage_Nest = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Nest = "Delete"
        static let cancelButtonTitle_Nest = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Nest {
        case block_Nest       // 拉黑用户
        case post_Nest        // 举报帖子
        case comment_Nest     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Nest(
        user_Nest: PrewUserModel_Nest,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        UIAlertController.report_Nest(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Nest(
                user_Nest: user_Nest,
                viewController_Nest: viewController_Nest
            )
            completion_Nest?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Nest(
        post_Nest: TitleModel_Nest,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        UIAlertController.report_Nest(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Nest(
                post_Nest: post_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest)
        })
    }
    
    /// 举报评论
    static func report_Nest(
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        UIAlertController.report_Nest(with: false, completeBlock: {
            performReportComment_Nest(
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Nest(
        post_Nest: TitleModel_Nest,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Nest(
            title_Nest: DeleteAlertConfig_Nest.postTitle_Nest,
            message_Nest: DeleteAlertConfig_Nest.postMessage_Nest,
            from: viewController_Nest
        ) {
            performDeletePost_Nest(
                post_Nest: post_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }
    }
    
    /// 删除评论
    static func delete_Nest(
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Nest(
            title_Nest: DeleteAlertConfig_Nest.commentTitle_Nest,
            message_Nest: DeleteAlertConfig_Nest.commentMessage_Nest,
            from: viewController_Nest
        ) {
            performDeleteComment_Nest(
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Nest(
        title_Nest: String,
        message_Nest: String,
        from viewController_Nest: UIViewController,
        completion_Nest: @escaping () -> Void
    ) {
        let alert_Nest = UIAlertController(
            title: title_Nest,
            message: message_Nest,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Nest = UIAlertAction(
            title: DeleteAlertConfig_Nest.deleteButtonTitle_Nest,
            style: .destructive
        ) { _ in
            completion_Nest()
        }
        
        // 取消按钮
        let cancelAction_Nest = UIAlertAction(
            title: DeleteAlertConfig_Nest.cancelButtonTitle_Nest,
            style: .cancel,
            handler: nil
        )
        
        alert_Nest.addAction(deleteAction_Nest)
        alert_Nest.addAction(cancelAction_Nest)
        
        viewController_Nest.present(alert_Nest, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Nest(
        action_Nest: @escaping @MainActor () -> Void,
        completion_Nest: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Nest * 1_000_000_000))
            
            await action_Nest()
            
            // 确保在主线程上执行回调
            if let completion_Nest = completion_Nest {
                await MainActor.run {
                    completion_Nest()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Nest(
        user_Nest: PrewUserModel_Nest,
        viewController_Nest: UIViewController
    ) {
        performAsyncAction_Nest(action_Nest: {
            UserViewModel_Nest.shared_Nest.reportUser_Nest(user_nest: user_Nest)
            print("已拉黑用户: \(user_Nest.userName_Nest ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Nest(
        post_Nest: TitleModel_Nest,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        performAsyncAction_Nest(
            action_Nest: {
                TitleViewModel_Nest.shared_Nest.deletePost_Nest(post_nest: post_Nest)
                print("已举报帖子: \(post_Nest.title_Nest)")
            },
            completion_Nest: completion_Nest
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Nest(
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        performAsyncAction_Nest(
            action_Nest: {
                TitleViewModel_Nest.shared_Nest.deleteComment_Nest(
                    post_nest: post_Nest,
                    comment_nest: comment_Nest
                )
                print("已举报评论: \(comment_Nest.commentContent_Nest)")
            },
            completion_Nest: completion_Nest
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Nest(
        post_Nest: TitleModel_Nest,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        performAsyncAction_Nest(
            action_Nest: {
                TitleViewModel_Nest.shared_Nest.deletePost_Nest(
                    post_nest: post_Nest,
                    isDelete_nest: true
                )
                print("已删除帖子: \(post_Nest.title_Nest)")
            },
            completion_Nest: completion_Nest
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Nest(
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) {
        performAsyncAction_Nest(
            action_Nest: {
                TitleViewModel_Nest.shared_Nest.deleteComment_Nest(
                    post_nest: post_Nest,
                    comment_nest: comment_Nest,
                    isDelete_nest: true
                )
                print("已删除评论: \(comment_Nest.commentContent_Nest)")
            },
            completion_Nest: completion_Nest
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Nest(
        post_Nest: TitleModel_Nest,
        size_Nest: CGFloat = 25,
        color_Nest: UIColor = .black,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) -> UIButton {
        let button_Nest = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Nest = UserViewModel_Nest.shared_Nest.isCurrentUser_Nest(
            userId_nest: post_Nest.titleUserId_Nest
        )
        
        // 配置按钮图标
        let iconName_Nest = isMyPost_Nest ? "trash" : "ellipsis"
        configureButtonIcon_Nest(
            button_Nest: button_Nest,
            iconName_Nest: iconName_Nest,
            size_Nest: size_Nest,
            color_Nest: color_Nest
        )
        
        button_Nest.addAction(UIAction { [weak viewController_Nest] _ in
            guard let viewController_Nest = viewController_Nest else { return }
            handlePostButtonTap_Nest(
                button_Nest: button_Nest,
                post_Nest: post_Nest,
                isMyPost_Nest: isMyPost_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }, for: .touchUpInside)
        
        return button_Nest
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Nest(
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        size_Nest: CGFloat = 25,
        color_Nest: UIColor = .black,
        from viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)? = nil
    ) -> UIButton {
        let button_Nest = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Nest = UserViewModel_Nest.shared_Nest.isCurrentUser_Nest(
            userId_nest: comment_Nest.commentUserId_Nest
        )
        
        // 配置按钮图标
        let iconName_Nest = isMyComment_Nest ? "trash" : "ellipsis"
        configureButtonIcon_Nest(
            button_Nest: button_Nest,
            iconName_Nest: iconName_Nest,
            size_Nest: size_Nest,
            color_Nest: color_Nest
        )
        
        button_Nest.addAction(UIAction { [weak viewController_Nest] _ in
            guard let viewController_Nest = viewController_Nest else { return }
            handleCommentButtonTap_Nest(
                button_Nest: button_Nest,
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                isMyComment_Nest: isMyComment_Nest,
                viewController_Nest: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }, for: .touchUpInside)
        
        return button_Nest
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Nest(
        size_Nest: CGFloat = 44,
        backgroundColor_Nest: UIColor? = nil,
        tintColor_Nest: UIColor = .white,
        withShadow_Nest: Bool = false
    ) -> UIButton {
        let button_Nest = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Nest = size_Nest * 0.5
        let config_Nest = UIImage.SymbolConfiguration(pointSize: iconSize_Nest, weight: .semibold)
        let image_Nest = UIImage(systemName: "ellipsis", withConfiguration: config_Nest)
        button_Nest.setImage(image_Nest, for: .normal)
        button_Nest.tintColor = tintColor_Nest
        
        // 设置背景
        let bgColor_Nest = backgroundColor_Nest ?? UIColor.white.withAlphaComponent(0.2)
        button_Nest.backgroundColor = bgColor_Nest
        button_Nest.layer.cornerRadius = size_Nest / 2
        
        // 添加阴影
        if withShadow_Nest {
            button_Nest.layer.shadowColor = UIColor.black.cgColor
            button_Nest.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Nest.layer.shadowOpacity = 0.15
            button_Nest.layer.shadowRadius = 8
        }
        
        return button_Nest
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Nest(button_Nest: UIButton) {
        UIView.animate(withDuration: animationDuration_Nest, animations: {
            button_Nest.transform = CGAffineTransform(
                scaleX: animationScale_Nest,
                y: animationScale_Nest
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Nest) {
                button_Nest.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Nest(
        button_Nest: UIButton,
        iconName_Nest: String,
        size_Nest: CGFloat,
        color_Nest: UIColor
    ) {
        let config_Nest = UIImage.SymbolConfiguration(pointSize: size_Nest, weight: .semibold)
        let image_Nest = UIImage(systemName: iconName_Nest, withConfiguration: config_Nest)
        button_Nest.setImage(image_Nest, for: .normal)
        button_Nest.tintColor = color_Nest
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Nest(
        button_Nest: UIButton,
        post_Nest: TitleModel_Nest,
        isMyPost_Nest: Bool,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)?
    ) {
        addButtonAnimation_Nest(button_Nest: button_Nest)
        
        if isMyPost_Nest {
            delete_Nest(
                post_Nest: post_Nest,
                from: viewController_Nest,
                completion_Nest: completion_Nest
            )
        } else {
            report_Nest(
                post_Nest: post_Nest,
                from: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Nest(
        button_Nest: UIButton,
        comment_Nest: Comment_Nest,
        post_Nest: TitleModel_Nest,
        isMyComment_Nest: Bool,
        viewController_Nest: UIViewController,
        completion_Nest: (() -> Void)?
    ) {
        addButtonAnimation_Nest(button_Nest: button_Nest)
        
        if isMyComment_Nest {
            delete_Nest(
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                from: viewController_Nest,
                completion_Nest: completion_Nest
            )
        } else {
            report_Nest(
                comment_Nest: comment_Nest,
                post_Nest: post_Nest,
                from: viewController_Nest,
                completion_Nest: completion_Nest
            )
        }
    }
}
