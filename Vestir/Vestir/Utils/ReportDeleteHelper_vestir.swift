import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Vestir {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Vestir: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Vestir: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Vestir: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Vestir {
        static let postTitle_Vestir = "Delete Post"
        static let postMessage_Vestir = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Vestir = "Delete Comment"
        static let commentMessage_Vestir = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Vestir = "Delete"
        static let cancelButtonTitle_Vestir = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Vestir {
        case block_Vestir       // 拉黑用户
        case post_Vestir        // 举报帖子
        case comment_Vestir     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Vestir(
        user_Vestir: PrewUserModel_Vestir,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        UIAlertController.report_Vestir(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Vestir(
                user_Vestir: user_Vestir,
                viewController_Vestir: viewController_Vestir
            )
            completion_Vestir?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Vestir(
        post_Vestir: TitleModel_Vestir,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        UIAlertController.report_Vestir(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Vestir(
                post_Vestir: post_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir)
        })
    }
    
    /// 举报评论
    static func report_Vestir(
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        UIAlertController.report_Vestir(with: false, completeBlock: {
            performReportComment_Vestir(
                comment_Vestir: comment_Vestir,
                post_Vestir: post_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Vestir(
        post_Vestir: TitleModel_Vestir,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Vestir(
            title_Vestir: DeleteAlertConfig_Vestir.postTitle_Vestir,
            message_Vestir: DeleteAlertConfig_Vestir.postMessage_Vestir,
            from: viewController_Vestir
        ) {
            performDeletePost_Vestir(
                post_Vestir: post_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }
    }
    
    /// 删除评论
    static func delete_Vestir(
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Vestir(
            title_Vestir: DeleteAlertConfig_Vestir.commentTitle_Vestir,
            message_Vestir: DeleteAlertConfig_Vestir.commentMessage_Vestir,
            from: viewController_Vestir
        ) {
            performDeleteComment_Vestir(
                comment_Vestir: comment_Vestir,
                post_Vestir: post_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Vestir(
        title_Vestir: String,
        message_Vestir: String,
        from viewController_Vestir: UIViewController,
        completion_Vestir: @escaping () -> Void
    ) {
        let alert_Vestir = UIAlertController(
            title: title_Vestir,
            message: message_Vestir,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Vestir = UIAlertAction(
            title: DeleteAlertConfig_Vestir.deleteButtonTitle_Vestir,
            style: .destructive
        ) { _ in
            completion_Vestir()
        }
        
        // 取消按钮
        let cancelAction_Vestir = UIAlertAction(
            title: DeleteAlertConfig_Vestir.cancelButtonTitle_Vestir,
            style: .cancel,
            handler: nil
        )
        
        alert_Vestir.addAction(deleteAction_Vestir)
        alert_Vestir.addAction(cancelAction_Vestir)
        
        viewController_Vestir.present(alert_Vestir, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Vestir(
        action_Vestir: @escaping @MainActor () -> Void,
        completion_Vestir: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Vestir * 1_000_000_000))
            
            await action_Vestir()
            
            // 确保在主线程上执行回调
            if let completion_Vestir = completion_Vestir {
                await MainActor.run {
                    completion_Vestir()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Vestir(
        user_Vestir: PrewUserModel_Vestir,
        viewController_Vestir: UIViewController
    ) {
        performAsyncAction_Vestir(action_Vestir: {
            UserViewModel_Vestir.shared_Vestir.reportUser_Vestir(user_vestir: user_Vestir)
            print("已拉黑用户: \(user_Vestir.userName_Vestir ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Vestir(
        post_Vestir: TitleModel_Vestir,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        performAsyncAction_Vestir(
            action_Vestir: {
                TitleViewModel_Vestir.shared_Vestir.deletePost_Vestir(post_vestir: post_Vestir)
                print("已举报帖子: \(post_Vestir.title_Vestir)")
            },
            completion_Vestir: completion_Vestir
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Vestir(
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        performAsyncAction_Vestir(
            action_Vestir: {
                TitleViewModel_Vestir.shared_Vestir.deleteComment_Vestir(
                    post_vestir: post_Vestir,
                    comment_vestir: comment_Vestir
                )
                print("已举报评论: \(comment_Vestir.commentContent_Vestir)")
            },
            completion_Vestir: completion_Vestir
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Vestir(
        post_Vestir: TitleModel_Vestir,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        performAsyncAction_Vestir(
            action_Vestir: {
                TitleViewModel_Vestir.shared_Vestir.deletePost_Vestir(
                    post_vestir: post_Vestir,
                    isDelete_vestir: true
                )
                print("已删除帖子: \(post_Vestir.title_Vestir)")
            },
            completion_Vestir: completion_Vestir
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Vestir(
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) {
        performAsyncAction_Vestir(
            action_Vestir: {
                TitleViewModel_Vestir.shared_Vestir.deleteComment_Vestir(
                    post_vestir: post_Vestir,
                    comment_vestir: comment_Vestir,
                    isDelete_vestir: true
                )
                print("已删除评论: \(comment_Vestir.commentContent_Vestir)")
            },
            completion_Vestir: completion_Vestir
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Vestir(
        post_Vestir: TitleModel_Vestir,
        size_Vestir: CGFloat = 25,
        color_Vestir: UIColor = .black,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) -> UIButton {
        let button_Vestir = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Vestir = UserViewModel_Vestir.shared_Vestir.isCurrentUser_Vestir(
            userId_vestir: post_Vestir.titleUserId_Vestir
        )
        
        // 配置按钮图标
        let iconName_Vestir = isMyPost_Vestir ? "trash" : "ellipsis"
        configureButtonIcon_Vestir(
            button_Vestir: button_Vestir,
            iconName_Vestir: iconName_Vestir,
            size_Vestir: size_Vestir,
            color_Vestir: color_Vestir
        )
        
        button_Vestir.addAction(UIAction { [weak viewController_Vestir] _ in
            guard let viewController_Vestir = viewController_Vestir else { return }
            handlePostButtonTap_Vestir(
                button_Vestir: button_Vestir,
                post_Vestir: post_Vestir,
                isMyPost_Vestir: isMyPost_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }, for: .touchUpInside)
        
        return button_Vestir
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Vestir(
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        size_Vestir: CGFloat = 25,
        color_Vestir: UIColor = .black,
        from viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)? = nil
    ) -> UIButton {
        let button_Vestir = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Vestir = UserViewModel_Vestir.shared_Vestir.isCurrentUser_Vestir(
            userId_vestir: comment_Vestir.commentUserId_Vestir
        )
        
        // 配置按钮图标
        let iconName_Vestir = isMyComment_Vestir ? "trash" : "ellipsis"
        configureButtonIcon_Vestir(
            button_Vestir: button_Vestir,
            iconName_Vestir: iconName_Vestir,
            size_Vestir: size_Vestir,
            color_Vestir: color_Vestir
        )
        
        button_Vestir.addAction(UIAction { [weak viewController_Vestir] _ in
            guard let viewController_Vestir = viewController_Vestir else { return }
            handleCommentButtonTap_Vestir(
                button_Vestir: button_Vestir,
                comment_Vestir: comment_Vestir,
                post_Vestir: post_Vestir,
                isMyComment_Vestir: isMyComment_Vestir,
                viewController_Vestir: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }, for: .touchUpInside)
        
        return button_Vestir
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Vestir(
        size_Vestir: CGFloat = 44,
        backgroundColor_Vestir: UIColor? = nil,
        tintColor_Vestir: UIColor = .white,
        withShadow_Vestir: Bool = false
    ) -> UIButton {
        let button_Vestir = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Vestir = size_Vestir * 0.5
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: iconSize_Vestir, weight: .semibold)
        let image_Vestir = UIImage(systemName: "ellipsis", withConfiguration: config_Vestir)
        button_Vestir.setImage(image_Vestir, for: .normal)
        button_Vestir.tintColor = tintColor_Vestir
        
        // 设置背景
        let bgColor_Vestir = backgroundColor_Vestir ?? UIColor.white.withAlphaComponent(0.2)
        button_Vestir.backgroundColor = bgColor_Vestir
        button_Vestir.layer.cornerRadius = size_Vestir / 2
        
        // 添加阴影
        if withShadow_Vestir {
            button_Vestir.layer.shadowColor = UIColor.black.cgColor
            button_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Vestir.layer.shadowOpacity = 0.15
            button_Vestir.layer.shadowRadius = 8
        }
        
        return button_Vestir
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Vestir(button_Vestir: UIButton) {
        UIView.animate(withDuration: animationDuration_Vestir, animations: {
            button_Vestir.transform = CGAffineTransform(
                scaleX: animationScale_Vestir,
                y: animationScale_Vestir
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Vestir) {
                button_Vestir.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Vestir(
        button_Vestir: UIButton,
        iconName_Vestir: String,
        size_Vestir: CGFloat,
        color_Vestir: UIColor
    ) {
        let config_Vestir = UIImage.SymbolConfiguration(pointSize: size_Vestir, weight: .semibold)
        let image_Vestir = UIImage(systemName: iconName_Vestir, withConfiguration: config_Vestir)
        button_Vestir.setImage(image_Vestir, for: .normal)
        button_Vestir.tintColor = color_Vestir
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Vestir(
        button_Vestir: UIButton,
        post_Vestir: TitleModel_Vestir,
        isMyPost_Vestir: Bool,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)?
    ) {
        addButtonAnimation_Vestir(button_Vestir: button_Vestir)
        
        if isMyPost_Vestir {
            delete_Vestir(
                post_Vestir: post_Vestir,
                from: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        } else {
            report_Vestir(
                post_Vestir: post_Vestir,
                from: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Vestir(
        button_Vestir: UIButton,
        comment_Vestir: Comment_Vestir,
        post_Vestir: TitleModel_Vestir,
        isMyComment_Vestir: Bool,
        viewController_Vestir: UIViewController,
        completion_Vestir: (() -> Void)?
    ) {
        addButtonAnimation_Vestir(button_Vestir: button_Vestir)
        
        if isMyComment_Vestir {
            delete_Vestir(
                comment_Vestir: comment_Vestir,
                post_Vestir: post_Vestir,
                from: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        } else {
            report_Vestir(
                comment_Vestir: comment_Vestir,
                post_Vestir: post_Vestir,
                from: viewController_Vestir,
                completion_Vestir: completion_Vestir
            )
        }
    }
}
