export type SourceTabType = 'text' | 'image' | 'link' | 'file';

export type SidebarTabType = 'home' | 'create' | 'library' | 'templates' | 'settings';

export interface Scene {
  id: number;
  timeRange: string;
  title: string;
  thumbnail: string;
  duration: number; // in seconds
}

export interface ProjectItem {
  id: string;
  title: string;
  duration: string;
  aspectRatio: string;
  createdAt: string;
  status: 'completed' | 'processing' | 'failed';
  thumbnail: string;
}

export interface LogEntry {
  id: string;
  timestamp: string;
  message: string;
  type: 'info' | 'progress' | 'success' | 'warn';
  icon?: string;
}

export interface ToastMessage {
  id: string;
  title: string;
  description?: string;
  type?: 'success' | 'info' | 'warning';
}
