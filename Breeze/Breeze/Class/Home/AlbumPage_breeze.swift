import Foundation
import UIKit
import SnapKit

// MARK: 个人露营纪念相册页

/// 个人露营纪念相册页
/// 核心作用：展示用户所有露营照片，支持按表单添加（封面/季节/时间/地点）/删除，按季节分类
/// 设计思路：渐变头部 + UICollectionView 三列网格（季节分组）+ 底部"Add Memory"按钮
/// 关键属性：sections_Breeze 季节分组数据
class AlbumPage_Breeze: UIViewController {
    
    // MARK: - 数据
    
    /// 按季节分组后的展示数据（section=季节, items=该季节照片）
    private var sections_Breeze: [(season_breeze: String, items_breeze: [CampingAlbumItem_Breeze])] = []
    
    // MARK: - UI：渐变头部
    
    private let heroView_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.clipsToBounds = true
        return v_breeze
    }()
    
    private var heroGradient_Breeze: CAGradientLayer?
    
    private let decorCircle_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v_breeze.layer.cornerRadius = 65
        return v_breeze
    }()
    
    private let backButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_breeze), for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_breeze.layer.cornerRadius = 18
        return btn_breeze
    }()
    
    private let heroTitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.text = "My Camping Album"
        label_breeze.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        label_breeze.textColor = .white
        return label_breeze
    }()
    
    private let heroSubtitle_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label_breeze.textColor = UIColor.white.withAlphaComponent(0.82)
        return label_breeze
    }()
    
    // MARK: - UI：相册网格
    
    private lazy var collectionView_Breeze: UICollectionView = {
        let layout_breeze = UICollectionViewFlowLayout()
        let itemW_breeze = (APPSCREEN_Breeze.WIDTH_Breeze - 40 - 8) / 3
        layout_breeze.itemSize = CGSize(width: itemW_breeze, height: itemW_breeze)
        layout_breeze.minimumInteritemSpacing = 4
        layout_breeze.minimumLineSpacing = 4
        layout_breeze.sectionInset = UIEdgeInsets(top: 12, left: 20, bottom: 20, right: 20)
        layout_breeze.headerReferenceSize = CGSize(width: APPSCREEN_Breeze.WIDTH_Breeze, height: 40)
        let cv_breeze = UICollectionView(frame: .zero, collectionViewLayout: layout_breeze)
        cv_breeze.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        cv_breeze.showsVerticalScrollIndicator = false
        cv_breeze.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        return cv_breeze
    }()
    
    // MARK: - UI：底部操作栏
    
    private let bottomBar_Breeze: UIView = {
        let v_breeze = UIView()
        v_breeze.backgroundColor = .white
        v_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        v_breeze.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_breeze.layer.shadowRadius = 10
        v_breeze.layer.shadowOpacity = 0.1
        return v_breeze
    }()
    
    private let addButton_Breeze: UIButton = {
        let btn_breeze = UIButton(type: .system)
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn_breeze.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: config_breeze), for: .normal)
        btn_breeze.setTitle("  Add Memory", for: .normal)
        btn_breeze.tintColor = .white
        btn_breeze.setTitleColor(.white, for: .normal)
        btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn_breeze.layer.cornerRadius = 22
        return btn_breeze
    }()
    
    private var addButtonGradient_Breeze: CAGradientLayer?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Breeze()
        setupObservers_Breeze()
        reloadData_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshHeroGradient_Breeze()
        refreshAddButtonGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupHeroView_Breeze()
        setupCollectionView_Breeze()
        setupBottomBar_Breeze()
    }
    
    private func setupHeroView_Breeze() {
        view.addSubview(heroView_Breeze)
        heroView_Breeze.addSubview(decorCircle_Breeze)
        heroView_Breeze.addSubview(backButton_Breeze)
        heroView_Breeze.addSubview(heroTitle_Breeze)
        heroView_Breeze.addSubview(heroSubtitle_Breeze)
        
        heroView_Breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        decorCircle_Breeze.snp.makeConstraints { make in
            make.width.height.equalTo(130)
            make.right.equalToSuperview().offset(32)
            make.top.equalToSuperview().offset(-26)
        }
        backButton_Breeze.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        heroTitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(backButton_Breeze.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(22)
        }
        heroSubtitle_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroTitle_Breeze.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-18)
        }
        
        backButton_Breeze.addTarget(self, action: #selector(handleBack_Breeze), for: .touchUpInside)
    }
    
    private func refreshHeroGradient_Breeze() {
        heroGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: heroView_Breeze.bounds)
        heroView_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        heroGradient_Breeze = gradient_breeze
    }
    
    private func setupCollectionView_Breeze() {
        view.addSubview(collectionView_Breeze)
        collectionView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(heroView_Breeze.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView_Breeze.dataSource = self
        collectionView_Breeze.delegate = self
        collectionView_Breeze.register(AlbumPhotoCell_Breeze.self, forCellWithReuseIdentifier: AlbumPhotoCell_Breeze.reuseId_Breeze)
        collectionView_Breeze.register(
            AlbumSectionHeader_Breeze.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AlbumSectionHeader_Breeze.reuseId_Breeze
        )
    }
    
    private func setupBottomBar_Breeze() {
        view.addSubview(bottomBar_Breeze)
        bottomBar_Breeze.addSubview(addButton_Breeze)
        
        bottomBar_Breeze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(84 + (view.window?.safeAreaInsets.bottom ?? 0))
        }
        // 添加按钮横跨全宽
        addButton_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(44)
        }
        
        addButton_Breeze.addTarget(self, action: #selector(handleAddPhoto_Breeze), for: .touchUpInside)
    }
    
    private func refreshAddButtonGradient_Breeze() {
        guard !addButton_Breeze.bounds.isEmpty else { return }
        addButtonGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: addButton_Breeze.bounds)
        gradient_breeze.cornerRadius = addButton_Breeze.layer.cornerRadius
        addButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        addButtonGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 通知
    
    private func setupObservers_Breeze() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData_Breeze),
                                               name: UserViewModel_Breeze.userStateDidChangeNotification_Breeze, object: nil)
    }
    
    // MARK: - 数据
    
    @objc private func reloadData_Breeze() {
        let grouped_breeze = UserViewModel_Breeze.shared_Breeze.getAlbumGroupedBySeason_Breeze()
        sections_Breeze = Season_Breeze.allCases.compactMap { season_breeze in
            guard let items_breeze = grouped_breeze[season_breeze.rawValue], !items_breeze.isEmpty else { return nil }
            return (season_breeze: season_breeze.rawValue, items_breeze: items_breeze)
        }
        
        let totalCount_breeze = sections_Breeze.reduce(0) { $0 + $1.items_breeze.count }
        heroSubtitle_Breeze.text = totalCount_breeze == 0
            ? "Start capturing your nature memories"
            : "\(totalCount_breeze) memory\(totalCount_breeze > 1 ? "s" : "") across \(sections_Breeze.count) season\(sections_Breeze.count > 1 ? "s" : "")"
        
        collectionView_Breeze.reloadData()
    }
    
    // MARK: - 事件
    
    @objc private func handleBack_Breeze() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 点击"Add Memory" → 弹出创建表单（选封面 + 季节 + 时间 + 地点）
    @objc private func handleAddPhoto_Breeze() {
        let sheet_breeze = AlbumCreateSheet_Breeze()
        sheet_breeze.onComplete_Breeze = { [weak self] in
            self?.reloadData_Breeze()
        }
        sheet_breeze.modalPresentationStyle = .pageSheet
        if let sheetCtrl_breeze = sheet_breeze.sheetPresentationController {
            sheetCtrl_breeze.detents = [.large()]
            sheetCtrl_breeze.prefersGrabberVisible = true
            sheetCtrl_breeze.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(sheet_breeze, animated: true)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - CollectionView DataSource / Delegate

extension AlbumPage_Breeze: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections_Breeze.isEmpty ? 1 : sections_Breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections_Breeze.isEmpty ? 0 : sections_Breeze[section].items_breeze.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_breeze = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumPhotoCell_Breeze.reuseId_Breeze,
            for: indexPath
        ) as! AlbumPhotoCell_Breeze
        let item_breeze = sections_Breeze[indexPath.section].items_breeze[indexPath.row]
        cell_breeze.configure_Breeze(item_breeze: item_breeze)
        return cell_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header_breeze = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumSectionHeader_Breeze.reuseId_Breeze,
            for: indexPath
        ) as! AlbumSectionHeader_Breeze
        if !sections_Breeze.isEmpty {
            header_breeze.configure_Breeze(title_breeze: "\(sections_Breeze[indexPath.section].season_breeze)")
        }
        return header_breeze
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item_breeze = sections_Breeze[indexPath.section].items_breeze[indexPath.row]
        // 全屏预览
        let player_breeze = MediaPlayerPage_Breeze()
        player_breeze.mediaPath_Breeze = item_breeze.imagePath_Breeze
        player_breeze.modalPresentationStyle = .overFullScreen
        player_breeze.modalTransitionStyle = .crossDissolve
        present(player_breeze, animated: true)
    }
    
    /// 长按删除相册条目
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let item_breeze = sections_Breeze[indexPath.section].items_breeze[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let delete_breeze = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                UserViewModel_Breeze.shared_Breeze.deleteAlbumItem_Breeze(itemId_breeze: item_breeze.itemId_Breeze)
            }
            return UIMenu(title: "", children: [delete_breeze])
        }
    }
}

