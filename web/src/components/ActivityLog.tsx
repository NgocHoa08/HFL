import React, { useRef, useEffect } from 'react';
import { 
  ClipboardList, 
  Trash2, 
  CheckCircle2, 
  Sparkles, 
  Cpu, 
  Image as ImageIcon, 
  Wand2, 
  Subtitles, 
  Film
} from 'lucide-react';
import type { LogEntry } from '../types';

interface ActivityLogProps {
  logs: LogEntry[];
  onClearLogs: () => void;
  isGenerating: boolean;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
}

export const ActivityLog: React.FC<ActivityLogProps> = ({ 
  logs, 
  onClearLogs, 
  isGenerating,
  onShowToast 
}) => {
  const logContainerRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on new log
  useEffect(() => {
    if (logContainerRef.current) {
      logContainerRef.current.scrollTop = logContainerRef.current.scrollHeight;
    }
  }, [logs]);

  const getLogIcon = (type: string, message: string) => {
    if (type === 'success' || message.includes('Hoàn thành')) {
      return <CheckCircle2 className="w-3.5 h-3.5 text-[#10B981] shrink-0" />;
    }
    if (message.includes('xử lý')) {
      return <Cpu className="w-3.5 h-3.5 text-[#3867FF] shrink-0" />;
    }
    if (message.includes('hình ảnh')) {
      return <ImageIcon className="w-3.5 h-3.5 text-cyan-400 shrink-0" />;
    }
    if (message.includes('Ghép') || message.includes('hiệu ứng')) {
      return <Wand2 className="w-3.5 h-3.5 text-[#6246F5] shrink-0" />;
    }
    if (message.includes('phụ đề')) {
      return <Subtitles className="w-3.5 h-3.5 text-amber-400 shrink-0" />;
    }
    if (message.includes('render')) {
      return <Film className="w-3.5 h-3.5 text-pink-400 shrink-0" />;
    }
    return <Sparkles className="w-3.5 h-3.5 text-[#3867FF] shrink-0" />;
  };

  return (
    <div className="bg-[#0B172B] border border-[#203455] rounded-xl p-4 sm:p-5 flex flex-col justify-between shadow-xl text-left relative">
      {/* Header */}
      <div>
        <div className="flex items-center justify-between pb-3 border-b border-[#203455] mb-3">
          <div className="flex items-center gap-2">
            <ClipboardList className="w-4 h-4 text-[#3867FF]" />
            <h3 className="text-sm font-bold text-white">Nhật ký hoạt động</h3>
            {isGenerating && (
              <span className="flex items-center gap-1 text-[10px] text-[#3867FF] font-semibold bg-[#3867FF]/10 border border-[#3867FF]/30 px-2 py-0.5 rounded-full animate-pulse">
                <span className="w-1.5 h-1.5 rounded-full bg-[#3867FF]" />
                Đang xử lý
              </span>
            )}
          </div>

          <button
            type="button"
            onClick={() => {
              onClearLogs();
              onShowToast('Đã xóa log', 'Nhật ký hoạt động đã được làm trống', 'info');
            }}
            className="flex items-center gap-1.5 text-xs text-[#A5B5D4] hover:text-white hover:bg-[#142441] px-2 py-1 rounded-lg border border-transparent hover:border-[#203455] transition-all cursor-pointer"
            title="Xóa toàn bộ nhật ký"
          >
            <Trash2 className="w-3.5 h-3.5" />
            <span>Xóa log</span>
          </button>
        </div>

        {/* Log Lines Box */}
        <div 
          ref={logContainerRef}
          className="h-[148px] overflow-y-auto bg-[#081326] border border-[#203455] rounded-xl p-3 font-mono text-[11px] leading-relaxed space-y-1.5 scrollbar-thin"
        >
          {logs.map((log) => {
            const isSuccess = log.type === 'success' || log.message.includes('Hoàn thành');
            return (
              <div 
                key={log.id} 
                className={`flex items-start gap-2.5 transition-colors py-0.5 ${
                  isSuccess 
                    ? 'text-[#10B981] font-semibold' 
                    : 'text-[#F1F5FF]'
                }`}
              >
                {/* Timestamp */}
                <span className="text-[#A5B5D4]/70 select-none shrink-0 font-medium">
                  {log.timestamp}
                </span>

                {/* Separator dash */}
                <span className="text-[#203455] select-none shrink-0">—</span>

                {/* Status Icon */}
                <span className="mt-0.5 shrink-0">
                  {getLogIcon(log.type, log.message)}
                </span>

                {/* Message text */}
                <span className="flex-1 break-words">
                  {log.message}
                </span>
              </div>
            );
          })}

          {logs.length === 0 && (
            <div className="h-full flex flex-col items-center justify-center text-[#A5B5D4]/60">
              <ClipboardList className="w-6 h-6 mb-1 opacity-50" />
              <span>Chưa có nhật ký hoạt động</span>
            </div>
          )}
        </div>
      </div>

      {/* Footer System Status */}
      <div className="pt-2 text-[11px] text-[#A5B5D4]/60 flex items-center justify-between border-t border-[#203455]/50 mt-2">
        <span className="flex items-center gap-1.5">
          <span className="w-1.5 h-1.5 rounded-full bg-[#10B981]" />
          Máy chủ AI: Hoạt động bình thường
        </span>
        <span className="font-mono">Độ trễ: 24ms</span>
      </div>
    </div>
  );
};
