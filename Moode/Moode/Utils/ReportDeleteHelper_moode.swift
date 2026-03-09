import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Moode {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Moode: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Moode: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Moode: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Moode {
        static let postTitle_Moode = "Delete Post"
        static let postMessage_Moode = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Moode = "Delete Comment"
        static let commentMessage_Moode = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Moode = "Delete"
        static let cancelButtonTitle_Moode = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Moode {
        case block_Moode       // 拉黑用户
        case post_Moode        // 举报帖子
        case comment_Moode     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Moode(
        user_Moode: PrewUserModel_Moode,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        UIAlertController.report_Moode(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Moode(
                user_Moode: user_Moode,
                viewController_Moode: viewController_Moode
            )
            completion_Moode?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Moode(
        post_Moode: TitleModel_Moode,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        UIAlertController.report_Moode(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Moode(
                post_Moode: post_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode)
        })
    }
    
    /// 举报评论
    static func report_Moode(
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        UIAlertController.report_Moode(with: false, completeBlock: {
            performReportComment_Moode(
                comment_Moode: comment_Moode,
                post_Moode: post_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Moode(
        post_Moode: TitleModel_Moode,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Moode(
            title_Moode: DeleteAlertConfig_Moode.postTitle_Moode,
            message_Moode: DeleteAlertConfig_Moode.postMessage_Moode,
            from: viewController_Moode
        ) {
            performDeletePost_Moode(
                post_Moode: post_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }
    }
    
    /// 删除评论
    static func delete_Moode(
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Moode(
            title_Moode: DeleteAlertConfig_Moode.commentTitle_Moode,
            message_Moode: DeleteAlertConfig_Moode.commentMessage_Moode,
            from: viewController_Moode
        ) {
            performDeleteComment_Moode(
                comment_Moode: comment_Moode,
                post_Moode: post_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Moode(
        title_Moode: String,
        message_Moode: String,
        from viewController_Moode: UIViewController,
        completion_Moode: @escaping () -> Void
    ) {
        let alert_Moode = UIAlertController(
            title: title_Moode,
            message: message_Moode,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Moode = UIAlertAction(
            title: DeleteAlertConfig_Moode.deleteButtonTitle_Moode,
            style: .destructive
        ) { _ in
            completion_Moode()
        }
        
        // 取消按钮
        let cancelAction_Moode = UIAlertAction(
            title: DeleteAlertConfig_Moode.cancelButtonTitle_Moode,
            style: .cancel,
            handler: nil
        )
        
        alert_Moode.addAction(deleteAction_Moode)
        alert_Moode.addAction(cancelAction_Moode)
        
        viewController_Moode.present(alert_Moode, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Moode(
        action_Moode: @escaping @MainActor () -> Void,
        completion_Moode: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Moode * 1_000_000_000))
            
            await action_Moode()
            
            // 确保在主线程上执行回调
            if let completion_Moode = completion_Moode {
                await MainActor.run {
                    completion_Moode()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Moode(
        user_Moode: PrewUserModel_Moode,
        viewController_Moode: UIViewController
    ) {
        performAsyncAction_Moode(action_Moode: {
            UserViewModel_Moode.shared_Moode.reportUser_Moode(user_moode: user_Moode)
            print("已拉黑用户: \(user_Moode.userName_Moode ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Moode(
        post_Moode: TitleModel_Moode,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        performAsyncAction_Moode(
            action_Moode: {
                TitleViewModel_Moode.shared_Moode.deletePost_Moode(post_moode: post_Moode)
                print("已举报帖子: \(post_Moode.title_Moode)")
            },
            completion_Moode: completion_Moode
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Moode(
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        performAsyncAction_Moode(
            action_Moode: {
                TitleViewModel_Moode.shared_Moode.deleteComment_Moode(
                    post_moode: post_Moode,
                    comment_moode: comment_Moode
                )
                print("已举报评论: \(comment_Moode.commentContent_Moode)")
            },
            completion_Moode: completion_Moode
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Moode(
        post_Moode: TitleModel_Moode,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        performAsyncAction_Moode(
            action_Moode: {
                TitleViewModel_Moode.shared_Moode.deletePost_Moode(
                    post_moode: post_Moode,
                    isDelete_moode: true
                )
                print("已删除帖子: \(post_Moode.title_Moode)")
            },
            completion_Moode: completion_Moode
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Moode(
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) {
        performAsyncAction_Moode(
            action_Moode: {
                TitleViewModel_Moode.shared_Moode.deleteComment_Moode(
                    post_moode: post_Moode,
                    comment_moode: comment_Moode,
                    isDelete_moode: true
                )
                print("已删除评论: \(comment_Moode.commentContent_Moode)")
            },
            completion_Moode: completion_Moode
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Moode(
        post_Moode: TitleModel_Moode,
        size_Moode: CGFloat = 25,
        color_Moode: UIColor = .black,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) -> UIButton {
        let button_Moode = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: post_Moode.titleUserId_Moode
        )
        
        // 配置按钮图标
        let iconName_Moode = isMyPost_Moode ? "trash" : "ellipsis"
        configureButtonIcon_Moode(
            button_Moode: button_Moode,
            iconName_Moode: iconName_Moode,
            size_Moode: size_Moode,
            color_Moode: color_Moode
        )
        
        button_Moode.addAction(UIAction { [weak viewController_Moode] _ in
            guard let viewController_Moode = viewController_Moode else { return }
            handlePostButtonTap_Moode(
                button_Moode: button_Moode,
                post_Moode: post_Moode,
                isMyPost_Moode: isMyPost_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }, for: .touchUpInside)
        
        return button_Moode
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Moode(
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        size_Moode: CGFloat = 25,
        color_Moode: UIColor = .black,
        from viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)? = nil
    ) -> UIButton {
        let button_Moode = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Moode = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: comment_Moode.commentUserId_Moode
        )
        
        // 配置按钮图标
        let iconName_Moode = isMyComment_Moode ? "trash" : "ellipsis"
        configureButtonIcon_Moode(
            button_Moode: button_Moode,
            iconName_Moode: iconName_Moode,
            size_Moode: size_Moode,
            color_Moode: color_Moode
        )
        
        button_Moode.addAction(UIAction { [weak viewController_Moode] _ in
            guard let viewController_Moode = viewController_Moode else { return }
            handleCommentButtonTap_Moode(
                button_Moode: button_Moode,
                comment_Moode: comment_Moode,
                post_Moode: post_Moode,
                isMyComment_Moode: isMyComment_Moode,
                viewController_Moode: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }, for: .touchUpInside)
        
        return button_Moode
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Moode(
        size_Moode: CGFloat = 44,
        backgroundColor_Moode: UIColor? = nil,
        tintColor_Moode: UIColor = .white,
        withShadow_Moode: Bool = false
    ) -> UIButton {
        let button_Moode = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Moode = size_Moode * 0.5
        let config_Moode = UIImage.SymbolConfiguration(pointSize: iconSize_Moode, weight: .semibold)
        let image_Moode = UIImage(systemName: "ellipsis", withConfiguration: config_Moode)
        button_Moode.setImage(image_Moode, for: .normal)
        button_Moode.tintColor = tintColor_Moode
        
        // 设置背景
        let bgColor_Moode = backgroundColor_Moode ?? UIColor.white.withAlphaComponent(0.2)
        button_Moode.backgroundColor = bgColor_Moode
        button_Moode.layer.cornerRadius = size_Moode / 2
        
        // 添加阴影
        if withShadow_Moode {
            button_Moode.layer.shadowColor = UIColor.black.cgColor
            button_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Moode.layer.shadowOpacity = 0.15
            button_Moode.layer.shadowRadius = 8
        }
        
        return button_Moode
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Moode(button_Moode: UIButton) {
        UIView.animate(withDuration: animationDuration_Moode, animations: {
            button_Moode.transform = CGAffineTransform(
                scaleX: animationScale_Moode,
                y: animationScale_Moode
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Moode) {
                button_Moode.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Moode(
        button_Moode: UIButton,
        iconName_Moode: String,
        size_Moode: CGFloat,
        color_Moode: UIColor
    ) {
        let config_Moode = UIImage.SymbolConfiguration(pointSize: size_Moode, weight: .semibold)
        let image_Moode = UIImage(systemName: iconName_Moode, withConfiguration: config_Moode)
        button_Moode.setImage(image_Moode, for: .normal)
        button_Moode.tintColor = color_Moode
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Moode(
        button_Moode: UIButton,
        post_Moode: TitleModel_Moode,
        isMyPost_Moode: Bool,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)?
    ) {
        addButtonAnimation_Moode(button_Moode: button_Moode)
        
        if isMyPost_Moode {
            delete_Moode(
                post_Moode: post_Moode,
                from: viewController_Moode,
                completion_Moode: completion_Moode
            )
        } else {
            report_Moode(
                post_Moode: post_Moode,
                from: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Moode(
        button_Moode: UIButton,
        comment_Moode: Comment_Moode,
        post_Moode: TitleModel_Moode,
        isMyComment_Moode: Bool,
        viewController_Moode: UIViewController,
        completion_Moode: (() -> Void)?
    ) {
        addButtonAnimation_Moode(button_Moode: button_Moode)
        
        if isMyComment_Moode {
            delete_Moode(
                comment_Moode: comment_Moode,
                post_Moode: post_Moode,
                from: viewController_Moode,
                completion_Moode: completion_Moode
            )
        } else {
            report_Moode(
                comment_Moode: comment_Moode,
                post_Moode: post_Moode,
                from: viewController_Moode,
                completion_Moode: completion_Moode
            )
        }
    }
}
