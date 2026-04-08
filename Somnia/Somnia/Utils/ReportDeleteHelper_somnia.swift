import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Somnia {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Somnia: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Somnia: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Somnia: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Somnia {
        static let postTitle_Somnia = "Delete Post"
        static let postMessage_Somnia = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Somnia = "Delete Comment"
        static let commentMessage_Somnia = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Somnia = "Delete"
        static let cancelButtonTitle_Somnia = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Somnia {
        case block_Somnia       // 拉黑用户
        case post_Somnia        // 举报帖子
        case comment_Somnia     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Somnia(
        user_Somnia: PrewUserModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Somnia(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Somnia(
                user_Somnia: user_Somnia,
                viewController_Somnia: viewController_Somnia
            )
            completion_Somnia?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Somnia(
        post_Somnia: TitleModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Somnia(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Somnia(
                post_Somnia: post_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia)
        })
    }
    
    /// 举报评论
    static func report_Somnia(
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        UIAlertController.report_Somnia(with: false, completeBlock: {
            performReportComment_Somnia(
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Somnia(
        post_Somnia: TitleModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Somnia(
            title_Somnia: DeleteAlertConfig_Somnia.postTitle_Somnia,
            message_Somnia: DeleteAlertConfig_Somnia.postMessage_Somnia,
            from: viewController_Somnia
        ) {
            performDeletePost_Somnia(
                post_Somnia: post_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }
    }
    
    /// 删除评论
    static func delete_Somnia(
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Somnia(
            title_Somnia: DeleteAlertConfig_Somnia.commentTitle_Somnia,
            message_Somnia: DeleteAlertConfig_Somnia.commentMessage_Somnia,
            from: viewController_Somnia
        ) {
            performDeleteComment_Somnia(
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Somnia(
        title_Somnia: String,
        message_Somnia: String,
        from viewController_Somnia: UIViewController,
        completion_Somnia: @escaping () -> Void
    ) {
        let alert_Somnia = UIAlertController(
            title: title_Somnia,
            message: message_Somnia,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Somnia = UIAlertAction(
            title: DeleteAlertConfig_Somnia.deleteButtonTitle_Somnia,
            style: .destructive
        ) { _ in
            completion_Somnia()
        }
        
        // 取消按钮
        let cancelAction_Somnia = UIAlertAction(
            title: DeleteAlertConfig_Somnia.cancelButtonTitle_Somnia,
            style: .cancel,
            handler: nil
        )
        
        alert_Somnia.addAction(deleteAction_Somnia)
        alert_Somnia.addAction(cancelAction_Somnia)
        
        viewController_Somnia.present(alert_Somnia, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Somnia(
        action_Somnia: @escaping @MainActor () -> Void,
        completion_Somnia: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Somnia * 1_000_000_000))
            
            await action_Somnia()
            
            // 确保在主线程上执行回调
            if let completion_Somnia = completion_Somnia {
                await MainActor.run {
                    completion_Somnia()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Somnia(
        user_Somnia: PrewUserModel_Somnia,
        viewController_Somnia: UIViewController
    ) {
        performAsyncAction_Somnia(action_Somnia: {
            UserViewModel_Somnia.shared_Somnia.reportUser_Somnia(user_somnia: user_Somnia)
            print("已拉黑用户: \(user_Somnia.userName_Somnia ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Somnia(
        post_Somnia: TitleModel_Somnia,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        performAsyncAction_Somnia(
            action_Somnia: {
                TitleViewModel_Somnia.shared_Somnia.deletePost_Somnia(post_somnia: post_Somnia)
                print("已举报帖子: \(post_Somnia.title_Somnia)")
            },
            completion_Somnia: completion_Somnia
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Somnia(
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        performAsyncAction_Somnia(
            action_Somnia: {
                TitleViewModel_Somnia.shared_Somnia.deleteComment_Somnia(
                    post_somnia: post_Somnia,
                    comment_somnia: comment_Somnia
                )
                print("已举报评论: \(comment_Somnia.commentContent_Somnia)")
            },
            completion_Somnia: completion_Somnia
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Somnia(
        post_Somnia: TitleModel_Somnia,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        performAsyncAction_Somnia(
            action_Somnia: {
                TitleViewModel_Somnia.shared_Somnia.deletePost_Somnia(
                    post_somnia: post_Somnia,
                    isDelete_somnia: true
                )
                print("已删除帖子: \(post_Somnia.title_Somnia)")
            },
            completion_Somnia: completion_Somnia
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Somnia(
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) {
        performAsyncAction_Somnia(
            action_Somnia: {
                TitleViewModel_Somnia.shared_Somnia.deleteComment_Somnia(
                    post_somnia: post_Somnia,
                    comment_somnia: comment_Somnia,
                    isDelete_somnia: true
                )
                print("已删除评论: \(comment_Somnia.commentContent_Somnia)")
            },
            completion_Somnia: completion_Somnia
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Somnia(
        post_Somnia: TitleModel_Somnia,
        size_Somnia: CGFloat = 25,
        color_Somnia: UIColor = .black,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) -> UIButton {
        let button_Somnia = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Somnia = UserViewModel_Somnia.shared_Somnia.isCurrentUser_Somnia(
            userId_somnia: post_Somnia.titleUserId_Somnia
        )
        
        // 配置按钮图标
        let iconName_Somnia = isMyPost_Somnia ? "trash" : "ellipsis"
        configureButtonIcon_Somnia(
            button_Somnia: button_Somnia,
            iconName_Somnia: iconName_Somnia,
            size_Somnia: size_Somnia,
            color_Somnia: color_Somnia
        )
        
        button_Somnia.addAction(UIAction { [weak viewController_Somnia] _ in
            guard let viewController_Somnia = viewController_Somnia else { return }
            handlePostButtonTap_Somnia(
                button_Somnia: button_Somnia,
                post_Somnia: post_Somnia,
                isMyPost_Somnia: isMyPost_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }, for: .touchUpInside)
        
        return button_Somnia
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Somnia(
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        size_Somnia: CGFloat = 25,
        color_Somnia: UIColor = .black,
        from viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)? = nil
    ) -> UIButton {
        let button_Somnia = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Somnia = UserViewModel_Somnia.shared_Somnia.isCurrentUser_Somnia(
            userId_somnia: comment_Somnia.commentUserId_Somnia
        )
        
        // 配置按钮图标
        let iconName_Somnia = isMyComment_Somnia ? "trash" : "ellipsis"
        configureButtonIcon_Somnia(
            button_Somnia: button_Somnia,
            iconName_Somnia: iconName_Somnia,
            size_Somnia: size_Somnia,
            color_Somnia: color_Somnia
        )
        
        button_Somnia.addAction(UIAction { [weak viewController_Somnia] _ in
            guard let viewController_Somnia = viewController_Somnia else { return }
            handleCommentButtonTap_Somnia(
                button_Somnia: button_Somnia,
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia,
                isMyComment_Somnia: isMyComment_Somnia,
                viewController_Somnia: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }, for: .touchUpInside)
        
        return button_Somnia
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Somnia(
        size_Somnia: CGFloat = 44,
        backgroundColor_Somnia: UIColor? = nil,
        tintColor_Somnia: UIColor = .white,
        withShadow_Somnia: Bool = false
    ) -> UIButton {
        let button_Somnia = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Somnia = size_Somnia * 0.5
        let config_Somnia = UIImage.SymbolConfiguration(pointSize: iconSize_Somnia, weight: .semibold)
        let image_Somnia = UIImage(systemName: "ellipsis", withConfiguration: config_Somnia)
        button_Somnia.setImage(image_Somnia, for: .normal)
        button_Somnia.tintColor = tintColor_Somnia
        
        // 设置背景
        let bgColor_Somnia = backgroundColor_Somnia ?? UIColor.white.withAlphaComponent(0.2)
        button_Somnia.backgroundColor = bgColor_Somnia
        button_Somnia.layer.cornerRadius = size_Somnia / 2
        
        // 添加阴影
        if withShadow_Somnia {
            button_Somnia.layer.shadowColor = UIColor.black.cgColor
            button_Somnia.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Somnia.layer.shadowOpacity = 0.15
            button_Somnia.layer.shadowRadius = 8
        }
        
        return button_Somnia
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Somnia(button_Somnia: UIButton) {
        UIView.animate(withDuration: animationDuration_Somnia, animations: {
            button_Somnia.transform = CGAffineTransform(
                scaleX: animationScale_Somnia,
                y: animationScale_Somnia
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Somnia) {
                button_Somnia.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Somnia(
        button_Somnia: UIButton,
        iconName_Somnia: String,
        size_Somnia: CGFloat,
        color_Somnia: UIColor
    ) {
        let config_Somnia = UIImage.SymbolConfiguration(pointSize: size_Somnia, weight: .semibold)
        let image_Somnia = UIImage(systemName: iconName_Somnia, withConfiguration: config_Somnia)
        button_Somnia.setImage(image_Somnia, for: .normal)
        button_Somnia.tintColor = color_Somnia
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Somnia(
        button_Somnia: UIButton,
        post_Somnia: TitleModel_Somnia,
        isMyPost_Somnia: Bool,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)?
    ) {
        addButtonAnimation_Somnia(button_Somnia: button_Somnia)
        
        if isMyPost_Somnia {
            delete_Somnia(
                post_Somnia: post_Somnia,
                from: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        } else {
            report_Somnia(
                post_Somnia: post_Somnia,
                from: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Somnia(
        button_Somnia: UIButton,
        comment_Somnia: Comment_Somnia,
        post_Somnia: TitleModel_Somnia,
        isMyComment_Somnia: Bool,
        viewController_Somnia: UIViewController,
        completion_Somnia: (() -> Void)?
    ) {
        addButtonAnimation_Somnia(button_Somnia: button_Somnia)
        
        if isMyComment_Somnia {
            delete_Somnia(
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia,
                from: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        } else {
            report_Somnia(
                comment_Somnia: comment_Somnia,
                post_Somnia: post_Somnia,
                from: viewController_Somnia,
                completion_Somnia: completion_Somnia
            )
        }
    }
}
