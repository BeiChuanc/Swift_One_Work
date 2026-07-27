import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
/// 功能：统一处理用户拉黑、帖子/评论举报与删除，以及对应操作按钮的创建
/// 设计：静态工具类，弹窗确认 + 异步执行 ViewModel 操作
class ReportDeleteHelper_Maki {

    // MARK: - 常量

    /// 操作延迟时间（秒）
    private static let actionDelay_Maki: TimeInterval = 0.5

    /// 按钮点击动画时长
    private static let animationDuration_Maki: TimeInterval = 0.1

    /// 按钮点击缩放比例
    private static let animationScale_Maki: CGFloat = 0.85

    /// 删除确认弹窗文案
    private enum DeleteAlertConfig_Maki {
        static let postTitle_Maki = "Delete Post"
        static let postMessage_Maki = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Maki = "Delete Comment"
        static let commentMessage_Maki = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Maki = "Delete"
        static let cancelButtonTitle_Maki = "Cancel"
    }

    // MARK: - 用户操作

    /// 拉黑用户
    /// 参数：
    /// - user_Maki: 被拉黑的用户
    /// - viewController_Maki: 发起操作的视图控制器
    /// - completion_Maki: 确认后立即回调（不等待异步操作完成）
    static func block_Maki(
        user_Maki: PrewUserModel_Maki,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) {
        UIAlertController.report_Maki(with: true, completeBlock: {
            performBlockUser_Maki(user_Maki: user_Maki)
            completion_Maki?()
        })
    }

    // MARK: - 举报

    /// 举报帖子
    static func report_Maki(
        post_Maki: TitleModel_Maki,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) {
        UIAlertController.report_Maki(with: false, completeBlock: {
            performReportPost_Maki(post_Maki: post_Maki, completion_Maki: completion_Maki)
        })
    }

    /// 举报评论
    static func report_Maki(
        comment_Maki: Comment_Maki,
        post_Maki: TitleModel_Maki,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) {
        UIAlertController.report_Maki(with: false, completeBlock: {
            performReportComment_Maki(
                comment_Maki: comment_Maki,
                post_Maki: post_Maki,
                completion_Maki: completion_Maki
            )
        })
    }

    // MARK: - 删除

    /// 删除帖子
    static func delete_Maki(
        post_Maki: TitleModel_Maki,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Maki(
            title_Maki: DeleteAlertConfig_Maki.postTitle_Maki,
            message_Maki: DeleteAlertConfig_Maki.postMessage_Maki,
            from: viewController_Maki
        ) {
            performDeletePost_Maki(post_Maki: post_Maki, completion_Maki: completion_Maki)
        }
    }

    /// 删除评论
    static func delete_Maki(
        comment_Maki: Comment_Maki,
        post_Maki: TitleModel_Maki,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Maki(
            title_Maki: DeleteAlertConfig_Maki.commentTitle_Maki,
            message_Maki: DeleteAlertConfig_Maki.commentMessage_Maki,
            from: viewController_Maki
        ) {
            performDeleteComment_Maki(
                comment_Maki: comment_Maki,
                post_Maki: post_Maki,
                completion_Maki: completion_Maki
            )
        }
    }

    /// 显示删除确认弹窗
    private static func showDeleteConfirmAlert_Maki(
        title_Maki: String,
        message_Maki: String,
        from viewController_Maki: UIViewController,
        completion_Maki: @escaping () -> Void
    ) {
        let alert_Maki = UIAlertController(title: title_Maki, message: message_Maki, preferredStyle: .alert)
        alert_Maki.addAction(UIAlertAction(title: DeleteAlertConfig_Maki.cancelButtonTitle_Maki, style: .cancel))
        alert_Maki.addAction(UIAlertAction(title: DeleteAlertConfig_Maki.deleteButtonTitle_Maki, style: .destructive) { _ in
            completion_Maki()
        })
        viewController_Maki.present(alert_Maki, animated: true)
    }

    // MARK: - 执行操作

