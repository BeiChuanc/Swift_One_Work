import Foundation
import UIKit
import SnapKit

// MARK: 中古故事馆列表页

/// 中古故事馆列表视图控制器
/// 功能：展示官方每日 3 个精选讨论话题，点击进入话题详情参与讨论
/// 设计：玫瑰渐变头部、话题卡片列表、官方角标
class VintageStoryList_Bague: UIViewController {

    // MARK: - 头部

    private let headerView_Bague = UIView()
    private var headerGrad_Bague: CAGradientLayer?

    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    private let headerTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Vintage Story Hall"
        label.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label.textColor = .white
        return label
    }()

    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Daily curated topics by Bague Official"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        return label
    }()

    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.18)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 话题列表

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Bague = UIView()
    private let topicsStack_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()

    // MARK: - 数据

    private var topics_Bague: [VintageTopicItem_Bague] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadTopics_Bague()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(headerView_Bague)
        headerView_Bague.addSubview(backBtn_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)
        contentView_Bague.addSubview(topicsStack_Bague)
    }

    private func setupConstraints_Bague() {
        headerView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(180)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        headerTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(backBtn_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(24)
        }
        headerSubtitle_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel_Bague.snp.bottom).offset(5)
            make.leading.equalTo(headerTitleLabel_Bague)
        }
        headerDecorIcon_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
            make.width.height.equalTo(68)
        }
        scrollView_Bague.snp.makeConstraints { make in
            make.top.equalTo(headerView_Bague.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        topicsStack_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变

    private func updateGradient_Bague() {
        headerGrad_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = headerView_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 28
        grad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(grad_bague, at: 0)
        headerGrad_Bague = grad_bague
    }

    // MARK: - 数据加载

    private func loadTopics_Bague() {
        topics_Bague = LocalData_Bague.shared_Bague.vintageTopics_Bague
        topicsStack_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }
        topics_Bague.enumerated().forEach { idx, topic in
            let card_bague = VintageTopicCard_Bague(topic: topic, index: idx) { [weak self] in
                self?.openTopic_Bague(topic)
            }
            topicsStack_Bague.addArrangedSubview(card_bague)
            card_bague.alpha = 0
            card_bague.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.38, delay: Double(idx) * 0.08, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3) {
                card_bague.alpha = 1
                card_bague.transform = .identity
            }
        }
    }

    private func openTopic_Bague(_ topic: VintageTopicItem_Bague) {
        let detail_bague = VintageStoryDetail_Bague()
        detail_bague.topic_Bague = topic
        Navigation_Bague.push_Bague(to: detail_bague)
    }

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }
}

// MARK: - 话题卡片视图

/// 中古故事馆话题卡片
private class VintageTopicCard_Bague: UIView {

