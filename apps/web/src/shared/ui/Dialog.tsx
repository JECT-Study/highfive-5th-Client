import { useEffect, useId, type ReactNode } from 'react';
import { Button } from './Button';
import styles from './Dialog.module.css';

type DialogProps = {
  open: boolean;
  title: string;
  message?: ReactNode;
  icon?: ReactNode;
  confirmLabel: string;
  /** 없으면 확인 버튼 하나만 보인다 */
  cancelLabel?: string;
  /** 확인 버튼을 danger(빨간 바탕)로 보인다 */
  destructive?: boolean;
  onConfirm: () => void;
  /** 취소, 바깥 누르기, Esc */
  onCancel: () => void;
};

/**
 * Figma `Dialog`. 열림 여부는 화면이 `open`으로 정한다.
 * 결과가 남는 명령(삭제·취소 등)은 `onConfirm`에서 화면의 명령 함수를 부른다.
 */
export function Dialog({
  open,
  title,
  message,
  icon,
  confirmLabel,
  cancelLabel,
  destructive = false,
  onConfirm,
  onCancel,
}: DialogProps) {
  const titleId = useId();

  useEffect(() => {
    if (!open) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onCancel();
    };
    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, [open, onCancel]);

  if (!open) return null;

  return (
    <div className={styles.backdrop} onClick={onCancel}>
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        className={styles.dialog}
        onClick={(event) => event.stopPropagation()}
      >
        {icon}
        <h2 id={titleId} className={styles.title}>
          {title}
        </h2>
        {message && <p className={styles.message}>{message}</p>}
        <div className={styles.actions}>
          {cancelLabel && (
            <Button variant="weak" onClick={onCancel}>
              {cancelLabel}
            </Button>
          )}
          <Button variant={destructive ? 'danger' : 'fill'} onClick={onConfirm} autoFocus>
            {confirmLabel}
          </Button>
        </div>
      </div>
    </div>
  );
}
