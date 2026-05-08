import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Posture {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Posture: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Posture: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Posture: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Posture {
        static let postTitle_Posture = "Delete Post"
        static let postMessage_Posture = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Posture = "Delete Comment"
        static let commentMessage_Posture = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Posture = "Delete"
        static let cancelButtonTitle_Posture = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Posture {
        case block_Posture       // 拉黑用户
        case post_Posture        // 举报帖子
        case comment_Posture     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Posture(
        user_Posture: PrewUserModel_Posture,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        UIAlertController.report_Posture(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Posture(
                user_Posture: user_Posture,
                viewController_Posture: viewController_Posture
            )
            completion_Posture?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Posture(
        post_Posture: TitleModel_Posture,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        UIAlertController.report_Posture(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Posture(
                post_Posture: post_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture)
        })
    }
    
    /// 举报评论
    static func report_Posture(
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        UIAlertController.report_Posture(with: false, completeBlock: {
            performReportComment_Posture(
                comment_Posture: comment_Posture,
                post_Posture: post_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Posture(
        post_Posture: TitleModel_Posture,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Posture(
            title_Posture: DeleteAlertConfig_Posture.postTitle_Posture,
            message_Posture: DeleteAlertConfig_Posture.postMessage_Posture,
            from: viewController_Posture
        ) {
            performDeletePost_Posture(
                post_Posture: post_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }
    }
    
    /// 删除评论
    static func delete_Posture(
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Posture(
            title_Posture: DeleteAlertConfig_Posture.commentTitle_Posture,
            message_Posture: DeleteAlertConfig_Posture.commentMessage_Posture,
            from: viewController_Posture
        ) {
            performDeleteComment_Posture(
                comment_Posture: comment_Posture,
                post_Posture: post_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Posture(
        title_Posture: String,
        message_Posture: String,
        from viewController_Posture: UIViewController,
        completion_Posture: @escaping () -> Void
    ) {
        let alert_Posture = UIAlertController(
            title: title_Posture,
            message: message_Posture,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Posture = UIAlertAction(
            title: DeleteAlertConfig_Posture.deleteButtonTitle_Posture,
            style: .destructive
        ) { _ in
            completion_Posture()
        }
        
        // 取消按钮
        let cancelAction_Posture = UIAlertAction(
            title: DeleteAlertConfig_Posture.cancelButtonTitle_Posture,
            style: .cancel,
            handler: nil
        )
        
        alert_Posture.addAction(deleteAction_Posture)
        alert_Posture.addAction(cancelAction_Posture)
        
        viewController_Posture.present(alert_Posture, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Posture(
        action_Posture: @escaping @MainActor () -> Void,
        completion_Posture: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Posture * 1_000_000_000))
            
            await action_Posture()
            
            // 确保在主线程上执行回调
            if let completion_Posture = completion_Posture {
                await MainActor.run {
                    completion_Posture()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Posture(
        user_Posture: PrewUserModel_Posture,
        viewController_Posture: UIViewController
    ) {
        performAsyncAction_Posture(action_Posture: {
            UserViewModel_Posture.shared_Posture.reportUser_Posture(user_posture: user_Posture)
            print("已拉黑用户: \(user_Posture.userName_Posture ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Posture(
        post_Posture: TitleModel_Posture,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        performAsyncAction_Posture(
            action_Posture: {
                TitleViewModel_Posture.shared_Posture.deletePost_Posture(post_posture: post_Posture)
                print("已举报帖子: \(post_Posture.title_Posture)")
            },
            completion_Posture: completion_Posture
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Posture(
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        performAsyncAction_Posture(
            action_Posture: {
                TitleViewModel_Posture.shared_Posture.deleteComment_Posture(
                    post_posture: post_Posture,
                    comment_posture: comment_Posture
                )
                print("已举报评论: \(comment_Posture.commentContent_Posture)")
            },
            completion_Posture: completion_Posture
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Posture(
        post_Posture: TitleModel_Posture,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        performAsyncAction_Posture(
            action_Posture: {
                TitleViewModel_Posture.shared_Posture.deletePost_Posture(
                    post_posture: post_Posture,
                    isDelete_posture: true
                )
                print("已删除帖子: \(post_Posture.title_Posture)")
            },
            completion_Posture: completion_Posture
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Posture(
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) {
        performAsyncAction_Posture(
            action_Posture: {
                TitleViewModel_Posture.shared_Posture.deleteComment_Posture(
                    post_posture: post_Posture,
                    comment_posture: comment_Posture,
                    isDelete_posture: true
                )
                print("已删除评论: \(comment_Posture.commentContent_Posture)")
            },
            completion_Posture: completion_Posture
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Posture(
        post_Posture: TitleModel_Posture,
        size_Posture: CGFloat = 25,
        color_Posture: UIColor = .black,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) -> UIButton {
        let button_Posture = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Posture = UserViewModel_Posture.shared_Posture.isCurrentUser_Posture(
            userId_posture: post_Posture.titleUserId_Posture
        )
        
        // 配置按钮图标
        let iconName_Posture = isMyPost_Posture ? "trash" : "ellipsis"
        configureButtonIcon_Posture(
            button_Posture: button_Posture,
            iconName_Posture: iconName_Posture,
            size_Posture: size_Posture,
            color_Posture: color_Posture
        )
        
        button_Posture.addAction(UIAction { [weak viewController_Posture] _ in
            guard let viewController_Posture = viewController_Posture else { return }
            handlePostButtonTap_Posture(
                button_Posture: button_Posture,
                post_Posture: post_Posture,
                isMyPost_Posture: isMyPost_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }, for: .touchUpInside)
        
        return button_Posture
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Posture(
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        size_Posture: CGFloat = 25,
        color_Posture: UIColor = .black,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) -> UIButton {
        let button_Posture = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Posture = UserViewModel_Posture.shared_Posture.isCurrentUser_Posture(
            userId_posture: comment_Posture.commentUserId_Posture
        )
        
        // 配置按钮图标
        let iconName_Posture = isMyComment_Posture ? "trash" : "ellipsis"
        configureButtonIcon_Posture(
            button_Posture: button_Posture,
            iconName_Posture: iconName_Posture,
            size_Posture: size_Posture,
            color_Posture: color_Posture
        )
        
        button_Posture.addAction(UIAction { [weak viewController_Posture] _ in
            guard let viewController_Posture = viewController_Posture else { return }
            handleCommentButtonTap_Posture(
                button_Posture: button_Posture,
                comment_Posture: comment_Posture,
                post_Posture: post_Posture,
                isMyComment_Posture: isMyComment_Posture,
                viewController_Posture: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }, for: .touchUpInside)
        
        return button_Posture
    }
    
    /// 创建话题评论举报/删除按钮
    /// - Parameters:
    ///   - comment_Posture: 目标评论
    ///   - topicId_Posture: 所属话题 ID
    ///   - size_Posture: 图标尺寸
    ///   - color_Posture: 图标颜色
    ///   - viewController_Posture: 发起操作的视图控制器
    ///   - completion_Posture: 操作完成回调
    /// - Returns: UIButton - 已配置的举报/删除按钮
    @MainActor static func createTopicCommentReportButton_Posture(
        comment_Posture: Comment_Posture,
        topicId_Posture: Int,
        size_Posture: CGFloat = 25,
        color_Posture: UIColor = .black,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)? = nil
    ) -> UIButton {
        let button_Posture = UIButton(type: .system)
        let isMyComment_Posture = UserViewModel_Posture.shared_Posture.isCurrentUser_Posture(
            userId_posture: comment_Posture.commentUserId_Posture
        )
        let iconName_Posture = isMyComment_Posture ? "trash" : "ellipsis"
        configureButtonIcon_Posture(
            button_Posture: button_Posture,
            iconName_Posture: iconName_Posture,
            size_Posture: size_Posture,
            color_Posture: color_Posture
        )
        button_Posture.addAction(UIAction { [weak viewController_Posture] _ in
            guard let viewController_Posture = viewController_Posture else { return }
            addButtonAnimation_Posture(button_Posture: button_Posture)
            if isMyComment_Posture {
                showDeleteTopicCommentAlert_Posture(
                    comment_Posture: comment_Posture,
                    topicId_Posture: topicId_Posture,
                    from: viewController_Posture,
                    completion_Posture: completion_Posture
                )
            } else {
                UIAlertController.report_Posture(with: false) {
                    performAsyncAction_Posture(action_Posture: {
                        TitleViewModel_Posture.shared_Posture.deleteTopicComment_Posture(
                            topicId_posture: topicId_Posture,
                            comment_posture: comment_Posture
                        )
                    }, completion_Posture: completion_Posture)
                }
            }
        }, for: .touchUpInside)
        return button_Posture
    }

    /// 显示话题评论删除确认弹窗
    private static func showDeleteTopicCommentAlert_Posture(
        comment_Posture: Comment_Posture,
        topicId_Posture: Int,
        from viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)?
    ) {
        showDeleteConfirmAlert_Posture(
            title_Posture: DeleteAlertConfig_Posture.commentTitle_Posture,
            message_Posture: DeleteAlertConfig_Posture.commentMessage_Posture,
            from: viewController_Posture
        ) {
            performAsyncAction_Posture(action_Posture: {
                TitleViewModel_Posture.shared_Posture.deleteTopicComment_Posture(
                    topicId_posture: topicId_Posture,
                    comment_posture: comment_Posture,
                    isDelete_posture: true
                )
            }, completion_Posture: completion_Posture)
        }
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Posture(
        size_Posture: CGFloat = 44,
        backgroundColor_Posture: UIColor? = nil,
        tintColor_Posture: UIColor = .white,
        withShadow_Posture: Bool = false
    ) -> UIButton {
        let button_Posture = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Posture = size_Posture * 0.5
        let config_Posture = UIImage.SymbolConfiguration(pointSize: iconSize_Posture, weight: .semibold)
        let image_Posture = UIImage(systemName: "ellipsis", withConfiguration: config_Posture)
        button_Posture.setImage(image_Posture, for: .normal)
        button_Posture.tintColor = tintColor_Posture
        
        // 设置背景
        let bgColor_Posture = backgroundColor_Posture ?? UIColor.white.withAlphaComponent(0.2)
        button_Posture.backgroundColor = bgColor_Posture
        button_Posture.layer.cornerRadius = size_Posture / 2
        
        // 添加阴影
        if withShadow_Posture {
            button_Posture.layer.shadowColor = UIColor.black.cgColor
            button_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Posture.layer.shadowOpacity = 0.15
            button_Posture.layer.shadowRadius = 8
        }
        
        return button_Posture
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Posture(button_Posture: UIButton) {
        UIView.animate(withDuration: animationDuration_Posture, animations: {
            button_Posture.transform = CGAffineTransform(
                scaleX: animationScale_Posture,
                y: animationScale_Posture
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Posture) {
                button_Posture.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Posture(
        button_Posture: UIButton,
        iconName_Posture: String,
        size_Posture: CGFloat,
        color_Posture: UIColor
    ) {
        let config_Posture = UIImage.SymbolConfiguration(pointSize: size_Posture, weight: .semibold)
        let image_Posture = UIImage(systemName: iconName_Posture, withConfiguration: config_Posture)
        button_Posture.setImage(image_Posture, for: .normal)
        button_Posture.tintColor = color_Posture
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Posture(
        button_Posture: UIButton,
        post_Posture: TitleModel_Posture,
        isMyPost_Posture: Bool,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)?
    ) {
        addButtonAnimation_Posture(button_Posture: button_Posture)
        
        if isMyPost_Posture {
            delete_Posture(
                post_Posture: post_Posture,
                from: viewController_Posture,
                completion_Posture: completion_Posture
            )
        } else {
            report_Posture(
                post_Posture: post_Posture,
                from: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Posture(
        button_Posture: UIButton,
        comment_Posture: Comment_Posture,
        post_Posture: TitleModel_Posture,
        isMyComment_Posture: Bool,
        viewController_Posture: UIViewController,
        completion_Posture: (() -> Void)?
    ) {
        addButtonAnimation_Posture(button_Posture: button_Posture)
        
        if isMyComment_Posture {
            delete_Posture(
                comment_Posture: comment_Posture,
                post_Posture: post_Posture,
                from: viewController_Posture,
                completion_Posture: completion_Posture
            )
        } else {
            report_Posture(
                comment_Posture: comment_Posture,
                post_Posture: post_Posture,
                from: viewController_Posture,
                completion_Posture: completion_Posture
            )
        }
    }
}
