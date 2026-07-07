import UIKit

// MARK: - 弹幕操作按钮（扩大点击热区）

/// DanmakuActionButton_Lens
/// 功能：弹幕池内举报/删除按钮，扩大热区便于飞行中点击
private class DanmakuActionButton_Lens: UIButton {

    /// 热区向外扩展的 pt 数
    var hitExpansion_Lens: CGFloat = 8

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -hitExpansion_Lens, dy: -hitExpansion_Lens).contains(point)
    }
}

// MARK: - 举报/删除助手类

/// 举报/删除助手类
/// 功能：统一处理用户拉黑、帖子/评论举报与删除，以及对应操作按钮的创建
/// 设计：静态工具类，弹窗确认 + 异步执行 ViewModel 操作
class ReportDeleteHelper_Lens {

    // MARK: - 常量

    /// 操作延迟时间（秒）
    private static let actionDelay_Lens: TimeInterval = 0.5

    /// 按钮点击动画时长
    private static let animationDuration_Lens: TimeInterval = 0.1

    /// 按钮点击缩放比例
    private static let animationScale_Lens: CGFloat = 0.85

    /// 删除确认弹窗文案
    private enum DeleteAlertConfig_Lens {
        static let postTitle_Lens = "Delete Post"
        static let postMessage_Lens = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Lens = "Delete Comment"
        static let commentMessage_Lens = "Are you sure you want to delete this comment? This action cannot be undone."
        static let danmakuTitle_Lens = "Delete Danmaku"
        static let danmakuMessage_Lens = "Are you sure you want to delete this danmaku? This action cannot be undone."
        static let deleteButtonTitle_Lens = "Delete"
        static let cancelButtonTitle_Lens = "Cancel"
    }

    // MARK: - 用户操作

    /// 拉黑用户
    /// 参数：
    /// - user_Lens: 被拉黑的用户
    /// - viewController_Lens: 发起操作的视图控制器
    /// - completion_Lens: 确认后立即回调（不等待异步操作完成）
    static func block_Lens(
        user_Lens: PrewUserModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lens(with: true, completeBlock_Lens: {
            performBlockUser_Lens(user_Lens: user_Lens)
            completion_Lens?()
        })
    }

    // MARK: - 举报

    /// 举报帖子
    static func report_Lens(
        post_Lens: TitleModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lens(with: false, completeBlock_Lens: {
            performReportPost_Lens(post_Lens: post_Lens, completion_Lens: completion_Lens)
        })
    }

    /// 举报评论
    static func report_Lens(
        comment_Lens: Comment_Lens,
        post_Lens: TitleModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lens(with: false, completeBlock_Lens: {
            performReportComment_Lens(
                comment_Lens: comment_Lens,
                post_Lens: post_Lens,
                completion_Lens: completion_Lens
            )
        })
    }

