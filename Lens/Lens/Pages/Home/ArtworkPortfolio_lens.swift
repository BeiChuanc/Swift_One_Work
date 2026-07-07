import UIKit
import SnapKit

// MARK: - 作品集页面

/// ArtworkPortfolio_Lens
/// 功能：展示用户全部作品，支持日期筛选与进入创作过程详情
class ArtworkPortfolio_Lens: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// 可选日期筛选 yyyy-MM-dd
    var filterDateKey_Lens: String?

    private var artworks_Lens: [ArtworkModel_Lens] = []

    private let navBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#161626")
        return v
    }()

    private let backButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.1)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Creation Timeline"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let createButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Lens = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        b.setImage(UIImage(systemName: "plus", withConfiguration: cfg_Lens), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        b.layer.cornerRadius = 18
        return b
    }()

    private let hintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Create your artwork and record every step"
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.4)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let filterBadge_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.15)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#4D96FF", alpha_Lens: 0.35).cgColor
        v.isHidden = true
        return v
    }()

    private let filterLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#4D96FF")
        return l
    }()

    private let clearFilterButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Clear", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 11, weight: .semibold)
        b.setTitleColor(UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.6), for: .normal)
        return b
    }()

    private let emptyStateView_Lens: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let emptyIconView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "paintpalette"))
        v.tintColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.6)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let emptyTitleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "No Artworks Yet"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let emptyDescLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Tap + to start your first Creation Timeline"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    /// 筛选条高度约束（隐藏时折叠为 0，避免列表上方空白）
    private var filterBadgeHeightConstraint_Lens: Constraint?

    private lazy var tableView_Lens: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorStyle = .none
        t.dataSource = self
        t.delegate = self
        t.register(ArtworkPortfolioCell_Lens.self, forCellReuseIdentifier: ArtworkPortfolioCell_Lens.reuseId_Lens)
        return t
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadData_Lens()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        setupBackgroundGlow_Lens()
        setupUI_Lens()
        reloadData_Lens()
    }

    /// 添加背景光晕装饰
    private func setupBackgroundGlow_Lens() {
        let glow_Lens = UIView()
        glow_Lens.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7", alpha_Lens: 0.12)
        glow_Lens.layer.cornerRadius = 120
        view.insertSubview(glow_Lens, at: 0)
        glow_Lens.snp.makeConstraints {
            $0.width.height.equalTo(240)
            $0.top.equalToSuperview().offset(80)
            $0.trailing.equalToSuperview().offset(60)
        }
    }

    private func setupUI_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        navBar_Lens.addSubview(createButton_Lens)
        view.addSubview(hintLabel_Lens)
        view.addSubview(filterBadge_Lens)
        filterBadge_Lens.addSubview(filterLabel_Lens)
        filterBadge_Lens.addSubview(clearFilterButton_Lens)
        view.addSubview(tableView_Lens)
        view.addSubview(emptyStateView_Lens)
        emptyStateView_Lens.addSubview(emptyIconView_Lens)
        emptyStateView_Lens.addSubview(emptyTitleLabel_Lens)
        emptyStateView_Lens.addSubview(emptyDescLabel_Lens)

        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        createButton_Lens.addTarget(self, action: #selector(createArtworkTapped_Lens), for: .touchUpInside)
        clearFilterButton_Lens.addTarget(self, action: #selector(clearFilterTapped_Lens), for: .touchUpInside)

        navBar_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(52)
        }
        backButton_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().inset(8)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Lens)
        }
        createButton_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(backButton_Lens)
            $0.width.height.equalTo(36)
        }
        hintLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        filterBadge_Lens.snp.makeConstraints {
            $0.top.equalTo(hintLabel_Lens.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            filterBadgeHeightConstraint_Lens = $0.height.equalTo(0).constraint
        }
        filterLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
        }
        clearFilterButton_Lens.snp.makeConstraints {
            $0.leading.equalTo(filterLabel_Lens.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
        tableView_Lens.snp.makeConstraints {
            $0.top.equalTo(filterBadge_Lens.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        emptyStateView_Lens.snp.makeConstraints {
            $0.center.equalTo(tableView_Lens)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        emptyIconView_Lens.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }
        emptyTitleLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(emptyIconView_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        emptyDescLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(emptyTitleLabel_Lens.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    /// 弹窗创建自定义作品（需登录，含封面上传）
    @objc private func createArtworkTapped_Lens() {
        let sheet_Lens = NewArtworkSheetVC_Lens()
        sheet_Lens.onCreate_Lens = { [weak self] title_Lens, coverImage_Lens in
            guard StudioViewModel_Lens.shared_Lens.createArtwork_Lens(
                title_Lens: title_Lens,
                coverImage_Lens: coverImage_Lens
            ) != nil else {
                Load_Lens.showWarning_Lens(message_Lens: "Failed to create artwork")
                return
            }
            self?.reloadData_Lens()
            Load_Lens.showSuccess_Lens(message_Lens: "Artwork created!")
        }
        sheet_Lens.modalPresentationStyle = .overFullScreen
        sheet_Lens.modalTransitionStyle = .crossDissolve
        present(sheet_Lens, animated: true)
    }

    @objc private func clearFilterTapped_Lens() {
        filterDateKey_Lens = nil
        reloadData_Lens()
    }

    private func reloadData_Lens() {
        var list_Lens = StudioViewModel_Lens.shared_Lens.getUserArtworks_Lens()
        if let dateKey_Lens = filterDateKey_Lens {
            list_Lens = list_Lens.filter {
                StudioViewModel_Lens.shared_Lens.artworkDateKey_Lens(for: $0) == dateKey_Lens
            }
            filterBadge_Lens.isHidden = false
            filterBadgeHeightConstraint_Lens?.update(offset: 28)
            filterLabel_Lens.text = "Filtered: \(dateKey_Lens)"
            emptyDescLabel_Lens.text = "No artworks recorded on this day"
        } else {
            filterBadge_Lens.isHidden = true
            filterBadgeHeightConstraint_Lens?.update(offset: 0)
            emptyDescLabel_Lens.text = "Tap + to start your first Creation Timeline"
        }
        artworks_Lens = list_Lens
        emptyStateView_Lens.isHidden = !artworks_Lens.isEmpty
        tableView_Lens.isHidden = artworks_Lens.isEmpty
        tableView_Lens.reloadData()
    }

    @objc private func backTapped_Lens() {
        Navigation_Lens.pop_Lens()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        artworks_Lens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Lens = tableView.dequeueReusableCell(
            withIdentifier: ArtworkPortfolioCell_Lens.reuseId_Lens,
            for: indexPath
        ) as? ArtworkPortfolioCell_Lens else {
            return UITableViewCell()
        }
        cell_Lens.configure_Lens(artwork_Lens: artworks_Lens[indexPath.row])
        return cell_Lens
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let artwork_Lens = artworks_Lens[indexPath.row]
        Navigation_Lens.toArtworkProcess_Lens(artworkId_Lens: artwork_Lens.artworkId_Lens)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        124
    }
}

// MARK: - 作品集 Cell

/// ArtworkPortfolioCell_Lens：作品集列表单元格
class ArtworkPortfolioCell_Lens: UITableViewCell {

    static let reuseId_Lens = "ArtworkPortfolioCell_Lens"

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        return v
    }()

    private let accentBar_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#4D96FF")
        v.layer.cornerRadius = 2
        return v
    }()

    private let thumbView_Lens = MediaDisplayView_Lens()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .bold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    private let metaLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.45)
        l.numberOfLines = 2
        return l
    }()

    private let arrowView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "chevron.right"))
        v.tintColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.3)
        v.contentMode = .scaleAspectFit
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(cardView_Lens)
        cardView_Lens.addSubview(accentBar_Lens)
        cardView_Lens.addSubview(thumbView_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(metaLabel_Lens)
        cardView_Lens.addSubview(arrowView_Lens)
        thumbView_Lens.layer.cornerRadius = 12
        thumbView_Lens.clipsToBounds = true

        cardView_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        }
        accentBar_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(3)
        }
        arrowView_Lens.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        thumbView_Lens.snp.makeConstraints {
            $0.leading.equalTo(accentBar_Lens.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(96)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(thumbView_Lens.snp.trailing).offset(12)
            $0.trailing.equalTo(arrowView_Lens.snp.leading).offset(-10)
            $0.top.equalToSuperview().offset(18)
        }
        metaLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(titleLabel_Lens)
            $0.trailing.equalTo(titleLabel_Lens)
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(6)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置作品信息
    func configure_Lens(artwork_Lens: ArtworkModel_Lens) {
        thumbView_Lens.configure_Lens(mediaPath_Lens: artwork_Lens.coverMedia_Lens)
        titleLabel_Lens.text = artwork_Lens.title_Lens
        metaLabel_Lens.text = "\(artwork_Lens.createdAt_Lens)\n\(artwork_Lens.totalStrokes_Lens) strokes · \(artwork_Lens.totalLayers_Lens) layers · \(artwork_Lens.events_Lens.count) steps"
    }
}

