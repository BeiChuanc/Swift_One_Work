import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Niche {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Niche: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Niche: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Niche: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Niche {
        static let postTitle_Niche = "Delete Post"
        static let postMessage_Niche = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Niche = "Delete Comment"
        static let commentMessage_Niche = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Niche = "Delete"
        static let cancelButtonTitle_Niche = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Niche {
        case block_Niche       // 拉黑用户
        case post_Niche        // 举报帖子
        case comment_Niche     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Niche(
        user_Niche: PrewUserModel_Niche,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        UIAlertController.report_Niche(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Niche(
                user_Niche: user_Niche,
                viewController_Niche: viewController_Niche
            )
            completion_Niche?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Niche(
        post_Niche: TitleModel_Niche,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        UIAlertController.report_Niche(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Niche(
                post_Niche: post_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche)
        })
    }
    
    /// 举报评论
    static func report_Niche(
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        UIAlertController.report_Niche(with: false, completeBlock: {
            performReportComment_Niche(
                comment_Niche: comment_Niche,
                post_Niche: post_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Niche(
        post_Niche: TitleModel_Niche,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Niche(
            title_Niche: DeleteAlertConfig_Niche.postTitle_Niche,
            message_Niche: DeleteAlertConfig_Niche.postMessage_Niche,
            from: viewController_Niche
        ) {
            performDeletePost_Niche(
                post_Niche: post_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }
    }
    
    /// 删除评论
    static func delete_Niche(
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Niche(
            title_Niche: DeleteAlertConfig_Niche.commentTitle_Niche,
            message_Niche: DeleteAlertConfig_Niche.commentMessage_Niche,
            from: viewController_Niche
        ) {
            performDeleteComment_Niche(
                comment_Niche: comment_Niche,
                post_Niche: post_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Niche(
        title_Niche: String,
        message_Niche: String,
        from viewController_Niche: UIViewController,
        completion_Niche: @escaping () -> Void
    ) {
        let alert_Niche = UIAlertController(
            title: title_Niche,
            message: message_Niche,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Niche = UIAlertAction(
            title: DeleteAlertConfig_Niche.deleteButtonTitle_Niche,
            style: .destructive
        ) { _ in
            completion_Niche()
        }
        
        // 取消按钮
        let cancelAction_Niche = UIAlertAction(
            title: DeleteAlertConfig_Niche.cancelButtonTitle_Niche,
            style: .cancel,
            handler: nil
        )
        
        alert_Niche.addAction(deleteAction_Niche)
        alert_Niche.addAction(cancelAction_Niche)
        
        viewController_Niche.present(alert_Niche, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Niche(
        action_Niche: @escaping @MainActor () -> Void,
        completion_Niche: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Niche * 1_000_000_000))
            
            await action_Niche()
            
            // 确保在主线程上执行回调
            if let completion_Niche = completion_Niche {
                await MainActor.run {
                    completion_Niche()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Niche(
        user_Niche: PrewUserModel_Niche,
        viewController_Niche: UIViewController
    ) {
        performAsyncAction_Niche(action_Niche: {
            UserViewModel_Niche.shared_Niche.reportUser_Niche(user_niche: user_Niche)
            print("已拉黑用户: \(user_Niche.userName_Niche ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Niche(
        post_Niche: TitleModel_Niche,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        performAsyncAction_Niche(
            action_Niche: {
                TitleViewModel_Niche.shared_Niche.deletePost_Niche(post_niche: post_Niche)
                print("已举报帖子: \(post_Niche.title_Niche)")
            },
            completion_Niche: completion_Niche
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Niche(
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        performAsyncAction_Niche(
            action_Niche: {
                TitleViewModel_Niche.shared_Niche.deleteComment_Niche(
                    post_niche: post_Niche,
                    comment_niche: comment_Niche
                )
                print("已举报评论: \(comment_Niche.commentContent_Niche)")
            },
            completion_Niche: completion_Niche
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Niche(
        post_Niche: TitleModel_Niche,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        performAsyncAction_Niche(
            action_Niche: {
                TitleViewModel_Niche.shared_Niche.deletePost_Niche(
                    post_niche: post_Niche,
                    isDelete_niche: true
                )
                print("已删除帖子: \(post_Niche.title_Niche)")
            },
            completion_Niche: completion_Niche
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Niche(
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) {
        performAsyncAction_Niche(
            action_Niche: {
                TitleViewModel_Niche.shared_Niche.deleteComment_Niche(
                    post_niche: post_Niche,
                    comment_niche: comment_Niche,
                    isDelete_niche: true
                )
                print("已删除评论: \(comment_Niche.commentContent_Niche)")
            },
            completion_Niche: completion_Niche
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Niche(
        post_Niche: TitleModel_Niche,
        size_Niche: CGFloat = 25,
        color_Niche: UIColor = .black,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) -> UIButton {
        let button_Niche = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Niche = UserViewModel_Niche.shared_Niche.isCurrentUser_Niche(
            userId_niche: post_Niche.titleUserId_Niche
        )
        
        // 配置按钮图标
        let iconName_Niche = isMyPost_Niche ? "trash" : "ellipsis"
        configureButtonIcon_Niche(
            button_Niche: button_Niche,
            iconName_Niche: iconName_Niche,
            size_Niche: size_Niche,
            color_Niche: color_Niche
        )
        
        button_Niche.addAction(UIAction { [weak viewController_Niche] _ in
            guard let viewController_Niche = viewController_Niche else { return }
            handlePostButtonTap_Niche(
                button_Niche: button_Niche,
                post_Niche: post_Niche,
                isMyPost_Niche: isMyPost_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }, for: .touchUpInside)
        
        return button_Niche
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Niche(
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        size_Niche: CGFloat = 25,
        color_Niche: UIColor = .black,
        from viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)? = nil
    ) -> UIButton {
        let button_Niche = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Niche = UserViewModel_Niche.shared_Niche.isCurrentUser_Niche(
            userId_niche: comment_Niche.commentUserId_Niche
        )
        
        // 配置按钮图标
        let iconName_Niche = isMyComment_Niche ? "trash" : "ellipsis"
        configureButtonIcon_Niche(
            button_Niche: button_Niche,
            iconName_Niche: iconName_Niche,
            size_Niche: size_Niche,
            color_Niche: color_Niche
        )
        
        button_Niche.addAction(UIAction { [weak viewController_Niche] _ in
            guard let viewController_Niche = viewController_Niche else { return }
            handleCommentButtonTap_Niche(
                button_Niche: button_Niche,
                comment_Niche: comment_Niche,
                post_Niche: post_Niche,
                isMyComment_Niche: isMyComment_Niche,
                viewController_Niche: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }, for: .touchUpInside)
        
        return button_Niche
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Niche(
        size_Niche: CGFloat = 44,
        backgroundColor_Niche: UIColor? = nil,
        tintColor_Niche: UIColor = .white,
        withShadow_Niche: Bool = false
    ) -> UIButton {
        let button_Niche = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Niche = size_Niche * 0.5
        let config_Niche = UIImage.SymbolConfiguration(pointSize: iconSize_Niche, weight: .semibold)
        let image_Niche = UIImage(systemName: "ellipsis", withConfiguration: config_Niche)
        button_Niche.setImage(image_Niche, for: .normal)
        button_Niche.tintColor = tintColor_Niche
        
        // 设置背景
        let bgColor_Niche = backgroundColor_Niche ?? UIColor.white.withAlphaComponent(0.2)
        button_Niche.backgroundColor = bgColor_Niche
        button_Niche.layer.cornerRadius = size_Niche / 2
        
        // 添加阴影
        if withShadow_Niche {
            button_Niche.layer.shadowColor = UIColor.black.cgColor
            button_Niche.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Niche.layer.shadowOpacity = 0.15
            button_Niche.layer.shadowRadius = 8
        }
        
        return button_Niche
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Niche(button_Niche: UIButton) {
        UIView.animate(withDuration: animationDuration_Niche, animations: {
            button_Niche.transform = CGAffineTransform(
                scaleX: animationScale_Niche,
                y: animationScale_Niche
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Niche) {
                button_Niche.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Niche(
        button_Niche: UIButton,
        iconName_Niche: String,
        size_Niche: CGFloat,
        color_Niche: UIColor
    ) {
        let config_Niche = UIImage.SymbolConfiguration(pointSize: size_Niche, weight: .semibold)
        let image_Niche = UIImage(systemName: iconName_Niche, withConfiguration: config_Niche)
        button_Niche.setImage(image_Niche, for: .normal)
        button_Niche.tintColor = color_Niche
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Niche(
        button_Niche: UIButton,
        post_Niche: TitleModel_Niche,
        isMyPost_Niche: Bool,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)?
    ) {
        addButtonAnimation_Niche(button_Niche: button_Niche)
        
        if isMyPost_Niche {
            delete_Niche(
                post_Niche: post_Niche,
                from: viewController_Niche,
                completion_Niche: completion_Niche
            )
        } else {
            report_Niche(
                post_Niche: post_Niche,
                from: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Niche(
        button_Niche: UIButton,
        comment_Niche: Comment_Niche,
        post_Niche: TitleModel_Niche,
        isMyComment_Niche: Bool,
        viewController_Niche: UIViewController,
        completion_Niche: (() -> Void)?
    ) {
        addButtonAnimation_Niche(button_Niche: button_Niche)
        
        if isMyComment_Niche {
            delete_Niche(
                comment_Niche: comment_Niche,
                post_Niche: post_Niche,
                from: viewController_Niche,
                completion_Niche: completion_Niche
            )
        } else {
            report_Niche(
                comment_Niche: comment_Niche,
                post_Niche: post_Niche,
                from: viewController_Niche,
                completion_Niche: completion_Niche
            )
        }
    }
}
