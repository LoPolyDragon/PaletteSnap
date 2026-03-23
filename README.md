# PaletteSnap — Photo Color Palette Extractor

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-green.svg" alt="SwiftUI 5.0">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License">
</p>

A beautiful, production-ready iOS app that extracts dominant color palettes from photos using advanced k-means clustering algorithms. Perfect for designers, artists, home decor enthusiasts, and anyone who loves color.

## ✨ Features

### 🎨 Color Extraction
- **Advanced Algorithm**: Uses k-means clustering with the Accelerate framework for fast, accurate color extraction
- **Customizable**: Extract 3-10 dominant colors from any photo
- **Photo Sources**: Choose from camera or photo library
- **Real-time Processing**: Optimized for performance with downsampling and efficient pixel analysis

### 🌈 Color Details
- **Multiple Formats**: View colors in HEX, RGB, and HSL formats
- **Copy to Clipboard**: Tap any color value to copy with haptic feedback
- **Manual Adjustment**: Long-press colors to fine-tune with a color picker
- **Color Information**: Automatic luminance calculation for light/dark detection

### 🎭 Color Harmony
Explore color theory with eight harmony types:
- **Complementary**: Opposite colors on the wheel
- **Analogous**: Adjacent colors for harmony
- **Triadic**: Three evenly-spaced colors
- **Split Complementary**: Sophisticated variation
- **Tetradic**: Four balanced colors
- **Monochromatic**: Single hue variations
- **Shades**: Darker variations
- **Tints**: Lighter variations

### 💾 Palette Management
- **SwiftData Persistence**: Fast, reliable local storage
- **Folder Organization**: Create colorful folders to organize palettes
- **Search**: Quickly find palettes by name
- **Sorting**: Palettes sorted by creation date

### 📤 Export & Share
- **Beautiful Cards**: Export palettes as designed PNG cards
- **Social Media Ready**: 1080x1920 optimized for sharing
- **Save to Photos**: Direct save to photo library
- **Share Sheet**: Native iOS sharing

### ⚙️ Settings
- **Customizable Extraction**: Choose default color count
- **Haptic Feedback**: Toggle tactile feedback
- **Auto-save Images**: Optionally save source images
- **Data Management**: View stats and clear data

## 🏗 Architecture

### Clean MVVM Structure
```
PaletteSnap/
├── Models/
│   ├── ColorItem.swift           # Color data model with HSL conversion
│   ├── Palette.swift              # Palette model with relationships
│   └── PaletteFolder.swift        # Folder organization model
├── Views/
│   ├── ExtractTab.swift           # Color extraction interface
│   ├── PalettesTab.swift          # Palette library
│   ├── SettingsTab.swift          # App settings
│   ├── ColorDetailView.swift     # Color display component
│   ├── PaletteCardView.swift     # Palette card component
│   ├── SavePaletteSheet.swift    # Save dialog
│   ├── ColorPickerSheet.swift    # Color adjustment
│   ├── ColorHarmonySheet.swift   # Harmony explorer
│   └── MainTabView.swift          # Tab navigation
├── Services/
│   ├── ColorExtractionService.swift  # K-means clustering
│   ├── ColorHarmonyService.swift     # Color theory
│   ├── ImageExportService.swift      # Card generation
│   └── HapticFeedbackService.swift   # Tactile feedback
└── Extensions/
    ├── Color+Extensions.swift     # Color utilities
    ├── Image+Extensions.swift     # Image processing
    └── View+Extensions.swift      # SwiftUI helpers
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's modern persistence framework
- **Accelerate**: High-performance vector operations for k-means
- **CoreImage**: Image processing and manipulation
- **PhotosUI**: Photo picker interface
- **UIKit Integration**: Camera and share sheet

## 🚀 Getting Started

### Requirements
- Xcode 15.0+
- iOS 17.0+ deployment target
- Swift 5.9+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/PaletteSnap.git
cd PaletteSnap
```

2. Open the project:
```bash
open PaletteSnap.xcodeproj
```

3. Build and run:
- Select your target device or simulator
- Press `Cmd+R` to build and run
- Grant camera and photo library permissions when prompted

### No Dependencies
PaletteSnap is built entirely with native iOS frameworks. No CocoaPods, no Swift Package Manager dependencies, no third-party libraries. Just pure Swift and Apple frameworks.

## 🎯 Usage

### Extracting Colors
1. Tap the **Extract** tab
2. Choose **Choose from Library** or **Take Photo**
3. Select or capture your image
4. Colors are automatically extracted using k-means clustering
5. Long-press any color to fine-tune it

### Saving Palettes
1. After extraction, tap the menu icon (•••)
2. Select **Save Palette**
3. Name your palette
4. Optionally assign to a folder
5. Tap **Save**

### Exploring Harmonies
1. Extract colors from a photo
2. Tap **Explore Color Harmonies**
3. Select a base color
4. Choose a harmony type
5. Copy generated colors

### Exporting
1. Open a saved palette
2. Tap the share icon
3. Choose to save to Photos or share via iOS share sheet
4. Beautiful palette card is generated automatically

## 🎨 Color Extraction Algorithm

PaletteSnap uses k-means clustering for superior color extraction:

1. **Downsampling**: Images are downsampled to 200x200 for performance
2. **Pixel Extraction**: RGB values extracted from non-transparent pixels
3. **K-Means Clustering**: Pixels grouped into k clusters (user-configurable)
4. **Centroid Calculation**: Cluster centers become palette colors
5. **Sorting**: Colors sorted by cluster size (prominence)
6. **HSL Conversion**: Automatic conversion for color harmony calculations

## 🔧 Configuration

### Default Settings
- Color count: 6 colors
- Haptic feedback: Enabled
- Auto-save images: Enabled

### Customization
All settings can be adjusted in the Settings tab:
- Extract 3-10 colors per photo
- Toggle haptic feedback
- Choose whether to save source images

## 📱 Supported Devices

- **iPhone**: iOS 17.0+ (all models)
- **iPad**: iPadOS 17.0+ (all models)
- **Orientation**: Portrait and Landscape

## 🎭 Dark Mode

Full dark mode support with adaptive colors throughout the app. All UI elements automatically adjust for light and dark appearances.

## ♿️ Accessibility

- VoiceOver labels on all interactive elements
- Dynamic Type support
- High contrast mode compatible
- Haptic feedback for non-visual confirmation

## 🐛 Known Issues

None at this time. This is a production-ready 1.0 release.

## 🗺 Roadmap

Potential future enhancements:
- [ ] Import palettes from Adobe, Coolors, etc.
- [ ] Color naming using AI
- [ ] iCloud sync across devices
- [ ] macOS companion app
- [ ] Gradient generation
- [ ] Color accessibility checker (WCAG compliance)
- [ ] CSV/JSON export formats

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using SwiftUI and SwiftData
- Color theory algorithms based on established color wheel mathematics
- K-means implementation optimized with Apple's Accelerate framework

## 📧 Contact

For questions, suggestions, or issues:
- Open an issue on GitHub
- Email: your.email@example.com
- Twitter: @yourusername

## 🌟 Show Your Support

If you find PaletteSnap useful, please consider:
- ⭐️ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 📱 Sharing with fellow designers and artists

---

**PaletteSnap** — Extract beautiful color palettes from photos
© 2024 PaletteSnap. All rights reserved.
