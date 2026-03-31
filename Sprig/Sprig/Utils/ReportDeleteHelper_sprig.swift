import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Sprig {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Sprig: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Sprig: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Sprig: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Sprig {
        static let postTitle_Sprig = "Delete Post"
        static let postMessage_Sprig = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Sprig = "Delete Comment"
        static let commentMessage_Sprig = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Sprig = "Delete"
        static let cancelButtonTitle_Sprig = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Sprig {
        case block_Sprig       // 拉黑用户
        case post_Sprig        // 举报帖子
        case comment_Sprig     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Sprig(
        user_Sprig: PrewUserModel_Sprig,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sprig(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Sprig(
                user_Sprig: user_Sprig,
                viewController_Sprig: viewController_Sprig
            )
            completion_Sprig?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Sprig(
        post_Sprig: TitleModel_Sprig,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sprig(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Sprig(
                post_Sprig: post_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig)
        })
    }
    
    /// 举报评论
    static func report_Sprig(
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sprig(with: false, completeBlock: {
            performReportComment_Sprig(
                comment_Sprig: comment_Sprig,
                post_Sprig: post_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Sprig(
        post_Sprig: TitleModel_Sprig,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Sprig(
            title_Sprig: DeleteAlertConfig_Sprig.postTitle_Sprig,
            message_Sprig: DeleteAlertConfig_Sprig.postMessage_Sprig,
            from: viewController_Sprig
        ) {
            performDeletePost_Sprig(
                post_Sprig: post_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }
    }
    
    /// 删除评论
    static func delete_Sprig(
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Sprig(
            title_Sprig: DeleteAlertConfig_Sprig.commentTitle_Sprig,
            message_Sprig: DeleteAlertConfig_Sprig.commentMessage_Sprig,
            from: viewController_Sprig
        ) {
            performDeleteComment_Sprig(
                comment_Sprig: comment_Sprig,
                post_Sprig: post_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Sprig(
        title_Sprig: String,
        message_Sprig: String,
        from viewController_Sprig: UIViewController,
        completion_Sprig: @escaping () -> Void
    ) {
        let alert_Sprig = UIAlertController(
            title: title_Sprig,
            message: message_Sprig,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Sprig = UIAlertAction(
            title: DeleteAlertConfig_Sprig.deleteButtonTitle_Sprig,
            style: .destructive
        ) { _ in
            completion_Sprig()
        }
        
        // 取消按钮
        let cancelAction_Sprig = UIAlertAction(
            title: DeleteAlertConfig_Sprig.cancelButtonTitle_Sprig,
            style: .cancel,
            handler: nil
        )
        
        alert_Sprig.addAction(deleteAction_Sprig)
        alert_Sprig.addAction(cancelAction_Sprig)
        
        viewController_Sprig.present(alert_Sprig, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Sprig(
        action_Sprig: @escaping @MainActor () -> Void,
        completion_Sprig: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Sprig * 1_000_000_000))
            
            await action_Sprig()
            
            // 确保在主线程上执行回调
            if let completion_Sprig = completion_Sprig {
                await MainActor.run {
                    completion_Sprig()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Sprig(
        user_Sprig: PrewUserModel_Sprig,
        viewController_Sprig: UIViewController
    ) {
        performAsyncAction_Sprig(action_Sprig: {
            UserViewModel_Sprig.shared_Sprig.reportUser_Sprig(user_sprig: user_Sprig)
            print("已拉黑用户: \(user_Sprig.userName_Sprig ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Sprig(
        post_Sprig: TitleModel_Sprig,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        performAsyncAction_Sprig(
            action_Sprig: {
                TitleViewModel_Sprig.shared_Sprig.deletePost_Sprig(post_sprig: post_Sprig)
                print("已举报帖子: \(post_Sprig.title_Sprig)")
            },
            completion_Sprig: completion_Sprig
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Sprig(
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        performAsyncAction_Sprig(
            action_Sprig: {
                TitleViewModel_Sprig.shared_Sprig.deleteComment_Sprig(
                    post_sprig: post_Sprig,
                    comment_sprig: comment_Sprig
                )
                print("已举报评论: \(comment_Sprig.commentContent_Sprig)")
            },
            completion_Sprig: completion_Sprig
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Sprig(
        post_Sprig: TitleModel_Sprig,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        performAsyncAction_Sprig(
            action_Sprig: {
                TitleViewModel_Sprig.shared_Sprig.deletePost_Sprig(
                    post_sprig: post_Sprig,
                    isDelete_sprig: true
                )
                print("已删除帖子: \(post_Sprig.title_Sprig)")
            },
            completion_Sprig: completion_Sprig
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Sprig(
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) {
        performAsyncAction_Sprig(
            action_Sprig: {
                TitleViewModel_Sprig.shared_Sprig.deleteComment_Sprig(
                    post_sprig: post_Sprig,
                    comment_sprig: comment_Sprig,
                    isDelete_sprig: true
                )
                print("已删除评论: \(comment_Sprig.commentContent_Sprig)")
            },
            completion_Sprig: completion_Sprig
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Sprig(
        post_Sprig: TitleModel_Sprig,
        size_Sprig: CGFloat = 25,
        color_Sprig: UIColor = .black,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) -> UIButton {
        let button_Sprig = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: post_Sprig.titleUserId_Sprig
        )
        
        // 配置按钮图标
        let iconName_Sprig = isMyPost_Sprig ? "trash" : "ellipsis"
        configureButtonIcon_Sprig(
            button_Sprig: button_Sprig,
            iconName_Sprig: iconName_Sprig,
            size_Sprig: size_Sprig,
            color_Sprig: color_Sprig
        )
        
        button_Sprig.addAction(UIAction { [weak viewController_Sprig] _ in
            guard let viewController_Sprig = viewController_Sprig else { return }
            handlePostButtonTap_Sprig(
                button_Sprig: button_Sprig,
                post_Sprig: post_Sprig,
                isMyPost_Sprig: isMyPost_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }, for: .touchUpInside)
        
        return button_Sprig
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Sprig(
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        size_Sprig: CGFloat = 25,
        color_Sprig: UIColor = .black,
        from viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)? = nil
    ) -> UIButton {
        let button_Sprig = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Sprig = UserViewModel_Sprig.shared_Sprig.isCurrentUser_Sprig(
            userId_sprig: comment_Sprig.commentUserId_Sprig
        )
        
        // 配置按钮图标
        let iconName_Sprig = isMyComment_Sprig ? "trash" : "ellipsis"
        configureButtonIcon_Sprig(
            button_Sprig: button_Sprig,
            iconName_Sprig: iconName_Sprig,
            size_Sprig: size_Sprig,
            color_Sprig: color_Sprig
        )
        
        button_Sprig.addAction(UIAction { [weak viewController_Sprig] _ in
            guard let viewController_Sprig = viewController_Sprig else { return }
            handleCommentButtonTap_Sprig(
                button_Sprig: button_Sprig,
                comment_Sprig: comment_Sprig,
                post_Sprig: post_Sprig,
                isMyComment_Sprig: isMyComment_Sprig,
                viewController_Sprig: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }, for: .touchUpInside)
        
        return button_Sprig
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Sprig(
        size_Sprig: CGFloat = 44,
        backgroundColor_Sprig: UIColor? = nil,
        tintColor_Sprig: UIColor = .white,
        withShadow_Sprig: Bool = false
    ) -> UIButton {
        let button_Sprig = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Sprig = size_Sprig * 0.5
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: iconSize_Sprig, weight: .semibold)
        let image_Sprig = UIImage(systemName: "ellipsis", withConfiguration: config_Sprig)
        button_Sprig.setImage(image_Sprig, for: .normal)
        button_Sprig.tintColor = tintColor_Sprig
        
        // 设置背景
        let bgColor_Sprig = backgroundColor_Sprig ?? UIColor.white.withAlphaComponent(0.2)
        button_Sprig.backgroundColor = bgColor_Sprig
        button_Sprig.layer.cornerRadius = size_Sprig / 2
        
        // 添加阴影
        if withShadow_Sprig {
            button_Sprig.layer.shadowColor = UIColor.black.cgColor
            button_Sprig.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Sprig.layer.shadowOpacity = 0.15
            button_Sprig.layer.shadowRadius = 8
        }
        
        return button_Sprig
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Sprig(button_Sprig: UIButton) {
        UIView.animate(withDuration: animationDuration_Sprig, animations: {
            button_Sprig.transform = CGAffineTransform(
                scaleX: animationScale_Sprig,
                y: animationScale_Sprig
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Sprig) {
                button_Sprig.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Sprig(
        button_Sprig: UIButton,
        iconName_Sprig: String,
        size_Sprig: CGFloat,
        color_Sprig: UIColor
    ) {
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: size_Sprig, weight: .semibold)
        let image_Sprig = UIImage(systemName: iconName_Sprig, withConfiguration: config_Sprig)
        button_Sprig.setImage(image_Sprig, for: .normal)
        button_Sprig.tintColor = color_Sprig
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Sprig(
        button_Sprig: UIButton,
        post_Sprig: TitleModel_Sprig,
        isMyPost_Sprig: Bool,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)?
    ) {
        addButtonAnimation_Sprig(button_Sprig: button_Sprig)
        
        if isMyPost_Sprig {
            delete_Sprig(
                post_Sprig: post_Sprig,
                from: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        } else {
            report_Sprig(
                post_Sprig: post_Sprig,
                from: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Sprig(
        button_Sprig: UIButton,
        comment_Sprig: Comment_Sprig,
        post_Sprig: TitleModel_Sprig,
        isMyComment_Sprig: Bool,
        viewController_Sprig: UIViewController,
        completion_Sprig: (() -> Void)?
    ) {
        addButtonAnimation_Sprig(button_Sprig: button_Sprig)
        
        if isMyComment_Sprig {
            delete_Sprig(
                comment_Sprig: comment_Sprig,
                post_Sprig: post_Sprig,
                from: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        } else {
            report_Sprig(
                comment_Sprig: comment_Sprig,
                post_Sprig: post_Sprig,
                from: viewController_Sprig,
                completion_Sprig: completion_Sprig
            )
        }
    }
}
