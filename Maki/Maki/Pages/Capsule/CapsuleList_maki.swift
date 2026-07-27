import Foundation
import UIKit
import SnapKit

// MARK: - 我的时光胶囊列表页面视图控制器

/// 我的时光胶囊列表页面视图控制器
/// 功能：以双列网格展示当前用户全部时光胶囊；未到开启时间的胶囊显示倒计时锁定态
/// 设计：渐变导航区 + 精美网格卡片；锁定态封面模糊叠加 + 倒计时徽章，解锁态可点击查看详情
/// 逻辑：点击已解锁胶囊 → 跳转详情页并标记为已查看；点击锁定胶囊 → 提示尚未到开启时间
class CapsuleList_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#9B59B6")
        static let accent  = UIColor(hexstring_Maki: "#6C3483")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let cellId  = "CapsuleGridCell_Maki"
    }

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 头部区域

    private let headerView_Maki = UIView()
    private let headerGrad_Maki = CAGradientLayer()

    // MARK: - UI 属性 / 网格

    private lazy var gridCV_Maki: UICollectionView = {
        let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        let layout_maki = UICollectionViewFlowLayout()
        layout_maki.itemSize = CGSize(width: itemW_maki, height: itemW_maki * 1.2)
        layout_maki.minimumInteritemSpacing = 10
        layout_maki.minimumLineSpacing = 12
        layout_maki.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 100, right: 20)
        let cv_maki = UICollectionView(frame: .zero, collectionViewLayout: layout_maki)
        cv_maki.backgroundColor = .clear
        cv_maki.isScrollEnabled = false
        cv_maki.dataSource = self
        cv_maki.delegate   = self
        cv_maki.register(CapsuleGridCell_Maki.self, forCellWithReuseIdentifier: K_Maki.cellId)
        return cv_maki
    }()
    private var gridCVHeight_Maki: Constraint?

    /// 空状态占位视图
    private let emptyView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.isHidden = true
        return v_maki
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        bindNotifications_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGrad_Maki.frame = headerView_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UI 构建