    private static let cardGrads_Bague: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Bague: "#F07DAD"), UIColor(hexstring_Bague: "#FFA07A")),
        (UIColor(hexstring_Bague: "#9B72F5"), UIColor(hexstring_Bague: "#7DC4F0")),
        (UIColor(hexstring_Bague: "#3DC9A6"), UIColor(hexstring_Bague: "#99E8D0")),
    ]

    private var gradLayer_Bague: CAGradientLayer?
    private let gradIdx_Bague: Int
    private var onTap_Bague: (() -> Void)?

    init(topic: VintageTopicItem_Bague, index: Int, onTap: @escaping () -> Void) {
        self.gradIdx_Bague = index % VintageTopicCard_Bague.cardGrads_Bague.count
        self.onTap_Bague = onTap
        super.init(frame: .zero)
        buildUI_Bague(topic: topic)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague(topic: VintageTopicItem_Bague) {
        layer.cornerRadius = 20
        layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12

        // 图标背景
        let iconBg_bague = UIView()
        iconBg_bague.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        iconBg_bague.layer.cornerRadius = 22
        addSubview(iconBg_bague)

        let iconIV_bague = UIImageView()
        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconIV_bague.image = UIImage(systemName: topic.iconName_Bague, withConfiguration: cfg_bague)
        iconIV_bague.tintColor = .white
        iconIV_bague.contentMode = .scaleAspectFit
        iconBg_bague.addSubview(iconIV_bague)

        // 官方徽章
        let badge_bague = UILabel()
        badge_bague.text = "  ✦ Official  "
        badge_bague.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        badge_bague.textColor = UIColor(hexstring_Bague: "#7B5800")
        badge_bague.backgroundColor = UIColor(hexstring_Bague: "#FFD700")
        badge_bague.layer.cornerRadius = 9
        badge_bague.clipsToBounds = true
        addSubview(badge_bague)

        let titleLbl_bague = UILabel()
        titleLbl_bague.text = topic.title_Bague
        titleLbl_bague.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl_bague.textColor = .white
        titleLbl_bague.numberOfLines = 2
        addSubview(titleLbl_bague)

        let descLbl_bague = UILabel()
        descLbl_bague.text = topic.description_Bague
        descLbl_bague.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLbl_bague.textColor = UIColor.white.withAlphaComponent(0.85)
        descLbl_bague.numberOfLines = 3
        addSubview(descLbl_bague)

        let commentCount_bague = UILabel()
        commentCount_bague.text = "💬 \(topic.comments_Bague.count) comments  →"
        commentCount_bague.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentCount_bague.textColor = UIColor.white.withAlphaComponent(0.88)
        addSubview(commentCount_bague)

        // 约束
        iconBg_bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(44)
        }
        iconIV_bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
        badge_bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(18)
        }
        titleLbl_bague.snp.makeConstraints { make in
            make.top.equalTo(iconBg_bague.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }
        descLbl_bague.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }
        commentCount_bague.snp.makeConstraints { make in
            make.top.equalTo(descLbl_bague.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-18)
        }

        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(tapped_Bague))
        addGestureRecognizer(tap_bague)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Bague?.removeFromSuperlayer()
        let colors_bague = VintageTopicCard_Bague.cardGrads_Bague[gradIdx_Bague]
        let grad_bague = CAGradientLayer()
        grad_bague.frame = bounds
        grad_bague.colors = [colors_bague.0.cgColor, colors_bague.1.cgColor]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 20
        layer.insertSublayer(grad_bague, at: 0)
        gradLayer_Bague = grad_bague
    }

    @objc private func tapped_Bague() {
        animatePressDown_Bague { self.animatePressUp_Bague { self.onTap_Bague?() } }
    }
}

// MARK: - 话题详情页

/// 中古故事馆话题详情视图控制器
/// 功能：展示话题信息、评论列表、发表评论、每条评论支持举报/删除
/// 设计：渐变头部、评论卡片、浅紫输入栏
class VintageStoryDetail_Bague: UIViewController {

    // MARK: - 属性

    /// 当前话题
    var topic_Bague: VintageTopicItem_Bague?

    // MARK: - 头部

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Bague = UIView()

