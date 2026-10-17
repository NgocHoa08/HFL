import React, { useState } from 'react';
import { 
  Bell, 
  ChevronDown, 
  User, 
  Settings, 
  CreditCard, 
  LogOut, 
  SlidersHorizontal
} from 'lucide-react';

interface HeaderProps {
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
}

export const Header: React.FC<HeaderProps> = ({ onShowToast }) => {
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [hasUnread, setHasUnread] = useState(true);

  return (
    <header className="h-[76px] bg-[#071225] border-b border-[#203455] px-6 flex items-center justify-between sticky top-0 z-40 select-none">
      {/* Left: Brand & Tagline */}
      <div className="flex items-center gap-4">
        {/* Logo */}
        <div className="flex items-center gap-3 cursor-pointer group" onClick={() => onShowToast('HaizFlow AI', 'Bạn đang ở trang chủ')}>
          <div className="w-11 h-11 rounded-xl bg-gradient-to-tr from-[#3867FF] to-[#6246F5] p-[1px] shadow-lg shadow-[#3867FF]/20 flex items-center justify-center transition-transform group-hover:scale-105">
            <div className="w-full h-full bg-[#081326] rounded-[11px] flex items-center justify-center overflow-hidden relative">
              <div className="absolute inset-0 bg-gradient-to-tr from-[#3867FF]/30 to-[#6246F5]/40 opacity-80" />
              {/* Stylized Play Triangle */}
              <svg 
                className="w-5 h-5 text-white ml-0.5 relative z-10 drop-shadow" 
                viewBox="0 0 24 24" 
                fill="currentColor"
              >
                <path d="M5 3.868v16.264c0 .858.948 1.373 1.666.907l13.12-8.132a1.07 1.07 0 0 0 0-1.814L6.666 2.96C5.948 2.495 5 3.01 5 3.868z" />
              </svg>
            </div>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="text-xl font-bold tracking-tight text-white font-['Inter']">HaizFlow</span>
              <span className="text-[10px] font-semibold uppercase tracking-wider px-1.5 py-0.5 rounded bg-gradient-to-r from-[#3867FF]/20 to-[#6246F5]/20 text-[#3867FF] border border-[#3867FF]/30">PRO</span>
            </div>
            <p className="text-xs text-[#A5B5D4] hidden sm:block">
              Tạo video dễ dàng - Biến ý tưởng thành hiện thực
            </p>
          </div>
        </div>
      </div>

      {/* Right: Controls & User Profile */}
      <div className="flex items-center gap-4">
        {/* Style/Effect trigger button */}
        <button 
          onClick={() => onShowToast('Tùy chỉnh giao diện', 'Đang sử dụng chủ đề Cyber Navy cao cấp')}
          className="w-10 h-10 rounded-xl bg-[#0D1B32] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50 hover:bg-[#142441] flex items-center justify-center transition-all cursor-pointer"
          title="Tùy chọn giao diện"
        >
          <SlidersHorizontal className="w-4 h-4" />
        </button>

        {/* Notifications */}
        <div className="relative">
          <button 
            onClick={() => {
              setShowNotifications(!showNotifications);
              setHasUnread(false);
            }}
            className="w-10 h-10 rounded-xl bg-[#0D1B32] border border-[#203455] text-[#A5B5D4] hover:text-white hover:border-[#3867FF]/50 hover:bg-[#142441] flex items-center justify-center transition-all relative cursor-pointer"
            title="Thông báo"
          >
            <Bell className="w-4 h-4" />
            {hasUnread && (
              <span className="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-red-500 ring-2 ring-[#0D1B32] animate-pulse" />
            )}
          </button>

          {/* Notifications Dropdown */}
          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-[#0B172B] border border-[#203455] rounded-xl shadow-2xl z-50 p-3 text-sm animate-in fade-in slide-in-from-top-2 duration-150">
              <div className="flex items-center justify-between pb-2 border-b border-[#203455] mb-2">
                <span className="font-semibold text-white">Thông báo</span>
                <span className="text-[11px] text-[#3867FF] cursor-pointer hover:underline" onClick={() => onShowToast('Đã đọc', 'Đã đánh dấu tất cả là đã đọc')}>Đánh dấu đã đọc</span>
              </div>
              <div className="space-y-2">
                <div className="p-2.5 rounded-lg bg-[#0D1B32] border border-[#203455]/60 flex items-start gap-2.5">
                  <div className="w-2 h-2 rounded-full bg-[#10B981] mt-1.5 shrink-0" />
                  <div>
                    <p className="text-xs font-medium text-white">Video áo thun HV đã render xong</p>
                    <p className="text-[11px] text-[#A5B5D4] mt-0.5">Sẵn sàng để tải xuống chất lượng 1080p</p>
                    <span className="text-[10px] text-[#A5B5D4]/70 mt-1 block">5 phút trước</span>
                  </div>
                </div>
                <div className="p-2.5 rounded-lg bg-[#0D1B32] border border-[#203455]/60 flex items-start gap-2.5">
                  <div className="w-2 h-2 rounded-full bg-[#3867FF] mt-1.5 shrink-0" />
                  <div>
                    <p className="text-xs font-medium text-white">Tính năng giọng đọc AI mới</p>
                    <p className="text-[11px] text-[#A5B5D4] mt-0.5">Thêm 4 giọng đọc tiếng Việt mượt mà</p>
                    <span className="text-[10px] text-[#A5B5D4]/70 mt-1 block">1 giờ trước</span>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* User Account Pill */}
        <div className="relative">
          <div 
            onClick={() => setShowUserMenu(!showUserMenu)}
            className="flex items-center gap-3 pl-2 pr-3 py-1.5 rounded-xl bg-[#0D1B32] border border-[#203455] hover:border-[#3867FF]/50 hover:bg-[#142441] transition-all cursor-pointer"
          >
            {/* Avatar */}
            <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-[#3867FF] to-[#6246F5] flex items-center justify-center text-white font-bold text-sm shadow-md shadow-[#3867FF]/20">
              H
            </div>
            {/* Account Info */}
            <div className="text-left hidden sm:block">
              <div className="text-sm font-semibold text-white leading-tight">Hòa Ngọc</div>
              <div className="text-[11px] text-[#10B981] font-medium flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-[#10B981]" />
                Online
              </div>
            </div>
            <ChevronDown className={`w-4 h-4 text-[#A5B5D4] transition-transform duration-200 ${showUserMenu ? 'rotate-180 text-white' : ''}`} />
          </div>

          {/* Account Dropdown */}
          {showUserMenu && (
            <div className="absolute right-0 mt-2 w-56 bg-[#0B172B] border border-[#203455] rounded-xl shadow-2xl z-50 p-1.5 text-sm animate-in fade-in slide-in-from-top-2 duration-150">
              <div className="px-3 py-2 border-b border-[#203455] mb-1">
                <p className="text-xs text-[#A5B5D4]">Đăng nhập với</p>
                <p className="font-semibold text-white truncate">hoangoc@haizflow.ai</p>
              </div>

              <button 
                onClick={() => { setShowUserMenu(false); onShowToast('Hồ sơ tài khoản', 'Mở thông tin tài khoản Hòa Ngọc'); }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] text-xs transition-colors text-left"
              >
                <User className="w-4 h-4 text-[#3867FF]" />
                Hồ sơ cá nhân
              </button>

              <button 
                onClick={() => { setShowUserMenu(false); onShowToast('Gói đăng ký Pro', 'Tài khoản Pro của bạn còn 28 ngày'); }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] text-xs transition-colors text-left"
              >
                <CreditCard className="w-4 h-4 text-[#6246F5]" />
                Gói dịch vụ & Hóa đơn
              </button>

              <button 
                onClick={() => { setShowUserMenu(false); onShowToast('Cài đặt', 'Mở cài đặt hệ thống HaizFlow'); }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] text-xs transition-colors text-left"
              >
                <Settings className="w-4 h-4 text-[#A5B5D4]" />
                Cài đặt chung
              </button>

              <div className="my-1 border-t border-[#203455]" />

              <button 
                onClick={() => { setShowUserMenu(false); onShowToast('Đăng xuất', 'Đã chuyển về phiên làm việc hiện tại'); }}
                className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg text-red-400 hover:text-red-300 hover:bg-red-500/10 text-xs transition-colors text-left"
              >
                <LogOut className="w-4 h-4" />
                Đăng xuất
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};
