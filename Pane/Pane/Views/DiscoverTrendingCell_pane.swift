import UIKit
import SnapKit

// MARK: 发现页热门帖子横向卡片

/// 发现页热门帖子横向滑动卡片 Cell
/// 核心作用：在发现页横向热门区展示单篇帖子，包含封面图、排名徽章、作者信息和点赞数
/// 设计理念：竖向卡片 + 底部渐变遮罩 + 左上角排名徽章（前三名金银铜特殊配色）
/// 关键属性：configure_Pane(post:rank:) - 传入帖子模型和名次
class DiscoverTrendingCell_Pane: UICollectionViewCell {

    // MARK: - 静态常量

    static let reuseId_Pane = "DiscoverTrendingCell_Pane"

    // MARK: - UI组件

    /// 卡片容器
    private let containerView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 媒体封面
    private let mediaView_Pane: MediaDisplayView_Pane = {
        let v = MediaDisplayView_Pane()
        v.layer.cornerRadius = 0
        v.clipsToBounds = true
        return v
    }()

    /// 顶部轻渐变（为排名徽章背景服务）
    private let topGradientView_Pane = UIView()
    private var topGradientLayer_Pane: CAGradientLayer?

    /// 底部主渐变遮罩
    private let bottomGradientView_Pane = UIView()
    private var bottomGradientLayer_Pane: CAGradientLayer?

    /// 排名徽章容器（左上角）
    private let rankBadge_Pane: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()

    private var rankBadgeGradient_Pane: CAGradientLayer?

    /// 排名数字
    private let rankLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .black)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    /// 帖子标题
    private let titleLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    /// 作者头像（底部）
    private let authorAvatar_Pane: UserAvatarView_Pane = {
        let v = UserAvatarView_Pane()
        v.onlineIndicator_Pane.isHidden = true
        return v
    }()

    /// 作者名称
    private let authorNameLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return l
    }()

    /// 点赞数角标（右上角）
    private let likesBadge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        v.layer.cornerRadius = 11
        v.clipsToBounds = true
        return v
    }()

    private let likesIcon_Pane: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor = UIColor(hexstring_Pane: "#FC8181")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let likesCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: - 高亮响应

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                containerView_Pane.animatePressDown_Pane()
            } else {
                containerView_Pane.animatePressUp_Pane()
            }
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        setupShadow_Pane()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer_Pane?.frame    = topGradientView_Pane.bounds
        bottomGradientLayer_Pane?.frame = bottomGradientView_Pane.bounds
        rankBadgeGradient_Pane?.frame   = rankBadge_Pane.bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 18).cgPath
    }

    // MARK: - UI布局

    private func setupUI_Pane() {
        contentView.addSubview(containerView_Pane)
        containerView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView_Pane.addSubview(mediaView_Pane)
        mediaView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 顶部轻渐变（黑→透明，高度 70pt）
        containerView_Pane.addSubview(topGradientView_Pane)
        topGradientView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
        let topGL = CAGradientLayer()
        topGL.colors = [UIColor.black.withAlphaComponent(0.55).cgColor, UIColor.clear.cgColor]
        topGL.startPoint = CGPoint(x: 0.5, y: 0)
        topGL.endPoint   = CGPoint(x: 0.5, y: 1)
        topGradientView_Pane.layer.addSublayer(topGL)
        topGradientLayer_Pane = topGL

        // 底部主渐变
        containerView_Pane.addSubview(bottomGradientView_Pane)
        bottomGradientView_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.65)
        }
        let botGL = CAGradientLayer()
        botGL.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.88).cgColor]
        botGL.startPoint = CGPoint(x: 0.5, y: 0)
        botGL.endPoint   = CGPoint(x: 0.5, y: 1)
        bottomGradientView_Pane.layer.addSublayer(botGL)
        bottomGradientLayer_Pane = botGL

        // 排名徽章（左上角）
        containerView_Pane.addSubview(rankBadge_Pane)
        rankBadge_Pane.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
            $0.width.height.equalTo(28)
        }
        rankBadge_Pane.addSubview(rankLabel_Pane)
        rankLabel_Pane.snp.makeConstraints { $0.center.equalToSuperview() }

        // 点赞角标（右上角）
        containerView_Pane.addSubview(likesBadge_Pane)
        likesBadge_Pane.addSubview(likesIcon_Pane)
        likesBadge_Pane.addSubview(likesCountLabel_Pane)
        likesBadge_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(22)
        }
        likesIcon_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(11)
        }
        likesCountLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(likesIcon_Pane.snp.trailing).offset(3)
            $0.trailing.equalToSuperview().offset(-6)
            $0.centerY.equalToSuperview()
        }

        // 帖子标题（底部倒数第二行）
        containerView_Pane.addSubview(titleLabel_Pane)
        titleLabel_Pane.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-36)
        }

        // 底部作者行
        containerView_Pane.addSubview(authorAvatar_Pane)
        containerView_Pane.addSubview(authorNameLabel_Pane)
        authorAvatar_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.width.height.equalTo(18)
        }
        authorNameLabel_Pane.snp.makeConstraints {
            $0.leading.equalTo(authorAvatar_Pane.snp.trailing).offset(5)
            $0.centerY.equalTo(authorAvatar_Pane)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }

    private func setupShadow_Pane() {
        layer.shadowColor   = ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset  = CGSize(width: 0, height: 6)
        layer.shadowRadius  = 14
        layer.masksToBounds = false
        containerView_Pane.layer.masksToBounds = true
    }

    // MARK: - 数据配置

    /// 配置热门帖子卡片
    /// - Parameters:
    ///   - post_pane: 帖子数据模型
    ///   - rank_pane: 排名（1 为第一），决定徽章颜色
    func configure_Pane(post_pane: TitleModel_Pane, rank_pane: Int) {
        mediaView_Pane.configure_Pane(mediaPath_Pane: post_pane.titleMeidas_Pane.first)
        titleLabel_Pane.text      = post_pane.title_Pane
        likesCountLabel_Pane.text = "\(post_pane.likes_Pane)"
        rankLabel_Pane.text       = "\(rank_pane)"
        authorNameLabel_Pane.text = post_pane.titleUserName_Pane
        authorAvatar_Pane.configure_Pane(userId_Pane: post_pane.titleUserId_Pane)

        // 排名徽章颜色：金银铜 / 普通紫
        rankBadgeGradient_Pane?.removeFromSuperlayer()
        rankBadgeGradient_Pane = nil
        let gl = CAGradientLayer()
        gl.cornerRadius = 14
        switch rank_pane {
        case 1:
            gl.colors = [UIColor(hexstring_Pane: "#F6D365").cgColor, UIColor(hexstring_Pane: "#FDA085").cgColor]
        case 2:
            gl.colors = [UIColor(hexstring_Pane: "#B0BEC5").cgColor, UIColor(hexstring_Pane: "#78909C").cgColor]
        case 3:
            gl.colors = [UIColor(hexstring_Pane: "#FFCCBC").cgColor, UIColor(hexstring_Pane: "#FF7043").cgColor]
        default:
            gl.colors = [
                ColorConfig_Pane.primaryGradientStart_Pane.withAlphaComponent(0.85).cgColor,
                ColorConfig_Pane.primaryGradientEnd_Pane.withAlphaComponent(0.85).cgColor
            ]
        }
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint   = CGPoint(x: 1, y: 1)
        rankBadge_Pane.layer.insertSublayer(gl, at: 0)
        rankBadgeGradient_Pane = gl
    }
}
