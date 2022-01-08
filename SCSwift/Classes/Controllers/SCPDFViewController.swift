//
//  SCPDFViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import CoreGraphics
import Alamofire
import PureLayout

extension CGPDFPage {
    /// original size of the PDF page.
    var originalPageRect: CGRect {
        switch rotationAngle {
        case 90, 270:
            let originalRect = getBoxRect(.mediaBox)
            let rotatedSize = CGSize(width: originalRect.height, height: originalRect.width)
            return CGRect(origin: originalRect.origin, size: rotatedSize)
        default:
            return getBoxRect(.mediaBox)
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class GridPreviewCell : UICollectionViewCell {
    
    var imgImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    var lblText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    func setupLayout() {
        backgroundColor = .clear
        
        addSubview(imgImage)
        imgImage.autoPinEdge(toSuperviewEdge: .top)
        imgImage.autoPinEdge(toSuperviewEdge: .left)
        imgImage.autoPinEdge(toSuperviewEdge: .right)
        imgImage.autoSetDimension(.height, toSize: frame.size.height-15)

        addSubview(lblText)
        lblText.autoPinEdge(.top, to: .bottom, of: imgImage)
        lblText.autoPinEdge(toSuperviewEdge: .left)
        lblText.autoPinEdge(toSuperviewEdge: .right)
        lblText.autoPinEdge(toSuperviewEdge: .bottom, withInset: 3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgImage.autoSetDimension(.height, toSize: frame.size.height-15)
    }
    
    func configure(media: SCMedia, pageNumber: Int) {
        imgImage.image = media.thumbnail
        lblText.text = "\(pageNumber)"
    }
}




public protocol SCPDFViewControllerDelegate : AnyObject {
    func pdfDidStartDownload()
    func pdfDidFinishDownload()
    func pdfDidUpdateDownload(progress: Float)
    func pdfDidLoad(page: Int, totalPages: Int)
}

open class SCPDFViewController: SCMediaViewController, SCMediaViewControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Xibs
    
    private var pageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private var pageController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        page.view.backgroundColor = .clear
        return page
    }()
    private var spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .lightGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private var gridContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .darkGray
        return view
    }()
    private var gridPreview: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        grid.isHidden = true
        grid.backgroundColor = .clear
        grid.register(GridPreviewCell.self, forCellWithReuseIdentifier: GridPreviewCell.identifier)
        return grid
    }()
    private var gridSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private var gridButton: SCButton = {
        let button = SCButton()
        button.setColors(mainBg: .darkGray, highlightedBg: .darkGray, standardTxt: .white, highlightedTxt: .white)
        button.backgroundColor = .darkGray
        button.setImage(UIImage(named: "ico_back"), for: .normal)
        button.imageView?.rotate(by: CGFloat.pi/2)
        return button
    }()
    
    // MARK: - Constraints
    
    private var cntGridContainerBottom: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    private var pages = [SCMedia]()
    private var nextIndex: Int = 0
    private var selectedIndex: Int = 0
    private var document: CGPDFDocument?
    public weak var pdfDelegate: SCPDFViewControllerDelegate?
    private let cellIdentifier = "cellIdentifier"
    private var didLoadThumbnails: Bool = false
    
    // MARK: - Initialization
    
    public convenience init(media: SCMedia, delegate: SCPDFViewControllerDelegate?) {
        self.init(media: media)
        
        self.pdfDelegate = delegate
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(netHex: 0xdddddd)
        setupLayout()
        setupPDF()
    }
    
    private func setupLayout() {
        view.insertSubview(pageContainer, at: 0)
        
        pageController.dataSource = self
        pageController.delegate = self
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        
        let blankController = UIViewController()
        blankController.view.backgroundColor = .clear
        pageController.setViewControllers([blankController], direction: .forward, animated: true, completion: nil)
        
        pageContainer.addSubview(pageController.view)
        addChild(pageController)
        
        view.addSubview(spinner)
        spinner.center = view.center
        spinner.startAnimating()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageContainer.frame = view.frame
        pageController.view.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: pageContainer.frame.size)
        
