import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Flick {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Flick: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Flick: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Flick: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Flick {
        static let postTitle_Flick = "Delete Post"
        static let postMessage_Flick = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Flick = "Delete Comment"
        static let commentMessage_Flick = "Are you sure you want to delete this comment? This action cannot be undone."
        static let challengeCompletionTitle_Flick = "Delete Completion"
        static let challengeCompletionMessage_Flick = "Are you sure you want to delete this completion? This action cannot be undone."
        static let deleteButtonTitle_Flick = "Delete"
        static let cancelButtonTitle_Flick = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Flick {
        case block_Flick       // 拉黑用户
        case post_Flick        // 举报帖子
        case comment_Flick     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Flick(
        user_Flick: PrewUserModel_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        UIAlertController.report_Flick(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Flick(
                user_Flick: user_Flick,
                viewController_Flick: viewController_Flick
            )
            completion_Flick?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Flick(
        post_Flick: TitleModel_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        UIAlertController.report_Flick(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Flick(
                post_Flick: post_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick)
        })
    }
    
    /// 举报评论
    static func report_Flick(
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        UIAlertController.report_Flick(with: false, completeBlock: {
            performReportComment_Flick(
                comment_Flick: comment_Flick,
                post_Flick: post_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Flick(
        post_Flick: TitleModel_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Flick(
            title_Flick: DeleteAlertConfig_Flick.postTitle_Flick,
            message_Flick: DeleteAlertConfig_Flick.postMessage_Flick,
            from: viewController_Flick
        ) {
            performDeletePost_Flick(
                post_Flick: post_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }
    }
    
    /// 删除评论
    static func delete_Flick(
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Flick(
            title_Flick: DeleteAlertConfig_Flick.commentTitle_Flick,
            message_Flick: DeleteAlertConfig_Flick.commentMessage_Flick,
            from: viewController_Flick
        ) {
            performDeleteComment_Flick(
                comment_Flick: comment_Flick,
                post_Flick: post_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }
    }

    // MARK: - 官方挑战补全（举报 / 删除）

    /// 举报他人对官方挑战的补全（统一举报弹窗，确认后移除该补全）
    /// - Parameters:
    ///   - comment_Flick: 补全对应的评论模型
    ///   - challenge_Flick: 所属挑战
    ///   - viewController_Flick: 发起页面
    ///   - completion_Flick: 异步操作结束回调，可选
    static func reportChallengeCompletion_Flick(
        comment_Flick: Comment_Flick,
        challenge_Flick: HalfChallenge_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        UIAlertController.report_Flick(with: false, completeBlock: {
            performReportChallengeCompletion_Flick(
                comment_Flick: comment_Flick,
                challenge_Flick: challenge_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        })
    }

    /// 删除本人对官方挑战的补全
    /// - Parameters:
    ///   - comment_Flick: 补全对应的评论模型
    ///   - challenge_Flick: 所属挑战
    ///   - viewController_Flick: 发起页面
    ///   - completion_Flick: 异步操作结束回调，可选
    static func deleteChallengeCompletion_Flick(
        comment_Flick: Comment_Flick,
        challenge_Flick: HalfChallenge_Flick,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Flick(
            title_Flick: DeleteAlertConfig_Flick.challengeCompletionTitle_Flick,
            message_Flick: DeleteAlertConfig_Flick.challengeCompletionMessage_Flick,
            from: viewController_Flick
        ) {
            performDeleteChallengeCompletion_Flick(
                comment_Flick: comment_Flick,
                challenge_Flick: challenge_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }
    }

    /// 举报官方挑战主体（仅提交举报流程，不改变挑战列表数据）
    /// - Parameters:
    ///   - viewController_Flick: 发起页面
    ///   - completion_Flick: 异步操作结束回调，可选
    static func reportOfficialChallenge_Flick(
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        // 与评论/帖子接口保持 from 参数，便于后续改为由指定 VC 弹出
        _ = viewController_Flick
        UIAlertController.report_Flick(with: false, completeBlock: {
            performAsyncAction_Flick(
                action_Flick: {
                    print("已提交官方挑战举报反馈")
                },
                completion_Flick: completion_Flick
            )
        })
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Flick(
        title_Flick: String,
        message_Flick: String,
        from viewController_Flick: UIViewController,
        completion_Flick: @escaping () -> Void
    ) {
        let alert_Flick = UIAlertController(
            title: title_Flick,
            message: message_Flick,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Flick = UIAlertAction(
            title: DeleteAlertConfig_Flick.deleteButtonTitle_Flick,
            style: .destructive
        ) { _ in
            completion_Flick()
        }
        
        // 取消按钮
        let cancelAction_Flick = UIAlertAction(
            title: DeleteAlertConfig_Flick.cancelButtonTitle_Flick,
            style: .cancel,
            handler: nil
        )
        
        alert_Flick.addAction(deleteAction_Flick)
        alert_Flick.addAction(cancelAction_Flick)
        
        viewController_Flick.present(alert_Flick, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Flick(
        action_Flick: @escaping @MainActor () -> Void,
        completion_Flick: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Flick * 1_000_000_000))
            
            await action_Flick()
            
            // 确保在主线程上执行回调
            if let completion_Flick = completion_Flick {
                await MainActor.run {
                    completion_Flick()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Flick(
        user_Flick: PrewUserModel_Flick,
        viewController_Flick: UIViewController
    ) {
        performAsyncAction_Flick(action_Flick: {
            UserViewModel_Flick.shared_Flick.reportUser_Flick(user_flick: user_Flick)
            print("已拉黑用户: \(user_Flick.userName_Flick ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Flick(
        post_Flick: TitleModel_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deletePost_Flick(post_flick: post_Flick)
                print("已举报帖子: \(post_Flick.title_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Flick(
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deleteComment_Flick(
                    post_flick: post_Flick,
                    comment_flick: comment_Flick
                )
                print("已举报评论: \(comment_Flick.commentContent_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Flick(
        post_Flick: TitleModel_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deletePost_Flick(
                    post_flick: post_Flick,
                    isDelete_flick: true
                )
                print("已删除帖子: \(post_Flick.title_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Flick(
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deleteComment_Flick(
                    post_flick: post_Flick,
                    comment_flick: comment_Flick,
                    isDelete_flick: true
                )
                print("已删除评论: \(comment_Flick.commentContent_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }

    /// 执行举报挑战补全（从挑战中移除该条）
    private static func performReportChallengeCompletion_Flick(
        comment_Flick: Comment_Flick,
        challenge_Flick: HalfChallenge_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deleteChallengeCompletion_Flick(
                    challenge_flick: challenge_Flick,
                    commentId_flick: comment_Flick.commentId_Flick
                )
                print("已举报并移除挑战补全: \(comment_Flick.commentContent_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }

    /// 执行删除挑战补全
    private static func performDeleteChallengeCompletion_Flick(
        comment_Flick: Comment_Flick,
        challenge_Flick: HalfChallenge_Flick,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        performAsyncAction_Flick(
            action_Flick: {
                TitleViewModel_Flick.shared_Flick.deleteChallengeCompletion_Flick(
                    challenge_flick: challenge_Flick,
                    commentId_flick: comment_Flick.commentId_Flick
                )
                print("已删除本人挑战补全: \(comment_Flick.commentContent_Flick)")
            },
            completion_Flick: completion_Flick
        )
    }
    
    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Flick(
        post_Flick: TitleModel_Flick,
        size_Flick: CGFloat = 25,
        color_Flick: UIColor = .black,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) -> UIButton {
        let button_Flick = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: post_Flick.titleUserId_Flick
        )
        
        // 配置按钮图标
        let iconName_Flick = isMyPost_Flick ? "trash" : "ellipsis"
        configureButtonIcon_Flick(
            button_Flick: button_Flick,
            iconName_Flick: iconName_Flick,
            size_Flick: size_Flick,
            color_Flick: color_Flick
        )
        
        button_Flick.addAction(UIAction { [weak viewController_Flick] _ in
            guard let viewController_Flick = viewController_Flick else { return }
            handlePostButtonTap_Flick(
                button_Flick: button_Flick,
                post_Flick: post_Flick,
                isMyPost_Flick: isMyPost_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }, for: .touchUpInside)
        
        return button_Flick
    }

    /// 详情页右上角已有按钮时，直接走举报/删除帖子流程（避免临时创建按钮再 sendActions）
    /// - Parameters:
    ///   - post_Flick: 当前帖子
    ///   - actionButton_Flick: 用于点击缩放动画的已有按钮
    ///   - viewController_Flick: 宿主控制器
    ///   - completion_Flick: 异步操作结束回调（主线程）
    @MainActor static func runPostReportOrDeleteFromDetail_Flick(
        post_Flick: TitleModel_Flick,
        actionButton_Flick: UIButton,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) {
        let isMyPost_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: post_Flick.titleUserId_Flick
        )
        handlePostButtonTap_Flick(
            button_Flick: actionButton_Flick,
            post_Flick: post_Flick,
            isMyPost_Flick: isMyPost_Flick,
            viewController_Flick: viewController_Flick,
            completion_Flick: completion_Flick
        )
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Flick(
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        size_Flick: CGFloat = 25,
        color_Flick: UIColor = .black,
        from viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)? = nil
    ) -> UIButton {
        let button_Flick = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Flick = UserViewModel_Flick.shared_Flick.isCurrentUser_Flick(
            userId_flick: comment_Flick.commentUserId_Flick
        )
        
        // 配置按钮图标
        let iconName_Flick = isMyComment_Flick ? "trash" : "ellipsis"
        configureButtonIcon_Flick(
            button_Flick: button_Flick,
            iconName_Flick: iconName_Flick,
            size_Flick: size_Flick,
            color_Flick: color_Flick
        )
        
        button_Flick.addAction(UIAction { [weak viewController_Flick] _ in
            guard let viewController_Flick = viewController_Flick else { return }
            handleCommentButtonTap_Flick(
                button_Flick: button_Flick,
                comment_Flick: comment_Flick,
                post_Flick: post_Flick,
                isMyComment_Flick: isMyComment_Flick,
                viewController_Flick: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }, for: .touchUpInside)
        
        return button_Flick
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Flick(
        size_Flick: CGFloat = 44,
        backgroundColor_Flick: UIColor? = nil,
        tintColor_Flick: UIColor = .white,
        withShadow_Flick: Bool = false
    ) -> UIButton {
        let button_Flick = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Flick = size_Flick * 0.5
        let config_Flick = UIImage.SymbolConfiguration(pointSize: iconSize_Flick, weight: .semibold)
        let image_Flick = UIImage(systemName: "ellipsis", withConfiguration: config_Flick)
        button_Flick.setImage(image_Flick, for: .normal)
        button_Flick.tintColor = tintColor_Flick
        
        // 设置背景
        let bgColor_Flick = backgroundColor_Flick ?? UIColor.white.withAlphaComponent(0.2)
        button_Flick.backgroundColor = bgColor_Flick
        button_Flick.layer.cornerRadius = size_Flick / 2
        
        // 添加阴影
        if withShadow_Flick {
            button_Flick.layer.shadowColor = UIColor.black.cgColor
            button_Flick.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Flick.layer.shadowOpacity = 0.15
            button_Flick.layer.shadowRadius = 8
        }
        
        return button_Flick
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Flick(button_Flick: UIButton) {
        UIView.animate(withDuration: animationDuration_Flick, animations: {
            button_Flick.transform = CGAffineTransform(
                scaleX: animationScale_Flick,
                y: animationScale_Flick
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Flick) {
                button_Flick.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Flick(
        button_Flick: UIButton,
        iconName_Flick: String,
        size_Flick: CGFloat,
        color_Flick: UIColor
    ) {
        let config_Flick = UIImage.SymbolConfiguration(pointSize: size_Flick, weight: .semibold)
        let image_Flick = UIImage(systemName: iconName_Flick, withConfiguration: config_Flick)
        button_Flick.setImage(image_Flick, for: .normal)
        button_Flick.tintColor = color_Flick
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Flick(
        button_Flick: UIButton,
        post_Flick: TitleModel_Flick,
        isMyPost_Flick: Bool,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)?
    ) {
        addButtonAnimation_Flick(button_Flick: button_Flick)
        
        if isMyPost_Flick {
            delete_Flick(
                post_Flick: post_Flick,
                from: viewController_Flick,
                completion_Flick: completion_Flick
            )
        } else {
            report_Flick(
                post_Flick: post_Flick,
                from: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Flick(
        button_Flick: UIButton,
        comment_Flick: Comment_Flick,
        post_Flick: TitleModel_Flick,
        isMyComment_Flick: Bool,
        viewController_Flick: UIViewController,
        completion_Flick: (() -> Void)?
    ) {
        addButtonAnimation_Flick(button_Flick: button_Flick)
        
        if isMyComment_Flick {
            delete_Flick(
                comment_Flick: comment_Flick,
                post_Flick: post_Flick,
                from: viewController_Flick,
                completion_Flick: completion_Flick
            )
        } else {
            report_Flick(
                comment_Flick: comment_Flick,
                post_Flick: post_Flick,
                from: viewController_Flick,
                completion_Flick: completion_Flick
            )
        }
    }
}
