import { useState, type TextareaHTMLAttributes } from 'react';
import styles from './TextArea.module.css';

/**
 * Figma `TextArea` 여러 줄 입력창. `maxLength`가 있으면 입력칸 안 오른쪽 아래에 `글자 수/최대`를 보인다.
 */
export function TextArea({
  maxLength,
  className,
  onChange,
  defaultValue,
  value,
  ...rest
}: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  const [ownLength, setOwnLength] = useState(String(defaultValue ?? '').length);
  const length = value === undefined ? ownLength : String(value).length;

  return (
    <div className={[styles.field, rest.disabled && styles.disabled].filter(Boolean).join(' ')}>
      <textarea
        {...rest}
        value={value}
        defaultValue={defaultValue}
        maxLength={maxLength}
        className={[styles.input, className].filter(Boolean).join(' ')}
        onChange={(event) => {
          setOwnLength(event.target.value.length);
          onChange?.(event);
        }}
      />
      {maxLength !== undefined && (
        <span className={styles.counter} aria-hidden="true">
          {length}/{maxLength}
        </span>
      )}
    </div>
  );
}
