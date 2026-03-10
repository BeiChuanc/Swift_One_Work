import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页
// 核心作用：展示预制用户（PrewUserModel_Moode）的个人主页，
//           包含头像、昵称、简介、举报按钮、关注/粉丝统计、关注+聊天按钮、帖子列表。
// 设计思路：渐变 Header（装饰圆 + 波浪底） + 浮动统计卡 + 操作行 + 帖子网格；
//           右上角统一提供举报入口；关注与聊天按钮并排于同一行；
//           移除 Header 内多余 Emoji 装饰，改以半透明圆圈丰富层次感。
// 关键属性：userModel_Moode（入口用户模型）

/// 用户中心页控制器
class UserInfo_Moode: UIViewController {

    // MARK: - 公开属性

    /// 传入的预制用户模型
    var userModel_Moode: PrewUserModel_Moode?

    // MARK: - 私有属性

    /// 当前展示的帖子列表
    private var posts_Moode: [TitleModel_Moode] = []

    /// 举报按钮（由 ReportDeleteHelper_Moode 生成，引用以便约束）
    private var reportBtn_Moode: UIButton?

    // MARK: - UI 组件

    private let scrollView_Moode: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Moode = UIView()

    // MARK: Header 渐变背景

    private let headerBg_Moode    = UIView()
    private let headerGrad_Moode  = CAGradientLayer()