    /// 举报弹幕
    static func report_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil,
        cancel_Lens: (() -> Void)? = nil
    ) {
        UIAlertController.report_Lens(with: false, completeBlock_Lens: {
            performReportDanmaku_Lens(danmaku_Lens: danmaku_Lens, completion_Lens: completion_Lens)
        }, cancelBlock_Lens: cancel_Lens)
    }

    // MARK: - 删除

    /// 删除帖子
    static func delete_Lens(
        post_Lens: TitleModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Lens(
            title_Lens: DeleteAlertConfig_Lens.postTitle_Lens,
            message_Lens: DeleteAlertConfig_Lens.postMessage_Lens,
            from: viewController_Lens
        ) {
            performDeletePost_Lens(post_Lens: post_Lens, completion_Lens: completion_Lens)
        }
    }

    /// 删除评论
    static func delete_Lens(
        comment_Lens: Comment_Lens,
        post_Lens: TitleModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Lens(
            title_Lens: DeleteAlertConfig_Lens.commentTitle_Lens,
            message_Lens: DeleteAlertConfig_Lens.commentMessage_Lens,
            from: viewController_Lens
        ) {
            performDeleteComment_Lens(
                comment_Lens: comment_Lens,
                post_Lens: post_Lens,
                completion_Lens: completion_Lens
            )
        }
    }

    /// 删除弹幕
    static func delete_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil,
        cancel_Lens: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Lens(
            title_Lens: DeleteAlertConfig_Lens.danmakuTitle_Lens,
            message_Lens: DeleteAlertConfig_Lens.danmakuMessage_Lens,
            from: viewController_Lens,
            cancel_Lens: cancel_Lens
        ) {
            performDeleteDanmaku_Lens(danmaku_Lens: danmaku_Lens, completion_Lens: completion_Lens)
        }
    }

    /// 显示删除确认弹窗
    private static func showDeleteConfirmAlert_Lens(
        title_Lens: String,
        message_Lens: String,
        from viewController_Lens: UIViewController,
        cancel_Lens: (() -> Void)? = nil,
        completion_Lens: @escaping () -> Void
    ) {
        let alert_Lens = UIAlertController(title: title_Lens, message: message_Lens, preferredStyle: .alert)
        alert_Lens.addAction(UIAlertAction(title: DeleteAlertConfig_Lens.cancelButtonTitle_Lens, style: .cancel) { _ in
            cancel_Lens?()
        })
        alert_Lens.addAction(UIAlertAction(title: DeleteAlertConfig_Lens.deleteButtonTitle_Lens, style: .destructive) { _ in
            completion_Lens()
        })
        resolvePresenter_Lens(viewController_Lens).present(alert_Lens, animated: true)
    }

    /// 解析弹窗展示控制器
    private static func resolvePresenter_Lens(_ viewController_Lens: UIViewController) -> UIViewController {
        UIViewController.currentViewController_Lens() ?? viewController_Lens
    }

    // MARK: - 执行操作

    /// 延迟后异步执行操作，完成后回调
    private static func performAsyncAction_Lens(
        action_Lens: @escaping @MainActor () -> Void,
        completion_Lens: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Lens * 1_000_000_000))
            await action_Lens()
            if let completion_Lens {
                await MainActor.run { completion_Lens() }
            }
        }
    }

    private static func performBlockUser_Lens(user_Lens: PrewUserModel_Lens) {
        performAsyncAction_Lens(action_Lens: {
            UserViewModel_Lens.shared_Lens.reportUser_Lens(user_lens: user_Lens)
            print("已拉黑用户: \(user_Lens.userName_Lens ?? "Unknown")")
        })
    }

    private static func performReportPost_Lens(post_Lens: TitleModel_Lens, completion_Lens: (() -> Void)? = nil) {
        performAsyncAction_Lens(action_Lens: {
            TitleViewModel_Lens.shared_Lens.deletePost_Lens(post_lens: post_Lens)
            print("已举报帖子: \(post_Lens.title_Lens)")
        }, completion_Lens: completion_Lens)
    }

    private static func performReportComment_Lens(
        comment_Lens: Comment_Lens,
        post_Lens: TitleModel_Lens,
        completion_Lens: (() -> Void)? = nil
    ) {
        performAsyncAction_Lens(action_Lens: {
            TitleViewModel_Lens.shared_Lens.deleteComment_Lens(
                post_lens: post_Lens,
                comment_lens: comment_Lens
            )
            print("已举报评论: \(comment_Lens.commentContent_Lens)")
        }, completion_Lens: completion_Lens)
    }

    private static func performDeletePost_Lens(post_Lens: TitleModel_Lens, completion_Lens: (() -> Void)? = nil) {
        performAsyncAction_Lens(action_Lens: {
            TitleViewModel_Lens.shared_Lens.deletePost_Lens(post_lens: post_Lens, isDelete_lens: true)
            print("已删除帖子: \(post_Lens.title_Lens)")
        }, completion_Lens: completion_Lens)
    }

    private static func performDeleteComment_Lens(
        comment_Lens: Comment_Lens,
        post_Lens: TitleModel_Lens,
        completion_Lens: (() -> Void)? = nil
    ) {
        performAsyncAction_Lens(action_Lens: {
            TitleViewModel_Lens.shared_Lens.deleteComment_Lens(
                post_lens: post_Lens,
                comment_lens: comment_Lens,
                isDelete_lens: true
            )
            print("已删除评论: \(comment_Lens.commentContent_Lens)")
        }, completion_Lens: completion_Lens)
    }

    private static func performReportDanmaku_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        completion_Lens: (() -> Void)? = nil
    ) {
        performAsyncAction_Lens(action_Lens: {
            StudioViewModel_Lens.shared_Lens.reportDanmaku_Lens(danmakuId_Lens: danmaku_Lens.danmakuId_Lens)
            print("已举报弹幕: \(danmaku_Lens.content_Lens)")
        }, completion_Lens: completion_Lens)
    }

    private static func performDeleteDanmaku_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        completion_Lens: (() -> Void)? = nil
    ) {
        performAsyncAction_Lens(action_Lens: {
            StudioViewModel_Lens.shared_Lens.deleteDanmaku_Lens(danmakuId_Lens: danmaku_Lens.danmakuId_Lens)
            print("已删除弹幕: \(danmaku_Lens.content_Lens)")
        }, completion_Lens: completion_Lens)
    }

    // MARK: - 按钮创建

    /// 创建帖子举报/删除按钮（自己的帖子显示删除图标）
    @MainActor static func createPostReportButton_Lens(
        post_Lens: TitleModel_Lens,
        size_Lens: CGFloat = 25,
        color_Lens: UIColor = .black,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Lens(
            ownerUserId_lens: post_Lens.titleUserId_Lens,
            size_Lens: size_Lens,
            color_Lens: color_Lens,
            from: viewController_Lens
        ) { vc_lens, isMine_lens in
            if isMine_lens {
                delete_Lens(post_Lens: post_Lens, from: vc_lens, completion_Lens: completion_Lens)
            } else {
                report_Lens(post_Lens: post_Lens, from: vc_lens, completion_Lens: completion_Lens)
            }
        }
    }

    /// 创建评论举报/删除按钮（自己的评论显示删除图标）
    @MainActor static func createCommentReportButton_Lens(
        comment_Lens: Comment_Lens,
        post_Lens: TitleModel_Lens,
        size_Lens: CGFloat = 25,
        color_Lens: UIColor = .black,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Lens(
            ownerUserId_lens: comment_Lens.commentUserId_Lens,
            size_Lens: size_Lens,
            color_Lens: color_Lens,
            from: viewController_Lens
        ) { vc_lens, isMine_lens in
            if isMine_lens {
                delete_Lens(
                    comment_Lens: comment_Lens,
                    post_Lens: post_Lens,
                    from: vc_lens,
                    completion_Lens: completion_Lens
                )
            } else {
                report_Lens(
                    comment_Lens: comment_Lens,
                    post_Lens: post_Lens,
                    from: vc_lens,
                    completion_Lens: completion_Lens
                )
            }
        }
    }

    /// 创建弹幕举报/删除按钮（登录用户自己的弹幕显示删除，其余显示举报）
    @MainActor static func createDanmakuActionButton_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        buttonSize_Lens: CGFloat,
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) -> UIButton {
        let isMine_Lens = UserViewModel_Lens.shared_Lens.isLoggedIn_Lens
            && UserViewModel_Lens.shared_Lens.isCurrentUser_Lens(userId_lens: danmaku_Lens.userId_Lens)
        let iconName_Lens = isMine_Lens ? "trash" : "flag"
        let tint_Lens = isMine_Lens
            ? UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.95)
            : UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.85)

        let button_Lens = DanmakuActionButton_Lens(type: .custom)
        button_Lens.hitExpansion_Lens = 10
        button_Lens.isUserInteractionEnabled = true
        let iconCfg_Lens = UIImage.SymbolConfiguration(pointSize: max(9, buttonSize_Lens * 0.42), weight: .semibold)
        button_Lens.setImage(UIImage(systemName: iconName_Lens, withConfiguration: iconCfg_Lens), for: .normal)
        button_Lens.tintColor = tint_Lens
        button_Lens.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.12)
        button_Lens.layer.cornerRadius = buttonSize_Lens / 2
        button_Lens.isExclusiveTouch = true

        button_Lens.addAction(UIAction { [weak viewController_Lens] _ in
            guard let vc_Lens = viewController_Lens else { return }
            addButtonAnimation_Lens(button_Lens: button_Lens)
            if isMine_Lens {
                delete_Lens(
                    danmaku_Lens: danmaku_Lens,
                    from: vc_Lens,
                    completion_Lens: completion_Lens
                )
            } else {
                report_Lens(
                    danmaku_Lens: danmaku_Lens,
                    from: vc_Lens,
                    completion_Lens: completion_Lens
                )
            }
        }, for: .touchUpInside)
        return button_Lens
    }

    /// 创建弹幕举报/删除按钮（自己的弹幕显示删除图标）
    @MainActor static func createDanmakuReportButton_Lens(
        danmaku_Lens: DanmakuModel_Lens,
        size_Lens: CGFloat = 14,
        color_Lens: UIColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5),
        from viewController_Lens: UIViewController,
        completion_Lens: (() -> Void)? = nil
    ) -> UIButton {
        createContentReportButton_Lens(
            ownerUserId_lens: danmaku_Lens.userId_Lens,
            size_Lens: size_Lens,
            color_Lens: color_Lens,
            from: viewController_Lens
        ) { vc_lens, isMine_lens in
            if isMine_lens {
                delete_Lens(danmaku_Lens: danmaku_Lens, from: vc_lens, completion_Lens: completion_Lens)
            } else {
                report_Lens(danmaku_Lens: danmaku_Lens, from: vc_lens, completion_Lens: completion_Lens)
            }
        }
    }

    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Lens(
        size_Lens: CGFloat = 44,
        backgroundColor_Lens: UIColor? = nil,
        tintColor_Lens: UIColor = .white,
        withShadow_Lens: Bool = false
    ) -> UIButton {
        let button_Lens = UIButton(type: .system)
        let iconSize_Lens = size_Lens * 0.5
        button_Lens.setImage(
            UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: iconSize_Lens, weight: .semibold)),
            for: .normal
        )
        button_Lens.tintColor = tintColor_Lens
        button_Lens.backgroundColor = backgroundColor_Lens ?? UIColor.white.withAlphaComponent(0.2)
        button_Lens.layer.cornerRadius = size_Lens / 2

        if withShadow_Lens {
            button_Lens.layer.shadowColor = UIColor.black.cgColor
            button_Lens.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Lens.layer.shadowOpacity = 0.15
            button_Lens.layer.shadowRadius = 8
        }
        return button_Lens
    }

    // MARK: - 私有辅助方法

    /// 创建帖子/评论通用的举报操作按钮
    /// 参数：
    /// - ownerUserId_lens: 内容所属用户 ID
    /// - onTap_lens: 点击回调，参数为 (视图控制器, 是否为本人内容)
    @MainActor
    private static func createContentReportButton_Lens(
        ownerUserId_lens: Int,
        size_Lens: CGFloat,
        color_Lens: UIColor,
        from viewController_Lens: UIViewController,
        onTap_lens: @escaping (UIViewController, Bool) -> Void
    ) -> UIButton {
        let button_Lens = UIButton(type: .system)
        let isMine_lens = UserViewModel_Lens.shared_Lens.isCurrentUser_Lens(userId_lens: ownerUserId_lens)
        configureButtonIcon_Lens(
            button_Lens: button_Lens,
            iconName_Lens: isMine_lens ? "trash" : "ellipsis",
            size_Lens: size_Lens,
            color_Lens: color_Lens
        )
        button_Lens.addAction(UIAction { [weak viewController_Lens] _ in
            guard let vc_lens = viewController_Lens else { return }
            addButtonAnimation_Lens(button_Lens: button_Lens)
            onTap_lens(vc_lens, isMine_lens)
        }, for: .touchUpInside)
        return button_Lens
    }

    /// 按钮按压缩放动画
    private static func addButtonAnimation_Lens(button_Lens: UIButton) {
        UIView.animate(withDuration: animationDuration_Lens, animations: {
            button_Lens.transform = CGAffineTransform(scaleX: animationScale_Lens, y: animationScale_Lens)
        }) { _ in
            UIView.animate(withDuration: animationDuration_Lens) { button_Lens.transform = .identity }
        }
    }

    /// 配置 SF Symbol 图标
    private static func configureButtonIcon_Lens(
        button_Lens: UIButton,
        iconName_Lens: String,
        size_Lens: CGFloat,
        color_Lens: UIColor
    ) {
        let config_Lens = UIImage.SymbolConfiguration(pointSize: size_Lens, weight: .semibold)
        button_Lens.setImage(UIImage(systemName: iconName_Lens, withConfiguration: config_Lens), for: .normal)
        button_Lens.tintColor = color_Lens
    }
}