    private let topicHeaderCard_Bague: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        return v
    }()

    private var topicHeaderGrad_Bague: CAGradientLayer?

    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn
    }()

    private let topicIconView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let topicTitleLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    private let topicDescLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor.white.withAlphaComponent(0.88)
        l.numberOfLines = 0
        return l
    }()

    // MARK: - 评论区

    private let commentHeaderRow_Bague: UIView = UIView()

    private let commentTitleLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Bague.textPrimary_Bague
        return l
    }()

    private let commentsStack_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    private let noCommentsLabel_Bague: UILabel = {
        let l = UILabel()
        l.text = "Be the first to share your story!"
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Bague.textPlaceholder_Bague
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    // MARK: - 底部输入栏

    private let inputContainer_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 12
        return v
    }()

    private let inputBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#FFF0F8")
        v.layer.cornerRadius = 22
        v.layer.borderWidth = 1.2
        v.layer.borderColor = UIColor(hexstring_Bague: "#FFD4E8").cgColor
        return v
    }()

    private let commentField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Share your vintage story..."
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        tf.returnKeyType = .send
        return tf
    }()

    private let sendBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(hexstring_Bague: "#F07DAD")
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupKeyboard_Bague()
        setupBindings_Bague()
        loadTopic_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTopicGradient_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)

        contentView_Bague.addSubview(topicHeaderCard_Bague)
        topicHeaderCard_Bague.addSubview(backBtn_Bague)
        topicHeaderCard_Bague.addSubview(topicIconView_Bague)
        topicHeaderCard_Bague.addSubview(topicTitleLabel_Bague)
        topicHeaderCard_Bague.addSubview(topicDescLabel_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        contentView_Bague.addSubview(commentHeaderRow_Bague)
        let iconIV_bague = UIImageView()
        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iconIV_bague.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg_bague)
        iconIV_bague.tintColor = UIColor(hexstring_Bague: "#F07DAD")
        iconIV_bague.contentMode = .scaleAspectFit
        commentHeaderRow_Bague.addSubview(iconIV_bague)
        commentHeaderRow_Bague.addSubview(commentTitleLabel_Bague)
        iconIV_bague.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        commentTitleLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_bague.snp.trailing).offset(8)
            make.centerY.trailing.top.bottom.equalToSuperview()
        }

        contentView_Bague.addSubview(commentsStack_Bague)
        contentView_Bague.addSubview(noCommentsLabel_Bague)

        view.addSubview(inputContainer_Bague)
        inputContainer_Bague.addSubview(inputBg_Bague)
        inputBg_Bague.addSubview(commentField_Bague)
        inputBg_Bague.addSubview(sendBtn_Bague)
        commentField_Bague.delegate = self
        sendBtn_Bague.addTarget(self, action: #selector(sendTapped_Bague), for: .touchUpInside)

        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        bgTap_bague.cancelsTouchesInView = false
        scrollView_Bague.addGestureRecognizer(bgTap_bague)
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainer_Bague.snp.top)
        }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        topicHeaderCard_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(16)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(36)
        }
        topicIconView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(62)
            make.leading.equalToSuperview().offset(18)
            make.width.height.equalTo(32)
        }
        topicTitleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(topicIconView_Bague.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }
        topicDescLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(topicTitleLabel_Bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-18)
        }
        commentHeaderRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(topicHeaderCard_Bague.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(22)
        }
        commentsStack_Bague.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderRow_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
        noCommentsLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderRow_Bague.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        inputContainer_Bague.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-4)
            make.height.equalTo(68)
        }
        inputBg_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        sendBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        commentField_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtn_Bague.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 渐变

    private func updateTopicGradient_Bague() {
        topicHeaderGrad_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = topicHeaderCard_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 20
        topicHeaderCard_Bague.layer.insertSublayer(grad_bague, at: 0)
        topicHeaderGrad_Bague = grad_bague
    }

    // MARK: - 数据加载

    private func loadTopic_Bague() {
        guard let topic_bague = topic_Bague else { return }

        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        topicIconView_Bague.image = UIImage(systemName: topic_bague.iconName_Bague, withConfiguration: cfg_bague)
        topicTitleLabel_Bague.text = topic_bague.title_Bague
        topicDescLabel_Bague.text = topic_bague.description_Bague
        // 标题计数由 refreshComments_Bague 统一更新（使用可见数量，避免与过滤后实际显示不符）
        refreshComments_Bague()
    }

    private func refreshComments_Bague() {
        guard let topic_bague = topic_Bague else { return }
        commentsStack_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let userList_bague = LocalData_Bague.shared_Bague.userList_Bague
        let currentId_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague().userId_Bague ?? 0

        // userList 为空：数据未初始化，显示全部；非空：过滤被拉黑用户的评论
        let visible_bague: [VintageComment_Bague]
        if userList_bague.isEmpty {
            visible_bague = topic_bague.comments_Bague
        } else {
            let validIds_bague = Set(userList_bague.compactMap { $0.userId_Bague })
            visible_bague = topic_bague.comments_Bague.filter {
                validIds_bague.contains($0.commentUserId_Bague)
                || $0.commentUserId_Bague == currentId_bague
            }
        }

        // 用可见数量更新标题，与实际显示保持一致
        commentTitleLabel_Bague.text = "Comments (\(visible_bague.count))"

        if visible_bague.isEmpty {
            noCommentsLabel_Bague.isHidden = false
        } else {
            noCommentsLabel_Bague.isHidden = true
            visible_bague.enumerated().forEach { idx, comment in
                let cell_bague = VintageCommentCell_Bague(
                    comment: comment,
                    topic: topic_bague,
                    vc: self
                )
                commentsStack_Bague.addArrangedSubview(cell_bague)
                cell_bague.alpha = 0
                UIView.animate(withDuration: 0.25, delay: Double(idx) * 0.03) {
                    cell_bague.alpha = 1
                }
            }
        }
    }

    // MARK: - 键盘

    private func setupKeyboard_Bague() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Bague(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Bague(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// 监听用户状态变化（举报/拉黑后刷新评论列表，过滤掉已屏蔽用户的评论）
    private func setupBindings_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userStateChanged_Bague),
            name: UserViewModel_Bague.userStateDidChangeNotification_Bague,
            object: nil
        )
    }

    @objc private func userStateChanged_Bague() {
        // 用户被拉黑后刷新评论列表，计数和内容都由 refreshComments_Bague 统一更新
        refreshComments_Bague()
    }

    @objc private func keyboardWillShow_Bague(_ notification: Notification) {
        guard let frame_bague = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let dur_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: dur_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-(frame_bague.height - self.view.safeAreaInsets.bottom + 4))
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide_Bague(_ notification: Notification) {
        guard let dur_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: dur_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-4)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard_Bague() { view.endEditing(true) }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    @objc private func sendTapped_Bague() {
        guard let text_bague = commentField_Bague.text, !text_bague.trimmingCharacters(in: .whitespaces).isEmpty else {
            commentField_Bague.animateShake_Bague()
            return
        }
        guard UserViewModel_Bague.shared_Bague.isLoggedIn_Bague else {
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
            return
        }
        guard let topic_bague = topic_Bague else { return }

        let currentUser_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague()
        let newComment_bague = VintageComment_Bague(
            commentId_Bague: (topic_bague.comments_Bague.max(by: { $0.commentId_Bague < $1.commentId_Bague })?.commentId_Bague ?? 0) + 1,
            commentUserId_Bague: currentUser_bague.userId_Bague ?? 0,
            commentUserName_Bague: currentUser_bague.userName_Bague ?? "User",
            commentContent_Bague: text_bague.trimmingCharacters(in: .whitespaces)
        )
        topic_bague.comments_Bague.append(newComment_bague)
        commentField_Bague.text = ""
        view.endEditing(true)
        sendBtn_Bague.animatePulse_Bague()
        refreshComments_Bague()
    }

    /// 从话题评论数组移除指定评论并刷新（供 VintageCommentCell 回调使用）
    func removeComment_Bague(commentId: Int) {
        guard let topic_bague = topic_Bague else { return }
        topic_bague.comments_Bague.removeAll { $0.commentId_Bague == commentId }
        refreshComments_Bague()
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITextFieldDelegate

extension VintageStoryDetail_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped_Bague()
        return true
    }
}

