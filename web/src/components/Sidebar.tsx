import React from 'react';
import { 
  Home, 
  Video, 
  Folder, 
  LayoutTemplate, 
  Settings, 
  Rocket, 
  Crown 
} from 'lucide-react';
import type { SidebarTabType } from '../types';

interface SidebarProps {
  currentTab: SidebarTabType;
  onTabChange: (tab: SidebarTabType) => void;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ currentTab, onTabChange, onShowToast }) => {
  const menuItems = [
    { id: 'home' as SidebarTabType, label: 'Trang chủ', icon: Home },
    { id: 'create' as SidebarTabType, label: 'Tạo video', icon: Video },
    { id: 'library' as SidebarTabType, label: 'Thư viện', icon: Folder },
    { id: 'templates' as SidebarTabType, label: 'Mẫu video', icon: LayoutTemplate },
    { id: 'settings' as SidebarTabType, label: 'Cài đặt', icon: Settings },
  ];

  return (
    <aside className="w-[235px] shrink-0 bg-[#081326] border-r border-[#203455] flex flex-col justify-between p-3.5 select-none min-h-[calc(100vh-76px)]">
      {/* Navigation Menu */}
      <div className="space-y-1.5">
        <div className="px-3 py-2 text-[11px] font-semibold tracking-wider text-[#A5B5D4]/60 uppercase">
          Menu chính
        </div>
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => {
                onTabChange(item.id);
                if (item.id !== 'home') {
                  onShowToast(`Chuyển mục: ${item.label}`, 'Đang hiển thị chế độ xem tương ứng');
                }
              }}
              className={`w-full flex items-center gap-3 px-3.5 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 cursor-pointer ${
                isActive
                  ? 'bg-gradient-to-r from-[#3867FF] to-[#6246F5] text-white shadow-md shadow-[#3867FF]/25 font-semibold'
                  : 'text-[#A5B5D4] hover:text-[#F1F5FF] hover:bg-[#142441]'
              }`}
            >
              <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-[#A5B5D4]'}`} />
              <span>{item.label}</span>
              {item.id === 'create' && (
                <span className="ml-auto text-[10px] bg-[#3867FF]/20 text-[#3867FF] px-1.5 py-0.5 rounded font-bold border border-[#3867FF]/30">
                  AI
                </span>
              )}
            </button>
          );
        })}
      </div>

      {/* Promotion Card */}
      <div className="mt-auto pt-4">
        <div className="relative overflow-hidden rounded-xl bg-gradient-to-b from-[#0D1B32] to-[#0B172B] border border-[#203455] p-3.5 text-left shadow-lg">
          {/* Subtle Ambient Glow */}
          <div className="absolute -top-12 -right-12 w-28 h-28 bg-[#3867FF]/20 rounded-full blur-2xl pointer-events-none" />

          {/* Rocket Icon */}
          <div className="w-9 h-9 rounded-lg bg-gradient-to-tr from-[#3867FF] to-[#6246F5] flex items-center justify-center text-white mb-2.5 shadow-md shadow-[#3867FF]/30">
            <Rocket className="w-4 h-4" />
          </div>

          <h4 className="text-xs font-bold text-white mb-1">
            Tạo video nhanh hơn với AI
          </h4>
          <p className="text-[11px] leading-relaxed text-[#A5B5D4] mb-3">
            Tiết kiệm thời gian, nâng cao hiệu suất sáng tạo của bạn.
          </p>

          <button
            onClick={() => onShowToast('Nâng cấp Pro', 'Chuyển hướng đến cổng thanh toán gói Pro vĩnh viễn', 'success')}
            className="w-full flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg bg-gradient-to-r from-[#3867FF] to-[#6246F5] hover:opacity-95 text-white font-semibold text-xs transition-all shadow-md shadow-[#3867FF]/30 cursor-pointer active:scale-[0.98]"
          >
            <Crown className="w-3.5 h-3.5 text-yellow-300 fill-yellow-300" />
            <span>Nâng cấp Pro</span>
          </button>
        </div>

        {/* System Status info */}
        <div className="mt-3 px-2 flex items-center justify-between text-[11px] text-[#A5B5D4]/60">
          <span>Phiên bản v2.4.0</span>
          <span className="flex items-center gap-1 text-[#10B981]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#10B981] animate-pulse" />
            AI Ready
          </span>
        </div>
      </div>
    </aside>
  );
};
