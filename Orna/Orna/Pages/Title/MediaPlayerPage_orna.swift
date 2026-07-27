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
///   - 媒体路径与 MediaDisplayView_Orna 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Orna:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Orna:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Orna: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Orna: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Orna: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Orna: MediaType_Orna = .none_Orna

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Orna = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Orna: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Orna: AVPlayer?
    private var playerLayer_Orna: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Orna: Any?
    /// 是否处于播放状态
    private var isPlaying_Orna = false

    // MARK: - UI：黑色背景

    private let backgroundView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Orna: UIScrollView = {
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

    private let imageView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Orna = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Orna), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Orna), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Orna: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Orna: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Orna: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Orna: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Orna = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Orna), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Orna: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Orna: UILabel = {
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
        buildUI_Orna()
        buildConstraints_Orna()
        bindGestures_Orna()
        loadMedia_Orna()
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
        cleanupPlayer_Orna()
    }

    deinit {
        cleanupPlayer_Orna()
    }

    // MARK: - UI 搭建

    private func buildUI_Orna() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Orna)

        // 图片容器
        view.addSubview(scrollView_Orna)
        scrollView_Orna.addSubview(imageView_Orna)
        scrollView_Orna.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Orna)
        videoContainerView_Orna.addSubview(playPauseButton_Orna)
        videoContainerView_Orna.addSubview(progressBg_Orna)
        progressBg_Orna.addSubview(progressFill_Orna)

        // 通用
        view.addSubview(loadingIndicator_Orna)
        view.addSubview(topBar_Orna)
        topBar_Orna.addSubview(closeButton_Orna)
        topBar_Orna.addSubview(mediaTypeLabel_Orna)
        view.addSubview(bottomHint_Orna)
    }

    private func buildConstraints_Orna() {
        backgroundView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Orna.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Orna.frame = view.bounds

        videoContainerView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Orna.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Orna.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Orna = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Orna.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Orna.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Orna.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Orna.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Orna.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Orna?.frame = videoContainerView_Orna.bounds
        updateImageLayout_Orna()
    }

    // MARK: - 手势

    private func bindGestures_Orna() {
        // 双击缩放（图片）
        let doubleTap_Orna = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Orna(_:)))
        doubleTap_Orna.numberOfTapsRequired = 2
        scrollView_Orna.addGestureRecognizer(doubleTap_Orna)

        // 单击关闭 / 视频播放切换
        let singleTap_Orna = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Orna))
        singleTap_Orna.numberOfTapsRequired = 1
        singleTap_Orna.require(toFail: doubleTap_Orna)
        scrollView_Orna.addGestureRecognizer(singleTap_Orna)

        // 视频区单击切换播放/暂停
        let videoTap_Orna = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Orna))
        videoContainerView_Orna.addGestureRecognizer(videoTap_Orna)

        // 下滑关闭
        let pan_Orna = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Orna(_:)))
        pan_Orna.delegate = self
        view.addGestureRecognizer(pan_Orna)

        // 播放/暂停按钮
        playPauseButton_Orna.addTarget(self, action: #selector(togglePlayPause_Orna), for: .touchUpInside)
        closeButton_Orna.addTarget(self, action: #selector(closeTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Orna 和 isVideo_Orna 加载媒体
    private func loadMedia_Orna() {
        guard let path_Orna = mediaPath_Orna, !path_Orna.isEmpty else { showEmpty_Orna(); return }
        loadingIndicator_Orna.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Orna, let url_Orna = resolveVideoURL_Orna(path_Orna) {
            setupVideoPlayer_Orna(url_Orna: url_Orna)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Orna = resolveVideoURL_Orna(path_Orna) {
            setupVideoPlayer_Orna(url_Orna: url_Orna)
            return
        }

        // 图片加载流程
        resolvedType_Orna = .image_Orna
        loadImage_Orna(path_Orna: path_Orna)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Orna: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Orna(_ path_Orna: String) -> URL? {
        // 完整本地路径（如相册选择后复制到临时目录的视频）
        if FileManager.default.fileExists(atPath: path_Orna) {
            return URL(fileURLWithPath: path_Orna)
        }
        // Bundle 资源
        if let url_Orna = MediaDisplayView_Orna.bundleVideoURL_Orna(named: path_Orna) {
            return url_Orna
        }
        // Documents 目录视频文件
        let docs_Orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Orna in ["mp4", "mov", "m4v"] {
            let url_Orna = docs_Orna.appendingPathComponent("\(path_Orna).\(ext_Orna)")
            if FileManager.default.fileExists(atPath: url_Orna.path) { return url_Orna }
        }
        // 已带扩展名的文档目录文件
        let direct_Orna = docs_Orna.appendingPathComponent(path_Orna)
        if FileManager.default.fileExists(atPath: direct_Orna.path) { return direct_Orna }
        // 网络视频 URL
        if (path_Orna.hasPrefix("http://") || path_Orna.hasPrefix("https://")),
           let url_Orna = URL(string: path_Orna) {
            let ext_Orna = (path_Orna as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Orna) { return url_Orna }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Orna 策略对齐）
    /// - Parameter path_Orna: 媒体路径
    private func loadImage_Orna(path_Orna: String) {
        // SF Symbols
        if let img_Orna = UIImage(systemName: path_Orna) { applyImage_Orna(img_Orna); return }
        // Assets
        if let img_Orna = UIImage(named: path_Orna) { applyImage_Orna(img_Orna); return }
        // 网络
        if path_Orna.hasPrefix("http://") || path_Orna.hasPrefix("https://") {
            guard let url_Orna = URL(string: path_Orna) else { showEmpty_Orna(); return }
            imageView_Orna.kf.setImage(with: url_Orna, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Orna.stopAnimating()
                if case .success(let v_Orna) = result { self?.onImageLoaded_Orna(v_Orna.image) }
                else { self?.showEmpty_Orna() }
            }
            return
        }
        // Documents 文件名
        let docs_Orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Orna = docs_Orna.appendingPathComponent(path_Orna)
        if let img_Orna = UIImage(contentsOfFile: docURL_Orna.path) { applyImage_Orna(img_Orna); return }
        // 完整路径
        if let img_Orna = UIImage(contentsOfFile: path_Orna) { applyImage_Orna(img_Orna); return }
        showEmpty_Orna()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Orna: 视频文件 URL
    private func setupVideoPlayer_Orna(url_Orna: URL) {
        resolvedType_Orna = .video_Orna

        // 切换到视频容器
        scrollView_Orna.isHidden         = true
        videoContainerView_Orna.isHidden = false
        progressBg_Orna.isHidden         = false

        mediaTypeLabel_Orna.text = "Video"

        let player_Orna  = AVPlayer(url: url_Orna)
        self.player_Orna = player_Orna
        let layer_Orna   = AVPlayerLayer(player: player_Orna)
        layer_Orna.videoGravity  = .resizeAspect
        layer_Orna.frame         = videoContainerView_Orna.bounds
        layer_Orna.backgroundColor = UIColor.black.cgColor
        videoContainerView_Orna.layer.insertSublayer(layer_Orna, at: 0)
        playerLayer_Orna = layer_Orna

        // 视频就绪后淡入播放按钮
        player_Orna.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Orna = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Orna = player_Orna.addPeriodicTimeObserver(
            forInterval: interval_Orna,
            queue: .main
        ) { [weak self] time_Orna in
            self?.updateProgress_Orna(currentTime_Orna: time_Orna)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Orna),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Orna.currentItem
        )

        loadingIndicator_Orna.stopAnimating()
        player_Orna.play()
        isPlaying_Orna = true
        playPauseButton_Orna.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Orna.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Orna: AVPlayer 当前时间
    private func updateProgress_Orna(currentTime_Orna: CMTime) {
        guard let duration_Orna = player_Orna?.currentItem?.duration,
              duration_Orna.isNumeric, duration_Orna.seconds > 0 else { return }
        let progress_Orna = CGFloat(currentTime_Orna.seconds / duration_Orna.seconds)
        let totalW_Orna   = progressBg_Orna.bounds.width
        progressWidthCon_Orna?.update(offset: totalW_Orna * min(max(progress_Orna, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Orna() {
        player_Orna?.seek(to: .zero)
        isPlaying_Orna = false
        playPauseButton_Orna.isSelected = false
        progressWidthCon_Orna?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Orna() {
        if let token_Orna = timeObserverToken_Orna {
            player_Orna?.removeTimeObserver(token_Orna)
            timeObserverToken_Orna = nil
        }
        player_Orna?.removeObserver(self, forKeyPath: "status")
        player_Orna?.pause()
        player_Orna = nil
        playerLayer_Orna?.removeFromSuperlayer()
        playerLayer_Orna = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Orna = object as? AVPlayer,
              player_Orna.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Orna() }
    }

    // MARK: - 图片辅助

    private func applyImage_Orna(_ image_Orna: UIImage) {
        loadingIndicator_Orna.stopAnimating()
        imageView_Orna.image = image_Orna
        imageSize_Orna       = image_Orna.size
        mediaTypeLabel_Orna.text = "Photo"
        updateImageLayout_Orna()
    }

    private func onImageLoaded_Orna(_ image_Orna: UIImage) {
        imageSize_Orna = image_Orna.size
        mediaTypeLabel_Orna.text = "Photo"
        updateImageLayout_Orna()
    }

    private func showEmpty_Orna() {
        loadingIndicator_Orna.stopAnimating()
        imageView_Orna.image       = UIImage(systemName: "photo.slash")
        imageView_Orna.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Orna.contentMode = .center
    }

    private func updateImageLayout_Orna() {
        guard imageSize_Orna != .zero else {
            imageView_Orna.frame = view.bounds
            scrollView_Orna.contentSize = view.bounds.size
            return
        }
        let screenW_Orna = view.bounds.width
        let screenH_Orna = view.bounds.height
        let ratio_Orna   = imageSize_Orna.height / imageSize_Orna.width
        let imgH_Orna    = screenW_Orna * ratio_Orna
        let y_Orna       = max(0, (screenH_Orna - imgH_Orna) / 2)
        imageView_Orna.frame        = CGRect(x: 0, y: y_Orna, width: screenW_Orna, height: imgH_Orna)
        scrollView_Orna.contentSize = CGSize(width: screenW_Orna,
                                              height: max(imgH_Orna + y_Orna * 2, screenH_Orna))
        scrollView_Orna.zoomScale   = 1.0
        centerImageIfNeeded_Orna()
    }

    private func centerImageIfNeeded_Orna() {
        let offX_Orna = max(0, (scrollView_Orna.bounds.width  - scrollView_Orna.contentSize.width)  / 2)
        let offY_Orna = max(0, (scrollView_Orna.bounds.height - scrollView_Orna.contentSize.height) / 2)
        imageView_Orna.center = CGPoint(
            x: scrollView_Orna.contentSize.width  / 2 + offX_Orna,
            y: scrollView_Orna.contentSize.height / 2 + offY_Orna
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Orna(_ gesture_Orna: UITapGestureRecognizer) {
        guard resolvedType_Orna == .image_Orna else { return }
        if scrollView_Orna.zoomScale > 1.0 {
            scrollView_Orna.setZoomScale(1.0, animated: true)
        } else {
            let pt_Orna    = gesture_Orna.location(in: imageView_Orna)
            let rect_Orna  = zoomRect_Orna(scale_Orna: 2.5, center_Orna: pt_Orna)
            scrollView_Orna.zoom(to: rect_Orna, animated: true)
        }
    }

    @objc private func handleSingleTap_Orna() {
        guard resolvedType_Orna != .video_Orna,
              scrollView_Orna.zoomScale <= 1.01 else { return }
        dismissPage_Orna(velocity_Orna: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Orna() {
        togglePlayPause_Orna()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Orna() {
        guard let player_Orna = player_Orna else { return }
        if isPlaying_Orna {
            player_Orna.pause()
            isPlaying_Orna = false
            playPauseButton_Orna.isSelected = false
        } else {
            player_Orna.play()
            isPlaying_Orna = true
            playPauseButton_Orna.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Orna.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Orna else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Orna.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Orna() {
        dismissPage_Orna(velocity_Orna: 0)
    }

    @objc private func handlePan_Orna(_ gesture_Orna: UIPanGestureRecognizer) {
        guard scrollView_Orna.zoomScale <= 1.01 else { return }
        let translation_Orna = gesture_Orna.translation(in: view)
        let velocity_Orna    = gesture_Orna.velocity(in: view).y
        switch gesture_Orna.state {
        case .changed:
            let progress_Orna         = max(0, translation_Orna.y / view.bounds.height)
            backgroundView_Orna.alpha = max(0, 1 - progress_Orna * 1.5)
            topBar_Orna.alpha         = max(0, 1 - progress_Orna * 2)
            bottomHint_Orna.alpha     = max(0, 1 - progress_Orna * 2)
            let activeView_Orna: UIView = resolvedType_Orna == .video_Orna
                ? videoContainerView_Orna : scrollView_Orna
            activeView_Orna.transform = CGAffineTransform(
                translationX: translation_Orna.x * 0.3,
                y: max(0, translation_Orna.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Orna = translation_Orna.y > view.bounds.height * 0.25 || velocity_Orna > 900
            if shouldDismiss_Orna {
                dismissPage_Orna(velocity_Orna: velocity_Orna)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Orna.transform         = .identity
                    self.videoContainerView_Orna.transform = .identity
                    self.backgroundView_Orna.alpha  = 1
                    self.topBar_Orna.alpha           = 1
                    self.bottomHint_Orna.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Orna: 下拉速度（影响动画时长）
    private func dismissPage_Orna(velocity_Orna: CGFloat) {
        guard !isDismissing_Orna else { return }
        isDismissing_Orna = true
        player_Orna?.pause()
        let duration_Orna = velocity_Orna > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Orna, animations: {
            self.view.alpha = 0
            let activeView_Orna: UIView = self.resolvedType_Orna == .video_Orna
                ? self.videoContainerView_Orna : self.scrollView_Orna
            activeView_Orna.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Orna(scale_Orna: CGFloat, center_Orna: CGPoint) -> CGRect {
        let w_Orna = scrollView_Orna.bounds.width  / scale_Orna
        let h_Orna = scrollView_Orna.bounds.height / scale_Orna
        return CGRect(x: center_Orna.x - w_Orna / 2,
                      y: center_Orna.y - h_Orna / 2,
                      width: w_Orna, height: h_Orna)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Orna: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Orna }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Orna() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Orna: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Orna = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Orna.zoomScale <= 1.01 else { return false }
        let vel_Orna = pan_Orna.velocity(in: view)
        return abs(vel_Orna.y) > abs(vel_Orna.x) && vel_Orna.y > 0
    }
}