extension CapsuleList_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildHeader_Maki()
        buildGrid_Maki()
    }

    /// 构建渐变头部（返回按钮 + 标题 + 新建按钮）
    private func buildHeader_Maki() {
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerGrad_Maki.colors = [
            K_Maki.accent.cgColor,
            K_Maki.primary.cgColor
        ]
        headerGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Maki.layer.insertSublayer(headerGrad_Maki, at: 0)
        contentView_Maki.addSubview(headerView_Maki)
        headerView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusH_maki + 108)
        }

        // 装饰气泡
        let bubble_maki = UIView()
        bubble_maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        bubble_maki.layer.cornerRadius = 60
        headerView_Maki.addSubview(bubble_maki)
        bubble_maki.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.trailing.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(-26)
        }

        // 返回按钮
        let backBtn_maki = UIButton(type: .system)
        backBtn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn_maki.tintColor = .white
        backBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_maki.layer.cornerRadius = 17
        backBtn_maki.layer.borderWidth = 1.5
        backBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(backBtn_maki)
        backBtn_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(34)
        }

        // 新建按钮
        let addBtn_maki = UIButton(type: .system)
        addBtn_maki.setImage(UIImage(systemName: "plus"), for: .normal)
        addBtn_maki.tintColor = .white
        addBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        addBtn_maki.layer.cornerRadius = 17
        addBtn_maki.layer.borderWidth = 1.5
        addBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        addBtn_maki.addTarget(self, action: #selector(onAddCapsule_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(addBtn_maki)
        addBtn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(backBtn_maki)
            make.width.height.equalTo(34)
        }

        // 标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "⏳  My Time Capsules"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        titleLb_maki.textColor = .white
        headerView_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(backBtn_maki.snp.bottom).offset(16)
        }

        let subLb_maki = UILabel()
        subLb_maki.text = "Your handmade growth, sealed in time"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.85)
        headerView_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
        }

        // 底部圆角过渡条
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 20
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(24)
        }
    }

    /// 构建网格 + 空状态视图
    private func buildGrid_Maki() {
        contentView_Maki.addSubview(gridCV_Maki)
        gridCV_Maki.snp.makeConstraints { make in
            make.top.equalTo(headerView_Maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            gridCVHeight_Maki = make.height.equalTo(300).constraint
        }

        buildEmptyView_Maki()
        contentView_Maki.addSubview(emptyView_Maki)
        emptyView_Maki.snp.makeConstraints { make in
            make.top.equalTo(headerView_Maki.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(220)
        }
    }

    /// 构建空状态占位视图
    private func buildEmptyView_Maki() {
        let card_maki = UIView()
        card_maki.backgroundColor = .white
        card_maki.layer.cornerRadius = 20
        card_maki.layer.shadowColor = K_Maki.primary.withAlphaComponent(0.1).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_maki.layer.shadowRadius = 12
        card_maki.layer.shadowOpacity = 1
        emptyView_Maki.addSubview(card_maki)
        card_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        let iconLb_maki = UILabel()
        iconLb_maki.text = "📦"
        iconLb_maki.font = .systemFont(ofSize: 52)
        iconLb_maki.textAlignment = .center
        let titleLb_maki = UILabel()
        titleLb_maki.text = "No capsules sealed yet"
        titleLb_maki.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLb_maki.textColor = K_Maki.tp
        titleLb_maki.textAlignment = .center
        let subLb_maki = UILabel()
        subLb_maki.text = "Seal your first creation and\nrediscover it in the future!"
        subLb_maki.font = .systemFont(ofSize: 13)
        subLb_maki.textColor = K_Maki.ts
        subLb_maki.textAlignment = .center
        subLb_maki.numberOfLines = 2

        card_maki.addSubview(iconLb_maki)
        card_maki.addSubview(titleLb_maki)
        card_maki.addSubview(subLb_maki)
        iconLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
        }
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalTo(iconLb_maki.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        subLb_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}

// MARK: - 数据刷新

extension CapsuleList_Maki {

    private func reloadAll_Maki() {
        let capsules_maki = CapsuleViewModel_Maki.shared_Maki.getCapsules_Maki()
        let hasCapsules_maki = !capsules_maki.isEmpty

        gridCV_Maki.isHidden   = !hasCapsules_maki
        emptyView_Maki.isHidden = hasCapsules_maki
        gridCV_Maki.reloadData()

        if hasCapsules_maki {
            let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
            let itemH_maki = itemW_maki * 1.2
            let rows_maki  = ceil(CGFloat(capsules_maki.count) / 2)
            gridCVHeight_Maki?.update(offset: rows_maki * itemH_maki + max(0, rows_maki - 1) * 12 + 20 + 100)
        } else {
            gridCVHeight_Maki?.update(offset: 0)
        }
    }
}

// MARK: - 通知绑定

extension CapsuleList_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: CapsuleViewModel_Maki.capsuleStateDidChangeNotification_Maki, object: nil
        )
    }
    @objc private func onDataChange_Maki() { reloadAll_Maki() }
}

// MARK: - 事件响应

