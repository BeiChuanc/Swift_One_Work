import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Bague {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Bague: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Bague: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Bague: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Bague {
        static let postTitle_Bague = "Delete Post"
        static let postMessage_Bague = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Bague = "Delete Comment"
        static let commentMessage_Bague = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Bague = "Delete"
        static let cancelButtonTitle_Bague = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Bague {
        case block_Bague       // 拉黑用户
        case post_Bague        // 举报帖子
        case comment_Bague     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Bague(
        user_Bague: PrewUserModel_Bague,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        UIAlertController.report_Bague(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Bague(
                user_Bague: user_Bague,
                viewController_Bague: viewController_Bague
            )
            completion_Bague?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Bague(
        post_Bague: TitleModel_Bague,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        UIAlertController.report_Bague(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Bague(
                post_Bague: post_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague)
        })
    }
    
    /// 举报评论
    static func report_Bague(
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        UIAlertController.report_Bague(with: false, completeBlock: {
            performReportComment_Bague(
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Bague(
        post_Bague: TitleModel_Bague,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Bague(
            title_Bague: DeleteAlertConfig_Bague.postTitle_Bague,
            message_Bague: DeleteAlertConfig_Bague.postMessage_Bague,
            from: viewController_Bague
        ) {
            performDeletePost_Bague(
                post_Bague: post_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }
    }
    
    /// 删除评论
    static func delete_Bague(
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Bague(
            title_Bague: DeleteAlertConfig_Bague.commentTitle_Bague,
            message_Bague: DeleteAlertConfig_Bague.commentMessage_Bague,
            from: viewController_Bague
        ) {
            performDeleteComment_Bague(
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Bague(
        title_Bague: String,
        message_Bague: String,
        from viewController_Bague: UIViewController,
        completion_Bague: @escaping () -> Void
    ) {
        let alert_Bague = UIAlertController(
            title: title_Bague,
            message: message_Bague,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Bague = UIAlertAction(
            title: DeleteAlertConfig_Bague.deleteButtonTitle_Bague,
            style: .destructive
        ) { _ in
            completion_Bague()
        }
        
        // 取消按钮
        let cancelAction_Bague = UIAlertAction(
            title: DeleteAlertConfig_Bague.cancelButtonTitle_Bague,
            style: .cancel,
            handler: nil
        )
        
        alert_Bague.addAction(deleteAction_Bague)
        alert_Bague.addAction(cancelAction_Bague)
        
        viewController_Bague.present(alert_Bague, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Bague(
        action_Bague: @escaping @MainActor () -> Void,
        completion_Bague: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Bague * 1_000_000_000))
            
            await action_Bague()
            
            // 确保在主线程上执行回调
            if let completion_Bague = completion_Bague {
                await MainActor.run {
                    completion_Bague()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Bague(
        user_Bague: PrewUserModel_Bague,
        viewController_Bague: UIViewController
    ) {
        performAsyncAction_Bague(action_Bague: {
            UserViewModel_Bague.shared_Bague.reportUser_Bague(user_bague: user_Bague)
            print("已拉黑用户: \(user_Bague.userName_Bague ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Bague(
        post_Bague: TitleModel_Bague,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        performAsyncAction_Bague(
            action_Bague: {
                TitleViewModel_Bague.shared_Bague.deletePost_Bague(post_bague: post_Bague)
                print("已举报帖子: \(post_Bague.title_Bague)")
            },
            completion_Bague: completion_Bague
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Bague(
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        performAsyncAction_Bague(
            action_Bague: {
                TitleViewModel_Bague.shared_Bague.deleteComment_Bague(
                    post_bague: post_Bague,
                    comment_bague: comment_Bague
                )
                print("已举报评论: \(comment_Bague.commentContent_Bague)")
            },
            completion_Bague: completion_Bague
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Bague(
        post_Bague: TitleModel_Bague,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        performAsyncAction_Bague(
            action_Bague: {
                TitleViewModel_Bague.shared_Bague.deletePost_Bague(
                    post_bague: post_Bague,
                    isDelete_bague: true
                )
                print("已删除帖子: \(post_Bague.title_Bague)")
            },
            completion_Bague: completion_Bague
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Bague(
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) {
        performAsyncAction_Bague(
            action_Bague: {
                TitleViewModel_Bague.shared_Bague.deleteComment_Bague(
                    post_bague: post_Bague,
                    comment_bague: comment_Bague,
                    isDelete_bague: true
                )
                print("已删除评论: \(comment_Bague.commentContent_Bague)")
            },
            completion_Bague: completion_Bague
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Bague(
        post_Bague: TitleModel_Bague,
        size_Bague: CGFloat = 25,
        color_Bague: UIColor = .black,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Bague = UserViewModel_Bague.shared_Bague.isCurrentUser_Bague(
            userId_bague: post_Bague.titleUserId_Bague
        )
        
        // 配置按钮图标
        let iconName_Bague = isMyPost_Bague ? "trash" : "ellipsis"
        configureButtonIcon_Bague(
            button_Bague: button_Bague,
            iconName_Bague: iconName_Bague,
            size_Bague: size_Bague,
            color_Bague: color_Bague
        )
        
        button_Bague.addAction(UIAction { [weak viewController_Bague] _ in
            guard let viewController_Bague = viewController_Bague else { return }
            handlePostButtonTap_Bague(
                button_Bague: button_Bague,
                post_Bague: post_Bague,
                isMyPost_Bague: isMyPost_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }, for: .touchUpInside)
        
        return button_Bague
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Bague(
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        size_Bague: CGFloat = 25,
        color_Bague: UIColor = .black,
        from viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)? = nil
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Bague = UserViewModel_Bague.shared_Bague.isCurrentUser_Bague(
            userId_bague: comment_Bague.commentUserId_Bague
        )
        
        // 配置按钮图标
        let iconName_Bague = isMyComment_Bague ? "trash" : "ellipsis"
        configureButtonIcon_Bague(
            button_Bague: button_Bague,
            iconName_Bague: iconName_Bague,
            size_Bague: size_Bague,
            color_Bague: color_Bague
        )
        
        button_Bague.addAction(UIAction { [weak viewController_Bague] _ in
            guard let viewController_Bague = viewController_Bague else { return }
            handleCommentButtonTap_Bague(
                button_Bague: button_Bague,
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                isMyComment_Bague: isMyComment_Bague,
                viewController_Bague: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }, for: .touchUpInside)
        
        return button_Bague
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Bague(
        size_Bague: CGFloat = 44,
        backgroundColor_Bague: UIColor? = nil,
        tintColor_Bague: UIColor = .white,
        withShadow_Bague: Bool = false
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Bague = size_Bague * 0.5
        let config_Bague = UIImage.SymbolConfiguration(pointSize: iconSize_Bague, weight: .semibold)
        let image_Bague = UIImage(systemName: "ellipsis", withConfiguration: config_Bague)
        button_Bague.setImage(image_Bague, for: .normal)
        button_Bague.tintColor = tintColor_Bague
        
        // 设置背景
        let bgColor_Bague = backgroundColor_Bague ?? UIColor.white.withAlphaComponent(0.2)
        button_Bague.backgroundColor = bgColor_Bague
        button_Bague.layer.cornerRadius = size_Bague / 2
        
        // 添加阴影
        if withShadow_Bague {
            button_Bague.layer.shadowColor = UIColor.black.cgColor
            button_Bague.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Bague.layer.shadowOpacity = 0.15
            button_Bague.layer.shadowRadius = 8
        }
        
        return button_Bague
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Bague(button_Bague: UIButton) {
        UIView.animate(withDuration: animationDuration_Bague, animations: {
            button_Bague.transform = CGAffineTransform(
                scaleX: animationScale_Bague,
                y: animationScale_Bague
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Bague) {
                button_Bague.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Bague(
        button_Bague: UIButton,
        iconName_Bague: String,
        size_Bague: CGFloat,
        color_Bague: UIColor
    ) {
        let config_Bague = UIImage.SymbolConfiguration(pointSize: size_Bague, weight: .semibold)
        let image_Bague = UIImage(systemName: iconName_Bague, withConfiguration: config_Bague)
        button_Bague.setImage(image_Bague, for: .normal)
        button_Bague.tintColor = color_Bague
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Bague(
        button_Bague: UIButton,
        post_Bague: TitleModel_Bague,
        isMyPost_Bague: Bool,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)?
    ) {
        addButtonAnimation_Bague(button_Bague: button_Bague)
        
        if isMyPost_Bague {
            delete_Bague(
                post_Bague: post_Bague,
                from: viewController_Bague,
                completion_Bague: completion_Bague
            )
        } else {
            report_Bague(
                post_Bague: post_Bague,
                from: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Bague(
        button_Bague: UIButton,
        comment_Bague: Comment_Bague,
        post_Bague: TitleModel_Bague,
        isMyComment_Bague: Bool,
        viewController_Bague: UIViewController,
        completion_Bague: (() -> Void)?
    ) {
        addButtonAnimation_Bague(button_Bague: button_Bague)
        
        if isMyComment_Bague {
            delete_Bague(
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                from: viewController_Bague,
                completion_Bague: completion_Bague
            )
        } else {
            report_Bague(
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                from: viewController_Bague,
                completion_Bague: completion_Bague
            )
        }
    }

    // MARK: - 弹幕操作按钮

    /// 创建弹幕删除/举报按钮
    /// - Parameters:
    ///   - barrageUserId_Bague: 弹幕发布者用户 ID
    ///   - size_Bague: 图标尺寸
    ///   - color_Bague: 图标颜色
    ///   - viewController_Bague: 用于弹出操作面板的宿主控制器
    ///   - onDelete_Bague: 确认删除后的回调（仅本人弹幕触发）
    /// - Returns: 配置好的 UIButton（本人→trash 删除，他人→ellipsis 举报）
    @MainActor static func createBarrageActionButton_Bague(
        barrageUserId_Bague: Int,
        size_Bague: CGFloat = 13,
        color_Bague: UIColor = UIColor(hexstring_Bague: "#9B72F5"),
        from viewController_Bague: UIViewController,
        onDelete_Bague: @escaping () -> Void
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        let isOwn_Bague = UserViewModel_Bague.shared_Bague.isCurrentUser_Bague(userId_bague: barrageUserId_Bague)
        let iconName_Bague = isOwn_Bague ? "trash" : "ellipsis"
        configureButtonIcon_Bague(
            button_Bague: button_Bague,
            iconName_Bague: iconName_Bague,
            size_Bague: size_Bague,
            color_Bague: color_Bague
        )
        button_Bague.addAction(UIAction { [weak viewController_Bague] _ in
            guard let vc_bague = viewController_Bague else { return }
            addButtonAnimation_Bague(button_Bague: button_Bague)
            if isOwn_Bague {
                // 本人弹幕：确认删除
                showDeleteConfirmAlert_Bague(
                    title_Bague: "Delete Barrage",
                    message_Bague: "Remove this barrage? This action cannot be undone.",
                    from: vc_bague,
                    completion_Bague: onDelete_Bague
                )
            } else {
                // 他人弹幕：举报/拉黑
                let user_bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: barrageUserId_Bague)
                block_Bague(user_Bague: user_bague, from: vc_bague)
            }
        }, for: .touchUpInside)
        return button_Bague
    }

    // MARK: - 藏包册删除按钮

    /// 创建我的藏包册卡片的删除按钮
    /// - 始终显示 trash 图标（仅本人藏包，不存在举报场景）
    /// - Parameters:
    ///   - size_Bague: 图标尺寸
    ///   - viewController_Bague: 用于弹出确认框的宿主控制器
    ///   - onDelete_Bague: 用户确认删除后的回调
    /// - Returns: 配置好的 UIButton
    @MainActor static func createBagDeleteButton_Bague(
        size_Bague: CGFloat = 12,
        from viewController_Bague: UIViewController,
        onDelete_Bague: @escaping () -> Void
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        configureButtonIcon_Bague(
            button_Bague: button_Bague,
            iconName_Bague: "xmark",
            size_Bague: size_Bague,
            color_Bague: .white
        )
        button_Bague.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        button_Bague.layer.cornerRadius = 12
        button_Bague.addAction(UIAction { [weak viewController_Bague] _ in
            guard let vc_bague = viewController_Bague else { return }
            addButtonAnimation_Bague(button_Bague: button_Bague)
            showDeleteConfirmAlert_Bague(
                title_Bague: "Remove from Collection",
                message_Bague: "Remove this bag from your collection book? This action cannot be undone.",
                from: vc_bague,
                completion_Bague: onDelete_Bague
            )
        }, for: .touchUpInside)
        return button_Bague
    }

    // MARK: - 中古故事馆评论操作按钮

    /// 创建中古故事馆评论操作按钮
    /// - 本人评论：trash 图标 → 删除确认弹窗 → onDelete 回调
    /// - 他人评论：ellipsis 图标 → block_Bague 举报/拉黑用户
    /// - Parameters:
    ///   - commentUserId_Bague: 评论发布者用户 ID
    ///   - size_Bague: 图标尺寸
    ///   - color_Bague: 图标颜色（他人评论场景）
    ///   - viewController_Bague: 用于弹出操作面板的宿主控制器
    ///   - onDelete_Bague: 删除确认后的回调（仅本人评论触发）
    @MainActor static func createVintageCommentButton_Bague(
        commentUserId_Bague: Int,
        size_Bague: CGFloat = 13,
        color_Bague: UIColor = UIColor(hexstring_Bague: "#F07DAD"),
        from viewController_Bague: UIViewController,
        onDelete_Bague: @escaping () -> Void
    ) -> UIButton {
        let button_Bague = UIButton(type: .system)
        let isOwn_Bague = UserViewModel_Bague.shared_Bague.isCurrentUser_Bague(userId_bague: commentUserId_Bague)
        let iconName_Bague = isOwn_Bague ? "trash" : "ellipsis"
        let iconColor_Bague: UIColor = isOwn_Bague
            ? UIColor(hexstring_Bague: "#FF6B6B")
            : color_Bague.withAlphaComponent(0.65)
        configureButtonIcon_Bague(
            button_Bague: button_Bague,
            iconName_Bague: iconName_Bague,
            size_Bague: size_Bague,
            color_Bague: iconColor_Bague
        )
        button_Bague.addAction(UIAction { [weak viewController_Bague] _ in
            guard let vc_bague = viewController_Bague else { return }
            addButtonAnimation_Bague(button_Bague: button_Bague)
            if isOwn_Bague {
                // 本人评论：确认删除
                showDeleteConfirmAlert_Bague(
                    title_Bague: "Delete Comment",
                    message_Bague: "Delete this comment? This action cannot be undone.",
                    from: vc_bague,
                    completion_Bague: onDelete_Bague
                )
            } else {
                // 他人评论：举报/拉黑发布者
                let user_bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: commentUserId_Bague)
                block_Bague(user_Bague: user_bague, from: vc_bague)
            }
        }, for: .touchUpInside)
        return button_Bague
    }
}