// MARK: - 相册照片 Cell

class AlbumPhotoCell_Breeze: UICollectionViewCell {
    
    static let reuseId_Breeze = "AlbumPhotoCell_Breeze"
    
    private let mediaView_Breeze: MediaDisplayView_Breeze = {
        let v_breeze = MediaDisplayView_Breeze()
        return v_breeze
    }()
    private let seasonBadge_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        label_breeze.textColor = .white
        label_breeze.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        label_breeze.layer.cornerRadius = 7
        label_breeze.clipsToBounds = true
        label_breeze.textAlignment = .center
        return label_breeze
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.addSubview(mediaView_Breeze)
        contentView.addSubview(seasonBadge_Breeze)
        mediaView_Breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        seasonBadge_Breeze.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(6)
            make.height.equalTo(16)
            make.width.greaterThanOrEqualTo(36)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Breeze(item_breeze: CampingAlbumItem_Breeze) {
        mediaView_Breeze.configure_Breeze(mediaPath_Breeze: item_breeze.imagePath_Breeze)
        seasonBadge_Breeze.text = "  \(item_breeze.season_Breeze.rawValue)  "
    }
}

// MARK: - 相册创建表单 Sheet

/// 创建露营记忆表单
/// 核心作用：引导用户填写封面、季节、日期、公园地点、备注后保存相册条目
class AlbumCreateSheet_Breeze: UIViewController {
    
