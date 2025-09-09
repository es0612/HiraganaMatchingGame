import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SettingsViewModel
    
    @State private var showResetAlert = false
    @State private var showPlayDataResetAlert = false
    @State private var showPlayDataResetSuccessAlert = false
    @State private var showTutorial = false
    
    let onDismiss: () -> Void
    
    init(modelContext: ModelContext, onDismiss: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: SettingsViewModel(modelContext: modelContext))
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                // 音声設定セクション
                SettingsSection(title: "音声設定") {
                    VStack(spacing: 16) {
                        HStack {
                            Toggle("効果音", isOn: $viewModel.soundEnabled)
                            Spacer(minLength: 50)
                            Toggle("BGM", isOn: $viewModel.musicEnabled)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("音量")
                                Spacer()
                                Text(viewModel.formattedSoundVolume())
                                    .foregroundStyle(.secondary)
                            }
                            Slider(value: $viewModel.soundVolume, in: 0...1)
                        }
                        
                    }
                }
                
                // ゲーム設定セクション
                SettingsSection(title: "ゲーム設定") {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("難易度")
                                .font(.subheadline)
                            Picker("難易度", selection: $viewModel.difficulty) {
                                ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                                    Text(difficulty.rawValue).tag(difficulty)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Toggle("ヒント表示", isOn: $viewModel.showHints)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("プレイ時間制限")
                                Spacer()
                                Text(viewModel.formattedPlaytimeLimit())
                                    .foregroundStyle(.secondary)
                            }
                            Stepper(
                                value: $viewModel.playtimeLimit,
                                in: 0...180,
                                step: 10
                            ) {
                                EmptyView()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("1セッションの問題数")
                                .font(.subheadline)
                            Picker("1セッションの問題数", selection: $viewModel.questionsPerSession) {
                                ForEach(QuestionsPerSession.allCases, id: \.self) { questionCount in
                                    Text(questionCount.displayName).tag(questionCount)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
                
                // リセット・その他セクション
                SettingsSection(title: "その他") {
                    VStack(spacing: 16) {
                        Button(action: {
                            showResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.circle.fill")
                                Text("設定をリセット")
                                Spacer()
                            }
                            .foregroundStyle(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showPlayDataResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("プレイデータをリセット")
                                Spacer()
                            }
                            .foregroundStyle(.orange)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: LicenseView()) {
                                HStack {
                                    Image(systemName: "doc.text")
                                    Text("ライセンス情報")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: AboutView()) {
                                HStack {
                                    Image(systemName: "info.circle")
                                    Text("アプリについて")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                showTutorial = true
                            }) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                    Text("チュートリアルを見る")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        onDismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("設定をリセット", isPresented: $showResetAlert) {
                Button("リセット", role: .destructive) {
                    viewModel.resetToDefaults()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("すべての設定をデフォルト値に戻しますか？この操作は取り消せません。")
            }
            .alert("プレイデータをリセット", isPresented: $showPlayDataResetAlert) {
                Button("リセット", role: .destructive) {
                    viewModel.resetPlayData()
                    showPlayDataResetSuccessAlert = true
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("レベル進行、獲得スター、キャラクター解放、実績データをすべて削除して最初からやり直しますか？この操作は取り消せません。")
            }
            .alert("リセット完了", isPresented: $showPlayDataResetSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("プレイデータが正常にリセットされました。アプリを再起動すると初期状態から開始できます。")
            }
            .sheet(isPresented: $showTutorial) {
                TutorialView(isPresented: $showTutorial)
                    .onAppear {
                        // 設定内チュートリアル開始時はBGM継続（設定で制御可能）
                    }
            }
        }
        .onAppear {
            viewModel.loadSettings()
        }
    }
}

// MARK: - SettingsSection Component
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - ライセンス情報画面
struct LicenseView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("オープンソースライセンス")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                LicenseItem(
                    title: "SwiftUI",
                    description: "Apple Inc.",
                    license: "Apple Software License Agreement"
                )
                
                LicenseItem(
                    title: "Swift Testing",
                    description: "Apple Inc.",
                    license: "Apache License 2.0"
                )
                
                Text("音声素材")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("このアプリで使用されている音声は、教育目的で作成されたオリジナル素材です。")
                    .font(.body)
                    .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("ライセンス情報")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicenseItem: View {
    let title: String
    let description: String
    let license: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(license)
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - アプリについて画面
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // アプリアイコン
                AppIconView(size: 100)
                
                VStack(spacing: 8) {
                    Text("ひらがなマッチングゲーム")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("バージョン 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("このアプリについて")
                        .font(.headline)
                    
                    Text("4歳から7歳のお子様を対象とした、楽しくひらがなを学習できるマッチングゲームです。")
                    
                    Text("特徴:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• 50文字のひらがな全てに対応")
                        Text("• 段階的なレベル進行システム")
                        Text("• スター獲得によるキャラクター解放")
                        Text("• 実績・バッジシステム")
                        Text("• アクセシビリティ対応")
                    }
                    .font(.body)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
            }
            .padding()
        }
        .navigationTitle("アプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView(modelContext: ModelContext(try! ModelContainer(for: UserSettings.self))) {
        print("Settings dismissed")
    }
}
