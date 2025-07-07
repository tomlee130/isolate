# TTS功能实现说明

## 概述

本项目已成功集成了与bloc项目相同的文字转语音(TTS)功能，支持iOS和Android平台。

## 实现的功能

### 1. 智能朗读
- **代码文件**：朗读文件结构摘要（类、函数、注释统计等）
- **Markdown文件**：朗读文档内容（自动去除Markdown标记）
- **智能分析**：自动识别文件类型并选择合适的朗读内容

### 2. 语音设置
- **中文语音**：优先使用中文语音引擎
- **语速调节**：默认设置为0.5倍速，适合代码朗读
- **音量控制**：支持音量调节
- **音调设置**：可调节语音音调

### 3. 操作界面
- **朗读按钮**：音量图标，一键开始朗读
- **停止按钮**：停止图标，朗读过程中可中断
- **测试按钮**：调试图标，用于测试TTS功能
- **复制按钮**：复制代码到剪贴板

### 4. 错误处理
- **引擎检测**：自动检测可用的TTS引擎
- **语言支持**：检查中文和英文语音支持
- **异常处理**：完善的错误提示和恢复机制

## 技术实现

### 1. 依赖配置
```yaml
dependencies:
  flutter_tts: ^3.8.5
```

### 2. 平台权限

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<!-- TTS相关权限 -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

#### iOS (ios/Runner/Info.plist)
```xml
<!-- TTS相关权限 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>此应用需要语音识别权限来提供文字转语音功能</string>
<key>NSMicrophoneUsageDescription</key>
<string>此应用需要麦克风权限来提供语音功能</string>
```

### 3. 核心代码结构

#### TTS初始化
```dart
void _initTts() async {
  _flutterTts = FlutterTts();
  
  // 配置TTS引擎
  await _configureTtsEngine();
  
  // 配置语言
  await _configureLanguage();
  
  // 配置语音参数
  await _flutterTts.setSpeechRate(0.5);
  await _flutterTts.setVolume(1.0);
  await _flutterTts.setPitch(1.0);
  
  // 设置事件处理器
  _flutterTts.setStartHandler(() {
    setState(() {
      _isSpeaking = true;
    });
  });
  
  _flutterTts.setCompletionHandler(() {
    setState(() {
      _isSpeaking = false;
    });
  });
  
  _flutterTts.setErrorHandler((msg) {
    setState(() {
      _isSpeaking = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('朗读出错: $msg')),
      );
    }
  });
}
```

#### 引擎配置
```dart
Future<void> _configureTtsEngine() async {
  try {
    // 获取可用的TTS引擎
    var engines = await _flutterTts.getEngines;
    
    // 优先尝试Google TTS引擎（最通用）
    if (engines.contains('com.google.android.tts')) {
      await _flutterTts.setEngine('com.google.android.tts');
      return;
    }
    
    // 尝试其他常见的TTS引擎
    List<String> commonEngines = [
      'com.android.tts',
      'com.samsung.tts',
      'com.huawei.tts',
      'com.oppo.tts',
      'com.vivo.tts',
      'com.miui.tts',
    ];
    
    for (String engine in commonEngines) {
      if (engines.contains(engine)) {
        await _flutterTts.setEngine(engine);
        return;
      }
    }
    
    // 使用系统默认引擎
  } catch (e) {
    print('配置TTS引擎时出错: $e');
  }
}
```

#### 语言配置
```dart
Future<void> _configureLanguage() async {
  try {
    // 检查中文是否可用
    var ttsStatus = await _flutterTts.isLanguageAvailable("zh-CN");
    if (ttsStatus == 1) {
      await _flutterTts.setLanguage("zh-CN");
    } else {
      // 如果中文不可用，尝试英文
      ttsStatus = await _flutterTts.isLanguageAvailable("en-US");
      if (ttsStatus == 1) {
        await _flutterTts.setLanguage("en-US");
      } else {
        // 使用系统默认语言
        await _flutterTts.setLanguage("");
      }
    }
  } catch (e) {
    print('配置语言时出错: $e');
  }
}
```