// MARK: - 话题评论单元格

/// 中古故事馆话题评论单元格
/// 功能：展示评论用户头像/姓名/内容，本人评论右上角显示删除按钮，他人评论显示举报按钮
class VintageCommentCell_Bague: UIView {

    private let comment_Bague: VintageComment_Bague
    private let topic_Bague: VintageTopicItem_Bague
    private weak var vc_Bague: VintageStoryDetail_Bague?

    private let cardView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#FFF5F8")
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Bague: "#FFD4E8").cgColor
        return v
    }()

    private let avatarView_Bague = UserAvatarView_Bague()

    private let nameLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        l.textColor = UIColor(hexstring_Bague: "#4A2030")
        return l
    }()

    private let commentLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Bague: "#5A3040")
        l.numberOfLines = 0
        return l
    }()

    init(comment: VintageComment_Bague, topic: VintageTopicItem_Bague, vc: VintageStoryDetail_Bague) {
        self.comment_Bague = comment
        self.topic_Bague = topic
        self.vc_Bague = vc
        super.init(frame: .zero)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague() {
        addSubview(cardView_Bague)
        cardView_Bague.addSubview(avatarView_Bague)
        cardView_Bague.addSubview(nameLabel_Bague)
        cardView_Bague.addSubview(commentLabel_Bague)

        avatarView_Bague.configure_Bague(userId_Bague: comment_Bague.commentUserId_Bague)
        nameLabel_Bague.text = comment_Bague.commentUserName_Bague
        commentLabel_Bague.text = comment_Bague.commentContent_Bague

        // 操作按钮：通过 ReportDeleteHelper 统一管理（本人→trash 删除，他人→ellipsis 举报）
        // vc_Bague 在点击时已在视图层级中，不存在找不到的问题
        if let vc_bague = vc_Bague {
            let actionBtn_bague = ReportDeleteHelper_Bague.createVintageCommentButton_Bague(
                commentUserId_Bague: comment_Bague.commentUserId_Bague,
                size_Bague: 13,
                color_Bague: UIColor(hexstring_Bague: "#F07DAD"),
                from: vc_bague,
                onDelete_Bague: { [weak vc_bague] in
                    guard let vc_bague = vc_bague else { return }
                    // 从话题评论数组中移除并刷新
                    vc_bague.removeComment_Bague(commentId: self.comment_Bague.commentId_Bague)
                }
            )
            cardView_Bague.addSubview(actionBtn_bague)
            actionBtn_bague.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.width.height.equalTo(24)
            }
        }

        cardView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        avatarView_Bague.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(34)
        }
        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Bague)
            make.leading.equalTo(avatarView_Bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-40)
        }
        commentLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Bague)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
