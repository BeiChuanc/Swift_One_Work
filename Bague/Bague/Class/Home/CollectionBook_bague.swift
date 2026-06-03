import Foundation
import UIKit
import SnapKit

// MARK: 我的藏包册页面

/// 我的藏包册视图控制器
/// 功能：展示用户上传的包包藏品列表、支持添加新藏品和删除已有条目
/// 设计：三色渐变头部、2列卡片网格、右上角删除按钮、底部悬浮添加按钮
class CollectionBook_Bague: UIViewController {

    // MARK: - UI 组件（头部）

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
        label.text = "My Collection Book"
        label.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label.textColor = .white
        return label
    }()

    private let headerSubtitle_Bague: UILabel = {
        let label = UILabel()
        label.text = "Your personal niche bag archive"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.82)
        return label
    }()

    private let headerDecorIcon_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "books.vertical.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.16)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - UI 组件（列表）

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Bague = UIView()

    /// 空状态视图
    private let emptyView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        iv.image = UIImage(systemName: "bag", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let emptyLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "No bags yet. Tap + to add your first one!"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    /// 藏包网格容器（左右两列）
    private let leftColumn_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    private let rightColumn_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        return sv
    }()

    /// 悬浮添加按钮
    private let addBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        btn.setImage(UIImage(systemName: "plus", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 28
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#9B72F5").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 12
        return btn
    }()

    private var addBtnGrad_Bague: CAGradientLayer?

    // MARK: - 数据

    private var bags_Bague: [BagItem_Bague] = []

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadBags_Bague()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        // 头部
        view.addSubview(headerView_Bague)
        headerView_Bague.addSubview(backBtn_Bague)
        headerView_Bague.addSubview(headerTitleLabel_Bague)
        headerView_Bague.addSubview(headerSubtitle_Bague)
        headerView_Bague.addSubview(headerDecorIcon_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        // 内容
        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)

        // 双列网格
        contentView_Bague.addSubview(leftColumn_Bague)
        contentView_Bague.addSubview(rightColumn_Bague)

        // 空状态
        contentView_Bague.addSubview(emptyView_Bague)
        emptyView_Bague.addSubview(emptyIcon_Bague)
        emptyView_Bague.addSubview(emptyLabel_Bague)

        // 悬浮添加按钮
        view.addSubview(addBtn_Bague)
        addBtn_Bague.addTarget(self, action: #selector(addBagTapped_Bague), for: .touchUpInside)
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
        let colW_bague = (APPSCREEN_Bague.WIDTH_Bague - 20 * 2 - 14) / 2
        leftColumn_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(colW_bague)
            make.bottom.equalToSuperview().offset(-100)
        }
        rightColumn_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(colW_bague)
        }
        emptyView_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        emptyIcon_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(72)
        }
        emptyLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(emptyIcon_Bague.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        addBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(56)
        }
    }

    // MARK: - 渐变

    private func updateGradients_Bague() {
        headerGrad_Bague?.removeFromSuperlayer()
        let hGrad_bague = CAGradientLayer()
        hGrad_bague.frame = headerView_Bague.bounds
        hGrad_bague.colors = [
            UIColor(hexstring_Bague: "#9B72F5").cgColor,
            UIColor(hexstring_Bague: "#C4ABFF").cgColor
        ]
        hGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        hGrad_bague.endPoint = CGPoint(x: 1, y: 1)
        hGrad_bague.cornerRadius = 28
        hGrad_bague.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Bague.layer.insertSublayer(hGrad_bague, at: 0)
        headerGrad_Bague = hGrad_bague

        addBtnGrad_Bague?.removeFromSuperlayer()
        let bGrad_bague = CAGradientLayer()
        bGrad_bague.frame = addBtn_Bague.bounds
        bGrad_bague.colors = [
            UIColor(hexstring_Bague: "#9B72F5").cgColor,
            UIColor(hexstring_Bague: "#7DC4F0").cgColor
        ]
        bGrad_bague.startPoint = CGPoint(x: 0, y: 0)
        bGrad_bague.endPoint = CGPoint(x: 1, y: 1)
        bGrad_bague.cornerRadius = 28
        addBtn_Bague.layer.insertSublayer(bGrad_bague, at: 0)
        addBtnGrad_Bague = bGrad_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataChanged_Bague),
            name: UserViewModel_Bague.userStateDidChangeNotification_Bague,
            object: nil
        )
    }

    @objc private func dataChanged_Bague() { reloadBags_Bague() }

    private func reloadBags_Bague() {
        bags_Bague = UserViewModel_Bague.shared_Bague.getBags_Bague()

        leftColumn_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumn_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if bags_Bague.isEmpty {
            emptyView_Bague.isHidden = false
        } else {
            emptyView_Bague.isHidden = true
            bags_Bague.enumerated().forEach { idx, bag in
                let card_bague = BagItemCard_Bague(
                    bag: bag,
                    viewController_bague: self,
                    onTap_bague: { [weak self] in
                        self?.showBagDetail_Bague(bag: bag)
                    },
                    onDelete_bague: { [weak self] in
                        Task { @MainActor in
                            UserViewModel_Bague.shared_Bague.deleteBag_Bague(itemId_bague: bag.itemId_Bague)
                            self?.reloadBags_Bague()
                        }
                    }
                )
                if idx % 2 == 0 {
                    leftColumn_Bague.addArrangedSubview(card_bague)
                } else {
                    rightColumn_Bague.addArrangedSubview(card_bague)
                }
            }
        }
    }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    /// 展示藏包详情底部弹窗
    private func showBagDetail_Bague(bag: BagItem_Bague) {
        let sheet_bague = BagDetailSheet_Bague(bag: bag) { [weak self] in
            self?.confirmDeleteFromDetail_Bague(bag: bag)
        }
        sheet_bague.modalPresentationStyle = .overFullScreen
        sheet_bague.modalTransitionStyle = .crossDissolve
        present(sheet_bague, animated: true)
    }

    /// 从详情弹窗触发删除（关闭详情后执行）
    private func confirmDeleteFromDetail_Bague(bag: BagItem_Bague) {
        Task { @MainActor in
            UserViewModel_Bague.shared_Bague.deleteBag_Bague(itemId_bague: bag.itemId_Bague)
            reloadBags_Bague()
        }
    }

    @objc private func addBagTapped_Bague() {
        addBtn_Bague.animatePulse_Bague()
        guard UserViewModel_Bague.shared_Bague.isLoggedIn_Bague else {
            Navigation_Bague.toLogin_Bague(style_bague: .present_bague)
            return
        }
        let sheet_bague = AddBagSheet_Bague()
        sheet_bague.modalPresentationStyle = .overFullScreen
        sheet_bague.modalTransitionStyle = .crossDissolve
        present(sheet_bague, animated: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - 藏包卡片视图

/// 单个藏包展示卡片
/// 功能：展示包包图片/占位图、名称、品牌、成色
/// 设计：右上角使用 ReportDeleteHelper 删除按钮；点击卡片触发详情回调
class BagItemCard_Bague: UIView {

    private var onTap_Bague: (() -> Void)?

    /// - Parameters:
    ///   - bag: 藏包数据
    ///   - viewController_bague: 宿主 VC（供 ReportDeleteHelper 弹出确认框）
    ///   - onTap_bague: 点击卡片主体触发（展示详情）
    ///   - onDelete_bague: 确认删除后的回调
    init(bag: BagItem_Bague,
         viewController_bague: UIViewController,
         onTap_bague: @escaping () -> Void,
         onDelete_bague: @escaping () -> Void) {
        self.onTap_Bague = onTap_bague
        super.init(frame: .zero)
        buildUI_Bague(bag: bag, vc: viewController_bague, onDelete: onDelete_bague)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI_Bague(bag: BagItem_Bague, vc: UIViewController, onDelete: @escaping () -> Void) {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8

        // 图片区
        let imageView_bague = UIImageView()
        imageView_bague.contentMode = .scaleAspectFill
        imageView_bague.clipsToBounds = true
        imageView_bague.layer.cornerRadius = 14
        imageView_bague.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addSubview(imageView_bague)

        if let path_bague = bag.imagePath_Bague, let img_bague = UIImage(contentsOfFile: path_bague) {
            imageView_bague.image = img_bague
        } else if let named_bague = bag.imagePath_Bague, let img_bague = UIImage(named: named_bague) {
            imageView_bague.image = img_bague
        } else {
            imageView_bague.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
            imageView_bague.image = UIImage(systemName: "bag.fill")
            imageView_bague.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.55)
        }

        // 删除按钮（ReportDeleteHelper 统一管理，右上角）
        let deleteBtn_bague = ReportDeleteHelper_Bague.createBagDeleteButton_Bague(
            size_Bague: 11,
            from: vc,
            onDelete_Bague: onDelete
        )
        addSubview(deleteBtn_bague)

        // 名称
        let nameLabel_bague = UILabel()
        nameLabel_bague.text = bag.name_Bague
        nameLabel_bague.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLabel_bague.textColor = ColorConfig_Bague.textPrimary_Bague
        nameLabel_bague.numberOfLines = 2
        addSubview(nameLabel_bague)

        // 品牌
        let brandLabel_bague = UILabel()
        brandLabel_bague.text = bag.brand_Bague ?? "Unknown Brand"
        brandLabel_bague.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        brandLabel_bague.textColor = ColorConfig_Bague.textSecondary_Bague
        addSubview(brandLabel_bague)

        // 成色徽章
        let condBadge_bague = UILabel()
        condBadge_bague.text = bag.condition_Bague ?? "—"
        condBadge_bague.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        condBadge_bague.textColor = UIColor(hexstring_Bague: "#9B72F5")
        condBadge_bague.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
        condBadge_bague.layer.cornerRadius = 8
        condBadge_bague.clipsToBounds = true
        condBadge_bague.textAlignment = .center
        addSubview(condBadge_bague)

        // 约束
        imageView_bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        deleteBtn_bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(24)
        }
        nameLabel_bague.snp.makeConstraints { make in
            make.top.equalTo(imageView_bague.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        brandLabel_bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_bague.snp.bottom).offset(3)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        condBadge_bague.snp.makeConstraints { make in
            make.top.equalTo(brandLabel_bague.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(18)
        }

        // 年份（如有）
        if let year_bague = bag.yearAcquired_Bague, !year_bague.isEmpty {
            let yearLabel_bague = UILabel()
            yearLabel_bague.text = year_bague
            yearLabel_bague.font = UIFont.systemFont(ofSize: 10, weight: .regular)
            yearLabel_bague.textColor = ColorConfig_Bague.textPlaceholder_Bague
            addSubview(yearLabel_bague)
            yearLabel_bague.snp.makeConstraints { make in
                make.centerY.equalTo(condBadge_bague)
                make.trailing.equalToSuperview().offset(-10)
            }
        }

        // 点击卡片主体进入详情（排除删除按钮区域使用 isUserInteractionEnabled 分层处理）
        let tap_bague = UITapGestureRecognizer(target: self, action: #selector(cardTapped_Bague))
        addGestureRecognizer(tap_bague)
        isUserInteractionEnabled = true
    }

    @objc private func cardTapped_Bague() {
        animatePressDown_Bague { self.animatePressUp_Bague { self.onTap_Bague?() } }
    }
}

// MARK: - 添加藏包底部弹窗

/// 添加藏包底部弹窗
/// 功能：图片选取、名称/品牌/年份/成色/备注输入，确认后写入用户藏包册
class AddBagSheet_Bague: UIViewController {

    private let overlayView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let sheetView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let grabber_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        v.layer.cornerRadius = 2
        return v
    }()

    private let titleLabel_Bague: UILabel = {
        let l = UILabel()
        l.text = "Add to Collection"
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Bague.textPrimary_Bague
        return l
    }()

    // 图片选取
    private let imagePickerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor(hexstring_Bague: "#D4C4FF").cgColor
        return v
    }()

    private let previewImage_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.isHidden = true
        return iv
    }()

    private let addPhotoIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let addPhotoLabel_Bague: UILabel = {
        let l = UILabel()
        l.text = "Add Photo"
        l.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = UIColor(hexstring_Bague: "#9B72F5")
        l.textAlignment = .center
        return l
    }()

    // 输入字段
    private let nameField_Bague = AddBagSheet_Bague.makeField_Bague(placeholder: "Bag name *", icon: "bag.fill", tint: UIColor(hexstring_Bague: "#9B72F5"))
    private let brandField_Bague = AddBagSheet_Bague.makeField_Bague(placeholder: "Brand", icon: "tag.fill", tint: UIColor(hexstring_Bague: "#5AADEC"))
    private let yearField_Bague = AddBagSheet_Bague.makeField_Bague(placeholder: "Year acquired", icon: "calendar", tint: UIColor(hexstring_Bague: "#3DC9A6"))
    private let conditionField_Bague = AddBagSheet_Bague.makeField_Bague(placeholder: "Condition (Mint / Good / Fair)", icon: "star.fill", tint: UIColor(hexstring_Bague: "#F5A623"))
    private let notesField_Bague = AddBagSheet_Bague.makeField_Bague(placeholder: "Story / Notes (optional)", icon: "text.alignleft", tint: UIColor(hexstring_Bague: "#F07DAD"))

    private let confirmBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Add to My Collection", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(hexstring_Bague: "#9B72F5")
        btn.layer.cornerRadius = 22
        btn.layer.shadowColor = UIColor(hexstring_Bague: "#9B72F5").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 10
        return btn
    }()

    private var selectedImagePath_Bague: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView_Bague.animateSlideInFromBottom_Bague(offset_Bague: 80)
    }

    private func setupUI_Bague() {
        view.backgroundColor = .clear
        view.addSubview(overlayView_Bague)
        view.addSubview(sheetView_Bague)
        sheetView_Bague.addSubview(grabber_Bague)
        sheetView_Bague.addSubview(titleLabel_Bague)
        sheetView_Bague.addSubview(imagePickerView_Bague)
        imagePickerView_Bague.addSubview(previewImage_Bague)
        imagePickerView_Bague.addSubview(addPhotoIcon_Bague)
        imagePickerView_Bague.addSubview(addPhotoLabel_Bague)
        sheetView_Bague.addSubview(nameField_Bague)
        sheetView_Bague.addSubview(brandField_Bague)
        sheetView_Bague.addSubview(yearField_Bague)
        sheetView_Bague.addSubview(conditionField_Bague)
        sheetView_Bague.addSubview(notesField_Bague)
        sheetView_Bague.addSubview(confirmBtn_Bague)

        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(cancelTapped_Bague))
        overlayView_Bague.addGestureRecognizer(bgTap_bague)
        let photoTap_bague = UITapGestureRecognizer(target: self, action: #selector(photoTapped_Bague))
        imagePickerView_Bague.addGestureRecognizer(photoTap_bague)
        imagePickerView_Bague.isUserInteractionEnabled = true
        confirmBtn_Bague.addTarget(self, action: #selector(confirmTapped_Bague), for: .touchUpInside)

        overlayView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        sheetView_Bague.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        grabber_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
        }
        imagePickerView_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(90)
        }
        previewImage_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        addPhotoIcon_Bague.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
            make.width.height.equalTo(28)
        }
        addPhotoLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(addPhotoIcon_Bague.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        nameField_Bague.snp.makeConstraints { make in
            make.top.equalTo(imagePickerView_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        brandField_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameField_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        yearField_Bague.snp.makeConstraints { make in
            make.top.equalTo(brandField_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        conditionField_Bague.snp.makeConstraints { make in
            make.top.equalTo(yearField_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        notesField_Bague.snp.makeConstraints { make in
            make.top.equalTo(conditionField_Bague.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        confirmBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(notesField_Bague.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }

    /// 工厂方法：创建带图标的输入框
    private static func makeField_Bague(placeholder: String, icon: String, tint: UIColor) -> UIView {
        let container_bague = UIView()
        container_bague.backgroundColor = UIColor(hexstring_Bague: "#F8F5FF")
        container_bague.layer.cornerRadius = 14
        container_bague.layer.borderWidth = 1
        container_bague.layer.borderColor = UIColor(hexstring_Bague: "#E0D4FF").cgColor

        let iv_bague = UIImageView()
        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
        iv_bague.tintColor = tint
        iv_bague.contentMode = .scaleAspectFit

        let tf_bague = UITextField()
        tf_bague.placeholder = placeholder
        tf_bague.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_bague.textColor = ColorConfig_Bague.textPrimary_Bague
        tf_bague.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        tf_bague.returnKeyType = .next

        container_bague.addSubview(iv_bague)
        container_bague.addSubview(tf_bague)
        iv_bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        tf_bague.snp.makeConstraints { make in
            make.leading.equalTo(iv_bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        return container_bague
    }

    /// 取某个字段内的 UITextField
    private func fieldText_Bague(_ field: UIView) -> String {
        return (field.subviews.compactMap { $0 as? UITextField }.first?.text ?? "").trimmingCharacters(in: .whitespaces)
    }

    @objc private func photoTapped_Bague() {
        MediaPickerHelper_Bague.pickImage_Bague(from: self) { [weak self] image_bague in
            guard let self = self, let img_bague = image_bague else { return }
            let path_bague = NSTemporaryDirectory() + "bag_\(Date().timeIntervalSince1970).jpg"
            try? img_bague.jpegData(compressionQuality: 0.85)?.write(to: URL(fileURLWithPath: path_bague))
            self.selectedImagePath_Bague = path_bague
            self.previewImage_Bague.image = img_bague
            self.previewImage_Bague.isHidden = false
            self.addPhotoIcon_Bague.isHidden = true
            self.addPhotoLabel_Bague.isHidden = true
        }
    }

    @objc private func confirmTapped_Bague() {
        let name_bague = fieldText_Bague(nameField_Bague)
        guard !name_bague.isEmpty else {
            nameField_Bague.subviews.compactMap { $0 as? UITextField }.first?.animateShake_Bague()
            Utils_Bague.showWarning_Bague(message_Bague: "Please enter a bag name")
            return
        }
        let item_bague = BagItem_Bague(
            itemId_Bague: UserViewModel_Bague.shared_Bague.nextBagId_Bague(),
            name_Bague: name_bague,
            brand_Bague: fieldText_Bague(brandField_Bague).isEmpty ? nil : fieldText_Bague(brandField_Bague),
            yearAcquired_Bague: fieldText_Bague(yearField_Bague).isEmpty ? nil : fieldText_Bague(yearField_Bague),
            condition_Bague: fieldText_Bague(conditionField_Bague).isEmpty ? nil : fieldText_Bague(conditionField_Bague),
            notes_Bague: fieldText_Bague(notesField_Bague).isEmpty ? nil : fieldText_Bague(notesField_Bague),
            imagePath_Bague: selectedImagePath_Bague
        )
        Task { @MainActor in
            UserViewModel_Bague.shared_Bague.addBag_Bague(item_bague: item_bague)
        }
        Utils_Bague.showSuccess_Bague(message_Bague: "Added to your collection!")
        dismiss(animated: true)
    }

    @objc private func cancelTapped_Bague() { dismiss(animated: true) }
}

// MARK: - 藏包详情底部弹窗

/// 藏包详情底部弹窗
/// 功能：展示藏包完整信息（图片、名称、品牌、年份、成色、故事备注）及删除操作
/// 设计：半透明遮罩 + 白色圆角弹窗，渐变头部图片区，信息条目行
class BagDetailSheet_Bague: UIViewController {

    private let bag_Bague: BagItem_Bague
    private var onDelete_Bague: (() -> Void)?

    private let overlayView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let sheetView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let grabber_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        v.layer.cornerRadius = 2
        return v
    }()

    /// 封面图
    private let coverView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        return iv
    }()

    /// 删除按钮（右上角）
    private let deleteBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "trash", withConfiguration: cfg), for: .normal)
        btn.tintColor = UIColor(hexstring_Bague: "#FF6B6B")
        btn.backgroundColor = UIColor(hexstring_Bague: "#FFF0F0")
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor(hexstring_Bague: "#FF6B6B").withAlphaComponent(0.3).cgColor
        return btn
    }()

    private let nameLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        l.textColor = ColorConfig_Bague.textPrimary_Bague
        l.numberOfLines = 2
        return l
    }()

    private let infoStack_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    init(bag: BagItem_Bague, onDelete: @escaping () -> Void) {
        self.bag_Bague = bag
        self.onDelete_Bague = onDelete
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView_Bague.animateSlideInFromBottom_Bague(offset_Bague: 60)
    }

    private func setupUI_Bague() {
        view.backgroundColor = .clear
        view.addSubview(overlayView_Bague)
        view.addSubview(sheetView_Bague)
        sheetView_Bague.addSubview(grabber_Bague)
        sheetView_Bague.addSubview(coverView_Bague)
        sheetView_Bague.addSubview(deleteBtn_Bague)
        sheetView_Bague.addSubview(nameLabel_Bague)
        sheetView_Bague.addSubview(infoStack_Bague)

        // 填充封面图
        if let path_bague = bag_Bague.imagePath_Bague, let img_bague = UIImage(contentsOfFile: path_bague) {
            coverView_Bague.image = img_bague
        } else if let named_bague = bag_Bague.imagePath_Bague, let img_bague = UIImage(named: named_bague) {
            coverView_Bague.image = img_bague
        } else {
            coverView_Bague.backgroundColor = UIColor(hexstring_Bague: "#EDD9FF")
            coverView_Bague.image = UIImage(systemName: "bag.fill")
            coverView_Bague.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.55)
            coverView_Bague.contentMode = .scaleAspectFit
        }

        nameLabel_Bague.text = bag_Bague.name_Bague

        // 信息条目行
        let infos_bague: [(String, String, UIColor)] = [
            ("tag.fill",      bag_Bague.brand_Bague ?? "—",         UIColor(hexstring_Bague: "#5AADEC")),
            ("calendar",      bag_Bague.yearAcquired_Bague ?? "—",  UIColor(hexstring_Bague: "#3DC9A6")),
            ("star.fill",     bag_Bague.condition_Bague ?? "—",     UIColor(hexstring_Bague: "#F5A623")),
            ("text.alignleft", bag_Bague.notes_Bague ?? "No notes", UIColor(hexstring_Bague: "#F07DAD")),
        ]
        infos_bague.forEach { iconName_bague, text_bague, tint_bague in
            let row_bague = makeInfoRow_Bague(icon: iconName_bague, text: text_bague, tint: tint_bague)
            infoStack_Bague.addArrangedSubview(row_bague)
        }

        // 点击遮罩关闭
        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(closeTapped_Bague))
        overlayView_Bague.addGestureRecognizer(bgTap_bague)
        deleteBtn_Bague.addTarget(self, action: #selector(deleteTapped_Bague), for: .touchUpInside)

        // 约束
        overlayView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        sheetView_Bague.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        grabber_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        coverView_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        deleteBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(coverView_Bague)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(36)
        }
        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(coverView_Bague)
            make.leading.equalTo(coverView_Bague.snp.trailing).offset(14)
            make.trailing.equalTo(deleteBtn_Bague.snp.leading).offset(-8)
        }
        infoStack_Bague.snp.makeConstraints { make in
            make.top.equalTo(coverView_Bague.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
        }
    }

    /// 创建一行信息展示行（图标 + 文字）
    private func makeInfoRow_Bague(icon: String, text: String, tint: UIColor) -> UIView {
        let row_bague = UIView()
        row_bague.backgroundColor = tint.withAlphaComponent(0.06)
        row_bague.layer.cornerRadius = 12

        let iv_bague = UIImageView()
        let cfg_bague = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_bague.image = UIImage(systemName: icon, withConfiguration: cfg_bague)
        iv_bague.tintColor = tint
        iv_bague.contentMode = .scaleAspectFit

        let lbl_bague = UILabel()
        lbl_bague.text = text
        lbl_bague.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl_bague.textColor = ColorConfig_Bague.textPrimary_Bague
        lbl_bague.numberOfLines = 3

        row_bague.addSubview(iv_bague)
        row_bague.addSubview(lbl_bague)
        iv_bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(16)
        }
        lbl_bague.snp.makeConstraints { make in
            make.leading.equalTo(iv_bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        return row_bague
    }

    @objc private func closeTapped_Bague() { dismiss(animated: true) }

    @objc private func deleteTapped_Bague() {
        dismiss(animated: true) { [weak self] in
            self?.onDelete_Bague?()
        }
    }
}
