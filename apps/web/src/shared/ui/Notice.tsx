import type { ReactNode } from 'react';
import styles from './Notice.module.css';

/** Figma `Notice` 종류: info = Default(회색 안내), warning = Warning(붉은 경고) */
export type NoticeType = 'info' | 'warning';

/** Figma `Notice` 안내 띠. 아이콘은 `icon`·`trailing`에 넣는다 (24 × 24) */
export function Notice({
  type = 'info',
  icon,
  trailing,
  children,
}: {
  type?: NoticeType;
  icon?: ReactNode;
  trailing?: ReactNode;
  children: ReactNode;
}) {
  return (
    <div
      className={[styles.notice, styles[type]].join(' ')}
      role={type === 'warning' ? 'alert' : undefined}
    >
      {icon && <span className={styles.icon}>{icon}</span>}
      <p className={styles.message}>{children}</p>
      {trailing && <span className={styles.icon}>{trailing}</span>}
    </div>
  );
}
