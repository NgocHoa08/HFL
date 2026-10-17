import { useState } from 'react';
import { Header } from './components/Header';
import { Sidebar } from './components/Sidebar';
import { CreateVideoPanel } from './components/CreateVideoPanel';
import { VideoPreviewPanel } from './components/VideoPreviewPanel';
import { RecentProjects } from './components/RecentProjects';
import { ActivityLog } from './components/ActivityLog';
import { ToastNotification } from './components/ToastNotification';
import type { SidebarTabType, LogEntry, ToastMessage } from './types';

const INITIAL_LOGS: LogEntry[] = [
  { id: '1', timestamp: '09:12:34', message: 'Bắt đầu tạo video...', type: 'info' },
  { id: '2', timestamp: '09:12:35', message: 'Đang xử lý nội dung bằng AI...', type: 'progress' },
  { id: '3', timestamp: '09:12:42', message: 'Tạo hình ảnh minh họa (5/5)...', type: 'progress' },
  { id: '4', timestamp: '09:12:46', message: 'Ghép video và thêm hiệu ứng...', type: 'progress' },
  { id: '5', timestamp: '09:12:52', message: 'Thêm phụ đề...', type: 'progress' },
  { id: '6', timestamp: '09:12:55', message: 'Đang render video...', type: 'progress' },
  { id: '7', timestamp: '09:13:08', message: 'Hoàn thành! Video đã được tạo thành công.', type: 'success' },
];

export function App() {
  const [currentSidebarTab, setCurrentSidebarTab] = useState<SidebarTabType>('home');
  const [activeSceneId, setActiveSceneId] = useState<number>(3); // Scene 3 (0:08 - 0:12) as in spec
  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [logs, setLogs] = useState<LogEntry[]>(INITIAL_LOGS);
  const [toasts, setToasts] = useState<ToastMessage[]>([]);

  const addToast = (title: string, description?: string, type: 'success' | 'info' | 'warning' = 'info') => {
    const id = Date.now().toString() + Math.random().toString(36).substring(2, 5);
    setToasts((prev) => [...prev, { id, title, description, type }]);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const handleClearLogs = () => {
    setLogs([]);
  };

  // Format current time HH:MM:SS
  const getCurrentTimeString = () => {
    const now = new Date();
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
  };

  // Simulated AI Video Generation Pipeline
  const handleGenerateVideo = (prompt: string, style: string, ratio: string, duration: string, voice: string) => {
    if (isGenerating) return;

    setIsGenerating(true);
    addToast('Bắt đầu tạo video AI', `Thời lượng: ${duration} · Phong cách: ${style} · Tỷ lệ: ${ratio}`, 'info');

    const steps = [
      { delay: 400, message: 'Bắt đầu tạo video mới...', type: 'info' as const },
      { delay: 1500, message: `Phân tích kịch bản: "${prompt.slice(0, 40)}..."`, type: 'progress' as const },
      { delay: 3000, message: `Tạo hình ảnh minh họa độ phân giải cao theo tỷ lệ ${ratio}...`, type: 'progress' as const },
      { delay: 4500, message: `Tổng hợp giọng đọc AI (${voice}) và đồng bộ nhịp phách...`, type: 'progress' as const },
      { delay: 6000, message: 'Tạo phụ đề tự động và hiệu ứng chuyển cảnh điện ảnh...', type: 'progress' as const },
      { delay: 7500, message: 'Đang kết xuất video Full HD 1080p 60fps...', type: 'progress' as const },
      { delay: 9000, message: 'Hoàn thành! Video đã được tạo thành công.', type: 'success' as const },
    ];

    steps.forEach((step) => {
      setTimeout(() => {
        setLogs((prev) => [
          ...prev,
          {
            id: Date.now().toString() + Math.random().toString(),
            timestamp: getCurrentTimeString(),
            message: step.message,
            type: step.type,
          },
        ]);

        if (step.type === 'success') {
          setIsGenerating(false);
          setActiveSceneId(1);
          addToast('Video đã hoàn thành!', 'Bạn có thể xem trước, chỉnh sửa hoặc tải về ngay', 'success');
        }
      }, step.delay);
    });
  };

  const handleSelectRecentProject = (title: string) => {
    addToast(`Đang mở: ${title}`, 'Đã tải dữ liệu kịch bản và phân cảnh');
  };

  return (
    <div className="min-h-screen bg-[#071225] text-[#F1F5FF] flex flex-col font-['Inter'] antialiased selection:bg-[#3867FF]/30">
      {/* Top Fixed Header */}
      <Header onShowToast={addToast} />

      {/* Main App Workspace */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left Fixed Sidebar */}
        <Sidebar 
          currentTab={currentSidebarTab} 
          onTabChange={setCurrentSidebarTab} 
          onShowToast={addToast} 
        />

        {/* Dashboard Main Content Area */}
        <main className="flex-1 overflow-y-auto p-3 sm:p-3.5 space-y-3.5 max-w-[1600px] w-full mx-auto">
          {/* Top Row: Video Creator Panel (40%) + Video Preview Panel (60%) */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-3.5 items-stretch">
            {/* Left Column: Create Video Panel (~40%) */}
            <div className="lg:col-span-5 flex flex-col">
              <CreateVideoPanel 
                onGenerate={handleGenerateVideo}
                isGenerating={isGenerating}
                onShowToast={addToast}
              />
            </div>

            {/* Right Column: Video Preview Panel (~60%) */}
            <div className="lg:col-span-7 flex flex-col">
              <VideoPreviewPanel 
                onShowToast={addToast}
                activeSceneId={activeSceneId}
                onSelectScene={setActiveSceneId}
                isGenerating={isGenerating}
              />
            </div>
          </div>

          {/* Bottom Row: Recent Projects (~48%) + Activity Log (~52%) */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-3.5 items-stretch">
            {/* Left: Recent Projects */}
            <div className="lg:col-span-6 flex flex-col">
              <RecentProjects 
                onSelectProject={handleSelectRecentProject}
                onShowToast={addToast}
              />
            </div>

            {/* Right: Activity Log */}
            <div className="lg:col-span-6 flex flex-col">
              <ActivityLog 
                logs={logs}
                onClearLogs={handleClearLogs}
                isGenerating={isGenerating}
                onShowToast={addToast}
              />
            </div>
          </div>
        </main>
      </div>

      {/* Interactive Toast Notifications */}
      <ToastNotification toasts={toasts} onDismiss={removeToast} />
    </div>
  );
}

export default App;