    /// 延迟后异步执行操作，完成后回调
    private static func performAsyncAction_Maki(
        action_Maki: @escaping @MainActor () -> Void,
        completion_Maki: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Maki * 1_000_000_000))
            await action_Maki()
            if let completion_Maki {
                await MainActor.run { completion_Maki() }
            }
        }
    }

    private static func performBlockUser_Maki(user_Maki: PrewUserModel_Maki) {
        performAsyncAction_Maki(action_Maki: {
            UserViewModel_Maki.shared_Maki.reportUser_Maki(user_maki: user_Maki)
            print("已拉黑用户: \(user_Maki.userName_Maki ?? "Unknown")")
        })
    }

    private static func performReportPost_Maki(post_Maki: TitleModel_Maki, completion_Maki: (() -> Void)? = nil) {
        performAsyncAction_Maki(action_Maki: {
            TitleViewModel_Maki.shared_Maki.deletePost_Maki(post_maki: post_Maki)
            print("已举报帖子: \(post_Maki.title_Maki)")
        }, completion_Maki: completion_Maki)
    }

    private static func performReportComment_Maki(
        comment_Maki: Comment_Maki,
        post_Maki: TitleModel_Maki,
        completion_Maki: (() -> Void)? = nil
    ) {
        performAsyncAction_Maki(action_Maki: {
            TitleViewModel_Maki.shared_Maki.deleteComment_Maki(
                post_maki: post_Maki,
                comment_maki: comment_Maki
            )
            print("已举报评论: \(comment_Maki.commentContent_Maki)")
        }, completion_Maki: completion_Maki)
    }

    private static func performDeletePost_Maki(post_Maki: TitleModel_Maki, completion_Maki: (() -> Void)? = nil) {
        performAsyncAction_Maki(action_Maki: {
            TitleViewModel_Maki.shared_Maki.deletePost_Maki(post_maki: post_Maki, isDelete_maki: true)
            print("已删除帖子: \(post_Maki.title_Maki)")
        }, completion_Maki: completion_Maki)
    }

    private static func performDeleteComment_Maki(
        comment_Maki: Comment_Maki,
        post_Maki: TitleModel_Maki,
        completion_Maki: (() -> Void)? = nil
    ) {
        performAsyncAction_Maki(action_Maki: {
            TitleViewModel_Maki.shared_Maki.deleteComment_Maki(
                post_maki: post_Maki,
                comment_maki: comment_Maki,
                isDelete_maki: true
            )
            print("已删除评论: \(comment_Maki.commentContent_Maki)")
        }, completion_Maki: completion_Maki)
    }

    // MARK: - 按钮创建

    /// 创建帖子举报/删除按钮（自己的帖子显示删除图标）
    @MainActor static func createPostReportButton_Maki(
        post_Maki: TitleModel_Maki,
        size_Maki: CGFloat = 25,
        color_Maki: UIColor = .black,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Maki(
            ownerUserId_maki: post_Maki.titleUserId_Maki,
            size_Maki: size_Maki,
            color_Maki: color_Maki,
            from: viewController_Maki
        ) { vc_maki, isMine_maki in
            if isMine_maki {
                delete_Maki(post_Maki: post_Maki, from: vc_maki, completion_Maki: completion_Maki)
            } else {
                report_Maki(post_Maki: post_Maki, from: vc_maki, completion_Maki: completion_Maki)
            }
        }
    }

    /// 创建评论举报/删除按钮（自己的评论显示删除图标）
    @MainActor static func createCommentReportButton_Maki(
        comment_Maki: Comment_Maki,
        post_Maki: TitleModel_Maki,
        size_Maki: CGFloat = 25,
        color_Maki: UIColor = .black,
        from viewController_Maki: UIViewController,
        completion_Maki: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Maki(
            ownerUserId_maki: comment_Maki.commentUserId_Maki,
            size_Maki: size_Maki,
            color_Maki: color_Maki,
            from: viewController_Maki
        ) { vc_maki, isMine_maki in
            if isMine_maki {
                delete_Maki(
                    comment_Maki: comment_Maki,
                    post_Maki: post_Maki,
                    from: vc_maki,
                    completion_Maki: completion_Maki
                )
            } else {
                report_Maki(
                    comment_Maki: comment_Maki,
                    post_Maki: post_Maki,
                    from: vc_maki,
                    completion_Maki: completion_Maki
                )
            }
        }
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Maki(
        size_Maki: CGFloat = 44,
        backgroundColor_Maki: UIColor? = nil,
        tintColor_Maki: UIColor = .white,
        withShadow_Maki: Bool = false
    ) -> UIButton {
        let button_Maki = UIButton(type: .system)
        let iconSize_Maki = size_Maki * 0.5
        button_Maki.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize_Maki, weight: .semibold)),
            for: .normal
        )
        button_Maki.tintColor = tintColor_Maki
        button_Maki.backgroundColor = backgroundColor_Maki ?? UIColor.white.withAlphaComponent(0.2)
        button_Maki.layer.cornerRadius = size_Maki / 2

        if withShadow_Maki {
            button_Maki.layer.shadowColor = UIColor.black.cgColor
            button_Maki.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Maki.layer.shadowOpacity = 0.15
            button_Maki.layer.shadowRadius = 8
        }   
        return button_Maki
    }

    // MARK: - 私有辅助方法

    /// 创建帖子/评论通用的举报操作按钮
    /// 参数：
    /// - ownerUserId_maki: 内容所属用户 ID
    /// - onTap_maki: 点击回调，参数为 (视图控制器, 是否为本人内容)
    @MainActor
    private static func createContentReportButton_Maki(
        ownerUserId_maki: Int,
        size_Maki: CGFloat,
        color_Maki: UIColor,
        from viewController_Maki: UIViewController,
        onTap_maki: @escaping (UIViewController, Bool) -> Void
    ) -> UIButton {
        let button_Maki = UIButton(type: .system)
        let isMine_maki = UserViewModel_Maki.shared_Maki.isCurrentUser_Maki(userId_maki: ownerUserId_maki)
        configureButtonIcon_Maki(
            button_Maki: button_Maki,
            iconName_Maki: isMine_maki ? "trash" : "ellipsis",
            size_Maki: size_Maki,
            color_Maki: color_Maki
        )
        button_Maki.addAction(UIAction { [weak viewController_Maki] _ in
            guard let vc_maki = viewController_Maki else { return }
            addButtonAnimation_Maki(button_Maki: button_Maki)
            onTap_maki(vc_maki, isMine_maki)
        }, for: .touchUpInside)
        return button_Maki
    }

    /// 按钮按压缩放动画
    private static func addButtonAnimation_Maki(button_Maki: UIButton) {
        UIView.animate(withDuration: animationDuration_Maki, animations: {
            button_Maki.transform = CGAffineTransform(scaleX: animationScale_Maki, y: animationScale_Maki)
        }) { _ in
            UIView.animate(withDuration: animationDuration_Maki) { button_Maki.transform = .identity }
        }
    }

    /// 配置 SF Symbol 图标
    private static func configureButtonIcon_Maki(
        button_Maki: UIButton,
        iconName_Maki: String,
        size_Maki: CGFloat,
        color_Maki: UIColor
    ) {
        let config_Maki = UIImage.SymbolConfiguration(pointSize: size_Maki, weight: .semibold)
        button_Maki.setImage(UIImage(systemName: iconName_Maki, withConfiguration: config_Maki), for: .normal)
        button_Maki.tintColor = color_Maki
    }
}
