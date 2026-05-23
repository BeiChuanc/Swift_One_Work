import UIKit
import SnapKit

// MARK: 热门帖子卡片视图

/// 热门帖子卡片视图（原灵感卡，已改造为展示热门帖）
/// 功能：展示单个热门帖子，包含封面图、排名徽章、点赞数、标题、作者；点击进入帖子详情
/// 关键属性：tapAction_Hush（点击回调）
class InspirationCardView_Hush: UIView {

    // MARK: - 回调

    /// 卡片点击回调
    var tapAction_Hush: (() -> Void)?

    // MARK: - UI 组件

    /// 封面图片（帖子媒体资源）
    private let coverImageView_Hush: UIImageView = {
        let iv_hush = UIImageView()
        iv_hush.contentMode = .scaleAspectFill
        iv_hush.clipsToBounds = true
        iv_hush.backgroundColor = UIColor(hexstring_Hush: "#2C2F3A")
        return iv_hush
    }()

    /// 底部渐变遮罩（提升文字可读性）
    private let gradientOverlay_Hush = UIView()
    private var overlayGradient_Hush: CAGradientLayer?

    /// 顶部左侧：排名徽章（#1 / #2 / #3）
    private let rankBadge_Hush: UIView = {
        let v_hush = UIView()
        v_hush.layer.cornerRadius = 12
        v_hush.clipsToBounds = true
        return v_hush
    }()
    private var rankGradient_Hush: CAGradientLayer?

    private let rankLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .black)
        lb_hush.textAlignment = .center
        return lb_hush
    }()

    /// 顶部右侧：点赞数徽章（🔥 count）
    private let likesBadge_Hush: UIView = {
        let v_hush = UIView()
        v_hush.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v_hush.layer.cornerRadius = 11
        v_hush.clipsToBounds = true
        return v_hush
    }()

    private let likesLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return lb_hush
    }()

    /// 底部：作者名
    private let authorLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.75)
        lb_hush.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        return lb_hush
    }()

    /// 底部：帖子标题
    private let titleLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.textColor = .white
        lb_hush.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lb_hush.numberOfLines = 2
        return lb_hush
    }()

    /// 底部 CTA 提示
    private let ctaLabel_Hush: UILabel = {
        let lb_hush = UILabel()
        lb_hush.text = "View Post  →"
        lb_hush.textColor = UIColor.white.withAlphaComponent(0.7)
        lb_hush.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        return lb_hush
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Hush()
        setupGesture_Hush()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Hush()
        setupGesture_Hush()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradient_Hush?.frame = gradientOverlay_Hush.bounds
        rankGradient_Hush?.frame = rankBadge_Hush.bounds
    }

    // MARK: - 私有方法

    /// 构建视图层次与约束
    private func setupUI_Hush() {
        layer.cornerRadius = 18
        clipsToBounds = true

        // 封面图（最底层）
        addSubview(coverImageView_Hush)
        coverImageView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }

        // 渐变遮罩
        addSubview(gradientOverlay_Hush)
        let overlay_hush = CAGradientLayer()
        overlay_hush.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.25).cgColor,
            UIColor.black.withAlphaComponent(0.82).cgColor,
        ]
        overlay_hush.locations = [0.0, 0.45, 1.0]
        overlay_hush.startPoint = CGPoint(x: 0.5, y: 0)
        overlay_hush.endPoint = CGPoint(x: 0.5, y: 1)
        gradientOverlay_Hush.layer.insertSublayer(overlay_hush, at: 0)
        overlayGradient_Hush = overlay_hush
        gradientOverlay_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }

        // 排名徽章
        addSubview(rankBadge_Hush)
        rankBadge_Hush.addSubview(rankLabel_Hush)
        let rankGrad_hush = CAGradientLayer()
        rankGrad_hush.startPoint = CGPoint(x: 0, y: 0)
        rankGrad_hush.endPoint = CGPoint(x: 1, y: 1)
        rankBadge_Hush.layer.insertSublayer(rankGrad_hush, at: 0)
        rankGradient_Hush = rankGrad_hush

        rankBadge_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(14)
            make_hush.left.equalToSuperview().offset(14)
            make_hush.height.equalTo(24)
            make_hush.width.greaterThanOrEqualTo(44)
        }
        rankLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10))
        }

        // 点赞数徽章
        addSubview(likesBadge_Hush)
        likesBadge_Hush.addSubview(likesLabel_Hush)
        likesBadge_Hush.snp.makeConstraints { make_hush in
            make_hush.top.equalToSuperview().offset(14)
            make_hush.right.equalToSuperview().offset(-14)
            make_hush.height.equalTo(24)
        }
        likesLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        // 底部信息
        addSubview(ctaLabel_Hush)
        addSubview(authorLabel_Hush)
        addSubview(titleLabel_Hush)

        ctaLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(14)
            make_hush.bottom.equalToSuperview().offset(-14)
        }
        authorLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.equalToSuperview().offset(14)
            make_hush.bottom.equalTo(ctaLabel_Hush.snp.top).offset(-4)
        }
        titleLabel_Hush.snp.makeConstraints { make_hush in
            make_hush.left.right.equalToSuperview().inset(14)
            make_hush.bottom.equalTo(authorLabel_Hush.snp.top).offset(-6)
        }
    }

    /// 绑定点击手势
    private func setupGesture_Hush() {
        let tap_hush = UITapGestureRecognizer(target: self, action: #selector(onTap_Hush))
        addGestureRecognizer(tap_hush)
        isUserInteractionEnabled = true
    }

    @objc private func onTap_Hush() {
        springScaleAnimate_Hush()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.tapAction_Hush?()
        }
    }

    // MARK: - 数据绑定

    /// 绑定热门帖数据
    /// - Parameters:
    ///   - model_hush: 帖子数据模型
    ///   - rank_hush: 排名（1 开始），决定徽章颜色
    func configureAsHotPost_Hush(model_hush: TitleModel_Hush, rank_hush: Int) {
        // 封面图（使用 Bundle 内资源名）
        if let mediaName_hush = model_hush.titleMeidas_Hush.first {
            coverImageView_Hush.image = UIImage(named: mediaName_hush)
        } else {
            coverImageView_Hush.image = nil
        }

        // 排名徽章颜色
        let rankColors_hush: [(String, String)] = [
            ("#FF6B35", "#C0392B"),   // #1 橙红
            ("#3A3D8F", "#6C5CE7"),   // #2 靛蓝紫
            ("#2C3E50", "#4A6741"),   // #3 深墨绿
        ]
        let (start_hush, end_hush) = rankColors_hush[(rank_hush - 1) % rankColors_hush.count]
        rankGradient_Hush?.colors = [
            UIColor(hexstring_Hush: start_hush).cgColor,
            UIColor(hexstring_Hush: end_hush).cgColor,
        ]
        rankLabel_Hush.text = "# \(rank_hush)  HOT"

        // 点赞数
        likesLabel_Hush.text = "🔥 \(model_hush.likes_Hush)"

        // 帖子标题 / 作者
        titleLabel_Hush.text = model_hush.title_Hush
        authorLabel_Hush.text = "by \(model_hush.titleUserName_Hush)"
    }
}

// MARK: - 热门帖卡片 CollectionViewCell

/// 热门帖子卡片 CollectionViewCell
class InspirationCell_Hush: UICollectionViewCell {

    static let reuseId_Hush = "InspirationCell_Hush"

    let cardView_Hush = InspirationCardView_Hush()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Hush)
        cardView_Hush.snp.makeConstraints { make_hush in
            make_hush.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
