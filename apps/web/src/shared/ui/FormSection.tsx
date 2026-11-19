import type { ReactNode } from 'react';
import styles from './FormSection.module.css';

/**
 * Figma `FormSection`. 폼 항목 하나: 제목(+ 필수 `*`, 힌트) 아래에 입력 컴포넌트를 둔다.
 * `htmlFor`를 주면 제목이 그 입력의 label이 된다.
 */
export function FormSection({
  title,
  required = false,
  hint,
  htmlFor,
  children,
}: {
  title: string;
  required?: boolean;
  hint?: string;
  htmlFor?: string;
  children: ReactNode;
}) {
  return (
    <div className={styles.section}>
      <div className={styles.header}>
        <label className={styles.title} htmlFor={htmlFor}>
          {title}
          {required && <span aria-hidden="true"> *</span>}
        </label>
        {hint && <span className={styles.hint}>{hint}</span>}
      </div>
      {children}
    </div>
  );
}
