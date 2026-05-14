import Foundation
import UIKit

// MARK: - 举报/删除助手类

/// 举报/删除助手类
class ReportDeleteHelper_Echd {
    
    // MARK: - 常量
    
    /// 操作延迟时间（秒）
    private static let actionDelay_Echd: TimeInterval = 0.5
    
    /// 动画时长
    private static let animationDuration_Echd: TimeInterval = 0.1
    
    /// 动画缩放比例
    private static let animationScale_Echd: CGFloat = 0.85
    
    /// 删除对话框配置
    private struct DeleteAlertConfig_Echd {
        static let postTitle_Echd = "Delete Post"
        static let postMessage_Echd = "Are you sure you want to delete this post? This action cannot be undone."
        static let commentTitle_Echd = "Delete Comment"
        static let commentMessage_Echd = "Are you sure you want to delete this comment? This action cannot be undone."
        static let deleteButtonTitle_Echd = "Delete"
        static let cancelButtonTitle_Echd = "Cancel"
    }
    
    // MARK: - 操作类型枚举
    
    /// 操作类型
    enum ActionType_Echd {
        case block_Echd       // 拉黑用户
        case post_Echd        // 举报帖子
        case comment_Echd     // 举报评论
    }
    
    // MARK: - 用户操作方法
    
    /// 拉黑用户
    static func block_Echd(
        user_Echd: PrewUserModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        UIAlertController.report_Echd(with: true, completeBlock: {
            // 执行拉黑用户逻辑
            performBlockUser_Echd(
                user_Echd: user_Echd,
                viewController_Echd: viewController_Echd
            )
            completion_Echd?()
        })
    }
    
    // MARK: - 举报方法
    
    /// 举报帖子
    static func report_Echd(
        post_Echd: TitleModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        UIAlertController.report_Echd(with: false, completeBlock: {
            // 执行举报帖子逻辑，操作完成后调用回调
            performReportPost_Echd(
                post_Echd: post_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd)
        })
    }
    
    /// 举报评论
    static func report_Echd(
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        UIAlertController.report_Echd(with: false, completeBlock: {
            performReportComment_Echd(
                comment_Echd: comment_Echd,
                post_Echd: post_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd)
        })
    }
    
    // MARK: - 删除方法
    
