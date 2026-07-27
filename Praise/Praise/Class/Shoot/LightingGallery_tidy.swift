import Foundation
import UIKit
import SnapKit

// MARK: - 离线光影教学图库

/// 离线光影教学参考图库页
/// 核心作用：分类浏览"离线光影教学参考"卡片，无需联网即可查阅构图/光影教学示例
/// 设计思路：顶部渐变 Header + 分类横向 Chip 筛选 + 双列网格卡片列表，
///           点击卡片弹出底部详情 Sheet 展示完整教学文案
/// 关键属性/方法：
///   - selectedCategory_Tidy：当前选中的构图分类（nil 表示查看全部）
///   - loadReferences_Tidy：根据分类刷新图库数据源
class LightingGallery_Tidy: UIViewController {

    private var selectedCategory_Tidy: GridTemplateType_Tidy?
    private var references_Tidy: [LightingReference_Tidy] = []

    private let backButton_Tidy = BackButton_Tidy()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Lighting Gallery"
        lb.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        lb.textColor = .white
        return lb
    }()
    private let subtitleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.text = "Offline composition & lighting references"
        lb.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lb.textColor = UIColor.white.withAlphaComponent(0.75)
        return lb
    }()
    private let headerView_Tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.layer.cornerRadius = 26
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v
    }()
    private var headerGradient_Tidy: CAGradientLayer?

    private let chipScroll_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    private let chipStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        return sv
    }()
    private var chipButtons_Tidy: [UIButton] = []

    private var collectionView_Tidy: UICollectionView!
    private let idCard_Tidy = "LightingReferenceCard"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupHeader_Tidy()
        setupChips_Tidy()
        setupCollectionView_Tidy()
        loadReferences_Tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Tidy?.frame = headerView_Tidy.bounds
    }

    // MARK: - Header 搭建

    private func setupHeader_Tidy() {
        view.addSubview(headerView_Tidy)
        headerView_Tidy.addSubview(backButton_Tidy)
        headerView_Tidy.addSubview(titleLabel_Tidy)
        headerView_Tidy.addSubview(subtitleLabel_Tidy)

        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [
            ColorConfig_Tidy.primaryGradientStart_Tidy.cgColor,
            ColorConfig_Tidy.primaryGradientEnd_Tidy.cgColor
        ]
        grad_tidy.startPoint = CGPoint(x: 0, y: 0)
        grad_tidy.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        headerGradient_Tidy = grad_tidy

        headerView_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        backButton_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            make.width.height.equalTo(40)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(backButton_Tidy.snp.bottom).offset(14)
        }
        subtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(4)
        }
        // Header 底部随内容自适应，避免依赖尚未生效的 safeAreaInsets 固定高度
        headerView_Tidy.snp.makeConstraints { make in
            make.bottom.equalTo(subtitleLabel_Tidy.snp.bottom).offset(18)
        }
        backButton_Tidy.onTapped_Tidy = { [weak self] in
            Navigation_Tidy.pop_Tidy(from: self)
        }
    }

    // MARK: - 分类 Chip 搭建

    private func setupChips_Tidy() {
        view.addSubview(chipScroll_Tidy)
        chipScroll_Tidy.addSubview(chipStack_Tidy)

        chipScroll_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerView_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        chipStack_Tidy.snp.makeConstraints { make in
            make.top.bottom.equalTo(chipScroll_Tidy.contentLayoutGuide)
            make.leading.equalTo(chipScroll_Tidy.contentLayoutGuide).offset(16)
            make.trailing.equalTo(chipScroll_Tidy.contentLayoutGuide).offset(-16)
            make.height.equalTo(chipScroll_Tidy.frameLayoutGuide)
        }

        let allChip_tidy = makeChip_Tidy(title_tidy: "All", tag_tidy: -1)
        allChip_tidy.addTarget(self, action: #selector(onChipTapped_Tidy(_:)), for: .touchUpInside)
        chipStack_Tidy.addArrangedSubview(allChip_tidy)
        chipButtons_Tidy.append(allChip_tidy)

        for (index_tidy, category_tidy) in GridTemplateType_Tidy.allCases.enumerated() {
            let chip_tidy = makeChip_Tidy(title_tidy: category_tidy.displayName_Tidy, tag_tidy: index_tidy)
            chip_tidy.addTarget(self, action: #selector(onChipTapped_Tidy(_:)), for: .touchUpInside)
            chipStack_Tidy.addArrangedSubview(chip_tidy)
            chipButtons_Tidy.append(chip_tidy)
        }
        updateChipSelection_Tidy()
    }

    /// 创建单个分类 Chip 按钮
    private func makeChip_Tidy(title_tidy: String, tag_tidy: Int) -> UIButton {
        let btn_tidy = UIButton(type: .custom)
        btn_tidy.tag = tag_tidy
        btn_tidy.setTitle(title_tidy, for: .normal)
        btn_tidy.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_tidy.contentEdgeInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        btn_tidy.layer.cornerRadius = 15
        return btn_tidy
    }

    /// 刷新分类 Chip 选中态样式
    private func updateChipSelection_Tidy() {
        for btn_tidy in chipButtons_Tidy {
            let selected_tidy = (btn_tidy.tag == -1 && selectedCategory_Tidy == nil)
                || (btn_tidy.tag >= 0 && btn_tidy.tag < GridTemplateType_Tidy.allCases.count
                    && GridTemplateType_Tidy.allCases[btn_tidy.tag] == selectedCategory_Tidy)
            btn_tidy.backgroundColor = selected_tidy ? ColorConfig_Tidy.tidyMint_Tidy : .white
            btn_tidy.setTitleColor(selected_tidy ? .white : ColorConfig_Tidy.textSecondary_Tidy, for: .normal)
            btn_tidy.layer.borderWidth = selected_tidy ? 0 : 1
            btn_tidy.layer.borderColor = ColorConfig_Tidy.divider_Tidy.cgColor
        }
    }

    @objc private func onChipTapped_Tidy(_ sender: UIButton) {
        selectedCategory_Tidy = sender.tag == -1 ? nil : GridTemplateType_Tidy.allCases[sender.tag]
        updateChipSelection_Tidy()
        sender.animatePulse_Tidy()
        loadReferences_Tidy()
    }

    // MARK: - 网格搭建

    private func setupCollectionView_Tidy() {
        let layout_tidy = UICollectionViewCompositionalLayout { _, _ in
            let item_tidy = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)
            ))
            item_tidy.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
            let group_tidy = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(168)),
                subitems: [item_tidy, item_tidy]
            )
            let section_tidy = NSCollectionLayoutSection(group: group_tidy)
            section_tidy.contentInsets = .init(top: 12, leading: 10, bottom: 24, trailing: 10)
            section_tidy.interGroupSpacing = 12
            return section_tidy
        }

        collectionView_Tidy = UICollectionView(frame: .zero, collectionViewLayout: layout_tidy)
        collectionView_Tidy.backgroundColor = .clear
        collectionView_Tidy.showsVerticalScrollIndicator = false
        collectionView_Tidy.delegate = self
        collectionView_Tidy.dataSource = self
        collectionView_Tidy.register(LightingReferenceCard_Tidy.self, forCellWithReuseIdentifier: idCard_Tidy)

        view.addSubview(collectionView_Tidy)
        collectionView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(chipScroll_Tidy.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 根据当前选中分类刷新图库数据源
    private func loadReferences_Tidy() {
        references_Tidy = ShootViewModel_Tidy.shared_Tidy.getLightingReferences_Tidy(category_tidy: selectedCategory_Tidy)
        collectionView_Tidy.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension LightingGallery_Tidy: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        references_Tidy.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCard_Tidy, for: indexPath) as! LightingReferenceCard_Tidy
        cell.configure_Tidy(reference_tidy: references_Tidy[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetail_Tidy(reference_tidy: references_Tidy[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.animateSlideInFromBottom_Tidy(
            offset_Tidy: 22, delay_Tidy: Double(indexPath.item % 6) * AnimationConfig_Tidy.delayShort_Tidy
        )
    }

    /// 弹出教学参考详情底部 Sheet
    private func showDetail_Tidy(reference_tidy: LightingReference_Tidy) {
        let sheet_tidy = LightingDetailSheet_Tidy(reference_tidy: reference_tidy)
        if let sheetPC_tidy = sheet_tidy.sheetPresentationController {
            sheetPC_tidy.detents = [.medium()]
            sheetPC_tidy.prefersGrabberVisible = false
            sheetPC_tidy.preferredCornerRadius = 24
        }
        Navigation_Tidy.present_Tidy(viewController: sheet_tidy, from: self)
    }
}

// MARK: - 教学参考卡片 Cell

/// 离线教学参考卡片单元格
/// 功能：以分类主题色渐变 + 占位图标 + 标题展示单条教学参考
class LightingReferenceCard_Tidy: UICollectionViewCell {

    private let cardView_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()
    private var gradLayer_Tidy: CAGradientLayer?
    private let iconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor.white.withAlphaComponent(0.9)
        return iv
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lb.textColor = .white
        lb.numberOfLines = 2
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI_Tidy()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Tidy?.frame = cardView_Tidy.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        gradLayer_Tidy?.removeFromSuperlayer()
        gradLayer_Tidy = nil
    }

    private func setupUI_Tidy() {
        contentView.addSubview(cardView_Tidy)
        cardView_Tidy.addSubview(iconView_Tidy)
        cardView_Tidy.addSubview(titleLabel_Tidy)
        cardView_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        iconView_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    /// 配置卡片内容：按分类主题色渐变背景 + 占位图标 + 标题
    /// 参数：
    /// - reference_tidy: 教学参考卡片数据
    func configure_Tidy(reference_tidy: LightingReference_Tidy) {
        gradLayer_Tidy?.removeFromSuperlayer()
        let color_tidy = reference_tidy.category_Tidy.themeColor_Tidy
        let grad_tidy = CAGradientLayer()
        grad_tidy.colors = [color_tidy.cgColor, color_tidy.withAlphaComponent(0.7).cgColor]
        grad_tidy.startPoint = CGPoint(x: 0, y: 0)
        grad_tidy.endPoint   = CGPoint(x: 1, y: 1)
        cardView_Tidy.layer.insertSublayer(grad_tidy, at: 0)
        gradLayer_Tidy = grad_tidy

        iconView_Tidy.image = UIImage(systemName: reference_tidy.iconName_Tidy,
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium))
        titleLabel_Tidy.text = reference_tidy.title_Tidy
    }
}

// MARK: - 教学参考详情弹窗

/// 离线教学参考详情底部弹窗
/// 功能：展示单条参考卡片的完整教学说明文案
class LightingDetailSheet_Tidy: UIViewController {

    private let reference_Tidy: LightingReference_Tidy

    private let dragBar_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Tidy: "#CBD5E0")
        v.layer.cornerRadius = 2.5
        return v
    }()
    private let iconBg_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 34
        return v
    }()
    private let iconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let categoryLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb.textAlignment = .center
        lb.clipsToBounds = true
        return lb
    }()
    private let titleLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb.textAlignment = .center
        lb.numberOfLines = 2
        return lb
    }()
    private let descriptionLabel_Tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textSecondary_Tidy
        lb.numberOfLines = 0
        lb.textAlignment = .center
        return lb
    }()

    /// 初始化
    /// 参数：
    /// - reference_tidy: 待展示的教学参考卡片数据
    init(reference_tidy: LightingReference_Tidy) {
        self.reference_Tidy = reference_tidy
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("不支持 Storyboard 初始化") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI_Tidy()
        configure_Tidy()
    }

    private func setupUI_Tidy() {
        view.addSubview(dragBar_Tidy)
        view.addSubview(iconBg_Tidy)
        iconBg_Tidy.addSubview(iconView_Tidy)
        view.addSubview(categoryLabel_Tidy)
        view.addSubview(titleLabel_Tidy)
        view.addSubview(descriptionLabel_Tidy)

        dragBar_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }
        iconBg_Tidy.snp.makeConstraints { make in
            make.top.equalTo(dragBar_Tidy.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(68)
        }
        iconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        categoryLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Tidy.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        titleLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(28)
        }
        descriptionLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    /// 配置详情内容与主题色
    private func configure_Tidy() {
        let color_tidy = reference_Tidy.category_Tidy.themeColor_Tidy
        iconBg_Tidy.backgroundColor = color_tidy
        iconView_Tidy.image = UIImage(systemName: reference_Tidy.iconName_Tidy,
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .medium))
        categoryLabel_Tidy.text = "  \(reference_Tidy.category_Tidy.displayName_Tidy)  "
        categoryLabel_Tidy.textColor = color_tidy
        categoryLabel_Tidy.backgroundColor = color_tidy.withAlphaComponent(0.10)
        categoryLabel_Tidy.layer.cornerRadius = 10
        titleLabel_Tidy.text = reference_Tidy.title_Tidy
        descriptionLabel_Tidy.text = reference_Tidy.description_Tidy
    }
}
