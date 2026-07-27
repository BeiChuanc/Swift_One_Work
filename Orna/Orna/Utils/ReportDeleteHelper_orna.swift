import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
/// 功能：统一处理用户拉黑、帖子/评论举报与删除，以及对应操作按钮的创建
/// 设计：静态工具类，弹窗确认 + 异步执行 ViewModel 操作
class ReportDeleteHelper_Orna {

    // MARK: - 常量

    /// 操作延迟时间（秒）
    private static let actionDelay_Orna: TimeInterval = 0.5

    /// 按钮点击动画时长
    private static let animationDuration_Orna: TimeInterval = 0.1

    /// 按钮点击缩放比例
    private static let animationScale_Orna: CGFloat = 0.85

    /// 删除确认弹窗文案
    private enum DeleteAlertConfig_Orna {
        static let postTitle_Orna = "Delete Post"
        static let postMessage_Orna = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Orna = "Delete Comment"
        static let commentMessage_Orna = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Orna = "Delete"
        static let cancelButtonTitle_Orna = "Cancel"
    }

    // MARK: - 用户操作

    /// 拉黑用户
    /// 参数：
    /// - user_Orna: 被拉黑的用户
    /// - viewController_Orna: 发起操作的视图控制器
    /// - completion_Orna: 确认后立即回调（不等待异步操作完成）
    static func block_Orna(
        user_Orna: PrewUserModel_Orna,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) {
        UIAlertController.report_Orna(with: true, completeBlock: {
            performBlockUser_Orna(user_Orna: user_Orna)
            completion_Orna?()
        })
    }

    // MARK: - 举报

    /// 举报帖子
    static func report_Orna(
        post_Orna: TitleModel_Orna,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) {
        UIAlertController.report_Orna(with: false, completeBlock: {
            performReportPost_Orna(post_Orna: post_Orna, completion_Orna: completion_Orna)
        })
    }

    /// 举报评论
    static func report_Orna(
        comment_Orna: Comment_Orna,
        post_Orna: TitleModel_Orna,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) {
        UIAlertController.report_Orna(with: false, completeBlock: {
            performReportComment_Orna(
                comment_Orna: comment_Orna,
                post_Orna: post_Orna,
                completion_Orna: completion_Orna
            )
        })
    }

    // MARK: - 删除

    /// 删除帖子
    static func delete_Orna(
        post_Orna: TitleModel_Orna,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Orna(
            title_Orna: DeleteAlertConfig_Orna.postTitle_Orna,
            message_Orna: DeleteAlertConfig_Orna.postMessage_Orna,
            from: viewController_Orna
        ) {
            performDeletePost_Orna(post_Orna: post_Orna, completion_Orna: completion_Orna)
        }
    }

    /// 删除评论
    static func delete_Orna(
        comment_Orna: Comment_Orna,
        post_Orna: TitleModel_Orna,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Orna(
            title_Orna: DeleteAlertConfig_Orna.commentTitle_Orna,
            message_Orna: DeleteAlertConfig_Orna.commentMessage_Orna,
            from: viewController_Orna
        ) {
            performDeleteComment_Orna(
                comment_Orna: comment_Orna,
                post_Orna: post_Orna,
                completion_Orna: completion_Orna
            )
        }
    }

    /// 显示删除确认弹窗
    private static func showDeleteConfirmAlert_Orna(
        title_Orna: String,
        message_Orna: String,
        from viewController_Orna: UIViewController,
        completion_Orna: @escaping () -> Void
    ) {
        let alert_Orna = UIAlertController(title: title_Orna, message: message_Orna, preferredStyle: .alert)
        alert_Orna.addAction(UIAlertAction(title: DeleteAlertConfig_Orna.cancelButtonTitle_Orna, style: .cancel))
        alert_Orna.addAction(UIAlertAction(title: DeleteAlertConfig_Orna.deleteButtonTitle_Orna, style: .destructive) { _ in
            completion_Orna()
        })
        viewController_Orna.present(alert_Orna, animated: true)
    }

