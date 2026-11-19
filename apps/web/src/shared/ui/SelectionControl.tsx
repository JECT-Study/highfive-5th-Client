import type { InputHTMLAttributes, ReactNode } from 'react';
import styles from './SelectionControl.module.css';

type ControlProps = Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> & {
  /** 옆에 보일 글자. 누르는 영역에 함께 들어간다 */
  children?: ReactNode;
};

/** Figma `Checkbox`. 실제 `<input type="checkbox">`를 숨겨 두고 Figma 모양을 그린다 */
export function Checkbox({ children, className, ...rest }: ControlProps) {
  return (
    <label className={[styles.control, className].filter(Boolean).join(' ')}>
      <input {...rest} type="checkbox" className={styles.native} />
      <span className={styles.target} aria-hidden="true">
        <span className={styles.checkbox}>
          <svg className={styles.check} viewBox="0 0 14 14">
            <path
              d="M12.149 4.181C12.2649 4.29705 12.33 4.45435 12.33 4.61836C12.33 4.78237 12.2649 4.93968 12.149 5.05572L6.37254 10.8322C6.25649 10.9481 6.09919 11.0132 5.93518 11.0132C5.77117 11.0132 5.61386 10.9481 5.49782 10.8322L2.19698 7.53135C2.13618 7.47469 2.08741 7.40636 2.05358 7.33044C2.01975 7.25452 2.00156 7.17257 2.0001 7.08947C1.99863 7.00637 2.01392 6.92382 2.04504 6.84676C2.07617 6.76969 2.1225 6.69969 2.18127 6.64092C2.24004 6.58215 2.31005 6.53582 2.38711 6.50469C2.46418 6.47356 2.54672 6.45827 2.62982 6.45974C2.71293 6.46121 2.79488 6.47939 2.8708 6.51322C2.94672 6.54705 3.01504 6.59582 3.07171 6.65663L5.93518 9.5201L11.2743 4.181C11.3903 4.0651 11.5476 4 11.7116 4C11.8756 4 12.033 4.0651 12.149 4.181Z"
              fill="currentColor"
            />
          </svg>
        </span>
      </span>
      {children}
    </label>
  );
}

/** Figma `Radio Button`. 같은 `name`끼리 하나만 고른다 */
export function Radio({ children, className, ...rest }: ControlProps) {
  return (
    <label className={[styles.control, className].filter(Boolean).join(' ')}>
      <input {...rest} type="radio" className={styles.native} />
      <span className={styles.target} aria-hidden="true">
        <span className={styles.radio} />
      </span>
      {children}
    </label>
  );
}
