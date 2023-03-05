import UIKit
import Combine

class LoginViewController: UIViewController {
    
    private let loginVM = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "E-posta"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Şifre"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Giriş Yap", for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.isHidden = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        setupBindings()
    }
    
    
    func setupLayouts() {
        view.backgroundColor = .white
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(errorLabel)
        view.addSubview(activityIndicator)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),
            emailTextField.heightAnchor.constraint(equalToConstant: 30),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            passwordTextField.heightAnchor.constraint(equalToConstant: 30),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 30),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            errorLabel.widthAnchor.constraint(equalToConstant: 250),
            errorLabel.heightAnchor.constraint(equalToConstant: 60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 250),
            activityIndicator.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupBindings() {
        emailTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .map({ $0.isValidEmail() })
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)
        
        Publishers.CombineLatest(emailTextField.textPublisher, passwordTextField.textPublisher)
            .map({ LoginCredentials(email: $0, password: $1) })
            .assign(to: \.credentials, on: loginVM)
            .store(in: &cancellables)
    }
    
    @objc func loginTapped()  {
        Task.detached{
            await self.login()
        }
  }
    
    func login() async {
        activityIndicator.startAnimating()
        self.errorLabel.isHidden = (self.activityIndicator.isAnimating )
        self.errorLabel.isHidden = (self.activityIndicator.isAnimating )
        await loginVM.login()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.activityIndicator.stopAnimating()
                    self?.errorLabel.isHidden = (self?.activityIndicator.isAnimating ?? false)
                    self?.errorLabel.text = "Geçersiz e-posta veya şifre"
                }
            } receiveValue: { [weak self] user in
                self?.activityIndicator.stopAnimating()
                self?.errorLabel.isHidden = (self?.activityIndicator.isAnimating ?? false)
                self?.errorLabel.text = "Hoş geldiniz, \(user.username)"
        }
        .store(in: &cancellables)
    }
}


extension UITextField {
  var textPublisher: AnyPublisher<String, Never> {
  NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
    .compactMap({ ($0.object as? UITextField)?.text ?? "" })
    .eraseToAnyPublisher()
  }
}

extension String {
  func isValidEmail() -> Bool {
    return !self.isEmpty && self.contains("@") && self.contains(".")
  }
}