        spinner.center = view.center
    }
    
    // MARK: - UIPageViewController DataSource & Delegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let preview = viewController as? SCMediaViewController else {
            return nil
        }
        
        return self.viewController(at: preview.index+1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let preview = viewController as? SCMediaViewController else {
            return nil
        }
        
        return self.viewController(at: preview.index-1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            if let viewController = pageViewController.viewControllers?.first as? SCMediaViewController {
                selectedIndex = viewController.index
                pdfDelegate?.pdfDidLoad(page: viewController.index+1, totalPages: pages.count)
                gridPreview.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    // MARK: - SCMediaViewController Delegate
    
    func mediaDidTapView() {
        delegate?.mediaDidTapView()
    }
    
    func mediaDidDoubleTap() {
        delegate?.mediaDidDoubleTap()
    }
    
    func mediaDidFailLoad(media: SCMedia) {
        
    }
    
    // MARK: - PDF Methods
    
    private func setupPDF() {
        
        if let localUrl = media.localUrl, localUrl.fileExists {
            initializePDF(with: localUrl)
        } else if let remoteUrl = media.remoteUrl {
            initializePDF(with: remoteUrl)
        }
    }
    
    private func initializePDF(with url: URL) {
        if let data = Cache.shared.object(forKey: url.absoluteString) {
            self.loadPdf(fromData: data)
        } else {
            pdfDelegate?.pdfDidStartDownload()
            AF.request(url).responseData(completionHandler: { [weak self] (response) in
                self?.pdfDelegate?.pdfDidFinishDownload()
                guard let data = response.data, data.count > 0 else {
                    if let media = self?.media {
                        self?.delegate?.mediaDidFailLoad(media: media)
                    }
                    return
                }
                Cache.shared.setObject(data, forKey: url.absoluteString)
                self?.loadPdf(fromData: data)
            }).downloadProgress { [weak self] (progress) in
                self?.pdfDelegate?.pdfDidUpdateDownload(progress: Float(progress.fractionCompleted))
            }
        }
    }
    
    private func loadPdf(fromData data: Data) {
        
        if let provider = CGDataProvider(data: data as CFData) {
            self.document = CGPDFDocument(provider)
            if let document = self.document {
                for _ in 0..<document.numberOfPages {
                    self.pages.append(SCMedia())
                }
                self.setupGridPreview()
                self.getImagesFromPDF(at: 0, completion: { [weak self] in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        self?.spinner.stopAnimating()
                        if let index = self?.selectedIndex {
                            if let viewController = self?.viewController(at: index) {
                                self?.pageController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
                            }
                        }
                    })
                })
            }
        }
    }
    
    private func getThumbnailsFromPDF(completion: @escaping () -> Void) {
        
        var completedImages: Int = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            for i in 1..<(self.pages.count+1) {
                self.imageFromPDFPage(at: i, thumbnail: true, completion: { [weak self] (image) in
                    self?.pages[i-1].thumbnail = image
                    DispatchQueue.main.sync {
                        self?.gridPreview.reloadItems(at: [IndexPath(row: i-1, section: 0)])
                    }
                    completedImages += 1
                    if completedImages == self?.pages.count {
                        self?.didLoadThumbnails = true
                        completion()
                    }
                })
            }
        }
    }
    
    private func getImagesFromPDF(at index: Int, completion: @escaping () -> Void) {
        var indexes = [Int]()
        /*if index > 0 {
         if pages[index-1].image == nil {
         indexes.append(index-1)
         }
         }*/
        if pages[index].image == nil {
            indexes.append(index)
        }
        if index < (pages.count-2) {
            if pages[index+1].image == nil {
                indexes.append(index+1)
            }
            if pages[index+2].image == nil {
                indexes.append(index+2)
            }
        } else if index < (pages.count-1) {
            if pages[index+1].image == nil {
                indexes.append(index+1)
            }
        }
        
        if indexes.count == 0 {
            completion()
            return
        }
        
        var completedImages: Int = 0
        print("PDF INDEXES: \(indexes)")
        DispatchQueue.global(qos: .userInitiated).async {
            for index in indexes {
                self.imageFromPDFPage(at: index+1, thumbnail: false, completion: { [weak self] (image) in
                    self?.pages[index].image = image
                    completedImages += 1
                    if completedImages == indexes.count {
                        DispatchQueue.main.sync {
                            completion()
                        }
                    }
                })
            }
        }
    }
    
    private func imageFromPDFPage(at index: Int, thumbnail: Bool, completion: (UIImage?) -> Void) {
        guard let page = document?.page(at: index) else {
            completion(nil)
            return
        }
        
        let contentId = media.id ?? ""
        let imageId = "\(contentId)_\(index)"
        if let data = Cache.shared.object(forKey: imageId), thumbnail == true {
            let image = UIImage(data: data)
            completion(image)
            return
        }
        
        //var originalPagerect: CGFloat = 0.0
        var scalingConstant: CGFloat = 0.0
        var pdfScale: CGFloat = 0.0
        var scaledPageSize: CGSize = .zero
        var scaledPageRect: CGRect = .zero
        
        var originalPageRect = page.getBoxRect(.trimBox)
        if originalPageRect.origin.x < originalPageRect.size.width {
            originalPageRect = page.originalPageRect
        }
        var xTranslate = originalPageRect.origin.x
        
        if thumbnail {
            scalingConstant = 120
            pdfScale = min(scalingConstant/originalPageRect.width, scalingConstant/originalPageRect.height)
            scaledPageSize = CGSize(width: originalPageRect.width * pdfScale, height: originalPageRect.height * pdfScale)
            scaledPageRect = CGRect(origin: .zero, size: scaledPageSize)
            xTranslate = originalPageRect.origin.x * pdfScale
            
        } else {
            scalingConstant = originalPageRect.size.width
            pdfScale = 2
            scaledPageSize = CGSize(width: originalPageRect.width*pdfScale, height: originalPageRect.height*pdfScale)
            scaledPageRect = CGRect(origin: .zero, size: scaledPageSize)
            xTranslate = originalPageRect.origin.x*pdfScale
        }
        
        UIGraphicsBeginImageContextWithOptions(scaledPageSize, true, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            completion(nil)
            return
        }
        
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fill(scaledPageRect)
        
        context.saveGState()
        
        let rotationAngle: CGFloat
        switch page.rotationAngle {
        case 90:
            rotationAngle = 270
        //context.translateBy(x: 0, y: scaledPageSize.height)
        case 180:
            rotationAngle = 180
            context.translateBy(x: 0, y: scaledPageSize.height)
        case 270:
            rotationAngle = 90
            context.translateBy(x: scaledPageSize.width, y: scaledPageSize.height)
        default:
            rotationAngle = 0
            context.translateBy(x: -xTranslate, y: scaledPageSize.height)
        }
        
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: rotationAngle.degreesToRadians)
        
        // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
        context.scaleBy(x: pdfScale, y: pdfScale)
        context.drawPDFPage(page)
        context.restoreGState()
        
        defer { UIGraphicsEndImageContext() }
        guard let backgroundImage = UIGraphicsGetImageFromCurrentImageContext() else {
            completion(nil)
            return
        }
        
        if thumbnail == true {
            if let data = backgroundImage.jpegData(compressionQuality: 1.0) {
                Cache.shared.setObject(data, forKey: imageId)
            }
        }
        
        completion(backgroundImage)
    }
    
    // MARK: - UICollectionView DataSource & Delegate
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GridPreviewCell
        cell.configure(media: pages[indexPath.row], pageNumber: indexPath.row+1)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = viewController(at: indexPath.row) {
            pageController.setViewControllers([viewController], direction: .forward, animated: false, completion: nil)
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - UICollectionViewFlowLayout Delegate
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = collectionView.frame.size.height
        let width = height - 15
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Other Methods
    
    func setupGridPreview() {
        
        if pages.count == 0 {
            return
        }
        
        view.addSubview(gridContainer)
        gridContainer.autoPinEdge(.left, to: .left, of: view)
        gridContainer.autoPinEdge(.right, to: .right, of: view)
        gridContainer.autoSetDimension(.height, toSize: 95+UIView.safeArea.bottom)
        
        cntGridContainerBottom = NSLayoutConstraint(item: gridContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 95+UIView.safeArea.bottom)
        view.addConstraint(cntGridContainerBottom)
        
        gridPreview.dataSource = self
        gridPreview.delegate = self
        
        gridContainer.addSubview(gridPreview)
        gridPreview.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        gridPreview.autoSetDimension(.height, toSize: 95)
        
        gridSpinner.startAnimating()
        gridContainer.addSubview(gridSpinner)
        gridSpinner.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        gridSpinner.autoAlignAxis(toSuperviewAxis: .vertical)
        
        gridButton.addTarget(self, action: #selector(didTapGridButton), for: .touchUpInside)
        view.addSubview(gridButton)
        gridButton.autoPinEdge(.bottom, to: .top, of: gridContainer)
        gridButton.autoPinEdge(toSuperviewEdge: .right)
        gridButton.autoSetDimensions(to: CGSize(width: 50, height: 35))
        
        self.getThumbnailsFromPDF { [weak self] in
            DispatchQueue.main.sync {
                self?.gridSpinner.stopAnimating()
                self?.gridPreview.isHidden = false
                self?.gridPreview.collectionViewLayout.invalidateLayout()
                self?.gridPreview.reloadData()
            }
        }
    }
    
    open func viewController(at index: Int) -> SCMediaViewController? {
        
        if index < 0 || index >= pages.count {
            return nil
        }
        
        let page = pages[index]
        var viewController: SCMediaViewController?
        viewController = SCImageViewController(media: page)
        viewController?.delegate = self
        viewController?.index = index
        
        getImagesFromPDF(at: index) { [weak self] in
            if let viewControllers = self?.pageController.viewControllers {
                for viewController in viewControllers {
                    if let view = viewController as? SCImageViewController, let page = self?.pages[view.index] {
                        view.refresh(media: page)
                    }
                }
            }
        }
        
        return viewController
    }
    
    @objc func didTapGridButton() {
        
        let show = gridContainer.frame.origin.y >= view.frame.size.height
        gridButton.imageView?.rotate(by: show ? -(CGFloat.pi/2) : CGFloat.pi/2)
        cntGridContainerBottom.constant = show ? 0 : gridContainer.frame.size.height
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    public override func didSingleTap(gesture: UITapGestureRecognizer) {
        
        if gridContainer.superview == nil {
            didTap()
            return
        }
        
        let point = gesture.location(in: view)
        if point.y < (gridContainer.frame.origin.y-gridButton.frame.size.height) {
            didTap()
        }
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