    /// 保存完成回调
    var onComplete_Breeze: (() -> Void)?
    
    // MARK: - 数据
    
    private var pickedImage_Breeze: UIImage?
    private var selectedSeason_Breeze: Season_Breeze = Season_Breeze.current_Breeze
    private var selectedDate_Breeze: Date = Date()
    
    // MARK: - UI
    
    private let scrollView_Breeze: UIScrollView = {
        let sv = UIScrollView(); sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag; return sv
    }()
    private let contentStack_Breeze: UIStackView = {
        let s = UIStackView(); s.axis = .vertical; s.spacing = 20; return s
    }()
    
    /// 封面选择区（点击选图）
    private let coverPickerView_Breeze: UIControl = {
        let v = UIControl()
        v.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1.5
        v.layer.borderColor = ColorConfig_Breeze.border_Breeze.cgColor
        return v
    }()
    private let coverImageView_Breeze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 14
        return iv
    }()
    private let coverPlaceholder_Breeze: UIView = UIView()
    private let coverPlaceholderIcon_Breeze: UIImageView = {
        let iv = UIImageView()
        let c = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv.image = UIImage(systemName: "camera.fill", withConfiguration: c)
        iv.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let coverPlaceholderLabel_Breeze: UILabel = {
        let l = UILabel()
        l.text = "Tap to add cover photo"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Breeze.textPlaceholder_Breeze
        return l
    }()
    
    /// 季节选择 Chips
    private var seasonChips_Breeze: [UIButton] = []
    
    /// 日期选择器
    private let datePicker_Breeze: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        dp.maximumDate = Date()
        return dp
    }()
    
    /// 地点输入框
    private let locationField_Breeze: UITextField = makeInputField_Breeze(placeholder_breeze: "Park or location name", icon_breeze: "mappin.circle.fill")
    
    /// 备注输入框（可选）
    private let noteField_Breeze: UITextField = makeInputField_Breeze(placeholder_breeze: "Add a note (optional)", icon_breeze: "text.bubble.fill")
    
    /// 保存按钮
    private let saveButton_Breeze: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Memory", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.layer.cornerRadius = 26
        btn.layer.shadowColor = ColorConfig_Breeze.primaryGradientStart_Breeze.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 14
        btn.layer.shadowOpacity = 0.36
        return btn
    }()
    private var saveGradient_Breeze: CAGradientLayer?
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        setupFormUI_Breeze()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshSaveGradient_Breeze()
    }
    
    // MARK: - UI 搭建
    
    private func setupFormUI_Breeze() {
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(contentStack_Breeze)
        
        scrollView_Breeze.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 30, right: 20))
            make.width.equalToSuperview().offset(-40)
        }
        
        // 顶部标题
        let titleLbl_breeze = UILabel()
        titleLbl_breeze.text = "New Camping Memory"
        titleLbl_breeze.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLbl_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        contentStack_Breeze.addArrangedSubview(titleLbl_breeze)
        
        // 封面选择
        buildCoverSection_Breeze()
        
        // 季节
        buildSeasonSection_Breeze()
        
        // 日期
        buildDateSection_Breeze()
        
        // 地点
        contentStack_Breeze.addArrangedSubview(makeSection_Breeze(title_breeze: "Park Location", content_breeze: locationField_Breeze))
        
        // 备注
        contentStack_Breeze.addArrangedSubview(makeSection_Breeze(title_breeze: "Note", content_breeze: noteField_Breeze))
        
        // 保存按钮
        contentStack_Breeze.addArrangedSubview(saveButton_Breeze)
        saveButton_Breeze.snp.makeConstraints { make in make.height.equalTo(52) }
        saveButton_Breeze.addTarget(self, action: #selector(handleSave_Breeze), for: .touchUpInside)
    }
    
    private func buildCoverSection_Breeze() {
        let section_breeze = UIView()
        let label_breeze = AlbumCreateSheet_Breeze.sectionLabel_Breeze(text_breeze: "Cover Photo")
        section_breeze.addSubview(label_breeze)
        section_breeze.addSubview(coverPickerView_Breeze)
        coverPickerView_Breeze.addSubview(coverImageView_Breeze)
        coverPickerView_Breeze.addSubview(coverPlaceholder_Breeze)
        coverPlaceholder_Breeze.addSubview(coverPlaceholderIcon_Breeze)
        coverPlaceholder_Breeze.addSubview(coverPlaceholderLabel_Breeze)
        
        label_breeze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        coverPickerView_Breeze.snp.makeConstraints { make in
            make.top.equalTo(label_breeze.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(160)
        }
        coverImageView_Breeze.snp.makeConstraints { make in make.edges.equalToSuperview() }
        coverPlaceholder_Breeze.snp.makeConstraints { make in make.center.equalToSuperview() }
        coverPlaceholderIcon_Breeze.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        coverPlaceholderLabel_Breeze.snp.makeConstraints { make in
            make.top.equalTo(coverPlaceholderIcon_Breeze.snp.bottom).offset(8)
            make.centerX.bottom.equalToSuperview()
        }
        coverImageView_Breeze.isHidden = true
        coverPickerView_Breeze.addTarget(self, action: #selector(handlePickCover_Breeze), for: .touchUpInside)
        contentStack_Breeze.addArrangedSubview(section_breeze)
    }
    
    private func buildSeasonSection_Breeze() {
        let section_breeze = UIView()
        let label_breeze = AlbumCreateSheet_Breeze.sectionLabel_Breeze(text_breeze: "Season")
        let stack_breeze = UIStackView()
        stack_breeze.axis = .horizontal
        stack_breeze.spacing = 10
        stack_breeze.distribution = .fillEqually
        section_breeze.addSubview(label_breeze)
        section_breeze.addSubview(stack_breeze)
        label_breeze.snp.makeConstraints { make in make.top.left.right.equalToSuperview() }
        stack_breeze.snp.makeConstraints { make in
            make.top.equalTo(label_breeze.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        for (idx_breeze, season_breeze) in Season_Breeze.allCases.enumerated() {
            let btn_breeze = UIButton(type: .system)
            btn_breeze.setTitle(season_breeze.rawValue, for: .normal)
            btn_breeze.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            btn_breeze.layer.cornerRadius = 12
            btn_breeze.tag = idx_breeze
            btn_breeze.addTarget(self, action: #selector(handleSeasonTap_Breeze(_:)), for: .touchUpInside)
            stack_breeze.addArrangedSubview(btn_breeze)
            seasonChips_Breeze.append(btn_breeze)
        }
        updateSeasonChips_Breeze()
        contentStack_Breeze.addArrangedSubview(section_breeze)
    }
    
    private func buildDateSection_Breeze() {
        let section_breeze = UIView()
        let label_breeze = AlbumCreateSheet_Breeze.sectionLabel_Breeze(text_breeze: "Date")
        let card_breeze = UIView()
        card_breeze.backgroundColor = .white
        card_breeze.layer.cornerRadius = 14
        card_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        card_breeze.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_breeze.layer.shadowRadius = 6
        card_breeze.layer.shadowOpacity = 0.08
        card_breeze.addSubview(datePicker_Breeze)
        section_breeze.addSubview(label_breeze)
        section_breeze.addSubview(card_breeze)
        label_breeze.snp.makeConstraints { make in make.top.left.right.equalToSuperview() }
        card_breeze.snp.makeConstraints { make in
            make.top.equalTo(label_breeze.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        datePicker_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        datePicker_Breeze.addTarget(self, action: #selector(handleDateChange_Breeze(_:)), for: .valueChanged)
        contentStack_Breeze.addArrangedSubview(section_breeze)
    }
    
    private func makeSection_Breeze(title_breeze: String, content_breeze: UIView) -> UIView {
        let section_breeze = UIView()
        let label_breeze = AlbumCreateSheet_Breeze.sectionLabel_Breeze(text_breeze: title_breeze)
        section_breeze.addSubview(label_breeze)
        section_breeze.addSubview(content_breeze)
        label_breeze.snp.makeConstraints { make in make.top.left.right.equalToSuperview() }
        content_breeze.snp.makeConstraints { make in
            make.top.equalTo(label_breeze.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        return section_breeze
    }
    
    private func refreshSaveGradient_Breeze() {
        guard !saveButton_Breeze.bounds.isEmpty else { return }
        saveGradient_Breeze?.removeFromSuperlayer()
        let gradient_breeze = UIColor.createPrimaryGradientLayer_Breeze(frame_Breeze: saveButton_Breeze.bounds)
        gradient_breeze.cornerRadius = saveButton_Breeze.layer.cornerRadius
        saveButton_Breeze.layer.insertSublayer(gradient_breeze, at: 0)
        saveGradient_Breeze = gradient_breeze
    }
    
    // MARK: - 样式
    
    private func updateSeasonChips_Breeze() {
        for (idx_breeze, chip_breeze) in seasonChips_Breeze.enumerated() {
            let isSelected_breeze = Season_Breeze.allCases[idx_breeze] == selectedSeason_Breeze
            chip_breeze.backgroundColor = isSelected_breeze
                ? ColorConfig_Breeze.primaryGradientStart_Breeze
                : .white
            chip_breeze.setTitleColor(isSelected_breeze ? .white : ColorConfig_Breeze.textSecondary_Breeze, for: .normal)
            chip_breeze.layer.borderWidth = isSelected_breeze ? 0 : 1
            chip_breeze.layer.borderColor = ColorConfig_Breeze.divider_Breeze.cgColor
        }
    }
    
    // MARK: - 事件
    
    @objc private func handlePickCover_Breeze() {
        MediaPickerHelper_Breeze.pickImage_Breeze(from: self) { [weak self] image_breeze in
            guard let self, let image_breeze else { return }
            self.pickedImage_Breeze = image_breeze
            self.coverImageView_Breeze.image = image_breeze
            self.coverImageView_Breeze.isHidden = false
            self.coverPlaceholder_Breeze.isHidden = true
        }
    }
    
    @objc private func handleSeasonTap_Breeze(_ sender: UIButton) {
        selectedSeason_Breeze = Season_Breeze.allCases[sender.tag]
        updateSeasonChips_Breeze()
    }
    
    @objc private func handleDateChange_Breeze(_ sender: UIDatePicker) {
        selectedDate_Breeze = sender.date
    }
    
    @objc private func handleSave_Breeze() {
        guard let image_breeze = pickedImage_Breeze else {
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Please add a cover photo")
            return
        }
        guard let path_breeze = MediaPickerHelper_Breeze.saveImageToDocuments_Breeze(image_breeze: image_breeze) else {
            Utils_Breeze.showError_Breeze(message_Breeze: "Failed to save photo")
            return
        }
        
        let location_breeze = locationField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let note_breeze = noteField_Breeze.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        UserViewModel_Breeze.shared_Breeze.addAlbumItem_Breeze(
            imagePath_breeze: path_breeze,
            season_breeze: selectedSeason_Breeze,
            date_breeze: selectedDate_Breeze,
            locationNote_breeze: location_breeze,
            userNote_breeze: note_breeze
        )
        Utils_Breeze.showSuccess_Breeze(message_Breeze: "Memory saved!")
        dismiss(animated: true) { [weak self] in self?.onComplete_Breeze?() }
    }
    
    // MARK: - 工厂
    
    private static func sectionLabel_Breeze(text_breeze: String) -> UILabel {
        let label_breeze = UILabel()
        label_breeze.text = text_breeze
        label_breeze.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }
    
    private static func makeInputField_Breeze(placeholder_breeze: String, icon_breeze: String) -> UITextField {
        let field_breeze = UITextField()
        field_breeze.font = UIFont.systemFont(ofSize: 14)
        field_breeze.textColor = ColorConfig_Breeze.textPrimary_Breeze
        field_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        field_breeze.backgroundColor = .white
        field_breeze.layer.cornerRadius = 14
        field_breeze.layer.shadowColor = ColorConfig_Breeze.shadowColor_Breeze.cgColor
        field_breeze.layer.shadowOffset = CGSize(width: 0, height: 2)
        field_breeze.layer.shadowRadius = 6
        field_breeze.layer.shadowOpacity = 0.08
        let container_breeze = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let config_breeze = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let iv_breeze = UIImageView(image: UIImage(systemName: icon_breeze, withConfiguration: config_breeze))
        iv_breeze.tintColor = ColorConfig_Breeze.primaryGradientStart_Breeze
        iv_breeze.contentMode = .scaleAspectFit
        iv_breeze.frame = CGRect(x: 14, y: 17, width: 18, height: 18)
        container_breeze.addSubview(iv_breeze)
        field_breeze.leftView = container_breeze
        field_breeze.leftViewMode = .always
        let attrs_breeze: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorConfig_Breeze.textPlaceholder_Breeze,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        field_breeze.attributedPlaceholder = NSAttributedString(string: placeholder_breeze, attributes: attrs_breeze)
        return field_breeze
    }
}

// MARK: - 相册 Section Header

class AlbumSectionHeader_Breeze: UICollectionReusableView {
    
    static let reuseId_Breeze = "AlbumSectionHeader_Breeze"
    
    private let titleLabel_Breeze: UILabel = {
        let label_breeze = UILabel()
        label_breeze.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_breeze.textColor = ColorConfig_Breeze.textSecondary_Breeze
        return label_breeze
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorConfig_Breeze.backgroundPrimary_Breeze
        addSubview(titleLabel_Breeze)
        titleLabel_Breeze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func configure_Breeze(title_breeze: String) {
        titleLabel_Breeze.text = title_breeze.uppercased()
    }
}
