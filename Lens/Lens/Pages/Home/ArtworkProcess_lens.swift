import UIKit
import SnapKit

// MARK: - 创作过程详情页

/// ArtworkProcess_Lens
/// 功能：展示单幅作品的完整创作时间线（笔触、调色、分层事件）
class ArtworkProcess_Lens: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var artworkId_Lens: Int = 0

    private var artwork_Lens: ArtworkModel_Lens?
    private var events_Lens: [CreationEvent_Lens] = []

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
        l.font = .systemFont(ofSize: 17, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()

    private let headerCard_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06).cgColor
        return v
    }()

    private let coverView_Lens = MediaDisplayView_Lens()
    private let statsLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.5)
        l.numberOfLines = 0
        return l
    }()

    private lazy var tableView_Lens: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.separatorStyle = .none
        t.dataSource = self
        t.delegate = self
        t.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        t.register(ProcessEventCell_Lens.self, forCellReuseIdentifier: ProcessEventCell_Lens.reuseId_Lens)
        return t
    }()

    private let addStepButton_Lens: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+ Add Step", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(hexstring_Lens: "#4D96FF")
        b.layer.cornerRadius = 26
        return b
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Lens: "#0D0D1A")
        setupUI_Lens()
        loadData_Lens()
    }

    private func setupUI_Lens() {
        view.addSubview(navBar_Lens)
        navBar_Lens.addSubview(backButton_Lens)
        navBar_Lens.addSubview(navTitleLabel_Lens)
        view.addSubview(headerCard_Lens)
        headerCard_Lens.addSubview(coverView_Lens)
        headerCard_Lens.addSubview(statsLabel_Lens)
        view.addSubview(tableView_Lens)
        view.addSubview(addStepButton_Lens)

        backButton_Lens.addTarget(self, action: #selector(backTapped_Lens), for: .touchUpInside)
        addStepButton_Lens.addTarget(self, action: #selector(addStepTapped_Lens), for: .touchUpInside)
        coverView_Lens.layer.cornerRadius = 12
        coverView_Lens.clipsToBounds = true

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
            $0.leading.trailing.equalToSuperview().inset(60)
        }
        headerCard_Lens.snp.makeConstraints {
            $0.top.equalTo(navBar_Lens.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        coverView_Lens.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(80)
        }
        statsLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(coverView_Lens.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
        tableView_Lens.snp.makeConstraints {
            $0.top.equalTo(headerCard_Lens.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        addStepButton_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(52)
        }
    }

    /// 加载作品与创作事件数据
    private func loadData_Lens() {
        artwork_Lens = StudioViewModel_Lens.shared_Lens.getArtwork_Lens(artworkId_Lens: artworkId_Lens)
        events_Lens = StudioViewModel_Lens.shared_Lens.getCreationTimeline_Lens(artworkId_Lens: artworkId_Lens)
        navTitleLabel_Lens.text = artwork_Lens?.title_Lens ?? "Process"
        coverView_Lens.configure_Lens(mediaPath_Lens: artwork_Lens?.coverMedia_Lens)
        statsLabel_Lens.text = "Created: \(artwork_Lens?.createdAt_Lens ?? "-")\n\(events_Lens.count) recorded events\nAuto-tracked strokes, colors & layers"
        let isUser_Lens = artwork_Lens?.isUserCreated_Lens == true
        addStepButton_Lens.isHidden = !isUser_Lens
        tableView_Lens.reloadData()
    }

    /// 添加自定义创作步骤（需登录）
    @objc private func addStepTapped_Lens() {
        let alert_Lens = UIAlertController(title: "Add Step", message: "Describe this creation step", preferredStyle: .alert)
        alert_Lens.addTextField { tf_Lens in
            tf_Lens.placeholder = "Step description"
            tf_Lens.textColor = .black
        }
        alert_Lens.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert_Lens.addAction(UIAlertAction(title: "Note", style: .default) { [weak self] _ in
            guard let self_Lens = self,
                  let detail_Lens = alert_Lens.textFields?.first?.text else { return }
            if StudioViewModel_Lens.shared_Lens.addCreationStep_Lens(
                artworkId_Lens: self_Lens.artworkId_Lens,
                type_Lens: .customNote_Lens,
                detail_Lens: detail_Lens
            ) {
                self_Lens.loadData_Lens()
                Load_Lens.showSuccess_Lens(message_Lens: "Step recorded!")
            }
        })
        alert_Lens.addAction(UIAlertAction(title: "Color", style: .default) { [weak self] _ in
            guard let self_Lens = self,
                  let detail_Lens = alert_Lens.textFields?.first?.text else { return }
            if StudioViewModel_Lens.shared_Lens.addCreationStep_Lens(
                artworkId_Lens: self_Lens.artworkId_Lens,
                type_Lens: .colorAdjust_Lens,
                detail_Lens: detail_Lens,
                fromColorHex_Lens: "#FFFFFF",
                toColorHex_Lens: "#C77DFF"
            ) {
                self_Lens.loadData_Lens()
                Load_Lens.showSuccess_Lens(message_Lens: "Step recorded!")
            }
        })
        present(alert_Lens, animated: true)
    }

    @objc private func backTapped_Lens() {
        Navigation_Lens.pop_Lens()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        events_Lens.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell_Lens = tableView.dequeueReusableCell(
            withIdentifier: ProcessEventCell_Lens.reuseId_Lens,
            for: indexPath
        ) as? ProcessEventCell_Lens else {
            return UITableViewCell()
        }
        cell_Lens.configure_Lens(event_Lens: events_Lens[indexPath.row], isLast_Lens: indexPath.row == events_Lens.count - 1)
        return cell_Lens
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
}

// MARK: - 创作事件 Cell

/// ProcessEventCell_Lens：创作过程时间线单元格
class ProcessEventCell_Lens: UITableViewCell {

    static let reuseId_Lens = "ProcessEventCell_Lens"

    private let timelineDot_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#7B2FF7")
        v.layer.cornerRadius = 5
        return v
    }()

    private let timelineLine_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08)
        return v
    }()

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#1C1C35")
        v.layer.cornerRadius = 14
        return v
    }()

    private let timeLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#4D96FF")
        return l
    }()

    private let typeLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let detailLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.55)
        l.numberOfLines = 0
        return l
    }()

    private let accessoryContainer_Lens: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var accessoryHeightConstraint_Lens: Constraint?

    private let strokeCanvas_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.04)
        v.layer.cornerRadius = 8
        v.isHidden = true
        return v
    }()

    private let colorSwatch_Lens: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(timelineDot_Lens)
        contentView.addSubview(timelineLine_Lens)
        contentView.addSubview(cardView_Lens)
        cardView_Lens.addSubview(timeLabel_Lens)
        cardView_Lens.addSubview(typeLabel_Lens)
        cardView_Lens.addSubview(detailLabel_Lens)
        cardView_Lens.addSubview(accessoryContainer_Lens)
        accessoryContainer_Lens.addSubview(strokeCanvas_Lens)
        accessoryContainer_Lens.addSubview(colorSwatch_Lens)

        timelineDot_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(18)
            $0.width.height.equalTo(10)
        }
        timelineLine_Lens.snp.makeConstraints {
            $0.centerX.equalTo(timelineDot_Lens)
            $0.top.equalTo(timelineDot_Lens.snp.bottom)
            $0.width.equalTo(2)
            $0.bottom.equalToSuperview()
        }
        cardView_Lens.snp.makeConstraints {
            $0.leading.equalTo(timelineDot_Lens.snp.trailing).offset(14)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        timeLabel_Lens.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(12)
        }
        typeLabel_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalTo(timeLabel_Lens.snp.bottom).offset(4)
        }
        detailLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(typeLabel_Lens.snp.bottom).offset(6)
        }
        accessoryContainer_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(detailLabel_Lens.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().inset(12)
            accessoryHeightConstraint_Lens = $0.height.equalTo(0).constraint
        }
        strokeCanvas_Lens.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        colorSwatch_Lens.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.height.equalTo(24)
        }
    }

    private var storedBrushPoints_Lens: [BrushPoint_Lens] = []

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        strokeCanvas_Lens.isHidden = true
        colorSwatch_Lens.isHidden = true
        accessoryContainer_Lens.isHidden = true
        accessoryHeightConstraint_Lens?.update(offset: 0)
        strokeCanvas_Lens.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        storedBrushPoints_Lens = []
    }

    /// 配置创作事件展示
    func configure_Lens(event_Lens: CreationEvent_Lens, isLast_Lens: Bool) {
        timeLabel_Lens.text = event_Lens.timestamp_Lens
        timelineLine_Lens.isHidden = isLast_Lens
        strokeCanvas_Lens.isHidden = true
        colorSwatch_Lens.isHidden = true
        accessoryContainer_Lens.isHidden = true
        accessoryHeightConstraint_Lens?.update(offset: 0)
        strokeCanvas_Lens.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        switch event_Lens.type_Lens {
        case .brushStroke_Lens:
            typeLabel_Lens.text = "Brush Stroke"
            detailLabel_Lens.text = event_Lens.detail_Lens
            if let points_Lens = event_Lens.brushPoints_Lens, !points_Lens.isEmpty {
                strokeCanvas_Lens.isHidden = false
                accessoryContainer_Lens.isHidden = false
                accessoryHeightConstraint_Lens?.update(offset: 48)
                storedBrushPoints_Lens = points_Lens
                setNeedsLayout()
            }
        case .colorAdjust_Lens:
            typeLabel_Lens.text = "Color Adjust"
            detailLabel_Lens.text = event_Lens.detail_Lens
            if let toHex_Lens = event_Lens.toColorHex_Lens {
                let fromHex_Lens = event_Lens.fromColorHex_Lens ?? "—"
                detailLabel_Lens.text = "\(event_Lens.detail_Lens)\n\(fromHex_Lens) → \(toHex_Lens)"
            }
            colorSwatch_Lens.isHidden = false
            accessoryContainer_Lens.isHidden = false
            accessoryHeightConstraint_Lens?.update(offset: 24)
            colorSwatch_Lens.backgroundColor = UIColor(hexstring_Lens: event_Lens.toColorHex_Lens ?? "#FFFFFF")
        case .layerAdd_Lens:
            typeLabel_Lens.text = "Layer Added"
            detailLabel_Lens.text = "\(event_Lens.detail_Lens) · \(event_Lens.layerName_Lens ?? "")"
        case .layerModify_Lens:
            typeLabel_Lens.text = "Layer Modified"
            detailLabel_Lens.text = "\(event_Lens.detail_Lens) · \(event_Lens.layerName_Lens ?? "")"
        case .acrylicTest_Lens:
            typeLabel_Lens.text = "Acrylic Test"
            detailLabel_Lens.text = event_Lens.detail_Lens
            colorSwatch_Lens.isHidden = false
            accessoryContainer_Lens.isHidden = false
            accessoryHeightConstraint_Lens?.update(offset: 24)
            colorSwatch_Lens.backgroundColor = UIColor(hexstring_Lens: event_Lens.toColorHex_Lens ?? "#C77DFF")
        case .lightAdjust_Lens:
            typeLabel_Lens.text = "Light Adjust"
            detailLabel_Lens.text = event_Lens.detail_Lens
            colorSwatch_Lens.isHidden = false
            accessoryContainer_Lens.isHidden = false
            accessoryHeightConstraint_Lens?.update(offset: 24)
            colorSwatch_Lens.backgroundColor = UIColor(hexstring_Lens: event_Lens.toColorHex_Lens ?? "#FFD93D")
        case .customNote_Lens:
            typeLabel_Lens.text = "Custom Note"
            detailLabel_Lens.text = event_Lens.detail_Lens
        }
    }

    /// 在迷你画布上绘制笔触轨迹
    private func drawStrokePath_Lens(points_Lens: [BrushPoint_Lens]) {
        let path_Lens = UIBezierPath()
        guard let first_Lens = points_Lens.first else { return }
        let w_Lens = strokeCanvas_Lens.bounds.width > 0 ? strokeCanvas_Lens.bounds.width : 260
        let h_Lens: CGFloat = 48
        path_Lens.move(to: CGPoint(x: first_Lens.x_Lens * w_Lens, y: first_Lens.y_Lens * h_Lens))
        for pt_Lens in points_Lens.dropFirst() {
            path_Lens.addLine(to: CGPoint(x: pt_Lens.x_Lens * w_Lens, y: pt_Lens.y_Lens * h_Lens))
        }
        let shape_Lens = CAShapeLayer()
        shape_Lens.path = path_Lens.cgPath
        shape_Lens.strokeColor = UIColor(hexstring_Lens: "#C77DFF").cgColor
        shape_Lens.fillColor = UIColor.clear.cgColor
        shape_Lens.lineWidth = 2
        shape_Lens.lineCap = .round
        strokeCanvas_Lens.layer.addSublayer(shape_Lens)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !strokeCanvas_Lens.isHidden, !storedBrushPoints_Lens.isEmpty {
            strokeCanvas_Lens.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            drawStrokePath_Lens(points_Lens: storedBrushPoints_Lens)
        }
    }
}
