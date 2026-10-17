import React, { useState } from 'react';
import { 
  Sparkles, 
  RotateCcw, 
  FileText, 
  Image as ImageIcon, 
  Link2, 
  UploadCloud, 
  Play, 
  Pause, 
  ChevronDown, 
  ChevronUp, 
  Music, 
  Sliders, 
  Video 
} from 'lucide-react';
import type { SourceTabType } from '../types';

interface CreateVideoPanelProps {
  onGenerate: (prompt: string, style: string, ratio: string, duration: string, voice: string) => void;
  isGenerating: boolean;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
}

const DEFAULT_PROMPT = "Tạo một video giới thiệu sản phẩm áo thun thời trang, phong cách trẻ trung, hiện đại, thời lượng khoảng 30 giây. Sử dụng nhạc nền sôi động, có phụ đề và hiệu ứng chuyển cảnh mượt mà.";

export const CreateVideoPanel: React.FC<CreateVideoPanelProps> = ({ 
  onGenerate, 
  isGenerating,
  onShowToast 
}) => {
  const [sourceTab, setSourceTab] = useState<SourceTabType>('text');
  const [prompt, setPrompt] = useState(DEFAULT_PROMPT);
  const [style, setStyle] = useState('Modern & Dynamic');
  const [aspectRatio, setAspectRatio] = useState('16:9 (YouTube, TikTok)');
  const [duration, setDuration] = useState('~ 30 giây');
  const [language, setLanguage] = useState('🇻🇳 Tiếng Việt');
  const [voice, setVoice] = useState('Nam - Trẻ trung, năng động');
  const [isPlayingVoice, setIsPlayingVoice] = useState(false);
  const [isAdvancedOpen, setIsAdvancedOpen] = useState(false);

  // Advanced fields
  const [musicPrompt, setMusicPrompt] = useState('Upbeat energetic pop synthwave, commercial fashion vibes');
  const [voiceSpeed, setVoiceSpeed] = useState('1.0x');
  const [subtitleStyle, setSubtitleStyle] = useState('Karaoke nổi bật (Highlight từng chữ)');
  const [transitionLevel, setTransitionLevel] = useState('Chuyển cảnh mượt mà');
  const [videoQuality, setVideoQuality] = useState('1080p Full HD (60fps)');
  const [aiInstructions, setAiInstructions] = useState('');

  // Tab specific mock inputs
  const [imageUrl, setImageUrl] = useState('');
  const [linkUrl, setLinkUrl] = useState('');
  const [fileName, setFileName] = useState('');

  // Play voice sample simulation with Web Audio API chime
  const handleToggleVoicePreview = () => {
    if (isPlayingVoice) {
      setIsPlayingVoice(false);
      return;
    }

    setIsPlayingVoice(true);
    onShowToast('Đang phát giọng đọc mẫu', `Mẫu giọng: ${voice}`, 'info');

    try {
      const audioCtx = new (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(320, audioCtx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(440, audioCtx.currentTime + 0.3);
      osc.frequency.exponentialRampToValueAtTime(520, audioCtx.currentTime + 0.7);

      gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 1.2);

      osc.connect(gain);
      gain.connect(audioCtx.destination);

      osc.start();
      osc.stop(audioCtx.currentTime + 1.3);

      setTimeout(() => {
        setIsPlayingVoice(false);
      }, 1500);
    } catch {
      setTimeout(() => {
        setIsPlayingVoice(false);
      }, 1200);
    }
  };

  const handleReset = () => {
    setPrompt(DEFAULT_PROMPT);
    setStyle('Modern & Dynamic');
    setAspectRatio('16:9 (YouTube, TikTok)');
    setDuration('~ 30 giây');
    setLanguage('🇻🇳 Tiếng Việt');
    setVoice('Nam - Trẻ trung, năng động');
    setMusicPrompt('Upbeat energetic pop synthwave, commercial fashion vibes');
    setVoiceSpeed('1.0x');
    setSubtitleStyle('Karaoke nổi bật (Highlight từng chữ)');
    setTransitionLevel('Chuyển cảnh mượt mà');
    setVideoQuality('1080p Full HD (60fps)');
    setAiInstructions('');
    setImageUrl('');
    setLinkUrl('');
    setFileName('');
    onShowToast('Đã đặt lại', 'Các trường cấu hình đã được khôi phục về mặc định', 'info');
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!prompt.trim() && sourceTab === 'text') {
      onShowToast('Chưa nhập mô tả', 'Vui lòng nhập nội dung mô tả video trước khi tạo', 'warning');
      return;
    }
    onGenerate(prompt, style, aspectRatio, duration, voice);
  };

  return (
    <div className="bg-[#0B172B] border border-[#203455] rounded-xl p-4 sm:p-5 text-left flex flex-col justify-between shadow-xl relative overflow-hidden">
      {/* Top subtle highlight */}
      <div className="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-[#3867FF]/60 to-transparent" />

      <div>
        {/* Title & Description */}
        <div className="flex items-start gap-3 mb-4">
          <div className="w-9 h-9 rounded-lg bg-gradient-to-tr from-[#3867FF] to-[#6246F5] flex items-center justify-center text-white shrink-0 shadow-md shadow-[#3867FF]/30 mt-0.5">
            <Video className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-bold text-white tracking-tight flex items-center gap-2">
              Tạo video mới
            </h2>
            <p className="text-xs text-[#A5B5D4] leading-relaxed">
              Nhập nội dung, chọn phong cách và để AI tạo video cho bạn
            </p>
          </div>
        </div>

        {/* Input Source Tabs */}
        <div className="grid grid-cols-4 gap-1.5 p-1 rounded-xl bg-[#0D1B32] border border-[#203455] mb-4">
          <button
            type="button"
            onClick={() => setSourceTab('text')}
            className={`flex items-center justify-center gap-1.5 py-1.5 px-2 rounded-lg text-xs font-medium transition-all cursor-pointer ${
              sourceTab === 'text'
                ? 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] text-white shadow-sm font-semibold'
                : 'text-[#A5B5D4] hover:text-white hover:bg-[#142441]'
            }`}
          >
            <FileText className="w-3.5 h-3.5" />
            <span className="truncate">Từ văn bản</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSourceTab('image');
              onShowToast('Chế độ tạo từ ảnh', 'Tải lên hình ảnh sản phẩm để AI diễn hoạt thành video');
            }}
            className={`flex items-center justify-center gap-1.5 py-1.5 px-2 rounded-lg text-xs font-medium transition-all cursor-pointer ${
              sourceTab === 'image'
                ? 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] text-white shadow-sm font-semibold'
                : 'text-[#A5B5D4] hover:text-white hover:bg-[#142441]'
            }`}
          >
            <ImageIcon className="w-3.5 h-3.5" />
            <span className="truncate">Từ hình ảnh</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSourceTab('link');
              onShowToast('Chế độ tạo từ link', 'Dán đường dẫn sản phẩm Shopee/TikTok/bài viết');
            }}
            className={`flex items-center justify-center gap-1.5 py-1.5 px-2 rounded-lg text-xs font-medium transition-all cursor-pointer ${
              sourceTab === 'link'
                ? 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] text-white shadow-sm font-semibold'
                : 'text-[#A5B5D4] hover:text-white hover:bg-[#142441]'
            }`}
          >
            <Link2 className="w-3.5 h-3.5" />
            <span className="truncate">Từ link</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSourceTab('file');
              onShowToast('Chế độ tạo từ file', 'Tải tài liệu PDF, kịch bản Word hoặc slide');
            }}
            className={`flex items-center justify-center gap-1.5 py-1.5 px-2 rounded-lg text-xs font-medium transition-all cursor-pointer ${
              sourceTab === 'file'
                ? 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] text-white shadow-sm font-semibold'
                : 'text-[#A5B5D4] hover:text-white hover:bg-[#142441]'
            }`}
          >
            <UploadCloud className="w-3.5 h-3.5" />
            <span className="truncate">Từ file</span>
          </button>
        </div>

        {/* Dynamic Source Input Section */}
        {sourceTab === 'image' && (
          <div className="mb-3.5 p-3 rounded-xl bg-[#0D1B32] border border-dashed border-[#3867FF]/50 text-center">
            <div className="flex flex-col items-center justify-center gap-1.5">
              <UploadCloud className="w-6 h-6 text-[#3867FF]" />
              <p className="text-xs text-white font-medium">Kéo thả ảnh hoặc chọn ảnh mẫu</p>
              <p className="text-[11px] text-[#A5B5D4]">PNG, JPG, WEBP lên đến 20MB</p>
              <button 
                type="button"
                onClick={() => {
                  setImageUrl('https://images.unsplash.com/photo-1521572267360-ee0c2909d518');
                  onShowToast('Đã đính kèm ảnh', 'Áo thun thời trang Streetwear Black Edition');
                }}
                className="mt-1 text-[11px] px-2.5 py-1 rounded bg-[#142441] text-[#3867FF] hover:bg-[#3867FF]/20 border border-[#203455]"
              >
                {imageUrl ? '✓ Đã đính kèm ảnh mẫu' : 'Chọn ảnh mẫu có sẵn'}
              </button>
            </div>
          </div>
        )}

        {sourceTab === 'link' && (
          <div className="mb-3.5">
            <label className="block text-xs font-medium text-[#A5B5D4] mb-1.5">
              Đường link sản phẩm hoặc bài viết:
            </label>
            <div className="relative">
              <Link2 className="w-4 h-4 text-[#A5B5D4] absolute left-3 top-2.5" />
              <input 
                type="url"
                value={linkUrl}
                onChange={(e) => setLinkUrl(e.target.value)}
                placeholder="https://tiktok.com/@brand/video/... hoặc link sản phẩm"
                className="w-full bg-[#0D1B32] border border-[#203455] rounded-xl pl-9 pr-3 py-2 text-xs text-white focus:outline-none focus:border-[#3867FF] transition-colors"
              />
            </div>
          </div>
        )}

        {sourceTab === 'file' && (
          <div className="mb-3.5 p-3 rounded-xl bg-[#0D1B32] border border-dashed border-[#203455] text-center">
            <UploadCloud className="w-6 h-6 text-[#A5B5D4] mx-auto mb-1" />
            <p className="text-xs text-white font-medium">Tải tệp kịch bản hoặc tài liệu</p>
            <p className="text-[11px] text-[#A5B5D4]">PDF, DOCX, TXT (Tối đa 50 trang)</p>
            <button 
              type="button"
              onClick={() => {
                setFileName('kich_ban_ao_thun_hv.docx');
                onShowToast('Đã tải tệp', 'Kịch bản: kich_ban_ao_thun_hv.docx');
              }}
              className="mt-1 text-[11px] px-2.5 py-1 rounded bg-[#142441] text-[#3867FF] border border-[#203455]"
            >
              {fileName ? `✓ ${fileName}` : 'Chọn tệp tài liệu'}
            </button>
          </div>
        )}

        {/* Text Prompt Input */}
        <div className="mb-3.5">
          <div className="flex items-center justify-between mb-1.5">
            <label className="text-xs font-semibold text-[#F1F5FF]">
              Nhập nội dung mô tả video...
            </label>
            <span className="text-[11px] text-[#A5B5D4] font-mono">
              {prompt.length}/1000
            </span>
          </div>

          <div className="relative">
            <textarea
              rows={4}
              value={prompt}
              maxLength={1000}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="Mô tả ý tưởng video, phong cách, nhân vật, bối cảnh, âm nhạc bạn muốn tạo..."
              className="w-full bg-[#0D1B32] border border-[#203455] rounded-xl p-3 text-xs text-[#F1F5FF] leading-relaxed resize-none focus:outline-none focus:border-[#3867FF] focus:ring-1 focus:ring-[#3867FF] transition-all placeholder:text-[#A5B5D4]/40"
            />
          </div>
        </div>

        {/* 2-Column Options Grid */}
        <div className="space-y-3 mb-3.5">
          {/* Row 1: Style & Aspect Ratio */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-[11px] font-medium text-[#A5B5D4] mb-1">
                Chọn phong cách
              </label>
              <div className="relative">
                <select
                  value={style}
                  onChange={(e) => setStyle(e.target.value)}
                  className="w-full bg-[#0D1B32] border border-[#203455] rounded-lg px-2.5 py-2 text-xs text-white appearance-none cursor-pointer focus:outline-none focus:border-[#3867FF] transition-colors pr-7"
                >
                  <option value="Modern & Dynamic">Modern & Dynamic</option>
                  <option value="Cinematic">Cinematic (Điện ảnh)</option>
                  <option value="Anime / Hoạt hình">Anime / Hoạt hình</option>
                  <option value="Tối giản / Minimalist">Tối giản / Minimalist</option>
                  <option value="Cyberpunk">Cyberpunk / Viễn tưởng</option>
                  <option value="Doanh nghiệp">Doanh nghiệp / Corporate</option>
                </select>
                <ChevronDown className="w-3.5 h-3.5 text-[#A5B5D4] absolute right-2.5 top-3 pointer-events-none" />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-medium text-[#A5B5D4] mb-1">
                Tỷ lệ khung hình
              </label>
              <div className="relative">
                <select
                  value={aspectRatio}
                  onChange={(e) => setAspectRatio(e.target.value)}
                  className="w-full bg-[#0D1B32] border border-[#203455] rounded-lg px-2.5 py-2 text-xs text-white appearance-none cursor-pointer focus:outline-none focus:border-[#3867FF] transition-colors pr-7"
                >
                  <option value="16:9 (YouTube, TikTok)">16:9 (Ngang - YouTube, PC)</option>
                  <option value="9:16 (Shorts, Reels)">9:16 (Dọc - TikTok, Reels)</option>
                  <option value="1:1 (Instagram)">1:1 (Vuông - Instagram)</option>
                  <option value="4:5 (Facebook)">4:5 (Dọc vừa - Feed)</option>
                </select>
                <ChevronDown className="w-3.5 h-3.5 text-[#A5B5D4] absolute right-2.5 top-3 pointer-events-none" />
              </div>
            </div>
          </div>

          {/* Row 2: Duration & Language */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="block text-[11px] font-medium text-[#A5B5D4] mb-1">
                Thời lượng video
              </label>
              <div className="relative">
                <select
                  value={duration}
                  onChange={(e) => setDuration(e.target.value)}
                  className="w-full bg-[#0D1B32] border border-[#203455] rounded-lg px-2.5 py-2 text-xs text-white appearance-none cursor-pointer focus:outline-none focus:border-[#3867FF] transition-colors pr-7"
                >
                  <option value="~ 15 giây">~ 15 giây (Quảng cáo nhanh)</option>
                  <option value="~ 30 giây">~ 30 giây (Chuẩn TikTok)</option>
                  <option value="~ 60 giây">~ 60 giây (Giới thiệu chi tiết)</option>
                  <option value="~ 90 giây">~ 90 giây (Video câu chuyện)</option>
                </select>
                <ChevronDown className="w-3.5 h-3.5 text-[#A5B5D4] absolute right-2.5 top-3 pointer-events-none" />
              </div>
            </div>

            <div>
              <label className="block text-[11px] font-medium text-[#A5B5D4] mb-1">
                Ngôn ngữ (phụ đề)
              </label>
              <div className="relative">
                <select
                  value={language}
                  onChange={(e) => setLanguage(e.target.value)}
                  className="w-full bg-[#0D1B32] border border-[#203455] rounded-lg px-2.5 py-2 text-xs text-white appearance-none cursor-pointer focus:outline-none focus:border-[#3867FF] transition-colors pr-7"
                >
                  <option value="🇻🇳 Tiếng Việt">🇻🇳 Tiếng Việt</option>
                  <option value="🇺🇸 Tiếng Anh">🇺🇸 Tiếng Anh (English)</option>
                  <option value="🇨🇳 Tiếng Trung">🇨🇳 Tiếng Trung (中文)</option>
                  <option value="🇯🇵 Tiếng Nhật">🇯🇵 Tiếng Nhật (日本語)</option>
                  <option value="🇰🇷 Tiếng Hàn">🇰🇷 Tiếng Hàn (한국어)</option>
                </select>
                <ChevronDown className="w-3.5 h-3.5 text-[#A5B5D4] absolute right-2.5 top-3 pointer-events-none" />
              </div>
            </div>
          </div>

          {/* Row 3: Voice Selection & Preview */}
          <div>
            <label className="block text-[11px] font-medium text-[#A5B5D4] mb-1">
              Chọn giọng đọc (nếu có)
            </label>
            <div className="flex items-center gap-2">
              <div className="relative flex-1">
                <select
                  value={voice}
                  onChange={(e) => setVoice(e.target.value)}
                  className="w-full bg-[#0D1B32] border border-[#203455] rounded-lg px-2.5 py-2 text-xs text-white appearance-none cursor-pointer focus:outline-none focus:border-[#3867FF] transition-colors pr-7"
                >
                  <option value="Nam - Trẻ trung, năng động">Nam - Trẻ trung, năng động</option>
                  <option value="Nữ - Dịu dàng, truyền cảm">Nữ - Dịu dàng, truyền cảm</option>
                  <option value="Nam - Trầm ấm, chuyên nghiệp">Nam - Trầm ấm, chuyên nghiệp</option>
                  <option value="Nữ - Tươi vui, sôi nổi">Nữ - Tươi vui, sôi nổi</option>
                  <option value="Không sử dụng giọng đọc">Không sử dụng giọng đọc (Chỉ nhạc nền)</option>
                </select>
                <ChevronDown className="w-3.5 h-3.5 text-[#A5B5D4] absolute right-2.5 top-3 pointer-events-none" />
              </div>

              {/* Play voice preview button */}
              <button
                type="button"
                onClick={handleToggleVoicePreview}
                className={`h-9 px-3 rounded-lg border flex items-center justify-center gap-1.5 text-xs font-medium transition-all cursor-pointer ${
                  isPlayingVoice
                    ? 'bg-[#3867FF] text-white border-[#3867FF] shadow-md shadow-[#3867FF]/30'
                    : 'bg-[#142441] border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50'
                }`}
                title="Nghe thử giọng đọc mẫu"
              >
                {isPlayingVoice ? (
                  <>
                    <Pause className="w-3.5 h-3.5 fill-current" />
                    <span className="text-[11px] hidden sm:inline">Dừng</span>
                  </>
                ) : (
                  <>
                    <Play className="w-3.5 h-3.5 fill-current ml-0.5" />
                    <span className="text-[11px] hidden sm:inline">Nghe thử</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </div>

        {/* Advanced Options Accordion */}
        <div className="mb-4 border border-[#203455] rounded-xl overflow-hidden bg-[#0D1B32]/40">
          <button
            type="button"
            onClick={() => setIsAdvancedOpen(!isAdvancedOpen)}
            className="w-full flex items-center justify-between px-3.5 py-2.5 bg-[#0D1B32] text-xs font-semibold text-[#A5B5D4] hover:text-white transition-colors cursor-pointer select-none"
          >
            <div className="flex items-center gap-2">
              <Sliders className="w-3.5 h-3.5 text-[#3867FF]" />
              <span>Tùy chọn nâng cao</span>
            </div>
            {isAdvancedOpen ? (
              <ChevronUp className="w-4 h-4 text-[#A5B5D4]" />
            ) : (
              <ChevronDown className="w-4 h-4 text-[#A5B5D4]" />
            )}
          </button>

          {isAdvancedOpen && (
            <div className="p-3.5 space-y-3 border-t border-[#203455] text-xs animate-in fade-in duration-200">
              {/* Music prompt */}
              <div>
                <label className="block text-[11px] text-[#A5B5D4] mb-1 flex items-center gap-1.5">
                  <Music className="w-3 h-3 text-[#3867FF]" />
                  Prompt âm thanh / Nhạc nền
                </label>
                <input
                  type="text"
                  value={musicPrompt}
                  onChange={(e) => setMusicPrompt(e.target.value)}
                  placeholder="Gợi ý: Nhạc EDM sôi động, Lofi acoustic nhẹ nhàng..."
                  className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2.5 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                />
              </div>

              {/* Speech speed & Subtitle style */}
              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block text-[11px] text-[#A5B5D4] mb-1">
                    Tốc độ giọng đọc
                  </label>
                  <select
                    value={voiceSpeed}
                    onChange={(e) => setVoiceSpeed(e.target.value)}
                    className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                  >
                    <option value="0.8x">0.8x (Chậm, rõ ràng)</option>
                    <option value="1.0x">1.0x (Chuẩn bình thường)</option>
                    <option value="1.2x">1.2x (Nhanh, hào hứng)</option>
                    <option value="1.5x">1.5x (Rất nhanh)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[11px] text-[#A5B5D4] mb-1">
                    Phong cách phụ đề
                  </label>
                  <select
                    value={subtitleStyle}
                    onChange={(e) => setSubtitleStyle(e.target.value)}
                    className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                  >
                    <option value="Karaoke nổi bật (Highlight từng chữ)">Karaoke nổi bật</option>
                    <option value="Chữ trắng viền đen tối giản">Chữ trắng viền đen tối giản</option>
                    <option value="Hộp nền mờ Cinematic">Hộp nền mờ Cinematic</option>
                  </select>
                </div>
              </div>

              {/* Transition & Video Quality */}
              <div className="grid grid-cols-2 gap-2.5">
                <div>
                  <label className="block text-[11px] text-[#A5B5D4] mb-1">
                    Mức độ chuyển cảnh
                  </label>
                  <select
                    value={transitionLevel}
                    onChange={(e) => setTransitionLevel(e.target.value)}
                    className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                  >
                    <option value="Chuyển cảnh mượt mà">Chuyển cảnh mượt mà</option>
                    <option value="Chuyển cảnh nhanh năng động">Chuyển cảnh nhanh năng động</option>
                    <option value="Chuyển cảnh nhẹ nhàng">Chuyển cảnh nhẹ nhàng</option>
                  </select>
                </div>

                <div>
                  <label className="block text-[11px] text-[#A5B5D4] mb-1">
                    Chất lượng video
                  </label>
                  <select
                    value={videoQuality}
                    onChange={(e) => setVideoQuality(e.target.value)}
                    className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                  >
                    <option value="1080p Full HD (60fps)">1080p Full HD (60fps)</option>
                    <option value="4K Ultra HD (60fps)">4K Ultra HD (Pro)</option>
                    <option value="720p HD (30fps)">720p HD (Tiết kiệm)</option>
                  </select>
                </div>
              </div>

              {/* Additional AI Instructions */}
              <div>
                <label className="block text-[11px] text-[#A5B5D4] mb-1">
                  Hướng dẫn bổ sung cho AI
                </label>
                <input
                  type="text"
                  value={aiInstructions}
                  onChange={(e) => setAiInstructions(e.target.value)}
                  placeholder="Ví dụ: Tông màu ấm áp, tránh cảnh quá tối, logo hiện ở góc phải..."
                  className="w-full bg-[#0B172B] border border-[#203455] rounded-lg px-2.5 py-1.5 text-xs text-white focus:outline-none focus:border-[#3867FF]"
                />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex items-center gap-3 pt-3 border-t border-[#203455]/70">
        {/* Create Video Button */}
        <button
          type="button"
          onClick={handleSubmit}
          disabled={isGenerating}
          className={`flex-1 flex items-center justify-center gap-2 py-2.5 px-4 rounded-xl text-white font-semibold text-xs transition-all shadow-lg cursor-pointer ${
            isGenerating
              ? 'bg-[#3867FF]/60 cursor-not-allowed opacity-80'
              : 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] hover:opacity-95 shadow-[#3867FF]/30 active:scale-[0.99]'
          }`}
        >
          {isGenerating ? (
            <>
              <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              <span>Đang tạo video bằng AI...</span>
            </>
          ) : (
            <>
              <Sparkles className="w-4 h-4 fill-white" />
              <span>Tạo video</span>
            </>
          )}
        </button>

        {/* Reset Button */}
        <button
          type="button"
          onClick={handleReset}
          disabled={isGenerating}
          className="flex items-center justify-center gap-1.5 py-2.5 px-3.5 rounded-xl bg-[#142441] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50 transition-all text-xs font-medium cursor-pointer active:scale-[0.99]"
          title="Đặt lại cài đặt về mặc định"
        >
          <RotateCcw className="w-4 h-4" />
          <span className="hidden sm:inline">Đặt lại</span>
        </button>
      </div>
    </div>
  );
};
