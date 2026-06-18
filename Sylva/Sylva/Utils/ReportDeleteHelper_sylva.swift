import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Sylva {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Sylva: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Sylva: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Sylva: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Sylva {
        static let postTitle_Sylva = "Delete Post"
        static let postMessage_Sylva = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Sylva = "Delete Comment"
        static let commentMessage_Sylva = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Sylva = "Delete"
        static let cancelButtonTitle_Sylva = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Sylva {
        case block_Sylva       // 拉黑用户
        case post_Sylva        // 举报帖子
        case comment_Sylva     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Sylva(
        user_Sylva: PrewUserModel_Sylva,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sylva(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Sylva(
                user_Sylva: user_Sylva,
                viewController_Sylva: viewController_Sylva
            )
            completion_Sylva?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Sylva(
        post_Sylva: TitleModel_Sylva,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sylva(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Sylva(
                post_Sylva: post_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva)
        })
    }
    
    /// 举报评论
    static func report_Sylva(
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        UIAlertController.report_Sylva(with: false, completeBlock: {
            performReportComment_Sylva(
                comment_Sylva: comment_Sylva,
                post_Sylva: post_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Sylva(
        post_Sylva: TitleModel_Sylva,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Sylva(
            title_Sylva: DeleteAlertConfig_Sylva.postTitle_Sylva,
            message_Sylva: DeleteAlertConfig_Sylva.postMessage_Sylva,
            from: viewController_Sylva
        ) {
            performDeletePost_Sylva(
                post_Sylva: post_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }
    }
    
    /// 删除评论
    static func delete_Sylva(
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Sylva(
            title_Sylva: DeleteAlertConfig_Sylva.commentTitle_Sylva,
            message_Sylva: DeleteAlertConfig_Sylva.commentMessage_Sylva,
            from: viewController_Sylva
        ) {
            performDeleteComment_Sylva(
                comment_Sylva: comment_Sylva,
                post_Sylva: post_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Sylva(
        title_Sylva: String,
        message_Sylva: String,
        from viewController_Sylva: UIViewController,
        completion_Sylva: @escaping () -> Void
    ) {
        let alert_Sylva = UIAlertController(
            title: title_Sylva,
            message: message_Sylva,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Sylva = UIAlertAction(
            title: DeleteAlertConfig_Sylva.deleteButtonTitle_Sylva,
            style: .destructive
        ) { _ in
            completion_Sylva()
        }
        
        // 取消按钮
        let cancelAction_Sylva = UIAlertAction(
            title: DeleteAlertConfig_Sylva.cancelButtonTitle_Sylva,
            style: .cancel,
            handler: nil
        )
        
        alert_Sylva.addAction(deleteAction_Sylva)
        alert_Sylva.addAction(cancelAction_Sylva)
        
        viewController_Sylva.present(alert_Sylva, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Sylva(
        action_Sylva: @escaping @MainActor () -> Void,
        completion_Sylva: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Sylva * 1_000_000_000))
            
            await action_Sylva()
            
            // 确保在主线程上执行回调
            if let completion_Sylva = completion_Sylva {
                await MainActor.run {
                    completion_Sylva()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Sylva(
        user_Sylva: PrewUserModel_Sylva,
        viewController_Sylva: UIViewController
    ) {
        performAsyncAction_Sylva(action_Sylva: {
            UserViewModel_Sylva.shared_Sylva.reportUser_Sylva(user_sylva: user_Sylva)
            print("已拉黑用户: \(user_Sylva.userName_Sylva ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Sylva(
        post_Sylva: TitleModel_Sylva,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        performAsyncAction_Sylva(
            action_Sylva: {
                TitleViewModel_Sylva.shared_Sylva.deletePost_Sylva(post_sylva: post_Sylva)
                print("已举报帖子: \(post_Sylva.title_Sylva)")
            },
            completion_Sylva: completion_Sylva
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Sylva(
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        performAsyncAction_Sylva(
            action_Sylva: {
                TitleViewModel_Sylva.shared_Sylva.deleteComment_Sylva(
                    post_sylva: post_Sylva,
                    comment_sylva: comment_Sylva
                )
                print("已举报评论: \(comment_Sylva.commentContent_Sylva)")
            },
            completion_Sylva: completion_Sylva
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Sylva(
        post_Sylva: TitleModel_Sylva,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        performAsyncAction_Sylva(
            action_Sylva: {
                TitleViewModel_Sylva.shared_Sylva.deletePost_Sylva(
                    post_sylva: post_Sylva,
                    isDelete_sylva: true
                )
                print("已删除帖子: \(post_Sylva.title_Sylva)")
            },
            completion_Sylva: completion_Sylva
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Sylva(
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) {
        performAsyncAction_Sylva(
            action_Sylva: {
                TitleViewModel_Sylva.shared_Sylva.deleteComment_Sylva(
                    post_sylva: post_Sylva,
                    comment_sylva: comment_Sylva,
                    isDelete_sylva: true
                )
                print("已删除评论: \(comment_Sylva.commentContent_Sylva)")
            },
            completion_Sylva: completion_Sylva
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Sylva(
        post_Sylva: TitleModel_Sylva,
        size_Sylva: CGFloat = 25,
        color_Sylva: UIColor = .black,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) -> UIButton {
        let button_Sylva = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Sylva = UserViewModel_Sylva.shared_Sylva.isCurrentUser_Sylva(
            userId_sylva: post_Sylva.titleUserId_Sylva
        )
        
        // 配置按钮图标
        let iconName_Sylva = isMyPost_Sylva ? "trash" : "ellipsis"
        configureButtonIcon_Sylva(
            button_Sylva: button_Sylva,
            iconName_Sylva: iconName_Sylva,
            size_Sylva: size_Sylva,
            color_Sylva: color_Sylva
        )
        
        button_Sylva.addAction(UIAction { [weak viewController_Sylva] _ in
            guard let viewController_Sylva = viewController_Sylva else { return }
            handlePostButtonTap_Sylva(
                button_Sylva: button_Sylva,
                post_Sylva: post_Sylva,
                isMyPost_Sylva: isMyPost_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }, for: .touchUpInside)
        
        return button_Sylva
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Sylva(
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        size_Sylva: CGFloat = 25,
        color_Sylva: UIColor = .black,
        from viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)? = nil
    ) -> UIButton {
        let button_Sylva = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Sylva = UserViewModel_Sylva.shared_Sylva.isCurrentUser_Sylva(
            userId_sylva: comment_Sylva.commentUserId_Sylva
        )
        
        // 配置按钮图标
        let iconName_Sylva = isMyComment_Sylva ? "trash" : "ellipsis"
        configureButtonIcon_Sylva(
            button_Sylva: button_Sylva,
            iconName_Sylva: iconName_Sylva,
            size_Sylva: size_Sylva,
            color_Sylva: color_Sylva
        )
        
        button_Sylva.addAction(UIAction { [weak viewController_Sylva] _ in
            guard let viewController_Sylva = viewController_Sylva else { return }
            handleCommentButtonTap_Sylva(
                button_Sylva: button_Sylva,
                comment_Sylva: comment_Sylva,
                post_Sylva: post_Sylva,
                isMyComment_Sylva: isMyComment_Sylva,
                viewController_Sylva: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }, for: .touchUpInside)
        
        return button_Sylva
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Sylva(
        size_Sylva: CGFloat = 44,
        backgroundColor_Sylva: UIColor? = nil,
        tintColor_Sylva: UIColor = .white,
        withShadow_Sylva: Bool = false
    ) -> UIButton {
        let button_Sylva = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Sylva = size_Sylva * 0.5
        let config_Sylva = UIImage.SymbolConfiguration(pointSize: iconSize_Sylva, weight: .semibold)
        let image_Sylva = UIImage(systemName: "ellipsis", withConfiguration: config_Sylva)
        button_Sylva.setImage(image_Sylva, for: .normal)
        button_Sylva.tintColor = tintColor_Sylva
        
        // 设置背景
        let bgColor_Sylva = backgroundColor_Sylva ?? UIColor.white.withAlphaComponent(0.2)
        button_Sylva.backgroundColor = bgColor_Sylva
        button_Sylva.layer.cornerRadius = size_Sylva / 2
        
        // 添加阴影
        if withShadow_Sylva {
            button_Sylva.layer.shadowColor = UIColor.black.cgColor
            button_Sylva.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Sylva.layer.shadowOpacity = 0.15
            button_Sylva.layer.shadowRadius = 8
        }
        
        return button_Sylva
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Sylva(button_Sylva: UIButton) {
        UIView.animate(withDuration: animationDuration_Sylva, animations: {
            button_Sylva.transform = CGAffineTransform(
                scaleX: animationScale_Sylva,
                y: animationScale_Sylva
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Sylva) {
                button_Sylva.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Sylva(
        button_Sylva: UIButton,
        iconName_Sylva: String,
        size_Sylva: CGFloat,
        color_Sylva: UIColor
    ) {
        let config_Sylva = UIImage.SymbolConfiguration(pointSize: size_Sylva, weight: .semibold)
        let image_Sylva = UIImage(systemName: iconName_Sylva, withConfiguration: config_Sylva)
        button_Sylva.setImage(image_Sylva, for: .normal)
        button_Sylva.tintColor = color_Sylva
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Sylva(
        button_Sylva: UIButton,
        post_Sylva: TitleModel_Sylva,
        isMyPost_Sylva: Bool,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)?
    ) {
        addButtonAnimation_Sylva(button_Sylva: button_Sylva)
        
        if isMyPost_Sylva {
            delete_Sylva(
                post_Sylva: post_Sylva,
                from: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        } else {
            report_Sylva(
                post_Sylva: post_Sylva,
                from: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Sylva(
        button_Sylva: UIButton,
        comment_Sylva: Comment_Sylva,
        post_Sylva: TitleModel_Sylva,
        isMyComment_Sylva: Bool,
        viewController_Sylva: UIViewController,
        completion_Sylva: (() -> Void)?
    ) {
        addButtonAnimation_Sylva(button_Sylva: button_Sylva)
        
        if isMyComment_Sylva {
            delete_Sylva(
                comment_Sylva: comment_Sylva,
                post_Sylva: post_Sylva,
                from: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        } else {
            report_Sylva(
                comment_Sylva: comment_Sylva,
                post_Sylva: post_Sylva,
                from: viewController_Sylva,
                completion_Sylva: completion_Sylva
            )
        }
    }
}
