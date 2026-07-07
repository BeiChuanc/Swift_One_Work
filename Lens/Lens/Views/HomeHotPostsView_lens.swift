import UIKit
import SnapKit

// MARK: - 首页热门帖子横向推荐

/// HomeHotPostsView_Lens
/// 功能：首页横向滚动展示热门帖子，按点赞数排序
/// 设计：封面图 + 标题 + 点赞数，点击跳转帖子详情
class HomeHotPostsView_Lens: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// 帖子点击回调
    var onPostSelected_Lens: ((TitleModel_Lens) -> Void)?

    private var posts_Lens: [TitleModel_Lens] = []
    private let cellId_Lens = "HomeHotPostCell_Lens"

    private let titleIconView_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "flame.fill"))
        v.tintColor = UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.85)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.text = "TRENDING POSTS"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.35)
        return l
    }()

    private lazy var collectionView_Lens: UICollectionView = {
        let layout_Lens = UICollectionViewFlowLayout()
        layout_Lens.scrollDirection = .horizontal
        layout_Lens.minimumLineSpacing = 12
        let cv_Lens = UICollectionView(frame: .zero, collectionViewLayout: layout_Lens)
        cv_Lens.backgroundColor = .clear
        cv_Lens.showsHorizontalScrollIndicator = false
        cv_Lens.clipsToBounds = false
        cv_Lens.dataSource = self
        cv_Lens.delegate = self
        cv_Lens.register(HomeHotPostCell_Lens.self, forCellWithReuseIdentifier: cellId_Lens)
        return cv_Lens
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleIconView_Lens)
        addSubview(titleLabel_Lens)
        addSubview(collectionView_Lens)
        titleIconView_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(4)
            $0.top.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(titleIconView_Lens.snp.trailing).offset(6)
            $0.centerY.equalTo(titleIconView_Lens)
        }
        collectionView_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleIconView_Lens.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(168)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 刷新热门帖子数据
    /// - Parameter posts_Lens: 按点赞数降序排列的帖子列表
    func reload_Lens(posts_Lens: [TitleModel_Lens]) {
        self.posts_Lens = posts_Lens
        collectionView_Lens.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts_Lens.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell_Lens = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellId_Lens,
            for: indexPath
        ) as? HomeHotPostCell_Lens else { return UICollectionViewCell() }
        cell_Lens.configure_Lens(post_Lens: posts_Lens[indexPath.item], rank_Lens: indexPath.item + 1)
        return cell_Lens
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPostSelected_Lens?(posts_Lens[indexPath.item])
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 132, height: 168)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 16)
    }
}

// MARK: - 热门帖子卡片 Cell

/// HomeHotPostCell_Lens
/// 功能：热门帖子横向卡片，展示封面、排名、标题与点赞
private class HomeHotPostCell_Lens: UICollectionViewCell {

    private let cardView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.06)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.08).cgColor
        v.clipsToBounds = true
        return v
    }()

    private let mediaView_Lens = MediaDisplayView_Lens()
    private let rankLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.backgroundColor = UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.9)
        l.layer.cornerRadius = 9
        l.clipsToBounds = true
        return l
    }()

    private let titleLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        return l
    }()

    private let likeIcon_Lens: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "heart.fill"))
        v.tintColor = UIColor(hexstring_Lens: "#FF6B6B", alpha_Lens: 0.85)
        v.contentMode = .scaleAspectFit
        return v
    }()

    private let likeLabel_Lens: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10, weight: .medium)
        l.textColor = UIColor(hexstring_Lens: "#FFFFFF", alpha_Lens: 0.55)
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Lens)
        cardView_Lens.addSubview(mediaView_Lens)
        cardView_Lens.addSubview(rankLabel_Lens)
        cardView_Lens.addSubview(titleLabel_Lens)
        cardView_Lens.addSubview(likeIcon_Lens)
        cardView_Lens.addSubview(likeLabel_Lens)

        cardView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        mediaView_Lens.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(96)
        }
        rankLabel_Lens.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(8)
            $0.width.height.equalTo(18)
        }
        titleLabel_Lens.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.equalTo(mediaView_Lens.snp.bottom).offset(8)
        }
        likeIcon_Lens.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.width.height.equalTo(10)
        }
        likeLabel_Lens.snp.makeConstraints {
            $0.leading.equalTo(likeIcon_Lens.snp.trailing).offset(4)
            $0.centerY.equalTo(likeIcon_Lens)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    /// 配置热门帖子卡片
    func configure_Lens(post_Lens: TitleModel_Lens, rank_Lens: Int) {
        titleLabel_Lens.text = post_Lens.title_Lens
        rankLabel_Lens.text = "\(rank_Lens)"
        likeLabel_Lens.text = formatLikeCount_Lens(post_Lens.likes_Lens)
        let mediaPath_Lens = post_Lens.titleMeidas_Lens.first
        let isVideo_Lens = mediaPath_Lens.map { isVideoPath_Lens($0) } ?? false
        mediaView_Lens.configure_Lens(mediaPath_Lens: mediaPath_Lens, isVideo_Lens: isVideo_Lens)
    }

    /// 判断是否为视频路径
    private func isVideoPath_Lens(_ path_Lens: String) -> Bool {
        let ext_Lens = (path_Lens as NSString).pathExtension.lowercased()
        return ["mp4", "mov", "m4v", "m3u8"].contains(ext_Lens)
    }

    /// 格式化点赞数
    private func formatLikeCount_Lens(_ count_Lens: Int) -> String {
        count_Lens >= 1000 ? String(format: "%.1fk", Double(count_Lens) / 1000.0) : "\(count_Lens)"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel_Lens.text = nil
        likeLabel_Lens.text = nil
    }
}
