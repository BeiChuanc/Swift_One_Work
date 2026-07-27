import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心页面视图控制器
/// 核心作用：展示指定用户的资料、数据统计与发布内容，支持关注与私信互动
/// 设计思路：
///   - 顶部渐变资料卡升级为三色渐变 + 悬浮光晕装饰 + 更强投影，呼应发现页横幅的"桌面摆件"视觉基调；
///     发布数达标（≥5 篇）的用户会在头像角标叠加"人气收藏家"徽标，让真实数据驱动的荣誉感自然呈现
///   - 数据统计行以竖向分隔线区隔关注 / 粉丝 / 发布三项，视觉更清晰规整
///   - 关注按钮改为图标 + 文案，已关注/未关注两态均带柔和投影；消息按钮同样强化投影层次
///   - 帖子分区标题统一为"图标徽标 + 标题 + 数量胶囊"的分区头样式，与详情页评论分区保持同一视觉语言；
///     无帖子时使用统一风格缺省态卡片替代单薄文字提示
///   - 关注按钮 + 消息按钮：点击消息按钮时先校验关注关系，未关注给出提示，
///     已关注则弹出底部信息确认面板，确认后才进入聊天页面
///   - 若从聊天页进入（isFromChat_Orna），隐藏消息按钮并将关注按钮居中显示；
///     此时若在此页取消关注，将直接清除该用户的聊天记录并返回消息列表
///   - 右上角举报按钮复用 ReportDeleteHelper_Orna 的拉黑流程
///   - 帖子列表复用 PostCardView_Orna
/// 关键属性：
///   - userModel_Orna: 目标用户模型
///   - isFromChat_Orna: 是否从聊天页进入（影响按钮布局与取消关注后的跳转行为）
class UserInfo_Orna: UIViewController {

    /// 人气收藏家徽标的最低发布数门槛
    private static let popularCreatorThreshold_Orna: Int = 5

    /// 用户模型
    var userModel_Orna: PrewUserModel_Orna?

    /// 是否从聊天页进入
    var isFromChat_Orna: Bool = false

    // MARK: - UI · 背景装饰

