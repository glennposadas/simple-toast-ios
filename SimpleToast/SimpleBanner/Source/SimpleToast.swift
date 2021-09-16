import UIKit

/**
 The protocol of `SimpleToast` view.
 */
protocol SimpleToastDelegate: AnyObject {
  func userdidTapToast(_ toast: SimpleToast, withData data: Any?)
}

func delay(_ seconds: Int, block: @escaping (()->())) {
  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: block)
}

/**
 A simple toast view used across the app. Currently shown in the navigation bar.
 */
class SimpleToast: UIView {
  
  // MARK: - Properties
  
  private(set) var label: UILabel!
  private(set) var data: Any?
  
  private(set) var tapGesture: UITapGestureRecognizer!
  private(set) var swipeGesture: UISwipeGestureRecognizer!
  
  weak var delegate: SimpleToastDelegate?
  
  private var windowRootController: UIViewController? {
    if #available(iOS 13.0, *) {
      let windowScene = UIApplication.shared
        .connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first
      
      if let window = windowScene as? UIWindowScene {
        return window.windows.last?.rootViewController
      }
      
      return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
    } else {
      return UIApplication.shared.keyWindow?.rootViewController
    }
  }
  
  // MARK: - Functions
  // MARK: Init
  
  /**
   Init function to generate a simple toast.
   
   Call `show` to show the toast..
   */
  init(text: String,
       textColor: UIColor = .white,
       bgColor: UIColor = .red,
       delegate: SimpleToastDelegate? = nil,
       data: Any? = nil) {
    super.init(frame: .zero)
    
    isUserInteractionEnabled = true
    
    self.data = data
    self.delegate = delegate
    
    setupViews()
    setupGestures()
    
    backgroundColor = bgColor
    label.text = text
    label.textColor = textColor
  }
  
  deinit {
    print("Deinit SimpleToast: \(self)")
  }
  
  // MARK: - Private
  // MARK: Selectors
  
  @objc
  private func didTapSelf() {
    print("Tap Toast!")
    delegate?.userdidTapToast(self, withData: data)
  }
  
  @objc
  private func didSwipe(_ gesture: UISwipeGestureRecognizer) {
    print("Swipe Toast!")
    delegate?.userdidTapToast(self, withData: data)
  }
  
  // MARK: Self setup
  
  private func setupViews() {
    label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.numberOfLines = 1
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(label)
    NSLayoutConstraint.activate([
      label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 25),
      label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25),
    ])
  }
  
  private func setupGestures() {
    tapGesture = UITapGestureRecognizer(target: self,
                                        action: #selector(didTapSelf))
    addGestureRecognizer(tapGesture)
    
    swipeGesture = UISwipeGestureRecognizer(target: self,
                                            action: #selector(didSwipe(_:)))
    addGestureRecognizer(swipeGesture)
  }
  
  // MARK: - Common Show Setup
  
  private func layoutForShow(animated: Bool, targetHeight: CGFloat) {
    guard let windowView = windowRootController?.view else {
      return
    }
    
    translatesAutoresizingMaskIntoConstraints = false
    windowView.addSubview(self)

    if animated {
      alpha = 0
    }
    
    NSLayoutConstraint.activate([
      self.heightAnchor.constraint(equalToConstant: targetHeight),
      self.leadingAnchor.constraint(equalTo: windowView.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: windowView.trailingAnchor),
      self.topAnchor.constraint(equalTo: windowView.safeAreaLayoutGuide.topAnchor)
    ])

    let iPxTopView = UIView()
    iPxTopView.backgroundColor = backgroundColor
    addSubview(iPxTopView)
    iPxTopView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      iPxTopView.heightAnchor.constraint(equalTo: self.heightAnchor),
      iPxTopView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      iPxTopView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      iPxTopView.bottomAnchor.constraint(equalTo: self.topAnchor)
    ])
  }
  
  private func show(animated: Bool) {
    if animated {
      fadeIn(duration: 0.3)
    }
  }
  
  private func hide(animated: Bool, duration: TimeInterval) {
    delay(Int(duration)) {
      if animated {
        self.fadeOut(duration: 0.3)
      }
      
      delay(2) {
        self.removeFromSuperview()
      }
    }
  }
  
  // MARK: - Public
  
  func show(
    animated: Bool = true,
    targetHeight: CGFloat = 50,
    duration: TimeInterval = 3.0
  ) {
    layoutForShow(animated: animated, targetHeight: targetHeight)
    show(animated: animated)
    hide(animated: animated, duration: duration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UIView Fade

extension UIView {
  /**
   Fade in a view with a duration
   
   - parameter duration: custom animation duration
   */
  func fadeIn(duration: TimeInterval = 2) {
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 1.0
    })
  }
  
  /**
   Fade out a view with a duration
   
   - parameter duration: custom animation duration
   */
  func fadeOut(duration: TimeInterval = 2) {
    UIView.animate(withDuration: duration, animations: {
      self.alpha = 0.0
    })
  }
}
