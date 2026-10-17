import React, { useState } from 'react';
import { 
  Clock, 
  MoreVertical, 
  CheckCircle2, 
  Play, 
  Download, 
  Trash2, 
  ExternalLink 
} from 'lucide-react';
import type { ProjectItem } from '../types';

interface RecentProjectsProps {
  onSelectProject: (title: string) => void;
  onShowToast: (title: string, description?: string, type?: 'success' | 'info' | 'warning') => void;
}

const INITIAL_PROJECTS: ProjectItem[] = [
  {
    id: 'proj-1',
    title: 'Video áo thun HV',
    duration: '30 giây',
    aspectRatio: '16:9',
    createdAt: '17/10/2025 09:12',
    status: 'completed',
    thumbnail: '/hero_fashion_sunrise.jpg',
  },
  {
    id: 'proj-2',
    title: 'Giới thiệu sản phẩm công nghệ',
    duration: '25 giây',
    aspectRatio: '9:16',
    createdAt: '16/10/2025 21:45',
    status: 'completed',
    thumbnail: '/project_tech_product.jpg',
  },
  {
    id: 'proj-3',
    title: 'Video du lịch Đà Lạt',
    duration: '45 giây',
    aspectRatio: '16:9',
    createdAt: '15/10/2025 18:30',
    status: 'completed',
    thumbnail: '/project_dalat_travel.jpg',
  },
];

export const RecentProjects: React.FC<RecentProjectsProps> = ({ 
  onSelectProject, 
  onShowToast 
}) => {
  const [projects, setProjects] = useState<ProjectItem[]>(INITIAL_PROJECTS);
  const [activeMenuId, setActiveMenuId] = useState<string | null>(null);

  const handleDelete = (id: string, title: string) => {
    setProjects(projects.filter((p) => p.id !== id));
    setActiveMenuId(null);
    onShowToast('Đã xóa dự án', `Đã xóa dự án "${title}" khỏi danh sách`, 'info');
  };

  return (
    <div className="bg-[#0B172B] border border-[#203455] rounded-xl p-4 sm:p-5 flex flex-col justify-between shadow-xl text-left relative">
      {/* Header */}
      <div>
        <div className="flex items-center justify-between pb-3 border-b border-[#203455] mb-3">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-[#3867FF]" />
            <h3 className="text-sm font-bold text-white">Dự án gần đây</h3>
          </div>
          <button 
            type="button"
            onClick={() => onShowToast('Thư viện dự án', 'Mở toàn bộ 24 dự án video đã tạo')}
            className="text-xs text-[#3867FF] hover:underline font-medium cursor-pointer"
          >
            Xem tất cả
          </button>
        </div>

        {/* Projects List */}
        <div className="divide-y divide-[#203455]/70">
          {projects.map((project) => (
            <div 
              key={project.id}
              className="py-2.5 first:pt-1 last:pb-1 flex items-center justify-between group hover:bg-[#0D1B32]/60 px-2 rounded-lg transition-colors relative"
            >
              {/* Left: Thumbnail + Info */}
              <div 
                className="flex items-center gap-3 cursor-pointer min-w-0 flex-1"
                onClick={() => {
                  onSelectProject(project.title);
                  onShowToast('Mở dự án', `Đang tải dữ liệu: ${project.title}`);
                }}
              >
                {/* Thumbnail */}
                <div className="relative w-16 sm:w-20 aspect-video rounded-md overflow-hidden bg-black/50 border border-[#203455] shrink-0 group-hover:border-[#3867FF]/60 transition-colors">
                  <img 
                    src={project.thumbnail} 
                    alt={project.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                  <div className="absolute inset-0 bg-black/25 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <Play className="w-3.5 h-3.5 text-white fill-white" />
                  </div>
                </div>

                {/* Details */}
                <div className="min-w-0 pr-2">
                  <h4 className="text-xs font-semibold text-white group-hover:text-[#3867FF] transition-colors truncate">
                    {project.title}
                  </h4>
                  <p className="text-[11px] text-[#A5B5D4] font-mono mt-0.5 truncate">
                    {project.duration} · {project.aspectRatio} · {project.createdAt}
                  </p>
                </div>
              </div>

              {/* Right: Status badge & Menu */}
              <div className="flex items-center gap-2.5 shrink-0">
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-[#10B981]/15 text-[#10B981] border border-[#10B981]/30">
                  <CheckCircle2 className="w-2.5 h-2.5" />
                  Đã hoàn thành
                </span>

                <div className="relative">
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      setActiveMenuId(activeMenuId === project.id ? null : project.id);
                    }}
                    className="w-7 h-7 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] flex items-center justify-center transition-colors cursor-pointer"
                    title="Tùy chọn dự án"
                  >
                    <MoreVertical className="w-3.5 h-3.5" />
                  </button>

                  {/* Dropdown Menu */}
                  {activeMenuId === project.id && (
                    <div 
                      onClick={(e) => e.stopPropagation()}
                      className="absolute right-0 bottom-full mb-1 w-36 bg-[#0B172B] border border-[#203455] rounded-xl shadow-2xl p-1 z-50 text-xs animate-in fade-in duration-100"
                    >
                      <button
                        onClick={() => {
                          setActiveMenuId(null);
                          onShowToast('Tải video', `Đang tải file MP4 của ${project.title}`, 'success');
                        }}
                        className="w-full flex items-center gap-2 px-2.5 py-1.5 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] text-left"
                      >
                        <Download className="w-3 h-3 text-[#10B981]" />
                        <span>Tải MP4</span>
                      </button>

                      <button
                        onClick={() => {
                          setActiveMenuId(null);
                          onSelectProject(project.title);
                          onShowToast('Mở trình xem', project.title);
                        }}
                        className="w-full flex items-center gap-2 px-2.5 py-1.5 rounded-lg text-[#A5B5D4] hover:text-white hover:bg-[#142441] text-left"
                      >
                        <ExternalLink className="w-3 h-3 text-[#3867FF]" />
                        <span>Xem chi tiết</span>
                      </button>

                      <div className="my-1 border-t border-[#203455]" />

                      <button
                        onClick={() => handleDelete(project.id, project.title)}
                        className="w-full flex items-center gap-2 px-2.5 py-1.5 rounded-lg text-red-400 hover:text-red-300 hover:bg-red-500/10 text-left"
                      >
                        <Trash2 className="w-3 h-3" />
                        <span>Xóa dự án</span>
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}

          {projects.length === 0 && (
            <div className="py-6 text-center text-xs text-[#A5B5D4]">
              Chưa có dự án nào gần đây. Hãy tạo video mới!
            </div>
          )}
        </div>
      </div>

      {/* Footer Info */}
      <div className="pt-2 text-[11px] text-[#A5B5D4]/60 flex items-center justify-between border-t border-[#203455]/50 mt-2">
        <span>Tự động lưu trữ đám mây</span>
        <span>Bộ nhớ dùng: 1.2 GB / 25 GB</span>
      </div>
    </div>
  );
};