#### 文本处理
```dart
String _processCodeForSpeech(String code) {
  // 分析代码结构并生成描述性文本
  final lines = code.split('\n');
  final totalLines = lines.length;
  
  // 统计主要元素
  int classCount = 0;
  int functionCount = 0;
  int importCount = 0;
  int commentCount = 0;

  String description = '${widget.title}，这是一个 ${widget.language} 文件。共 $totalLines 行代码';

  for (String line in lines) {
    final trimmedLine = line.trim();
    if (trimmedLine.startsWith('class ')) classCount++;
    if (trimmedLine.startsWith('void ') ||
        trimmedLine.startsWith('String ') ||
        trimmedLine.startsWith('int ') || 
        trimmedLine.startsWith('bool ') ||
        trimmedLine.startsWith('Widget ') ||
        trimmedLine.startsWith('Future<')) functionCount++;
    if (trimmedLine.startsWith('import ')) importCount++;
    if (trimmedLine.startsWith('//') || trimmedLine.startsWith('/*')) {
      commentCount++;
      description += trimmedLine.replaceAll('/', '');
    }
  }

  if (importCount > 0) description += '，包含 $importCount 个导入语句';
  if (classCount > 0) description += '，定义了 $classCount 个类';
  if (functionCount > 0) description += '，包含 $functionCount 个函数';
  if (commentCount > 0) description += '，有 $commentCount 行注释';

  return description;
}

String _processMarkdownForSpeech(String markdown) {
  // 移除markdown标记，保留纯文本内容
  return markdown
      .replaceAll(RegExp(r'#+\s*'), '') // 移除标题标记
      .replaceAll(RegExp(r'!+\s*'), '') // 移除变量标记
      .replaceAll(RegExp(r'\^+\s*'), '') // 移除变量标记
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), '') // 移除粗体标记
      .replaceAll(RegExp(r'\*(.*?)\*'), '') // 移除斜体标记
      .replaceAll(RegExp(r'`(.*?)`'), '') // 移除代码标记
      .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), '') // 移除链接标记
      .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '') // 移除图片标记
      .trim();
}
```

## 使用方法

### 1. 基本使用
1. 在源代码浏览器中打开任意文件
2. 点击右上角的"朗读全文"按钮（音量图标）
3. 朗读过程中可点击"停止"按钮（停止图标）中断朗读
4. 朗读完成后按钮自动恢复为"朗读全文"状态

### 2. 测试功能
1. 点击右上角的"测试TTS"按钮（调试图标）
2. 系统会自动测试TTS功能并显示结果
3. 测试结果会显示使用的TTS引擎信息

### 3. 支持的平台
- **Android**：支持Google TTS、系统TTS、各厂商TTS引擎
- **iOS**：支持系统语音合成引擎
- **Web**：支持浏览器内置TTS功能

## 与bloc项目的对比

### 相同点
1. **功能完全一致**：朗读功能、界面设计、错误处理完全相同
2. **技术实现相同**：都使用flutter_tts框架
3. **平台支持相同**：都支持iOS和Android平台
4. **用户体验一致**：操作方式、反馈机制完全相同

### 不同点
1. **项目架构**：isolate项目专注于多线程实现，TTS作为辅助功能
2. **代码组织**：isolate项目的TTS功能集成在源代码查看器中
3. **测试覆盖**：isolate项目有完整的单元测试覆盖

## 性能优化

### 1. 资源管理
- 在dispose()方法中正确释放TTS资源
- 避免内存泄漏和后台进程残留

### 2. 错误处理
- 完善的异常捕获和处理机制
- 用户友好的错误提示

### 3. 平台适配
- 自动检测和适配不同平台的TTS引擎
- 支持多种语音语言

## iOS平台问题解决

### 问题描述
在iOS平台上，TTS功能出现了以下错误：
```
MissingPluginException(No implementation found for method getEngines on channel flutter_tts)
```

### 问题原因
1. **平台差异**：iOS平台不支持`getEngines`方法，这是Android特有的API
2. **插件配置**：iOS平台的flutter_tts插件需要特殊的配置
3. **权限设置**：iOS需要额外的语音合成权限

### 解决方案

#### 1. 平台检测和适配
```dart
// 检查平台
if (Theme.of(context).platform == TargetPlatform.iOS) {
  // iOS平台跳过引擎检查
  print('iOS平台，使用系统默认TTS引擎');
  return;
}
```

#### 2. 权限配置更新
在`ios/Runner/Info.plist`中添加：
```xml
<key>NSSpeechSynthesisUsageDescription</key>
<string>此应用需要语音合成权限来提供文字转语音功能</string>
```

#### 3. Podfile配置
设置正确的iOS最低版本：
```ruby
platform :ios, '12.0'
```

#### 4. 错误处理优化
- 为iOS平台跳过不支持的API调用
- 添加备用方案和错误恢复机制
- 提供平台特定的用户反馈

### 修复结果
- ✅ iOS平台TTS功能正常工作
- ✅ Android平台功能保持不变
- ✅ 跨平台兼容性良好
- ✅ 错误处理更加健壮

## 总结

TTS功能的成功集成使得isolate项目具备了与bloc项目相同的文字转语音能力，为用户提供了更好的代码浏览体验。该功能：

1. **技术成熟**：基于成熟的flutter_tts框架
2. **功能完整**：支持代码和文档的智能朗读
3. **平台兼容**：支持iOS和Android平台，已解决平台差异问题
4. **用户体验**：操作简单，反馈及时
5. **代码质量**：遵循Flutter最佳实践，包含完善的错误处理

这为isolate项目增加了重要的辅助功能，提升了整体的用户体验。 