extension CapsuleList_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    @objc private func onAddCapsule_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toCreateCapsule_Maki()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension CapsuleList_Maki: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CapsuleViewModel_Maki.shared_Maki.getCapsules_Maki().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_maki = collectionView.dequeueReusableCell(
            withReuseIdentifier: K_Maki.cellId, for: indexPath
        ) as! CapsuleGridCell_Maki
        let capsule_maki = CapsuleViewModel_Maki.shared_Maki.getCapsules_Maki()[indexPath.item]
        cell_maki.configure_Maki(capsule_maki: capsule_maki)
        return cell_maki
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let capsules_maki = CapsuleViewModel_Maki.shared_Maki.getCapsules_Maki()
        guard indexPath.item < capsules_maki.count else { return }
        let capsule_maki = capsules_maki[indexPath.item]

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard capsule_maki.isUnlocked_Maki else {
            let days_maki = daysUntil_Maki(capsule_maki.openDate_Maki)
            Load_Maki.showInfo_Maki(message_Maki: "Still sealed! Opens in \(days_maki) day\(days_maki == 1 ? "" : "s")")
            return
        }
        Navigation_Maki.toCapsuleDetail_Maki(with: capsule_maki)
    }

    /// 计算距开启日期的剩余天数（至少为 1）
    private func daysUntil_Maki(_ date_maki: Date) -> Int {
        max(1, Calendar.current.dateComponents([.day], from: Date(), to: date_maki).day ?? 1)
    }
}

// MARK: - CapsuleGridCell_Maki（胶囊网格 Cell）

/// 时光胶囊网格 Cell
/// 功能：解锁态展示封面 + 心情 + 状态角标；锁定态展示模糊遮罩 + 锁图标 + 倒计时文字
final class CapsuleGridCell_Maki: UICollectionViewCell {

    // MARK: UI 子视图

    private let cardView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 16
        v_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#6C3483").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_maki.layer.shadowRadius = 10
        v_maki.layer.shadowOpacity = 1
        v_maki.layer.masksToBounds = false
        return v_maki
    }()
    private let innerClip_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = 16
        v_maki.clipsToBounds = true
        return v_maki
    }()
    private let mediaIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.contentMode = .scaleAspectFill
        iv_maki.clipsToBounds = true
        iv_maki.backgroundColor = UIColor(hexstring_Maki: "#F3E5F5")
        return iv_maki
    }()
    /// 锁定态模糊遮罩
    private let lockOverlay_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        return v_maki
    }()
    private let lockIconIV_Maki: UIImageView = {
        let iv_maki = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv_maki.tintColor = .white
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let countdownLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11, weight: .semibold)
        lb_maki.textColor = .white
        lb_maki.textAlignment = .center
        lb_maki.numberOfLines = 2
        return lb_maki
    }()
    /// 解锁态角标（心情 emoji）
    private let moodBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        v_maki.layer.cornerRadius = 14
        return v_maki
    }()
    private let moodLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 16)
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    /// "NEW" 提示徽章（已解锁未查看）
    private let newBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00")
        v_maki.layer.cornerRadius = 8
        v_maki.isHidden = true
        return v_maki
    }()
    private let newLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "NEW"
        lb_maki.font = .systemFont(ofSize: 9, weight: .bold)
        lb_maki.textColor = .white
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    private let dateLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 11, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        contentView.addSubview(cardView_Maki)
        cardView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Maki.addSubview(innerClip_Maki)
        innerClip_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        innerClip_Maki.addSubview(mediaIV_Maki)
        mediaIV_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.72)
        }

        innerClip_Maki.addSubview(lockOverlay_Maki)
        lockOverlay_Maki.snp.makeConstraints { make in
            make.edges.equalTo(mediaIV_Maki)
        }
        lockOverlay_Maki.addSubview(lockIconIV_Maki)
        lockIconIV_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(22)
        }
        lockOverlay_Maki.addSubview(countdownLb_Maki)
        countdownLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(lockIconIV_Maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(6)
        }

        moodBadge_Maki.addSubview(moodLb_Maki)
        innerClip_Maki.addSubview(moodBadge_Maki)
        moodLb_Maki.snp.makeConstraints { $0.center.equalToSuperview() }
        moodBadge_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(28)
        }

        newBadge_Maki.addSubview(newLb_Maki)
        innerClip_Maki.addSubview(newBadge_Maki)
        newLb_Maki.snp.makeConstraints { $0.center.equalToSuperview(); $0.leading.trailing.equalToSuperview().inset(4) }
        newBadge_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(16)
        }

        innerClip_Maki.addSubview(dateLb_Maki)
        dateLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(mediaIV_Maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().offset(-6)
        }
    }

    // MARK: 配置

    func configure_Maki(capsule_maki: TimeCapsuleModel_Maki) {
        if capsule_maki.isUnlocked_Maki {
            mediaIV_Maki.image = UIImage(named: capsule_maki.coverMedia_Maki)
                ?? UIImage(contentsOfFile: documentsPath_Maki(for: capsule_maki.coverMedia_Maki))
                ?? UIImage(systemName: "photo.fill")
            mediaIV_Maki.tintColor = UIColor(hexstring_Maki: "#9B59B6")
            lockOverlay_Maki.isHidden = true
            moodBadge_Maki.isHidden = false
            moodLb_Maki.text = capsule_maki.mood_Maki
            newBadge_Maki.isHidden = capsule_maki.isOpened_Maki
            let fmt_maki = DateFormatter()
            fmt_maki.dateFormat = "MMM d, yyyy"
            dateLb_Maki.text = "Opened \(fmt_maki.string(from: capsule_maki.openDate_Maki))"
        } else {
            mediaIV_Maki.image = UIImage(named: capsule_maki.coverMedia_Maki)
                ?? UIImage(contentsOfFile: documentsPath_Maki(for: capsule_maki.coverMedia_Maki))
                ?? UIImage(systemName: "photo.fill")
            lockOverlay_Maki.isHidden = false
            moodBadge_Maki.isHidden = true
            newBadge_Maki.isHidden = true
            let days_maki = max(1, Calendar.current.dateComponents([.day], from: Date(), to: capsule_maki.openDate_Maki).day ?? 1)
            countdownLb_Maki.text = "Opens in\n\(days_maki)d"
            let fmt_maki = DateFormatter()
            fmt_maki.dateFormat = "MMM d, yyyy"
            dateLb_Maki.text = "Opens \(fmt_maki.string(from: capsule_maki.openDate_Maki))"
        }
    }

    /// 拼接 Documents 目录完整路径
    private func documentsPath_Maki(for filename_maki: String) -> String {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_maki).path
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaIV_Maki.image = nil
        countdownLb_Maki.text = nil
        dateLb_Maki.text = nil
    }
}

