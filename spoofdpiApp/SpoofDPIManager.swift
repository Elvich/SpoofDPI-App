import Combine
import Foundation
import SwiftUI

@MainActor
final class SpoofDPIManager: ObservableObject {
    @AppStorage("isOn") private var isOn: Bool = false
    
    @AppStorage("windowSize") private var windowSize = 1
    
    
    // MARK: - Constants
    private let appName = "SpoofDPI-Wrapper"
    private let binaryName = "spoofdpi-terminal"

    // MARK: - Paths (без standardizedFileURL!)
    private var appSupportDir: URL {
        let urls = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        return urls.first!.appendingPathComponent(appName, isDirectory: true)
    }

    private var binDir: URL {
        appSupportDir.appendingPathComponent("bin", isDirectory: true)
    }

    var spoofdpiURL: URL {
        binDir.appendingPathComponent(binaryName)
    }

    // MARK: - State
    @Published var isInstalled: Bool = false
    private var _isRunning: Bool = false
    @Published var logOutput: String = ""
    @Published var error: String? = nil

    private var process: Process?

    var isRunning: Bool {
        get { _isRunning }
        set {
            guard newValue != _isRunning else { return }
            if newValue {
                startProxy()
            } else {
                stopProxy()
            }
        }
    }

    // MARK: - Lifecycle
    init() {
        checkInstallation()
        isOn = _isRunning
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.stopProxy()
        }
    }

    private func checkInstallation() {
        isInstalled = FileManager.default.fileExists(atPath: spoofdpiURL.path)
        print("🔍 Проверка установки: \(spoofdpiURL.path)")
        print("   Файл существует: \(isInstalled)")
    }

    // MARK: - Install from Bundle
    func installIfNeeded() {
        guard !isInstalled else {
            print("⏭️ Уже установлен, пропускаем установку")
            return
        }
        print("📥 Начинаем установку spoofdpi...")

        let success = installFromBundle()
        isInstalled = success

        if !success {
            error = "Не удалось установить spoofdpi из ресурсов."
            print("❌ Установка не удалась")
        } else {
            print("✅ Установка завершена успешно")
        }
    }

    private func installFromBundle() -> Bool {
        guard
            let bundled = Bundle.main.url(
                forResource: "spoofdpi-terminal",
                withExtension: nil
            )
        else {
            print("❌ Бинарник 'spoofdpi-terminal' не найден в Resources!")
            return false
        }

        do {
            // Создаём директорию
            try FileManager.default.createDirectory(
                at: binDir,
                withIntermediateDirectories: true
            )

            // Удаляем старый, если есть
            if FileManager.default.fileExists(atPath: spoofdpiURL.path) {
                try FileManager.default.removeItem(at: spoofdpiURL)
            }

            // Копируем
            try FileManager.default.copyItem(at: bundled, to: spoofdpiURL)
            print("📦 Скопирован в: \(spoofdpiURL.path)")

            // 1. Удаляем quarantine
            let xattr = Process()
            xattr.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
            xattr.arguments = ["-d", "com.apple.quarantine", spoofdpiURL.path]
            try? xattr.run()
            xattr.waitUntilExit()
            print("🧹 Quarantine удалён")

            // 2. Делаем исполняемым
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: spoofdpiURL.path
            )
            print("🔐 Права 0o755 установлены")

            // 3. Подписываем
            let sign = Process()
            sign.executableURL = URL(fileURLWithPath: "/usr/bin/codesign")
            sign.arguments = ["--force", "--deep", "-s", "-", spoofdpiURL.path]
            try sign.run()
            sign.waitUntilExit()
            print("✍️  Ad-hoc подпись применена")

            return true

        } catch {
            print("💥 Ошибка при установке: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Run / Stop Proxy
    func startProxy() {
        guard isInstalled, !_isRunning else { return }

        let filePath = spoofdpiURL.path

        // Доп. проверки
        guard FileManager.default.fileExists(atPath: filePath) else {
            error = "Файл не найден: \(filePath)"
            isInstalled = false
            return
        }
        guard FileManager.default.isExecutableFile(atPath: filePath) else {
            error = "Файл не исполняемый: \(filePath)"
            return
        }

        print("🚀 Запуск spoofdpi из: \(filePath)")

        let process = Process()
        process.executableURL = spoofdpiURL
        process.arguments = [
            "--system-proxy",
            "--dns-ipv4-only",
            "--window-size=\(windowSize)",
            //"--policy=.*",
        ]
        self._isRunning = true
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            self.process = process

            self.logOutput = "Запущено...\n"
            
            isOn = true

            pipe.fileHandleForReading.readabilityHandler = {
                [weak self] handle in
                let data = handle.availableData
                if !data.isEmpty,
                    let output = String(data: data, encoding: .utf8)
                {
                    DispatchQueue.main.async {
                        self?.logOutput += output
                    }
                }
            }
        } catch {
            let error = "Ошибка запуска: \(error.localizedDescription)"
            print("💥 Не удалось запустить: \(error)")
            isOn = false
        }
    }

    func stopProxy() {
        guard let process = self.process, process.isRunning else { return }
        process.terminate()
        self.process = nil
        self._isRunning = false
        self.logOutput += "\n[Остановлено]\n"
        print("⏹️ Прокси остановлен")
        isOn = false
    }
}
