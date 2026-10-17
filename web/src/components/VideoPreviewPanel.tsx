import React, { useState, useEffect, useRef } from 'react';
import { 
  Play, 
  Pause, 
  Volume2, 
  VolumeX, 
  Maximize, 
  Minimize, 
  Settings, 
  Pencil, 
  Download, 
  Share2, 
  MoreHorizontal, 
  Plus, 
  Check, 
  Sparkles,
  Film
} from 'lucide-react';
import type { Scene } from '../types';

interface VideoPreviewPanelProps {
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
  activeSceneId: number;
  onSelectScene: (id: number) => void;
  isGenerating: boolean;
}

const INITIAL_SCENES: Scene[] = [
  { id: 1, timeRange: '0:00 - 0:04', title: 'Người mẫu ngắm bình minh', thumbnail: '/hero_fashion_sunrise.jpg', duration: 4 },
  { id: 2, timeRange: '0:04 - 0:08', title: 'Cận cảnh áo thun đen', thumbnail: '/scene_tshirt_detail.jpg', duration: 4 },
  { id: 3, timeRange: '0:08 - 0:12', title: 'Người mẫu đứng bên hồ', thumbnail: '/scene_lake_view.jpg', duration: 4 },
  { id: 4, timeRange: '0:12 - 0:18', title: 'Cận cảnh bàn tay', thumbnail: '/scene_tshirt_detail.jpg', duration: 6 },
  { id: 5, timeRange: '0:18 - 0:24', title: 'Người mẫu đi bộ ngoài trời', thumbnail: '/scene_lake_view.jpg', duration: 6 },
  { id: 6, timeRange: '0:24 - 0:30', title: 'Khung hình logo HV', thumbnail: '/hero_fashion_sunrise.jpg', duration: 6 },
];