    /// 删除帖子
    static func delete_Echd(
        post_Echd: TitleModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Echd(
            title_Echd: DeleteAlertConfig_Echd.postTitle_Echd,
            message_Echd: DeleteAlertConfig_Echd.postMessage_Echd,
            from: viewController_Echd
        ) {
            performDeletePost_Echd(
                post_Echd: post_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }
    }
    
    /// 删除评论
    static func delete_Echd(
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Echd(
            title_Echd: DeleteAlertConfig_Echd.commentTitle_Echd,
            message_Echd: DeleteAlertConfig_Echd.commentMessage_Echd,
            from: viewController_Echd
        ) {
            performDeleteComment_Echd(
                comment_Echd: comment_Echd,
                post_Echd: post_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }
    }
    
    /// 显示删除确认对话框
    private static func showDeleteConfirmAlert_Echd(
        title_Echd: String,
        message_Echd: String,
        from viewController_Echd: UIViewController,
        completion_Echd: @escaping () -> Void
    ) {
        let alert_Echd = UIAlertController(
            title: title_Echd,
            message: message_Echd,
            preferredStyle: .alert
        )
        
        // 确认删除按钮
        let deleteAction_Echd = UIAlertAction(
            title: DeleteAlertConfig_Echd.deleteButtonTitle_Echd,
            style: .destructive
        ) { _ in
            completion_Echd()
        }
        
        // 取消按钮
        let cancelAction_Echd = UIAlertAction(
            title: DeleteAlertConfig_Echd.cancelButtonTitle_Echd,
            style: .cancel,
            handler: nil
        )
        
        alert_Echd.addAction(deleteAction_Echd)
        alert_Echd.addAction(cancelAction_Echd)
        
        viewController_Echd.present(alert_Echd, animated: true)
    }
    
    // MARK: - 私有方法 - 执行操作
    
    /// 统一异步执行操作
    private static func performAsyncAction_Echd(
        action_Echd: @escaping @MainActor () -> Void,
        completion_Echd: (() -> Void)? = nil
    ) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(actionDelay_Echd * 1_000_000_000))
            
            await action_Echd()
            
            // 确保在主线程上执行回调
            if let completion_Echd = completion_Echd {
                await MainActor.run {
                    completion_Echd()
                }
            }
        }
    }
    
    /// 执行拉黑用户操作
    private static func performBlockUser_Echd(
        user_Echd: PrewUserModel_Echd,
        viewController_Echd: UIViewController
    ) {
        performAsyncAction_Echd(action_Echd: {
            UserViewModel_Echd.shared_Echd.reportUser_Echd(user_echd: user_Echd)
            print("已拉黑用户: \(user_Echd.userName_Echd ?? "Unknown")")
        })
    }
    
    /// 执行举报帖子操作
    private static func performReportPost_Echd(
        post_Echd: TitleModel_Echd,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        performAsyncAction_Echd(
            action_Echd: {
                TitleViewModel_Echd.shared_Echd.deletePost_Echd(post_echd: post_Echd)
                print("已举报帖子: \(post_Echd.title_Echd)")
            },
            completion_Echd: completion_Echd
        )
    }
    
    /// 执行举报评论操作
    private static func performReportComment_Echd(
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        performAsyncAction_Echd(
            action_Echd: {
                TitleViewModel_Echd.shared_Echd.deleteComment_Echd(
                    post_echd: post_Echd,
                    comment_echd: comment_Echd
                )
                print("已举报评论: \(comment_Echd.commentContent_Echd)")
            },
            completion_Echd: completion_Echd
        )
    }
    
    /// 执行删除帖子操作
    private static func performDeletePost_Echd(
        post_Echd: TitleModel_Echd,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        performAsyncAction_Echd(
            action_Echd: {
                TitleViewModel_Echd.shared_Echd.deletePost_Echd(
                    post_echd: post_Echd,
                    isDelete_echd: true
                )
                print("已删除帖子: \(post_Echd.title_Echd)")
            },
            completion_Echd: completion_Echd
        )
    }
    
    /// 执行删除评论操作
    private static func performDeleteComment_Echd(
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        performAsyncAction_Echd(
            action_Echd: {
                TitleViewModel_Echd.shared_Echd.deleteComment_Echd(
                    post_echd: post_Echd,
                    comment_echd: comment_Echd,
                    isDelete_echd: true
                )
                print("已删除评论: \(comment_Echd.commentContent_Echd)")
            },
            completion_Echd: completion_Echd
        )
    }
    
    // MARK: - 弹幕专用方法

    /// 举报弹幕（弹出确认框，确认后从弹幕池移除并回调）
    /// - Parameters:
    ///   - danmaku_Echd: 被举报的弹幕
    ///   - viewController_Echd: 发起操作的视图控制器
    ///   - completion_Echd: 举报完成后的回调
    static func reportDanmaku_Echd(
        danmaku_Echd: DanmakuModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        UIAlertController.report_Echd(with: false, completeBlock: {
            DanmakuFavVM_Echd.shared_Echd.removeDanmaku_Echd(danmakuId_echd: danmaku_Echd.danmakuId_Echd)
            completion_Echd?()
        })
    }

    /// 删除自己发布的弹幕（弹出确认框，确认后删除并回调）
    /// - Parameters:
    ///   - danmaku_Echd: 要删除的弹幕
    ///   - viewController_Echd: 发起操作的视图控制器
    ///   - completion_Echd: 删除完成后的回调
    static func deleteDanmaku_Echd(
        danmaku_Echd: DanmakuModel_Echd,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) {
        showDeleteConfirmAlert_Echd(
            title_Echd: "Delete Spark",
            message_Echd: "Are you sure you want to delete this spark? This action cannot be undone.",
            from: viewController_Echd
        ) {
            DanmakuFavVM_Echd.shared_Echd.deleteMyDanmaku_Echd(danmakuId_echd: danmaku_Echd.danmakuId_Echd)
            completion_Echd?()
        }
    }

    // MARK: - 按钮创建方法
    
    /// 创建举报按钮
    @MainActor static func createPostReportButton_Echd(
        post_Echd: TitleModel_Echd,
        size_Echd: CGFloat = 25,
        color_Echd: UIColor = .black,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) -> UIButton {
        let button_Echd = UIButton(type: .system)
        
        // 判断是否是自己的帖子
        let isMyPost_Echd = UserViewModel_Echd.shared_Echd.isCurrentUser_Echd(
            userId_echd: post_Echd.titleUserId_Echd
        )
        
        // 配置按钮图标
        let iconName_Echd = isMyPost_Echd ? "trash" : "ellipsis"
        configureButtonIcon_Echd(
            button_Echd: button_Echd,
            iconName_Echd: iconName_Echd,
            size_Echd: size_Echd,
            color_Echd: color_Echd
        )
        
        button_Echd.addAction(UIAction { [weak viewController_Echd] _ in
            guard let viewController_Echd = viewController_Echd else { return }
            handlePostButtonTap_Echd(
                button_Echd: button_Echd,
                post_Echd: post_Echd,
                isMyPost_Echd: isMyPost_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }, for: .touchUpInside)
        
        return button_Echd
    }
    
    /// 创建评论举报按钮
    @MainActor static func createCommentReportButton_Echd(
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        size_Echd: CGFloat = 25,
        color_Echd: UIColor = .black,
        from viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)? = nil
    ) -> UIButton {
        let button_Echd = UIButton(type: .system)
        
        // 判断是否是自己的评论
        let isMyComment_Echd = UserViewModel_Echd.shared_Echd.isCurrentUser_Echd(
            userId_echd: comment_Echd.commentUserId_Echd
        )
        
        // 配置按钮图标
        let iconName_Echd = isMyComment_Echd ? "trash" : "ellipsis"
        configureButtonIcon_Echd(
            button_Echd: button_Echd,
            iconName_Echd: iconName_Echd,
            size_Echd: size_Echd,
            color_Echd: color_Echd
        )
        
        button_Echd.addAction(UIAction { [weak viewController_Echd] _ in
            guard let viewController_Echd = viewController_Echd else { return }
            handleCommentButtonTap_Echd(
                button_Echd: button_Echd,
                comment_Echd: comment_Echd,
                post_Echd: post_Echd,
                isMyComment_Echd: isMyComment_Echd,
                viewController_Echd: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }, for: .touchUpInside)
        
        return button_Echd
    }
    
    /// 创建用户举报按钮（用于聊天、视频通话等场景）
    static func createUserReportButton_Echd(
        size_Echd: CGFloat = 44,
        backgroundColor_Echd: UIColor? = nil,
        tintColor_Echd: UIColor = .white,
        withShadow_Echd: Bool = false
    ) -> UIButton {
        let button_Echd = UIButton(type: .system)
        
        // 配置图标
        let iconSize_Echd = size_Echd * 0.5
        let config_Echd = UIImage.SymbolConfiguration(pointSize: iconSize_Echd, weight: .semibold)
        let image_Echd = UIImage(systemName: "ellipsis", withConfiguration: config_Echd)
        button_Echd.setImage(image_Echd, for: .normal)
        button_Echd.tintColor = tintColor_Echd
        
        // 设置背景
        let bgColor_Echd = backgroundColor_Echd ?? UIColor.white.withAlphaComponent(0.2)
        button_Echd.backgroundColor = bgColor_Echd
        button_Echd.layer.cornerRadius = size_Echd / 2
        
        // 添加阴影
        if withShadow_Echd {
            button_Echd.layer.shadowColor = UIColor.black.cgColor
            button_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
            button_Echd.layer.shadowOpacity = 0.15
            button_Echd.layer.shadowRadius = 8
        }
        
        return button_Echd
    }
    
    // MARK: - 私有辅助方法
    
    /// 添加按钮点击动画
    fileprivate static func addButtonAnimation_Echd(button_Echd: UIButton) {
        UIView.animate(withDuration: animationDuration_Echd, animations: {
            button_Echd.transform = CGAffineTransform(
                scaleX: animationScale_Echd,
                y: animationScale_Echd
            )
        }) { _ in
            UIView.animate(withDuration: animationDuration_Echd) {
                button_Echd.transform = .identity
            }
        }
    }
    
    /// 配置按钮图标
    private static func configureButtonIcon_Echd(
        button_Echd: UIButton,
        iconName_Echd: String,
        size_Echd: CGFloat,
        color_Echd: UIColor
    ) {
        let config_Echd = UIImage.SymbolConfiguration(pointSize: size_Echd, weight: .semibold)
        let image_Echd = UIImage(systemName: iconName_Echd, withConfiguration: config_Echd)
        button_Echd.setImage(image_Echd, for: .normal)
        button_Echd.tintColor = color_Echd
    }
    
    /// 处理按钮点击（帖子）
    private static func handlePostButtonTap_Echd(
        button_Echd: UIButton,
        post_Echd: TitleModel_Echd,
        isMyPost_Echd: Bool,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)?
    ) {
        addButtonAnimation_Echd(button_Echd: button_Echd)
        
        if isMyPost_Echd {
            delete_Echd(
                post_Echd: post_Echd,
                from: viewController_Echd,
                completion_Echd: completion_Echd
            )
        } else {
            report_Echd(
                post_Echd: post_Echd,
                from: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }
    }
    
    /// 处理按钮点击（评论）
    private static func handleCommentButtonTap_Echd(
        button_Echd: UIButton,
        comment_Echd: Comment_Echd,
        post_Echd: TitleModel_Echd,
        isMyComment_Echd: Bool,
        viewController_Echd: UIViewController,
        completion_Echd: (() -> Void)?
    ) {
        addButtonAnimation_Echd(button_Echd: button_Echd)
        
        if isMyComment_Echd {
            delete_Echd(
                comment_Echd: comment_Echd,
                post_Echd: post_Echd,
                from: viewController_Echd,
                completion_Echd: completion_Echd
            )
        } else {
            report_Echd(
                comment_Echd: comment_Echd,
                post_Echd: post_Echd,
                from: viewController_Echd,
                completion_Echd: completion_Echd
            )
        }
    }
}
