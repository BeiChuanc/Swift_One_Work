import Foundation
import UIKit
import SnapKit

// MARK: - 帖子卡片组件

/// 帖子卡片视图
/// 核心作用：统一展示单条帖子的媒体、作者（可选）、标题、内容摘要与互动数据，
///           并在右上角提供举报/删除按钮，供"我的"、"用户中心"、"发现"等页面复用
/// 设计思路：
///   - 媒体展示复用 MediaDisplayView_Orna，支持图片 / 视频缩略图
///   - 举报/删除按钮复用 ReportDeleteHelper_Orna，自动区分本人内容与他人内容
///   - 点击卡片默认跳转帖子详情页，点击按钮不触发跳转
/// 关键属性：
///   - onDeleted_Orna: 举报/删除成功后的回调，供宿主页面移除该卡片
class PostCardView_Orna: UIView {

    // MARK: - 属性

    /// 当前绑定的帖子模型
    private var post_Orna: TitleModel_Orna?

    /// 举报/删除成功后的回调
    private var onDeleted_Orna: (() -> Void)?

    // MARK: - UI组件

    private let mediaView_Orna = MediaDisplayView_Orna()

    private var mediaHeightConstraint_Orna: Constraint?

    /// 左侧色带（发现页瀑布流用于按帖子轮换主题色，丰富卡片视觉层次；默认隐藏不影响其他页面）
    private let accentBarView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.isHidden = true
        return v
    }()

    /// 热门标签（点赞数较高的帖子展示，叠加在媒体图左上角，与右上角举报按钮对称）
    private let hotBadgeView_Orna: UILabel = {
        let l = UILabel()
        l.text = "🔥 Hot"
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.92)
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.isHidden = true
        return l
    }()

    /// 作者行容器（默认隐藏，展示作者时使用）
    private let authorRow_Orna: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let authorAvatarView_Orna = UserAvatarView_Orna()

    private let authorNameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let titleLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        l.numberOfLines = 2
        return l
    }()

    private let contentLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.numberOfLines = 2
        return l
    }()

    private let likeIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor = UIColor(hexstring_Orna: "#FF6B9D")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likeCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    private let commentIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.left.fill"))
        iv.tintColor = UIColor(hexstring_Orna: "#8B87A0")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        return l
    }()

    /// 举报/删除按钮容器（按钮由 ReportDeleteHelper_Orna 动态创建后插入）
    private let actionButtonContainer_Orna: UIView = {
        let v = UIView()
        return v
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI搭建

    private func setupUI_Orna() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10

        addSubview(mediaView_Orna)
        addSubview(accentBarView_Orna)
        addSubview(actionButtonContainer_Orna)
        addSubview(hotBadgeView_Orna)

        authorRow_Orna.addSubview(authorAvatarView_Orna)
        authorRow_Orna.addSubview(authorNameLabel_Orna)
        addSubview(authorRow_Orna)

        addSubview(titleLabel_Orna)
        addSubview(contentLabel_Orna)
        addSubview(likeIconView_Orna)
        addSubview(likeCountLabel_Orna)
        addSubview(commentIconView_Orna)
        addSubview(commentCountLabel_Orna)

        mediaView_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            mediaHeightConstraint_Orna = $0.height.equalTo(140).constraint
        }
        actionButtonContainer_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaView_Orna).offset(10)
            $0.trailing.equalTo(mediaView_Orna).offset(-10)
            $0.width.height.equalTo(30)
        }
        accentBarView_Orna.snp.makeConstraints {
            // 上下各留出圆角安全距离，避免方形色带边角溢出卡片圆角轮廓
            $0.leading.equalToSuperview()
            $0.top.equalTo(mediaView_Orna.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalTo(4)
        }
        hotBadgeView_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaView_Orna).offset(10)
            $0.leading.equalTo(mediaView_Orna).offset(10)
            $0.height.equalTo(20)
            $0.width.equalTo(52)
        }

        authorAvatarView_Orna.snp.makeConstraints { $0.width.height.equalTo(22) }
        authorAvatarView_Orna.layer.cornerRadius = 11
        authorAvatarView_Orna.clipsToBounds = true
        authorRow_Orna.snp.makeConstraints {
            $0.top.equalTo(mediaView_Orna.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(22)
        }
        authorAvatarView_Orna.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        authorNameLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(authorAvatarView_Orna.snp.trailing).offset(6)
            $0.trailing.centerY.equalToSuperview()
        }

        titleLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(authorRow_Orna.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        contentLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        likeIconView_Orna.snp.makeConstraints {
            $0.top.equalTo(contentLabel_Orna.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(13)
            $0.bottom.equalToSuperview().offset(-12)
        }
        likeCountLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(likeIconView_Orna.snp.trailing).offset(4)
            $0.centerY.equalTo(likeIconView_Orna)
        }
        commentIconView_Orna.snp.makeConstraints {
            $0.leading.equalTo(likeCountLabel_Orna.snp.trailing).offset(14)
            $0.centerY.equalTo(likeIconView_Orna)
            $0.width.height.equalTo(13)
        }
        commentCountLabel_Orna.snp.makeConstraints {
            $0.leading.equalTo(commentIconView_Orna.snp.trailing).offset(4)
            $0.centerY.equalTo(likeIconView_Orna)
        }

        let tap_orna = UITapGestureRecognizer(target: self, action: #selector(handleCardTap_Orna))
        addGestureRecognizer(tap_orna)
        isUserInteractionEnabled = true
    }

    // MARK: - 公共方法

    /// 配置帖子卡片
    /// 参数：
    /// - post_orna: 帖子模型
    /// - viewController_orna: 承载举报/删除弹窗的视图控制器
    /// - showAuthor_orna: 是否展示作者头像与昵称（发现页需要，个人主页无需）
    /// - showContentPreview_orna: 是否展示正文摘要
    /// - mediaHeight_orna: 媒体展示高度（用于瀑布流构造不规则高度）
    /// - accentColorHex_orna: 卡片主题色（十六进制，如 "#7B61FF"），传入后左侧显示色带并轻染卡片背景，
    ///   用于发现页瀑布流按帖子轮换主题色以丰富视觉层次；为 nil 时保持原有纯白卡片样式
    /// - isHot_orna: 是否展示"热门"标签（用于发现页高互动帖子的视觉强调）
    /// - onDeleted_orna: 举报/删除成功后的回调，供宿主页面移除该卡片
    func configure_Orna(
        post_orna: TitleModel_Orna,
        from viewController_orna: UIViewController,
        showAuthor_orna: Bool = false,
        showContentPreview_orna: Bool = true,
        mediaHeight_orna: CGFloat = 140,
        accentColorHex_orna: String? = nil,
        isHot_orna: Bool = false,
        onDeleted_orna: (() -> Void)? = nil
    ) {
        self.post_Orna = post_orna
        self.onDeleted_Orna = onDeleted_orna

        mediaView_Orna.configure_Orna(mediaPath_Orna: post_orna.titleMeidas_Orna.first, isVideo_Orna: post_orna.isVideoMedia_Orna)
        mediaHeightConstraint_Orna?.update(offset: mediaHeight_orna)

        applyAccentTheme_Orna(colorHex_orna: accentColorHex_orna)
        hotBadgeView_Orna.isHidden = !isHot_orna

        authorRow_Orna.isHidden = !showAuthor_orna
        if showAuthor_orna {
            authorAvatarView_Orna.configure_Orna(userId_Orna: post_orna.titleUserId_Orna)
            authorNameLabel_Orna.text = post_orna.titleUserName_Orna
        }

        titleLabel_Orna.text = post_orna.title_Orna
        contentLabel_Orna.isHidden = !showContentPreview_orna
        contentLabel_Orna.text = showContentPreview_orna ? post_orna.titleContent_Orna : nil

        likeCountLabel_Orna.text = "\(post_orna.likes_Orna)"
        commentCountLabel_Orna.text = "\(post_orna.reviews_Orna.count)"

        rebuildActionButton_Orna(post_orna: post_orna, from: viewController_orna)
    }

    // MARK: - 私有方法

    /// 应用卡片主题色：染色左侧色带、轻染背景与投影色，未传入主题色时恢复默认纯白样式
    /// 参数：
    /// - colorHex_orna: 主题色十六进制字符串，nil 表示恢复默认样式
    private func applyAccentTheme_Orna(colorHex_orna: String?) {
        guard let colorHex_orna = colorHex_orna else {
            accentBarView_Orna.isHidden = true
            backgroundColor = .white
            layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
            return
        }
        let accentColor_orna = UIColor(hexstring_Orna: colorHex_orna)
        accentBarView_Orna.isHidden = false
        accentBarView_Orna.backgroundColor = accentColor_orna
        backgroundColor = accentColor_orna.withAlphaComponent(0.06)
        layer.shadowColor = accentColor_orna.cgColor
    }

    /// 重建举报/删除按钮（依赖 ReportDeleteHelper_Orna 动态生成）
    private func rebuildActionButton_Orna(post_orna: TitleModel_Orna, from viewController_orna: UIViewController) {
        actionButtonContainer_Orna.subviews.forEach { $0.removeFromSuperview() }

        let button_orna = ReportDeleteHelper_Orna.createPostReportButton_Orna(
            post_Orna: post_orna,
            size_Orna: 14,
            color_Orna: .white,
            from: viewController_orna
        ) { [weak self] in
            self?.onDeleted_Orna?()
        }
        button_orna.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        button_orna.layer.cornerRadius = 15
        actionButtonContainer_Orna.addSubview(button_orna)
        button_orna.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    /// 点击卡片跳转帖子详情页
    @objc private func handleCardTap_Orna() {
        guard let post_orna = post_Orna else { return }
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.08) { self.transform = .identity }
        }
        Navigation_Orna.toTitleDetail_Orna(titleModel_orna: post_orna)
    }
}