    /// 资料卡背后的柔和光晕圆，透过卡片圆角边缘微微露出，强化层叠悬浮的立体感
    private let decorCircleTop_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#FF6B9D").withAlphaComponent(0.12)
        return v
    }()

    private let decorCircleBottom_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.10)
        return v
    }()

    // MARK: - UI · 顶部工具条

    private let backButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private lazy var reportButton_Orna: UIButton = ReportDeleteHelper_Orna.createUserReportButton_Orna(
        size_Orna: 36,
        backgroundColor_Orna: UIColor.white.withAlphaComponent(0.2),
        tintColor_Orna: .white
    )

    // MARK: - UI · 资料卡

    private let headerCardView_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()

    /// 资料卡外层投影容器：headerCardView_Orna 自身 clipsToBounds 无法承载阴影，
    /// 使用独立底层视图承接更强的投影，强化卡片的悬浮层次感
    private let headerShadowView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 28
        v.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        v.layer.shadowOpacity = 0.22
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        return v
    }()

    private var headerGradientLayer_Orna: CAGradientLayer?

    /// 资料卡右上角装饰性光晕圆，呼应发现页横幅的"桌面摆件"点缀语言
    private let headerSparkleView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.22)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 38
        v.clipsToBounds = true
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        return v
    }()

    /// 人气收藏家徽标：发布数达到门槛时叠加于头像右下角，纯展示无交互
    private let popularBadgeView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#FFB74D")
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        v.isHidden = true
        return v
    }()

    private let popularBadgeIconView_Orna: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 21, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let bioLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.85)
        l.numberOfLines = 2
        return l
    }()

    private let statsRow_Orna = UIView()
    private let followStatView_Orna = ProfileStatItemView_Orna()
    private let fansStatView_Orna = ProfileStatItemView_Orna()
    private let postStatView_Orna = ProfileStatItemView_Orna()

    /// 数据统计项之间的竖向分隔线，弱化裸露数字堆叠的杂乱感
    private let statsDividerLeft_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return v
    }()

    private let statsDividerRight_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        return v
    }()

    private let followButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        return b
    }()

    private let messageButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "message.fill"), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#7B61FF")
        b.backgroundColor = .white
        b.layer.cornerRadius = 18
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        return b
    }()

    // MARK: - UI · 帖子列表

    /// 帖子分区头（图标徽标 + 标题），与帖子详情页评论分区保持同一视觉语言
    private lazy var postsSectionHeader_Orna = makeSectionHeader_Orna(icon_orna: "square.grid.2x2.fill", accentColorHex_orna: "#7B61FF")

    private let postsSectionTitleLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "Posts"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    /// 帖子数量胶囊：展示该用户发布总数，与分区标题呼应形成完整信息闭环
    private let postsCountChip_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        v.layer.cornerRadius = 11
        return v
    }()

    private let postsCountLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#7B61FF")
        return l
    }()

    private let scrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView_Orna = UIView()

    private let listStack_Orna: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    /// 无帖子时的统一风格缺省态，替代原本单薄的纯文字提示
    private let emptyStateView_Orna: EmptyStateView_Orna = {
        let v = EmptyStateView_Orna()
        v.configure_Orna(
            icon_orna: "tray.fill",
            title_orna: "No posts yet",
            subtitle_orna: "This wanderer hasn't shared a desk moment yet."
        )
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Orna: "#F6F3FF")
        setupUI_Orna()
        setupConstraints_Orna()
        setupActions_Orna()
        observeStateChanges_Orna()
        refreshAll_Orna()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        refreshAll_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradientLayer_Orna?.frame = headerCardView_Orna.bounds
        headerShadowView_Orna.layer.shadowPath = UIBezierPath(roundedRect: headerShadowView_Orna.bounds, cornerRadius: 28).cgPath
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    private func setupUI_Orna() {
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(contentView_Orna)

        contentView_Orna.addSubview(decorCircleTop_Orna)
        contentView_Orna.addSubview(decorCircleBottom_Orna)

        contentView_Orna.addSubview(headerShadowView_Orna)
        contentView_Orna.addSubview(headerCardView_Orna)
        setupHeaderGradient_Orna()
        headerCardView_Orna.addSubview(headerSparkleView_Orna)
        headerCardView_Orna.addSubview(backButton_Orna)
        headerCardView_Orna.addSubview(reportButton_Orna)
        headerCardView_Orna.addSubview(avatarView_Orna)
        popularBadgeView_Orna.addSubview(popularBadgeIconView_Orna)
        headerCardView_Orna.addSubview(popularBadgeView_Orna)
        headerCardView_Orna.addSubview(nameLabel_Orna)
        headerCardView_Orna.addSubview(bioLabel_Orna)
        headerCardView_Orna.addSubview(statsRow_Orna)
        headerCardView_Orna.addSubview(followButton_Orna)
        headerCardView_Orna.addSubview(messageButton_Orna)

        statsRow_Orna.addSubview(followStatView_Orna)
        statsRow_Orna.addSubview(statsDividerLeft_Orna)
        statsRow_Orna.addSubview(fansStatView_Orna)
        statsRow_Orna.addSubview(statsDividerRight_Orna)
        statsRow_Orna.addSubview(postStatView_Orna)

        postsCountChip_Orna.addSubview(postsCountLabel_Orna)
        contentView_Orna.addSubview(postsSectionHeader_Orna)
        contentView_Orna.addSubview(postsSectionTitleLabel_Orna)
        contentView_Orna.addSubview(postsCountChip_Orna)
        contentView_Orna.addSubview(listStack_Orna)
        contentView_Orna.addSubview(emptyStateView_Orna)
    }

    /// 资料卡三色渐变背景：紫 → 靛蓝 → 粉，比原双色渐变层次更丰富
    private func setupHeaderGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#63B3ED").cgColor,
            UIColor(hexstring_Orna: "#8B7BFF").cgColor,
            UIColor(hexstring_Orna: "#B388EB").cgColor
        ]
        layer_orna.locations = [0, 0.55, 1]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        headerCardView_Orna.layer.insertSublayer(layer_orna, at: 0)
        headerGradientLayer_Orna = layer_orna
    }

    /// 搭建帖子分区头图标徽标，与帖子详情页评论分区保持同一视觉语言
    /// 参数：
    /// - icon_orna: SF Symbols 图标名称
    /// - accentColorHex_orna: 该分区的强调色（十六进制）
    private func makeSectionHeader_Orna(icon_orna: String, accentColorHex_orna: String) -> UIView {
        let container_orna = UIView()
        let accentColor_orna = UIColor(hexstring_Orna: accentColorHex_orna)

        let badge_orna = UIView()
        badge_orna.backgroundColor = accentColor_orna.withAlphaComponent(0.15)
        badge_orna.layer.cornerRadius = 14
        container_orna.addSubview(badge_orna)

        let iconView_orna = UIImageView(image: UIImage(systemName: icon_orna))
        iconView_orna.tintColor = accentColor_orna
        iconView_orna.contentMode = .scaleAspectFit
        badge_orna.addSubview(iconView_orna)

        badge_orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(28)
        }
        iconView_orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        return container_orna
    }

    // MARK: - 约束

    private func setupConstraints_Orna() {
        scrollView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        decorCircleTop_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-40)
            $0.trailing.equalToSuperview().offset(50)
            $0.width.height.equalTo(180)
        }
        decorCircleBottom_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalToSuperview().offset(-70)
            $0.width.height.equalTo(160)
        }

        headerShadowView_Orna.snp.makeConstraints { $0.edges.equalTo(headerCardView_Orna) }
        headerCardView_Orna.snp.makeConstraints {
            // 注意：顶部安全区锚点必须取自 contentView_Orna（滚动内容自身），而非 view（控制器根视图）。
            // 若跨越 UIScrollView 边界直接锚定到 view.safeAreaLayoutGuide，Auto Layout 会在每次布局时
            // 将该视图强制拉回相对屏幕的固定位置，导致 scrollView 内容整体无法真正滚动。
            $0.top.equalTo(contentView_Orna.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        headerSparkleView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(46)
        }
        backButton_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }
        reportButton_Orna.snp.makeConstraints {
            $0.centerY.equalTo(backButton_Orna)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(36)
        }
        avatarView_Orna.snp.makeConstraints {
            $0.top.equalTo(backButton_Orna.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(76)
        }
        popularBadgeView_Orna.snp.makeConstraints {
            $0.bottom.trailing.equalTo(avatarView_Orna)
            $0.width.height.equalTo(22)
        }
        popularBadgeIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(11)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna)
            $0.leading.equalTo(avatarView_Orna.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        bioLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(6)
            $0.leading.equalTo(nameLabel_Orna)
            $0.trailing.equalToSuperview().offset(-16)
        }
        statsRow_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        followStatView_Orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(fansStatView_Orna)
        }
        statsDividerLeft_Orna.snp.makeConstraints {
            $0.leading.equalTo(followStatView_Orna.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(24)
        }
        fansStatView_Orna.snp.makeConstraints {
            $0.leading.equalTo(statsDividerLeft_Orna.snp.trailing)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(postStatView_Orna)
        }
        statsDividerRight_Orna.snp.makeConstraints {
            $0.leading.equalTo(fansStatView_Orna.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(1)
            $0.height.equalTo(24)
        }
        postStatView_Orna.snp.makeConstraints {
            $0.leading.equalTo(statsDividerRight_Orna.snp.trailing)
            $0.trailing.top.bottom.equalToSuperview()
        }

        // 消息按钮位置固定；关注按钮的位置随 isFromChat_Orna 在 refreshButtonsLayout_Orna 中动态调整
        messageButton_Orna.snp.makeConstraints {
            $0.top.equalTo(statsRow_Orna.snp.bottom).offset(18)
            $0.bottom.equalToSuperview().offset(-20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(44)
            $0.width.equalTo(44)
        }

        postsSectionHeader_Orna.snp.makeConstraints {
            $0.top.equalTo(headerCardView_Orna.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(28)
        }
        postsSectionTitleLabel_Orna.snp.makeConstraints {
            $0.centerY.equalTo(postsSectionHeader_Orna)
            // 徽标容器自身宽度未显式约束（仅内部图标 badge 靠左对齐），
            // 因此标题改为直接相对徽标容器"起点"偏移 36（= 28 宽度 + 8 间距）定位，
            // 而非依赖容器的 trailing（容器宽度未定义时 trailing 等同 leading，会与徽标重叠）
            $0.leading.equalTo(postsSectionHeader_Orna).offset(36)
        }
        postsCountChip_Orna.snp.makeConstraints {
            $0.centerY.equalTo(postsSectionHeader_Orna)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(22)
            $0.width.greaterThanOrEqualTo(40)
        }
        postsCountLabel_Orna.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10))
        }
        listStack_Orna.snp.makeConstraints {
            $0.top.equalTo(postsSectionHeader_Orna.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-30)
        }
        emptyStateView_Orna.snp.makeConstraints {
            $0.top.equalTo(postsSectionHeader_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
    }

    /// 依据 isFromChat_Orna 动态调整关注 / 消息按钮布局
    private func refreshButtonsLayout_Orna() {
        messageButton_Orna.isHidden = isFromChat_Orna
        followButton_Orna.snp.remakeConstraints { make in
            make.top.equalTo(statsRow_Orna.snp.bottom).offset(18)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            if isFromChat_Orna {
                make.centerX.equalToSuperview()
                make.width.equalTo(160)
            } else {
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalTo(messageButton_Orna.snp.leading).offset(-12)
            }
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Orna() {
        backButton_Orna.addTarget(self, action: #selector(handleBackTapped_Orna), for: .touchUpInside)
        reportButton_Orna.addTarget(self, action: #selector(handleReportTapped_Orna), for: .touchUpInside)
        followButton_Orna.addTarget(self, action: #selector(handleFollowTapped_Orna), for: .touchUpInside)
        messageButton_Orna.addTarget(self, action: #selector(handleMessageTapped_Orna), for: .touchUpInside)
    }

    private func observeStateChanges_Orna() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: UserViewModel_Orna.userStateDidChangeNotification_Orna, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAll_Orna),
            name: TitleViewModel_Orna.titleStateDidChangeNotification_Orna, object: nil
        )
    }

    // MARK: - 数据刷新

    @objc private func refreshAll_Orna() {
        guard let user_orna = userModel_Orna, let userId_orna = user_orna.userId_Orna else { return }

        avatarView_Orna.configure_Orna(userId_Orna: userId_orna)
        nameLabel_Orna.text = user_orna.userName_Orna
        bioLabel_Orna.text = (user_orna.userIntroduce_Orna?.isEmpty == false) ? user_orna.userIntroduce_Orna : "This wanderer hasn't written a bio yet."

        followStatView_Orna.configure_Orna(count_orna: user_orna.userFollow_Orna ?? 0, title_orna: "Following")
        fansStatView_Orna.configure_Orna(count_orna: user_orna.userFans_Orna ?? 0, title_orna: "Fans")
        let postCount_orna = TitleViewModel_Orna.shared_Orna.getUserPosts_Orna(user_orna: user_orna).count
        postStatView_Orna.configure_Orna(count_orna: postCount_orna, title_orna: "Posts")
        postsCountLabel_Orna.text = "\(postCount_orna) total"
        popularBadgeView_Orna.isHidden = postCount_orna < Self.popularCreatorThreshold_Orna

        let isFollowing_orna = UserViewModel_Orna.shared_Orna.isFollowing_Orna(user_orna: user_orna)
        updateFollowButtonAppearance_Orna(isFollowing_orna: isFollowing_orna)
        refreshButtonsLayout_Orna()
        refreshPosts_Orna(user_orna: user_orna)
    }

    /// 更新关注按钮外观（图标 + 文案，已关注/未关注两态）
    private func updateFollowButtonAppearance_Orna(isFollowing_orna: Bool) {
        var config_orna = UIButton.Configuration.plain()
        config_orna.image = UIImage(
            systemName: isFollowing_orna ? "checkmark" : "person.fill.badge.plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        )
        config_orna.title = isFollowing_orna ? "Following" : "Follow"
        config_orna.imagePadding = 6
        config_orna.contentInsets = .zero
        config_orna.baseForegroundColor = isFollowing_orna ? UIColor(hexstring_Orna: "#7B61FF") : .white
        config_orna.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing_orna = incoming
            outgoing_orna.font = .systemFont(ofSize: 14, weight: .bold)
            return outgoing_orna
        }
        followButton_Orna.configuration = config_orna
        followButton_Orna.backgroundColor = isFollowing_orna ? .white : UIColor.white.withAlphaComponent(0.25)
        followButton_Orna.layer.borderWidth = isFollowing_orna ? 0 : 1.5
        followButton_Orna.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
    }

    /// 刷新该用户的帖子列表
    private func refreshPosts_Orna(user_orna: PrewUserModel_Orna) {
        listStack_Orna.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let posts_orna = TitleViewModel_Orna.shared_Orna.getUserPosts_Orna(user_orna: user_orna)
        emptyStateView_Orna.isHidden = !posts_orna.isEmpty

        for post_orna in posts_orna.reversed() {
            let card_orna = PostCardView_Orna()
            card_orna.configure_Orna(post_orna: post_orna, from: self, showAuthor_orna: false, mediaHeight_orna: 170) { [weak self] in
                self?.refreshAll_Orna()
            }
            listStack_Orna.addArrangedSubview(card_orna)
        }
    }

    // MARK: - 事件处理

    @objc private func handleBackTapped_Orna() {
        Navigation_Orna.pop_Orna(from: self)
    }

    /// 举报/拉黑该用户，成功后清除导航栈中与该用户相关的页面
    @objc private func handleReportTapped_Orna() {
        guard let user_orna = userModel_Orna else { return }
        ReportDeleteHelper_Orna.block_Orna(user_Orna: user_orna, from: self) { [weak self] in
            guard let self else { return }
            Navigation_Orna.popToSafeStateAfterBlock_Orna(from: self)
        }
    }

    /// 关注/取消关注按钮点击
    /// 若从聊天页进入且取消关注，则移除该用户聊天记录并返回消息列表
    @objc private func handleFollowTapped_Orna() {
        guard let user_orna = userModel_Orna, let userId_orna = user_orna.userId_Orna else { return }
        let wasFollowing_orna = UserViewModel_Orna.shared_Orna.isFollowing_Orna(user_orna: user_orna)

        UserViewModel_Orna.shared_Orna.followUser_Orna(user_orna: user_orna)

        if isFromChat_Orna, wasFollowing_orna {
            MessageViewModel_Orna.shared_Orna.deleteUserMessages_Orna(userId_orna: userId_orna)
            Navigation_Orna.popToMessageListAfterUnfollow_Orna(from: self)
        }
    }

    /// 消息按钮点击：未关注给出提示，已关注弹出确认面板后进入聊天
    @objc private func handleMessageTapped_Orna() {
        guard let user_orna = userModel_Orna else { return }

        guard UserViewModel_Orna.shared_Orna.isFollowing_Orna(user_orna: user_orna) else {
            let alert_orna = UIAlertController(
                title: "Follow Required",
                message: "You need to follow this user before you can send a message.",
                preferredStyle: .alert
            )
            alert_orna.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert_orna, animated: true)
            return
        }

        let sheet_orna = ChatEntryConfirmSheet_Orna(user_orna: user_orna)
        sheet_orna.onConfirm_Orna = { [weak self] in
            guard let self, let confirmedUser_orna = self.userModel_Orna else { return }
            Navigation_Orna.toMessageUser_Orna(with: confirmedUser_orna)
        }
        sheet_orna.present(from: self)
    }
}

// MARK: - 聊天确认底部弹窗

/// 进入聊天确认底部弹窗
/// 核心作用：进入私信前的二次确认，底部弹窗展示目标用户信息，确认后才允许进入聊天页面
/// 设计思路：新增顶部拖拽把手与头像描边环，确认按钮改为品牌渐变，与全 App 其他底部弹窗 / CTA 视觉统一
private class ChatEntryConfirmSheet_Orna: UIViewController {

    /// 确认回调
    var onConfirm_Orna: (() -> Void)?

    private let targetUser_Orna: PrewUserModel_Orna

    private let dimView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return v
    }()

    private let cardView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 26
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    /// 顶部拖拽把手，暗示这是一个可下滑关闭的底部弹窗
    private let grabberView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Orna: "#EDE9FE")
        v.layer.cornerRadius = 2.5
        return v
    }()

    private let avatarView_Orna: UserAvatarView_Orna = {
        let v = UserAvatarView_Orna()
        v.layer.cornerRadius = 30
        v.clipsToBounds = true
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor(hexstring_Orna: "#7B61FF").withAlphaComponent(0.2).cgColor
        return v
    }()

    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = UIColor(hexstring_Orna: "#2D2A3D")
        return l
    }()

    private let bioLabel_Orna: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.numberOfLines = 2
        return l
    }()

    private let hintLabel_Orna: UILabel = {
        let l = UILabel()
        l.text = "💬 Start a private chat with this wanderer?"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(hexstring_Orna: "#8B87A0")
        l.textAlignment = .center
        return l
    }()

    private let confirmButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("Confirm & Chat", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.layer.cornerRadius = 22
        b.layer.shadowColor = UIColor(hexstring_Orna: "#7B61FF").cgColor
        b.layer.shadowOpacity = 0.28
        b.layer.shadowOffset = CGSize(width: 0, height: 6)
        b.layer.shadowRadius = 12
        return b
    }()

    private var confirmButtonGradientLayer_Orna: CAGradientLayer?

    private let cancelButton_Orna: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.setTitleColor(UIColor(hexstring_Orna: "#8B87A0"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return b
    }()

    init(user_orna: PrewUserModel_Orna) {
        self.targetUser_Orna = user_orna
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupUI_Orna()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmButtonGradientLayer_Orna?.frame = confirmButton_Orna.bounds
    }

    private func setupUI_Orna() {
        view.addSubview(dimView_Orna)
        view.addSubview(cardView_Orna)
        cardView_Orna.addSubview(grabberView_Orna)
        cardView_Orna.addSubview(avatarView_Orna)
        cardView_Orna.addSubview(nameLabel_Orna)
        cardView_Orna.addSubview(bioLabel_Orna)
        cardView_Orna.addSubview(hintLabel_Orna)
        cardView_Orna.addSubview(confirmButton_Orna)
        setupConfirmButtonGradient_Orna()
        cardView_Orna.addSubview(cancelButton_Orna)

        dimView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Orna.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        grabberView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(36)
            $0.height.equalTo(5)
        }
        avatarView_Orna.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        nameLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(avatarView_Orna.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        bioLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(nameLabel_Orna.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.centerX.equalToSuperview()
        }
        hintLabel_Orna.snp.makeConstraints {
            $0.top.equalTo(bioLabel_Orna.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        confirmButton_Orna.snp.makeConstraints {
            $0.top.equalTo(hintLabel_Orna.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(46)
        }
        cancelButton_Orna.snp.makeConstraints {
            $0.top.equalTo(confirmButton_Orna.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-14)
            $0.height.equalTo(30)
        }

        if let userId_orna = targetUser_Orna.userId_Orna {
            avatarView_Orna.configure_Orna(userId_Orna: userId_orna)
        }
        nameLabel_Orna.text = targetUser_Orna.userName_Orna
        bioLabel_Orna.text = targetUser_Orna.userIntroduce_Orna

        let dimTap_orna = UITapGestureRecognizer(target: self, action: #selector(handleCancel_Orna))
        dimView_Orna.addGestureRecognizer(dimTap_orna)
        confirmButton_Orna.addTarget(self, action: #selector(handleConfirm_Orna), for: .touchUpInside)
        cancelButton_Orna.addTarget(self, action: #selector(handleCancel_Orna), for: .touchUpInside)

        cardView_Orna.transform = CGAffineTransform(translationX: 0, y: 300)
    }

    /// 确认按钮紫粉品牌渐变背景，与全 App 主要 CTA 按钮保持同一强调色
    private func setupConfirmButtonGradient_Orna() {
        let layer_orna = CAGradientLayer()
        layer_orna.colors = [
            UIColor(hexstring_Orna: "#7B61FF").cgColor,
            UIColor(hexstring_Orna: "#FF6B9D").cgColor
        ]
        layer_orna.startPoint = CGPoint(x: 0, y: 0)
        layer_orna.endPoint = CGPoint(x: 1, y: 1)
        layer_orna.cornerRadius = 22
        confirmButton_Orna.layer.insertSublayer(layer_orna, at: 0)
        confirmButtonGradientLayer_Orna = layer_orna
    }

    /// 展示底部弹窗（弹性上滑动画）
    func present(from viewController_orna: UIViewController) {
        viewController_orna.present(self, animated: true) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.6) {
                self.cardView_Orna.transform = .identity
            }
        }
    }

    @objc private func handleConfirm_Orna() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm_Orna?()
        }
    }

    @objc private func handleCancel_Orna() {
        dismiss(animated: true)
    }
}