    // MARK: - 执行操作

    /// 延迟后异步执行操作，完成后回调
    private static func performAsyncAction_Orna(
        action_Orna: @escaping @MainActor () -> Void,
        completion_Orna: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Orna * 1_000_000_000))
            await action_Orna()
            if let completion_Orna {
                await MainActor.run { completion_Orna() }
            }
        }
    }

    private static func performBlockUser_Orna(user_Orna: PrewUserModel_Orna) {
        performAsyncAction_Orna(action_Orna: {
            UserViewModel_Orna.shared_Orna.reportUser_Orna(user_orna: user_Orna)
            print("已拉黑用户: \(user_Orna.userName_Orna ?? "Unknown")")
        })
    }

    private static func performReportPost_Orna(post_Orna: TitleModel_Orna, completion_Orna: (() -> Void)? = nil) {
        performAsyncAction_Orna(action_Orna: {
            TitleViewModel_Orna.shared_Orna.deletePost_Orna(post_orna: post_Orna)
            print("已举报帖子: \(post_Orna.title_Orna)")
        }, completion_Orna: completion_Orna)
    }

    private static func performReportComment_Orna(
        comment_Orna: Comment_Orna,
        post_Orna: TitleModel_Orna,
        completion_Orna: (() -> Void)? = nil
    ) {
        performAsyncAction_Orna(action_Orna: {
            TitleViewModel_Orna.shared_Orna.deleteComment_Orna(
                post_orna: post_Orna,
                comment_orna: comment_Orna
            )
            print("已举报评论: \(comment_Orna.commentContent_Orna)")
        }, completion_Orna: completion_Orna)
    }

    private static func performDeletePost_Orna(post_Orna: TitleModel_Orna, completion_Orna: (() -> Void)? = nil) {
        performAsyncAction_Orna(action_Orna: {
            TitleViewModel_Orna.shared_Orna.deletePost_Orna(post_orna: post_Orna, isDelete_orna: true)
            print("已删除帖子: \(post_Orna.title_Orna)")
        }, completion_Orna: completion_Orna)
    }

    private static func performDeleteComment_Orna(
        comment_Orna: Comment_Orna,
        post_Orna: TitleModel_Orna,
        completion_Orna: (() -> Void)? = nil
    ) {
        performAsyncAction_Orna(action_Orna: {
            TitleViewModel_Orna.shared_Orna.deleteComment_Orna(
                post_orna: post_Orna,
                comment_orna: comment_Orna,
                isDelete_orna: true
            )
            print("已删除评论: \(comment_Orna.commentContent_Orna)")
        }, completion_Orna: completion_Orna)
    }

    // MARK: - 按钮创建

    /// 创建帖子举报/删除按钮（自己的帖子显示删除图标）
    @MainActor static func createPostReportButton_Orna(
        post_Orna: TitleModel_Orna,
        size_Orna: CGFloat = 25,
        color_Orna: UIColor = .black,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Orna(
            ownerUserId_orna: post_Orna.titleUserId_Orna,
            size_Orna: size_Orna,
            color_Orna: color_Orna,
            from: viewController_Orna
        ) { vc_orna, isMine_orna in
            if isMine_orna {
                delete_Orna(post_Orna: post_Orna, from: vc_orna, completion_Orna: completion_Orna)
            } else {
                report_Orna(post_Orna: post_Orna, from: vc_orna, completion_Orna: completion_Orna)
            }
        }
    }

    /// 创建评论举报/删除按钮（自己的评论显示删除图标）
    @MainActor static func createCommentReportButton_Orna(
        comment_Orna: Comment_Orna,
        post_Orna: TitleModel_Orna,
        size_Orna: CGFloat = 25,
        color_Orna: UIColor = .black,
        from viewController_Orna: UIViewController,
        completion_Orna: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Orna(
            ownerUserId_orna: comment_Orna.commentUserId_Orna,
            size_Orna: size_Orna,
            color_Orna: color_Orna,
            from: viewController_Orna
        ) { vc_orna, isMine_orna in
            if isMine_orna {
                delete_Orna(
                    comment_Orna: comment_Orna,
                    post_Orna: post_Orna,
                    from: vc_orna,
                    completion_Orna: completion_Orna
                )
            } else {
                report_Orna(
                    comment_Orna: comment_Orna,
                    post_Orna: post_Orna,
                    from: vc_orna,
                    completion_Orna: completion_Orna
                )
            }
        }
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Orna(
        size_Orna: CGFloat = 44,
        backgroundColor_Orna: UIColor? = nil,
        tintColor_Orna: UIColor = .white,
        withShadow_Orna: Bool = false
    ) -> UIButton {
        let button_Orna = UIButton(type: .system)
        let iconSize_Orna = size_Orna * 0.5
        button_Orna.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize_Orna, weight: .semibold)),
            for: .normal
        )
        button_Orna.tintColor = tintColor_Orna
        button_Orna.backgroundColor = backgroundColor_Orna ?? UIColor.white.withAlphaComponent(0.2)
        button_Orna.layer.cornerRadius = size_Orna / 2

        if withShadow_Orna {
            button_Orna.layer.shadowColor = UIColor.black.cgColor
            button_Orna.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Orna.layer.shadowOpacity = 0.15
            button_Orna.layer.shadowRadius = 8
        }
        return button_Orna
    }

    // MARK: - 私有辅助方法

    /// 创建帖子/评论通用的举报操作按钮
    /// 参数：
    /// - ownerUserId_orna: 内容所属用户 ID
    /// - onTap_orna: 点击回调，参数为 (视图控制器, 是否为本人内容)
    @MainActor
    private static func createContentReportButton_Orna(
        ownerUserId_orna: Int,
        size_Orna: CGFloat,
        color_Orna: UIColor,
        from viewController_Orna: UIViewController,
        onTap_orna: @escaping (UIViewController, Bool) -> Void
    ) -> UIButton {
        let button_Orna = UIButton(type: .system)
        let isMine_orna = UserViewModel_Orna.shared_Orna.isCurrentUser_Orna(userId_orna: ownerUserId_orna)
        configureButtonIcon_Orna(
            button_Orna: button_Orna,
            iconName_Orna: isMine_orna ? "trash" : "ellipsis",
            size_Orna: size_Orna,
            color_Orna: color_Orna
        )
        button_Orna.addAction(UIAction { [weak viewController_Orna] _ in
            guard let vc_orna = viewController_Orna else { return }
            addButtonAnimation_Orna(button_Orna: button_Orna)
            onTap_orna(vc_orna, isMine_orna)
        }, for: .touchUpInside)
        return button_Orna
    }

    /// 按钮按压缩放动画
    private static func addButtonAnimation_Orna(button_Orna: UIButton) {
        UIView.animate(withDuration: animationDuration_Orna, animations: {
            button_Orna.transform = CGAffineTransform(scaleX: animationScale_Orna, y: animationScale_Orna)
        }) { _ in
            UIView.animate(withDuration: animationDuration_Orna) { button_Orna.transform = .identity }
        }
    }

    /// 配置 SF Symbol 图标
    private static func configureButtonIcon_Orna(
        button_Orna: UIButton,
        iconName_Orna: String,
        size_Orna: CGFloat,
        color_Orna: UIColor
    ) {
        let config_Orna = UIImage.SymbolConfiguration(pointSize: size_Orna, weight: .semibold)
        button_Orna.setImage(UIImage(systemName: iconName_Orna, withConfiguration: config_Orna), for: .normal)
        button_Orna.tintColor = color_Orna
    }
}