export const VideoPreviewPanel: React.FC<VideoPreviewPanelProps> = ({ 
  onShowToast,
  activeSceneId,
  onSelectScene,
  isGenerating
}) => {
  const [scenes, setScenes] = useState<Scene[]>(INITIAL_SCENES);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(8); // Default 0:08 as in spec
  const totalDuration = 30; // 30s
  const [isMuted, setIsMuted] = useState(false);
  const [volume, setVolume] = useState(80);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [showSettingsMenu, setShowSettingsMenu] = useState(false);
  const [playbackSpeed, setPlaybackSpeed] = useState('1.0x');

  const playerRef = useRef<HTMLDivElement>(null);

  // Playback timer simulation
  useEffect(() => {
    let interval: number | undefined;
    if (isPlaying) {
      interval = window.setInterval(() => {
        setCurrentTime((prev) => {
          if (prev >= totalDuration) {
            setIsPlaying(false);
            return 0;
          }
          return prev + 1;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isPlaying]);

  // Keep scene in sync with currentTime
  useEffect(() => {
    if (currentTime < 4) onSelectScene(1);
    else if (currentTime < 8) onSelectScene(2);
    else if (currentTime < 12) onSelectScene(3);
    else if (currentTime < 18) onSelectScene(4);
    else if (currentTime < 24) onSelectScene(5);
    else onSelectScene(6);
  }, [currentTime, onSelectScene]);

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
  };

  const handleSeek = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const pos = (e.clientX - rect.left) / rect.width;
    const newTime = Math.round(pos * totalDuration);
    setCurrentTime(newTime);
  };

  const handleSceneClick = (scene: Scene) => {
    onSelectScene(scene.id);
    let targetTime = 0;
    if (scene.id === 1) targetTime = 0;
    else if (scene.id === 2) targetTime = 4;
    else if (scene.id === 3) targetTime = 8;
    else if (scene.id === 4) targetTime = 12;
    else if (scene.id === 5) targetTime = 18;
    else if (scene.id === 6) targetTime = 24;

    setCurrentTime(targetTime);
    onShowToast(`Phân cảnh ${scene.id}`, `${scene.title} (${scene.timeRange})`);
  };

  const handleAddScene = () => {
    const nextId = scenes.length + 1;
    const newScene: Scene = {
      id: nextId,
      timeRange: `0:30 - 0:35`,
      title: `Phân cảnh kết thúc ${nextId}`,
      thumbnail: '/scene_tshirt_detail.jpg',
      duration: 5,
    };
    setScenes([...scenes, newScene]);
    onShowToast('Đã thêm phân cảnh mới', `Phân cảnh ${nextId} đã được thêm vào timeline`, 'success');
  };

  const toggleFullscreen = () => {
    if (!playerRef.current) return;
    if (!isFullscreen) {
      if (playerRef.current.requestFullscreen) {
        playerRef.current.requestFullscreen();
      }
      setIsFullscreen(true);
    } else {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      }
      setIsFullscreen(false);
    }
  };

  // Resolve current active scene thumbnail
  const currentActiveScene = scenes.find((s) => s.id === activeSceneId) || scenes[0];
  const activeThumbnail = currentActiveScene.thumbnail || '/hero_fashion_sunrise.jpg';

  return (
    <div className="bg-[#0B172B] border border-[#203455] rounded-xl p-4 sm:p-5 flex flex-col justify-between shadow-xl relative overflow-hidden text-left">
      {/* Top subtle highlight */}
      <div className="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-[#6246F5]/60 to-transparent" />

      <div>
        {/* Video Player Container (16:9 ratio) */}
        <div 
          ref={playerRef}
          className="relative w-full aspect-video rounded-xl overflow-hidden bg-black border border-[#203455] group shadow-2xl mb-4 select-none"
        >
          {/* Video Poster Image with subtle motion when playing */}
          <div className="absolute inset-0 overflow-hidden">
            <img 
              src={activeThumbnail} 
              alt="AI Video Preview"
              className={`w-full h-full object-cover transition-transform duration-700 ${
                isPlaying ? 'scale-105 brightness-105' : 'scale-100 brightness-95'
              }`}
            />
            {/* Cinematic Gradient Vignette */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-black/40 pointer-events-none" />
          </div>

          {/* Top Badges */}
          <div className="absolute top-3 left-3 right-3 flex items-center justify-between z-10 pointer-events-none">
            <div className="flex items-center gap-2">
              <span className="px-2 py-0.5 rounded bg-black/60 backdrop-blur-md text-[10px] font-bold text-white uppercase tracking-wider border border-white/10">
                1080p
              </span>
              <span className="px-2 py-0.5 rounded bg-[#3867FF]/80 backdrop-blur-md text-[10px] font-semibold text-white tracking-wider flex items-center gap-1">
                <Sparkles className="w-2.5 h-2.5" />
                AI Video
              </span>
            </div>

            <div className="px-2 py-0.5 rounded bg-black/60 backdrop-blur-md text-[10px] font-medium text-[#A5B5D4] border border-white/10">
              Phân cảnh {activeSceneId} / {scenes.length}
            </div>
          </div>

          {/* Fashion Typography Overlay: "BẬT CHẤT RIÊNG - SỐNG ĐÚNG GU" */}
          <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none z-10 px-4 text-center">
            <div className="transform -rotate-1 tracking-tight">
              <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold italic uppercase tracking-wider text-white drop-shadow-[0_4px_12px_rgba(0,0,0,0.9)] font-['Inter'] leading-none">
                BẬT CHẤT RIÊNG
              </h2>
              <h3 className="text-xl sm:text-2xl md:text-3xl font-extrabold italic uppercase tracking-widest text-transparent bg-clip-text bg-gradient-to-r from-amber-300 via-orange-400 to-yellow-200 drop-shadow-[0_4px_12px_rgba(0,0,0,0.9)] mt-1">
                SỐNG ĐÚNG GU
              </h3>
            </div>
            {/* Subtitle tag */}
            <div className="mt-3 px-3 py-1 rounded-full bg-black/50 backdrop-blur-md border border-white/20 text-[11px] text-[#F1F5FF] font-medium drop-shadow-md">
              Bộ sưu tập Streetwear Xuân Hè 2026
            </div>
          </div>

          {/* Center Play Overlay Trigger when paused */}
          {!isPlaying && !isGenerating && (
            <button
              onClick={() => setIsPlaying(true)}
              className="absolute inset-0 m-auto w-14 h-14 rounded-full bg-gradient-to-tr from-[#3867FF]/90 to-[#6246F5]/90 text-white flex items-center justify-center shadow-2xl shadow-[#3867FF]/50 hover:scale-110 active:scale-95 transition-all z-20 cursor-pointer backdrop-blur-sm"
              title="Phát video"
            >
              <Play className="w-6 h-6 fill-white ml-1" />
            </button>
          )}

          {/* Generating Loading Overlay */}
          {isGenerating && (
            <div className="absolute inset-0 bg-black/75 backdrop-blur-sm flex flex-col items-center justify-center z-30">
              <div className="w-12 h-12 rounded-full border-4 border-[#3867FF]/30 border-t-[#3867FF] animate-spin mb-3" />
              <p className="text-sm font-semibold text-white">Đang kết xuất video AI...</p>
              <p className="text-xs text-[#A5B5D4] mt-1">Vui lòng đợi vài giây trong lúc AI render</p>
            </div>
          )}

          {/* Video Control Bar */}
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/95 via-black/80 to-transparent pt-6 pb-2.5 px-3 z-20">
            {/* Progress Scrubber */}
            <div 
              onClick={handleSeek}
              className="w-full h-1.5 bg-white/20 rounded-full cursor-pointer relative group/progress mb-2"
            >
              <div 
                className="h-full bg-gradient-to-r from-[#3867FF] to-[#6246F5] rounded-full relative transition-all duration-100"
                style={{ width: `${(currentTime / totalDuration) * 100}%` }}
              >
                <div className="absolute right-0 top-1/2 -translate-y-1/2 w-3 h-3 bg-white rounded-full shadow-md opacity-0 group-hover/progress:opacity-100 transition-opacity" />
              </div>
            </div>

            {/* Bottom Controls */}
            <div className="flex items-center justify-between text-white text-xs">
              {/* Left controls */}
              <div className="flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => setIsPlaying(!isPlaying)}
                  className="hover:text-[#3867FF] transition-colors cursor-pointer"
                  title={isPlaying ? 'Tạm dừng' : 'Phát'}
                >
                  {isPlaying ? (
                    <Pause className="w-4 h-4 fill-current" />
                  ) : (
                    <Play className="w-4 h-4 fill-current ml-0.5" />
                  )}
                </button>

                <div className="flex items-center gap-1.5 font-mono text-[11px] text-[#A5B5D4]">
                  <span className="text-white font-medium">{formatTime(currentTime)}</span>
                  <span>/</span>
                  <span>{formatTime(totalDuration)}</span>
                </div>

                {/* Volume */}
                <div className="flex items-center gap-1.5 group/volume ml-1">
                  <button
                    type="button"
                    onClick={() => setIsMuted(!isMuted)}
                    className="hover:text-[#3867FF] transition-colors cursor-pointer text-[#A5B5D4]"
                  >
                    {isMuted || volume === 0 ? (
                      <VolumeX className="w-4 h-4" />
                    ) : (
                      <Volume2 className="w-4 h-4" />
                    )}
                  </button>
                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={isMuted ? 0 : volume}
                    onChange={(e) => {
                      setVolume(Number(e.target.value));
                      setIsMuted(false);
                    }}
                    className="w-14 h-1 accent-[#3867FF] bg-white/20 rounded-lg cursor-pointer"
                  />
                </div>
              </div>

              {/* Right controls */}
              <div className="flex items-center gap-2.5 relative">
                {/* Speed indicator / settings */}
                <div className="relative">
                  <button
                    type="button"
                    onClick={() => setShowSettingsMenu(!showSettingsMenu)}
                    className="text-[#A5B5D4] hover:text-white transition-colors cursor-pointer flex items-center gap-1"
                    title="Cài đặt tốc độ"
                  >
                    <span className="text-[10px] font-mono font-medium">{playbackSpeed}</span>
                    <Settings className="w-3.5 h-3.5" />
                  </button>

                  {showSettingsMenu && (
                    <div className="absolute bottom-8 right-0 bg-[#0B172B] border border-[#203455] rounded-lg shadow-xl p-1 z-50 text-[11px] w-28">
                      <div className="px-2 py-1 text-[#A5B5D4] text-[10px] font-semibold border-b border-[#203455]">
                        Tốc độ phát
                      </div>
                      {['0.5x', '1.0x', '1.25x', '1.5x', '2.0x'].map((s) => (
                        <button
                          key={s}
                          type="button"
                          onClick={() => {
                            setPlaybackSpeed(s);
                            setShowSettingsMenu(false);
                            onShowToast('Tốc độ phát', `Đã chọn ${s}`);
                          }}
                          className={`w-full text-left px-2 py-1 rounded flex items-center justify-between hover:bg-[#142441] ${
                            playbackSpeed === s ? 'text-[#3867FF] font-semibold' : 'text-white'
                          }`}
                        >
                          <span>{s}</span>
                          {playbackSpeed === s && <Check className="w-3 h-3" />}
                        </button>
                      ))}
                    </div>
                  )}
                </div>

                {/* Fullscreen */}
                <button
                  type="button"
                  onClick={toggleFullscreen}
                  className="text-[#A5B5D4] hover:text-white transition-colors cursor-pointer"
                  title="Toàn màn hình"
                >
                  {isFullscreen ? (
                    <Minimize className="w-4 h-4" />
                  ) : (
                    <Maximize className="w-4 h-4" />
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Scene Timeline (Hàng thumbnail các phân cảnh) */}
        <div className="mb-4">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-1.5 text-xs font-semibold text-[#F1F5FF]">
              <Film className="w-3.5 h-3.5 text-[#3867FF]" />
              <span>Timeline phân cảnh ({scenes.length})</span>
            </div>
            <span className="text-[10px] text-[#A5B5D4]">
              Nhấp để chuyển cảnh
            </span>
          </div>

          <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-thin">
            {scenes.map((scene) => {
              const isSelected = activeSceneId === scene.id;
              return (
                <div
                  key={scene.id}
                  onClick={() => handleSceneClick(scene)}
                  className={`shrink-0 w-24 sm:w-28 group cursor-pointer transition-all ${
                    isSelected ? 'scale-[1.02]' : 'opacity-80 hover:opacity-100'
                  }`}
                >
                  {/* Thumbnail Card */}
                  <div className={`relative aspect-video rounded-lg overflow-hidden border transition-all ${
                    isSelected
                      ? 'border-[#3867FF] ring-2 ring-[#3867FF]/50 shadow-md shadow-[#3867FF]/20'
                      : 'border-[#203455] group-hover:border-[#3867FF]/50'
                  }`}>
                    <img 
                      src={scene.thumbnail} 
                      alt={scene.title}
                      className="w-full h-full object-cover" 
                    />
                    <div className="absolute inset-0 bg-black/20 group-hover:bg-transparent transition-colors" />
                    
                    {/* Scene number tag */}
                    <span className="absolute top-1 left-1 px-1 py-0.2 rounded bg-black/70 text-[9px] font-bold text-white">
                      #{scene.id}
                    </span>
                  </div>

                  {/* Scene Time & Title */}
                  <div className="mt-1 text-center">
                    <p className={`text-[10px] font-mono font-medium ${
                      isSelected ? 'text-[#3867FF] font-semibold' : 'text-[#A5B5D4]'
                    }`}>
                      {scene.timeRange}
                    </p>
                    <p className="text-[10px] text-[#F1F5FF] truncate" title={scene.title}>
                      {scene.title}
                    </p>
                  </div>
                </div>
              );
            })}

            {/* Add Scene Button */}
            <button
              type="button"
              onClick={handleAddScene}
              className="shrink-0 w-16 h-[54px] rounded-lg border border-dashed border-[#203455] hover:border-[#3867FF] hover:bg-[#142441] flex flex-col items-center justify-center text-[#A5B5D4] hover:text-white transition-all cursor-pointer mb-5"
              title="Thêm phân cảnh mới"
            >
              <Plus className="w-4 h-4 text-[#3867FF]" />
              <span className="text-[9px] mt-0.5">Thêm</span>
            </button>
          </div>
        </div>
      </div>

      {/* Video Action Bar (4 Buttons) */}
      <div className="grid grid-cols-4 gap-2 pt-3 border-t border-[#203455]/70">
        <button
          type="button"
          onClick={() => onShowToast('Chỉnh sửa video', 'Đang mở phòng biên tập video HFL Studio')}
          className="flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl bg-[#142441] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50 hover:bg-[#3867FF]/15 transition-all text-xs font-medium cursor-pointer active:scale-[0.98]"
        >
          <Pencil className="w-3.5 h-3.5 text-[#3867FF]" />
          <span>Chỉnh sửa</span>
        </button>

        <button
          type="button"
          onClick={() => onShowToast('Tải xuống video', 'Bắt đầu xuất video MP4 Full HD 1080p về máy', 'success')}
          className="flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl bg-[#142441] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#10B981]/50 hover:bg-[#10B981]/15 transition-all text-xs font-medium cursor-pointer active:scale-[0.98]"
        >
          <Download className="w-3.5 h-3.5 text-[#10B981]" />
          <span>Tải xuống</span>
        </button>

        <button
          type="button"
          onClick={() => onShowToast('Chia sẻ video', 'Đã sao chép liên kết video vào bộ nhớ tạm (Clipboard)')}
          className="flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl bg-[#142441] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#6246F5]/50 hover:bg-[#6246F5]/15 transition-all text-xs font-medium cursor-pointer active:scale-[0.98]"
        >
          <Share2 className="w-3.5 h-3.5 text-[#6246F5]" />
          <span>Chia sẻ</span>
        </button>

        <button
          type="button"
          onClick={() => onShowToast('Tùy chọn khác', 'Xuất bản phụ đề SRT, tách âm thanh MP3, trích xuất hình ảnh')}
          className="flex items-center justify-center gap-1.5 py-2 px-2.5 rounded-xl bg-[#142441] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50 hover:bg-[#3867FF]/15 transition-all text-xs font-medium cursor-pointer active:scale-[0.98]"
        >
          <MoreHorizontal className="w-3.5 h-3.5 text-[#A5B5D4]" />
          <span>Khác</span>
        </button>
      </div>
    </div>
  );
};
