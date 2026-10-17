import { useEffect } from 'react';
import { CheckCircle2, Info, AlertTriangle, X } from 'lucide-react';
import type { ToastMessage } from '../types';

interface ToastNotificationProps {
  toasts: ToastMessage[];
  onDismiss: (id: string) => void;
}

export const ToastNotification: React.FC<ToastNotificationProps> = ({ toasts, onDismiss }) => {
  return (
    <div className="fixed bottom-5 right-5 z-50 flex flex-col gap-2 pointer-events-none max-w-sm w-full px-4 select-none">
      {toasts.map((toast) => (
        <ToastItem key={toast.id} toast={toast} onDismiss={onDismiss} />
      ))}
    </div>
  );
};

const ToastItem: React.FC<{ toast: ToastMessage; onDismiss: (id: string) => void }> = ({ toast, onDismiss }) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onDismiss(toast.id);
    }, 3500);
    return () => clearTimeout(timer);
  }, [toast.id, onDismiss]);

  const getIcon = () => {
    switch (toast.type) {
      case 'success':
        return <CheckCircle2 className="w-4 h-4 text-[#10B981] shrink-0" />;
      case 'warning':
        return <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0" />;
      default:
        return <Info className="w-4 h-4 text-[#3867FF] shrink-0" />;
    }
  };

  return (
    <div className="pointer-events-auto bg-[#0B172B] border border-[#203455] text-white p-3.5 rounded-xl shadow-2xl flex items-start gap-3 animate-in slide-in-from-bottom-3 duration-200 backdrop-blur-md">
      <div className="mt-0.5">{getIcon()}</div>
      <div className="flex-1 text-left min-w-0">
        <h4 className="text-xs font-bold leading-tight text-white truncate">{toast.title}</h4>
        {toast.description && (
          <p className="text-[11px] text-[#A5B5D4] leading-normal mt-0.5">{toast.description}</p>
        )}
      </div>
      <button
        onClick={() => onDismiss(toast.id)}
        className="text-[#A5B5D4] hover:text-white transition-colors p-0.5 rounded cursor-pointer"
      >
        <X className="w-3.5 h-3.5" />
      </button>
    </div>
  );
};
