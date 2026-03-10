import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Doze {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Doze: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Doze: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Doze: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Doze {
        static let postTitle_Doze = "Delete Post"
        static let postMessage_Doze = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Doze = "Delete Comment"
        static let commentMessage_Doze = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Doze = "Delete"
        static let cancelButtonTitle_Doze = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Doze {
        case block_Doze       // 拉黑用户
        case post_Doze        // 举报帖子
        case comment_Doze     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Doze(
        user_Doze: PrewUserModel_Doze,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Doze(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Doze(
                user_Doze: user_Doze,
                viewController_Doze: viewController_Doze
            )
            completion_Doze?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Doze(
        post_Doze: TitleModel_Doze,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Doze(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Doze(
                post_Doze: post_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze)
        })
    }
    
    /// 举报评论
    static func report_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        UIAlertController.report_Doze(with: false, completeBlock: {
            performReportComment_Doze(
                comment_Doze: comment_Doze,
                post_Doze: post_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Doze(
        post_Doze: TitleModel_Doze,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Doze(
            title_Doze: DeleteAlertConfig_Doze.postTitle_Doze,
            message_Doze: DeleteAlertConfig_Doze.postMessage_Doze,
            from: viewController_Doze
        ) {
            performDeletePost_Doze(
                post_Doze: post_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }
    }
    
    /// 删除评论
    static func delete_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Doze(
            title_Doze: DeleteAlertConfig_Doze.commentTitle_Doze,
            message_Doze: DeleteAlertConfig_Doze.commentMessage_Doze,
            from: viewController_Doze
        ) {
            performDeleteComment_Doze(
                comment_Doze: comment_Doze,
                post_Doze: post_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Doze(
        title_Doze: String,
        message_Doze: String,
        from viewController_Doze: UIViewController,
        completion_Doze: @escaping () -> Void
    ) {
        let alert_Doze = UIAlertController(
            title: title_Doze,
            message: message_Doze,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Doze = UIAlertAction(
            title: DeleteAlertConfig_Doze.deleteButtonTitle_Doze,
            style: .destructive
        ) { _ in
            completion_Doze()
        }
        
        // 取消按钮
        let cancelAction_Doze = UIAlertAction(
            title: DeleteAlertConfig_Doze.cancelButtonTitle_Doze,
            style: .cancel,
            handler: nil
        )
        
        alert_Doze.addAction(deleteAction_Doze)
        alert_Doze.addAction(cancelAction_Doze)
        
        viewController_Doze.present(alert_Doze, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Doze(
        action_Doze: @escaping @MainActor () -> Void,
        completion_Doze: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Doze * 1_000_000_000))
            
            await action_Doze()
            
            // 确保在主线程上执行回调
            if let completion_Doze = completion_Doze {
                await MainActor.run {
                    completion_Doze()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Doze(
        user_Doze: PrewUserModel_Doze,
        viewController_Doze: UIViewController
    ) {
        performAsyncAction_Doze(action_Doze: {
            UserViewModel_Doze.shared_Doze.reportUser_Doze(user_doze: user_Doze)
            print("已拉黑用户: \(user_Doze.userName_Doze ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Doze(
        post_Doze: TitleModel_Doze,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        performAsyncAction_Doze(
            action_Doze: {
                TitleViewModel_Doze.shared_Doze.deletePost_Doze(post_doze: post_Doze)
                print("已举报帖子: \(post_Doze.title_Doze)")
            },
            completion_Doze: completion_Doze
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        performAsyncAction_Doze(
            action_Doze: {
                TitleViewModel_Doze.shared_Doze.deleteComment_Doze(
                    post_doze: post_Doze,
                    comment_doze: comment_Doze
                )
                print("已举报评论: \(comment_Doze.commentContent_Doze)")
            },
            completion_Doze: completion_Doze
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Doze(
        post_Doze: TitleModel_Doze,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        performAsyncAction_Doze(
            action_Doze: {
                TitleViewModel_Doze.shared_Doze.deletePost_Doze(
                    post_doze: post_Doze,
                    isDelete_doze: true
                )
                print("已删除帖子: \(post_Doze.title_Doze)")
            },
            completion_Doze: completion_Doze
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) {
        performAsyncAction_Doze(
            action_Doze: {
                TitleViewModel_Doze.shared_Doze.deleteComment_Doze(
                    post_doze: post_Doze,
                    comment_doze: comment_Doze,
                    isDelete_doze: true
                )
                print("已删除评论: \(comment_Doze.commentContent_Doze)")
            },
            completion_Doze: completion_Doze
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Doze(
        post_Doze: TitleModel_Doze,
        size_Doze: CGFloat = 25,
        color_Doze: UIColor = .black,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) -> UIButton {
        let button_Doze = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Doze = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(
            userId_doze: post_Doze.titleUserId_Doze
        )
        
        // 配置按钮图标
        let iconName_Doze = isMyPost_Doze ? "trash" : "ellipsis"
        configureButtonIcon_Doze(
            button_Doze: button_Doze,
            iconName_Doze: iconName_Doze,
            size_Doze: size_Doze,
            color_Doze: color_Doze
        )
        
        button_Doze.addAction(UIAction { [weak viewController_Doze] _ in
            guard let viewController_Doze = viewController_Doze else { return }
            handlePostButtonTap_Doze(
                button_Doze: button_Doze,
                post_Doze: post_Doze,
                isMyPost_Doze: isMyPost_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }, for: .touchUpInside)
        
        return button_Doze
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Doze(
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        size_Doze: CGFloat = 25,
        color_Doze: UIColor = .black,
        from viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)? = nil
    ) -> UIButton {
        let button_Doze = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Doze = UserViewModel_Doze.shared_Doze.isCurrentUser_Doze(
            userId_doze: comment_Doze.commentUserId_Doze
        )
        
        // 配置按钮图标
        let iconName_Doze = isMyComment_Doze ? "trash" : "ellipsis"
        configureButtonIcon_Doze(
            button_Doze: button_Doze,
            iconName_Doze: iconName_Doze,
            size_Doze: size_Doze,
            color_Doze: color_Doze
        )
        
        button_Doze.addAction(UIAction { [weak viewController_Doze] _ in
            guard let viewController_Doze = viewController_Doze else { return }
            handleCommentButtonTap_Doze(
                button_Doze: button_Doze,
                comment_Doze: comment_Doze,
                post_Doze: post_Doze,
                isMyComment_Doze: isMyComment_Doze,
                viewController_Doze: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }, for: .touchUpInside)
        
        return button_Doze
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Doze(
        size_Doze: CGFloat = 44,
        backgroundColor_Doze: UIColor? = nil,
        tintColor_Doze: UIColor = .white,
        withShadow_Doze: Bool = false
    ) -> UIButton {
        let button_Doze = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Doze = size_Doze * 0.5
        let config_Doze = UIImage.SymbolConfiguration(pointSize: iconSize_Doze, weight: .semibold)
        let image_Doze = UIImage(systemName: "ellipsis", withConfiguration: config_Doze)
        button_Doze.setImage(image_Doze, for: .normal)
        button_Doze.tintColor = tintColor_Doze
        
        // 设置背景
        let bgColor_Doze = backgroundColor_Doze ?? UIColor.white.withAlphaComponent(0.2)
        button_Doze.backgroundColor = bgColor_Doze
        button_Doze.layer.cornerRadius = size_Doze / 2
        
        // 添加阴影
        if withShadow_Doze {
            button_Doze.layer.shadowColor = UIColor.black.cgColor
            button_Doze.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Doze.layer.shadowOpacity = 0.15
            button_Doze.layer.shadowRadius = 8
        }
        
        return button_Doze
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Doze(button_Doze: UIButton) {
        UIView.animate(withDuration: animationDuration_Doze, animations: {
            button_Doze.transform = CGAffineTransform(
                scaleX: animationScale_Doze,
                y: animationScale_Doze
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Doze) {
                button_Doze.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Doze(
        button_Doze: UIButton,
        iconName_Doze: String,
        size_Doze: CGFloat,
        color_Doze: UIColor
    ) {
        let config_Doze = UIImage.SymbolConfiguration(pointSize: size_Doze, weight: .semibold)
        let image_Doze = UIImage(systemName: iconName_Doze, withConfiguration: config_Doze)
        button_Doze.setImage(image_Doze, for: .normal)
        button_Doze.tintColor = color_Doze
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Doze(
        button_Doze: UIButton,
        post_Doze: TitleModel_Doze,
        isMyPost_Doze: Bool,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)?
    ) {
        addButtonAnimation_Doze(button_Doze: button_Doze)
        
        if isMyPost_Doze {
            delete_Doze(
                post_Doze: post_Doze,
                from: viewController_Doze,
                completion_Doze: completion_Doze
            )
        } else {
            report_Doze(
                post_Doze: post_Doze,
                from: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Doze(
        button_Doze: UIButton,
        comment_Doze: Comment_Doze,
        post_Doze: TitleModel_Doze,
        isMyComment_Doze: Bool,
        viewController_Doze: UIViewController,
        completion_Doze: (() -> Void)?
    ) {
        addButtonAnimation_Doze(button_Doze: button_Doze)
        
        if isMyComment_Doze {
            delete_Doze(
                comment_Doze: comment_Doze,
                post_Doze: post_Doze,
                from: viewController_Doze,
                completion_Doze: completion_Doze
            )
        } else {
            report_Doze(
                comment_Doze: comment_Doze,
                post_Doze: post_Doze,
                from: viewController_Doze,
                completion_Doze: completion_Doze
            )
        }
    }
}