    /// 装饰圆 1（右上大圆）
    private let decCircle1_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 90
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 2（左下中圆）
    private let decCircle2_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 55
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 3（右中小圆，增加层次感）
    private let decCircle3_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 35
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰圆 4（左上微圆，点缀用）
    private let decCircle4_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        v.layer.cornerRadius = 22
        v.isUserInteractionEnabled = false
        return v
    }()

    /// Header 底部波浪遮罩（增加层次过渡）
    private let headerWaveView_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.isUserInteractionEnabled = false
        return v
    }()
    private let headerWaveLayer_Moode = CAShapeLayer()

    // MARK: 导航按钮区

    private let backBtn_Moode = BackButton_Moode()

    // MARK: 头像区（带渐变环）

    private let avatarRing_Moode: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 46
        v.clipsToBounds = true
        return v
    }()
    private let avatarRingGrad_Moode = CAGradientLayer()
    private let avatarView_Moode = UserAvatarView_Moode(frame: .zero)

    private let userNameLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .heavy)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    private let userBioLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor.white.withAlphaComponent(0.82)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // MARK: 浮动统计卡

    private let statsCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 22
        v.layer.shadowColor  = UIColor(hexstring_Moode: "#9BB5F0").cgColor
        v.layer.shadowOpacity = 0.18
        v.layer.shadowRadius  = 16
        v.layer.shadowOffset  = CGSize(width: 0, height: 6)
        return v
    }()

    private let postsCountLbl_Moode  = UserInfo_Moode.makeStatCountLbl_Moode()
    private let postsDescLbl_Moode   = UserInfo_Moode.makeStatDescLbl_Moode("Posts")
    private let fansCountLbl_Moode   = UserInfo_Moode.makeStatCountLbl_Moode()
    private let fansDescLbl_Moode    = UserInfo_Moode.makeStatDescLbl_Moode("Fans")
    private let followCountLbl_Moode = UserInfo_Moode.makeStatCountLbl_Moode()
    private let followDescLbl_Moode  = UserInfo_Moode.makeStatDescLbl_Moode("Following")

    // MARK: 操作行（关注 + 聊天）

    private let actionRow_Moode = UIView()

    private let followBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        return btn
    }()
    private let followBtnGrad_Moode = CAGradientLayer()

    /// 聊天按钮（与关注按钮并排）
    private let chatBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(hexstring_Moode: "#F0EEFF")
        btn.layer.cornerRadius = 22
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor(hexstring_Moode: "#C4B5FD").cgColor
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "message.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Chat", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.tintColor = UIColor(hexstring_Moode: "#6C5CE7")
        btn.setTitleColor(UIColor(hexstring_Moode: "#6C5CE7"), for: .normal)
        return btn
    }()

    // MARK: 帖子内容区

    private let contentCard_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let sectionRow_Moode = UIView()

    private let sectionDot_Moode: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()
    private var sectionDotGrad_Moode: CAGradientLayer?

    private let sectionLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "Posts"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Moode.textPrimary_Moode
        return l
    }()

    private let sectionCountBadge_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EEE9FF")
        v.layer.cornerRadius = 11
        return v
    }()
    private let sectionCountLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(hexstring_Moode: "#6C5CE7")
        l.textAlignment = .center
        return l
    }()

    private lazy var postsCV_Moode: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.width - 48 - 8) / 2
        layout.itemSize        = CGSize(width: w, height: w * 1.15)
        layout.minimumLineSpacing      = 10
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor    = .clear
        cv.isScrollEnabled    = false
        cv.register(UserInfoPostCell_Moode.self, forCellWithReuseIdentifier: UserInfoPostCell_Moode.reuseId_Moode)
        return cv
    }()

    private var cvHeightConstraint_Moode: Constraint?

    private let emptyView_Moode: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    private let emptyIconView_Moode: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 38, weight: .light)
        iv.image = UIImage(systemName: "square.stack.3d.up.slash", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Moode: "#C4B5FD")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let emptyLbl_Moode: UILabel = {
        let l = UILabel()
        l.text = "No posts yet"
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Moode.textPlaceholder_Moode
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Moode.backgroundPrimary_Moode
        setupScrollLayout_Moode()
        setupHeaderUI_Moode()
        setupStatsCard_Moode()
        setupActionRow_Moode()
        setupContentCard_Moode()
        bindData_Moode()
        observeNotifications_Moode()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGrad_Moode.frame      = headerBg_Moode.bounds
        followBtnGrad_Moode.frame   = followBtn_Moode.bounds
        avatarRingGrad_Moode.frame  = avatarRing_Moode.bounds
        sectionDotGrad_Moode?.frame = sectionDot_Moode.bounds
        updateHeaderWave_Moode()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 工厂

    private static func makeStatCountLbl_Moode() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .heavy)
        l.textColor = ColorConfig_Moode.textPrimary_Moode
        l.textAlignment = .center
        return l
    }

    private static func makeStatDescLbl_Moode(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 11)
        l.textColor = ColorConfig_Moode.textSecondary_Moode
        l.textAlignment = .center
        return l
    }

    // MARK: - 布局搭建

    private func setupScrollLayout_Moode() {
        view.addSubview(scrollView_Moode)
        scrollView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Moode.addSubview(contentView_Moode)
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 搭建渐变 Header（装饰圆 + 波浪 + 导航按钮 + 头像 + 用户名 + Bio）
    private func setupHeaderUI_Moode() {
        // 渐变背景
        headerGrad_Moode.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Moode.endPoint   = CGPoint(x: 1, y: 1)
        headerBg_Moode.layer.insertSublayer(headerGrad_Moode, at: 0)

        contentView_Moode.addSubview(headerBg_Moode)
        headerBg_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(310)
        }

        // 装饰圆
        headerBg_Moode.addSubview(decCircle1_Moode)
        decCircle1_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(180)
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(50)
        }
        headerBg_Moode.addSubview(decCircle2_Moode)
        decCircle2_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.bottom.equalToSuperview().offset(30)
            make.left.equalToSuperview().offset(-25)
        }
        headerBg_Moode.addSubview(decCircle3_Moode)
        decCircle3_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.top.equalToSuperview().offset(80)
            make.right.equalToSuperview().offset(-20)
        }
        headerBg_Moode.addSubview(decCircle4_Moode)
        decCircle4_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.top.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(60)
        }

        // 波浪遮罩层（叠加在 headerBg 上方）
        headerBg_Moode.addSubview(headerWaveView_Moode)
        headerWaveView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerWaveLayer_Moode.fillColor = UIColor.white.withAlphaComponent(0.06).cgColor
        headerWaveView_Moode.layer.addSublayer(headerWaveLayer_Moode)

        // 返回按钮（左上）
        headerBg_Moode.addSubview(backBtn_Moode)
        backBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        backBtn_Moode.onTapped_Moode = { [weak self] in self?.handleBack_Moode() }

        // 举报按钮（右上）— 在 bindData_Moode 中创建并挂载
        // 此处占位约束在 bindData 阶段添加

        // 头像渐变环
        headerBg_Moode.addSubview(avatarRing_Moode)
        avatarRingGrad_Moode.startPoint  = CGPoint(x: 0, y: 0)
        avatarRingGrad_Moode.endPoint    = CGPoint(x: 1, y: 1)
        avatarRingGrad_Moode.cornerRadius = 46
        avatarRing_Moode.layer.insertSublayer(avatarRingGrad_Moode, at: 0)
        avatarRing_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }
        avatarRing_Moode.addSubview(avatarView_Moode)
        avatarView_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(82)
        }

        // 用户名
        headerBg_Moode.addSubview(userNameLbl_Moode)
        userNameLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Moode.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(24)
        }

        // Bio
        headerBg_Moode.addSubview(userBioLbl_Moode)
        userBioLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(userNameLbl_Moode.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
        }
    }

    private func setupStatsCard_Moode() {
        contentView_Moode.addSubview(statsCard_Moode)
        statsCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(280)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(84)
        }

        // 单列工厂：SF Symbol 图标 + 数字 + 描述
        func makeCol_Moode(symbolName: String, count: UILabel, desc: UILabel) -> UIStackView {
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
            let iv = UIImageView(image: UIImage(systemName: symbolName, withConfiguration: cfg))
            iv.tintColor = UIColor(hexstring_Moode: "#6C5CE7")
            iv.contentMode = .scaleAspectFit
            iv.snp.makeConstraints { make in make.width.height.equalTo(20) }
            let stack = UIStackView(arrangedSubviews: [iv, count, desc])
            stack.axis      = .vertical
            stack.spacing   = 2
            stack.alignment = .center
            return stack
        }

        let col1 = makeCol_Moode(symbolName: "square.and.pencil",   count: postsCountLbl_Moode,  desc: postsDescLbl_Moode)
        let col2 = makeCol_Moode(symbolName: "person.2.fill",        count: fansCountLbl_Moode,   desc: fansDescLbl_Moode)
        let col3 = makeCol_Moode(symbolName: "globe",                count: followCountLbl_Moode, desc: followDescLbl_Moode)

        let div1 = makeStatDivider_Moode()
        let div2 = makeStatDivider_Moode()

        statsCard_Moode.addSubview(col1)
        statsCard_Moode.addSubview(div1)
        statsCard_Moode.addSubview(col2)
        statsCard_Moode.addSubview(div2)
        statsCard_Moode.addSubview(col3)

        col1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.32)
        }
        div1.snp.makeConstraints { make in
            make.left.equalTo(col1.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(36)
        }
        col2.snp.makeConstraints { make in
            make.left.equalTo(div1.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.34)
        }
        div2.snp.makeConstraints { make in
            make.left.equalTo(col2.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(36)
        }
        col3.snp.makeConstraints { make in
            make.left.equalTo(div2.snp.right)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    private func makeStatDivider_Moode() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Moode: "#EDF2F7")
        return v
    }

    /// 搭建操作行：Follow 按钮（左） + Chat 按钮（右）
    private func setupActionRow_Moode() {
        contentView_Moode.addSubview(actionRow_Moode)
        actionRow_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(380)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        // Follow 按钮（左侧，自适应宽，渐变背景）
        followBtnGrad_Moode.startPoint   = CGPoint(x: 0, y: 0)
        followBtnGrad_Moode.endPoint     = CGPoint(x: 1, y: 0)
        followBtnGrad_Moode.cornerRadius = 22
        followBtn_Moode.layer.insertSublayer(followBtnGrad_Moode, at: 0)
        followBtn_Moode.addTarget(self, action: #selector(handleFollow_Moode), for: .touchUpInside)

        // Chat 按钮（右侧固定宽）
        chatBtn_Moode.addTarget(self, action: #selector(handleChat_Moode), for: .touchUpInside)

        actionRow_Moode.addSubview(followBtn_Moode)
        actionRow_Moode.addSubview(chatBtn_Moode)

        chatBtn_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(44)
        }
        followBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(chatBtn_Moode.snp.left).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
    }

    private func setupContentCard_Moode() {
        contentView_Moode.addSubview(contentCard_Moode)
        contentCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(442)
            make.left.right.bottom.equalToSuperview()
        }

        // 标题行：彩色小圆点 + 标题 + 数量徽标
        contentCard_Moode.addSubview(sectionRow_Moode)
        sectionRow_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }

        sectionRow_Moode.addSubview(sectionDot_Moode)
        sectionDot_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(22)
        }

        sectionRow_Moode.addSubview(sectionLbl_Moode)
        sectionLbl_Moode.snp.makeConstraints { make in
            make.left.equalTo(sectionDot_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        sectionRow_Moode.addSubview(sectionCountBadge_Moode)
        sectionCountBadge_Moode.snp.makeConstraints { make in
            make.left.equalTo(sectionLbl_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }
        sectionCountBadge_Moode.addSubview(sectionCountLbl_Moode)
        sectionCountLbl_Moode.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }

        contentCard_Moode.addSubview(postsCV_Moode)
        postsCV_Moode.delegate   = self
        postsCV_Moode.dataSource = self
        postsCV_Moode.snp.makeConstraints { make in
            make.top.equalTo(sectionRow_Moode.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            cvHeightConstraint_Moode = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview().offset(-20)
        }

        contentCard_Moode.addSubview(emptyView_Moode)
        emptyView_Moode.snp.makeConstraints { make in
            make.top.equalTo(sectionRow_Moode.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(130)
        }
        emptyView_Moode.addSubview(emptyIconView_Moode)
        emptyIconView_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        emptyView_Moode.addSubview(emptyLbl_Moode)
        emptyLbl_Moode.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Moode.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }

    // MARK: - Header 波浪更新

    /// 在 bounds 确定后更新波浪路径
    private func updateHeaderWave_Moode() {
        let w = headerBg_Moode.bounds.width
        let h = headerBg_Moode.bounds.height
        guard w > 0, h > 0 else { return }
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: h - 30))
        path.addCurve(
            to: CGPoint(x: w, y: h - 10),
            controlPoint1: CGPoint(x: w * 0.35, y: h + 18),
            controlPoint2: CGPoint(x: w * 0.65, y: h - 40)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.close()
        headerWaveLayer_Moode.path = path.cgPath
    }

    // MARK: - 数据绑定

    private func bindData_Moode() {
        guard let user = userModel_Moode else { return }

        // 情绪渐变色（用 userId 取余映射到情绪）
        let idx  = (user.userId_Moode ?? 0) % MoodType_Moode.allCases.count
        let mood = MoodType_Moode.allCases[idx]
        headerGrad_Moode.colors      = [mood.gradientStart_Moode.cgColor, mood.gradientEnd_Moode.cgColor]
        avatarRingGrad_Moode.colors  = [
            UIColor.white.withAlphaComponent(0.9).cgColor,
            mood.gradientStart_Moode.withAlphaComponent(0.6).cgColor
        ]
        // 标题行小圆点渐变
        if sectionDotGrad_Moode == nil {
            let grad = UIColor.createPrimaryGradientLayer_Moode(frame_Moode: CGRect(x: 0, y: 0, width: 4, height: 22))
            grad.startPoint  = CGPoint(x: 0, y: 0)
            grad.endPoint    = CGPoint(x: 0, y: 1)
            grad.cornerRadius = 2
            sectionDot_Moode.layer.insertSublayer(grad, at: 0)
            sectionDotGrad_Moode = grad
        }

        // 创建并挂载举报按钮（避免重复添加）
        if reportBtn_Moode == nil {
            let btn = ReportDeleteHelper_Moode.createUserReportButton_Moode(
                size_Moode: 36,
                backgroundColor_Moode: UIColor.white.withAlphaComponent(0.20),
                tintColor_Moode: .white
            )
            headerBg_Moode.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
                make.right.equalToSuperview().offset(-16)
                make.width.height.equalTo(36)
            }
            btn.addAction(UIAction { [weak self] _ in
                guard let self = self, let user = self.userModel_Moode else { return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                ReportDeleteHelper_Moode.block_Moode(user_Moode: user, from: self) {
                    Navigation_Moode.pop_Moode()
                }
            }, for: .touchUpInside)
            reportBtn_Moode = btn
        }

        // 头像
        avatarView_Moode.configure_Moode(userId_Moode: user.userId_Moode ?? 0)

        // 用户名 / Bio
        userNameLbl_Moode.text = user.userName_Moode ?? "User"
        userBioLbl_Moode.text  = user.userIntroduce_Moode?.isEmpty == false
            ? user.userIntroduce_Moode
            : "No bio yet"

        // 统计数据
        posts_Moode = TitleViewModel_Moode.shared_Moode.getUserPosts_Moode(user_moode: user)
        postsCountLbl_Moode.text  = "\(posts_Moode.count)"
        fansCountLbl_Moode.text   = "\(user.userFans_Moode ?? 0)"
        followCountLbl_Moode.text = "\(user.userFollow_Moode ?? 0)"
        sectionCountLbl_Moode.text = "\(posts_Moode.count)"

        // 关注按钮状态
        updateFollowBtn_Moode()

        // 帖子
        let isEmpty = posts_Moode.isEmpty
        postsCV_Moode.isHidden   = isEmpty
        emptyView_Moode.isHidden = !isEmpty

        if !isEmpty {
            postsCV_Moode.reloadData()
            let rows   = ceil(Double(posts_Moode.count) / 2.0)
            let itemH  = (UIScreen.main.bounds.width - 48 - 8) / 2 * 1.15
            let cvH    = rows * Double(itemH) + (rows - 1) * 10
            cvHeightConstraint_Moode?.update(offset: max(cvH, 200))
        } else {
            cvHeightConstraint_Moode?.update(offset: 130)
        }
    }

    /// 更新关注按钮渐变与文字
    private func updateFollowBtn_Moode() {
        guard let user = userModel_Moode else { return }
        let isFollowing = UserViewModel_Moode.shared_Moode.isFollowing_Moode(user_moode: user)

        if isFollowing {
            followBtnGrad_Moode.colors = [
                UIColor(hexstring_Moode: "#CBD5E0").cgColor,
                UIColor(hexstring_Moode: "#A0AEC0").cgColor
            ]
            followBtn_Moode.setTitle("Followed", for: .normal)
            followBtn_Moode.setTitleColor(.white, for: .normal)
        } else {
            followBtnGrad_Moode.colors = [
                ColorConfig_Moode.primaryGradientStart_Moode.cgColor,
                ColorConfig_Moode.primaryGradientEnd_Moode.cgColor
            ]
            followBtn_Moode.setTitle("Follow", for: .normal)
            followBtn_Moode.setTitleColor(.white, for: .normal)
        }
    }

    // MARK: - 通知监听

    private func observeNotifications_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Moode),
            name: TitleViewModel_Moode.titleStateDidChangeNotification_Moode, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Moode),
            name: UserViewModel_Moode.userStateDidChangeNotification_Moode, object: nil
        )
    }

    @objc private func onDataChanged_Moode() {
        bindData_Moode()
    }

    // MARK: - 事件

    @objc private func handleBack_Moode() {
        Navigation_Moode.pop_Moode(animated: true)
    }

    /// 关注 / 取消关注
    @objc private func handleFollow_Moode() {
        guard let user = userModel_Moode else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        followBtn_Moode.animatePressDown_Moode { self.followBtn_Moode.animatePressUp_Moode() }
        UserViewModel_Moode.shared_Moode.followUser_Moode(user_moode: user)
    }

    /// 跳转私信聊天页（Replace 方式，避免导航栈累积）
    @objc private func handleChat_Moode() {
        guard let user = userModel_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        chatBtn_Moode.animatePressDown_Moode { self.chatBtn_Moode.animatePressUp_Moode() }
        Navigation_Moode.toMessageUser_Moode(with: user, style_moode: .replace_moode)
    }
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate

