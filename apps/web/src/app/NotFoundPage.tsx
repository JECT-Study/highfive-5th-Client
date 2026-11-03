import { Link } from 'react-router';
import styles from './NotFoundPage.module.css';
import { routes } from './routes';

export function NotFoundPage() {
  return (
    <main className={styles.page}>
      <h1>페이지를 찾을 수 없어요</h1>
      <p>주소가 바뀌었거나 없는 페이지예요.</p>
      <Link className={styles.link} to={routes.home}>
        처음으로 가기
      </Link>
    </main>
  );
}
