import styles from './SectionDivider.module.css';

/** Figma `Divider`. 화면 구역 사이 두꺼운 회색 띠 */
export function SectionDivider() {
  return <hr className={styles.divider} />;
}