extension UserInfo_Moode: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Moode.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(
            withReuseIdentifier: UserInfoPostCell_Moode.reuseId_Moode, for: indexPath
        ) as? UserInfoPostCell_Moode else { return UICollectionViewCell() }

        let post = posts_Moode[indexPath.item]
        cell.configure_Moode(post: post)

        // 举报回调：自己的帖子走删除流程，他人帖子走举报流程
        cell.onReportTapped_Moode = { [weak self] targetPost in
            guard let self = self else { return }
            let isMyPost = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
                userId_moode: targetPost.titleUserId_Moode
            )
            if isMyPost {
                ReportDeleteHelper_Moode.delete_Moode(
                    post_Moode: targetPost, from: self
                ) { [weak self] in self?.bindData_Moode() }
            } else {
                ReportDeleteHelper_Moode.report_Moode(
                    post_Moode: targetPost, from: self
                ) { [weak self] in self?.bindData_Moode() }
            }
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts_Moode[indexPath.item]
        Navigation_Moode.toTitleDetail_Moode(titleModel_moode: post)
    }
}

// MARK: - UserInfoPostCell_Moode（帖子网格单元格）

/// 用户中心帖子网格单元格
/// 功能：以封面图 + 底部渐变遮罩 + 标题 + 情绪徽标（仅情绪帖子显示）+ 右上角举报按钮展示单条帖子
/// 关键方法：configure_Moode 绑定数据；onReportTapped_Moode 举报回调由外部 VC 注入
class UserInfoPostCell_Moode: UICollectionViewCell {

