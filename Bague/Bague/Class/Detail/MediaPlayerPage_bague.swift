import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Bague 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Bague:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Bague:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Bague: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Bague: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Bague: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Bague: MediaType_Bague = .none_Bague

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Bague = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Bague: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Bague: AVPlayer?
    private var playerLayer_Bague: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Bague: Any?
    /// 是否处于播放状态
    private var isPlaying_Bague = false

    // MARK: - UI：黑色背景

    private let backgroundView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Bague: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Bague = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Bague), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Bague), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Bague: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Bague: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Bague: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Bague: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Bague = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Bague), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Bague: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Bague: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Bague()
        buildConstraints_Bague()
        bindGestures_Bague()
        loadMedia_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Bague()
    }

    deinit {
        cleanupPlayer_Bague()
    }

    // MARK: - UI 搭建

    private func buildUI_Bague() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Bague)

        // 图片容器
        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(imageView_Bague)
        scrollView_Bague.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Bague)
        videoContainerView_Bague.addSubview(playPauseButton_Bague)
        videoContainerView_Bague.addSubview(progressBg_Bague)
        progressBg_Bague.addSubview(progressFill_Bague)

        // 通用
        view.addSubview(loadingIndicator_Bague)
        view.addSubview(topBar_Bague)
        topBar_Bague.addSubview(closeButton_Bague)
        topBar_Bague.addSubview(mediaTypeLabel_Bague)
        view.addSubview(bottomHint_Bague)
    }

    private func buildConstraints_Bague() {
        backgroundView_Bague.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Bague.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Bague.frame = view.bounds

        videoContainerView_Bague.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Bague.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Bague.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Bague.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Bague = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Bague.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Bague.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Bague.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Bague.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Bague.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Bague.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Bague?.frame = videoContainerView_Bague.bounds
        updateImageLayout_Bague()
    }

    // MARK: - 手势

    private func bindGestures_Bague() {
        // 双击缩放（图片）
        let doubleTap_Bague = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Bague(_:)))
        doubleTap_Bague.numberOfTapsRequired = 2
        scrollView_Bague.addGestureRecognizer(doubleTap_Bague)

        // 单击关闭 / 视频播放切换
        let singleTap_Bague = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Bague))
        singleTap_Bague.numberOfTapsRequired = 1
        singleTap_Bague.require(toFail: doubleTap_Bague)
        scrollView_Bague.addGestureRecognizer(singleTap_Bague)

        // 视频区单击切换播放/暂停
        let videoTap_Bague = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Bague))
        videoContainerView_Bague.addGestureRecognizer(videoTap_Bague)

        // 下滑关闭
        let pan_Bague = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Bague(_:)))
        pan_Bague.delegate = self
        view.addGestureRecognizer(pan_Bague)

        // 播放/暂停按钮
        playPauseButton_Bague.addTarget(self, action: #selector(togglePlayPause_Bague), for: .touchUpInside)
        closeButton_Bague.addTarget(self, action: #selector(closeTapped_Bague), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Bague 和 isVideo_Bague 加载媒体
    private func loadMedia_Bague() {
        guard let path_Bague = mediaPath_Bague, !path_Bague.isEmpty else { showEmpty_Bague(); return }
        loadingIndicator_Bague.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Bague, let url_Bague = resolveVideoURL_Bague(path_Bague) {
            setupVideoPlayer_Bague(url_Bague: url_Bague)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Bague = resolveVideoURL_Bague(path_Bague) {
            setupVideoPlayer_Bague(url_Bague: url_Bague)
            return
        }

        // 图片加载流程
        resolvedType_Bague = .image_Bague
        loadImage_Bague(path_Bague: path_Bague)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Bague: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Bague(_ path_Bague: String) -> URL? {
        // Bundle 资源
        if let url_Bague = MediaDisplayView_Bague.bundleVideoURL_Bague(named: path_Bague) {
            return url_Bague
        }
        // Documents 目录视频文件
        let docs_Bague = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Bague in ["mp4", "mov", "m4v"] {
            let url_Bague = docs_Bague.appendingPathComponent("\(path_Bague).\(ext_Bague)")
            if FileManager.default.fileExists(atPath: url_Bague.path) { return url_Bague }
        }
        // 已带扩展名的文档目录文件
        let direct_Bague = docs_Bague.appendingPathComponent(path_Bague)
        if FileManager.default.fileExists(atPath: direct_Bague.path) { return direct_Bague }
        // 网络视频 URL
        if (path_Bague.hasPrefix("http://") || path_Bague.hasPrefix("https://")),
           let url_Bague = URL(string: path_Bague) {
            let ext_Bague = (path_Bague as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Bague) { return url_Bague }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Bague 策略对齐）
    /// - Parameter path_Bague: 媒体路径
    private func loadImage_Bague(path_Bague: String) {
        // SF Symbols
        if let img_Bague = UIImage(systemName: path_Bague) { applyImage_Bague(img_Bague); return }
        // Assets
        if let img_Bague = UIImage(named: path_Bague) { applyImage_Bague(img_Bague); return }
        // 网络
        if path_Bague.hasPrefix("http://") || path_Bague.hasPrefix("https://") {
            guard let url_Bague = URL(string: path_Bague) else { showEmpty_Bague(); return }
            imageView_Bague.kf.setImage(with: url_Bague, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Bague.stopAnimating()
                if case .success(let v_Bague) = result { self?.onImageLoaded_Bague(v_Bague.image) }
                else { self?.showEmpty_Bague() }
            }
            return
        }
        // Documents 文件名
        let docs_Bague = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Bague = docs_Bague.appendingPathComponent(path_Bague)
        if let img_Bague = UIImage(contentsOfFile: docURL_Bague.path) { applyImage_Bague(img_Bague); return }
        // 完整路径
        if let img_Bague = UIImage(contentsOfFile: path_Bague) { applyImage_Bague(img_Bague); return }
        showEmpty_Bague()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Bague: 视频文件 URL
    private func setupVideoPlayer_Bague(url_Bague: URL) {
        resolvedType_Bague = .video_Bague

        // 切换到视频容器
        scrollView_Bague.isHidden         = true
        videoContainerView_Bague.isHidden = false
        progressBg_Bague.isHidden         = false

        mediaTypeLabel_Bague.text = "Video"

        let player_Bague  = AVPlayer(url: url_Bague)
        self.player_Bague = player_Bague
        let layer_Bague   = AVPlayerLayer(player: player_Bague)
        layer_Bague.videoGravity  = .resizeAspect
        layer_Bague.frame         = videoContainerView_Bague.bounds
        layer_Bague.backgroundColor = UIColor.black.cgColor
        videoContainerView_Bague.layer.insertSublayer(layer_Bague, at: 0)
        playerLayer_Bague = layer_Bague

        // 视频就绪后淡入播放按钮
        player_Bague.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Bague = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Bague = player_Bague.addPeriodicTimeObserver(
            forInterval: interval_Bague,
            queue: .main
        ) { [weak self] time_Bague in
            self?.updateProgress_Bague(currentTime_Bague: time_Bague)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Bague),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Bague.currentItem
        )

        loadingIndicator_Bague.stopAnimating()
        player_Bague.play()
        isPlaying_Bague = true
        playPauseButton_Bague.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Bague.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Bague: AVPlayer 当前时间
    private func updateProgress_Bague(currentTime_Bague: CMTime) {
        guard let duration_Bague = player_Bague?.currentItem?.duration,
              duration_Bague.isNumeric, duration_Bague.seconds > 0 else { return }
        let progress_Bague = CGFloat(currentTime_Bague.seconds / duration_Bague.seconds)
        let totalW_Bague   = progressBg_Bague.bounds.width
        progressWidthCon_Bague?.update(offset: totalW_Bague * min(max(progress_Bague, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Bague() {
        player_Bague?.seek(to: .zero)
        isPlaying_Bague = false
        playPauseButton_Bague.isSelected = false
        progressWidthCon_Bague?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Bague() {
        if let token_Bague = timeObserverToken_Bague {
            player_Bague?.removeTimeObserver(token_Bague)
            timeObserverToken_Bague = nil
        }
        player_Bague?.removeObserver(self, forKeyPath: "status")
        player_Bague?.pause()
        player_Bague = nil
        playerLayer_Bague?.removeFromSuperlayer()
        playerLayer_Bague = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Bague = object as? AVPlayer,
              player_Bague.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Bague() }
    }

    // MARK: - 图片辅助

    private func applyImage_Bague(_ image_Bague: UIImage) {
        loadingIndicator_Bague.stopAnimating()
        imageView_Bague.image = image_Bague
        imageSize_Bague       = image_Bague.size
        mediaTypeLabel_Bague.text = "Photo"
        updateImageLayout_Bague()
    }

    private func onImageLoaded_Bague(_ image_Bague: UIImage) {
        imageSize_Bague = image_Bague.size
        mediaTypeLabel_Bague.text = "Photo"
        updateImageLayout_Bague()
    }

    private func showEmpty_Bague() {
        loadingIndicator_Bague.stopAnimating()
        imageView_Bague.image       = UIImage(systemName: "photo.slash")
        imageView_Bague.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Bague.contentMode = .center
    }

    private func updateImageLayout_Bague() {
        guard imageSize_Bague != .zero else {
            imageView_Bague.frame = view.bounds
            scrollView_Bague.contentSize = view.bounds.size
            return
        }
        let screenW_Bague = view.bounds.width
        let screenH_Bague = view.bounds.height
        let ratio_Bague   = imageSize_Bague.height / imageSize_Bague.width
        let imgH_Bague    = screenW_Bague * ratio_Bague
        let y_Bague       = max(0, (screenH_Bague - imgH_Bague) / 2)
        imageView_Bague.frame        = CGRect(x: 0, y: y_Bague, width: screenW_Bague, height: imgH_Bague)
        scrollView_Bague.contentSize = CGSize(width: screenW_Bague,
                                              height: max(imgH_Bague + y_Bague * 2, screenH_Bague))
        scrollView_Bague.zoomScale   = 1.0
        centerImageIfNeeded_Bague()
    }

    private func centerImageIfNeeded_Bague() {
        let offX_Bague = max(0, (scrollView_Bague.bounds.width  - scrollView_Bague.contentSize.width)  / 2)
        let offY_Bague = max(0, (scrollView_Bague.bounds.height - scrollView_Bague.contentSize.height) / 2)
        imageView_Bague.center = CGPoint(
            x: scrollView_Bague.contentSize.width  / 2 + offX_Bague,
            y: scrollView_Bague.contentSize.height / 2 + offY_Bague
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Bague(_ gesture_Bague: UITapGestureRecognizer) {
        guard resolvedType_Bague == .image_Bague else { return }
        if scrollView_Bague.zoomScale > 1.0 {
            scrollView_Bague.setZoomScale(1.0, animated: true)
        } else {
            let pt_Bague    = gesture_Bague.location(in: imageView_Bague)
            let rect_Bague  = zoomRect_Bague(scale_Bague: 2.5, center_Bague: pt_Bague)
            scrollView_Bague.zoom(to: rect_Bague, animated: true)
        }
    }

    @objc private func handleSingleTap_Bague() {
        guard resolvedType_Bague != .video_Bague,
              scrollView_Bague.zoomScale <= 1.01 else { return }
        dismissPage_Bague(velocity_Bague: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Bague() {
        togglePlayPause_Bague()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Bague() {
        guard let player_Bague = player_Bague else { return }
        if isPlaying_Bague {
            player_Bague.pause()
            isPlaying_Bague = false
            playPauseButton_Bague.isSelected = false
        } else {
            player_Bague.play()
            isPlaying_Bague = true
            playPauseButton_Bague.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Bague.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Bague else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Bague.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Bague() {
        dismissPage_Bague(velocity_Bague: 0)
    }

    @objc private func handlePan_Bague(_ gesture_Bague: UIPanGestureRecognizer) {
        guard scrollView_Bague.zoomScale <= 1.01 else { return }
        let translation_Bague = gesture_Bague.translation(in: view)
        let velocity_Bague    = gesture_Bague.velocity(in: view).y
        switch gesture_Bague.state {
        case .changed:
            let progress_Bague         = max(0, translation_Bague.y / view.bounds.height)
            backgroundView_Bague.alpha = max(0, 1 - progress_Bague * 1.5)
            topBar_Bague.alpha         = max(0, 1 - progress_Bague * 2)
            bottomHint_Bague.alpha     = max(0, 1 - progress_Bague * 2)
            let activeView_Bague: UIView = resolvedType_Bague == .video_Bague
                ? videoContainerView_Bague : scrollView_Bague
            activeView_Bague.transform = CGAffineTransform(
                translationX: translation_Bague.x * 0.3,
                y: max(0, translation_Bague.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Bague = translation_Bague.y > view.bounds.height * 0.25 || velocity_Bague > 900
            if shouldDismiss_Bague {
                dismissPage_Bague(velocity_Bague: velocity_Bague)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Bague.transform         = .identity
                    self.videoContainerView_Bague.transform = .identity
                    self.backgroundView_Bague.alpha  = 1
                    self.topBar_Bague.alpha           = 1
                    self.bottomHint_Bague.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Bague: 下拉速度（影响动画时长）
    private func dismissPage_Bague(velocity_Bague: CGFloat) {
        guard !isDismissing_Bague else { return }
        isDismissing_Bague = true
        player_Bague?.pause()
        let duration_Bague = velocity_Bague > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Bague, animations: {
            self.view.alpha = 0
            let activeView_Bague: UIView = self.resolvedType_Bague == .video_Bague
                ? self.videoContainerView_Bague : self.scrollView_Bague
            activeView_Bague.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Bague(scale_Bague: CGFloat, center_Bague: CGPoint) -> CGRect {
        let w_Bague = scrollView_Bague.bounds.width  / scale_Bague
        let h_Bague = scrollView_Bague.bounds.height / scale_Bague
        return CGRect(x: center_Bague.x - w_Bague / 2,
                      y: center_Bague.y - h_Bague / 2,
                      width: w_Bague, height: h_Bague)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Bague: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Bague }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Bague() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Bague: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Bague = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Bague.zoomScale <= 1.01 else { return false }
        let vel_Bague = pan_Bague.velocity(in: view)
        return abs(vel_Bague.y) > abs(vel_Bague.x) && vel_Bague.y > 0
    }
}
