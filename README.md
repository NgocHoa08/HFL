<div align="center">
  <img src="src/truongngochoa/desktop/assets/branding/truongngochoa-mark.png" width="96" alt="Truong Ngoc Hoa logo">
  <h1>Trương Ngọc Hoà</h1>
  <p><strong>A Windows app for downloading, translating, subtitling and dubbing videos.</strong></p>
  <p><a href="docs/user-guide.md">User guide</a> · <a href="docs/support.md">Help</a> · <a href="README.vi.md">Tiếng Việt</a></p>
</div>

## About Trương Ngọc Hoà

The **Trương Ngọc Hoà** application helps you download videos, translate speech, create subtitles and add translated voice tracks. Process one video or a batch, cover original subtitles and assign different voices to different speakers. You can publish processed videos to social media through Zernio.

Automatic mode runs the steps you select. The Manual editor lets you review and correct captions or voice tracks before exporting.

## Main features

| Feature | What you can do |
| --- | --- |
| **Batch video downloads** | Select multiple videos from supported public channels or profiles and queue them for download. |
| **Video translation** | Recognize speech with Whisper; translate locally with HY-MT2 or use Gemini. Review translations before exporting. |
| **Subtitle creation** | Create captions from video speech; edit text, timing, Bangers styling and karaoke highlighting. |
| **Video dubbing** | Generate speech for translated text using built-in voices or a reference sample you have permission to use. |
| **Automatic processing** | Choose languages, models and voice settings, then run your selected recognition, translation, dubbing and caption-coverage steps. |
| **Batch processing** | Apply common settings to multiple videos and follow each video's progress and results. |
| **Cover original subtitles** | Detect caption regions with OCR and cover them using blur or background patching. |
| **Multiple-speaker detection** | Group speakers and assign a separate voice to each group instead of using one voice for the entire conversation. |
| **Social publishing** | Select an account, prepare the post and publish through Zernio. You can use processed videos directly from projects. |

Manual tools run independently: dubbing is optional when you only need translated captions.

Preview the video, edit captions and choose suitable voices before exporting or publishing.

## Application overview

- **Home**: Find recent projects, filter by project type, and create new single, manual, or batch projects.
- **Automatic processing**: Choose speech recognition, translation, and voice models, then configure subtitle coverage, audio mixing, background music, and watermark settings.
- **Manual editor**: Review source and result previews, run individual processing steps independently, split the Result timeline into clips, import SRT captions, and export original or translated SRT files.
- **Downloads**: Inspect video, channel, or audio links, review channel video lists, and select items for batch downloading (including Douyin channels).
- **Social publishing**: Queue processed videos from existing projects and publish directly to connected accounts via Zernio.
- **Settings**: Manage interface language, GPU/CPU processing modes, API keys, and local AI resource packs.

## Local translation without per-call API charges

Whisper and HY-MT2 run on your computer after their resource packs are installed. They do not require API keys or per-call translation fees. Gemini is an additional option for online translation.

Computers without an NVIDIA GPU can use supported CPU options. Compatible NVIDIA GPUs can use GPU models. Choose a processing mode in Settings and install the matching resources for the tools you want to use.

Gemini, Zernio and other external services have their own terms, limits and charges. OmniVoice has the usage restriction described below.

## Install and get started

**[Download the Windows installer](https://github.com/NgocHoa08/HFL/releases/latest).** Run this EXE only; do not download or extract Core files. Resource packs are installed inside TruongNgocHoa. Version 1.0.0 can update directly in the app. [Release and installation details](https://github.com/NgocHoa08/HFL/releases/latest).

1. Install and open TruongNgocHoa. Vietnamese is the default; English is available in Settings.
2. Choose CPU or NVIDIA GPU in **Settings → General**, then install the resource packs you need.
3. Create an **Automatic**, **Manual** or **Batch** project and add videos.
4. Select language, models and voice if needed. Process, review and **Export** the video.

Supported systems are Windows 10 version 1809 or later and Windows 11 x64, with at least 16 GB system RAM. Installer users do not need Python. Resource packs, projects and exports need additional storage; Setup and the Resource packs page show their corresponding requirements.

GPU mode supports compatible NVIDIA 4 GB-class cards (at least 3.5 GiB dedicated VRAM reported by CUDA). On 4 GB, use Whisper Small GPU, HY-MT2 CPU Q4 or Gemini, and OmniVoice GPU; these heavy stages run sequentially, with one voice sentence at a time. Whisper Turbo and full HY-MT2 GPU need more VRAM. Available VRAM and system memory still matter at runtime. Windows Smart App Control or an Application Control policy may block this unsigned build; see the [installation guide](docs/install.md).

See [Installation](docs/install.md) for CPU/GPU packs, API keys and storage. See the [User guide](docs/user-guide.md) for projects, captions, dubbing and publishing.

## License and commercial use

Trương Ngọc Hoà is free to use under [Trương Ngọc Hoà Source-Available 1.0](LICENSE). This is not an OSI open-source license. Redistribution, repackaging and commercial software conditions are specified in LICENSE.

**The current OmniVoice model is licensed for noncommercial use only.** Do not assume it can be used for advertising, monetized videos or client work without appropriate permission. Trương Ngọc Hoà's license does not replace the model license.

You need permission to use imported video, music and voice samples. See [NOTICE](NOTICE) and [third-party notices](THIRD_PARTY_NOTICES.md). The [licensing review](docs/licensing-review.md) and [inactive draft terms](legal/LICENSE-SOURCE-AVAILABLE-DRAFT.md) are retained separately.

Trương Ngọc Hoà uses Qt/PySide under LGPL and FFmpeg under GPL/LGPL, depending on the component. [Bundled library sources](https://github.com/NgocHoa08/HFL/releases/latest) and [library replacement instructions](docs/third-party-library-replacement.md) are provided separately. Independent library-license rights remain available.

## Support and contributions

See [Help](docs/support.md) for resources, API keys and data management. You can also [send feedback or request support](https://github.com/NgocHoa08/HFL/issues). Never include keys or private data.

Source installation, testing and packaging are covered in the [development guide](docs/development.md). See the [technical documentation](docs/README.md) to contribute code.

Owned and maintained by **Trương Ngọc Hoà (Truong Ngoc Hoa)**.