    static let reuseId_Moode = "UserInfoPostCell_Moode"

    // MARK: - 回调

    /// 举报按钮点击回调（携带帖子模型，由外部 VC 处理实际举报逻辑）
    var onReportTapped_Moode: ((TitleModel_Moode) -> Void)?

    // MARK: - 私有属性

    private var post_Moode: TitleModel_Moode?

    // MARK: - UI 组件

    private let coverView_Moode = MediaDisplayView_Moode()
    private let gradOverlay_Moode = CAGradientLayer()

    private let titleLbl_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    /// 情绪徽标（仅情绪帖子可见）
    private let moodBadge_Moode: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = UIColor.white.withAlphaComponent(0.92)
        l.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        l.layer.cornerRadius = 8
        l.clipsToBounds = true
        l.textAlignment = .center
        return l
    }()

    /// 右上角举报按钮（半透明背景 + ellipsis 图标）
    private let reportBtn_Moode: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        btn.layer.cornerRadius = 13
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        contentView.addSubview(coverView_Moode)
        coverView_Moode.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 底部渐变遮罩（三段式，标题更易读）
        gradOverlay_Moode.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.25).cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor
        ]
        gradOverlay_Moode.locations = [0.0, 0.55, 1.0]
        gradOverlay_Moode.startPoint = CGPoint(x: 0, y: 0)
        gradOverlay_Moode.endPoint   = CGPoint(x: 0, y: 1)
        contentView.layer.addSublayer(gradOverlay_Moode)

        contentView.addSubview(titleLbl_Moode)
        titleLbl_Moode.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 左上角情绪徽标
        contentView.addSubview(moodBadge_Moode)
        moodBadge_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.height.equalTo(20)
        }

        // 右上角举报按钮（26×26pt）
        contentView.addSubview(reportBtn_Moode)
        reportBtn_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }
        reportBtn_Moode.addTarget(self, action: #selector(handleReportTapped_Moode), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradOverlay_Moode.frame = contentView.bounds
    }

    // MARK: - 数据绑定

    /// 绑定帖子数据
    /// - Parameter post: 要展示的帖子模型
    func configure_Moode(post: TitleModel_Moode) {
        post_Moode = post
        titleLbl_Moode.text = post.title_Moode

        // 仅情绪帖子显示情绪徽标
        let isMoodPost = post.postType_Moode == .mood_moode
        moodBadge_Moode.isHidden = !isMoodPost
        if isMoodPost {
            let mood = post.moodType_Moode
            moodBadge_Moode.text = " \(mood.emoji_Moode) \(mood.displayName_Moode) "
        }

        let mediaPath = post.titleMeidas_Moode.first ?? ""
        coverView_Moode.configure_Moode(mediaPath_Moode: mediaPath.isEmpty ? nil : mediaPath)

        // 自己帖子→删除(trash/红色)，他人帖子→举报(ellipsis/白色半透明)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let isMyPost = UserViewModel_Moode.shared_Moode.isCurrentUser_Moode(
            userId_moode: post.titleUserId_Moode
        )
        reportBtn_Moode.setImage(
            UIImage(systemName: isMyPost ? "trash" : "ellipsis", withConfiguration: cfg),
            for: .normal
        )
        reportBtn_Moode.tintColor = isMyPost ? UIColor(hexstring_Moode: "#FF6B6B") : .white
        reportBtn_Moode.backgroundColor = isMyPost
            ? UIColor(hexstring_Moode: "#FF6B6B").withAlphaComponent(0.28)
            : UIColor.black.withAlphaComponent(0.42)
    }

    // MARK: - 复用清理

    override func prepareForReuse() {
        super.prepareForReuse()
        post_Moode = nil
        onReportTapped_Moode = nil
        moodBadge_Moode.isHidden = true
    }

    // MARK: - 事件

    /// 举报按钮点击：触发回调，由外部 VC 调用 ReportDeleteHelper 处理
    @objc private func handleReportTapped_Moode() {
        guard let post = post_Moode else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onReportTapped_Moode?(post)
    }
}