// MARK: - CapsuleDetail_Maki（时光胶囊详情页）

/// 时光胶囊详情页视图控制器
/// 功能：展示已解锁胶囊的完整内容——成品封面、制作视频入口、材料清单、心情、赠送对象与故事
/// 设计：与创建页统一的紫色渐变导航风格；卡片式信息分区
/// 逻辑：进入页面后调用 CapsuleViewModel_Maki.markOpened_Maki 标记为已查看
class CapsuleDetail_Maki: UIViewController {

    /// 对外属性：待展示的胶囊模型
    var capsuleModel_Maki: TimeCapsuleModel_Maki?

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#9B59B6")
        static let accent  = UIColor(hexstring_Maki: "#6C3483")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
    }

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    private let mediaContainer_Maki = UIView()
    private let mediaDisplayView_Maki = MediaDisplayView_Maki()
    private let backBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        btn_maki.layer.cornerRadius = 19
        btn_maki.layer.borderWidth = 1
        btn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return btn_maki
    }()

    private let infoCard_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 22
        v_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.07).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_maki.layer.shadowRadius = 12
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        fillContent_Maki()
        if let capsule_maki = capsuleModel_Maki {
            CapsuleViewModel_Maki.shared_Maki.markOpened_Maki(capsule_maki: capsule_maki)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension CapsuleDetail_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }

        contentView_Maki.addSubview(mediaContainer_Maki)
        mediaContainer_Maki.clipsToBounds = true
        mediaContainer_Maki.addSubview(mediaDisplayView_Maki)
        mediaContainer_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(320)
        }
        mediaDisplayView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        mediaContainer_Maki.addSubview(backBtn_Maki)
        backBtn_Maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        backBtn_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(statusH_maki + 8)
            make.width.height.equalTo(38)
        }

        contentView_Maki.addSubview(infoCard_Maki)
        infoCard_Maki.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Maki.snp.bottom).offset(-20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-40)
        }
    }

    /// 填充胶囊内容到详情卡片
    private func fillContent_Maki() {
        guard let capsule_maki = capsuleModel_Maki else { return }
        mediaDisplayView_Maki.configure_Maki(mediaPath_Maki: capsule_maki.coverMedia_Maki)

        let fmt_maki = DateFormatter()
        fmt_maki.dateFormat = "MMMM d, yyyy"

        // 心情 + 开启日期行
        let moodRow_maki = UIView()
        let moodLb_maki = UILabel()
        moodLb_maki.text = capsule_maki.mood_Maki
        moodLb_maki.font = .systemFont(ofSize: 34)
        let dateInfoStack_maki = UIView()
        let sealedLb_maki = UILabel()
        sealedLb_maki.text = "Sealed on \(fmt_maki.string(from: capsule_maki.createDate_Maki))"
        sealedLb_maki.font = .systemFont(ofSize: 12)
        sealedLb_maki.textColor = K_Maki.ts
        let openedLb_maki = UILabel()
        openedLb_maki.text = "Opened on \(fmt_maki.string(from: Date()))"
        openedLb_maki.font = .systemFont(ofSize: 12, weight: .semibold)
        openedLb_maki.textColor = K_Maki.primary
        dateInfoStack_maki.addSubview(sealedLb_maki)
        dateInfoStack_maki.addSubview(openedLb_maki)
        sealedLb_maki.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        openedLb_maki.snp.makeConstraints { make in
            make.top.equalTo(sealedLb_maki.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
        moodRow_maki.addSubview(moodLb_maki)
        moodRow_maki.addSubview(dateInfoStack_maki)
        moodLb_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        dateInfoStack_maki.snp.makeConstraints { make in
            make.leading.equalTo(moodLb_maki.snp.trailing).offset(14)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        infoCard_Maki.addSubview(moodRow_maki)
        moodRow_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(44)
        }

        // 制作视频入口（如有）
        var lastView_maki: UIView = moodRow_maki
        if let videoPath_maki = capsule_maki.videoPath_Maki {
            let videoBtn_maki = UIButton(type: .system)
            videoBtn_maki.setTitle("  Watch Process Video", for: .normal)
            videoBtn_maki.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            videoBtn_maki.setTitleColor(.white, for: .normal)
            videoBtn_maki.tintColor = .white
            videoBtn_maki.backgroundColor = K_Maki.primary
            videoBtn_maki.layer.cornerRadius = 12
            videoBtn_maki.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            videoBtn_maki.addAction(UIAction { _ in
                Navigation_Maki.toMediaPlayer_Maki(mediaPath_maki: videoPath_maki, isVideo_maki: true)
            }, for: .touchUpInside)
            infoCard_Maki.addSubview(videoBtn_maki)
            videoBtn_maki.snp.makeConstraints { make in
                make.top.equalTo(moodRow_maki.snp.bottom).offset(14)
                make.leading.trailing.equalToSuperview().inset(18)
                make.height.equalTo(46)
            }
            lastView_maki = videoBtn_maki
        }

        // 材料清单
        let materialsHeader_maki = buildSectionLabel_Maki(icon_maki: "list.bullet.clipboard.fill", title_maki: "Materials")
        infoCard_Maki.addSubview(materialsHeader_maki)
        materialsHeader_maki.snp.makeConstraints { make in
            make.top.equalTo(lastView_maki.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(18)
        }
        let materialsWrap_maki = buildTagWrap_Maki(items_maki: capsule_maki.materials_Maki)
        infoCard_Maki.addSubview(materialsWrap_maki)
        materialsWrap_maki.snp.makeConstraints { make in
            make.top.equalTo(materialsHeader_maki.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 赠送对象
        let giftHeader_maki = buildSectionLabel_Maki(icon_maki: "gift.fill", title_maki: "Made For")
        infoCard_Maki.addSubview(giftHeader_maki)
        giftHeader_maki.snp.makeConstraints { make in
            make.top.equalTo(materialsWrap_maki.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
        }
        let giftLb_maki = UILabel()
        giftLb_maki.text = capsule_maki.giftTo_Maki
        giftLb_maki.font = .systemFont(ofSize: 14)
        giftLb_maki.textColor = K_Maki.tp
        giftLb_maki.numberOfLines = 0
        infoCard_Maki.addSubview(giftLb_maki)
        giftLb_maki.snp.makeConstraints { make in
            make.top.equalTo(giftHeader_maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 背后故事
        let storyHeader_maki = buildSectionLabel_Maki(icon_maki: "text.quote", title_maki: "The Story")
        infoCard_Maki.addSubview(storyHeader_maki)
        storyHeader_maki.snp.makeConstraints { make in
            make.top.equalTo(giftLb_maki.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
        }
        let storyLb_maki = UILabel()
        storyLb_maki.text = capsule_maki.story_Maki
        storyLb_maki.font = .systemFont(ofSize: 14)
        storyLb_maki.textColor = UIColor(hexstring_Maki: "#4A3010")
        storyLb_maki.numberOfLines = 0
        infoCard_Maki.addSubview(storyLb_maki)
        storyLb_maki.snp.makeConstraints { make in
            make.top.equalTo(storyHeader_maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 构建区块标题（图标 + 文字）
    private func buildSectionLabel_Maki(icon_maki: String, title_maki: String) -> UIView {
        let wrap_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: icon_maki))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let lb_maki = UILabel()
        lb_maki.text = title_maki
        lb_maki.font = .systemFont(ofSize: 13, weight: .bold)
        lb_maki.textColor = K_Maki.tp
        wrap_maki.addSubview(iconIV_maki)
        wrap_maki.addSubview(lb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        lb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(6)
            make.centerY.trailing.equalToSuperview()
        }
        return wrap_maki
    }

    /// 构建材料标签流式排布（简化为水平换行 UIStackView 拼接）
    private func buildTagWrap_Maki(items_maki: [String]) -> UIView {
        let container_maki = UIView()
        var currentRow_maki: UIStackView?
        var currentRowWidth_maki: CGFloat = 0
        let maxWidth_maki = APPSCREEN_Maki.WIDTH_Maki - 32 - 36
        let verticalStack_maki = UIStackView()
        verticalStack_maki.axis = .vertical
        verticalStack_maki.spacing = 8
        container_maki.addSubview(verticalStack_maki)
        verticalStack_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        for item_maki in items_maki {
            let chip_maki = buildChip_Maki(text_maki: item_maki)
            let estWidth_maki = CGFloat(item_maki.count) * 8 + 28
            if currentRow_maki == nil || currentRowWidth_maki + estWidth_maki > maxWidth_maki {
                let row_maki = UIStackView()
                row_maki.axis = .horizontal
                row_maki.spacing = 8
                verticalStack_maki.addArrangedSubview(row_maki)
                currentRow_maki = row_maki
                currentRowWidth_maki = 0
            }
            currentRow_maki?.addArrangedSubview(chip_maki)
            currentRowWidth_maki += estWidth_maki + 8
        }
        return container_maki
    }

    /// 构建单个材料标签胶囊
    private func buildChip_Maki(text_maki: String) -> UIView {
        let chip_maki = UIView()
        chip_maki.backgroundColor = K_Maki.primary.withAlphaComponent(0.1)
        chip_maki.layer.cornerRadius = 12
        let lb_maki = UILabel()
        lb_maki.text = text_maki
        lb_maki.font = .systemFont(ofSize: 12, weight: .medium)
        lb_maki.textColor = K_Maki.primary
        chip_maki.addSubview(lb_maki)
        lb_maki.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        return chip_maki
    }

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }
}
