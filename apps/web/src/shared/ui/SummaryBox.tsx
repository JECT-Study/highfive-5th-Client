import styles from './SummaryBox.module.css';

type SummaryBoxProps = {
  readonly rows: ReadonlyArray<{ readonly label: string; readonly value: string }>;
};

/** V3 SummaryBox(2014:19752). Dialog 내용 등에서 이름과 값을 짝지어 표시한다. */
export function SummaryBox({ rows }: SummaryBoxProps) {
  return (
    <dl className={styles.box}>
      {rows.map(({ label, value }) => (
        <div key={label} className={styles.row}>
          <dt className={styles.label}>{label}</dt>
          <dd className={styles.value}>{value}</dd>
        </div>
      ))}
    </dl>
  );
}
