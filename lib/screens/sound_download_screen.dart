import 'package:flutter/material.dart';
import '../services/download_service.dart';
import '../utils/constants.dart';

class SoundDownloadScreen extends StatefulWidget {
  const SoundDownloadScreen({super.key});

  @override
  State<SoundDownloadScreen> createState() => _SoundDownloadScreenState();
}

class _SoundDownloadScreenState extends State<SoundDownloadScreen> {
  final DownloadService _downloadService = DownloadService();
  final TextEditingController _urlController = TextEditingController();
  bool _isDownloading = false;
  List<String> _downloadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final files = await _downloadService.getDownloadedFiles(
      subfolder: 'sounds',
    );
    setState(() {
      _downloadedFiles = files;
    });
  }

  Future<void> _downloadSoundPack() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // サンプル音源パック（Google Driveリンクのマップ）
      final soundUrls = {
        'note_0.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_0/view?usp=sharing',
        'note_1.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_1/view?usp=sharing',
        'note_2.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_2/view?usp=sharing',
        'note_3.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_3/view?usp=sharing',
        'note_4.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_4/view?usp=sharing',
        'note_5.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_5/view?usp=sharing',
        'note_6.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_6/view?usp=sharing',
        'note_7.wav':
            'https://drive.google.com/file/d/YOUR_FILE_ID_7/view?usp=sharing',
      };

      final results = await _downloadService.downloadSoundPack(
        soundUrls: soundUrls,
      );

      final successCount = results.values.where((path) => path != null).length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount個のファイルをダウンロードしました'),
            backgroundColor: Colors.green,
          ),
        );
      }

      await _loadDownloadedFiles();
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ダウンロードエラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // ファイル名を推測（または手動入力にする）
      final fileName = 'custom_${DateTime.now().millisecondsSinceEpoch}.wav';

      final filePath = await _downloadService.downloadFromGoogleDrive(
        driveUrl: url,
        fileName: fileName,
        subfolder: 'sounds',
      );

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ダウンロード完了: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();
        await _loadDownloadedFiles();
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ダウンロードエラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        title: const Text('音源ダウンロード'),
        backgroundColor: Color(AppColors.surfaceColor),
        foregroundColor: Color(AppColors.textColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '音源パック',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Color(AppColors.surfaceColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'デフォルト音源パック',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.textColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '基本的な8音階の音源ファイル（note_0.wav - note_7.wav）',
                          style: TextStyle(
                            color: Color(AppColors.secondaryTextColor),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isDownloading
                                ? null
                                : _downloadSoundPack,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(AppColors.primaryColor),
                            ),
                            child: _isDownloading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text('ダウンロード中...'),
                                    ],
                                  )
                                : const Text('音源パックをダウンロード'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'カスタム音源',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Color(AppColors.surfaceColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Driveから個別ダウンロード',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.textColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText: 'Google Drive共有リンクを入力',
                            hintStyle: TextStyle(
                              color: Color(AppColors.secondaryTextColor),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Color(AppColors.secondaryTextColor),
                              ),
                            ),
                          ),
                          style: TextStyle(color: Color(AppColors.textColor)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isDownloading ? null : _downloadFromUrl,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(AppColors.accentColor),
                            ),
                            child: const Text('ダウンロード'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ダウンロード済みファイル (${_downloadedFiles.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _downloadedFiles.isEmpty
                      ? Center(
                          child: Text(
                            'ダウンロード済みファイルがありません',
                            style: TextStyle(
                              color: Color(AppColors.secondaryTextColor),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _downloadedFiles.length,
                          itemBuilder: (context, index) {
                            final fileName = _downloadedFiles[index];
                            return Card(
                              color: Color(AppColors.surfaceColor),
                              child: ListTile(
                                leading: Icon(
                                  Icons.music_note,
                                  color: Color(AppColors.primaryColor),
                                ),
                                title: Text(
                                  fileName,
                                  style: TextStyle(
                                    color: Color(AppColors.textColor),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    final success = await _downloadService
                                        .deleteDownloadedFile(
                                          fileName,
                                          subfolder: 'sounds',
                                        );
                                    if (success) {
                                      await _loadDownloadedFiles();
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('$fileNameを削除しました'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Color(AppColors.secondaryTextColor),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