// MARK: - 新建作品弹窗

/// NewArtworkSheetVC_Lens
/// 核心作用：创建作品时收集标题与封面图
/// 设计思路：居中卡片弹窗 + 封面预览区 + 标题输入
class NewArtworkSheetVC_Lens: UIViewController {

    /// 创建成功回调（标题 + 封面图）
    var onCreate_Lens: ((String, UIImage) -> Void)?

    /// 已选封面
    private var selectedCoverImage_Lens: UIImage?

    private let maskView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.96)
        v.layer.cornerRadius = 20
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "New Artwork"
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    private let messageLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Enter a title and upload a cover"
        l.font = .systemFont(ofSize: 13)
        l.textColor = UIColor(hexstring_Lens: "#666666")
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private let coverButton_Lens: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = UIColor(hexstring_Lens: "#F2F2F7")
        b.layer.cornerRadius = 14
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(hexstring_Lens: "#D1D1D6").cgColor
        b.clipsToBounds = true
        return b
    }()

    private let coverPreview_Lens = MediaDisplayView_Lens()

    private let coverHintLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "Upload Cover"
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#7B2FF7")
        l.textAlignment = .center
        return l
    }()

    private let coverIcon_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        v.tintColor = UIColor(hexstring_Lens: "#7B2FF7")
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let titleField_Lens: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Artwork title"
        tf.font = .systemFont(ofSize: 15)
        tf.textColor = .black
        tf.backgroundColor = UIColor(hexstring_Lens: "#F2F2F7")
        tf.layer.cornerRadius = 12
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        tf.returnKeyType = .done
        return tf
    }()

    private let cancelButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Cancel", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.setTitleColor(UIColor(hexstring_Lens: "#666666"), for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#F2F2F7")
        b.layer.cornerRadius = 12
        return b
    }()

    private let createButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Create", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        b.layer.cornerRadius = 12
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Lens()
        bindActions_Lens()
    }

    /// 搭建弹窗 UI
    private func setupUI_Lens() {
        view.addSubview(maskView_Lens)
        view.addSubview(cardView_Lens)
        maskView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        cardView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(36)
        }

        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(messageLabel_Lens)
        cardView_Lens.addSubview(coverButton_Lens)
        coverButton_Lens.addSubview(coverPreview_Lens)
        coverButton_Lens.addSubview(coverIcon_Lens)
        coverButton_Lens.addSubview(coverHintLabel_Lens)
        cardView_Lens.addSubview(titleField_Lens)
        cardView_Lens.addSubview(cancelButton_Lens)
        cardView_Lens.addSubview(createButton_Lens)

        coverPreview_Lens.isHidden = true
        coverPreview_Lens.isUserInteractionEnabled = false
        coverPreview_Lens.layer.cornerRadius = 14
        coverPreview_Lens.clipsToBounds = true

        titleLabel_Lens.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        messageLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(titleLabel_Lens.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        coverButton_Lens.snp.makeConstraints {
            $0.top.equalTo(messageLabel_Lens.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        coverPreview_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        coverIcon_Lens.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-10)
            $0.width.height.equalTo(32)
        }
        coverHintLabel_Lens.snp.makeConstraints {
            $0.top.equalTo(coverIcon_Lens.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        titleField_Lens.snp.makeConstraints {
            $0.top.equalTo(coverButton_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        cancelButton_Lens.snp.makeConstraints {
            $0.top.equalTo(titleField_Lens.snp.bottom).offset(18)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().inset(18)
        }
        createButton_Lens.snp.makeConstraints {
            $0.top.equalTo(cancelButton_Lens)
            $0.leading.equalTo(cancelButton_Lens.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(cancelButton_Lens)
            $0.height.equalTo(44)
        }
    }

    /// 绑定按钮事件
    private func bindActions_Lens() {
        let maskTap_Lens = UITapGestureRecognizer(target: self, action: #selector(onCancelTap_Lens))
        maskView_Lens.addGestureRecognizer(maskTap_Lens)
        coverButton_Lens.addTarget(self, action: #selector(onCoverTap_Lens), for: .touchUpInside)
        cancelButton_Lens.addTarget(self, action: #selector(onCancelTap_Lens), for: .touchUpInside)
        createButton_Lens.addTarget(self, action: #selector(onCreateTap_Lens), for: .touchUpInside)
        titleField_Lens.delegate = self
    }

    /// 打开相册选择封面
    @objc private func onCoverTap_Lens() {
        MediaPickerHelper_Lens.pickImage_Lens(from: self) { [weak self] image_Lens in
            guard let self_Lens = self, let image_Lens else { return }
            self_Lens.selectedCoverImage_Lens = image_Lens
            self_Lens.coverPreview_Lens.isHidden = false
            self_Lens.coverIcon_Lens.isHidden = true
            self_Lens.coverHintLabel_Lens.isHidden = true
            self_Lens.coverPreview_Lens.configureWithImage_Lens(image_Lens: image_Lens)
        }
    }

    /// 关闭弹窗
    @objc private func onCancelTap_Lens() {
        dismiss(animated: true)
    }

    /// 校验并创建作品
    @objc private func onCreateTap_Lens() {
        let title_Lens = titleField_Lens.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title_Lens.isEmpty else {
            Load_Lens.showWarning_Lens(message_Lens: "Please enter a title")
            return
        }
        guard let coverImage_Lens = selectedCoverImage_Lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Please upload a cover image")
            return
        }
        dismiss(animated: true) { [weak self] in
            self?.onCreate_Lens?(title_Lens, coverImage_Lens)
        }
    }
}

extension NewArtworkSheetVC_Lens: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
